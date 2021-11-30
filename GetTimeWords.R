## extract "Time" words from Harvard Inquirer Dictionary

library(readxl)
library(dplyr)

read_excel("data/inquireraugmented.xls") %>%
  filter(!is.na(`Time@`)) %>%
  group_by(`Time@`, Entry) %>%
  summarise (n = n()) %>%
    .$Entry %>%
  gsub("#.", "", .) %>%
  unique() %>%
  tolower() %T>%
  write.csv(., file = "data/time_words_hiq.csv", row.names = FALSE)
