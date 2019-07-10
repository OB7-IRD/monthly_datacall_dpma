REFRESH MATERIALIZED VIEW views.logbook_for_orthongel
;

SELECT * FROM views.logbook_for_orthongel
WHERE activity_year = put_year_here
ORDER BY ocean, vessel_name, fishing_date
;
