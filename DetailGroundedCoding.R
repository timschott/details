## Sifting through Relic examples that contain keywords of interest

## libraries

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

df <- read.csv("detail_claims_subset.csv")

df_sub <- df %>% filter(match_output =="Both") %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id)

comments <- NA

for (i in 1: nrow(df_sub)) {
  print(df_sub[i,][c('left_claim', 'right_claim', 'passage', 'book')])
  comment <- readline(prompt="Enter feedback: ")
  comments[i] <- paste0(comment, " : ", df_sub[i,]['claim_id']) 
}

claim_ids <- c(6640,29788,13925,15355,36138,39929,16445,57179,43477,4361,6620,31236,4487,16496,28779,57550,64791,6081,46074,46001,22754,35986,13482,5532,50357,70506,14828,54459,13016,1854,4968,69855,45106,69917,18701,29272,63259,37256,15407,15368,22074,18012,22059,20943,65626,67491,68948)

combined <- as.data.frame(cbind(comments, claim_ids))
colnames(combined) <- c("comments", "claim_id")
# write to file
write.csv(combined, "detail_both_sides_comments.csv")

### now pull descriptive passages as well and see if the treatment is different or falls into similar themes
