# Function to return the word that has been found in a sentence

library(tidyverse)
library(stringi)

# this takes the target sentence and the sdg_vector of words as arguments
# lowers the words from both arguments to lower case
# then looks to extract the key sdg word from the input sentence across all sdg words for that sdg
# subsets the sdg vector by the location of the first word found and returns this word

# note that there could be more than one sdg keyword per sentence but this only returns the first one
# it also assumes that there is more than one keyword per sdg for there to be a clean output 

check_words <- function(token, sdg_vector) { 
  
  token <- tolower(token)
  sdg_vector <- tolower(sdg_vector)

  words <- sapply(token, str_extract, sdg_vector)
  
  word <- words[!is.na(words)][1]
  
  return(word)
}

