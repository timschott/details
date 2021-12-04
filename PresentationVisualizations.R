## Project Viz

## Chi Squared

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

df <- read.csv("data/chi_squared_results.csv")

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
)

# attention weights
