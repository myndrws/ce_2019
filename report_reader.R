#-----------------------------------------------------------------------------#
# Program purpose: Finding out which reports are related to which SDGs        #
# Author: Emma Oldfield & Amy Andrews                                         #
# Date: SEP2019                                                               #
#-----------------------------------------------------------------------------#

# Use CTRL + ENTER to run code line by line. 


# install packages - This can also take a while to download. Only needs to be run once per machine
install.packages("tidyverse") # for general data manipulation. - May get asked if you want to install from sources the packages need to compile (type yes)
install.packages("tokenizers") # split reports into sentences
install.packages("testthat") # for read_in function
install.packages("pdftools") # for read_in function
install.packages("readtext") # for read_in function
install.packages("openxlsx") # creating nice looking excel books
install.packages("data.tree")
install.packages("plyr")

# load libraries - run at beginning of every session
library(tidyverse) # for general data manipulation 
library(tokenizers) #splits test into sentences - tokens
library(openxlsx) # creating nice looking excel books

# set working directory -----------------------------------------------------------

# Please type the file path of where you have stored the R code:
R_code <- "/Users/emmaoldfield/ce_2019"

# Please type the file path of where you have stored the key words text file:
SDG_key_words <- "/Users/emmaoldfield/ce_2019/sdg_output"


# Please type the file path of where you have stored the documents you wish to scan:
documents_partnerships <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Partnerships"
documents_field_trips <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Field trips"
documents_archive <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/ARCHIVE"

# Set working directory - this is where outputs will be saved
if(getwd()=="/cloud/project"){
  setwd("/cloud/project/")
}else{
  setwd(R_code)}


# source functions ----------------------------------------------------------------
source("functions/read_in.R") # function to read .doc , .docx and pdf files
source("functions/check_words.R")

#----------------------------------------------------------------------------------#
# Things to update in script                                                       #
#----------------------------------------------------------------------------------#

# Tidy up by adding functions for outputs into excel


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
num_pdf <- length(grepl(".pdf", files_all$file_path)[grepl(".pdf", files_all$file_path)==TRUE]) #1036
num_word_docx <- length(grepl(".docx", files_all$file_path)[grepl(".docx", files_all$file_path)==TRUE]) #1799
num_word_doc <- length(grepl(".doc", files_all$file_path)[grepl(".doc", files_all$file_path)==TRUE]) #1577

# create a single dataframe with each row representing each document
reports_all <- purrr::map_dfr(as.character(files_all$file_path), read_in, .id = "report_id") 

# create list of report file paths and report ids



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
    mutate(sentence_id = row_number(), report_id = i, report_file_path = report_selected$filepath[1]) 
  
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

#----------------------------------------------------------------------------------#
# Step 4 - Find SDG words in documents                                             #
#----------------------------------------------------------------------------------#


# finds yes or no occurance not count of occurances
report_output <- report_tokenized_all %>%
  rowwise() %>%
  mutate(SDG01 = check_words(report_tokenized, wordsOfInterest_SDG1)) %>%
  mutate(SDG02 = check_words(report_tokenized, wordsOfInterest_SDG2)) %>%
  mutate(SDG03 = check_words(report_tokenized, wordsOfInterest_SDG3)) %>%
  mutate(SDG04 = check_words(report_tokenized, wordsOfInterest_SDG4)) %>%
  mutate(SDG05 = check_words(report_tokenized, wordsOfInterest_SDG5)) %>%
  mutate(SDG06 = check_words(report_tokenized, wordsOfInterest_SDG6)) %>%
  mutate(SDG07 = check_words(report_tokenized, wordsOfInterest_SDG7)) %>%
  mutate(SDG08 = check_words(report_tokenized, wordsOfInterest_SDG8)) %>%
  mutate(SDG09 = check_words(report_tokenized, wordsOfInterest_SDG9)) %>%
  mutate(SDG10 = check_words(report_tokenized, wordsOfInterest_SDG10)) %>%
  mutate(SDG11 = check_words(report_tokenized, wordsOfInterest_SDG11)) %>%
  mutate(SDG12 = check_words(report_tokenized, wordsOfInterest_SDG12)) %>%
  mutate(SDG13 = check_words(report_tokenized, wordsOfInterest_SDG13)) %>%
  mutate(SDG14 = check_words(report_tokenized, wordsOfInterest_SDG14)) %>%
  mutate(SDG15 = check_words(report_tokenized, wordsOfInterest_SDG15)) %>%
  mutate(SDG16 = check_words(report_tokenized, wordsOfInterest_SDG16)) %>%
  mutate(SDG17 = check_words(report_tokenized, wordsOfInterest_SDG17))



# keep only rows where at least one word has been found
occurance_SDG <-  report_output[!(rowSums(is.na(report_output[,5:21]))==ncol(report_output)-4),]



#----------------------------------------------------------------------------------#
# Step 5 - Prepare for Excel                                                       #
#----------------------------------------------------------------------------------#

excel <- occurance_SDG %>%
  pivot_longer(5:21) %>% #SDG columns 
  filter(!is.na(value)) %>% #remove columns where no SDG has been found
  select(report_id, report_file_path, sentence_id, report_tokenized, name, value) %>%
  arrange(report_id, sentence_id) %>%
  rename(`SDG words found` = value, `SDG related to` = name, 
         "Sentence"= report_tokenized, `Report ID` = report_id,
         `Report file path` = report_file_path, `Sentence ID` = "sentence_id"
  )  # rename columns

summary_excel_sdg_hits_per_report <- excel %>%
  group_by(`Report ID`, `SDG related to`) %>%
  summarize(`Number of SDG words found in document` = n())

summary_excel_reports_per_sdg <- excel %>%
  group_by(`SDG related to`) %>%
  summarize(`Number of reports related to SDG` = n()) %>%
  arrange(`SDG related to`)


#----------------------------------------------------------------------------------#
# Step 6 - Output to Excel                                                         #
#----------------------------------------------------------------------------------#

  # create workbook
  wb <- createWorkbook()
  
  # define styles to use in writeData
  headerStyle <- createStyle(fontSize = 12, halign = "center", fontColour = "white",
                             border = "TopBottom", borderColour = "#4F81BD", fgFill = "#00447c")
  
  # define name of sheet in the workbook
  addWorksheet(wb, "Summary of SDGs")
  addWorksheet(wb, "Summary of reports")
  addWorksheet(wb, "Words found in reports")
  
  # add data to the workbook
  writeData(wb, "Summary of reports", summary_excel_sdg_hits_per_report, headerStyle = headerStyle)
  setColWidths(wb, "Summary of reports", cols = c(1:ncol(summary_excel_sdg_hits_per_report)), widths = "auto")
  setRowHeights(wb, "Summary of reports", rows = 1, heights = 40)
  addFilter(wb, "Summary of reports", rows = 1, cols = c(1:ncol(summary_excel_sdg_hits_per_report)))
  
  # add data to the workbook
  writeData(wb, "Summary of SDGs", summary_excel_reports_per_sdg, headerStyle = headerStyle)
  setColWidths(wb, "Summary of SDGs", cols = c(1:ncol(summary_excel_reports_per_sdg)), widths = "auto")
  setRowHeights(wb, "Summary of SDGs", rows = 1, heights = 40)
  addFilter(wb, "Summary of SDGs", rows = 1, cols = c(1:ncol(summary_excel_reports_per_sdg)))
  
  # add data to the workbook
  writeData(wb, "Words found in reports", excel, headerStyle = headerStyle)
  setColWidths(wb, "Words found in reports", cols = c(1:ncol(excel)), widths = "auto")
  setRowHeights(wb, "Words found in reports", rows = 1, heights = 40)
  addFilter(wb, "Words found in reports", rows = 1, cols = c(1:ncol(excel)))
  
  saveWorkbook(wb, paste0(getwd(), "/results_", Sys.Date(),".xlsx"), overwrite = TRUE)
  

#----------------------------------------------------------------------------------#
# Additional - Plot file structure                                                 #
#----------------------------------------------------------------------------------#
library(data.tree)
library(plyr)



# All nodes
x <- lapply(strsplit(as.character(files_all$file_path), "/"), function(z) as.data.frame(t(z)))
x <- rbind.fill(x)
x$pathString <- apply(x, 1, function(x) paste(trimws(na.omit(x)), collapse="/"))
(mytree <- data.tree::as.Node(x))

plot_files <- print(mytree, limit = 10000)


# Archive folder ---------------------------------------------------------------------------
archive <- lapply(strsplit(as.character(files_list_archive$file_path), "/"), function(z) as.data.frame(t(z)))
archive <- rbind.fill(archive)
archive$pathString <- apply(archive, 1, function(archive) paste(trimws(na.omit(archive)), collapse="/"))
(mytree_archive <- data.tree::as.Node(archive))

plot_files_archive <- print(mytree_archive, limit = 10000)


# Field trips folder ---------------------------------------------------------------------------
FieldTrips <- lapply(strsplit(as.character(files_list_field_trips$file_path), "/"), function(z) as.data.frame(t(z)))
FieldTrips <- rbind.fill(FieldTrips)
FieldTrips$pathString <- apply(FieldTrips, 1, function(FieldTrips) paste(trimws(na.omit(FieldTrips)), collapse="/"))
(mytree_FieldTrips <- data.tree::as.Node(FieldTrips))

plot_files_FieldTrips <- print(mytree_FieldTrips, limit = 10000)

# Partnerships folder ---------------------------------------------------------------------------
partnerships <- lapply(strsplit(as.character(files_list_partnerships$file_path), "/"), function(z) as.data.frame(t(z)))
partnerships <- rbind.fill(partnerships)
partnerships$pathString <- apply(partnerships, 1, function(partnerships) paste(trimws(na.omit(partnerships)), collapse="/"))
(mytree_partnerships <- data.tree::as.Node(partnerships))

plot_files_partnerships <- print(mytree_partnerships, limit = 10000)




# create workbook -----------------------------------------------------------------------------
wb2 <- createWorkbook()

# define styles to use in writeData
headerStyle2 <- createStyle(fontSize = 12, halign = "center", fontColour = "white",
                           border = "TopBottom", borderColour = "#4F81BD", fgFill = "#00447c")

# define name of sheet in the workbook
addWorksheet(wb2, "File structure all")
addWorksheet(wb2, "Programmmes-ARCHIVE")
addWorksheet(wb2, "Programmmes-Field Trips")
addWorksheet(wb2, "Programmmes-Partnerships")


# add data to the workbook
writeData(wb2, "File structure all", plot_files, headerStyle = headerStyle2)
setColWidths(wb2, "File structure all", cols = c(1:ncol(plot_files)), widths = "auto")
setRowHeights(wb2, "File structure all", rows = 1, heights = 40)
addFilter(wb2, "File structure all", rows = 1, cols = c(1:ncol(plot_files)))

# add data to the workbook
writeData(wb2, "Programmmes-ARCHIVE", plot_files_archive, headerStyle = headerStyle2)
setColWidths(wb2, "Programmmes-ARCHIVE", cols = c(1:ncol(plot_files_archive)), widths = "auto")
setRowHeights(wb2, "Programmmes-ARCHIVE", rows = 1, heights = 40)
addFilter(wb2, "Programmmes-ARCHIVE", rows = 1, cols = c(1:ncol(plot_files_archive)))

# add data to the workbook
writeData(wb2, "Programmmes-Field Trips", plot_files_FieldTrips, headerStyle = headerStyle2)
setColWidths(wb2, "Programmmes-Field Trips", cols = c(1:ncol(plot_files_FieldTrips)), widths = "auto")
setRowHeights(wb2, "Programmmes-Field Trips", rows = 1, heights = 40)
addFilter(wb2, "Programmmes-Field Trips", rows = 1, cols = c(1:ncol(plot_files_FieldTrips)))

# add data to the workbook
writeData(wb2, "Programmmes-Partnerships", plot_files_partnerships, headerStyle = headerStyle2)
setColWidths(wb2, "Programmmes-Partnerships", cols = c(1:ncol(plot_files_partnerships)), widths = "auto")
setRowHeights(wb2, "Programmmes-Partnerships", rows = 1, heights = 40)
addFilter(wb2, "Programmmes-Partnerships", rows = 1, cols = c(1:ncol(plot_files_partnerships)))

saveWorkbook(wb2, paste0(getwd(), "/fileStructure_", Sys.Date(),".xlsx"), overwrite = TRUE)






#plot with networkD3 - creating radial diagram - too clustered
# install.packages("networkD3")
# library(networkD3)
# useRtreeList <- ToListExplicit(mytree, unname = TRUE)
# radialNetwork( useRtreeList)
# diagonalNetwork(useRtreeList)

