# script to summarise the topics of the SDGs 
# Amy Andrews, 10/10/2019

## libraries and functions -----------------

library(tidyverse) # for manipulation
library(stringi) # for string extraction
library(LSAfun) # for summarisation
library(tidytext) # for word frequencies
library(topicmodels) # for topic modelling

setwd("~/R/Projects/ce_2019")

source("functions/read_in.R")

## read in the data ------------------

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

## find the most common words in each document ----------------

word_frequencies <- function(df, text_var) {
  
  expect_s3_class(df, "data.frame")
  expect_type(text_var, "character")
  
  word_counts <- df %>%
    unnest_tokens(word, !!text_var) %>%
    anti_join(stop_words) %>%
    count(rowid, word, sort = TRUE) %>%
    ungroup() %>%
    filter(n > 2) # where the wordcount is greater than one
  
  return(word_counts)
  
}

sdg_word_frequencies <- word_frequencies(sdgs, "text"[1])




## summarise each document with LSA ------------------

# tokenize each document into sentences

result1 <- genericSummary(sdgs$text[1], 10, split = c(".", "!", "?"))


## combine common words and summary for each document -----------------



## save this as target sentences/words for each SDG ------------------