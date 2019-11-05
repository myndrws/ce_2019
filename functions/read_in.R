#--------------------------------------------------------------------#
# Program purpose: functions to read in either pdf or word documents #
# Author: Amy Andrews                                                #
# Date: OCT2019                                                      #
#--------------------------------------------------------------------#


library(testthat)
library(tidyverse)
library(pdftools)
library(readtext)

read_in <- function(input_file) {
  
  testthat::expect_type(input_file, "character")
  
  is_word <- (grepl(".docx", input_file) | grepl(".docx", input_file)) #checks for all word docs
  is_pdf <- grepl(".pdf", input_file)
  
  if (is_word == TRUE & is_pdf == FALSE) {
    
    # read in word document
    t <- readtext::readtext(input_file) %>%
      as.data.frame() %>%
      mutate(text = as.character(text)) %>%
      select(-doc_id) %>%
      # remove numbers
      mutate(text = map(text, function(x) gsub("\\d+", "", x))) %>%
      # remove the pdf characters
      mutate(text = map(text, function(x) gsub("\\n|\\b|\\r", "", x))) %>%
      mutate(filepath = input_file)
    
    return(t)
    
  } else if (is_pdf == TRUE & is_word == FALSE) {
    
    # read in pdf document
    t <- pdftools::pdf_text(input_file) %>%
      as.data.frame() %>%
      mutate(text = as.character(`.`)) %>%
      select(-`.`) %>%
      # remove numbers
      mutate(text = map(text, function(x) gsub("\\d+", "", x))) %>%
      # remove the pdf characters
      mutate(text = map(text, function(x) gsub("\\n|\\b|\\r", "", x))) %>%
      mutate(filepath = input_file)
    
    return(t)
    
  } else {
    
    warning("Unrecognised file input: this should be a docx or pdf")
    
  }
  
  
}


