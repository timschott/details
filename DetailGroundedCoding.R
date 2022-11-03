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

prev_ids <- c(43357,13861,55809,3193,18123,18448,49273,4444,63287,67719,12988,20046,43562,13420,27174,32501,62124,60257,56027,69729,43446,39151,55292,44568,15542,51063,994,36447,44670,7011,67510,45214,55054,5346,21951,24223,62978,70195,19124,64519,69863,52234,20012,7956,63241,36809,48194,16294,51557,42180,58662,59369,40206,42189,5488,53543,25272,18541,37242,2295,26770,63139,40227,6045,42420,15138,7948,51055,70427,21920,43633,5824,26715,33456,1608,15763,15600,45357,56060,66181,39935,3507,49554,39207,42066,36228,53733,14953,14767,25525,43391,57058,37038,52542,67295,42338,31870,16672,5059,3947,69610,26113,70658,70355,28518,53626,62128,29743,16367,38917,56736,37921,48398,6798,70364,4416,40352,1034,20193,51914,68366,55951,49269,7298,22575,22525,20373,26414,55013,67264,29128,56771,15664,29860,43870,48159,18852,36757,42581,261,48323,50557,18082,48958,67557,31238,49051,187,30448,27501,5529,16687,53943,52606,45723,27095,40303,53742,4050,32193,20205,51647,17968,55719,18572,27742,36466,31145,39079,39353,42775,2287,43287,19428,25216,36511,4362)

df_sub <- df %>% filter(match_output != "Right") %>%
  filter(!(claim_id %in% prev_ids)) %>%
  select(passage, book, left_claim_keywords, right_claim_keywords, left_claim, right_claim, claim_id)

dods <- NA
buckets <- NA

for (i in c(1:50)) {
  print(df_sub[i,][c('left_claim', 'right_claim', 'passage', 'claim_id')])
  comment <- readline(prompt="DoD: ")
  focus <- readline(prompt="focus: ")
  dods[i] <- paste0(comment, " : ", df_sub[i,]['claim_id']) 
  buckets[i] <- paste0(focus, " : ", df_sub[i,]['claim_id']) 
}

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
