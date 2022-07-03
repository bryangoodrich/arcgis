loadDB <- function(datafile, dbname = "saccrime.db") {
  require(RSQLite)
  
  # ========== Prepare data for loading ==========
  load(datafile)  # loads 'crime'
  
  # Create crime type based on SimpleCode
  crime_type <- data.frame(
    SimpleCode  = 1:8,
    Description = c(                   "Homicide",        "Assault", "Kidnapping", "Robbery & Arson", 
                       "Embezzlement & Extortion", "Stolen Vehicle", 
                    "Stolen or Damanged Property",         "Others")
  );  #end data.frame
  
  # Police Station data matrix
  stations <- read.table(file.path("stations", "locationmatrix.txt"))
  
  
  
  # ========== Prepare database file creation ==========
  # Delete any prior instances of database db
  if (file.exists(dbname)) {
    cat("Deleting prior copy of database\n")
    unlink(dbname)
  }  # end if
  
  # Initialize SQLite driver and database
  drv <- dbDriver("SQLite")
  con <- dbConnect(drv, dbname)
  on.exit(dbDisconnect(con), add = TRUE)
  
  
  
  # ========== Create Database Tables ==========
  # Create the table structures for the crime and crime type data
  res <- dbSendQuery(con, "CREATE TABLE crime (
    rowname      INTEGER PRIMARY KEY ASC
    ,InternalID  TEXT
    ,OccDate     TEXT
    ,Location    TEXT
    ,Apartment   TEXT
    ,District    TEXT
    ,Beat        TEXT
    ,Grid        TEXT
    ,X_Coord     INT
    ,Y_Coord     INT
    ,Code        INT
    ,Description TEXT
    ,SimpleCode  INT)"
  )  # end create table
  dbClearResult(res)
  
  # Create the crime type data table
  res <- dbSendQuery(con, "CREATE TABLE crime_type (
    SimpleCode   INTEGER PRIMARY KEY ASC
    ,Description TEXT)"
  )  # end create table
  dbClearResult(res)
  
  # Create the PD station table
  res <- dbSendQuery(con, "CREATE TABLE stations (
    station_name
    ,lat
    ,lng)"
  )  # end create table
  dbClearResult(res)
  
  
  
  # ========== Load prepared data into database tables ==========
  # Write the contents of the crime and crime type data to their tables
  dbWriteTable(con,      "crime",      crime, append = TRUE)
  dbWriteTable(con, "crime_type", crime_type, append = TRUE, row.names = FALSE)
  dbWriteTable(con,   "stations",   stations, append = TRUE)
  
  
  
  # ========== Define Indexes on date and code for later querying ==========
  res <- dbSendQuery(con, "CREATE INDEX index_OccDate ON crime (OccDate)")
  dbClearResult(res)
  res <- dbSendQuery(con, "CREATE INDEX index_code    ON crime (SimpleCode)")
  dbClearResult(res)
}  # end function
