#--------------------------------------------------------------------#
# Program purpose: functiona to read in either pdf or word documents #
# Author: Amy Andrews                                                #
# Date: OCT2019                                                      #
#--------------------------------------------------------------------#

# 2 functions: read in and bind together

library(testthat)
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
      select(-doc_id)
    
    return(t)
    
  } else if (is_pdf == TRUE & is_word == FALSE) {
    
    # read in pdf document
    t <- pdftools::pdf_text(input_file) %>%
      as.data.frame() %>%
      mutate(text = as.character(`.`)) %>%
      select(-`.`)
    
    return(t)
    
  } else {
    
    warning("Unrecognised file input: this should be a docx or pdf")
    
  }

  
}


# create function to bind together the rows read in where needed
# and tokenise these 

bind_tokenise <- function(data, report_id_col) {

# iterate through each report - linking all strings in a file into one big string
for(i in 1:max(reports_id_col)){
  
  # select one report at a time
  report_selected <- data %>% filter(report_id_col == i )
  
  # create one string
  report_string <- paste(report_selected[,"text"])
  
  # split into sentences
  report_tokenized <- unlist(tokenize_sentences(report_string))
  
  # create data frame with sentence as each row and sentence Id
  report_analysis <- as.data.frame(report_tokenized) %>%
    mutate(sentence_id = row_number(), report_id = i) 
  
  if(exists("report_tokenized_all")){
    report_tokenized_all <<- rbind(report_analysis, report_tokenized_all)
  }else{
    report_tokenized_all <<- report_analysis
  }
}


}


