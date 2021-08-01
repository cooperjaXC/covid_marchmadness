# Carbon Footprinting the 2019 NCAA Men's Basketball Tournament

These scripts are the ones run by J. A. Cooper to roughly estimate 
the quantity of greenhouse gas (GHG) emissions associated with the 
2019 USA sports phenomenon, March Madness.

This project is associated with peer-reviewed publications in 
*[Tourism Geographies](https://doi.org/10.1080/14616688.2020.1759135)*
and the *[Journal of Cleaner Production]()*,
and it draws heavily from a previous publication in the 
*[Journal of Sport & Tourism](https://doi.org/10.1080/14775085.2020.1726802)* 
with a similar methodology (see that 
[GitHub Repo](https://github.com/cooperjaXC/utkthesis_coding_cooper2020)).

    References
    ----------
    Cooper, J. A. (2020). Making orange green? A critical carbon footprinting of Tennessee football gameday
        tourism. Journal of Sport & Tourism, 24(1): 31-51.
    Cooper, J. A. & Derek H. Alderman (2020). Cancelling March Madness exposes opportunity for more 
        sustainable sports tourism economy. Tourism Geographies, 22(3): 525-535.
    Cooper, J. A. & Brian M. McCullough (2021). Bracketing sustainability: Carbon footprinting March Madness 
        to rethink sustainable tourism approaches and measurements. Journal of Cleaner Production.

Included here are basic instructions for understanding the process 
and reproducing it if necessary.
Note that the following steps were run in a Windows 10 environment using the git bash shell;
please make necessary adjustments if using different configurations or versions of PostgreSQL.

## Prerequisites

### Install

* [PostgreSQL](https://www.postgresql.org/download/)
    * [PostGIS extension](https://postgis.net/windows_downloads/)
    * [pgAdmin 4](https://www.pgadmin.org/)
* Python 2.7
    * psycopg2 package
        * To install this package, use this command in the command line or bash:


	python -m pip install psycopg2

### Personal Machine Setup
#### Connections to PostgreSQL Databases 
* This uses individualized roles created for the author's personal workflow. 
A user looking to reproduce this work may need to adopt these role names or change role names
referenced downstream in .sql (and other) files. 
* Setup a [pgpass.conf file](https://www.postgresql.org/docs/current/libpq-pgpass.html) 
in your App Data \ postgresql directory so you can access these databases.
    
    ```
    ~\AppData\postgresql\pgpass.conf
    ```

   * Make sure these items are included 

pgpass.conf |
------- |
localhost:5432:covid:alexadmin:alexadmin |
localhost:5432:covid:alexuser:alexuser |

   * Change permissions for that file.

    $ chmod 0600 pgpass.conf

   * Set the `pgpass.conf` file as the **PGPASSFILE** environment variable.

    $ export PGPASSFILE='~\AppData\postgresql\pgpass.conf'

* Also set up the pg_hba.conf file in your Program Files \ PostgreSQL directory 

    ```
    ~\ProgramFiles\postgresql\11\data\pg_hba.conf
    ```

* Make sure these items are included 


 \# TYPE | DATABASE     |   USER      |      ADDRESS          |       METHOD |
-----|--------------|---------------|-----------------------|------------- |
\# IPv4 local connections: |
host  |  all     |        all        |     127.0.0.1/32     |       md5
\# IPv6 local connections: |
host  |  all       |      alexadmin   |	::1/128         |        trust
host  |  all       |      postgres	  | 	::1/128      |           md5
host  |  all       |      alexuser	 | 	::1/128          |       trust
\# Allow replication connections from localhost, by a user with the replication privilege. |
host |   replication  |   all      |       127.0.0.1/32  |          md5
host  |  replication |     all      |       ::1/128     |            md5

* Then, make sure your postgresql system is started 
    * Run these commands as an administrator

    ```
    $ /c/Program\ Files/PostgreSQL/11/bin/pg_ctl.exe start -D /c/Program\ Files/PostgreSQL/11/data
    ```
   * Remember, *anytime* you change configurations, you have to reload the re-load that configuration file
    
    ```
    $ /c/Program\ Files/PostgreSQL/11/bin/pg_ctl.exe reload -D /c/Program\ Files/PostgreSQL/11/data
    ```

## Database Creation
* Run each line of the `~/bash/createpsqldb_fromcmdline.bash` to create the covid database and enable all PostGIS features.
* Connect to the database in pgAdmin 4

## Loading Initial Data 

The data for this project is in .csv format in the `~\data_init_forgit` directory. 

The .sql file associated with this process is `~\sql\alexadmin_initdb_importdata.sql`
* Team data was originally uploaded via KML &rarr; QGIS &rarr; PostgreSQL covid database midway through 
processes laid out in `~\sql\alexadmin_initdb_importdata.sql`.
    * However, some work has already been completed for you. Find a .csv copy of this data in 
    the `~\data_init_forgit` directory. Then, upload it manually to the marchmad SCHEMA of covid DATABASE
    [using pgAdmin 4](https://www.pgadmin.org/docs/pgadmin4/development/import_export_data.html).
* Session location data is uploaded via running `~\sql\alexadmin_initdb_importdata.sql`. A shell table
marchmad.locats_ncaat19 is created with the code in the file. 
    * After this, manually import the `2019ncaatourneylocatdata.csv` from the `~\data__init__forgit`
     directory [using pgAdmin 4](https://www.pgadmin.org/docs/pgadmin4/development/import_export_data.html).

### Merging team and session data
After successfully loading the TABLES `marchmad.teams_ncaat19` and `marchmad.locats_ncaat19`,
run `~/sql/alexadmin_mergeteamgamelocats.sql`.

This will result in a `marchmad.locats_ncaat19` table that contains attendance and locational data
for each session site and all 4 teams from that session.


## Carbon Footprinting the 2019 Data
1. Run `~/sql/alexadmin_environcalcs1.sql` to set up the *environ* SCHEMA 
and import hotel emissions data  from *Ricaurte & Jagarajan (2019)*.

2. Next is the only python step of the project. Run `~/python/alexadmin_environcalcs2.py` for quick
psycopg2-bsaed PSQL commands to actually footprint the tournament at the per-session level.

3. Run `~/sql/alexadmin_environcalcs3.sql` to tabulate the data in different ways by creating tables in 
the *environ* SCHEMA at the following levels:
    * per-team-per-round
    * per-trip
    * per-team
    * per-host site
    * the whole tournament. 

## Exploring the Data
##### Use the `user_.sql` files in `~/sql/` directory 
These user files will give you a head start in exploring your new data in a safer user rather than admin
querying arena that will ensure you don't destroy your hard-created database. 

Also, you can import the data with its spatial attributes in the *geometry* columns into your GIS viewer like ArcGIS or QGIS.