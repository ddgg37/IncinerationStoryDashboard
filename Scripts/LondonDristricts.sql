
SET GLOBAL local_infile = 1;

CREATE TABLE dataschoolprojectv2.london_districts (
Lad23cd VARCHAR(40),
Lad23Nm VARCHAR(80),
london_subregion VARCHAR(20));

LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/IncinerationStoryDashboard/Datasets/OriginalResources/london_33_authorities_central_east_north_south_west.csv'
INTO TABLE dataschoolprojectv2.london_districts
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS;
    