import numpy as np
import pandas as pd
import sys
import spacy
sys.path.insert(0, '../LMMS')

from transformers_encoder import TransformersEncoder
from vectorspace import SensesVSM
from wn_utils import WN_Utils

from nltk.corpus import wordnet as wn
from nltk.corpus.reader.wordnet import WordNetError

'''
Helper method to load a pretrained model from Loureiro and Jorge (2019)
This model is trained to disambiguate wordsenses, performing better than more rudimentary options
Such as defaulting to the most-common sense or using a look-up based method like the Lesk algorithm

'''
def load_lmms_models():
	# NLM/LMMS paths and parameters
	vecs_path = '../LMMS/data/vectors/lmms-wsd-roberta/lmms-sp-wsd.roberta-large.vectors.txt'
	wsd_encoder_cfg = {
	    'model_name_or_path': 'roberta-large',
	    'min_seq_len': 0,
	    'max_seq_len': 512,
	    'layers': [-n for n in range(1, 12 + 1)],  # all layers, with reversed indices
	    'layer_op': 'ws',
	    'weights_path': '../LMMS/data/weights/lmms-sp-wsd.roberta-large.weights.txt',
	    'subword_op': 'mean'
	}

	print('Loading NLM and sense embeddings ...')  # (takes a while)
	wsd_encoder = TransformersEncoder(wsd_encoder_cfg)
	senses_vsm = SensesVSM(vecs_path, normalize=True)
	print('Done')
	return wsd_encoder, senses_vsm

'''
Read in .csv of descriptive passages as a Pandas data frame
Add appropriate header to the columns as well.
col names are: 
[blank],passage,book,left_claim,left_claim_keywords,
right_claim,right_claim_keywords,claim_id,passage_id,
passage_size,match_output

'''
def read_as_df(filename):
    # read data
    df = pd.read_csv(filename)
    # filter out first column as well as books that are not Left/Both
    df = df[df['match_output'] != 'Right']
    # drop unneeded row number
    df.drop(['Unnamed: 0'], axis=1, inplace=True)
    return df

'''
Driver method that:
-tags passage with spacy, pulling out every NOUN
-hands off lemmas and their indices (in the doc) to disambiguate lemmas
'''
def tag_passage_with_spacy(passage, target_pos, spacy_tagger, wsd_encoder, senses_vsm):
	# input sentence, with indices of token/span to disambiguate
	doc = spacy_tagger(passage)
	target_idxs = []
	for i, word in enumerate(doc):
		if word.pos_ == target_pos:
			target_idxs.append(i)

	target_lemmas = [doc[i].lemma_ for i in target_idxs]

	passage_nouns = []
	passage_deps = []
	passage_lexs = []

	passage_nouns, passage_deps, passage_lexs = disambiguate_lemmas(target_lemmas, target_idxs, doc, target_pos, wsd_encoder, senses_vsm)

	return passage_nouns, passage_deps, passage_lexs

'''
Helper method to extract the requisite embedding for a given word from the context embedding list
'''
def get_target_embedding(contextual_embeddings, index):
	target_embedding = np.array([contextual_embeddings[index][1]]).mean(axis=0)
	return target_embedding / np.linalg.norm(target_embedding)

def disambiguate_lemmas(lemmas, idxs, doc, target_pos, wsd_encoder, senses_vsm):

	# retrieve contextual embedding for target token/span
	tokens = [t.text for t in doc]
	# gather contextual embeddings from encoder
	contextual_embeddings = wsd_encoder.token_embeddings([tokens])[0]

	nouns = []
	deps = []
	lexs = []

	# get target embedding
	for i in range(len(idxs)):
		# get target embedding
		target_embedding = get_target_embedding(contextual_embeddings, idxs[i])

		# perform lookup
		matches = senses_vsm.match_senses(target_embedding, lemma=lemmas[i], postag=target_pos, topn=1)

		# report matches, showing also additional info from WordNet for each match
		for sk, sim in matches:
			syn = wn_utils.sk2syn(sk)
			lex = wn_utils.sk2lexname(sk)
			nouns.append(lemmas[i])
			deps.append(doc[idxs[i]].dep_)
			lexs.append(lex)
	
	if len(nouns) != len(deps) or len(deps) != len(lexs):
		print(f"mismatch -- nouns: {len(nouns)} deps: {len(deps)} lexs: {(len(lexs))} for {doc}")
		return [], [], []

	return nouns, deps, lexs

def specificity_neural(sample, spacy_tagger, wsd_encoder, senses_vsm, target_pos_list):
	tagged_sample=spacy_tagger(sample)
	hyper_sum = 0
	noun_and_verb_count = 0
	target_pos = []

	target_idxs = []
	for i, word in enumerate(tagged_sample):
		if word.pos_ in target_pos_list:
			target_pos.append(word.pos_)
			target_idxs.append(i)
			noun_and_verb_count += 1

	target_lemmas = [tagged_sample[i].lemma_ for i in target_idxs]

	# retrieve contextual embedding for target token/span
	tokens = [t.text for t in tagged_sample]
	# gather contextual embeddings from encoder
	contextual_embeddings = wsd_encoder.token_embeddings([tokens])[0]

	# get target embedding
	for i in range(len(target_idxs)):
		# get target embedding
		target_embedding = get_target_embedding(contextual_embeddings, target_idxs[i])

		# perform lookup
		matches = senses_vsm.match_senses(target_embedding, lemma=target_lemmas[i], postag=target_pos[i], topn=1)

		# if empty, continue
		if matches is None:
			noun_and_verb_count -= 1
			continue

		# iterate through (single val) tuple
		for sk, sim in matches:

			# get proper synset
			syn = wn_utils.sk2syn(sk)

			# update hyper_sum with the number of nouns in the hypernym chain for that lemma's synset
			# note that it's OK to see this warning https://github.com/nltk/nltk/blob/develop/nltk/corpus/reader/wordnet.py#L594
			hyper_sum += len(list(syn.closure(lambda s: s.hypernyms())))

	# a few 'descriptive' passages lack any actual nouns, control for that
	if noun_and_verb_count == 0:
		return 0

	return hyper_sum / noun_and_verb_count

'''
Consult wordnet for the situation of a noun and verb with respect to its station in the hypernym hierarchy. 
Based on current SOA, it is acceptable to simply grab the top-level (.01) synset.

Args:
    tagged_sample: a spacy doc

Return:
    specificity: a value conveying the "specificity" of the input, via Nelson (2020)
'''

def specificity_normal(sample, spacy_tagger, passage_id):

    tagged_sample=spacy_tagger(sample)
    hyper_sum = 0
    noun_and_verb_count = 0
    for word in tagged_sample:
        if word.pos_ == "NOUN" or word.pos_ == "VERB":
            noun_and_verb_count +=1
            # if it's a verb, get the most common verb hypernym chain
            # else, get the most common noun hypernym chain
            pos = word.pos_
            tag = "n" if pos.startswith("N") else "v"
            synset = word.lemma_ + "." + tag + ".01"    
            # occasionally, an adjective will be misidentified as a noun;
            # in that case, catch the exception (since the word won't a true synset) + fix the count
            try: 
                synset_def = wn.synset(synset)
                # print(f"noun: {word.lemma_}, first_syn: {synset}, calculated syn: {synset_def}")
            except WordNetError as w_e:
                noun_and_verb_count -= 1
                continue
            else:
                hyper_sum +=len(list(synset_def.closure(lambda s: s.hypernyms())))

    # a few 'descriptive' passages lack 
    if noun_and_verb_count == 0:
        return 0
    return hyper_sum / noun_and_verb_count

'''
Helper for reporting 5-number summary of an inputted list
'''
def five_number(data):
    # calculate quartiles
    quartiles = np.percentile(data, [25, 50, 75])
    # calculate min/max
    data_min, data_max = data.min(), data.max()
    # print 5-number summary
    print('Min: %.3f' % data_min)
    print('Q1: %.3f' % quartiles[0])
    print('Median: %.3f' % quartiles[1])
    print('Q3: %.3f' % quartiles[2])
    print('Max: %.3f' % data_max)

if __name__ == '__main__':

	# load spacy
	en_nlp = spacy.load('en_core_web_sm')

	# WordNet auxiliary methods (just for describing results)
	wn_utils = WN_Utils() 

	encoder, vsm = load_lmms_models()
	descriptive_passages = read_as_df('data/descriptive_claims_subset.csv')
	all_nouns = []
	all_deps = []
	all_lexs = []
	test_specs = []
	c = 0

	for passage in descriptive_passages['passage']:
		passage_nouns = []
		passage_deps = []
		passage_lexs = []
		passage_nouns, passage_deps, passage_lexs = tag_passage_with_spacy(passage, "NOUN", en_nlp, encoder, vsm)
		all_nouns.append(passage_nouns)
		all_deps.append(passage_deps)
		all_lexs.append(passage_lexs)
		test_spec = specificity_neural(passage, en_nlp, encoder, vsm, ["NOUN", "VERB"])
		test_specs.append(test_spec)
		if c % 100 == 0 and c != 0:
			print(f"inventorying passage at index {c} with id {descriptive_passages['passage_id'].iloc[c]}")
		c+=1

	print(f"inventoried {c} passages")

	
	descriptive_passages['nouns'] = all_nouns
	descriptive_passages['deps'] = all_deps
	descriptive_passages['supersenses'] = all_lexs
	descriptive_passages['specificity_neural'] = test_specs

	# write out
	descriptive_passages.to_csv('data/descriptive_claims_analyzed_10_20.csv')
	

