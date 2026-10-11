
SELECT *
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND facility_type IN (
      'Incineration with energy recovery',
      'Incineration without energy recovery'
  )
ORDER BY facility_type, period_start, authority;

SELECT
    facility_type,
    COUNT(*) AS row_count,
    COUNT(DISTINCT waste_processor_id) AS distinct_processors,
    COUNT(DISTINCT waste_stream_id) AS distinct_waste_streams,
    COUNT(DISTINCT authority_id) AS distinct_authorities,
    SUM(total_tonnes) AS summed_total_tonnes,
    SUM(tonnes_by_material) AS summed_material_tonnes,
    MIN(total_tonnes) AS min_total_tonnes,
    MAX(total_tonnes) AS max_total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND facility_type IN (
      'Incineration with energy recovery',
      'Incineration without energy recovery'
  )
GROUP BY facility_type;

SELECT
    CONCAT(
        YEAR(period_start),
        '/',
        RIGHT(YEAR(period_start) + 1, 2)
    ) AS financial_year,
    period_start,
    period_end,
    authority,
    waste_processor_id,
    waste_stream_id,
    facility_type,
    waste_stream_type,
    material_group,
    material,
    total_tonnes,
    tonnes_by_material,
    national_facility_id,
    facility_name
FROM dataschoolprojectv2.main_waste_collection_23_25 mw
JOIN london_districts ld
ON mw.authority = ld.Lad23Nm
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND facility_type IN (
      'Incineration without energy recovery'
  )
  #AND waste_stream_type = 'Residual waste'
ORDER BY facility_type, period_start, authority;

##-------------------------------------------

SELECT
    facility_type,
    SUM(total_tonnes)
FROM dataschoolprojectv2.main_waste_collection_23_25 mw
JOIN london_districts ld
ON mw.authority = ld.Lad23Nm
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND facility_type IN (
      'Incineration without energy recovery'
  )
  AND waste_stream_type = 'Residual waste';
#GROUP BY facility_type;

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes / 3
WHERE period_start >= '2017-04-01'
  AND period_start < '2018-04-01'
  AND facility_type = 'Incineration without energy recovery'
  AND waste_stream_type = 'Residual waste'
  AND total_tonnes > 0;

##----------------------------------------------------

SELECT
    facility_type,
    SUM(total_tonnes)
FROM dataschoolprojectv2.main_waste_collection_23_25 mw
JOIN london_districts ld
ON mw.authority = ld.Lad23Nm
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND facility_type IN (
      'Incineration with energy recovery'
  )
  AND waste_stream_type = 'Residual waste';

UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 0.9
WHERE period_start >= '2017-04-01'
  AND period_start < '2018-04-01'
  AND facility_type = 'Incineration with energy recovery'
  AND waste_stream_type = 'Residual waste'
  AND total_tonnes > 0;  

##----------------------------------------------

SELECT
    treatment_group,
    SUM(total_tonnes)
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2017-04-01'
  AND period_start <  '2018-04-01'
  AND treatment_group = 'Landfill' 
  #AND treatment_group = 'Incineration' 
  AND waste_stream_type = 'Residual waste';
 
UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 1.3
WHERE period_start >= '2017-04-01'
  AND period_start < '2018-04-01'
  AND treatment_group = 'Landfill'
  AND waste_stream_type = 'Residual waste'
  AND total_tonnes > 0;   