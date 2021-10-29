## Merge sample df with new data points from WordnetSpecificity / POS tagging
library(dplyr)
library(ggplot2)
df <- read.csv("tagged_details.tsv", stringsAsFactors = FALSE)

# drop unneeded row index
df <- df[,2:4]

new_col_names <- c(colnames(df), c("specificity", "adjectives", "adverbs", "nouns", "verbs"))

# read data for "detail" samples
detail_sample_data <- read.csv("detail_sample_data.csv", stringsAsFactors = FALSE, header = FALSE)

# and "not"
not_detail_sample_data <- read.csv("not_detail_sample_data.csv", stringsAsFactors = FALSE, header=FALSE)

wordnet_and_pos_data <- as.data.frame(rbind(detail_sample_data, not_detail_sample_data))

df <- as.data.frame(cbind(df, wordnet_and_pos_data))
colnames(df) <- new_col_names

# also, add a column to denote the "class_label" label ie just checking if sample rating is above mean
df <- df %>%
  mutate(class_label = ifelse(rating > mean(rating), "detail", "not_detail"))

## gut check a couple samples / tags.
df$text[246]
df$adverbs[2]

summary(df$specificity)

## to wordnet, verbs are "less specific" than nouns.
## so, passages that contain a high number of verbs compared to adjectives
## will have their scores diluted
## in wordnet, it's quite difficult to come up with a highly hyponymic verb
## especially compared to nouns - whose top level hypernyms rarely surface as often
## as common words like "enter" (0 hypernyms) and "say" (1 level below "express")
## compared to common nouns like "house" (9 levels below "entity") and "room" (7 levels below "entity")
df %>% slice_min(specificity, n=10) %>% select(sample, specificity, verbs, nouns)
## the amount of nouns vs. verbs a text uses is highly correlated.
## there is only so much physical space an author can devote to objects
## which means that a passage primarily focusing on the actions or dialogue of two characters
## is likely going to be considered less "specific" than a package with a lot of nouns
cor(df$nouns, df$verbs)

color_vals <- c("(-Inf,3.5]" = "#ffff00","(3.5,4]" = "#3df100","(4,4.5]" = "#00e370","(4.5,5]" = "#00a2d5", "(5, Inf]" = "#0003c7")
scale_labels <- c("<= 3.0", "3.5 < specificity <= 4", "4 < specificity <= 4.5","4.5 < specificity <= 5.0", "> 5")
## graph words, nouns, colored by specificity
ggplot(data = df, aes(x=nouns, y=verbs)) +
  theme_classic() +
  geom_point(aes(color = cut(specificity, c(-Inf, 3.5, 4.0, 4.5, 5.0, Inf))), size = 1.25) +
  scale_color_manual(name = "specificity",values = color_vals, labels = scale_labels) + 
  ggtitle("Average Distance to Broadest Hypernym")
