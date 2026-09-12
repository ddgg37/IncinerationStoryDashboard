SELECT
    material,
    authority,
    period_start,
    facility_type,
    facility_name,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('HDPE [2]', 'PET [1]')
GROUP BY material, authority,period_start,facility_type, facility_name
ORDER BY facility_name DESC;

SELECT
    material,
    authority,
    period_start,
    facility_type,
    facility_name,
    
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('HDPE [2]', 'PET [1]')
GROUP BY material, authority,period_start,facility_type, facility_name
ORDER BY facility_name DESC;

SELECT
    material,
    material_group,
    year(period_start),
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('HDPE [2]', 'PET [1]')
GROUP BY material,material_group, year(period_start)
ORDER BY material,material_group, year(period_start);

SELECT
    material_group,
    year(period_start),
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material_group = 'Plastic'
GROUP BY material_group, year(period_start)
ORDER BY material_group, year(period_start);

SELECT
    'Plastic (whole group)' AS comparison_label,
    period_start,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material_group = 'Plastic'
GROUP BY period_start

UNION ALL

SELECT
    material AS comparison_label,
    period_start,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('HDPE [2]', 'PET [1]')
GROUP BY material, period_start
ORDER BY comparison_label, period_start;

SELECT
    'Plastic (whole group)' AS comparison_label,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material_group = 'Plastic'

UNION ALL

SELECT
    'PET/HDPE' AS comparison_label,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('HDPE [2]', 'PET [1]')
ORDER BY comparison_label;