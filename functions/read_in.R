#--------------------------------------------------------------------#
# Program purpose: function to read pdf, word or spredsheet document #
# Author: Amy Andrews                                                #
# Date: NOV2019                                                      #
#--------------------------------------------------------------------#

library(testthat) # for testing the input
library(tidyverse) # for manipulating
library(textreadr) # reading in word documents
library(tools) # getting file extension 

source("functions/all_sheets_to_chr.R") # read in each excel sheet one by one

read_in <- function(input_file) {

    testthat::expect_type(input_file, "character")
    
    is_word <- (file_ext(input_file) == "docx" | file_ext(input_file) == "doc") #checks for all word docs
    is_pdf <- file_ext(input_file) == "pdf"
    is_csv <- file_ext(input_file) == "csv"
    is_spreadsheet <- file_ext(input_file) == "xls" | file_ext(input_file) == "xlsx"
  
  if (is_word == TRUE | is_pdf == TRUE) {
    
    # read in the document, convert it to a dataframe, rename the cols
    # remove all the wierd characters that might exist and ruin word structure
    # get the output cols including file extension 
    
    t <- textreadr::read_document(input_file) %>%  
      as.data.frame() %>% 
      mutate(text = as.character(.)) %>% 
      select(text) %>% 
      mutate(text = map(text, function(x) gsub("\\d+", "", x))) %>% 
      mutate(text = map(text, function(x) gsub("\\n|\\b|\\r", "", x))) %>%
      mutate(text = as.character(text)) %>%
      mutate(filepath = input_file) %>%
      mutate(ext = tools::file_ext(input_file))
    
    return(t)
    
  } else if (is_csv == TRUE) {
    
    # read in the csv, make sure all the columns are characters
    # turn the dataframe to a character vector, clean of punctuation and numbers
    # clean of NAs and then make a new frame
    # with the expected output
    
    t <- read_csv(input_file, col_names = FALSE)
    t <- data.frame(lapply(t, as.character), stringsAsFactors=FALSE) 
    t <- paste(unlist(t, use.names=TRUE), collapse=", ")
    t <- gsub("[[:punct:]]+", "", t)
    t <- gsub("[[:digit:]]+", "", t)
    t <- gsub("NA ", "", t)
    t <- data.frame(text = as.character(t), filepath = input_file, ext=file_ext(input_file))
    t <- t %>% mutate(text = as.character(text), filepath = as.character(filepath), ext = as.character(ext))
    
    return(t)
    
  } else if (is_spreadsheet == TRUE) {
    
    # read in each excel sheet as a separater character string
    # see the function for further details
    
    t <- all_sheets_to_chr(input_file)
  
  return(t)
  
}


  
  
}


