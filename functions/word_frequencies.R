
# get word frequencies per document
# and then also create a column for total words in that document
# bind together in one dataframe

library(tidyverse)
library(tidytext)

word_frequencies <- function(df, text_var) {
  
  expect_s3_class(df, "data.frame")
  expect_type(text_var, "character")
  
  # word counts across all docs
  word_counts <- df %>%
    unnest_tokens(word, !!text_var) %>%
    anti_join(stop_words) %>%
    count(rowid, word, sort = TRUE) %>%
    filter(n > 1) # where the wordcount is greater than one
  
  # total words per document
  total_words <- word_counts %>% 
    group_by(rowid) %>% 
    summarize(total = sum(n))
  
  # create df for word count per document against total words
  word_counts <- left_join(word_counts, total_words)
  
  return(word_counts)
  
}