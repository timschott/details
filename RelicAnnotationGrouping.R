## Dropping relic annotations into .pdf's by group

## libraries

library(dplyr)

prev_ids <- read.csv("data/relic_prev_ids.csv", header=TRUE)
prev_buckets <- read.delim('data/relic_prev_buckets.txt', sep="\n", header = TRUE)
prev_passages <- read.delim('data/relic_prev_passages.txt', sep="\n", header = TRUE)

agg <- as.data.frame(cbind(prev_buckets, prev_ids, prev_passages))

prev_buckets %>% group_by(bucket) %>% summarize(count = (n())) %>% arrange(desc(count))

metaphor <- agg %>% filter(bucket == 'metaphor') %>% select(claim_id, passage)
ice <- agg %>% filter(bucket == 'internal character experience') %>% select(claim_id, passage)
ec <- agg %>% filter(bucket == 'external characterization') %>% select(claim_id, passage)
sd <- agg %>% filter(bucket == 'sensory detail') %>% select(claim_id, passage)
id <- agg %>% filter(bucket == 'informative detail') %>% select(claim_id, passage)
ee <- agg %>% filter(bucket == 'embellishing an event') %>% select(claim_id, passage)
x <- agg %>% filter(bucket == 'x') %>% select(claim_id, passage)

write.table(ice,"data/relic-banks/internal-character-experience.txt",sep="\t\t", eol="\n\n", col.names = c("internal-character-experience", ""), row.names=FALSE)
write.table(ec,"data/relic-banks/external-characterization.txt",sep="\t\t", eol="\n\n", col.names = c("external-characterization", ""), row.names=FALSE)
write.table(metaphor,"data/relic-banks/metaphor.txt",sep="\t\t", eol="\n\n", col.names = c("metaphor", ""), row.names=FALSE)
write.table(sd,"data/relic-banks/sensory-detail.txt",sep="\t\t", eol="\n\n", col.names = c("sensory-detail", ""), row.names=FALSE)
write.table(id,"data/relic-banks/informative-detail.txt",sep="\t\t", eol="\n\n", col.names = c("informative-detail", ""), row.names=FALSE)
write.table(ee,"data/relic-banks/embellishing-an-event.txt",sep="\t\t", eol="\n\n", col.names = c("embellishing-an-event", ""), row.names=FALSE)
write.table(x,"data/relic-banks/x.txt",sep="\t\t", eol="\n\n", col.names = c("x", ""), row.names=FALSE)

## 

# what books are in the dataset?
df <- read.csv("data/descriptive_claims_subset.csv")

d <- df %>% filter(match_output != "Right") %>% # remove claims that don't implicate description in left_claim
  filter(book != 'the_souls_of_black_folk') %>% # remove non-fiction
  filter(claim_id != 43357) %>% # remove reference to out of corpus work
  filter(claim_id != 5454) %>%
  group_by(book) %>%
  summarize(count=n())
