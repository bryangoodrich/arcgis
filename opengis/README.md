# opengis


## Open Source GIS

This project aims to use freely available, open source GIS tools to deliver usable and robust spatial data and reporting.

This codebase automates data importing and configuring data geometry. Data sources come from a variety of sites, but the primary example for this project will be the Sacramento city police crime extracts. To support the GIS in its abstraction and analysis, a number of shapefiles will also be included. As time permits, raster layers will form the basemap and also be maintained by the local spatial database.


### Tools

+ R
+ SQLite + Spatialite
+ Quantum GIS + GRASS

The data stores will include

+ Crime Extracts: ZIP archives cached from web repositories
+ Police Stations: Web scraped from the SacPD website and geocoded by Google Geocoding API
+ Boundary vector shapefiles
+ School vector shapefiles


### Source Code and Processing

The scripts in this repository will either provide automatic processing or require the user to issue the commands sequentially. The R scripts are designed for an interactive session, but they facilitate their linking. For instance, the caching script pulls the data to the local folder, whereas the build script converts the local data--namely, the crime data--into an R table, performing some cleaning operations such as ranking the crime types into a 'simple code' for later use. The build returns the time-stamped file name to the Rdata file created. This is then used in the load function that creates the SQLite database, creates the tables, populates them, and issues a couple indexes. 

From that point on, the database is set up and the initializing SQL scripts will be used to further set up the data store. This includes turning the SQLite DB into a spatial database, setting up geometry columns, creating spatial indexes, and loading the shapefiles.

Once the database is finalized, it can be directly connected to from QGIS. The spatial analysis portion of this project is still in the works, but GRASS is the primary vehicle for an intended kernel density surface analysis--i.e., a raster displaying crime density will be generated. Once this process is established, either GRASS scripts or Python scripts (utilizing GRASS) or shell scripts (invoking GRASS) will be created to automate this portion, facilitating repeated analyses for various data subsets (crime time frames, crime types, etc.).