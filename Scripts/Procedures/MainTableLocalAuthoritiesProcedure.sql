
-- ###################################################################
-- THIS IS THE PROCEDURE THAT WILL CREATE AND LOAD DATA FOR THE UK AUTHORITY CODES AND NAMES
-- ###################################################################

DELIMITER $$

CREATE PROCEDURE main_local_authority_table_procedure()
BEGIN

	DROP TABLE IF EXISTS dataschoolprojectv2.main_local_authority_districts_2025;

	CREATE TABLE dataschoolprojectv2.main_local_authority_districts_2025 (
	lad25_code VARCHAR(15),
	lad25_name VARCHAR(100),
	lad_nmw VARCHAR(100),
	bng_e int,
	bng_n int,
	long_n int,
	lat_n int,
	global_id VARCHAR(100));
    
    
END $$

DELIMITER ;
