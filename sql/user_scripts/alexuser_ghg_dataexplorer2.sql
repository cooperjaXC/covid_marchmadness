SELECT 
-- 	 name,
--        CASE WHEN lower(name) LIKE '%f%' THEN 'one'
--             WHEN lower(name) LIKE '%ff%' THEN 'two'
--             ELSE 'other'
--        END
-- CASE
-- -- GROUP 1
-- -- First 4, Round 1 Loss
-- 	-- Attendance Inclusive: ie both fans and team
-- 	WHEN (
-- 		(lower(round) LIKE 'first four') 
-- 		OR (lower(round) LIKE 'first round' AND t1win LIKE '%loss%')
-- 	) THEN  -- 3 Days x nInclu * FoodGHG/person
-- 		3 * (attnincluperteam * 7.4)
-- -- Sweet 16 Team Loss, Final 4 Team Loss
-- 	WHEN (
-- 		(lower(round) LIKE 'sweet%sixteen' AND t1win LIKE '%loss%')	
-- 		OR (lower(round) LIKE 'final%four' AND t1win LIKE '%loss%')	
-- 	) THEN 
-- 		-- TEAM: 3 Days x nTeam * FoodGHG/person
-- 		(3 * (28 * 7.4))
-- 		+
-- 		-- FANS: 3 Days x nFans * FoodGHG/person
-- 		(3 * (attnperteam * 7.4))
-- -- GROUP 2
-- 	-- Round 1 Win
-- 	-- Sweet 16 Win
-- 	-- Final 4 Win
-- 	-- Sweet 16 Fan Loss (already above)
-- 	-- Final 4 Fan Loss (already Above)
-- 	WHEN (
-- 		(lower(round) LIKE 'first round' AND t1win LIKE '%win%')
-- 		OR (lower(round) LIKE 'sweet%sixteen' AND t1win LIKE '%win%')
-- 			OR (lower(round) LIKE 'final%four' AND t1win LIKE '%win%')	
-- 	) THEN  -- 3 Days x nInclu * FoodGHG/person
-- 		3 * (attnincluperteam * 7.4)
-- -- GROUP 3
-- -- Round 2 Play, E8 Play, NatCh Play, E8 Fan "-", NatCh Fan "-"
-- 	WHEN (
-- 		(lower(round) LIKE 'second%round')
-- 		OR (lower(round) LIKE 'elite%eight' AND t1win NOT LIKE '-')
-- 		OR (lower(round) LIKE 'national%championship' AND t1win NOT LIKE '-')
-- 	) THEN  -- 2 more days x nInclu * FoodGHG/person)
-- 		2 * (attnincluperteam * 7.4)
-- -- E8 Fan "-", NatCh Fan "-"
-- 	WHEN (
-- 		(lower(round) LIKE 'elite%eight' AND t1win LIKE '-')
-- 		OR (lower(round) LIKE 'national%championship' AND t1win LIKE '-')
-- 	) THEN  -- 2 more days x nFans * FoodGHG/person)
-- 		2 * (attnperteam * 7.4)
-- -- Check for errors
-- 	ELSE NULL
-- END AS t1food,
-- CASE
-- -- GROUP 1
-- -- First 4, Round 1 Loss
-- 	-- Attendance Inclusive: ie both fans and team
-- 	WHEN (
-- 		(lower(round) LIKE 'first four') 
-- 		OR (lower(round) LIKE 'first round')

-- 		OR (lower(round) LIKE 'sweet%sixteen')	
-- 		OR (lower(round) LIKE 'final%four')	


-- 	) THEN  -- 3 Days x nInclu * FoodGHG/person
-- 		3 * (attnincluperteam * 7.4)
-- -- GROUP 3
-- -- Round 2 Play, E8 Play, NatCh Play, E8 Fan "-", NatCh Fan "-"
-- 	WHEN (
-- 		(lower(round) LIKE 'second%round')
-- 		OR (lower(round) LIKE 'elite%eight' AND t1win NOT LIKE '-')
-- 		OR (lower(round) LIKE 'national%championship' AND t1win NOT LIKE '-')
-- 	) THEN  -- 2 more days x nInclu * FoodGHG/person)
-- 		2 * (attnincluperteam * 7.4)
-- -- E8 Fan "-", NatCh Fan "-"
-- 	WHEN (
-- 		(lower(round) LIKE 'elite%eight' AND t1win LIKE '-')
-- 		OR (lower(round) LIKE 'national%championship' AND t1win LIKE '-')
-- 	) THEN  -- 2 more days x nFans * FoodGHG/person)
-- 		2 * (attnperteam * 7.4)
-- -- Check for errors
-- 	ELSE NULL
-- END AS t1food2,

t4trav, t1food, t3waste,
t4tot, seshtravtot, 
seshtotghg,
*
-- hotl.chsb_ghgs AS hotelghgs,
-- hotl.chsbpp as hotelghgpp,
-- locats.*
-- -- Create all the columns you'll need for CF calculations. 
-- -- Connect hotel emissions values to the locations table via a join
-- FROM 
-- marchmad.locats_ncaat19 locats
-- LEFT JOIN environ.hotelz hotl
-- 	ON hotl.sitecity = locats.sitecity

FROM 
environ.mm19co2
-- environ.hotelz
-- marchmad.locats_ncaat19
-- skratch.teams_ncaat19_qgisimport

-- GROUP BY 
-- (sitegeom), 
-- (sitecity), (sitestate)

-- WHERE 
-- t1km < 257.5 OR t2km < 257.5 OR t3km < 257.5 OR t4km < 257.5 
-- t1km < 300 OR t2km < 300 OR t3km < 300 OR t4km < 300
-- t1km < 643 OR t2km < 643 OR t3km < 643 OR t4km < 643
-- t1km < 500 OR t2km < 500 OR t3km < 500 OR t4km < 500

ORDER BY 
sessionid
-- sitestate
