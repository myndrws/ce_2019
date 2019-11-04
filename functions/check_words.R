# Function to return the word that has been found in a sentence

library(tidyverse)
library(stringi)

# this takes the target sentence and the sdg_vector of words as arguments
# lowers the words from both arguments to lower case
# splits up the input sentence by word
# finds the location of the match of words in the target vector
# subsets the sdg vector by the location and returns this word

check_words <- function(token, sdg_vector) { 
  
  token <- tolower(token)
  sdg_vector <- tolower(sdg_vector)
  token <- unlist(stringi::stri_extract_all_words(token))
  
  id <- match(token, sdg_vector)
  
  num <- id[!is.na(id)][1]
  
  return(sdg_vector[num])
  
}

# check_words("this has none of the words in", c("nothing", "can't"))
