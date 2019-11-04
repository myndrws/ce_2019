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
library(pdftools) # for some pdf manipulation 
library(qdap) # for getting synonyms

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
  rowid_to_column() 

# get the other sdg pdf document
sdg_report <- read_in("https://unstats.un.org/sdgs/report/2019/The-Sustainable-Development-Goals-Report-2019.pdf") %>%
  rowid_to_column() %>%
  filter(rowid > 23 & rowid < 60) # filter down to relevant page numbers

# split according to pages 
filter_bind <- function(range, sdg_number) {
  
  sdg <- sdg_report %>%
    filter(rowid %in% range) %>%
    select(text)
  
  concat <- paste(as.character(sdg$text), collapse = "")
  
  sdgs <<- sdgs %>%
    mutate(text = ifelse(rowid == sdg_number, paste(text, concat, ""), text))
  
}

filter_bind(24:25, 1)
filter_bind(26:27, 2)
filter_bind(28:31, 3)
filter_bind(32:33, 4)
filter_bind(34:35, 5)
filter_bind(36:37, 6)
filter_bind(38:39, 7)
filter_bind(40:41, 8)
filter_bind(42:43, 9)
filter_bind(44:45, 10)
filter_bind(46:47, 11)
filter_bind(48:49, 12)
filter_bind(50:51, 13)
filter_bind(52:53, 14)
filter_bind(54:55, 15)
filter_bind(56:57, 16)
filter_bind(58:59, 17)

# leaves a final dataset
# introduce a hyphen for between "climate" and "change"
# remove all numbers
sdgs <- sdgs %>%
  mutate(text = map(text, function(x) gsub("climate change", "climate-change", x)))


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
  top_n(10) %>% 
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
  top_n(5) %>% 
  ungroup() %>%
  arrange(rowid, desc(tf_idf))

fwrite(top_words, file = paste0("sdg_words_output-", Sys.Date(), ".csv"))

# get synonyms for top 5 words
# top_words_synonyms <- top_words %>%
#   mutate(synonyms = qdap::synonyms(word, report.null = FALSE) %>% unlist() %>% paste(sep = " ", collapse=" "))


# can we predict a report that also has tf-idf ratings?

sdg_goal6_test <- read_in("https://unstats.un.org/sdgs/files/report/2018/TheSustainableDevelopmentGoalsReport2018-EN.pdf") %>% rowid_to_column() %>% filter(rowid %in% 20:23)

g6 <- paste(as.character(sdg_goal6_test$text), collapse = "") %>% data.frame()

names(g6)[1] <- "text"

g6$text <- as.character(g6$text)
g6 <- g6 %>% rowid_to_column()
g6 <- word_frequencies(g6, "text")
  
g6 <- g6 %>% 
  group_by(rowid) %>% 
  mutate(rank = row_number(), `term frequency` = n/total) %>%
  select(-total) %>%
    group_by(rowid) %>% 
    top_n(10) %>% 
    ungroup()

# this has overlapping words with the sdg6 topic - so we could classify it as sdg6?

## summarise each document with LSA ------------------

# split each sdg document into sentences 
sdgs_tokens <- tokenize(sdgs$text)
sdgs_tokens <- unlist(sdgs_tokens) %>% data.frame() %>% rowid_to_column()

sdgs_tokens$sdgs <- as.character(sdgs_tokens$sdgs)


# tokenize each document into sentences

result1 <- genericSummary(sdgs$sdg[1], 10, split = c(".", "!", "?"))


## combine common words and summary for each document -----------------



## save this as target sentences/words for each SDG ------------------