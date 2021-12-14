Code for "Details in the Novel"

## File Map:

* `BertPreTrainDataMunge.R`
  * Partitions annotated data set into train, dev and test sets.
* `BertTrainModel.ipynb`
  * Trains `BERT` classifiers of various sizes to determine optimal model for detail classification.
* `ClauseParse.ipynb`
  * Breaks a paragraph into its clauses. Used for early exploration of manually identifying a "detail" (with Zola's *Germinal* as a test case)
* `Clustering.ipynb`
  * Explores unsupervised clustering on my dataset (via k-means and hierarchical methods).
* `DetailSummarize.R`
  * Initial aggregation of data points following annotations.
* `DetailTagging.R`
  * Annotation script: iterates over a list of samples, printing out the text in the console and attaching the user's input to a data frame. Allows a reader to tag texts without knowing the source (*prima facie*). For now, used to apply scores to 364 800 character passages.
* `Embeddings.ipynb`
  * Generates and stores word embedding values from `BERT`. Also contains a function for "augmenting" embedding vectors with additional points of information.
* `GeneralWordFrequencies.ipynb`
  * Catch-all script that calculates the relative frequency of word `w` in a text `t`.
* `GetTimeWords.R`
  * Extracts relevant words from the [Harvard Inquirer](http://www.wjh.harvard.edu/~inquirer/) dictionary.
* `KeyWordsInContext.ipynb`
  * Highlights the usage of a word of interest across corpus. Associated cli version is `kwic.py`.
* `LogOddsTables.R`
  * Aggregates the results from `LogOdds` calculations and produces charts for each class' most distinctive words.
* `LogOddsWithPriors.ipynb`
  * Implements the log-odds ratio with an informative Dirichlet prior (described in [Monroe et al. 2009, Fighting Words](http://languagelog.ldc.upenn.edu/myl/Monroe.pdf)). As adapted from a (completed) INFO-256 [assignment](https://github.com/dbamman/anlp21/blob/main/2.compare/Log-odds%20ratio%20with%20priors_TODO.ipynb)
* `PrepositionChiSquared.ipynb`
  * Runs the chi-squared test for independence using the frequency of prepositions to determine whether there is a significance difference in each preposition's usage in detail and not_detail samples.
* `ProcessedTextsToFile.ipynb`
  * Helper file for shuttling texts through a processing pipeline (see `gut_tokenize.py`) and writing their outputs to a `/processed/` dir.
* `SamplerForAnnotation.ipynb`
  * Randomly draws `n` samples of `k` length from a directory of `.txt` files. Writes samples to a (configurable) output directory, maintaining the location (start:stop char index) in each text that a given sample was drawn from in order to easily trace the sample back to its place of context in a given text file.
* `SpecificitySummarize.R`
  * Investigates the outputs from `WordnetSpecificity.ipynb`. Tallies metrics by class "label," produces visualizations, determines normality of calculated data with `stat_qq()`, etc.
* `TimeSummarize.R`
  * Investigates the frequency of "Time" words per [Harvard Inquirer](http://www.wjh.harvard.edu/~inquirer/)
* `TokensWithHighestAttention.ipynb`
  * Pools the attention weights (from `BERT`) of each token. Outputs the 100 highest and 100 lowest attention-values. Provides an easy look up for a word of interest's attention weight.
* `WordnetSpecificity.ipynb`
  * Routine to calculate a "specificity" metric for an inputted block of text (described in [Nelson 2020, Computational
Grounded Theory: A Methodological Framework](https://journals.sagepub.com/doi/pdf/10.1177/0049124117729703)). Also applies part of speech tallies for classes of interest. Writes results to file.
* `concat_txts.sh`
  * Combines .txt files in a directory into one-big `.txt` file. (I'm trying to get better at bash...)
* `get_26_gutentexts.sh`
  * Invokes Wolff's Project Gutenberg [wrapper](https://github.com/c-w/gutenberg) for a provided series of books and their Gutenberg id's. Saves each book's output as `.txt` file. (Again, trying to get better at bash.)
* `bert_interp.py`
  * Uses the [captum](https://captum.ai/) library to extract and visualize the attention weights of each token used by `BERT` during the classification of my annotated samples. As adapted from an INFO-256 [activity](https://github.com/dbamman/anlp21/blob/main/9.neural/Interpretability.ipynb)
* `gut_tokenize.py`
  * Reusable/importable text-cleaning methods for books from Project Gutenberg. Attempts to advance past the opening "boilerplate," removes chapter numbers, etc. Relatively "unopinionated" -- doesn't remove numbers, punctuation, stopwords, etc. (maintains as much as possible to keep options open for downstream analysis).
* `data/` contains the feature matrix, which holds:
  * sample name
  * parts of speech data
  * specificity scores
  * my detail "rating" annotation
* `paper/` contains the project write-up, which is 6 pages and adheres to the ACL's formatting guidelines.
* `viz/` contains graphs and tables related to the log-odds and specificity work.

## Corpus:

* austen *pride_and_prejudice*
* austen *sense_and_sensibility*
* carroll *alice_in_wonderland*
* conrad *heart_of_darkness*
* defoe *robinson_crusoe*
* dickens *bleak_house*
* dickens *great_expectations*
* dostoevsky *crime_and_punishment*
* eliot *adam_bede*
* eliot *middlemarch*
* fielding *tom_jones*
* fitzgerald *great_gatsby*
* flaubert *madame_bovary*
* gaskell *north_and_south*
* hawthorne *scarlet_letter*
* lewis *babbit*
* melville *moby_dick*
* more *utopia*
* shelley *frankenstein*
* shelley *the_last_man*
* sinclair *the_jungle*
* tolstoy *anna_karenina*
* verne *around_the_world_in_80_days*
* verne *twenty_thousand_leagues_under_the_sea*
* wells *the_time_machine*
* wilde *picture_of_dorian_grey*
* zola *germinal*
* zola *the_fortune_of_the_rougons*