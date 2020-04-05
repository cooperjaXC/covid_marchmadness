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
-- 1st, use miles
UPDATE marchmad.locats_ncaat19
SET t1mi = ST_Distance(t1geom::geography,sitegeom::geography)* 0.000621371 
			-- could also be > ST_Distance(t1geom,sitegeom, true)/1609.344
;
UPDATE marchmad.locats_ncaat19
SET t2mi = ST_Distance(t2geom::geography,sitegeom::geography)* 0.000621371,
	t3mi = ST_Distance(t3geom::geography,sitegeom::geography)* 0.000621371,
	t4mi = ST_Distance(t4geom::geography,sitegeom::geography)* 0.000621371
;
-- But since most co2eq studies use kilometers, calc that too. 
	-- putting the "true" booleen argument in the 3rd position makes results of ST_Distance = meters
UPDATE marchmad.locats_ncaat19
SET t1km = ST_Distance(t1geom,sitegeom, true)/1000,
	t2km = ST_Distance(t2geom,sitegeom, true)/1000,
	t3km = ST_Distance(t3geom,sitegeom, true)/1000,
	t4km = ST_Distance(t4geom,sitegeom, true)/1000;

-- Get the distance represented as geometry for downstream visualizations in ArcGIS/QGIS
UPDATE marchmad.locats_ncaat19
SET t1tositegeom = ST_MakeLine(t1geom, sitegeom),
	t2tositegeom = ST_MakeLine(t2geom, sitegeom),
	t3tositegeom = ST_MakeLine(t3geom, sitegeom),
	t4tositegeom = ST_MakeLine(t4geom, sitegeom);

-- Add attendance columns accounting for 28 players, coaches & staff per team (112 overall).
ALTER TABLE marchmad.locats_ncaat19
ADD COLUMN attninclusive numeric (5, 0);
ALTER TABLE marchmad.locats_ncaat19
ADD COLUMN attnincluperteam numeric (7, 2);

-- -- 4 teams per session, remember?
-- UPDATE marchmad.locats_ncaat19
-- SET attninclusive = attendance + (28 * 4);
-- -- Then, get that value divided by 4 
-- UPDATE marchmad.locats_ncaat19
-- SET attnincluperteam = attninclusive / 4;

-- 4 teams per session
	-- but only include teams when they play that session.
	-- ie when teams don't play Elite 8 or Natty C, only 28 * 2
UPDATE marchmad.locats_ncaat19
SET attninclusive = 
	CASE WHEN ((lower(round) LIKE 'elite%eight') 
		OR (lower(round) LIKE 'national%championship'))
	THEN attendance + (28 * 2)
	ELSE 	attendance + (28 * 4)
	END;
-- Then, get that value divided by 4 
UPDATE marchmad.locats_ncaat19
SET attnincluperteam = 
	CASE WHEN ((lower(round) LIKE 'elite%eight') 
		OR (lower(round) LIKE 'national%championship'))
	THEN NULL  -- Not an even distribution per team in the session. 
			-- Some teams have players, some do not
	ELSE attninclusive / 4  -- When each team in the session is playing and has fans
	END;

