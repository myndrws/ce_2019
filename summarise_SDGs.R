# script to summarise the topics of the SDGs 
# Amy Andrews, 10/10/2019

## libraries and functions -----------------

library(tidyverse) # for manipulation
library(stringi) # for string extraction
library(LSAfun) # for summarisation
library(tidytext) # for word frequencies
library(topicmodels) # for topic modelling
library(quanteda) # for tokenising
library(data.table) # for writing to csv

setwd("~/R/Projects/ce_2019") # for reading in 

source("functions/read_in.R") # for reading in 
source("functions/word_frequencies.R") # for word frequencies

## read in and clean the data ------------------

# list of files names in the SDG folder
files <- data.frame(list.files(path = "SDG data/", full.names = TRUE))

# get the SDG order and arrange - this is important for assigning rowid when read in 
files <- files %>% 
  mutate(sdg_number = stringi::stri_extract_all(files[,1], regex = "\\d+")) %>%
  mutate(sdg_number = as.numeric(sdg_number)) %>%
  arrange(sdg_number)

# create a single dataframe with each row representing each document
sdgs <- purrr::map_dfr(as.character(files[,1]), read_in) %>%
  rowid_to_column() %>%
  mutate(text = gsub("\r", ".", text))

# introduce a hyphen for between "climate" and "change"
sdgs <- sdgs %>%
  mutate(text = map(text, function(x) gsub("climate change", "climate-change", x))) %>%
  mutate(text = map(text, function(x) gsub("\\d+", "", x)))

# remove numbers


## find the word frequencies in each document ----------------

# get the word frequencies and the total number words per doc
sdg_word_frequencies <- word_frequencies(sdgs, "text")

# need to remove more stopwords and numbers
# may want to adjust the function to remove all less than 2 words too


## tf - idf  -------------------

# zipfs law - frequency is inversely proportional to rank
freq_by_rank <- sdg_word_frequencies %>% 
  group_by(rowid) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total)

# tf-idf measure
sdg_tf_idf <- sdg_word_frequencies %>%
  bind_tf_idf(word, rowid, n) %>%
  select(-total) %>%
  arrange(desc(tf_idf))

# plot this - produces 17 plots 
for (i in 1:17) {
  
p <- sdg_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>% 
  group_by(rowid) %>% 
  top_n(15) %>% 
  ungroup()
  
  print(subset(p, rowid == i) %>%
  ggplot(aes(word, tf_idf, fill = rowid)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~rowid, ncol = 2, scales = "free") +
  coord_flip())
  
}

# create list of words and write to .csv
top_words <- sdg_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>% 
  group_by(rowid) %>% 
  top_n(10) %>% 
  ungroup() %>%
  arrange(rowid, tf_idf)

fwrite(top_words, file = "sdg_words_output.csv")


## summarise each document with LSA ------------------

# split each sdg document into sentences 
sdgs <- tokenize(sdgs$text)
sdgs <- unlist(sdgs)
sdgs <- data.frame(sdgs)
sdgs <- sdgs %>% rowid_to_column()

sdgs$sdgs <- as.character(sdgs$sdgs)


# tokenize each document into sentences

result1 <- genericSummary(sdgs$sdg[1], 10, split = c(".", "!", "?"))


## combine common words and summary for each document -----------------



## save this as target sentences/words for each SDG ------------------