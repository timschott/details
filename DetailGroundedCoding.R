## Sifting through Relic examples that contain keywords of interest

## libraries

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

df <- read.csv("data/detail_claims_subset.csv")

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

### now pull descriptive passages as well 
## and see if the treatment is different or falls into similar themes
df <- read.csv("data/descriptive_claims_subset.csv")

prev_ids <- c (43357,13861,55809,3193,18123,18448,49273,4444,63287,67719,12988,20046,43562,13420,27174,32501,62124,60257,56027,69729,43446,39151,55292,44568,15542,51063,994)

df_sub <- df %>% filter(match_output != "Right") %>%
  filter(!(claim_id %in% prev_ids)) %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id)

dods <- NA
buckets <- NA

for (i in c(26:50)) {
  print(df_sub[i,][c('left_claim', 'right_claim', 'passage', 'claim_id')])
  comment <- readline(prompt="DoD: ")
  focus <- readline(prompt="focus: ")
  dods[i] <- paste0(comment, " : ", df_sub[i,]['claim_id']) 
  buckets[i] <- paste0(focus, " : ", df_sub[i,]['claim_id']) 
}

# claim_ids <- c(17693,39939,59229,52499,48223,17512,50217,17594,17387,13652,20046,17096,67807,27083,2083,3956,55292,67091,43705,3951,57917,32486,30733,17271,48023,19491,20408,17931,67703,54030,2295,70092,54061,56516,16672,48822,2935,70031,32024,15763,25800,20124,13084,66413,15545,13539,24697,66167,19291,48792,42628,67434,2564,5499,43297,68948,63136,4413,20052,43446,29018,6189,69696)

# claim_ids <- claim_ids[1:44]

combined <- as.data.frame(cbind(comments, claim_ids))
colnames(combined) <- c("comments", "claim_id")
# write to file
write.csv(combined, "descriptive_both_sides_comments.csv")

## it looks like descriptive, compared to detail, is giving us a lot more mileage. 
## now, let's check out if that holds for left/right context
## first, lets sample 10 at random

df <- read.csv("descriptive_claims_subset.csv")

df_sub <- df %>% filter(match_output == "Left") %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id)

comments <- NA

for (i in 1:10) {
  print(df_sub[i,][c('left_claim', 'right_claim', 'passage', 'book')])
  comment <- readline(prompt="Enter feedback: ")
  comments[i] <- paste0(comment, " : ", df_sub[i,]['claim_id']) 
}

comments

df_sub[1:10,]$claim_id

df <- read.csv("descriptive_claims_subset.csv")

df_sub <- df %>% filter(match_output == "Right") %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id)

comments <- NA

for (i in 1: 5) {
  print(df_sub[i,][c('left_claim', 'right_claim', 'passage', 'book')])
  comment <- readline(prompt="Enter feedback: ")
  comments[i] <- paste0(comment, " : ", df_sub[i,]['claim_id']) 
}
