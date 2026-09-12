
select count(lad23cd) from main_england_regions_23; -- 296

select count(rg.lad23cd) from main_england_regions_23 rg
join main_local_authority_districts_2025 au
on rg.lad23cd = au.lad25_code
where rg.lad23cd like 'E%'; -- 294

#where rg.rgn23nm = 'London'; -- 33

select count(*) from main_population_uk_by_location_2024 p
join main_england_regions_23 rg
on rg.lad23cd = p.location_code
where p.location_code like 'E%'; -- 296

select count(distinct(la.lad25_code)) from main_local_authority_districts_2025 la
join main_population_uk_by_location_2024 p 
on p.location_code = la.lad25_code
join main_england_regions_23 rg
on rg.lad23cd = la.lad25_code
where la.lad25_code like 'E%'; -- 294

select la.lad25_code from main_local_authority_districts_2025 la
join main_population_uk_by_location_2024 p 
on p.location_code = la.lad25_code
where la.lad25_code not in (
 select lad23cd from main_england_regions_23
); -- 65

select count(distinct(authority_id)) from main_waste_collection_23_25; -- 322


