## Time Words Summarize

library(dplyr)
library(ggplot2)

df <- read.csv("data/samples_data.tsv", sep="\t", stringsAsFactors = FALSE, header = TRUE)

df <- df %>%
  mutate(class_label = ifelse(Rating > mean(Rating), "detail", "not_detail"))

summary(df$Time)

df %>% group_by(class_label) %>% summarize(m = mean(Time))

# Top 10 
df %>% arrange(desc(Time)) %>%
  filter(row_number() <= 10) %>%
  select(Text_Loc, Time, class_label)

# Bottom 10
df %>% arrange(Time) %>%
  filter(row_number() <= 10) %>%
  select(Text_Loc, Time, class_label)

ggplot(df[df$class_label=="detail",], aes(x=Time)) + 
  geom_density(alpha=.9, fill="#82C0E7") + 
  labs(title="Time, Detail")

ggplot(df[df$class_label=="not_detail",], aes(x=Time)) + 
  geom_density(alpha=.9, fill="#82C0E7") + 
  labs(title="Time, Not Detail")