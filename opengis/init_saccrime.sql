-- initialize spatialite extensions to SQLite database
.read init_spatialite.sql UTF-8
  
-- Add SHAPE (geometry) column to data tables; make them feature classes
SELECT AddGeometryColumn('crime',    'SHAPE', 2226, 'POINT', 2);
SELECT AddGeometryColumn('stations', 'SHAPE', 4326, 'POINT', 2);

-- Update table SHAPE fields with new geometry values
UPDATE crime    SET SHAPE = GeomFromText('POINT(' || X_Coord || ' ' || Y_Coord || ')', 2226);
UPDATE stations SET SHAPE = GeomFromText('POINT(' || lng     || ' ' || lat     || ')', 4326);

-- Load shapefiles
.loadshp shapefiles/Sac_2010CensusBlkPop blocks    UTF-8 2226 SHAPE
.loadshp shapefiles/maj_hosp             hospitals UTF-8 2226 SHAPE

--These shapefiles would not load due to invalid data type in dbf?
-- .loadshp shapefiles/CITIES               cities    UTF-8 2226 SHAPE
-- .loadshp shapefiles/MAIN_RIVERS          rivers    UTF-8 2226 SHAPE
-- .loadshp shapefiles/MajorRoads           roads     UTF-8 2226 SHAPE
-- .loadshp shapefiles/RECREATION           parks     UTF-8 2226 SHAPE
-- .loadshp shapefiles/schools              schools   UTF-8 2226 SHAPE

-- Add spatial indexes to optimize spatial searches
SELECT CreateSpatialIndex('crime', 'SHAPE');
