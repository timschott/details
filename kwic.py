# colors
from termcolor import colored

# inf filter
from numpy import inf

# pandas
import pandas as pd

# CL
import sys

# nlp
import spacy

'''
Read in .tsv of tagged sample data as a Pandas data frame
Add appropriate header to the columns as well.
'''
def read_as_df(filename):
    df = pd.read_csv(filename, sep="\t", header = None)
    df.columns = ["Text_Loc", "Sample", "Rating", "Specificity","Adj", "Adv", "Noun", "Verb", "Adp"]
    return df

'''
Read in .csv of results from chi-squared
'''
def read_chi_squared_data(filename):
    df = pd.read_csv(filename, sep=",")
    return df

'''
Helper function to call https://pypi.org/project/termcolor/
'''
def make_colored_string(word):
    return colored(word, 'cyan', attrs=['bold'])

'''
Locates word of interest across the corpus samples.
Includes an optional param for excluding "not_detail" samples.
Returns a series of strings w/ the word highlighted in context.
'''
def find_samples(df, word, ratings_cutoff = True):
    
    if ratings_cutoff:
        df = df[df['Rating'] > 3.0]
    
    word_samples = ""
    for sample in df['Sample']:
        if word in sample:
            text_loc = df.loc[df['Sample'] == sample]['Text_Loc'].item()
            # build out a string that is, normal, then colored for the word, etc.
            doc = nlp(sample)
            word_samples += text_loc + " "
            for w in doc:
                if w.text == word:
                    word_samples += make_colored_string(word)
                else:
                    word_samples += w.text
                word_samples+= ' '
            word_samples += "\n"
    
    print(word_samples)

if __name__ == '__main__':
	nlp = spacy.load('en_core_web_sm', disable=['ner,parser'])
	nlp.remove_pipe('ner')
	nlp.remove_pipe('parser')

	chi_squared_data = read_chi_squared_data("data/chi_squared_results.csv")
	chi_squared_data[chi_squared_data['stat'] != inf].sort_values('stat', ascending = False)

	df = read_as_df("data/samples_data.tsv")

	n = len(sys.argv)
	if n == 0:
		print("Please pass words into the function.")
		sys.exit(0)

	for i in range(1, n):
		find_samples(df, sys.argv[i], True)
