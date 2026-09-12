select count(distinct(lp.location_name)) from main_population_uk_by_location_2024 lp
join main_waste_collection_23_25 wc
on lp.location_name = wc.authority;

select count(distinct(la.lad25_name)) from main_local_authority_districts_2025 la
join main_waste_collection_23_25 wc
on la.lad25_name = wc.authority; -- 12

select * from main_local_authority_districts_2025
where lad25_name like '%london%';

select * from main_waste_collection_23_25
where authority like '%london%';

select count(*) from main_population_uk_by_location_2024 pu
join main_waste_collection_23_25 wc
on pu.location_name = wc.authority;

select * from main_population_uk_by_location_2024
where location_name like '%london%';




