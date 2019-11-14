
# load libraries
library(tidyverse)
library(readxl)
library(tools)

# works with single filepath 
# need to test with a vector of filepaths too 
input_files <- c("C:/Users/Amy/Documents/R/Projects/ce_practice_data/test.xlsx", "C:/Users/Amy/Documents/R/Projects/ce_practice_data/test2.xlsx")

# just one
file_path <- "C:/Users/Amy/Documents/R/Projects/ce_practice_data/test.xlsx"

# create a function to return the input_file path and each sheet related to it in a dataframe
all_sheets_to_df <- function(file_path) {
    
    # get the number of sheets for that file 
    sheets <- excel_sheets(file_path)
  
  # for each excel file return a dataframe of the filename and the sheet number next to it
    master_df <- data.frame()
    
    #for loop to bind to empty dataframe
    for (i in 1:length(sheets)) {

       sheet <- readxl::read_excel(file_path, sheet = i, col_names = FALSE) 
       # no col_names = FALSE means names are read in as words
       sheet <- data.frame(lapply(sheet, as.character), stringsAsFactors=FALSE) 
       chr_sheet <- paste(unlist(sheet, use.names=TRUE), collapse=", ")
       chr_sheet <- gsub("NA, ", "", chr_sheet)
       
       df <- data.frame(text = chr_sheet, filepath = paste(file_path, " sheet =", i), ext=file_ext(file_path))
       
       master_df <- rbind(master_df, df)
       
    }
  
    return(master_df)
  
}

  