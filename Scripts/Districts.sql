

SET GLOBAL local_infile = 1;

CREATE TABLE dataschoolprojectv2.main_districts (
	postcode VARCHAR(10),
	region VARCHAR(100)
);
    
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/Postcode districts_short.csv'
INTO TABLE dataschoolprojectv2.main_districts
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
