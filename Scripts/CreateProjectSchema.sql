
-- ###################################################################
-- THIS IS THE INITIAL SCRIPT TO RUN TO CREATE THE TABLES AND LOAD DATA
-- ###################################################################

-- Few Mysql settings check
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SHOW PROCEDURE STATUS
WHERE Db = 'dataschoolprojectv2';

SET GLOBAL local_infile = 1;

-- Create Schema
CREATE SCHEMA IF NOT EXISTS dataschoolprojectv2;

-- Set as default Schema
USE dataschoolprojectv2;

-- Call Procedure the procedures to create the master tables and load the data
#CALL dataschoolprojectv2.main_local_authority_table_procedure();
CALL dataschoolprojectv2.main_population_table_procedure();
CALL dataschoolprojectv2.main_waste_collection_table_procedure();

SHOW PROCEDURE STATUS
WHERE Db = 'dataschoolprojectv2';

-- Import Data from csv file to Waste Collection Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2024-25.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2023-24.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2022-23.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2021-22.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2020-21.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Data from csv file to Population Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/UKPopulationByAuthority2024.csv'
INTO TABLE dataschoolprojectv2.main_population_UK_by_location_2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;





