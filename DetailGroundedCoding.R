## Sifting through Relic examples that contain keywords of interest

## libraries

library(dplyr)

## pull descriptive passages 
## and see if the treatment is different or falls into similar themes

## load current data 
df <- read.csv("data/descriptive_claims_subset.csv")

prev_ids <- read.csv("data/relic_prev_ids.csv", header=TRUE)

prev_passages <- read.delim('data/relic_prev_passages.txt', sep="\n", header = TRUE)

prev_buckets <- read.delim('data/relic_prev_buckets.txt', sep="\n", header = TRUE)

## filter out previously attend to samples

df_sub <- df %>% filter(match_output != "Right") %>%
  filter(!(claim_id %in% prev_ids$claim_id)) %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id) %>%
  sample_frac(size=1)

## create container for new tags

buckets <- NA

## set number of passages to annotate

to_check <- 50

for (i in c(1:to_check)) {
  print(df_sub[i,][c('left_claim', 'passage', 'right_claim', 'claim_id')])
  focus <- readline(prompt="focus: ")
  buckets[i] <- focus
}

## store new information

## track claim ids

new_ids <- c(prev_ids$claim_id, df_sub$claim_id[1:to_check])
new_ids <- as.data.frame(new_ids)
colnames(new_ids) <- c("claim_id")

write.csv(new_ids, 'data/relic_prev_ids.csv', row.names=FALSE, quote = FALSE)

## track passages

new_passages <- c(prev_passages$passage, df_sub$passage[1:to_check])
new_passages <- as.data.frame(new_passages)
colnames(new_passages) <- c("passage")

write.csv(new_passages, 'data/relic_prev_passages.txt', row.names = FALSE, quote = FALSE)

## track buckets

new_buckets <- c(prev_buckets$bucket, buckets)
new_buckets <- as.data.frame(new_buckets)
colnames(new_buckets) <- c("bucket")

write.csv(new_buckets, 'data/relic_prev_buckets.txt', row.names = FALSE, quote = FALSE)
