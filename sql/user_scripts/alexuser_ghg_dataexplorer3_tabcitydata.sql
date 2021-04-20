-- Works to tabulate data at the host city level

SELECT 
(sitecity), (sitestate),
count(*) AS nseshs,
-- t4trav, t1food, t3waste,
-- t4tot, seshtravtot, 
-- seshtotghg,
sum(attninclusive) as totincluattn, CAST(sum(attninclusive)/count(*) AS NUMERIC(15,2)) as avgincluattnpersesh,
CAST((sum(attninclusive)/count(*))/4 AS NUMERIC(15,2)) as avgincluattnperteam,
sum(seshfoodtot) AS foodtot, sum(seshwastetot) AS wastetot, sum(seshtravtot) as travtot, sum(seshhoteltot) AS hoteltot, sum(seshstadtot) AS stadtot,
sum(seshtotghg) as tottotghgs,
CAST((sum(seshtotghg) / sum(attninclusive))AS NUMERIC(15,3)) AS avg_ghgpp
-- ,CAST((sum(seshtotghg)/count(*)) / (sum(attninclusive)/count(*))AS NUMERIC(15,3)) AS avg_ghgpp_persesh  -- same as w/o normalizing for count(*)

-- Try to think about the per team measure. Per city. You know if nseshs = 3 OR city = Dayton, 8 tot teams. else, teams there = 2
	-- Simply dividing each sesh total by 4 double counts some teams in early rounds
	-- Try with kilometers 

AS kmperteamtrue

-- Try to get an average distance each team was from the site per site
, CAST(sum(seshtotkm) / count(*) AS NUMERIC(15,3)) AS kmpersesh, CAST((sum(seshtotkm) / count(*) ) / 4 AS NUMERIC(15,3)) AS kmperteam
-- *
,sitegeom
FROM 
environ.mm19co2
-- environ.hotelz
-- marchmad.locats_ncaat19
-- skratch.teams_ncaat19_qgisimport

-- WHERE 
-- sitegeom = '0101000020E6100000074C9649430C55C0822F963325E14340'

GROUP BY 
(sitegeom), 
(sitecity), (sitestate)

ORDER BY 
-- sessionid
-- sitestate
-- sum(seshtotghg) DESC  -- totghg
-- sum(seshtotghg) / sum(attninclusive) DESC  -- avgghgpp
sum(attninclusive)/count(*) DESC  -- avgattnpersesh
;



-- Try it again after tablulating by team and trip
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