cacheData <- function() {
  # ========== User-Defined Functions ==========
  findZip <- function(url) {
    require(RCurl)
    urlRequest <- getURL(paste(url, "reports/", sep = ""))
    g <- gregexpr("data/.*?zip'", urlRequest) 
    g <- unlist(regmatches(urlRequest, g))  # regmatches returns list of 1
    g <- substring(g, 6, nchar(g)-1)        # vector of ZIP file names
    g <- paste(url, "data/", g, sep = "")
    return(g)
  }  # end function

  makeCache <- function(filename) {
    tdir <- file.path(getwd(), filename)
    if (file.exists(tdir))  # if directory filename exists, 
      unlink(tdir, TRUE)    # delete it and its contents 
        
    if(!dir.create(tdir, showWarnings = FALSE))
      stop("ZIP caching directory could not be created")  
  }  # end function
  
  getZIP <- function(zipfile) {
    require(RCurl)
    tpath <- file.path("zipcache", paste(substr(zipfile, 39, nchar(zipfile)), sep = ""))
    if (!file.create(tpath))
      stop("File could not be created")
    bin <- getBinaryURL(zipfile)
    zipcon <- file(tpath, open = "wb")
    writeBin(bin, zipcon)
    close(zipcon)
  }  # end function
  
  getStations <- function(url) {
    require(RCurl)
    require(RJSONIO)
    doc <- getURL(url)
    doc <- unlist(strsplit(doc, "\n"))  # Break HTML string by newlines
    
    # Access Station Names from HTML document
    stations <- grep("index.aspx.*<br", doc, value = TRUE)  # station names are between 'station/index.aspx> ... name here ... </a><br \>'
    stations <- regmatches(stations, gregexpr(">.*</", stations))  # grab everything between the HTML tags from the above HTML lines
    stations <- substring(stations, 2, nchar(stations) - 2)  # Remove the remains of those tags used to parse these strings
 
    # Access Station address from HTML document
    addr <- grep("map it", doc, value = TRUE)  # Address in Google Maps API string on line with "(map it)" link
    addr <- sapply(strsplit(addr, "&"), function(x) x[4])  # API parameters separated by &; require 4th element
    addr <- substring(addr, 3)  # ignore the first 2 characters "q="  # Grab address component from split string
    addr <- paste("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=", addr, sep = "")  # Make API strings
    jsonRequest <- getURL(addr)  # returns 4-point character vectors containing JSON strings for each station
    json <- lapply(jsonRequest, fromJSON)  # Convert JSON to R list objects
    pts  <- sapply(json, function(place) place$results[[1]]$geometry$location)  # matrix of (lat, lng)

    # Give Station matrix proper names
    dimnames(pts)[[2]] <- stations  # Properly name our points
    pts <- t(pts)  # lat/long should be on top
    
    # Write out matrix
    tpath <- file.path("stations", "locationmatrix.txt")
    if (!file.create(tpath))
      stop("File could not be created")
    write.table(pts, tpath)
  }  # end function
  
  getShapefiles <- function(zipfile) {
    require(RCurl)
    
    tpath <- file.path("shapefiles", "temp.zip")
    if (!file.create(tpath))
      stop("File could not be created")
    bin <- getBinaryURL(zipfile)
    zipcon <- file(tpath, open = "wb")
    writeBin(bin, zipcon)
    close(zipcon)
    
    # Extract shapefile files
    unzip(tpath, exdir = "shapefiles")
    unlink(tpath)  # remove zip archive
  }  # end function
  
  
  
  # ========== Begin Caching Data ==========
  # Make file directories
  makeCache("zipcache")     # Store crime extracts as zipfiles 
  makeCache("stations")     # Store PD stations data table
  makeCache("shapefiles")   # Store Census boundary shapefiles
  makeCache("images")       # Store basemap imagry
  
  # Obtain data sources
  zipfiles <- findZip("http://www.sacpd.org/crime/stats/")  # Crime extract locations
  lapply(zipfiles, getZIP)  # Download ZIP files
  getStations("http://www.sacpd.org/inside/stations/")  # Create PD station location table
  getShapefiles("http://www.cityofsacramento.org/gis/zipdata/Census2010_BlockPopulation.zip")  # Blocks w/demographics
  getShapefiles("http://www.cityofsacramento.org/gis/zipdata/Schools.zip")                     # Sacramento Schools
  getShapefiles("http://www.sacgis.org/GISDataPub/Data/RECREATION.zip")                        # Sac County Parks
  getShapefiles("http://www.cityofsacramento.org/gis/zipdata/Hospital.zip")                    # Sacramento Hospitals
  getShapefiles("http://www.sacgis.org/GISDataPub/Data/MAIN_RIVERS.zip")                       # Main Rivers
  getShapefiles("http://www.sacgis.org/GISDataPub/Data/CITIES.zip")                            # City boundaries
  getShapefiles("http://www.sacog.org/mapping/clearinghouse/data/MajorRoads.zip")              # Major Roads
}  # end function