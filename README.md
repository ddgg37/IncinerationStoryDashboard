# London residual waste treatment (2015 - 2025)

  I decided to build a dashboard related to recycling and waste management in England. This is an interesting topic for me as people do not care or value the cost of managing the waste we throw away. The reality is that we need to start taking seriously what we throw away and make the effort to do our best to separate different type of waste like recycling, composting or rubbish.  

## Recycling has become far too complex topic

  Although it sounds surprising nowadays there is not much information about the waste treatment process, unless we search in internet. From my point of view, public services should inform and educate the population about their impact in waste management with their daily decisions and this is why I decided to analyse the data from Defra and do this dashboard.

  I started trying to cover all parts of waste management but I realise it was too extensive and this is why I decided to simplify it. Surprisingly, I was disappointed to find out that recycling is not doing well and this is the reason why incineration and landfill are taking more importance. The only thing I can say is that there is not perfect solution for a complex problem like this one.

## Challenge I faced with data

  Defra has extensive datasets, you can find quite detailed data from previous years. The fact the data is quite complex can bring you to a quite extensive dashboard, my fear was I would not be able to communicate clearly about the waste management problem.

  I decided to make two decisions so that I could simplify the data to get a more understandable dashboard:
  
  - I download the last ten years of waste data from Defra. This allowed me to analyse the progressions of waste that ended up or pass through incineration and landfill facilities.
  - Focus on London districts only, as I am a London habitant, I though it would be good to focus in the city I live.  

## Technology used for this project

- Github : Version Control used to upload all Scripts, Resources, Tableau project and Documentation.
- MySQL : Database used to import/export and transform data into csv file.
- MS Excell : To view xls/csv files.
- Tableau : This is the main tool to create the sheets and Dashboard.

## Data Origin

- <a href="https://www.data.gov.uk/dataset/0e0c12d8-24f6-461f-b4bc-f6d6a5bf2de5/waste-data-flow" target="_blank">Waste Recycling Data</a>

- <a href="https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland%26lang%3Dde%26lang%3Dde" target="_blank">The UK Population Data</a>

- <a href="https://geoportal.statistics.gov.uk/datasets/ons::local-authority-districts-december-2025-boundaries-uk-bfc/about" target="_blank">Local Authority District</a>



## SQL Procedures to created Master Tables (inside Procedures folder)

- MainTableLocalAuthoritiesProcedure.sql - This procedure stores the UK authorities name, code and geolocation data
- MainTablePopulationProcedure.sql - This procedure stores the each authorities population data
- MainTableWasteCollectionProcedure.sql - This is the biggest and the most important data, it will store the waste collection data in England between 2023 and 2025

## Loading data Script (inside Scripts folder)

- CreateProjectSchema - It will run all the procedures, mentioned before, creating the tables and loading data to master tables

## Data Conversion Scripts (inside Scripts folder)

- WasterCollectionSummaryQueries.sql - This script contains the Data local authorities names conversion and clean up. This is important for a correct link with Authorities population data
- AuthotiryLocationMappingQueries.sql - This is the most important query as it populated the lookup table that works as a bridge between local authorities and ONS codes 
- DataAnalysisScripts.sql - This is a mix of different queries to check data content in different tables

## Data Export Scripts

- The scripts are contained in the Data conversion ones

## Tableau Data Source, Sheet, and Dashboard (inside Tableau folder)

- The Tableau project is stored inside Tableau folder

## The Datasets are not included in this repository as they were quite big files


