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

# read in word document as one long string
report <- readtext::readtext("C:/Users/Amy/Documents/ce_report_example.docx")
# any checks that the read-in document should have?

report <- as.data.frame(report) %>%
  mutate(report = as.character(report))
styles_info(report)

# # this will read in the report with line breaks and so multiple string records
# report2 <- read_docx("C:/Users/Amy/Documents/ce_report_example.docx")
# df <- as.data.frame(report)
# 
# # we can see styles info from the doc read in with read_docx
# # but still can't get the style info of our document
# styles_info(report2)
# 
# 
# report2 %>% head()
report %>% head()

# locating parts of report with regular expressions

# title of report
title_of_report <- report$report[1]

# important sections of report
  # Search for the Abstract:
location_first_section <- grep("new partners/ organisations?", report$report)[1]

# Search for the Keyword
location_second_section <- grep("this is a new heading", report$report)[1]

# The text in between these 2 sections will be the text we want
first_section_text <- paste(report$report[(location_first_section+1):(location_second_section-1)], collapse=" ")

# word frequency data and plotly graph
library(ggplot2)
library(plotly)
library(tidytext)

# split into words - NEEDS EDITING FOR SECTIONS NOT WHOLE REPORT
section_by_words <- report %>%
  unnest_tokens(word, report)

# find document-word counts & remove stopwords
word_counts <- by_question_word %>%
  anti_join(stop_words) %>%
  count(id, word, sort = TRUE) %>%
  ungroup()

# visualise the top 5 words in these topics 
top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

# counting from sections of data 



