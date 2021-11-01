## Merge sample df with new data points from WordnetSpecificity / POS tagging
library(dplyr)
library(ggplot2)
df <- read.csv("samples_data_with_spec_and_pos.tsv", sep="\t", stringsAsFactors = FALSE, header = FALSE)

colnames(df) <- c("sample", "text", "rating", "specificity", "adjectives", "adverbs", "nouns", "verbs", "adpositions")
# also, add a column to denote the "class_label" label ie just checking if sample rating is above mean
df <- df %>%
  mutate(class_label = ifelse(rating > mean(rating), "detail", "not_detail"))

## gut check a couple samples / tags.
df$text[246]
df$adverbs[2]

summary(df$specificity)

df %>% group_by(class_label) %>% summarize(n = n())

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

## let's group by class_label and then average specificity
df %>% group_by(class_label) %>%
  summarize(mean(specificity), mean(nouns), mean(verbs), mean(adjectives), mean(adverbs))

df %>% arrange(desc(specificity)) %>%
  filter(row_number() <= 10) %>%
  select(sample, specificity, nouns, verbs)

df %>% arrange(specificity) %>%
  filter(row_number() <= 10) %>%
  select(sample, specificity, class_label)

## let's check out a noun-to-verb ratio
df %>%arrange(specificity) %>%
  select(sample, specificity, class_label) %>% 
  filter(row_number() <= 10)

df %>% select(class_label)
df$text[72]
df <- df %>% mutate(ntv = nouns/verbs)

## label by detail / not_detail
ggplot(df, aes(x = ntv, y = specificity)) +
  theme_classic() +
  geom_point(aes(col=class_label), size = 1.25) + 
  scale_color_manual(name="Label", labels = c("Detail", "Not Detail"), 
  values = c("detail"="#0003c7", "not_detail"="#3df100")) +
  labs(title="Specificity and Noun-to-Verb Ratio", y="specificity", x="noun-to-verb ratio")

## .778 - extremely highly correlated
cor(df$ntv, df$specificity)

## is there a significant difference between the specificity of detail and non detail assignments?
ggplot(df[df$class_label=="detail",], aes(x=specificity)) + 
  geom_density(alpha=.9, fill="#82C0E7") + 
  labs(title="Specificity, Detail")

ggplot(df[df$class_label=="not_detail",], aes(x=specificity)) + 
  geom_density(alpha=.9, fill="#82C0E7") + 
  labs(title="Specificity, Not Detail")

detail <- df[df$class_label == "detail",]
not_detail <- df[df$class_label == "not_detail",]

## Is specificity normally distributed?

shapiro.test(df$specificity) # p val of .005, so it is not normal
shapiro.test(detail$specificity) # p val of .008, so it is not normal
shaprio.test(not_detail$specificity) # p val of .17, so it is normal

ggplot(detail, aes(sample = specificity)) + 
  stat_qq() +
  stat_qq_line() + 
  labs(title="QQ-Plot, Detail", x = "Theoretical", y = "Sample")

ggplot(not_detail, aes(sample = specificity)) + 
  stat_qq() +
  stat_qq_line() + 
  labs(title="QQ-Plot, Not Detail", x = "Theoretical", y = "Sample")

ggplot(df, aes(sample = specificity)) + 
  stat_qq() +
  stat_qq_line() + 
  labs(title="QQ-Plot of Specificity, 364 Random Passages", x = "Theoretical", y = "Sample")

## let's get prepositions, too...
## mean adjectives differ by .3 so not included
## detail group has more specificity because more nouns
## and more adpositions 
df %>% group_by(class_label) %>%
  summarize(mean(specificity), mean(nouns), mean(verbs), mean(adverbs), mean(adpositions))

t <- as.data.frame(df$text)
t[311,]
