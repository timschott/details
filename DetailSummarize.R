## Rating Summarize

# graphs
library(ggplot2)
library(ggridges)
# cleanup
library(dplyr)
library(stringr)

df <- read.csv("tagged_details.tsv", stringsAsFactors = FALSE)

# drop unneeded row index
df <- df[,2:4]

summary(df$rating)

# Histogram
ggplot(df, aes(x=rating)) +
  geom_histogram(binwidth=.1, colour="black", fill="#82C0E7") +
  ggtitle("Detail Ratings Histogram") +
  theme(plot.title = element_text(hjust = 0.5))

# Histogram overlaid with kernel density curve
ggplot(df, aes(x=rating)) + 
  geom_density(alpha=.9, fill="#82C0E7") + 
  ggtitle("Detail Ratings Distribution") +
  theme(plot.title = element_text(hjust = 0.5))

# Histogram, but with counts on side rather than density
ggplot(df, aes(x=rating)) + 
  geom_density(aes(y = ..count..), fill = "#82C0E7") +
  geom_vline(aes(xintercept = mean(rating)), 
             linetype = "dashed", size = 0.6,
             color = "#FC4E07") +
  ggtitle("Detail Ratings Distribution") +
  theme(plot.title = element_text(hjust = 0.5))

# add column to capture book title
pat <- "\\/([a-z]+_){1,}"
df <- df %>% mutate(work = as.factor(substr(str_extract(sample, pat), 2, nchar(str_extract(sample, pat)) - 1)))
# hex_vec <- c("#8595e2","#b2fffc","#f7a3ce","#996edd","#c8ffaf","#ffcac6",
#              "#c0d4f9","#ffc9ee","#9b7ee5","#2f7202","#b0ef62","#4e9b14",
#              "#79ce12","#ebffb2","#0cb523","#c6e868","#a4dd6e","#21cec5",
#              "#7454af","#dcccff","#742cc1","#611a93","#9a4dc6","#864cce",
#              "#be6ae8","#a14dea","#9210d3","#df1ced")

# sort of cool but hard to really get a hold of w/o tons of data
ggplot(df, aes(x = rating, y = work, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 2, size =.1) +
  scale_fill_viridis_c(name = "Detail Rating", option = "C") +
  ggtitle("Detail Ratings Distribution") +
  theme(plot.title = element_text(hjust = 0.5))
  
# again, same thing - would be better if we had a lot more observations
ggplot(df, aes(rating, work, group = work, height = ..density..)) +
    geom_density_ridges(stat = "density", trim = TRUE, scale=2)

# tables per book
ratings_per_work <- df %>% 
  group_by(work) %>% 
  summarize(avg_rating = mean(rating)) %>%
  arrange(desc(avg_rating))

# best samples
best_samples <- df %>% 
  arrange(desc(rating)) %>%
  filter(row_number() <= 10) %>%
  select(sample, text, work, rating)

# H0: mean is 3 ie it is not biased towards detail
# H1: mean is not 3 ie it is biased towards either pro or not detail
# let alpha = .05
# not super insightful since this isn't a sample from a population (per-se)
wilcox.test(df$rating, mu = 3, conf.int = TRUE, alternative = "greater")

# still, make division, at the mean
df <- df %>%
  mutate(detail = ifelse(rating > mean(rating), "detail", "not_detail"))

# 197 detail, 167 not detail
df %>%
  group_by(detail) %>%
  summarize(n = n())

# now, need to splinter these samples into two big text files: one for detail, one not, all separated by new_lines
detail_samples <- df[df$detail=="detail",2]
not_detail_samples <- df[df$detail=="not_detail",2]

write.table(detail_samples,"detail_samples.txt",sep="\n",row.names=FALSE)
write.table(not_detail_samples,"not_detail_samples.txt",sep="\n",row.names=FALSE)

