REFRESH MATERIALIZED VIEW views.dpma_format2_rapport_acdr;
SELECT
  dpma_format2_rapport_acdr."année",
  dpma_format2_rapport_acdr.mois,
  dpma_format2_rapport_acdr.pavillon,
  dpma_format2_rapport_acdr."code CFR",
  dpma_format2_rapport_acdr."nom du navire",
  dpma_format2_rapport_acdr."pays de débarquement",
  dpma_format2_rapport_acdr."espèce",
  dpma_format2_rapport_acdr."zone FAO",
  dpma_format2_rapport_acdr."sous division FAO",
  dpma_format2_rapport_acdr."zone pays tiers",
  dpma_format2_rapport_acdr."quantité capturée débarquée (en kg)"
FROM views.dpma_format2_rapport_acdr
WHERE "année"=put_year_here
AND pavillon='FRA' 
;
