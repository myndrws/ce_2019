# Reading text from templated word docs into an R data frame
# Amy Andrews
# 12/08/2019

# load libraries

library(textreadr) # for reading in word documents and preserving formatting
library(readtext) # for doing the same thing (?)
library(tm) # for manipulating text and getting named terms
library(tidyverse) # for general data manipulation 
library(testthat) # for checking the code along the way
library(officer) # for reading the styles of the documents
library(data.table) # for using quick things
library(ggplot2) # for graphing
library(plotly) # for interactive graphing
library(tidytext) # for word frequencies
library(cleanNLP) # clean named word entities
library(pdftools) # read pdfs

# source functions
source("~/read_in.R")

# input_file 
input_file <- "C:/Users/Amy/Documents/ce_report_example.docx"

# read in the report 
report <- read_in(input_file = input_file)

# may or may not work 
styles_info(report)

# # this will read in the report with line breaks and so multiple string records
# report2 <- read_docx("C:/Users/Amy/Documents/ce_report_example.docx")
# df <- as.data.frame(report)
# 
# # we can see styles info from the doc read in with read_docx
# # but still can't get the style info of our document
# styles_info(report2)

report %>% head()

# locating parts of report with regular expressions

# title of report
title_of_report <- report$text[1]

# important sections of report
  # Search for the Abstract:
location_first_section <- grep("new partners/ organisations?", report$text)[1]

# Search for the Keyword
location_second_section <- grep("this is a new heading", report$text)[1]

# The text in between these 2 sections will be the text we want
section_text <- paste(report$text[(location_first_section+1):(location_second_section-1)], collapse=" ")

section_text <- data.frame(section_text) %>%
  mutate(section_text = as.character(section_text))


# create function to split the words of the section and plot them

word_frequencies <- function(section_df, text_var) {
  
  expect_s3_class(section_df, "data.frame")
  expect_type(text_var, "character")
  
section_df <- section_df %>%
  rowid_to_column()
# split just that section into words &
# find document-word counts & 
# remove stopwords
word_counts <- section_df %>%
  unnest_tokens(word, !!text_var) %>%
  anti_join(stop_words) %>%
  count(rowid, word, sort = TRUE) %>%
  ungroup() %>%
  filter(n > 2) # where the wordcount is greater than one

# visualise the top 5 words in these topics 
p <- ggplotly(
  word_counts %>%
    ggplot(aes(reorder(word, n), n, fill = as.factor(word))) +
    geom_col(show.legend = FALSE) +
    theme(legend.position = "none", axis.title.y = element_blank()) +
    ggtitle("Count of most frequent words in section") +
  coord_flip()
)

return(p)

}

word_frequencies(section_text, "first_section_text")

?Annotation(report$text)
class(report$text)

# what are the most common entity types used in the addresses?
cnlp_get_entity(report$first_section_text)$entity_type %>%
  table()

# what are the most common locations mentioned?
res <- cnlp_get_entity(report) %>%
  filter(entity_type == "LOCATION")
res$entity %>%
  table() %>%
  sort(decreasing = TRUE) %>%
  head(n = 25)
