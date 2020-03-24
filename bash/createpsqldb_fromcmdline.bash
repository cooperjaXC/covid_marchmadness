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
# Now you're all ready to load spatial COVID-19 and March Madness data into your new postgres database!