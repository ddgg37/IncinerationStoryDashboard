


SELECT
    'location_code',
    'location_name',
    'geography_type',    
    'population'
UNION ALL
SELECT
    location_code,
    location_name,
    geography_type,
    population
FROM dataschoolprojectv2.main_population_uk_by_location_2024
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportLADPopulation.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';