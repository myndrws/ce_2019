#-----------------------------------------------------------------------------#
# Program purpose: Finding out which reports are related to which SDGs        #
# Author: Emma Oldfield & Amy Andrews                                         #
# Date: SEP2019                                                               #
#-----------------------------------------------------------------------------#

# install packages - This can also take a while to download. Only needs to be run once per machine
install.packages("tidyverse") # for general data manipulation. - May get asked if you want to install from sources the packages need to compile (type yes)
install.packages("tokenizers") # split reports into sentences
install.packages("testthat") # for read_in function
install.packages("pdftools") # for read_in function
install.packages("readtext") # for read_in function


# load libraries

library(tidyverse) # for general data manipulation 
library(tokenizers) #splits test into sentences - tokens


# set working directory -----------------------------------------------------------

# Please type the file path of where you have stored the R code:
R_code <- "/Users/emmaoldfield/ce_2019"

# Please type the file path of where you have stored the key words text file:
SDG_key_words <- "/Users/emmaoldfield/ce_2019/sdg_output"


# Please type the file path of where you have stored the documents you wish to scan:
documents_partnerships <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Partnerships"
documents_field_trips <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Field trips"
documents_archive <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/ARCHIVE"


if(getwd()=="/cloud/project"){
  setwd("/cloud/project/")
}else{
  setwd(R_code)}


# source functions ----------------------------------------------------------------
source("functions/read_in.R")
source("functions/check_words.R")

#----------------------------------------------------------------------------------#
# Things to update in script                                                       #
#----------------------------------------------------------------------------------#

# tidy up


#----------------------------------------------------------------------------------#
# Step 1 - Bring in the report(s)                                                  #
#----------------------------------------------------------------------------------#

# Read in a list of files names in the report folder
files_list_partnerships <- data.frame(list.files(path = documents_partnerships, full.names = TRUE, recursive = TRUE)) 
files_list_field_trips <- data.frame(list.files(path = documents_field_trips, full.names = TRUE, recursive = TRUE))
files_list_archive <- data.frame(list.files(path = documents_archive, full.names = TRUE, recursive = TRUE))


# rename columns
colnames(files_list_partnerships) <-  "file_path"
colnames(files_list_field_trips)  <-  "file_path"
colnames(files_list_archive) <-  "file_path"

# bind list of all 3 folders together
files_all <- rbind(files_list_partnerships, files_list_field_trips, files_list_archive)

# count number of pdfs and word docs
num_pdf <- length(grepl(".pdf", files_all$file_path)[grepl(".pdf", files_all$file_path)==TRUE]) #923
num_word_docx <- length(grepl(".docx", files_all$file_path)[grepl(".docx", files_all$file_path)==TRUE]) #1535
num_word_doc <- length(grepl(".doc", files_all$file_path)[grepl(".doc", files_all$file_path)==TRUE]) #1535


# create a single dataframe with each row representing each document
reports_all <- purrr::map_dfr(as.character(files_all$file_path), read_in, .id = "report_id") 


# .id creates a unique id for every iteration of the purrr i.e. a unique id for each report
  #rowid_to_column() %>%
  #mutate(text = gsub("\r", ".", text))


#----------------------------------------------------------------------------------#
# Step 2 - Split into sentences                                                    #
#----------------------------------------------------------------------------------#

# iterate through each report - linking all strings in a file into one big string
for(i in 1:max(reports_all$report_id)){
  
  # select one report at a time
  report_selected <- reports_all %>% filter(report_id == i )
  
  # create one string
  report_string <- paste(report_selected[,"text"])
  
  # split into sentences
  report_tokenized <- unlist(tokenize_sentences(report_string))
  
  # create data frame with sentence as each row and sentence Id
  report_analysis <- as.data.frame(report_tokenized) %>%
    mutate(sentence_id = row_number(), report_id = i) 
  
  if(exists("report_tokenized_all")){
    report_tokenized_all <- rbind(report_analysis, report_tokenized_all)
  }else{
    report_tokenized_all <- report_analysis
  }
}



#----------------------------------------------------------------------------------#
# Step 3 - Create target sentences/vectors                                         #
#----------------------------------------------------------------------------------#

# read in SDGs from td-idf output
SDGs <- readxl::read_xls("sdg_output/sdg_words_manual_output-2019-11-04.xls", sheet=2)

# function to create vector of words for each SDG
create_vector_words <- function(SDG_id){
  select_rows <- filter(SDGs, rowid == SDG_id)
  
  combine_words <- paste(select_rows$word)
  
  combine_words
}

# call function to create 17 vectors of SDG words
for(i in 1:17){
  name_of_vector <- paste0("wordsOfInterest_SDG", i) # create name of vector to change with SDG number
  assign(name_of_vector, create_vector_words(i)) 
  }



# finds yes or no occurance not count of occurances
report_output <- report_tokenized_all %>%
  rowwise() %>%
  mutate(sdg1 = check_words(report_tokenized, wordsOfInterest_SDG1)) %>%
  mutate(sdg2 = check_words(report_tokenized, wordsOfInterest_SDG2)) %>%
  mutate(sdg3 = check_words(report_tokenized, wordsOfInterest_SDG3)) %>%
  mutate(sdg4 = check_words(report_tokenized, wordsOfInterest_SDG4)) %>%
  mutate(sdg5 = check_words(report_tokenized, wordsOfInterest_SDG5)) %>%
  mutate(sdg6 = check_words(report_tokenized, wordsOfInterest_SDG6)) %>%
  mutate(sdg7 = check_words(report_tokenized, wordsOfInterest_SDG7)) %>%
  mutate(sdg8 = check_words(report_tokenized, wordsOfInterest_SDG8)) %>%
  mutate(sdg9 = check_words(report_tokenized, wordsOfInterest_SDG9)) %>%
  mutate(sdg10 = check_words(report_tokenized, wordsOfInterest_SDG10)) %>%
  mutate(sdg11 = check_words(report_tokenized, wordsOfInterest_SDG11)) %>%
  mutate(sdg12 = check_words(report_tokenized, wordsOfInterest_SDG12)) %>%
  mutate(sdg13 = check_words(report_tokenized, wordsOfInterest_SDG13)) %>%
  mutate(sdg14 = check_words(report_tokenized, wordsOfInterest_SDG14)) %>%
  mutate(sdg15 = check_words(report_tokenized, wordsOfInterest_SDG15)) %>%
  mutate(sdg16 = check_words(report_tokenized, wordsOfInterest_SDG16)) %>%
  mutate(sdg17 = check_words(report_tokenized, wordsOfInterest_SDG17))



# keep only rows where at least one word has been found
occurance_SDG <-  report_output[!(rowSums(is.na(report_output[,4:20]))==ncol(report_output)-3),]



# keep only rows where at least one word has been found
occurance_SDG <-  report_output[!(rowSums(is.na(report_output[,4:20]))==ncol(report_output)-3),]

#----------------------------------------------------------------------------------#
# Step 5 - Output into Excel                                                       #
#----------------------------------------------------------------------------------#

excel <- occurance_SDG %>%
  pivot_longer(4:20) %>% #SDG columns 
  filter(!is.na(value)) %>% #remove columns where no SDG has been found
  rename("SDG_words_found" = value, "SDG_related_to" = name )

write_csv(excel, paste0(getwd(), "results.csv"))



