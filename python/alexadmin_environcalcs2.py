import psycopg2, os

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

ghgratedict = {
    foodvar: 7.4,  # Berners-Lee et al. 2012
    wastevar: 1.1,  # Cooper 2020
    stadvar: 14.74,  # Hedayati et al. 2014
    hotelvar: "hotelghgpp"#,  # Recaurte & ____ 2019
    #travvar: travelghg_caseclause  # Filimonau et al. 2014, Pereira et al. 2019, Dolf & Teehan 2015
}

# Pull in snipet files directly from their directory so changes can be made there.
# To do this, set working directory. Needs to be dynamic because this fil may be run with different os.getcwd()s.
curdir = os.getcwd()
parentdir = os.path.abspath(os.path.join(curdir, os.pardir))
if "coding" not in parentdir:
    sqldir = os.path.join(parentdir, 'coding', "sql")  # "coding",  # Play with this if this line errors. Hard to tell getcwd()
else:
    sqldir = os.path.join(parentdir, 'sql')
print os.path.exists(sqldir), sqldir  # double check this to be true

# Set basic multi-function SQL clauses.
lilsqlclause = """ALTER TABLE environ.mm19co2 ADD COLUMN IF NOT EXISTS {targetcol} NUMERIC(15,3);"""
    # Limit footprinting col.s to 15 digits. Most it is for now is 10 (w/ 3 decimals) + 5 just in case for la futur.
dropsqlclause = """ALTER TABLE environ.mm19co2 DROP COLUMN IF EXISTS {targetcol} CASCADE ;"""


def carbonfootprinting():
    """ Carbon footprints each column in PSQL you need. """
    # Establish your PSQL Connection
    connstr = "host=localhost dbname=covid user=alexadmin password=alexadmin"
    connection = psycopg2.connect(connstr)
    cursr = connection.cursor()

    # Prepare the .sql file properties for opening
    bigsnipetfilnam = os.path.join(sqldir, r"mostghgindexes_codesnipet_forpythonedit.sql")
    snipetread = open(bigsnipetfilnam, "r")
    bigsqlclause = str(snipetread.read())

    # Loop through for each team in session
    for team in allvarsdict:  # t1 - t4
        print "--------------", team, "-----------------"
        loopfoodvar = allvarsdict[team][0]  # EX: t1food
        loopwastevar = allvarsdict[team][1]
        loophotelvar = allvarsdict[team][3]
        loopstadvar = allvarsdict[team][4]
        loopwincol = allvarsdict[team][5]
        innerloopvars = {foodvar: loopfoodvar, wastevar: loopwastevar, hotelvar: loophotelvar, stadvar: loopstadvar}
        for hardvar in innerloopvars:
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


carbonfootprinting()


def travelcfootprinting():
    """ Carbon footprints each column in PSQL you need. """
    # Establish your PSQL Connection
    connstr = "host=localhost dbname=covid user=alexadmin password=alexadmin"
    connection = psycopg2.connect(connstr)
    cursr = connection.cursor()

    # Prepare the .sql file for opening.
    travelsnipetfilnam = os.path.join(sqldir, r"travelfootprinting_codesnipet_forpythonedit.sql")
    snipetread = open(travelsnipetfilnam, "r")
    travsqlclause = str(snipetread.read())

    # Loop through for each team in session
    for team in allvarsdict:  # t1 - t4
        print "--------------", team, "-----------------"
        looptravvar = allvarsdict[team][2]  # EX: t1trav
        hardvar = travvar
        loopvar_targcol = looptravvar
        loopwincol = allvarsdict[team][5]
        loopteamkmcol = allvarsdict[team][6]
        # example: for food for t 1: hardvar = foodvar (ie "food") and loopvar = "t1food"
            # Allows for dynamic lookup in other dictonaries
        dropsqlclause_filled = dropsqlclause.format(targetcol=loopvar_targcol)
        lilsqlclause_filled = lilsqlclause.format(targetcol=loopvar_targcol)
        travsqlclause_filled = travsqlclause.format(wincol=loopwincol, targetcol=loopvar_targcol,
                                                    teamkilometers=loopteamkmcol)
        # # Print statements if you need to double check what on earth is going on
        print lilsqlclause_filled
        print "--------"
        # print travsqlclause_filled
        # print "- - - - - - - "
        # print hardvar, loopvar_targcol
        # print loopwincol, loopteamkmcol

        # Now (drumroll........) EXECUTE THE PSQL!
        cursr.execute(dropsqlclause_filled)
        cursr.execute(lilsqlclause_filled)
        cursr.execute(travsqlclause_filled)
        connection.commit()

travelcfootprinting()
