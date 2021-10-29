# graphs
library(ggplot2)
library(gridExtra)
# cleanup
library(dplyr)
library(stringr)

df <- read.csv("log_odds_data.csv", stringsAsFactors = FALSE)

# drop unneeded row index
df <- df[,2:4]

top_details <- df %>% slice_max(log_odds, n=25)
top_not_details <- df %>% slice_min(log_odds, n=25)

combined = as.data.frame(cbind(top_details, top_not_details))

png("top_details.png", height = 25*nrow(top_details), width = 150*ncol(top_details))
grid.table(top_details)
dev.off()

png("top_not_details.png", height = 25*nrow(top_not_details), width = 150*ncol(top_not_details))
grid.table(top_not_details)
dev.off()


