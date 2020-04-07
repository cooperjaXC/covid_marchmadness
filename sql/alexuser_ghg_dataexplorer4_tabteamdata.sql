-- Works to tabulate data at the team level

-- 1st, per team per round
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

-- Then collapse by trip 
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


-- Then collapse by team. Total numbers. 

