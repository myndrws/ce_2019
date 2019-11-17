Report Reader README 
Authors: Amy Andrews & Emma Oldfield
Date: August-November 2019

## Aim

To extract useful insights from qualitative in-country reports by summarising them through the lens of the 17 SDGs.

## Use case

Used to read through historical texts and pick out words and the sentence they belong to related to the 17 different SDGs by topic, and show where these are in the document.

## Description

There are three tasks; reading in relevant documents (pdf, word, excel and csv files), extracting the SDG-relevant sections of the reports (defined by the user), and presentating these to the user (in an excel format).

Further to this, the extraction of the SDGs relies on the preprocessing of SDG text data to create 17 reliable topics which can then be used to categorise the sentences of documents that the program reads in. These then need to be presented to the user, by SDG type, in a way which is allows for information to be sifted quickly, in a way which allows the user to find the original report and sentence. 

Each SDG is defined by a vector of important words and phrases which have been defined by combining expert knowledge and by running TF-IDF analyses on SDG content to extract words most often associated with that SDG proportional to their rarity. The data which was used for the TF-IDF analyses was compiled from information on the SDGS from the UN Sustainable Development Goals website, and can be found in word documents in the folder SDG data. The TF-IDF analysis was carried out using the summarise_SDGs script, which also calls the function word_frequencies.R, neither of which is used directly by the final report reading program.

## How to use

The only file which should need modification to run the program is report_reader.R. This is the central .R file containing instructions on how to produce word searches for the 17 SDG key words. It calls the following two functions:
  read_in.R 
  check_words.R

File paths for which documents should be read can be changed at the start of the report_reader.R script. The file path should also be set for where the program should look to read in the target words for which it scans the read in documents (i.e. the SDG keywords).

To update the words which the report reader is looking for, the file sdg_output/sdg_words_manual_output-2019-11-04.xls should be edited. This is read in in step 3 of the the report_reader.R file and so will need to have a test run after this file is edited.

### Reading in relevant documents 

The function read_in.R is called in the report_reader.R script from the functions folder. read_in.R checks whether the file it is attempting to read in is a pdf, word (either .docx or .doc) excel (either .xls or .xlsx) or csv document. Depending on what kind of file it is, it uses different R packages to read in that file. Once the file has been read in to R as a dataframe with the text of the file in one column, the function also gets the extension of file and the filepath and binds this information into a 3-column dataframe. read_in.R calls a sub-function, all_sheets_to_chr.R, for reading in excel files. Excel files may contain multiple sheets which all need to be read in separately, so this is the main purpose of all_sheets_to_chr.R.

When multiple files are read in all at once, as is called in the report_reader.R script, they are joined together to make one big dataframe. 
Then each file has the it's text data 'tokenised'. For pdf and word documents, this means the text data is broken down into sentences, and each sentence is given its own ID. For excel and csv files, because these are spreadsheets, there are no sentences - so even though the tokenising function is run on them, they are not broken down. Instead, the 'sentence_id' number for these files can be interpreted as the sheet number the text data was found in (in the case of workbooks with multiple sheets). Once all the files have been appropriately tokenised, the resulting dataframe in R is reports_tokenised_all. 

### Extracting the SDG relevant parts of documents

Step 3 in report_reader.R creates vectors of the words of interest (i.e. the words we want to find in our documents). It does this by reading in the excel sheet where the words are stored, and combining the words into a vector based on which SDG they belong to (defined in the excel sheet).

Step 4 then finds any of the words contained in these vectors within the dataframe containing the tokenised text data of all the documents. For each of the 17 SDGs, a new column is created which searches each row of tokenised text and pulls out all of the words of interest for that SDG. It does this by calling the function check_words.R, which searches for a regex match for each of the words in the SDG vector and then, if more than one word is found, binds these together as a single string. It then returns all these words. Only tokenised text which has SDG words found within it is then kept in the dataframe.

Please note that this part of the script can take a substantial time to run if it has to scan through thousands of read in documents. We have tried to make the process as efficient as possible, but R can still take a lot of time to run this.

### Presenting to the user

The final part of the report_reader.R script (from Step 5 onwards) prepares the dataframe created in the previous step and currently stored in R's memory (occurance_SDG) and prepares it to be written to an excel workbook file. This workbook has three sheets, two of which are summary sheets and one which prints the dataframe created in the previous step. Formatting is also applied at this stage.

Please note that there was an unknown issue in running the saving of the resulting xlsx workbook when the script was run originally, though this was suspected due to a system error outside of our control and may not persist in subsequent runnings of the script.

### Additional: plot file structure

The final part of the report_reader.R script runs a separate analyses of the file structure of input folders, and creates a plot of these as a tree structure, which is then written to a separate excel workbook file. This is useful for visualising how different folders are organised.

## Future improvements 

- Put the plotting of file structure into a separate R file from report_reader.R
- Edit openxlsx function at the end of the report_reader script to read R dataframe into Excel properly (encoding issues?)
- Potential: including a summary of each read-in document using TF-IDF, in the same way as we extracted the original words?
- Potential: using Word2Vec to help find sdg references in a more sophisticated way?

## Outputs
Outputs have been handed over to the organisation, along with instructions on how to interpret them. 
  
