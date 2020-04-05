import psycopg2

teams = ('t1', 't2', 't3', 't4')

teamsfood = []
teamswaste = []
teamstravel = []
teamshotel = []
teamsstad = []
wincoldict = {}
allvarsdict = {}

# indices variables
foodvar = "food"
wastevar = "waste"
travvar= "trav"
hotelvar = "hotel"
stadvar = "stad"

for teem in teams:
    teamsfood.append(teem + foodvar)
    teamswaste.append(teem + wastevar)
    teamstravel.append(teem + travvar)
    teamshotel.append(teem + hotelvar)
    teamsstad.append(teem + stadvar)
    wincoldict[teem] = (teem + 'win')

    allvarsdict[teem] = (
        (teem + foodvar),  # 0
        (teem + wastevar),  # 1
        (teem + travvar),  # 2
        (teem + hotelvar),  # 3
        (teem + stadvar),  # 4
        (teem + 'win'),  # 5
        (teem + 'km'),  # 6
        (teem + 'travelfrom')  # 7
    )

# vas in sql script to set :
# format(wincol=___, ghgrate-___, targetcol=___, normaldaysvar=____, winnerdaysvar=____)

daysdict = {
    # co2var: [firstfour_r1_loss, s16f4_loss_team, s16f4_loss_fans, r1s16f4_win, r2, e8nc_play, e8nc_NOTplay] #(len=7)
    # varposit: 0                    1                   2               3       4      5           6
    # {normaldaysvar}, {winnerdaysvar}
    foodvar: [3, 2],
    wastevar: [3, 2],
    stadvar: [1, 1],
    hotelvar: [2, 2]
}

travelghg_caseclause = """ CASE WHEN {teamkilometers} < 500
                        THEN (attnperteam * 0.136) + .058 * 28
                        WHEN {teamkilometers} >= 500
                        THEN 
END
"""  # Incomplete. May be too complicated to lump into the rest. Do Travel separately. Can be done in PSQL.
ghgratedict = {
    foodvar: 7.4,  # Berners-Lee et al. 2012
    wastevar: 1.1,  # Cooper 2020
    stadvar: 14.74,  # Hedayati et al. 2014
    hotelvar: "hotelghgpp",  # Recaurte & ____ 2019
    travvar: travelghg_caseclause  # Filimonau et al. 2014, Pereira et al. 2019, Dolf & Teehan 2015
}


bigsqlclausetrial = """
{wincol} , {ghgrate} , {targetcol} , {normaldaysvar} , {winnerdaysvar}
"""
bigsqlclause = """ UPDATE environ.mm19co2
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
"""
lilsqlclause = """ALTER TABLE environ.mm19co2 ADD COLUMN IF NOT EXISTS {targetcol} numeric;"""
dropsqlclause = """ALTER TABLE environ.mm19co2 DROP COLUMN IF EXISTS {targetcol} CASCADE ;"""


def carbonfootprinting():
    """ Carbon footprints each column in PSQL you need. """
    # Establish your PSQL Connection
    connstr = "host=localhost dbname=covid user=alexadmin password=alexadmin"
    connection = psycopg2.connect(connstr)
    cursr = connection.cursor()

    # Loop through for each team in session
    for team in allvarsdict:  # t1 - t4
        print "--------------", team, "-----------------"
        loopfoodvar = allvarsdict[team][0]  # EX: t1food
        loopwastevar = allvarsdict[team][1]
        loophotelvar = allvarsdict[team][3]
        loopstadvar = allvarsdict[team][4]
        loopwincol = allvarsdict[team][5]
        innerloopvars = {foodvar: loopfoodvar, wastevar: loopwastevar, hotelvar: loophotelvar, stadvar: loopstadvar}
        for hardvar in innerloopvars:#allvarsdict[team]:
            loopvar_targcol = innerloopvars[hardvar]
            # example: for food for t 1: hardvar = foodvar (ie "food") and loopvar = "t1food"
                # Allows for dynamic lookup in other dictonaries
            dropsqlclause_filled = dropsqlclause.format(targetcol = loopvar_targcol)
            lilsqlclause_filled = lilsqlclause.format(targetcol=loopvar_targcol)
            bigsqlclause_filled = bigsqlclause.format(wincol=loopwincol, ghgrate=ghgratedict[hardvar],
                                                   targetcol=loopvar_targcol, normaldaysvar=daysdict[hardvar][0],
                                                   winnerdaysvar=daysdict[hardvar][1])
            # # Print statements if you need to double check what on earth is going on
            print lilsqlclause_filled
            # print "--------"
            # print bigsqlclause_filled

            # Now (drumroll........) EXECUTE THE PSQL!
            cursr.execute(dropsqlclause_filled)
            cursr.execute(lilsqlclause_filled)
            cursr.execute(bigsqlclause_filled)
            connection.commit()
            # quit()  # Use for testing so you don't overload things. Use to just test 1 col


        # sqlclause_loopfood = bigsqlclause.format(wincol=loopwincol, ghgrate=ghgratedict[foodvar], targetcol=loopfoodvar,
        #                                          normaldaysvar=daysdict[foodvar][0], winnerdaysvar=daysdict[foodvar][0])
        # sqlclause_loopwaste =
carbonfootprinting()
