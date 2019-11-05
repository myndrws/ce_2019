# working file for developing read in excel documents 


library(testthat)
library(tidyverse)
library(pdftools)
library(readtext)

read_in <- function(input_file) {
  
  testthat::expect_type(input_file, "character")
  
  is_word <- (grepl(".docx", input_file) | grepl(".doc", input_file)) #checks for all word docs
  is_pdf <- grepl(".pdf", input_file)
  is_spreadsheet <- (grepl(".xls", input_file) | grepl(".xlsx", input_file) | grepl(".csv", input_file))
  
  
  if (is_word == TRUE & is_pdf == FALSE & is_spreadsheet == FALSE) {
    
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
    
  } else if (is_pdf == TRUE & is_word == FALSE & is_spreadsheet == FALSE) {
    
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
    
  } else if (is_pdf == FALSE & is_word == FALSE & is_spreadsheet == TRUE) {
    
    if (grepl(".xls", input_file) | grepl(".xlsx", input_file)) {
      
      # sheetnames <<- readxl::excel_sheets(input_file)
      # sheetlist <- lapply(readxl::excel_sheets(input_file), readxl::read_excel, path = input_file)
      # names(sheetlist) <- sheetnames
      
      t <- map(sheetnames, ~readxl::read_excel(path = input_file))
      
      # for each sheet in the list, read it in and then put it into the format we need
      #purrr::map_df(sheetlist, ~read_excel(path = .x))
      
      
      # readLines to collapse collumn structure
      
      return(t)
      
    } else { # or csv
      
      # readLines straight away 
      t <- readLines(input_file) %>%
        as.data.frame() %>%
        mutate(text = as.character(`.`)) %>%
        select(-`.`) %>%
        # remove numbers
        mutate(text = map(text, function(x) gsub("\\d+", "", x))) %>%
        # remove the pdf characters
        mutate(text = map(text, function(x) gsub("\\n|\\b|\\r", "", x))) %>%
        mutate(filepath = input_file)
      
      return(t)
      
    }
    
  } else {
    
    warning("Unrecognised file input: this should be a docx, a pdf, a csv or an excel file")
    
  }
  
  
  
}