
-- ###################################################################
-- THIS IS THE PROCEDURE THAT WILL CREATE AND LOAD DATA FOR THE UK REGIONS AND AUTHORITIES
-- ###################################################################

DELIMITER $$

CREATE PROCEDURE main_england_regions_and_local_authorities_table_procedure()
BEGIN

	DROP TABLE IF EXISTS dataschoolprojectv2.main_local_authority_districts_23;

	CREATE TABLE dataschoolprojectv2.main_england_regions_23 (
	lad23cd VARCHAR(15),
	lad23nm VARCHAR(100),
	rgn23cd VARCHAR(100),
    rgn23nm VARCHAR(100),
    objectid INT
	);
    
END $$

DELIMITER ;
