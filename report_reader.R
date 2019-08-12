# Reading text from templated word docs into an R data frame
# Amy Andrews
# 12/08/2019

# load libraries

library(textreadr) # for reading in word documents and preserving formatting
library(readtext) # for doing the same thing (?)
library(tm) # for manipulating text and getting named terms
library(tidyverse) # for general data manipulation 
library(testthat) # for checking the code along the way
library(officer) # for reading the styles of the documets

# read in word document as one long string
report <- readtext::readtext("C:/Users/Amy/Documents/ce_report_example.docx")
# any checks that the read-in document should have?

# this will read in the report with line breaks and so multiple string records
report2 <- read_docx("C:/Users/Amy/Documents/ce_report_example.docx")
df <- as.data.frame(report2)

# we can see styles info from the doc read in with read_docx
# but still can't get the style info of our document
number1 <- report2 %>% styles_info()
number1


report2 %>% head()
report %>% head()



