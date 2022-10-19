import numpy as np
import pandas as pd
import sys
import spacy
sys.path.insert(0, '../LMMS')

from transformers_encoder import TransformersEncoder
from vectorspace import SensesVSM
from wn_utils import WN_Utils

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

def tag_passage_with_spacy(passage):
	# input sentence, with indices of token/span to disambiguate
	doc = nlp(passage)
	target_idxs = []
	target_pos == "NOUN"
	for word in enumerate(i, doc):
		if word.pos == "NOUN":
			target_idxs.append(i)

	target_lemmas = '_'.join([doc[i].lemma_ for i in target_idxs])

	print(target_lemmas)

if __name__ == '__main__':

	# load spacy
	en_nlp = spacy.load('en_core_web_sm')

	 # WordNet auxiliary methods (just for describing results)
	wn_utils = WN_Utils() 

	load_lmms_models()
	descriptive_passages = read_as_df('data/descriptive_claims_subset.csv')
	print(descriptive_passages.head())
	print(descriptive_passages.columns)
	# passages = descriptive_passages['passage']
	tag_passage_with_spacy(descriptive_passages['passage'][4])

