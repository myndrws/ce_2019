#--------------------------------------------------------------------#
# Program purpose: functions to read in either pdf or word documents #
# Author: Amy Andrews                                                #
# Date: OCT2019                                                      #
#--------------------------------------------------------------------#


library(testthat) # for testing the input
library(tidyverse) # for manipulating
library(pdftools) # reading in pdfs
library(textreadr) # reading in word documents
library(tools) # getting file extension 

read_in <- function(input_file) {

    testthat::expect_type(input_file, "character")
    
    is_word <- (file_ext(input_file) == "docx" | file_ext(input_file) == "doc") #checks for all word docs
    is_pdf <- file_ext(input_file) == "pdf"
    
  
  if (is_word == TRUE | is_pdf == TRUE) {
    
    t <- textreadr::read_document(input_file) %>%  
      as.data.frame() %>% 
      mutate(text = as.character(.)) %>% 
      select(text) %>% 
      mutate(text = map(text, function(x) gsub("\\d+", "", x))) %>% 
      mutate(text = map(text, function(x) gsub("\\n|\\b|\\r", "", x))) %>%
      mutate(filepath = input_file) %>%
      mutate(ext = tools::file_ext(input_file))
    
    
    return(t)
    
  } else {

    
  }

  
  
}


