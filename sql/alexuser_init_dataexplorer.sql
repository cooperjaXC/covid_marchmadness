SELECT 
-- ST_SetSRID(ST_MakePoint(sitelon, sitelat),4326),
-- (sitegeom), (sitecity), (sitestate)
-- ST_Distance(t1geom,sitegeom),
-- ST_Distance(t1geom,sitegeom, false) as sphere,
-- ST_Distance(t1geom,sitegeom, true) as spheroid,
-- ST_Distance(t1geom,sitegeom, true)/1609.344 as miles_spheroid,
-- ST_Distance(t1geom::geography,sitegeom::geography)* 0.000621371 as st_miles,
-- ST_MakeLine(t1geom, sitegeom),
t1mi * 1.609344 as t1km,
* 
FROM 
-- marchmad.teams_ncaat19
marchmad.locats_ncaat19

-- GROUP BY 
-- (sitegeom), (sitecity), (sitestate)

ORDER BY 
-- sitestate
sessionid
