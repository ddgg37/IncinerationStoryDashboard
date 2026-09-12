
-- ###################################################################
-- THIS IS THE PROCCEDURE TO CREATE AND LOAD DATA OF UK POPULATION BASED ON LOCATION CODE
-- ###################################################################

DELIMITER $$

CREATE PROCEDURE main_population_table_procedure()
BEGIN

	DROP TABLE IF EXISTS dataschoolprojectv2.main_population_UK_by_location_2024;
 
	-- Create Table
	CREATE TABLE dataschoolprojectv2.main_population_UK_by_location_2024 (
	location_code VARCHAR(15),
	location_name VARCHAR(100),
	geography_type VARCHAR(100),
	population INT);
  
END $$

DELIMITER ;
