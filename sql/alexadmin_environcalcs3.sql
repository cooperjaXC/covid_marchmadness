-- Tinker with environ.mm19co2 for downstream edits

-- Make some manual geometry edits to get Minneapolis & Dayton's geoms standardized
UPDATE environ.mm19co2 SET sitegeom = '0101000020E6100000582547F0F55057C03FC4060B277D4640'
WHERE sitegeom = '0101000020E61000008EC5DBEFF55057C06F48A302277D4640';
UPDATE environ.mm19co2 SET sitegeom = '0101000020E6100000074C9649430C55C0822F963325E14340'
WHERE sitegeom = '0101000020E6100000D2AB014A430C55C017EF6C3425E14340';

-- Get summaries of distances traveled at the session level
ALTER TABLE environ.mm19co2 DROP COLUMN IF EXISTS seshtotkm;
ALTER TABLE environ.mm19co2 ADD COLUMN IF NOT EXISTS seshtotkm NUMERIC(15,3);
UPDATE environ.mm19co2 SET seshtotkm = t1km + t2km + t3km + t4km;
ALTER TABLE environ.mm19co2 DROP COLUMN IF EXISTS seshkmperteam;
ALTER TABLE environ.mm19co2 ADD COLUMN IF NOT EXISTS seshkmperteam NUMERIC(15,3);
UPDATE environ.mm19co2 SET seshkmperteam = seshtotkm / 4;


-- Now, work on taulating the data at different levels.
-- First, tabulate data at the team level
-- 1st, per team per round
CREATE TABLE environ.mm19pteam_pround AS
SELECT 
t1 as team,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t1win as result,	travelto,	t1travelfrom as travelfrom,	t1mi AS miles,	t1km AS km,	hotelghgpp,	t1food AS teamfood,	t1hotel AS teamhotel,	t1waste AS teamwaste,	t1stad as teamstad,	t1trav AS teamtrav,	t1tot AS totghg,	CAST(t1tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t1geom AS schoolgeom,	t1tositegeom AS travelgeom																																
FROM environ.mm19co2 UNION ALL SELECT 
t2,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t2win,	travelto,	t2travelfrom,	t2mi,	t2km,	hotelghgpp,	t2food,	t2hotel,	t2waste,	t2stad,	t2trav,	t2tot,	CAST(t2tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t2geom,	t2tositegeom																																
FROM environ.mm19co2 UNION ALL SELECT
t3,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t3win,	travelto,	t3travelfrom,	t3mi,	t3km,	hotelghgpp,	t3food,	t3hotel,	t3waste,	t3stad,	t3trav,	t3tot,	CAST(t3tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t3geom,	t3tositegeom																																
FROM environ.mm19co2 UNION ALL SELECT
t4,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t4win,	travelto,	t4travelfrom,	t4mi,	t4km,	hotelghgpp,	t4food,	t4hotel,	t4waste,	t4stad,	t4trav,	t4tot,	CAST(t4tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t4geom,	t4tositegeom																																
FROM environ.mm19co2
ORDER BY team,sessionid;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
-- Create geometry indexes
CREATE INDEX pathgeom_ptpr_idx ON environ.mm19pteam_pround USING gist (travelgeom);
CREATE INDEX sitegeom_ptpr_idx ON environ.mm19pteam_pround USING gist (sitegeom);
CREATE INDEX schoolgeom_ptpr_idx ON environ.mm19pteam_pround USING gist (schoolgeom);
-- Make some attendance edits for schools who lost in earlier rounds. 
UPDATE environ.mm19pteam_pround 
SET attnincluperteam = attnperteam, ghgpppteam = totghg / attnperteam
WHERE attnincluperteam IS NULL;
-- Add primary key just incase I need to import into GIS
ALTER TABLE environ.mm19pteam_pround 
ADD COLUMN pkey_id SERIAL PRIMARY KEY;

-- Now consolidate per trip. 
	-- This is key because it will normalize some of the varying session weirdness.
CREATE TABLE environ.mm19_pteam_ptrip AS SELECT
team, sitecity,	sitestate, COUNT(*) AS gamesplayed,	
CAST(AVG(attnperteam) AS NUMERIC(15,2)) as attnptpg, 
CAST(SUM(attnperteam) AS NUMERIC(10)) as sumrawattn,
CAST(AVG(attnincluperteam)AS NUMERIC(15,2)) AS attnincluptpg, 
CAST(SUM(attnincluperteam)AS NUMERIC(10)) AS sumincluattn, 
miles, km,	hotelghgpp,	
sum(teamfood) AS sumtfood, sum(teamhotel) as sumthotel, sum(teamwaste) as sumtwaste, 
SUM(teamstad) AS sumtstad, SUM(teamtrav)AS sumttrav, SUM(totghg) AS totghg,
CAST((sum(totghg)/AVG(attnincluperteam)) AS NUMERIC(15,3)) AS ghgppptptrip,
sitegeom, schoolgeom, travelgeom																																
FROM environ.mm19pteam_pround
GROUP BY
team, sitecity, sitestate, miles, km, hotelghgpp, sitegeom, schoolgeom, travelgeom
ORDER BY team
;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
-- Create primary key for importing into GIS
ALTER TABLE environ.mm19_pteam_ptrip 
ADD COLUMN pkey_id SERIAL PRIMARY KEY;
-- Create geometry indexes
CREATE INDEX pathgeom_ptpt_idx ON environ.mm19_pteam_ptrip USING gist (travelgeom);
CREATE INDEX sitegeom_ptpt_idx ON environ.mm19_pteam_ptrip USING gist (sitegeom);
CREATE INDEX schoolgeom_ptpt_idx ON environ.mm19_pteam_ptrip USING gist (schoolgeom);

