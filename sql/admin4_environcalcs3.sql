-- Tinker with environ.mm19co2 for downstream edits
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
CAST(AVG(attnperteam) AS NUMERIC(15,2)) as attnptptrip, 
CAST(SUM(attnperteam) AS NUMERIC(15,2)) as sumrawattn,  -- Cast with decimals to avoid downstream rounding errors. 
CAST(AVG(attnincluperteam)AS NUMERIC(15,2)) AS attnincluptptrip, -- Inclusive attendance per team per game in trip. Big one!
CAST(SUM(attnincluperteam)AS NUMERIC(15,2)) AS sumincluattn, 
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


-- Now consolidate per team
CREATE TABLE environ.mm19perteam AS SELECT
team, SUM(gamesplayed) AS ngmsplyd, COUNT(gamesplayed) AS ntrips, sum(attnptptrip) AS totfanattnpteam, SUM(sumrawattn) as sum_raw_indoor_attn, 
-- This is the big normalizing attendance field you'll want. 
SUM(attnincluptptrip) AS totincluattnpteam, -- !!
SUM(sumincluattn) AS sum_inclu_indoor_attn,
CAST(AVG(miles) AS REAL) AS avmiptrip, CAST(AVG(km) AS REAL) AS avgkmptrip,
SUM(sumtfood) AS sumtfood, SUM(sumthotel) AS sumthotel, SUM(sumtwaste) AS sumtwaste, SUM(sumtstad) AS sumtstad, 
SUM(sumttrav) AS sumttrav, SUM(totghg) AS totghg, 
-- ghgpp 
CAST((sum(totghg)/SUM(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgppptptrip,
schoolgeom, ST_Collect(travelgeom) AS alltripsgeom, ST_Collect(sitegeom) AS dstnatngeom  -- merge travelgeom into multipart new geom line file
FROM environ.mm19_pteam_ptrip
GROUP BY team, schoolgeom
;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
ALTER TABLE environ.mm19perteam 
ADD COLUMN pkey_id SERIAL PRIMARY KEY;
-- Create geom idxs
CREATE INDEX schoolgeom_pert_idx ON environ.mm19perteam USING gist (schoolgeom);
CREATE INDEX atripsgm_pert_idx ON environ.mm19perteam USING gist (alltripsgeom);

-- Try to consolidate per host destination
CREATE TABLE environ.mm19_bylocat AS SELECT
sitecity, sitestate, 
CAST(((SUM(gamesplayed)/2) - (CASE WHEN (SUM(gamesplayed)/2) >5 THEN 0 ELSE 1 END) )
	AS NUMERIC(1,0)) AS gamesplayed,  -- How many games were played at this location
SUM(attnptptrip) AS totfanattn,	SUM(sumrawattn) AS sum_raw_indoor_attn,	SUM(attnincluptptrip) AS totincluattn, SUM(sumincluattn) AS sum_inclu_indoor_attn, 	
CAST(AVG(miles) AS REAL) AS avmipteam, CAST(AVG(km) AS REAL) AS avgkmpteam, hotelghgpp,
SUM(sumtfood) AS sumtfood, 	SUM(sumthotel) AS sumthotel, 	SUM(sumtwaste) AS sumtwaste, 
SUM(sumtstad) AS sumtstad, 	SUM(sumttrav) AS sumttrav, 	SUM(totghg) AS totghg, 
CAST((sum(totghg)/SUM(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgpppsite,
sitegeom, ST_Collect(schoolgeom) AS schoolsgeom, ST_Collect(travelgeom) AS alltripsgeom
,ST_X(sitegeom) as sitelon,ST_Y(Sitegeom) as sitelat
FROM environ.mm19_pteam_ptrip
GROUP BY sitecity, sitestate, hotelghgpp, sitegeom
ORDER BY sitecity
;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
ALTER TABLE environ.mm19_bylocat
ADD COLUMN pkey_id SERIAL PRIMARY KEY;
-- Create geom idxs
CREATE INDEX sitegeom_ploct_idx ON environ.mm19_bylocat USING gist (sitegeom);
CREATE INDEX atripsgm_ploct_idx ON environ.mm19_bylocat USING gist (alltripsgeom);

-- Get one final table that tabulates stats for the entire tournament. 
CREATE TABLE environ.mm19_tourneystats AS SELECT 
CAST(1 AS NUMERIC(1,0)) AS unqid,
COUNT(DISTINCT(team)) AS nteams, COUNT(DISTINCT(sitecity)) AS nsites, CAST(67 AS NUMERIC(2,0)) AS ngames,
SUM(attnptptrip) AS totfanattn,	SUM(sumrawattn) AS sum_raw_indoor_attn,	SUM(attnincluptptrip) AS totincluattn, SUM(sumincluattn) AS sum_inclu_indoor_attn, 	
CAST(AVG(miles) AS REAL) AS avmipteam, CAST(AVG(km) AS REAL) AS avgkmpteam, 
CAST(SUM(miles) AS REAL) AS totmiles, CAST(sum(km) AS REAL) AS sumkm, 
SUM(sumtfood) AS sumtfood, 	SUM(sumthotel) AS sumthotel, 	SUM(sumtwaste) AS sumtwaste, 
SUM(sumtstad) AS sumtstad, 	SUM(sumttrav) AS sumttrav, 	SUM(totghg) AS totghg, 
CAST((sum(totghg)/SUM(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgpp
FROM environ.mm19_pteam_ptrip;
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
