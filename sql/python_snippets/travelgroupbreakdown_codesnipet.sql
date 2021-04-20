CASE
-- GROUP 1
-- First 4, Round 1 Loss
	-- Attendance Inclusive: ie both fans and team
	WHEN (
		(lower(round) LIKE 'first four') 
		OR (lower(round) LIKE 'first round' AND t1win LIKE '%loss%')
	) THEN  -- 3 Days x nInclu * FoodGHG/person
		3 * (attnincluperteam * 7.4)
-- Sweet 16 Team Loss, Final 4 Team Loss
	WHEN (
		(lower(round) LIKE 'sweet%sixteen' AND t1win LIKE '%loss%')	
		OR (lower(round) LIKE 'final%four' AND t1win LIKE '%loss%')	
	) THEN 
		-- TEAM: 3 Days x nTeam * FoodGHG/person
		(3 * (28 * 7.4))
		+
		-- FANS: 3 Days x nFans * FoodGHG/person
		(3 * (attnperteam * 7.4))
-- GROUP 2
	-- Round 1 Win
	-- Sweet 16 Win
	-- Final 4 Win
	-- Sweet 16 Fan Loss (already above)
	-- Final 4 Fan Loss (already Above)
	WHEN (
		(lower(round) LIKE 'first round' AND t1win LIKE '%win%')
		OR (lower(round) LIKE 'sweet%sixteen' AND t1win LIKE '%win%')
			OR (lower(round) LIKE 'final%four' AND t1win LIKE '%win%')	
	) THEN  -- 3 Days x nInclu * FoodGHG/person
		3 * (attnincluperteam * 7.4)
-- GROUP 3
-- Round 2 Play, E8 Play, NatCh Play, E8 Fan "-", NatCh Fan "-"
	WHEN (
		(lower(round) LIKE 'second%round')
	) THEN -- 2 more days x nInclu * FoodGHG/person)
		2 * (attnincluperteam * 7.4)
	WHEN (lower(round) LIKE 'elite%eight' AND t1win NOT LIKE '-')
		OR (lower(round) LIKE 'national%championship' AND t1win NOT LIKE '-')
	) THEN  -- 2 more days x ((nFans + the 28 players) * FoodGHG/person)
		2 * ((attnperteam + 28) * 7.4)  
-- E8 Fan "-", NatCh Fan "-"
	WHEN (
		(lower(round) LIKE 'elite%eight' AND t1win LIKE '-')
		OR (lower(round) LIKE 'national%championship' AND t1win LIKE '-')
	) THEN  -- 2 more days x nFans * FoodGHG/person)
		2 * (attnperteam * 7.4)
-- Check for errors
	ELSE NULL
END AS t1food,