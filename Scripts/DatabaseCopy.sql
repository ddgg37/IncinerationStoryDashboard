describe dataschoolprojectv2.main_waste_collection_23_25;

RENAME TABLE dataschoolprojectv2.main_waste_collection_23_25_copy TO dataschoolprojectv2.main_waste_collection_23_25;

CREATE TABLE dataschoolprojectv2.main_waste_collection_23_25_copy AS 
SELECT * 
FROM dataschoolprojectv2.main_waste_collection_23_25;

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
DROP COLUMN waste_processor_id,
DROP COLUMN waste_stream_id,
DROP COLUMN waste_processor_output_id,
DROP COLUMN sender_waste_processor_output_id,
DROP COLUMN authority_id,
DROP COLUMN period_id,
DROP COLUMN waste_stream_type_id,
DROP COLUMN output_process_type_id,
DROP COLUMN material_id,
DROP COLUMN tonnes_from_HH_sources,
DROP COLUMN tonnes_from_commercial_sources,
DROP COLUMN tonnes_from_industrial_sources,
DROP COLUMN tonnes_from_non_HH_sources,
DROP COLUMN tonnes_from_WfH_sources,
DROP COLUMN tonnes_from_WnfH_sources,
DROP COLUMN usage_id,
DROP COLUMN `usage`,
DROP COLUMN quarterly_comments,
DROP COLUMN monthly_comments;
