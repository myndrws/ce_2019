# Function to return the word that has been found in a sentence

# this takes the target sentence and the sdg_vector of words as arguments
# lowers the words from both arguments to lower case
# then extracts the key sdg word from the input sentence across all sdg words for that sdg
# returns all key words in a token as a single character vector

library(tidyverse)
library(stringi)

check_words <- function(token, sdg_vector) { 
  
  # make sure comparison equal 
  token <- tolower(token)
  sdg_vector <- tolower(sdg_vector)

  # for the token extract every word that appears in the sdg vector
  words <- sapply(token, str_extract, sdg_vector)
  
  # remove na entries 
  words <- ifelse(is.na(words), return(NA), words[!is.na(words)])
  
  # get a vector of all the words, collapse to create one string
  # to have them as vector only, remove 'collapse' argument
  allwords <- paste(words, collapse = ", ")
  
  return(allwords)
  
}