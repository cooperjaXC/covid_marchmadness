--lilsqlclause
ALTER TABLE environ.mm19co2
ADD COLUMN IF NOT EXISTS {targetcol} numeric;


--bigsqlclause
UPDATE environ.mm19co2
SET {targetcol} =  -- t1food = 
CASE
-- GROUP 1
-- First 4, Round 1 Loss
	-- Attendance Inclusive: ie both fans and team
	WHEN (
		(lower(round) LIKE 'first four') 
		OR (lower(round) LIKE 'first round' AND {wincol} LIKE '%loss%')
	) THEN  -- 3 Days x nInclu * FoodGHG/person
		{normaldaysvar} * (attnincluperteam * {ghgrate})
-- Sweet 16 Team Loss, Final 4 Team Loss
	WHEN (
		(lower(round) LIKE 'sweet%sixteen' AND {wincol} LIKE '%loss%')	
		OR (lower(round) LIKE 'final%four' AND {wincol} LIKE '%loss%')	
	) THEN 
		-- TEAM: 3 Days x nTeam * FoodGHG/person
		({normaldaysvar} * (28 * {ghgrate}))
		+
		-- FANS: 3 Days x nFans * FoodGHG/person
		({normaldaysvar} * (attnperteam * {ghgrate}))
-- GROUP 2
	-- Round 1 Win
	-- Sweet 16 Win
	-- Final 4 Win
	-- Sweet 16 Fan Loss (already above)
	-- Final 4 Fan Loss (already Above)
	WHEN (
		(lower(round) LIKE 'first round' AND {wincol} LIKE '%win%')
		OR (lower(round) LIKE 'sweet%sixteen' AND {wincol} LIKE '%win%')
		OR (lower(round) LIKE 'final%four' AND {wincol} LIKE '%win%')	
	) THEN  -- 3 Days x nInclu * FoodGHG/person
		{normaldaysvar} * (attnincluperteam * {ghgrate})
-- GROUP 3
-- Round 2 Play, E8 Play, NatCh Play, E8 Fan "-", NatCh Fan "-"
	WHEN (
		(lower(round) LIKE 'second%round')
	) THEN -- 2 more days x nInclu * FoodGHG/person)
		{winnerdaysvar} * (attnincluperteam * {ghgrate})
	WHEN (
		(lower(round) LIKE 'elite%eight' AND {wincol} NOT LIKE '-')
		OR (lower(round) LIKE 'national%championship' AND {wincol} NOT LIKE '-')
	) THEN  -- 2 more days x ((nFans + the 28 players) * FoodGHG/person)
		2 * ((attnperteam + 28) * {ghgrate})  
-- E8 Fan "-", NatCh Fan "-"
	WHEN (
		(lower(round) LIKE 'elite%eight' AND {wincol} LIKE '-')
		OR (lower(round) LIKE 'national%championship' AND {wincol} LIKE '-')
	) THEN  -- 2 more days x nFans * FoodGHG/person)
		2 * (attnperteam * {ghgrate})
-- Check for errors
	ELSE NULL
END;