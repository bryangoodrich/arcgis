# quake

Python app for reading USGS GeoRSS Data

A lot of internet content can easily be provied by RSS or ATOM standard feeds. These are typically XML-based data transport objects (DTOs). While I would prefer dealing with GeoJSON these days, when this project began, GeoRSS was
an XML extension that handled spatial geometry fields.

This Python script is designed to handle the USGS earthquake GeoRSS by being an aggregator that creates an aggregation via a feature class for ArcGIS. When the user selects an already existing feature class, the behavior is to update the feature with the new information not already contained within. There is a flag to overwrite the class to begin a
fresh aggregation.

~~The USGS earthquake feeds are listed here: http://earthquake.usgs.gov/earthquakes/catalogs/~~

Today you can just use their own web map: https://earthquake.usgs.gov/earthquakes/map/

