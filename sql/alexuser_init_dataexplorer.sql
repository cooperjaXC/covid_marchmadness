SELECT 
-- ST_SetSRID(ST_MakePoint(sitelon, sitelat),4326),
-- (sitegeom), (sitecity), (sitestate)
-- ST_Distance(t1geom,sitegeom),
-- ST_Distance(t1geom,sitegeom, false) as sphere,
-- ST_Distance(t1geom,sitegeom, true) as spheroid,
-- ST_Distance(t1geom,sitegeom, true)/1609.344 as miles_spheroid,
-- ST_Distance(t1geom::geography,sitegeom::geography)* 0.000621371 as st_miles,
-- ST_MakeLine(t1geom, sitegeom),
-- cast((t1mi * 1.609344) AS REAL) as t1km,
-- t2mi * 1.609344 as t2km,
-- CAST(t2mi * 1.609344 AS REAL) as t2kmreal,
-- CAST((ST_Distance(t2geom,sitegeom, true)/1000) AS REAL) as t2stkmreal,
-- attendance, attnperteam, attninclusive, attnincluperteam
sitecity, sitestate
-- * 
FROM 
marchmad.locats_ncaat19

GROUP BY 
-- (sitegeom), 
(sitecity), (sitestate)

-- WHERE 
-- t1km < 257.5 OR t2km < 257.5 OR t3km < 257.5 OR t4km < 257.5 
-- t1km < 300 OR t2km < 300 OR t3km < 300 OR t4km < 300
-- t1km < 643 OR t2km < 643 OR t3km < 643 OR t4km < 643
-- t1km < 500 OR t2km < 500 OR t3km < 500 OR t4km < 500

-- ORDER BY 
-- sessionid
-- sitestate
