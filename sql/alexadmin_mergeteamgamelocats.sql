-- BEFORE BEGINNING! run alexadmin_initdb_importdata.sql
	-- will import the tables referenced here. 
-- Goal = get all geographic data merged into one table.

-- Update the session table to have geoms for site locations. 
UPDATE marchmad.locats_ncaat19
SET sitegeom = ST_SetSRID(ST_MakePoint(sitelon, sitelat),4326);
--GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad TO alexuser;
DROP INDEX IF EXISTS og_sitegeom_idx;
CREATE INDEX og_sitegeom_idx ON marchmad.locats_ncaat19 USING gist(sitegeom);

-- Move teams' geoms to the corresponding columns using UPDATE commands.
UPDATE marchmad.locats_ncaat19 sitetab
SET t1geom = teamtab.teamgeom
FROM marchmad.teams_ncaat19 teamtab
WHERE teamtab.teamname = sitetab.t1 
;
UPDATE marchmad.locats_ncaat19 sitetab
SET t2geom = teamtab.teamgeom
FROM marchmad.teams_ncaat19 teamtab
WHERE teamtab.teamname = sitetab.t2
;
UPDATE marchmad.locats_ncaat19 sitetab
SET t3geom = teamtab.teamgeom
FROM marchmad.teams_ncaat19 teamtab
WHERE teamtab.teamname = sitetab.t3
;
UPDATE marchmad.locats_ncaat19 sitetab
SET t4geom = teamtab.teamgeom
FROM marchmad.teams_ncaat19 teamtab
WHERE teamtab.teamname = sitetab.t4
;

-- Calculate the distance from each team in the session to its NCAAT site
UPDATE marchmad.locats_ncaat19
SET t1dist = ST_Distance(t1geom::geography,sitegeom::geography)* 0.000621371 
			-- could also be > ST_Distance(t1geom,sitegeom, true)/1609.344
;
UPDATE marchmad.locats_ncaat19
SET t2dist = ST_Distance(t2geom::geography,sitegeom::geography)* 0.000621371,
	t3dist = ST_Distance(t3geom::geography,sitegeom::geography)* 0.000621371,
	t4dist = ST_Distance(t4geom::geography,sitegeom::geography)* 0.000621371
;

-- Get the distance represented as geometry for downstream visualizations in ArcGIS/QGIS
UPDATE marchmad.locats_ncaat19
SET t1tositegeom = ST_MakeLine(t1geom, sitegeom),
	t2tositegeom = ST_MakeLine(t2geom, sitegeom),
	t3tositegeom = ST_MakeLine(t3geom, sitegeom),
	t4tositegeom = ST_MakeLine(t4geom, sitegeom);