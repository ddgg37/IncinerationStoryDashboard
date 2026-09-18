
-- ###################################################################
-- THIS SCRIPT CONVERTS AND CLEANS UP THE DATA FROM SPECIAL CHARACTERS
-- THERE ARE AS WELL GENERIC DATA CHECK SCRIPTS TO UNDETAND BETTER THE DATA INSIDE THIS TABLE 
-- ###################################################################


-- Clean up and transformation of few fields in the tasble
SELECT 
	authority AS original,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''),
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
                        '')) AS authority_converted
FROM
    dataschoolprojectv2.main_waste_collection_23_25;



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


select * from main_waste_collection_23_25
where authority like '%london%';

UPDATE dataschoolprojectv2.main_waste_collection_23_25 
SET 
    authority = 'City of London'
WHERE authority = 'of London';


-- ##################################################################
-- Remove special characters from material group

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @character9 = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material_group, 
CASE
	WHEN material_group LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material_group LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material_group LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE material_group LIKE CONCAT('%', @character13, '%') OR 
	material_group LIKE CONCAT('%', @character10, '%') OR 
	material_group LIKE CONCAT('%', @character9, '%'); 

-- Remove Return, line feed or tab characters
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


-- Transform Periods

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period = 'Period';

DELETE FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period = 'Period';

-- We create two data columns to store period as date

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN period_start DATE,
ADD COLUMN period_end DATE;

SELECT
    period,
    STR_TO_DATE(
        CONCAT('01 ', TRIM(SUBSTRING_INDEX(period, '-', 1))),
        '%d %b %y'
    ) AS period_start,
    STR_TO_DATE(
        CONCAT('01 ', RIGHT(period, 6)),
        '%d %b %y'
    ) AS period_end
FROM dataschoolprojectv2.main_waste_collection_23_25;

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

-- Add new column for postCode district calculation as Tableau not recognising most of the postcodes

DESCRIBE dataschoolprojectv2.main_waste_collection_23_25;

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN postcode_district VARCHAR(10);

SELECT
    UPPER(TRIM(facility_postCode)) AS facility_postCode,
    SUBSTRING_INDEX(UPPER(TRIM(facility_postCode)), ' ', 1) AS postcode_district
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_postCode IS NOT NULL
  AND TRIM(facility_postCode) <> ''
  AND national_facility_id <> 0
  AND REGEXP_LIKE(
        UPPER(TRIM(facility_postCode)),
        '^[A-Z]{1,2}[0-9][0-9A-Z]?[[:space:]][0-9][A-Z]{2}$'
      )    
GROUP BY
    UPPER(TRIM(facility_postCode)),
    SUBSTRING_INDEX(UPPER(TRIM(facility_postCode)), ' ', 1)
ORDER BY
    facility_postCode;
  
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
  
SELECT facility_postCode,postcode_district FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE postcode_district  <> '';

-- Adding treatment group field to simplify more Tableau 

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
ADD COLUMN treatment_group VARCHAR(250);

-- There is a problem with total tonnesin Financial year 2017/18, for some reason they added a decimal part of the value

WITH update_tonnes AS (
	SELECT
		total_tonnes
	FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE period_start >= '2017-04-01'
		AND period_start < '2018-04-01'
)
UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 10
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Landfill";

UPDATE dataschoolprojectv2.main_waste_collection_23_25
#SET total_tonnes = total_tonnes * 100
SET total_tonnes = total_tonnes / 100 ##only NULL back to initial stage
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Incineration"
    AND material_group IS NULL;
    
UPDATE dataschoolprojectv2.main_waste_collection_23_25
SET total_tonnes = total_tonnes * 100 #in material group it is distibilising
WHERE period_start >= '2017-04-01'
	AND period_start < '2018-04-01' 
    AND treatment_group = "Incineration"
    AND material_group IS NOT NULL;    
    
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


-- #################################QUERIES RELATED TO SEASONAL MATERIAL PERIODS #######################################

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

WITH cleaned AS (
    SELECT
        material_group,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE
            WHEN MONTH(period_start) >= 4 THEN YEAR(period_start)
            ELSE YEAR(period_start) - 1
        END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM main_waste_collection_23_25
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material_group, period_start
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes ASC)  AS trough_rank
    FROM cleaned
),
peaks_troughs AS (
    SELECT
        material_group,
        fiscal_year,
        MAX(CASE WHEN peak_rank = 1 THEN fiscal_quarter END)  AS peak_quarter,
        MAX(CASE WHEN peak_rank = 1 THEN total_tonnes END)    AS peak_tonnes,
        MAX(CASE WHEN trough_rank = 1 THEN fiscal_quarter END) AS trough_quarter,
        MAX(CASE WHEN trough_rank = 1 THEN total_tonnes END)   AS trough_tonnes
    FROM ranked
    GROUP BY material_group, fiscal_year
)
-- Part 1: peak/trough detail per material, per year
SELECT
    material_group,
    fiscal_year,
    peak_quarter,
    ROUND(peak_tonnes, 0)   AS peak_tonnes,
    trough_quarter,
    ROUND(trough_tonnes, 0) AS trough_tonnes,
    ROUND((peak_tonnes - trough_tonnes) / trough_tonnes * 100, 1) AS swing_pct
FROM peaks_troughs
ORDER BY material_group, fiscal_year;


-- ########################################################################

WITH cleaned AS (
    SELECT
        material_group,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE
            WHEN MONTH(period_start) >= 4 THEN YEAR(period_start)
            ELSE YEAR(period_start) - 1
        END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM main_waste_collection_23_25
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material_group, period_start
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank
    FROM cleaned
),
peak_quarters AS (
    SELECT material_group, fiscal_year, fiscal_quarter
    FROM ranked
    WHERE peak_rank = 1
)
SELECT
    material_group,
    COUNT(DISTINCT fiscal_year)    AS years_covered,
    COUNT(DISTINCT fiscal_quarter) AS distinct_peak_quarters,
    GROUP_CONCAT(DISTINCT fiscal_quarter ORDER BY fiscal_year) AS peak_quarter_by_year,
    CASE
        WHEN COUNT(DISTINCT fiscal_quarter) = 1 THEN 'Consistent — likely genuine seasonal pattern'
        ELSE 'Inconsistent — probably not seasonal'
    END AS verdict
FROM peak_quarters
GROUP BY material_group
ORDER BY verdict, material_group;

-- #####BIGGEST SEASONAL SWINGS ########

SELECT
    material_group,
    material,
    fiscal_year,
    peak_quarter,
    ROUND(peak_tonnes, 0)   AS peak_tonnes,
    trough_quarter,
    ROUND(trough_tonnes, 0) AS trough_tonnes,
    ROUND((peak_tonnes - trough_tonnes) / trough_tonnes * 100, 1) AS swing_pct
FROM peaks_troughs
ORDER BY swing_pct DESC;   -- biggest seasonal swings first

--  MORE USEFUL QUERY ABOUT SEASONAL DATA

WITH cleaned AS (
    SELECT
        material,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE WHEN MONTH(period_start) >= 4 THEN YEAR(period_start) ELSE YEAR(period_start) - 1 END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM main_waste_collection_23_25
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material, period_start
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY material, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank,
        RANK() OVER (PARTITION BY material, fiscal_year ORDER BY total_tonnes ASC)  AS trough_rank
    FROM cleaned
),
peak_quarters AS (
    SELECT material, fiscal_year, fiscal_quarter,
           MAX(CASE WHEN peak_rank=1 THEN total_tonnes END)   AS peak_tonnes,
           MAX(CASE WHEN trough_rank=1 THEN total_tonnes END) AS trough_tonnes
    FROM ranked
    WHERE peak_rank = 1 OR trough_rank = 1
    GROUP BY material, fiscal_year, fiscal_quarter
),
verdict AS (
    SELECT
        material,
        COUNT(DISTINCT fiscal_quarter) AS distinct_peak_quarters,
        AVG((peak_tonnes - trough_tonnes) / NULLIF(trough_tonnes,0) * 100) AS avg_swing_pct
    FROM peak_quarters
    GROUP BY material
)
SELECT
    material,
    ROUND(avg_swing_pct, 1) AS avg_swing_pct
FROM verdict
WHERE distinct_peak_quarters = 1        -- only genuinely consistent (seasonal) materials
ORDER BY avg_swing_pct DESC;            -- strongest seasonal swing first


-- Material calculation 
SELECT
    material,
    period_start,
    period_id,
    SUM(tonnes_by_material) AS total_tonnes
FROM main_waste_collection_23_25  -- main_waste_collection_23_25
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('Mixed cans', 'Green glass')
GROUP BY material, period_start, period_id
ORDER BY material, period_start;

SELECT
    w.material,
    w.period_start,
    w.period_id,
    SUM(w.tonnes_by_material) AS total_tonnes
FROM main_waste_collection_23_25 w
JOIN authority_locations_lookup al
    ON w.authority_id = al.authority_id
WHERE w.facility_type <> 'Final Destination'
  AND w.tonnes_by_material > 0
  AND w.material IN ('Mixed cans', 'Green glass')
  AND al.geography_type IN ('Unitary Authority', 'Non-metropolitan District', 'Metropolitan District', 'London Borough')
GROUP BY w.material, w.period_start, w.period_id
ORDER BY w.material, w.period_start;

--  ###############################GNERAL QUERIES##########################

SELECT distinct(authority)  
FROM dataschoolprojectv2.main_waste_collection_23_25;

-- Data Analisys
SELECT DISTINCT(material),material_group,authority, period_id, period, tonnes_by_material, total_tonnes 
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE TRIM(material) != '';

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25 
WHERE TRIM(material) = ''; -- check waste stream type

-- General information
SELECT wc.material,wc.authority, wc.period_id, wc.period, SUM(wc.tonnes_by_material), al.population
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,wc.authority, wc.period_id, wc.period, al.population;

SELECT wc.authority_id, wc.authority, wc.total_tonnes 
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority = al.authority_name;

SELECT count(wc.authority_id) 
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority_id = al.authority_id; -- 623755

SELECT count(wc.authority_id) 
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority = al.authority_convert; -- 601406


-- SUM of tonnes by material
SELECT 
	wc.material,
    al.authority_convert, 
    al.population, 
    wc.period, 
    ROUND(SUM(wc.tonnes_by_material), 2) as material_tonnes, 
    ROUND((al.population * 100)/@England_population, 2) as population_percentage
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,al.authority_convert, al.population, wc.period
ORDER BY SUM(wc.tonnes_by_material) DESC;

    
SELECT count(distinct(wc.authority_id)) 
FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN dataschoolprojectv2.authority_locations_lookup al
ON wc.authority_id = al.authority_id;  -- 321

SELECT count(*) 
FROM dataschoolprojectv2.authority_locations_lookup al
JOIN dataschoolprojectv2.local_authority_districts_2025 la
ON al.authority_convert = la.lad25_name
where la.lad25_code LIKE 'E%';  -- 292

SELECT authority, tonnes_by_material, total_tonnes FROM dataschoolprojectv2.main_waste_collection_2025;

-- total tonnes per period
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschoolprojectv2.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest per population and material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschoolprojectv2.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest when tonnes per material is zero
SELECT * FROM dataschoolprojectv2.main_waste_collection_2025
where output_process_type = 'Treatment unknown';

-- to differetiate total_tonnes and tonnes by material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), material, authority FROM dataschoolprojectv2.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, material, authority;

SELECT count(*) FROM dataschoolprojectv2.main_waste_collection_23_25;

SELECT count(distinct(location_code)) FROM dataschoolprojectv2.authority_locations_lookup
where location_code like 'E%';

SELECT SUM(population) FROM dataschoolprojectv2.authority_locations_lookup
where location_code like 'E%';

SELECT * FROM dataschoolprojectv2.authority_locations_lookup
where location_code like 'E%';

SELECT * FROM dataschoolprojectv2.authority_locations_lookup
where location_code like 'E%';

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25
where waste_processor_id = 0;

SELECT count(distinct(authority_id)) FROM dataschoolprojectv2.main_waste_collection_23_25;

SELECT SUM(tonnes_by_material), material_group FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE material_group like '%organic%'
GROUP BY material_group;

DELETE FROM dataschoolprojectv2.main_waste_collection_23_25 
WHERE waste_processor_id = 0;

SELECT
    w.authority_id,
    w.authority,
    w.material,
    w.material_group,
    w.facility_type,
    w.period_start,
    w.tonnes_by_material,
    al.population,
    al.geography_type
FROM waste_collection_23_25_summary w
JOIN authority_locations_lookup al
    ON w.authority_id = al.authority_id;
    
    
SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25 
WHERE authority LIKE '%london%';

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25 
WHERE authority LIKE '%london%';

SELECT facility_type, total_tonnes, tonnes_by_material, period FROM dataschoolprojectv2.main_waste_collection_23_25
#where YEAR(period_start) = 2020;
where period like '%21%';

SELECT distinct(period_start) FROM dataschoolprojectv2.main_waste_collection_23_25;

SELECT distinct(facility_type) FROM dataschoolprojectv2.main_waste_collection_23_25 where facility_type like '%recycling%';

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25
where period like '%22%';

SELECT facility_type, YEAR(period_start), SUM(tonnes_by_material) FROM dataschoolprojectv2.main_waste_collection_23_25
GROUP BY facility_type, YEAR(period_start);

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25 
where YEAR(period_start) = 2025;

SELECT SUM(tonnes_by_material), sum(total_tonnes), SUM(tonnes_from_WfH_sources), SUM(tonnes_from_WnfH_sources) FROM dataschoolprojectv2.main_waste_collection_23_25 
where national_facility_id !=0 and facility_type = 'Incineration without energy recovery' and YEAR(period_start) = 2023; -- 23 149.68 63077.92 # 24 623.61 154094.96 # 25 


SELECT SUM(tonnes_by_material), sum(total_tonnes) FROM dataschoolprojectv2.main_waste_collection_23_25 
where national_facility_id !=0 and facility_type = 'Incineration without energy recovery' and YEAR(period_start) = 2023; -- 149.68 63077.92

SELECT
    waste_stream_type,
    facility_type,
    COUNT(*) AS records,
    SUM(total_tonnes) AS total_tonnes,
    SUM(tonnes_by_material) AS tonnes_by_material
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2020-04-01'
  AND period_start < '2021-04-01'
  AND national_facility_id != 0
  AND facility_type = 'Incineration without energy recovery'
GROUP BY
    waste_stream_type,
    facility_type
ORDER BY total_tonnes DESC;

SELECT
    material,
    material_group,
    period_start
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2020-04-01'
  AND period_start < '2021-04-01';

SELECT
    waste_stream_type,
    facility_type,
    SUM(total_tonnes) AS total_tonnes,
    SUM(tonnes_by_material) AS tonnes_by_material
FROM dataschoolprojectv2.main_waste_collection_23_25
GROUP BY waste_stream_type,facility_type;

SELECT
    distinct(waste_stream_type),
    facility_type
FROM dataschoolprojectv2.main_waste_collection_23_25;

SELECT
    SUM(total_tonnes) AS total_tonnes,
    SUM(tonnes_by_material) AS tonnes_material
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2024-04-01'
  AND period_start < '2025-04-01'
  AND national_facility_id != 0
  AND facility_type = 'Incineration without energy recovery'
  OR facility_type = 'Incineration with energy recovery';

SELECT
    SUM(total_tonnes) AS total_tonnes,
    SUM(tonnes_by_material) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2024-04-01'
  AND period_start < '2025-04-01'
  AND national_facility_id != 0
  AND treatment_group = "Landfill";
  
 SELECT
    SUM(total_tonnes) AS total_tonnes,
    SUM(tonnes_by_material) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start >= '2024-04-01'
  AND period_start < '2025-04-01'
  AND national_facility_id != 0
  AND facility_type = "qualifying composting/digestion"; 

ALTER TABLE dataschoolprojectv2.main_waste_collection_23_25
DROP COLUMN period;

SELECT *
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE authority LIKE '%Allasanne%';

SELECT
    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    SUM(
        CASE
            WHEN facility_type IN (
                'Reprocessor - recycling (qu19)',
                'Exporter - recycling (qu19)',
                'Reuse (qu35)'
            )
            THEN tonnes_by_material
            ELSE 0
        END
    ) AS recycling_tonnes,

    SUM(tonnes_by_material) AS total_tonnes,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN facility_type IN (
                    'Reprocessor - recycling (qu19)',
                    'Exporter - recycling (qu19)',
                    'Reuse (qu35)'
                )
                THEN tonnes_by_material
                ELSE 0
            END
        )
        / NULLIF(SUM(tonnes_by_material), 0),
        2
    ) AS recycling_rate_percent

FROM dataschoolprojectv2.main_waste_collection_23_25

GROUP BY financial_year
ORDER BY financial_year;

-- Food waste
-- Comingled recyclate
-- Green waste / Mixed green and food waste
-- Residual waste

SELECT
    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    SUM(
        CASE
            WHEN waste_stream_type IN ('Food waste')
				THEN tonnes_by_material
            ELSE 0
        END
    ) AS food_waste_tonnes,

	SUM(
        CASE
            WHEN waste_stream_type IN ('Comingled recyclate')
				THEN tonnes_by_material
            ELSE 0
        END
    ) AS dry_recycling_tonnes,
    
    SUM(
        CASE
            WHEN waste_stream_type IN (
				'Green waste',
                'Mixed green and food waste')
				THEN tonnes_by_material
            ELSE 0
        END
    ) AS green_waste_tonnes,
    
    SUM(
        CASE
            WHEN waste_stream_type IN (
				'Residual waste')
				THEN tonnes_by_material
            ELSE 0
        END
    ) AS residual_waste_tonnes,
    
    SUM(tonnes_by_material) AS total_tonnes,

	ROUND(
        100 *
		SUM(
			CASE
				WHEN waste_stream_type IN ('Food waste')
					THEN tonnes_by_material
				ELSE 0
			END
    	)/ NULLIF(SUM(tonnes_by_material), 0),
		2		
	) AS food_waste_reciclate_rate_percent,

	ROUND(
        100 *
		SUM(
			CASE
				WHEN waste_stream_type IN ('Comingled recyclate')
					THEN tonnes_by_material
				ELSE 0
			END
		)/ NULLIF(SUM(tonnes_by_material), 0),
		2		
	) AS dry_reciclate_rate_percent,
    
    ROUND(
        100 *
		SUM(
			CASE
				WHEN waste_stream_type IN (
					'Green waste',
					'Mixed green and food waste')
					THEN tonnes_by_material
				ELSE 0
			END
		)
        / NULLIF(SUM(tonnes_by_material), 0),
		2
	) AS green_waste_rate_percent,

    ROUND(
        100 *    
		SUM(
			CASE
				WHEN waste_stream_type IN (
					'Residual waste')
					THEN tonnes_by_material
				ELSE 0
			END
		)
		/ NULLIF(SUM(tonnes_by_material), 0),
		2
	) AS residual_rate_percent
  
FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE material_group IS NOT NULL AND facility_type_id != 0

GROUP BY financial_year
ORDER BY financial_year;

-- residual waste tonnes

SELECT
    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    SUM(
        CASE
            WHEN waste_stream_type IN (
                'Residual waste'
            )
            THEN tonnes_by_material
            ELSE 0
        END
    ) AS recycling_tonnes,

    SUM(tonnes_by_material) AS total_tonnes
  
FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE material_group IS NOT NULL

GROUP BY financial_year
ORDER BY financial_year;

-- Residual waste

SELECT
    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    SUM(
        CASE
            WHEN waste_stream_type = 'Residual waste'
            THEN total_tonnes
            ELSE 0
        END
    ) AS residual_waste_tonnes,

    SUM(total_tonnes) AS total_tonnes

FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE material_group IS NOT NULL

GROUP BY financial_year
ORDER BY financial_year;

SELECT
    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    SUM(
        CASE
            WHEN waste_stream_type = 'Residual waste'
            THEN tonnes_from_WfH_sources
            ELSE 0
        END
    ) AS residual_waste_tonnes,

    SUM(tonnes_from_WfH_sources) AS total_waste_from_households,

    ROUND(
        100 *
        SUM(
            CASE
                WHEN waste_stream_type = 'Residual waste'
                THEN tonnes_from_WfH_sources
                ELSE 0
            END
        )
        /
        NULLIF(SUM(tonnes_from_WfH_sources), 0),
        2
    ) AS residual_waste_percentage

FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE facility_type <> 'Final Destination'
  AND tonnes_from_WfH_sources IS NOT NULL

GROUP BY financial_year
ORDER BY financial_year;

select * from dataschoolprojectv2.main_waste_collection_23_25 
where  tonnes_from_WfH_sources IS NOT NULL and tonnes_from_WfH_sources > 0 ANd facility_type <> 'Final Destination';

-- to detect problem of duplicated records in tonnes_from_wfh_sources
SELECT
    waste_processor_id,
    waste_stream_id,
    facility_type,
    national_facility_id,
    total_tonnes,
    tonnes_from_WfH_sources,
    COUNT(*) AS number_of_rows,
    COUNT(DISTINCT material_group) AS material_groups,
    SUM(tonnes_by_material) AS sum_material_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE tonnes_from_WfH_sources IS NOT NULL
  AND tonnes_from_WfH_sources > 0
  AND facility_type IS NOT NULL
  AND facility_type <> 'Final Destination'
GROUP BY
    waste_processor_id,
    waste_stream_id,
    facility_type,
    national_facility_id,
    total_tonnes,
    tonnes_from_WfH_sources
HAVING COUNT(*) > 1
ORDER BY number_of_rows DESC;


SELECT
    waste_processor_id,
    waste_stream_id,
    MAX(tonnes_from_WfH_sources) AS wfh_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE tonnes_from_WfH_sources IS NOT NULL
  AND tonnes_from_WfH_sources > 0
  AND facility_type IS NOT NULL
  AND facility_type <> 'Final Destination'
GROUP BY
    waste_processor_id,
    waste_stream_id;
    
-- incineration with energy recovery progression

SELECT
    financial_year,
    SUM(wfh_tonnes) AS total_waste_from_households
FROM (
    SELECT
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,

        waste_processor_id,
        waste_stream_id,

        MAX(tonnes_from_WfH_sources) AS wfh_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE tonnes_from_WfH_sources IS NOT NULL
      AND tonnes_from_WfH_sources > 0
      AND facility_type IS NOT NULL
      AND facility_type <> 'Final Destination'

    GROUP BY
        financial_year,
        waste_processor_id,
        waste_stream_id
) x

GROUP BY financial_year
ORDER BY financial_year;



SELECT
    financial_year,
    SUM(wfh_tonnes) AS total_waste_from_households
FROM (
    SELECT
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,

        authority,
        period_start,
        waste_processor_id,
        waste_stream_id,

        MAX(tonnes_from_WfH_sources) AS wfh_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE tonnes_from_WfH_sources IS NOT NULL
      AND tonnes_from_WfH_sources > 0
      AND facility_type IS NOT NULL
      AND facility_type <> 'Final Destination'

    GROUP BY
        financial_year,
        authority,
        period_start,
        waste_processor_id,
        waste_stream_id
) x

GROUP BY financial_year
ORDER BY financial_year;


-- relationship waste stream and facility types
SELECT
    waste_stream_type,
    facility_type,
    COUNT(*) AS number_of_records,
    ROUND(SUM(tonnes_by_material), 2) AS tonnes_by_material
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE waste_stream_type = 'Residual waste'
  AND facility_type IS NOT NULL
  AND facility_type <> 'Final Destination'
GROUP BY
    waste_stream_type,
    facility_type
ORDER BY
    waste_stream_type,
    tonnes_by_material DESC;
    
-- Facility types, with all waste streams
     
SELECT
    waste_stream_type,
    facility_type,
    COUNT(*) AS number_of_records,
    ROUND(SUM(total_tonnes), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE waste_stream_type IS NOT NULL
  AND facility_type IS NOT NULL
  AND facility_type <> 'Final Destination'
GROUP BY
    waste_stream_type,
    facility_type
ORDER BY
    waste_stream_type,
    total_tonnes DESC;
    
-- Facility types only connected to residual waste
SELECT
    facility_type,
    COUNT(*) AS number_of_records,
    ROUND(SUM(tonnes_by_material), 2) AS tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE waste_stream_type = 'Residual waste'
  AND facility_type IS NOT NULL
  AND facility_type <> 'Final Destination'
GROUP BY facility_type
ORDER BY tonnes DESC;    

-- Check facilities in England

DESCRIBE dataschoolprojectv2.main_waste_collection_23_25;

SELECT
    national_facility_id,
    facility_name,
    facility_type,
    TRIM(facility_postCode),
    facility_address,
    COUNT(*) AS number_of_records,
    ROUND(SUM(tonnes_by_material), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IS NOT NULL
  AND LOWER(facility_type) LIKE '%incineration%'
  AND national_facility_id <> 0
  AND facility_name <> "Other/Exempt"
  AND facility_postCode IS NOT NULL 
  AND facility_postCode != ""
  AND facility_postCode != "na"
  AND facility_postCode != "Unknown"
  AND facility_postCode != "Multiple"
GROUP BY
    national_facility_id,
    facility_name,
    facility_type,
    facility_postCode,
    facility_address
ORDER BY
    total_tonnes DESC;

SELECT
    national_facility_id,
    facility_name,
    facility_type,
    facility_address,
    facility_postCode,
    COUNT(*) AS number_of_records,
    ROUND(SUM(tonnes_by_material), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_postCode IS NOT NULL
  AND TRIM(facility_postCode) <> ''
  AND facility_postCode <> "na"
  AND facility_postCode <> "Unknown"
  AND facility_postCode <> "Multiple"  
  AND facility_name <> 'Other/Exempt'
  AND national_facility_id <> 0
  AND (
        LOWER(facility_type) LIKE '%incineration%'
        OR facility_type = 'Advanced Thermal Treatment'
      )  
GROUP BY
    national_facility_id,
    facility_name,
    facility_type,
    facility_address,
    facility_postCode
ORDER BY
    facility_name;

-- Not repeated PostCodes with correct format

SELECT
    TRIM(facility_postCode) AS facility_postCode,
    GROUP_CONCAT(DISTINCT facility_name SEPARATOR ', ') AS facility_names,
    GROUP_CONCAT(DISTINCT facility_type SEPARATOR ', ') AS facility_types,
    GROUP_CONCAT(DISTINCT facility_address SEPARATOR ', ') AS facility_addresses,
    COUNT(DISTINCT national_facility_id) AS number_of_facilities,
    ROUND(SUM(tonnes_by_material), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_postCode IS NOT NULL
  AND TRIM(facility_postCode) <> ''
  AND facility_name <> 'Other/Exempt'
  AND national_facility_id <> 0
  AND (
        LOWER(facility_type) LIKE '%incineration%'
        OR facility_type = 'Advanced Thermal Treatment'
      )
GROUP BY
    TRIM(facility_postCode)
ORDER BY
    facility_postCode;

-- incineration by Post code

SELECT
    UPPER(TRIM(facility_postCode)) AS facility_postCode,
    SUBSTRING_INDEX(UPPER(TRIM(facility_postCode)), ' ', 1) AS postcode_district,
    GROUP_CONCAT(DISTINCT facility_name SEPARATOR ', ') AS facility_names,
    GROUP_CONCAT(DISTINCT facility_type SEPARATOR ', ') AS facility_types,
    GROUP_CONCAT(DISTINCT facility_address SEPARATOR ', ') AS facility_addresses,
    COUNT(DISTINCT national_facility_id) AS number_of_facilities,
    ROUND(SUM(tonnes_by_material), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_postCode IS NOT NULL
  AND TRIM(facility_postCode) <> ''
  AND facility_name <> 'Other/Exempt'
  AND national_facility_id <> 0
  AND (
        LOWER(facility_type) LIKE '%incineration%'
        OR facility_type = 'Advanced Thermal Treatment'
      )
  AND REGEXP_LIKE(
        UPPER(TRIM(facility_postCode)),
        '^[A-Z]{1,2}[0-9][0-9A-Z]?[[:space:]][0-9][A-Z]{2}$'
      )    
GROUP BY
    UPPER(TRIM(facility_postCode)),
    SUBSTRING_INDEX(UPPER(TRIM(facility_postCode)), ' ', 1)
ORDER BY
    facility_postCode;
    
    

SELECT
    national_facility_id,
    facility_name,
    facility_type,
    TRIM(facility_postCode),
    facility_address
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IS NOT NULL
  AND LOWER(facility_type) LIKE '%incineration%'
  AND national_facility_id = 7932;
    
SELECT
    national_facility_id,
    facility_name,
    facility_type,
    COUNT(*) AS number_of_records,
    ROUND(SUM(total_tonnes), 2) AS total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IS NOT NULL
  AND (
        LOWER(facility_type) LIKE '%incineration%'
        OR facility_type = 'Advanced Thermal Treatment'
      )
  AND national_facility_id <> 0
GROUP BY
    national_facility_id,
    facility_name,
    facility_type
ORDER BY
    total_tonnes DESC;
    
SELECT    
	authority,
    facility_name,    
    TRIM(facility_postCode),
    facility_address
FROM dataschoolprojectv2.main_waste_collection_23_25
where authority = "*";    


-- *************************************************************
-- Analysis for 3rd version focus on incineration and landfill

-- Adding Treatment groups

SELECT
    period_id,
    period_start,
    period_end,
    'Incineration' AS treatment_group,
    SUM(total_tonnes) AS total_incineration_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IN (
    'Incineration with energy recovery',
    'Incineration without energy recovery',
    'Advanced Thermal Treatment'
)
GROUP BY
    period_id,
    period_start,
    period_end
ORDER BY
    period_start;

    
-- Add quarter progression in treatment_group
-- gorka

WITH incineration_by_period AS (
    SELECT
        period_id,
        period_start,
        period_end,
        SUM(total_tonnes) AS incineration_tonnes
    FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE facility_type IN (
        'Incineration with energy recovery',
        'Incineration without energy recovery',
        'Advanced Thermal Treatment'
    )
    GROUP BY
        period_id,
        period_start,
        period_end
)

SELECT
    period_id,
    period_start,
    period_end,
    incineration_tonnes,

    LAG(incineration_tonnes) OVER (
        ORDER BY period_start
    ) AS previous_quarter_tonnes,

    incineration_tonnes
        - LAG(incineration_tonnes) OVER (
            ORDER BY period_start
        ) AS tonnes_change,

    ROUND(
        (
            incineration_tonnes
            - LAG(incineration_tonnes) OVER (
                ORDER BY period_start
            )
        )
        /
        LAG(incineration_tonnes) OVER (
            ORDER BY period_start
        ) * 100,
        2
    ) AS percentage_change

FROM incineration_by_period
ORDER BY period_start;    
    
-- YEAR progression

WITH incineration_by_year AS (
    SELECT
        YEAR(period_start) AS year_period,
        SUM(tonnes_by_material) AS incineration_tonnes
    FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE facility_type IN (
        'Incineration with energy recovery',
        'Incineration without energy recovery',
        'Advanced Thermal Treatment'
    )
    GROUP BY YEAR(period_start)
)

SELECT
    year_period,
    incineration_tonnes,

    LAG(incineration_tonnes) OVER (
        ORDER BY year_period
    ) AS previous_year_tonnes,

    incineration_tonnes
        - LAG(incineration_tonnes) OVER (
            ORDER BY year_period
        ) AS tonnes_change,

    ROUND(
        (
            incineration_tonnes
            - LAG(incineration_tonnes) OVER (ORDER BY year_period)
        )
        /
        LAG(incineration_tonnes) OVER (ORDER BY year_period)
        * 100,
        2
    ) AS percentage_change

FROM incineration_by_year
ORDER BY year_period;

-- WITH tonnes_from_WfH_sources

WITH incineration_by_year AS (
    SELECT
        YEAR(period_start) AS year_period,
        SUM(tonnes_from_WfH_sources) AS tonnes_from_WfH_sources
    FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE facility_type IN (
        'Incineration with energy recovery',
        'Incineration without energy recovery',
        'Advanced Thermal Treatment'
    )
    GROUP BY YEAR(period_start)
)

SELECT
    year_period,
    tonnes_from_WfH_sources,

    LAG(tonnes_from_WfH_sources) OVER (
        ORDER BY year_period
    ) AS previous_year_tonnes,

    tonnes_from_WfH_sources
        - LAG(tonnes_from_WfH_sources) OVER (
            ORDER BY year_period
        ) AS tonnes_change,

    ROUND(
        (
            tonnes_from_WfH_sources
            - LAG(tonnes_from_WfH_sources) OVER (ORDER BY year_period)
        )
        /
        LAG(tonnes_from_WfH_sources) OVER (ORDER BY year_period)
        * 100,
        2
    ) AS percentage_change

FROM incineration_by_year
ORDER BY year_period;

-- YEARLY landfill

WITH landfill_by_year AS (
    SELECT
        YEAR(period_start) AS year_period,
        SUM(tonnes_by_material) AS landfill_tonnes
    FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE facility_type IN (
		'Inert landfill',
		'Non-hazardous landfill',
		'Hazardous landfill'
	)
    GROUP BY YEAR(period_start)
)

SELECT
    year_period,
    landfill_tonnes,

    LAG(landfill_tonnes) OVER (
        ORDER BY year_period
    ) AS previous_year_tonnes,

    landfill_tonnes
        - LAG(landfill_tonnes) OVER (
            ORDER BY year_period
        ) AS tonnes_change,

    ROUND(
        (
            landfill_tonnes
            - LAG(landfill_tonnes) OVER (
                ORDER BY year_period
            )
        )
        /
        LAG(landfill_tonnes) OVER (
            ORDER BY year_period
        ) * 100,
        2
    ) AS percentage_change

FROM landfill_by_year
ORDER BY year_period;

-- FINANCIAL YEAR

WITH landfill_by_financial_year AS (
    SELECT
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,

        SUM(total_tonnes) AS landfill_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE facility_type IN (
		'Inert landfill',
		'Non-hazardous landfill',
		'Hazardous landfill'
	)

    GROUP BY
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END
)

SELECT
    financial_year,
    landfill_tonnes,

    LAG(landfill_tonnes) OVER (
        ORDER BY financial_year
    ) AS previous_year_tonnes,

    landfill_tonnes
        - LAG(landfill_tonnes) OVER (
            ORDER BY financial_year
        ) AS tonnes_change,

    ROUND(
        (
            landfill_tonnes
            - LAG(landfill_tonnes) OVER (
                ORDER BY financial_year
            )
        )
        /
        LAG(landfill_tonnes) OVER (
            ORDER BY financial_year
        ) * 100,
        2
    ) AS percentage_change

FROM landfill_by_financial_year
ORDER BY financial_year;

-- Incineration + Financial year

WITH incineration_by_year AS (
    SELECT
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,
        SUM(total_tonnes) AS incineration_tonnes
    FROM dataschoolprojectv2.main_waste_collection_23_25
    WHERE facility_type IN (
        'Incineration with energy recovery',
        'Incineration without energy recovery',
        'Advanced Thermal Treatment'
    ) AND waste_stream_type = 'Residual waste'
    GROUP BY
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END
)

SELECT
    financial_year,
    incineration_tonnes,

    LAG(incineration_tonnes) OVER (
        ORDER BY financial_year
    ) AS previous_year_tonnes,

    incineration_tonnes
        - LAG(incineration_tonnes) OVER (
            ORDER BY financial_year
        ) AS tonnes_change,

    ROUND(
        (
            incineration_tonnes
            - LAG(incineration_tonnes) OVER (ORDER BY financial_year)
        )
        /
        LAG(incineration_tonnes) OVER (ORDER BY financial_year)
        * 100,
        2
    ) AS percentage_change

FROM incineration_by_year
ORDER BY financial_year;   


-- check where comes the incineration spike 

SELECT
    facility_name,
    facility_type,
    period_start,
    ROUND(SUM(tonnes_by_material), 2) AS tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IN (
    'Incineration with energy recovery',
    'Incineration without energy recovery',
    'Advanced Thermal Treatment'
)
AND period_start BETWEEN '2020-10-01' AND '2021-06-30'
GROUP BY
    facility_name,
    facility_type,
    period_start
ORDER BY
    period_start,
    tonnes DESC;
 
 SELECT
    authority,
    authority_id,
    waste_processor_id,
    national_facility_id,
    facility_name,
    facility_type,
    waste_stream_type,
    material,
    total_tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE period_start = '2021-04-01'
  AND facility_name = ''
  AND facility_type = 'Incineration with energy recovery'
ORDER BY tonnes_by_material DESC;

SELECT
    YEAR(period_start),
    LAG(SUM(total_tonnes)) OVER(ORDER BY YEAR(period_start)) AS previous_year_tonnes,
    SUM(total_tonnes) AS tonnes,
    LAG(SUM(total_tonnes)) OVER(ORDER BY YEAR(period_start)) - SUM(total_tonnes) AS difference,
    LAG(SUM(tonnes_by_material)) OVER(ORDER BY YEAR(period_start)) AS previous_year_tonnes_material,
    SUM(tonnes_by_material) AS tonnes_material,
    LAG(SUM(tonnes_by_material)) OVER(ORDER BY YEAR(period_start)) - SUM(tonnes_by_material) AS difference_material
FROM dataschoolprojectv2.main_waste_collection_23_25
WHERE facility_type IN (
    'Incineration with energy recovery',
    'Incineration without energy recovery',
    'Advanced Thermal Treatment'
)
AND waste_stream_type = 'Residual waste'
GROUP BY
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END;

SELECT
    waste_processor_id,
    waste_stream_id,
    period_start,
    authority,
    facility_type,
    COUNT(*) AS number_of_rows,
    MIN(total_tonnes) AS min_total_tonnes,
    MAX(total_tonnes) AS max_total_tonnes,
    SUM(total_tonnes) AS summed_total_tonnes

FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE facility_type IN (
    'Incineration with energy recovery',
    'Incineration without energy recovery',
    'Advanced Thermal Treatment'
)
AND waste_stream_type = 'Residual waste'

GROUP BY
    waste_processor_id,
    waste_stream_id,
    period_start,
    authority,
    facility_type

ORDER BY number_of_rows DESC;

WITH deduplicated_landfill AS (
    SELECT
        waste_processor_id,
        waste_stream_id,
        YEAR(period_start) AS year,
        authority_id,
        facility_type,
        MAX(total_tonnes) AS total_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE facility_type IN (
        'Inert landfill',
		'Non-hazardous landfill',
        'Hazardous landfill'
    )
    AND waste_stream_type = 'Residual waste'

    GROUP BY
        waste_processor_id,
        waste_stream_id,
        YEAR(period_start),
        authority_id,
        facility_type
)

SELECT
    year,
    SUM(total_tonnes) AS landfill_tonnes

FROM deduplicated_landfill

GROUP BY year
ORDER BY year;

WITH deduplicated_landfill AS (
    SELECT
        waste_processor_id,
        waste_stream_id,
        authority_id,
        facility_type,

        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,

        MAX(total_tonnes) AS total_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE facility_type IN (
		'Inert landfill',
		'Non-hazardous landfill',
        'Hazardous landfill'
    )
    AND waste_stream_type = 'Residual waste'
    #AND material_group NOT REGEXP '^[0-9]+$'
    
    GROUP BY
        waste_processor_id,
        waste_stream_id,
        authority_id,
        facility_type,
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END
)

SELECT
    financial_year,
    ROUND(SUM(total_tonnes), 2) AS landfill_tonnes

FROM deduplicated_landfill

GROUP BY financial_year
ORDER BY financial_year;


WITH deduplicated_incineration AS (
    SELECT
        waste_processor_id,
        waste_stream_id,
        authority_id,
        facility_type,

        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END AS financial_year,

        MAX(total_tonnes) AS total_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE facility_type IN (
        'Incineration with energy recovery',
        'Incineration without energy recovery',
        'Advanced Thermal Treatment'
    )
    AND waste_stream_type = 'Residual waste'
    AND material_group NOT REGEXP '^[0-9]+$'
    
    GROUP BY
        waste_processor_id,
        waste_stream_id,
        authority_id,
        facility_type,
        CASE
            WHEN MONTH(period_start) >= 4 THEN
                CONCAT(
                    YEAR(period_start),
                    '/',
                    RIGHT(YEAR(period_start) + 1, 2)
                )
            ELSE
                CONCAT(
                    YEAR(period_start) - 1,
                    '/',
                    RIGHT(YEAR(period_start), 2)
                )
        END
)

SELECT
    financial_year,
    ROUND(SUM(total_tonnes), 2) AS incineration_tonnes

FROM deduplicated_incineration

GROUP BY financial_year
ORDER BY financial_year;

SELECT
    treatment_group,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT authority_id) AS authorities,
    COUNT(DISTINCT waste_processor_id) AS processors,
    COUNT(DISTINCT waste_stream_id) AS waste_streams,
    ROUND(SUM(total_tonnes), 0) AS raw_total_tonnes

FROM dataschoolprojectv2.main_waste_collection_23_25

WHERE treatment_group = "Landfill"
    OR treatment_group = 'Incineration'
    AND waste_stream_type = 'Residual waste'
	AND (period_start >= '2017-04-01'
	AND period_start < '2018-04-01')
GROUP BY treatment_group;



-- creating a view

CREATE OR REPLACE VIEW dataschoolprojectv2.vw_residual_treatment AS

WITH deduplicated AS (

    SELECT
        waste_processor_id,
        waste_stream_id,
        authority_id,
        period_start,

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
        END AS treatment_group,

        MAX(total_tonnes) AS total_tonnes

    FROM dataschoolprojectv2.main_waste_collection_23_25

    WHERE waste_stream_type = 'Residual waste'
      AND facility_type IN (
          'Incineration with energy recovery',
          'Incineration without energy recovery',
          'Advanced Thermal Treatment',
          'Inert landfill',
          'Non-hazardous landfill',
          'Hazardous landfill'
      )

    GROUP BY
        waste_processor_id,
        waste_stream_id,
        authority_id,
        period_start,
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
        END
)

SELECT
    period_start,

    CASE
        WHEN MONTH(period_start) >= 4 THEN
            CONCAT(
                YEAR(period_start),
                '/',
                RIGHT(YEAR(period_start) + 1, 2)
            )
        ELSE
            CONCAT(
                YEAR(period_start) - 1,
                '/',
                RIGHT(YEAR(period_start), 2)
            )
    END AS financial_year,

    treatment_group,

    SUM(total_tonnes) AS treatment_tonnes

FROM deduplicated

GROUP BY
    period_start,
    treatment_group;

SELECT *
FROM dataschoolprojectv2.vw_residual_treatment
ORDER BY period_start, treatment_group;


