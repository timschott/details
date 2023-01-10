## make unique ids for dataset

library(dplyr)

## load in tagged data

prev_ids <- read.csv("data/relic_prev_ids.csv", header=TRUE)
prev_buckets <- read.delim('data/relic_prev_buckets.txt', sep="\n", header = TRUE)
prev_passages <- read.delim('data/relic_prev_passages.txt', sep="\n", header = TRUE)

## create an id marker

relic_ids <- seq(1, nrow(prev_ids))

df <- read.csv("data/descriptive_claims_subset.csv")

## connect each passage to its originating novel

books_and_claim_ids <- df %>% filter(match_output != "Right") %>% # remove claims that don't implicate description in left_claim
  filter(book != 'the_souls_of_black_folk') %>% # remove non-fiction
  filter(claim_id != 43357) %>% # remove reference to out of corpus work
  filter(claim_id != 5454) %>%
  select(book, claim_id)

agg <- as.data.frame(cbind(relic_ids, prev_buckets, prev_ids, prev_passages))

## join on claim_id

agg <- left_join(agg, books_and_claim_ids, by="claim_id")

colnames(agg) <- c("passage_id", "bucket", "claim_id", "passage", "book")

## write out 'complete' dataset

write.table(agg, 'data/annotated_relic_data.txt', row.names = FALSE, quote = FALSE, sep="\t")