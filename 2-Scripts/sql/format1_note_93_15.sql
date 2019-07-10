REFRESH MATERIALIZED VIEW views.dpma_format1_note_93_15;
SELECT
  dpma_format1_note_93_15."Member_State",
  dpma_format1_note_93_15."Vessel_CFR",
  dpma_format1_note_93_15."Vessel_Name",
  dpma_format1_note_93_15."SFPA_fishing_zone",
  dpma_format1_note_93_15."Time_period",
  dpma_format1_note_93_15."Category",
  dpma_format1_note_93_15."Parameter",
  dpma_format1_note_93_15."Fishing_ancillaries",
  dpma_format1_note_93_15."Species",
  dpma_format1_note_93_15."Unit",
  dpma_format1_note_93_15."Quantity"
FROM views.dpma_format1_note_93_15
WHERE "Member_State" = 'FRA'
AND "Time_period" LIKE 'put_year_here%';
