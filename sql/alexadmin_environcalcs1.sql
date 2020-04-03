CREATE SCHEMA environ;

GRANT USAGE ON SCHEMA environ TO alexuser;

-- Now, from QGIS, I imported the teams and their locations from a .kml file into skratch.
-- Copy relevant fields into the marchmad schema.
GRANT SELECT ON ALL TABLES IN SCHEMA environ TO alexuser;

-- Enter hotel metro area hotel emission values into new environ schema
CREATE TABLE environ.hotelz AS SELECT sitecity, sitestate FROM marchmad.locats_ncaat19 GROUP BY sitecity, sitestate; 
GRANT SELECT ON ALL TABLES IN SCHEMA skratch, marchmad, environ TO alexuser;
-- Values from Ricaurte, E., & Jagarajan, R. (2019). Benchmarking Index 2019: Carbon, energy, and water. Cornell Hospitality Report, 19(4), 1-23.
ALTER TABLE environ.hotelz ADD COLUMN chsb_ghgs numeric(3,1);
-- nifty little query from https://stackoverflow.com/questions/18797608/update-multiple-rows-in-same-query-using-postgresql
UPDATE environ.hotelz as tbl
	SET chsb_ghgs = ctb.chsb_ghgs
	FROM (VALUES 
		('dayton', 19.1),
		('des moines' , 25.9),
		('hartford' , 12.0),
		('jacksonville',18.9),
		('salt lake city',19.5),
		('columbia', 14.2),
		('columbus', 23.9),
		('tulsa', 30.2),
		('san jose', 8.8),
		('anaheim', 10.6),
		('kansas city', 27.3),
		('louisville', 23.9),
		('washington', 19.8),
		('minneapolis', 24.7)
	) AS ctb(sitecity, chsb_ghgs)
	WHERE lower(ctb.sitecity) = lower(tbl.sitecity)
;
-- Make a column for a per person value according to AHLA's (2015) 2 people per room in the USA.
ALTER TABLE environ.hotelz ADD COLUMN chsbpp real;
UPDATE environ.hotelz SET chsbpp = chsb_ghgs / 2;


