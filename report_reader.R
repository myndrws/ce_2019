#-----------------------------------------------------------------------------#
# Program purpose: Finding out which reports are related to which SDGs        #
# Author: Emma Oldfield & Amy Andrews                                         #
# Date: SEP2019                                                               #
#-----------------------------------------------------------------------------#

# install packages - This can also take a while to download
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
SDG_key_words <- "/Users/emmaoldfield/ce_2019/SDG key words"


# Please type the file path of where you have stored the documents you wish to scan:
documents_partnerships <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Partnerships"
documents_field_trips <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/Field trips"
documents_archive <- "/Users/emmaoldfield/Dropbox (Cool Earth)/Programmes/ARCHIVE"


if(getwd()=="/cloud/project"){
  setwd("/cloud/project/")
}else{
  setwd(R_code)}


# source functions ----------------------------------------------------------------
source("read_in.R")
source("functions/check_words.R")

#----------------------------------------------------------------------------------#
# Things to update in script                                                       #
#----------------------------------------------------------------------------------#
# File path to reports
# File path to SDGs
# Working directory


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




filter(files_all, file_path=='')
# .id creates a unique id for every iteration of the purrr i.e. a unique id for each report
  #rowid_to_column() %>%
  #mutate(text = gsub("\r", ".", text))
files_all <- head(files_all)


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


# remove nouns?

#----------------------------------------------------------------------------------#
# Step 3 - Create target sentences/vectors                                         #
#----------------------------------------------------------------------------------#

# read in SDGs from td-idf output
SDGs <- read_csv("sdg_output/sdg_words_output- 2019-11-02 .csv")

# clean up words
################################################ missing

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
# Step 4 - Use spacyr for word2vec analysis                                        #
#----------------------------------------------------------------------------------#
# Sys.which("condaenv")
# 
# install.packages("reticulate")
# library(reticulate)
# use_python("/usr/bin/python")
# use_virtualenv("~/myenv")
# use_condaenv("myenv")
# use_condaenv(condaenv = "r-nlp", conda = "/opt/anaconda3/bin/conda")
# 
# library(spacyr)
# # download language model pre trained
# spacy_download_langmodel("en_core_web_md")
# 
# # Using spacey
# spacy_initialize(model = "en_core_web_md", python_executable = "/usr/bin/python" )
# 
# # create function to find cosine similarity between vectors
# vector_similarity <- function(v1,v2){
#   dist <- textstat_dist(v1, v2, method = "cosine")
#   if(is.nan(dist)){
#     dist = 1
#   }
#   return(1-dist)
# }
# 
# 
# # define function to get semantic match between document sentences and target sentences
# get_semantic_match <- function(document_sentences, target_sentence){
#   matched_target <- c()
#   sentence_vectors <- c()
#   
#   #load dictionary
#   nlp <- spacy_download_langmodel("en_core_web_md")
# }
# 
# 
# 
# #When spacy_initialize() is executed, a background process of spaCy is attached in python space. 
# #This can take up a significant size of memory especially when a larger language model is used. Therefore,
# #close the session
# spacy_finalize() 

#----------------------------------------------------------------------------------#
# Step 4 - Method 1 - Count occurances of key words                                #
#----------------------------------------------------------------------------------#


# See count vector matrices in https://www.analyticsvidhya.com/blog/2017/06/word-embeddings-count-word2veec/
# The corpus consists of D documents {d1,d2,d3...dD}. i.e. our reports

# # Define vector of reports
# reports <- c(report_tokenized) 
#               # ,"word01 word04 word03",
#               # "word10",
#              #  "",
#              #  "word02 word07 word08 word09",
#              #  ...)



# Use words of interest defined in section 3 to count occurance in each sentence (e.g. wordsOfInterest_SDG1)

# # create function to loop through SDG key words to create 17 new columns
# function(SDG_ID_number){
#   name_of_new_col <- paste0("keywordtag_SDG_", i)
#   assign(report)
# 
# }


# finds yes or no occurance not count of occurances
report_output <- report_tokenized_all

report_output  <- report_tokenized_all %>% 
  mutate(SDG1= check_words(report_tokenized, wordsOfInterest_SDG1))




report_output$keywordtag_SDG1 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG1, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG2 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG2, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG3 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG3, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG4 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG4, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG5 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG5, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG6 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG6, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG7 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG7, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG8 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG8, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG9 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG9, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG10 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG10, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG11 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG11, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG12 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG12, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG13 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG13, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG14 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG14, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG15 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG15, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG16 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG16, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0
report_output$keywordtag_SDG17 <- 
  (1:nrow(report_tokenized_all) %in% c(sapply(wordsOfInterest_SDG17, grep, report_tokenized_all$report_tokenized, fixed = TRUE)))+0


# Keep dataframe of all occurances and remove 0s
occurance_SDG <- report_tokenized_all %>% filter(keywordtag_SDG1 != 0 |
                                   keywordtag_SDG2 != 0 |
                                   keywordtag_SDG3 != 0|
                                     keywordtag_SDG4 != 0|
                                     keywordtag_SDG5 != 0|
                                     keywordtag_SDG6 != 0|
                                     keywordtag_SDG7 != 0|
                                     keywordtag_SDG8 != 0|
                                     keywordtag_SDG9 != 0|
                                     keywordtag_SDG10 != 0|
                                     keywordtag_SDG11 != 0|
                                     keywordtag_SDG12 != 0|
                                     keywordtag_SDG13 != 0|
                                     keywordtag_SDG14 != 0|
                                     keywordtag_SDG15 != 0|
                                     keywordtag_SDG16 != 0|
                                     keywordtag_SDG17 != 0)
#####################vis above logic correct



# loop through each SDG
# loop through all reports



#----------------------------------------------------------------------------------#
# Step 4 - Method 2 - Use fasttext for word2vec analysis                           #
#----------------------------------------------------------------------------------#

#install.packages("fastTextR")
#install.packages("fastText")
#library(fastTextR)
#library(fastText)

# save.fasttext(con, "dbpedia")
# #download pre trained model
# model <- read.fasttext(con)
# 
# 
# # Download Data
# fn <- "dbpedia_csv.tar.gz"
# 
# if ( !file.exists(fn) ) {
#   download.file("https://github.com/le-scientifique/torchDatasets/raw/master/dbpedia_csv.tar.gz",
#                 fn)
#   untar(fn)
# }
# 
# #Normalize Data
# install.packages("fastText")
# library("fastText")
# 
# train <- sample(sprintf("__label__%s", readLines("dbpedia_csv/train.csv")))
# head(train)
# 
# train <- normalize(train)
# writeLines(train, con = "dbpedia.train")
# 
# test <- readLines("dbpedia_csv/test.csv")
# test <- normalize(test)
# labels <- gsub("\\D", "", substr(test, 1, 4))
# test <- substr(test, 5, max(nchar(test)))
# head(test)
# head(labels)
# 
# # Train model
# cntrl <- ft.control(word_vec_size = 10L, learning_rate = 0.1, max_len_ngram = 2L, 
#                     min_count = 1L, nbuckets = 10000000L, epoch = 5L, nthreads = 20L)
# 
# model <- fasttext(input = "dbpedia.train", method = "supervised", control = cntrl)
# save.fasttext(model, "dbpedia")


# This model is downloaded from: https://fasttext.cc/docs/en/supervised-models.html 
# and is used because of its high accuracy rating 

# It is uploaded using the bottom left panel in the R studio screen under files > upload.
# (It can take a few minutes to upload) or running the code below

# con = url("https://dl.fbaipublicfiles.com/fasttext/supervised-models/dbpedia.bin", "r")
# con = gzcon(con)
# wv = readLines(con)
# 
# # This line reads in the model. The model is used to predict whether a word/vector 
# # of words is related to a piece of text 
# 
# model <- fasttext(input = wv, method = "supervised", control = cntrl)
# save.fasttext(wv, "dbpedia")
# 
# model <- read.fasttext(wv)

# If this errors - 


# # Different method
# install.packages("wordVectors")
# install.packages("devtools")
# install_github("bmschmidt/wordVectors")
# 
# library(wordVectors)
# library(devtools)
# library(httr)
# library(tm)
# 
# # Train word2vec model and explore.
# model <- word2vec('text8')
# model %>% closest_to("communism")
# 
# # Plot similar terms to 'computer' and 'internet'.
# computers <- model[[c("computer","internet"),average=F]]
# 
# # model[1:3000,] here restricts to the 3000 most common words in the set.
# computer_and_internet <- model[1:3000,] %>% cosineSimilarity(computers)
# 
# # Filter to the top 20 terms.
# computer_and_internet <- computer_and_internet[
#   rank(-computer_and_internet[,1])<20 |
#     rank(-computer_and_internet[,2])<20,
#   ]
# 
# plot(computer_and_internet,type='n')
# text(computer_and_internet,labels=rownames(computer_and_internet))



#----------------------------------------------------------------------------------#
# Step 4 - Use rword2vec for word2vec analysis                                     #
#----------------------------------------------------------------------------------#
# install.packages("devtools")
# library(devtools)
# install_github("mukul13/rword2vec")
# 
# install.packages("rword2vec")
# install.packages("lsa")
# library(rword2vec)
# library(lsa)
# 
# 
# # Load pre trained model
# distance(file_name = "vec.bin",
#          search_word = "princess",
#          num = 10)


#----------------------------------------------------------------------------------#
# Step 4 - Use rword2vec for word2vec analysis                                     #
#----------------------------------------------------------------------------------#
install.packages("fastrtext")
library(fastrtext)
