#--------------------------------------------------------------------#
# Program purpose: function to read in either pdf or word documents  #
# Author: Amy Andrews                                                #
# Date: OCT2019                                                      #
#--------------------------------------------------------------------#
# this still needs to get the word and pdf document into the same format at the end

library(testthat)
library(pdftools)
library(readtext)

read_in <- function(input_file) {
  
  testthat::expect_type(input_file, "character")
  
  is_word <- grepl(".docx", input_file)
  is_pdf <- grepl(".pdf", input_file)
  
  if (is_word == TRUE & is_pdf == FALSE) {
    
    # read in word document
    t <- readtext::readtext(input_file) %>%
      as.data.frame() %>%
      mutate(text = as.character(text)) %>%
      select(-doc_id)
    
    return(t)
    
  } else if (is_pdf == TRUE & is_word == FALSE) {
    
    # read in pdf document
    t <- pdftools::pdf_text(input_file) %>%
      as.data.frame() %>%
      mutate(text = as.character(`.`)) %>%
      select(-`.`)
    
    # note: this includes the tags of the text 
    # BUT further analysis seems to ignore these
    
    return(t)
    
  } else {
    
    stop("Unrecognised file input: this should be a docx or pdf")
    
  }
  
}
