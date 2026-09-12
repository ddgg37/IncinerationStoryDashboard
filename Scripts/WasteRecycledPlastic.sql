

SELECT MIN(period_start) FROM dataschoolprojectv2.main_waste_collection_23_25;


-- All facility types
SELECT distinct(facility_type_id),facility_type FROM dataschoolprojectv2.main_waste_collection_23_25
where waste_stream_type = 'residual waste' AND national_facility_id != 0
order by facility_type_id;

SELECT SUM(tonnes_by_material) FROM dataschoolprojectv2.main_waste_collection_23_25
#where facility_type like '%recycling%' AND national_facility_id != 0 AND year(period_start) = 2023;
#where facility_type like '%incinera%' AND national_facility_id != 0 AND year(period_start) = 2025;
where facility_type like '%landfil%' AND national_facility_id != 0 AND year(period_start) = 2023;

-- Tonnes for recycling, incineration, landfil
SELECT SUM(tonnes_by_material) FROM dataschoolprojectv2.main_waste_collection_23_25
#where facility_type like '%recycling%' AND national_facility_id != 0 AND year(period_start) = 2023;
#where facility_type like '%incinera%' AND national_facility_id != 0 AND year(period_start) = 2025;
where facility_type like '%landfil%' AND national_facility_id != 0 AND year(period_start) = 2023;

SELECT er.rgn23nm,count(distinct(national_facility_id))  FROM dataschoolprojectv2.main_waste_collection_23_25 wc
JOIN main_england_regions_23 er
ON wc.authority = er.lad23nm
GROUP BY er.rgn23nm;

SELECT * FROM dataschoolprojectv2.main_waste_collection_23_25
where national_facility_id != 0 AND material_group like 'Plastic%';

SELECT er.lad23nm,er.rgn23nm,mw.material_group,mw.material,mw.tonnes_by_material FROM dataschoolprojectv2.main_waste_collection_23_25 mw 
JOIN main_england_regions_23 er
ON mw.authority = er.lad23nm
where national_facility_id != 0 AND material_group like 'Plastic%';

SELECT er.rgn23cd,
er.rgn23nm,
pu.location_name,
pu.geography_type,
pu.population,
mw.material,
mw.waste_stream_type,
SUM(mw.tonnes_by_material) as tonnes
FROM dataschoolprojectv2.main_waste_collection_23_25 mw 
JOIN main_england_regions_23 er
ON mw.authority = er.lad23nm
JOIN main_population_uk_by_location_2024 pu
ON er.rgn23cd = pu.location_code
WHERE mw.national_facility_id != 0 AND mw.material_group like 'Plastic%'
GROUP BY er.rgn23cd,er.rgn23nm,pu.location_name,pu.geography_type,pu.population,mw.material,mw.waste_stream_type
ORDER BY tonnes,er.rgn23nm asc;

