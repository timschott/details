## Dropping relic annotations into .pdf's by group

## libraries

library(dplyr)
library(ggplot2)
library(gt)
library(paletteer)

df <- read.csv("data/relic-annotations-through-11-6.csv")

metaphor <- df %>% filter(bucket == 'metaphor') %>% select(passage, claim.id)
ice <- df %>% filter(bucket == 'internal character experience') %>% select(claim.id, passage)
ec <- df %>% filter(bucket == 'external characterization') %>% select(claim.id, passage)
sd <- df %>% filter(bucket == 'sensory detail') %>% select(claim.id, passage)
id <- df %>% filter(bucket == 'informative detail') %>% select(claim.id, passage)
ee <- df %>% filter(bucket == 'embellishing an event') %>% select(claim.id, passage)

write.table(ice,"relic-banks/internal-character-experience.txt",sep="\t\t", eol="\n\n", col.names = c("internal-character-experience", ""), row.names=FALSE)
write.table(ec,"relic-banks/external-characterization.txt",sep="\t\t", eol="\n\n", col.names = c("external-characterization", ""), row.names=FALSE)
write.table(metaphor,"relic-banks/metaphor.txt",sep="\t\t", eol="\n\n", col.names = c("metaphor", ""), row.names=FALSE)
write.table(sd,"relic-banks/sensory-detail.txt",sep="\t\t", eol="\n\n", col.names = c("sensory-detail", ""), row.names=FALSE)
write.table(id,"relic-banks/informative-detail.txt",sep="\t\t", eol="\n\n", col.names = c("informative-detail", ""), row.names=FALSE)
write.table(ee,"relic-banks/embellishing-an-event.txt",sep="\t\t", eol="\n\n", col.names = c("embellishing-an-event", ""), row.names=FALSE)


