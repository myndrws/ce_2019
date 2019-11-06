Report Reader README 
Authors: Amy Andrews & Emma Oldfield
Date: August-November 2019

## Aim

To extract useful insights from qualitative in-country reports by summarising them through the lens of the 17 SDGs.

## Use case

Used to read through historical texts and pick out words and the sentence they belong to related to the 17 different SDGs by topic, and show where these are in the document.

### High level
There are three tasks; reading in relevant documents, extracting the SDG-relevant sections of the reports, and presentating these to the user.

Further to this, the extraction of the SDGs relies on the preprocessing of SDG text data to create 17 reliable topics which can then be used to categorise the sentences of documents that the model has never seen. These then need to be presented to the user, by SDG type, in a way which is allows for information to be sifted quickly, in a way which allows the user to find the original report and sentence. 

Each SDG is defined by a vector of important words and phrases which have been defined by combining expert knowledge and by running TF-IDF analyses on SDG content to extract words most often associated with that SDG proportional to their rarity. 

## Future improvements 
- Read in excel files to gain similar information as from word/pdf docs
- Edit openxlsx function at the end of the report_reader script to read R dataframe into Excel properly (encoding issues?)
- Can we include a summary of each read-in document using TF-IDF, in the same way as we extracted the original words?
- Can we use Word2Vec to help find sdg references in a more sophisticated way?

## Files to hand over
report_reader.R - This is the central .R file containing instructions on how to produce word searches for the 17 SDG key words. It calls the following two functions:
  read_in.R 
  check_words.R

## Outputs
Outputs have been handed over to the organisation, along with instructions on how to interpret them. 
  
