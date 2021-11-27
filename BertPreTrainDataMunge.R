## Make Train, Dev and Test sets
library(dplyr)
library(caret)
# sample <- sample.int(n = nrow(mtcars), size = floor(.80*nrow(mtcars)), replace = F)
# train <- mtcars[sample, ]
# test  <- mtcars[-sample, ]

## Load Samples
samples <- read.csv("data/samples_data.tsv", sep="\t", header = TRUE)

samples <- samples %>%
  mutate(label = ifelse(Rating > mean(Rating), "detail", "not_detail")) %>%
  select(label, Sample)

# Define the partition (e.g. 80% of the data for training)
trainIndex <- createDataPartition(samples$label, p = .80, 
                                  list = FALSE, 
                                  times = 1)

# Split the dataset using the defined partition
train_data <- samples[trainIndex, ,drop=FALSE]
dev_plus_test_data <- samples[-trainIndex, ,drop=FALSE]

# Define a new partition to split the remaining 20%
dev_plus_test_index <- createDataPartition(dev_plus_test_data$label,
                                           p = .5,
                                           list = FALSE,
                                           times = 1)

# Split the remaining ~20% of the data: 50% (dev) and 50% (test)
dev_data <- dev_plus_test_data[-dev_plus_test_index, ,drop=FALSE]
test_data <- dev_plus_test_data[dev_plus_test_index, ,drop=FALSE]

# Outcome of this section is that the data (100%) is split into:
# training (~80%)
# dev (~10%)
# test (~10%)
nrow(train_data) + nrow(dev_data) + nrow(test_data) # 364

# write to file
write.table(train_data, file = "data/train.tsv", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
write.table(dev_data, file = "data/dev.tsv", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
write.table(test_data, file = "data/test.tsv", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
