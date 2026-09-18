
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

-- C:\Users\aDesktop\Development\DataSchoolProject\IncinerationStoryDashboard\Datasets\OriginalResources

-- Import Data from csv file to Waste Collection Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2024-25.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2023-24.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2022-23.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2021-22.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100+Waste+Collection+data+England+2020-21.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100_Waste_collection_data_England_2019-20.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100_Waste_collection_data_England_2018-19.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100_Data_England_2017_2018.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100_Data_England_2016_2017_rev.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Q100_Data_England_2015_2016_rev.csv'
INTO TABLE dataschoolprojectv2.main_waste_collection_23_25
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;

-- Import Data from csv file to Population Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/UKPopulationByAuthority2024.csv'
INTO TABLE dataschoolprojectv2.main_population_UK_by_location_2024
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- STAGE: Clean up Authorities names for match later on

UPDATE dataschoolprojectv2.main_waste_collection_23_25 
SET 
    authority = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''),
                                                                'Borough',
                                                                ''),
                                                            'District',
                                                            ''),
                                                        'MBC',
                                                        ''),
                                                    'LB',
                                                    ''),
                                                'County',
                                                ''),
                                            'City',
                                            ''),
                                        'Waste',
                                        ''),
                                    'Authority',
                                    ''),
                                'WDA ()',
                                ''),
                            'MDC ()',
                            ''),
                        'MDC',
                        '')));

-- Change London Authority for match with lad23nm

UPDATE dataschoolprojectv2.main_waste_collection_23_25 
SET 
    authority = 'City of London'
WHERE authority = 'of London';

-- Remove special characters in Material-group
 
-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @character9 = CHAR(9);

UPDATE dataschoolprojectv2.main_waste_collection_23_25 
SET material_group = 
		REPLACE(
			REPLACE(
				REPLACE(material_group, @character13, ''),
			@character10, ''),
		@character9, '')
WHERE material_group LIKE CONCAT('%', @character13, '%')
   OR material_group LIKE CONCAT('%', @character10, '%')
   OR material_group LIKE CONCAT('%', @character9, '%');

-- We create a date format for more convenience in Tableau
   
ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN period_start DATE,
ADD COLUMN period_end DATE;

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET period_start = STR_TO_DATE(
    CONCAT(
        '01 ',
        TRIM(SUBSTRING_INDEX(period, '-', 1))
    ),
    '%d %b %y'
);

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET period_end = STR_TO_DATE(
	CONCAT(
		'01 ',
		TRIM(SUBSTRING_INDEX(period, '-', -1))
	),
	'%d %b %y'
);


-- Create a new postcode field for first part of post code

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN postcode_district VARCHAR(10);

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET postcode_district =
    SUBSTRING_INDEX(UPPER(TRIM(facility_postCode)), ' ', 1)
WHERE facility_postCode IS NOT NULL
  AND TRIM(facility_postCode) <> ''
  AND national_facility_id <> 0
  AND REGEXP_LIKE(
        UPPER(TRIM(facility_postCode)),
        '^[A-Z]{1,2}[0-9][0-9A-Z]?[[:space:]][0-9][A-Z]{2}$'
      );
      
-- Adding treatment group field to simplify data in Tableau 

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN treatment_group VARCHAR(250);

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET treatment_group =
    CASE
        WHEN facility_type IN (
            'Incineration with energy recovery',
            'Incineration without energy recovery',
            'Advanced Thermal Treatment'
        )
        THEN 'Incineration'

        WHEN facility_type IN (
            'Inert landfill',
            'Non-hazardous landfill',
            'Hazardous landfill'
        )
        THEN 'Landfill'

		WHEN facility_type IN (
			'Reprocessor - recycling (qu19)',
			'Exporter - recycling (qu19)',
			'Reuse (qu35)'
        )
        THEN 'Recycling'
    END;


-- CRITICAL on 2017/18 finantial year

-- There is a problem with total tonnes in Financial year 2017/18, we need to do some adaptation of the tonnes for Residual waste

-- Landfill

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 10
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Landfill";

-- Incineration

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 12 
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Incineration"
    AND material_group = '';

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 1.16 
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Incineration"
    AND waste_stream_type = 'Residual waste';
  
-- ############################EXPORT DATA TO CSV FILE#######################################
-- Export Data to CSV file for Tableau
-- We filter only the records that belong to incineration and recycling

SELECT
    'waste_processor_id',
    'authority', 
    'authority_id',
    'period_id',
    'period_start',
    'period_end',
    'waste_stream_type_id',
    'waste_stream_type',
    'facility_type_id',
    'facility_type',
    'treatment_group',
    'national_facility_id',
    'facility_name',
    'facility_postCode',    
    'total_tonnes',
    'material_group',
    'material_id',
    'material',
    'tonnes_by_material',
    'postCode_district'

UNION ALL

SELECT
    waste_processor_id,
    authority, 
    authority_id,
    period_id,
    period_start,
    period_end,
    waste_stream_type_id,
    waste_stream_type,
    facility_type_id,
    facility_type,

    CASE
        WHEN facility_type IN (
            'Incineration with energy recovery',
            'Incineration without energy recovery',
            'Advanced Thermal Treatment'
        ) THEN 'Incineration'

        WHEN facility_type IN (
            'Inert landfill',
			'Non-hazardous landfill',
			'Hazardous landfill'
        ) THEN 'Landfill'
        
        WHEN facility_type IN (
            'Reprocessor - recycling (qu19)',
			'Exporter - recycling (qu19)',
            'Reuse (qu35)'
        ) THEN 'Recycling'
    END AS treatment_group,

    national_facility_id,
    facility_name,
    facility_postCode,    
    total_tonnes,
    material_group,
    material_id,
    material,
    tonnes_by_material,
    postcode_district

FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE facility_type IN (
    'Incineration with energy recovery',
    'Incineration without energy recovery',
    'Advanced Thermal Treatment',
    'Inert landfill',
	'Non-hazardous landfill',
	'Hazardous landfill',
	'Reprocessor - recycling (qu19)',
	'Exporter - recycling (qu19)',
	'Reuse (qu35)'
)

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportFromDBWasteCollectionSummary.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';      
      



   
   




