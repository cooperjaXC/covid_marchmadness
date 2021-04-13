--bigsqlclause

UPDATE environ.mm19co2
SET {targetcol} =  -- t1travl = 
CASE
-- Do people fly or drive?
	WHEN ({teamkilometers} >= 500)  
	-- You Fly! 0.15kgco2eq/person/km (Filimonau et al. 2014; Pereira et al. 2019)
	THEN CASE
	-- GROUP 1: First 4, Round 1 Loss
		WHEN(
		(lower(round) LIKE 'first four') 
		OR (lower(round) LIKE 'first round' AND {wincol} LIKE '%loss%')
		) THEN  -- 2 flights * (inclusive_attendance * (ghgrate) (ghgs/p/km x km)
			2 * (attnincluperteam * (0.15 * {teamkilometers}))
			-- How many ways is this trip? Will either the team or fans arrive & leave in the same round?

	-- Sweet 16 Team Loss, Final 4 Team Loss
		WHEN (
			(lower(round) LIKE 'sweet%sixteen' AND {wincol} LIKE '%loss%')	
			OR (lower(round) LIKE 'final%four' AND {wincol} LIKE '%loss%')	
		) THEN 
			-- TEAM: 2 Flights x nTeam * (ghgrate)
			(2 * (28 * (0.15 * {teamkilometers})))
			+
			-- FANS: 1 Flight x nFans * ghgrate
			(1 * (attnperteam * (0.15 * {teamkilometers})))
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
			OR (lower(round) LIKE 'second%round')
			OR (lower(round) LIKE 'elite%eight' AND {wincol} NOT LIKE '-')
			OR (lower(round) LIKE 'national%championship' AND {wincol} NOT LIKE '-')
		) THEN -- 1 flight x (nFans + nTeam) * (ghgrate))
			(1 * ((attnperteam + 28) * (0.15 * {teamkilometers})))
	-- E8 Fan "-", NatCh Fan "-"
		WHEN (
			(lower(round) LIKE 'elite%eight' AND {wincol} LIKE '-')
			OR (lower(round) LIKE 'national%championship' AND {wincol} LIKE '-')
		) THEN  -- 1 Flight x nFans * ghgrate
			(1 * (attnperteam * (0.15 * {teamkilometers})))
	-- Check for errors
		ELSE NULL
	END
	-------------------------------------------------
	WHEN ({teamkilometers} < 500)  
	-- Ground transport
		-- Teams via coaches: 0.058 kgco2eq/person/km (Dolf & Teehan 2015)
		-- Fans via automobile: 0.136 kgco2eq/person/km (Dolf & Teehan 2015)
	THEN CASE
	-- GROUP 1: First 4, Round 1 Loss
		WHEN(
		(lower(round) LIKE 'first four') 
		OR (lower(round) LIKE 'first round' AND {wincol} LIKE '%loss%')
		) THEN  -- 2 rides * 
			--((nFans * (carrate)(ghgs/p/km x km)) +
			-- (nTeam 8 (coachrate)(ghgs/p/km * km)))
			(2 * (
				(attnperteam * (0.136 * {teamkilometers}))
				+
				(28 * (.058 * {teamkilometers}))
			))
			-- How many ways is this trip? Will either the team or fans arrive & leave in the same round?

	-- Sweet 16 Team Loss, Final 4 Team Loss
		WHEN (
			(lower(round) LIKE 'sweet%sixteen' AND {wincol} LIKE '%loss%')	
			OR (lower(round) LIKE 'final%four' AND {wincol} LIKE '%loss%')	
		) THEN 
			-- TEAM: 2 Bus rides x nTeam * (ghgrate)
			(2 * (28 * (0.058 * {teamkilometers})))
			+
			-- FANS: 1 carride x nFans * ghgrate
			(1 * (attnperteam * (0.136 * {teamkilometers})))
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
			OR (lower(round) LIKE 'second%round')
			OR (lower(round) LIKE 'elite%eight' AND {wincol} NOT LIKE '-')
			OR (lower(round) LIKE 'national%championship' AND {wincol} NOT LIKE '-')
		) THEN -- 1 ride x (nFans /or/ nTeam) * (ghgrate))
			(1 * (attnperteam) * (0.136 * {teamkilometers}))
			+
			(1 * (28 * (0.058 * {teamkilometers})))
	-- E8 Fan "-", NatCh Fan "-"
		WHEN (
			(lower(round) LIKE 'elite%eight' AND {wincol} LIKE '-')
			OR (lower(round) LIKE 'national%championship' AND {wincol} LIKE '-')
		) THEN  -- 1 Flight x nFans * carrate
			(1 * (attnperteam * (0.136 * {teamkilometers})))
	-- Check for errors
		ELSE NULL
	END
END;