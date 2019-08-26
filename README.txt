Report Reader README 
Authors: Amy Andrews & Emma Oldfield
Date: August-September 2019

----- Aim ------

To extract useful insights from qualitative in-country reports in the form of numbers included, entities referenced and frequency of words used in different sections

----- Use case -------

Exploration of trends for monthly in-country reports as relating to the topics they report on, e.g. the activities of the relevant community in the past month and new partners/organisations

------ Specification --------

> High level
- Shiny app or markdown dashboard 
- 2 tabs, one to analyse individual reports and one to analyse trends over time 
- 1 informational tab
- 1 permanent sidebar 
- Ability to upload word documents 
- Ability to write to and update a spreadsheet of insights over time 
- Ability to read and pull insights from individual word document
- Ability to read and pull insights from updating spreadsheet/ database
- Ability to associate report titles with coordinates for map 

> 1st tab: analysing individual report
- Word document uploader
- A module to show the report title
- A module to display the relevent sections of text by question from the report template*
- Feature to indicate which section of text is being analysed 
- Bar charts to show word frequencies of different sections 
- Tables to show named entities in each section of text
	- People
	- Organisations
- Tables to show relevant numbers in each section of text 
- Page organised according to the report template* key questions and whole report option 
- Option to add the generated insights to the updating spreadsheet/ database
	- Saved to trends of relevant country

> 2nd tab: showing trends over time 
- Updating spreadsheet uploader/ refresher
- Map to show different locations and projects and select different projects
- Option to switch to other tab to select individual report insights 
- Line graphs to look at all the individual report insights over time 
	- for most common word frequencies by month
	- for most common named entities by month
	- for relevant numbers by month

> Permanent sidebar
- Organises insights by report template* question
	- Option to view insights by entire report 
	- Modules on tab 1 and tab 2 update according to input here

> Informational tab
- Includes information on how to use the dashboard
- Includes any declarations made by Cool Earth
- Includes any links to help troubleshooting 
- Includes contact emails for developers

> Design 
- Cool Earth brand colours (green: #A7C484 ; blue: #75A5C1 ; accent = white)
- Cool Earth logo (on permission) 


Remaining questions:
- What is most appropriate to build the app in?
- Spreadsheet/ database?
- How does the app handle multiple different in-country reports from different sources? (e.g. in terms of keeping trends from different countries separate?)
- Confirmed report template from ce?









*The 'report template' is the core list of questions which are consistent between most reports and from which the text analysis are based on in the code