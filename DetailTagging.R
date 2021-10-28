### Tagging ###
### Where 1.0 is the least detailed, 5.0 is the most

filenames <- list.files("../Gutenberg/samples", pattern="*.txt", full.names=TRUE)

df <- as.data.frame(filenames)

for (i in seq(1:length(filenames))) { 
  df[i, 2]  <- paste(scan(filenames[i], what="character"), collapse=" ")
  df[i, 3] <- 0.0
}

colnames(df) <- c("sample", "text", "rating")

# now, shuffle order of df
df <- df[sample(nrow(df)),]

for (i in 1: nrow(df)) {
  print(df$text[i])
  detail_score <- readline(prompt="Enter rating: ")
  df$rating[i] <- detail_score
}

# cast to double
df$rating <- as.double(df$rating)

# fix a few typos 
which(is.na(df$rating))
df$rating[84] <- 1.0
df$rating[85] <-3.6
df$rating[323] <- 4.4

# write to tsv
write.csv(df, file = "tagged_details.tsv", sep = "\t")

# summarize ratings


