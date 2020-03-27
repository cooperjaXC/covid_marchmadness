# Creating the covid database
# pg_hba.comf file located at /c/Program Files/PostgreSQL/11/data
	# Looks like everything is all set up. 
	# Just remember that from the CMD LINE, you have to put what -U user you are. alexadmin, alexuser, or postgres

# Folowing ORNL file Configuring_gistfrankfurt_for_OSM_database
# Create database covid
	# Trying to create with owner alexadmin. Seems to be what DB utkthesis had. 
psql -d postgres -U postgres -c "CREATE DATABASE covid WITH OWNER alexadmin ENCODING = 'UTF-8' TABLESPACE = pg_default CONNECTION LIMIT = -1;"
	# Success! 

# Set up initial workspace before switching to psql scripts
psql -d covid -U alexadmin -c "CREATE SCHEMA marchmad;"
psql -d covid -U alexadmin -c "GRANT USAGE on SCHEMA marchmad TO alexuser;"
psql -d covid -U alexadmin -c "GRANT SELECT ON ALL TABLES IN SCHEMA marchmad TO alexuser;"

# Enable postgis extension
	# Had to copy "libeay32.dll" and "ssleay32.dll" from Postgresql>11>bin>postgisgui into the bin folder just above it. No clue why.
	# https://gis.stackexchange.com/questions/331653/error-could-not-load-library-c-program-files-postgresql-11-lib-rtpostgis-2-5
psql -d covid -U postgres -c "CREATE EXTENSION postgis;"
psql -d covid -U postgres -c "CREATE EXTENSION postgis_topology CASCADE;"
psql -d covid -U postgres -c "CREATE EXTENSION hstore;"

# Now you're all ready to load spatial COVID-19 and March Madness data into your new postgres database!