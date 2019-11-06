Report Reader README 
Authors: Amy Andrews & Emma Oldfield
Date: August-November 2019

## Aim

To extract useful insights from qualitative in-country reports by summarising them through the lens of the 17 SDGs

## Use case

Used to read through historical texts and pick out words and the sentence they belong to related to the 17 different SDGs by topic, and show where these are in the document.

## Specification

### High level
There are two tasks; extracting the SDG-relevant sections of the reports and presentation these to the user.
Further to this, the extraction of the SDGs relies on the preprocessing of SDG text data to create 17 reliable topics which can then be used to categorise the sentences of documents that the model has never seen. These then need to be presented to the user, by SDG type, in a way which is allows for information to be sifted quickly and reports to be created. 

## Future improvements 
- How do we define the 17 topics? Can we use Word2Vec to solve this problem?
- Read in excel files to gain similar information as from word/pdf docs


## Files to hand over
report_reader.R - This is the central .R file containing instructions on how to produce word searches for the 17 SDG key words. It calls the following two funcitons:
  read_in.R 
  check_words.R
  
sdg_outputs folder contains 