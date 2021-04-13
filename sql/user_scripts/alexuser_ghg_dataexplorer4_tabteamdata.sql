-- Works to tabulate data at the team level

-- 1st, prepare to group by team per round
SELECT 
t1 as team,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t1win as result,	travelto,	t1travelfrom as travelfrom,	t1mi AS miles,	t1km AS km,	hotelghgpp,	t1food AS teamfood,	t1hotel AS teamhotel,	t1waste AS teamwaste,	t1stad as teamstad,	t1trav AS teamtrav,	t1tot AS totghg,	CAST(t1tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t1geom AS schoolgeom,	t1tositegeom AS travelgeom																																
FROM environ.mm19co2 UNION ALL SELECT 
t2,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t2win,	travelto,	t2travelfrom,	t2mi,	t2km,	hotelghgpp,	t2food,	t2hotel,	t2waste,	t2stad,	t2trav,	t2tot,	CAST(t2tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t2geom,	t2tositegeom																																
FROM environ.mm19co2 UNION ALL SELECT
t3,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t3win,	travelto,	t3travelfrom,	t3mi,	t3km,	hotelghgpp,	t3food,	t3hotel,	t3waste,	t3stad,	t3trav,	t3tot,	CAST(t3tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t3geom,	t3tositegeom																																
FROM environ.mm19co2 UNION ALL SELECT
t4,	sessionid,	round,	sitecity,	sitestate,	attendance,	attnperteam,	attninclusive,	attnincluperteam,	t4win,	travelto,	t4travelfrom,	t4mi,	t4km,	hotelghgpp,	t4food,	t4hotel,	t4waste,	t4stad,	t4trav,	t4tot,	CAST(t4tot / attnincluperteam AS NUMERIC(15,3)) AS ghgpppteam,	sitegeom,	t4geom,	t4tositegeom																																
FROM environ.mm19co2


ORDER BY 
team,
sessionid
-- sitestate

;

-- Then prepare to group by trip 
SELECT 
-- *
team, sitecity,	sitestate, COUNT(*) AS gamesplayed,	CAST(AVG(attnperteam) AS NUMERIC(15,2)) as attnptpg,
CAST(AVG(attnincluperteam)AS NUMERIC(15,2)) AS attnincluptpg, miles, km,	hotelghgpp,	
sum(teamfood) AS sumtfood, sum(teamhotel) as sumthotel, sum(teamwaste) as sumtwaste, 
SUM(teamstad) AS sumtstad, SUM(teamtrav)AS sumttrav, SUM(totghg) AS totghg,
CAST((sum(totghg)/AVG(attnincluperteam)) AS NUMERIC(15,3)) AS ghgppptptrip,
sitegeom, schoolgeom, travelgeom																																
FROM environ.mm19pteam_pround

GROUP BY
team, sitecity, sitestate, miles, km, hotelghgpp, sitegeom, schoolgeom, travelgeom

ORDER BY 
team
-- , sessionid
;
-- Double check the sums vs the mm19co2 sums. -- Checks for sum accuracy
sum(sumtfood) AS sumtfood, sum(sumthotel) as sumthotel, sum(sumtwaste) as sumtwaste, 
SUM(sumtstad) AS sumtstad, SUM(sumttrav)AS sumttrav, SUM(totghg) AS totghg,
CAST((sum(totghg)/Sum(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgppptptrip,
CAST(AVG(attnincluptptrip) AS NUMERIC(15,3)) as avattn, sum(attnincluptptrip) as sumtripattn
,sum(sumincluattn) as addedincluattn
FROM environ.mm19_pteam_ptrip
-- All looks good ! 
	-- the sum of the average attendance per trip and the resulting ghgppptptrip is different than the per session figures but probs more accurate.
	-- Use per trip attn inclusive figures going forward. 
		-- Counts bodies not stad entrances. 
	-- Avg attn per team per trip = 4572
	-- Total (attn per team per trip) = 420,630  -- This represents the total bodies involved in all mm travel. 
		-- Close to the sum of 1st 4, 1st R, Sweet 16, & Final 4 total of 418,875*
	-- vs SUM(inclusive bodies through door) = 693,240 -- ie 700k entrances to the stadium for whole tourney
-- seshfoodtot	seshhoteltot	seshwastetot	seshstadtot	seshtravtot	seshtotghg
--  13,363,549.00 	 14,342,131.32 	 1,986,473.50 	 12,382,278.04 	 167,814,764.01 	 209,889,195.88 


-- Then group by team. Total numbers. 
SELECT
team AS teammmmmmmmmmmmmm, SUM(gamesplayed) AS ngmsplyd, COUNT(gamesplayed) AS ntrips, sum(attnptptrip) AS totfanattnpteam, SUM(sumrawattn) as sum_raw_indoor_attn, 
-- This is the big normalizing attendance field you'll want. 
SUM(attnincluptptrip) AS totincluattnpteam, 
SUM(sumincluattn) AS sum_inclu_indoor_attn,
CAST(AVG(miles) AS REAL) AS avmiptrip, CAST(AVG(km) AS REAL) AS avgkmptrip,
SUM(sumtfood) AS sumtfood, SUM(sumthotel) AS sumthotel, SUM(sumtwaste) AS sumtwaste, SUM(sumtstad) AS sumtstad, 
SUM(sumttrav) AS sumttrav, SUM(totghg) AS totghg, 
-- ghgpp 
CAST((sum(totghg)/SUM(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgppptptrip,
-- merge travelgeom into multipart new geom line file
schoolgeom
, ST_Collect(travelgeom) AS alltripsgeom
-- , ST_Multi(travelgeom)
FROM environ.mm19_pteam_ptrip
GROUP BY team, schoolgeom
ORDER BY (sum(totghg)/SUM(attnincluptptrip)) DESC;

-- Then group by location. Finally. 
SELECT
sitecity, sitestate, 
CAST(((SUM(gamesplayed)/2) - (CASE WHEN (SUM(gamesplayed)/2) >5 THEN 0 ELSE 1 END) )
	AS NUMERIC(1,0)) AS gamesplayed, 
SUM(attnptptrip) AS totfanattn,	SUM(sumrawattn) AS sum_raw_indoor_attn,	SUM(attnincluptptrip) AS totincluattn, SUM(sumincluattn) AS sum_inclu_indoor_attn, 	
CAST(AVG(miles) AS REAL) AS avmipteam, CAST(AVG(km) AS REAL) AS avgkmpteam, hotelghgpp,
SUM(sumtfood) AS sumtfood, 	SUM(sumthotel) AS sumthotel, 	SUM(sumtwaste) AS sumtwaste, 
SUM(sumtstad) AS sumtstad, 	SUM(sumttrav) AS sumttrav, 	SUM(totghg) AS totghg, 
CAST((sum(totghg)/SUM(attnincluptptrip)) AS NUMERIC(15,3)) AS ghgppptptrip,
sitegeom, ST_Collect(schoolgeom) AS schoolsgeom, ST_Collect(travelgeom) AS alltripsgeom
FROM environ.mm19_pteam_ptrip

GROUP BY sitecity, sitestate, hotelghgpp, sitegeom
-- 	(sitecity), (sitestate), sitegeom	

ORDER BY -- team
sitecity
;


-- Test to make sure sums match up. Again. 