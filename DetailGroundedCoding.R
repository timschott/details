## Sifting through Relic examples that contain keywords of interest

## libraries

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

### now pull descriptive passages as well 
## and see if the treatment is different or falls into similar themes
df <- read.csv("data/descriptive_claims_subset.csv")

prev_ids <- read.csv("data/relic_prev_ids.csv", header=TRUE)

prev_passages <- read.delim('data/relic_prev_passages.txt', sep="\n", header = TRUE)

prev_buckets <- read.delim('data/relic_prev_buckets.txt', sep="\n", header = TRUE)

df_sub <- df %>% filter(match_output != "Right") %>%
  filter(!(claim_id %in% prev_ids$claim_id)) %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id) %>%
  sample_frac(size=1)

buckets <- NA

for (i in c(1:50)) {
  print(df_sub[i,][c('left_claim', 'passage', 'right_claim', 'claim_id')])
  focus <- readline(prompt="focus: ")
  buckets[i] <- paste0(focus, " : ", df_sub[i,]['claim_id']) 
}



# combined <- as.data.frame(cbind(comments, claim_ids))
# colnames(combined) <- c("comments", "claim_id")
# write to file
# write.csv(combined, "descriptive_both_sides_comments.csv")
