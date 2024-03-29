# -*- coding: utf-8 -*-
"""RelicDataSplits.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1z_B8JPY1NKde584o9tV6N1DjJ2BhVIt3

## This notebook trains classifiers using data from the RELiC dataset.
"""

from google.colab import drive
drive.mount('/content/drive')

"""### Libraries"""

# data libraries
import pandas as pd
import numpy as np

# util
import random
from collections import Counter

# sklearn helpers

from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight

"""### Import Data"""

def read_labels(filename):
    labels={}
    with open(filename) as file:
        next(file)
        for line in file:
            cols = line.split("\t")
            label = cols[1]
            if label not in labels:
                labels[label]=len(labels)
    return labels

def read_aggregated_data(filename, labels, max_data_points=None):
    """
    :param filename: the name of the file
    :return: list of tuple ([word index list], label)
    as input for the forward and backward function
    """    
    data = []
    data_labels = []
    with open(filename) as file:
        next(file)
        for line in file:
            cols = line.split("\t")
            label = cols[1]
            text = cols[3]
            
            data.append(text)
            data_labels.append(labels[label])

    # shuffle the data
    tmp = list(zip(data, data_labels))
    random.shuffle(tmp)
    data, data_labels = zip(*tmp)
    
    if max_data_points is None:
        return data, data_labels
    
    return data[:max_data_points], data_labels[:max_data_points]

def read_text_data(filename):
    data = []
    with open(filename) as file:
        for line in file:
            line = line.replace("\\n", "")
            line = line.replace("\n", "")
            data.append(line)
    return data

def read_class_data(filename):
    data = []
    with open(filename) as file:
        for line in file:
            line = line.replace("\n", "")
            data.append(int(line))
    return data

# write out the training, validation and testing sets to separate .txt files
def write_processed_text_to_file(text, filename):
    if text is None:
        return
    t = open(filename, "w")
    for line in text:
        t.write(str(line))
        t.write("\n")
    t.close()

labels=read_labels("/content/drive/MyDrive/ANLP21/relic_analysis/annotated_relic_data.txt")
print(labels)

relic_data, relic_labels = read_aggregated_data("/content/drive/MyDrive/ANLP21/relic_analysis/annotated_relic_data.txt", labels)

relic_df = pd.DataFrame(list(zip(relic_data, relic_labels)), columns = ['passage', 'label'])

relic_df.shape

"""### Data for Binary Model

#### Create pool of all negative examples
"""

# half of what will be used in the binary model
relic_negative_examples = relic_df[relic_df['label'] == 1]

relic_negative_examples.shape

"""#### Extract subset of all positive examples"""

# other half of what will be used in the binary model
relic_positive_examples = relic_df[relic_df['label'] != 1]

relic_positive_examples.shape

relic_positive_examples['label'].value_counts()

# stratified random sample based on the label values
relic_positive_examples = relic_positive_examples.groupby('label', group_keys=False).apply(lambda x: x.sample(min(len(x), min(np.unique(relic_positive_examples['label'], return_counts=True)[1]))).sample(frac=.225, random_state=42))

# random sample now has an equal number of samples (label-wise), this will be used in the binary model as the 'positive' group
relic_positive_examples['label'].value_counts()

positive_and_negative_examples = pd.concat([relic_positive_examples, relic_negative_examples])

positive_and_negative_examples.shape

"""### Data for Detail Examples"""

detail_examples=relic_df[~relic_df.isin(positive_and_negative_examples)].dropna(how = 'all')

detail_examples.shape

detail_examples['label'] = detail_examples['label'].astype(str)
positive_and_negative_examples['label'] = positive_and_negative_examples['label'].astype(str)

"""#### Save Detail samples"""

# write out detail_examples to use
write_processed_text_to_file(detail_examples['passage'],  "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_examples_x.txt")
write_processed_text_to_file(detail_examples['label'],  "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_examples_y.txt")
# write out detail .csv
detail_examples.to_csv("/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_examples.csv")

"""#### Save Binary samples"""

# write out the binary data, passage and label
write_processed_text_to_file(positive_and_negative_examples['passage'], "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_examples_x.txt")
write_processed_text_to_file(positive_and_negative_examples['label'], "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_examples_y.txt")

# write out binary .csv version
positive_and_negative_examples.to_csv("/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_examples.csv")

"""### Train-Test split (one time only)

#### Detail
"""

# recode the detail samples to be 0-5.
detail_examples['label'].value_counts()

detail_labels = list(detail_examples['label'])

fixed_detail_labels = []
for dl in detail_labels:
    dl = float(dl)
    if dl == 0:
        fixed_detail_labels.append(str(int(0.0)))
    else:
        fixed_detail_labels.append(str(int(dl-1.0)))

detail_examples['label'] = fixed_detail_labels

detail_examples['label'].value_counts()

train_ratio = 0.925
validation_ratio = 0.05
test_ratio = 0.025

# train is now 92.5% of the entire data set
# stratify label proportions of split datasets based on label distribution
detail_x_train, detail_x_test, detail_y_train, detail_y_test = train_test_split(detail_examples['passage'], detail_examples['label'], test_size = 1 - train_ratio, stratify=detail_examples.label.values, random_state = 42)

detail_x_val, detail_x_test, detail_y_val, detail_y_test = train_test_split(detail_x_test, detail_y_test, test_size = test_ratio/(test_ratio + validation_ratio), random_state = 42) 

print(len(detail_x_train), len(detail_x_val), len(detail_x_test))

detail_x_train[0:3]

detail_y_train[0:3]

write_processed_text_to_file(detail_x_train, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_x_train.txt")
write_processed_text_to_file(detail_y_train, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_y_train.txt")
write_processed_text_to_file(detail_x_val, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_x_val.txt")
write_processed_text_to_file(detail_y_val, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_y_val.txt")
write_processed_text_to_file(detail_x_test, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_x_test.txt")
write_processed_text_to_file(detail_y_test, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/detail_y_test.txt")

"""#### Binary"""

# recode the labels to be either 0 or 1.
positive_and_negative_examples['label'].value_counts()

binary_labels = list(positive_and_negative_examples['label'])

fixed_binary_labels = [str(0) if int(l) != 1 else str(1) for l in binary_labels]

positive_and_negative_examples['label'] = fixed_binary_labels

train_ratio = 0.925
validation_ratio = 0.05
test_ratio = 0.025

# train is now 92.5% of the entire data set
# stratify label proportions of split datasets based on label distribution
binary_x_train, binary_x_test, binary_y_train, binary_y_test = train_test_split(positive_and_negative_examples['passage'], positive_and_negative_examples['label'], test_size = 1 - train_ratio, stratify=positive_and_negative_examples.label.values, random_state = 42)

binary_x_val, binary_x_test, binary_y_val, binary_y_test = train_test_split(binary_x_test, binary_y_test, test_size = test_ratio/(test_ratio + validation_ratio), random_state = 42) 

print(len(binary_x_train), len(binary_x_val), len(binary_x_test))

binary_x_train[:3]

binary_y_train[:3]

# write out datasets
write_processed_text_to_file(binary_x_train, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_x_train.txt")
write_processed_text_to_file(binary_y_train, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_y_train.txt")
write_processed_text_to_file(binary_x_val, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_x_val.txt")
write_processed_text_to_file(binary_y_val, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_y_val.txt")
write_processed_text_to_file(binary_x_test, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_x_test.txt")
write_processed_text_to_file(binary_y_test, "/content/drive/MyDrive/ANLP21/relic_analysis/data/classification_data/binary_y_test.txt")