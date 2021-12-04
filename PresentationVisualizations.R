## Project Viz

## Chi Squared

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

t <- read.csv("data/chi_squared_results.csv")

# chi squared
df %>%
  select(-c(X, fisher)) %>%
  mutate(word = ifelse(is.infinite(stat), paste(word, "*"), word)) %>%
  mutate(stat = ifelse(is.infinite(stat), 100, stat)) %>%
  arrange(desc(stat)) %>%
  rename("p_value" = "p", "test_statistic" = "stat", "H0" = "reject") %>% 
  gt() %>%
  data_color(
    columns = test_statistic,
    colors = scales::col_numeric(
      palette = c("blue", "orange") %>% as.character(),
    domain = NULL
  )
)  %>%
  tab_header(title = "Chi-squared output for adpositions")

# attention weights
highlight <- c("across", "against", "at", "behind", "between", "by", "like", "of", "under", "eight", "ten", "twice", "observed", "saw")
df_top_100 <- read.csv("data/top_100_attention_sums.txt", sep="\t", header = FALSE)

df_top_100 %>% 
  rename("token" = "V1", "weight" = "V2") %>%
  filter(token %in% highlight) %>%
  arrange(desc(weight)) %>%
  mutate(class = c(rep("preposition", 9), "meta", "number", "meta", "number", "number")) %>%
  mutate(class = as.factor(class)) %>%
  arrange(desc(class)) %>% 
  gt() %>%
  data_color(
    columns = token,
    colors = scales::col_factor(
      palette = c("#6495ed") %>% as.character(),
      domain = NULL
    )
  ) %>%
  tab_header(title = "Subset of Top 100 most attended to tokens", subtitle = "via Captum on test data")
