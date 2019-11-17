#-----------------------------------------------------------------------------#
# Program purpose: Finding out which reports are related to which SDGs        #
# Author: Amy Andrews & Emma Oldfield                                         #
# Date: NOV2019                                                               #
#-----------------------------------------------------------------------------#

# This function takes an xlsx or xls file
# and reads in each sheet one by one
# then converts the data of that sheet to a single character string
# and creates a dataframe of that string, the file path + sheet name, and file extension type

# load libraries
library(tidyverse)
library(readxl)
library(tools)

# create a function to return the input_file path and each sheet related to it in a dataframe
all_sheets_to_chr <- function(file_path) {
    
    # get the number of sheets for that file 
    sheets <- excel_sheets(file_path)
  
  # for each excel file return a dataframe of the filename and the sheet number next to it
    master_df <- data.frame()
    
    #for loop to bind to empty dataframe
    for (i in 1:length(sheets)) {
      
      # read in that sheet without colnames so they are also read in as words
       sheet <- readxl::read_excel(file_path, sheet = i, col_names = FALSE) 
       
       # make everything character 
       sheet <- data.frame(lapply(sheet, as.character), stringsAsFactors=FALSE) 
       
       # unlist the dataframe to a character vector
       chr_sheet <- paste(unlist(sheet, use.names=TRUE), collapse=", ")
       
       # remove all punctuation and numbers, remove all NAs
       chr_sheet <- gsub("[[:punct:]]+", "", chr_sheet)
       chr_sheet <- gsub("[[:digit:]]+", "", chr_sheet)
       chr_sheet <- gsub("NA ", "", chr_sheet)
       
       
       df <- data.frame(text = chr_sheet, filepath = paste(file_path, " sheet =", i), ext=file_ext(file_path))
       
       df <- df %>% mutate(text = as.character(text), filepath = as.character(filepath), ext = as.character(ext))
       
       master_df <- rbind(master_df, df)
       
    }
  
    return(master_df)
  
}

  