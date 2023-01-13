# reading files
from os import listdir
from os.path import isfile, join, basename
# re
import re

'''
This method reads and returns the text of each .txt file in a directory.
These files should be the "cleaned" output of the c-w gutenberg routine

Args:
    directory_name: str

Returns:
    texts: container for the inputted texts. list
'''
def read_data(directory_name):
    texts = []
    files = [f for f in listdir(directory_name) if isfile(join(directory_name, f))]
    file_list = []
    for file in files:
        if (".txt" in file):
            with open(directory_name + file, encoding="utf-8") as f:
                print(f"tokenizing {file}...")
                #lowercase text and append
                file_list.append(basename(f.name))
                texts.append(f.read().lower())
    
    return file_list, texts

'''
This method reads and returns the text of each .txt file in a directory.
These inputs files should be the "cleaned" output of the c-w gutenberg routine

- remove new lines
- lowercase
- advance past headmatter
- remove chapter / vol / part numbers

Args:
    raw_text: str

Returns:
    text: rougly cleaned text
'''
def preprocess(raw_text):
    
    if raw_text is None:
        return
    
    text = raw_text
    
    # very high level pre-processing...
    text = text.replace("\n", " ")
    
    # lower
    text = text.lower()
    
    # listify, splitting on spaces
    text = text.split(' ')
    
    # advance us past headmatter
    for i in range(len(text) - 1):
        window_val = ' '.join(text[i:i+2])
        if (window_val == "chapter 1" or window_val == "chapter i"):
            text = text[i+2:]
            break
    
    # back to string
    text = ' '.join(text)
    
    # strip all the extraneous spaces (more than 2)
    text = re.sub('\s{2,}', ' ', text)
    
    # remove volume numbers
    text = re.sub("volume i{1,}|volume [0-9]{1,}|volume one|volume two|volume three", "", text)
    
    # remove part numbers
    text = re.sub("part i{1,}|volume [0-9]{1,}|part one|part two|part three", "", text)
    
    # remove chapters
    text = re.sub("chapter [a-z]+|chapter [0-9]+", "", text)
    
    # get rid of empties
    text = [word for word in text if word != ""]
    
    # back to string
    text = ''.join(text)
    
    return text