-- BEFORE BEGINNING! run createpsqldb_fromcmdline.bash
	-- has important features including enabling postgis & hstore
-- Check these installations
SELECT postgis_full_version();  
-- should return something. If error, troubleshoot the .bash file process.

CREATE SCHEMA skratch, marchmad;

GRANT USAGE ON SCHEMA skratch, marchmad TO alexuser;

-- Now, from QGIS, I imported the teams and their locations from a .kml file into skratch.
-- Copy relevant fields into the marchmad schema.
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad TO alexuser;
CREATE TABLE marchmad.teams_ncaat19 AS 
SELECT id, name as teamname, description as descrip, ST_Force2d(geom) as teamgeom
FROM skratch.teams_ncaat19_qgisimport;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad TO alexuser;
CREATE INDEX IF NOT EXISTS teamgeom_init ON marchmad.teams_ncaat19 using gist(teamgeom);
-- now all teams and their geographies are in your DB! Huzzah


-- Now you need your game locations in there too w/ geom. 

-- A good deal of this prep work was done in excel manually
	-- I used a ncaa tourney bracket and publically available attendance data to compile sheet at the session unit of analysis to record where and when teams played.
	-- Then, I used batchgeo.com to geocode the tourney locations. 
		-- Downloaded as a .kml. 
		-- Opened the .kml in an excel file as a .xml table.
		-- then moved the lat and lon back to the original excel file I was working with. 
			-- these will later be geocoded w/ postgis. See below.
	-- Then, I converted the excel sheet to a simple .csv.
	
-- Prepare a sql table for .csv import
CREATE TABLE IF NOT EXISTS marchmad.locats_ncaat19(
	SessionID serial PRIMARY KEY,
	Round	text,
	SiteCity	varchar,
	SiteState	varchar(2),
	attendance	numeric(5),  -- No game has more than 99,999 fans
	t1	text,
	t2	text,
	t3	text,
	t4	text,
	t1win	varchar(4),
	t2win	varchar(4),
	t3win	varchar(4),
	t4win	varchar(4),
	attnperteam	numeric(7,2),
	travelto	varchar(4),
	t1travelfrom	varchar(4),
	t2travelfrom	varchar(4),
	t3travelfrom	varchar(4),
	t4travelfrom	varchar(4),
	t1geom	geometry,
	t2geom	geometry,
	t3geom	geometry,
	t4geom	geometry,
	sitegeom	geometry,
	sitelat	double precision,
	sitelon	double precision,
	t1mi	real,
	t2mi 	real,
	t3mi	real,
	t4mi	real,
	t1tositegeom	geometry,
	t2tositegeom	geometry,
	t3tositegeom	geometry,
	t4tositegeom 	geometry
	);
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad TO alexuser;
