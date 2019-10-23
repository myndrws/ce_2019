#-----------------------------------------------------------------------------#
# Program purpose: Reading text from templated word docs into an R data frame #
# Author: Amy Andrews                                                         #
# Date: SEP2019                                                               #
#-----------------------------------------------------------------------------#

# install packages
#install.packages("textreadr") # for reading in word documents and preserving formatting
#install.packages("readtext") # for doing the same thing (?")
#install.packages("tm") # for manipulating text and getting named terms
install.packages("tidyverse") # for general data manipulation 
#install.packages("testthat") # for checking the code along the way
#install.packages("officer") # for reading the styles of the documents
#install.packages("data.table") # for using quick things
#install.packages("ggplot2") # for graphing
#install.packages("plotly") # for interactive graphing
#install.packages("tidytext") # for word frequencies
#install.packages("cleanNLP") # clean named word entities
#install.packages("pdftools") # read pdfs
install.packages("tokenizers")
install.packages("spaceyr")


# load libraries
# library(textreadr) # for reading in word documents and preserving formatting
# library(readtext) # for doing the same thing (?)
# library(tm) # for manipulating text and getting named terms
library(tidyverse) # for general data manipulation 
# library(testthat) # for checking the code along the way
# library(officer) # for reading the styles of the documents
# library(data.table) # for using quick things
# library(ggplot2) # for graphing
# library(plotly) # for interactive graphing
# library(tidytext) # for word frequencies
# library(cleanNLP) # clean named word entities
# library(pdftools) # read pdfs
library(tokenizers) #splits test into sentences - tokens
library(spaceyr)

# source functions
if(getwd()=="/cloud/project"){
  source("/cloud/project/read_in.R")
}else{
  source("~/R/Projects/ce_2019/read_in.R")}

# may want to use the 'here' package for this 

# input_file 
input_file_pdf <- "/cloud/project/ADAS-Research-to-update-the-evidence-base-for-indicators-of-climate-related-risks-and-actions-in-England.pdf"

# read in the report using read_in function created
report <- read_in(input_file = input_file_pdf)

# split into sentences
report_tokenized <- unlist(tokenize_sentences(report$text))



# Using spacey
spacy_initialize()

#When spacy_initialize() is executed, a background process of spaCy is attached in python space. 
#This can take up a significant size of memory especially when a larger language model is used. Therefore,
#close the session
spacy_finalize() 

