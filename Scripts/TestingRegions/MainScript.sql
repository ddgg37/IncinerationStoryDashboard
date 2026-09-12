
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SHOW PROCEDURE STATUS
WHERE Db = 'dataschool_project';

SET GLOBAL local_infile = 1;

CREATE SCHEMA dataschoolprojectv2;

USE dataschoolprojectv2;

-- Crate Regions Table and load data

CALL main_england_regions_and_local_authorities_table_procedure();

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Local_Authority_District_to_Region_(December_2023)_Lookup_in_England.csv'
INTO TABLE dataschoolprojectv2.main_england_regions_23
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Local Authority Lookup

CALL dataschoolprojectv2.main_local_authority_table_procedure();

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/LocalAuthorityDistricts/LAD_DEC_2025_UK_BGC.csv'
INTO TABLE dataschoolprojectv2.main_local_authority_districts_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
    
-- England population Data

CALL dataschoolprojectv2.main_population_table_procedure();

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/UKPopulationByAuthority2024.csv'
INTO TABLE dataschoolprojectv2.main_population_UK_by_location_2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Waste Recycling Data

CALL dataschoolprojectv2.main_waste_collection_table_procedure();

-- Import 2024-25
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import 2023-24
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProjectV2/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2023-24.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
	
    