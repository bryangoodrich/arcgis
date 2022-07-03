buildCrimeTable <- function(filename = "crime") {
  read.zip <- function(zipfile, infile, ...) {
    tpath  <- file.path("zipcache", zipfile)  # Full path to current zipfile
    data   <- read.table(unz(tpath, infile), ...)
    return(data)
  }  # end function
  
  # Converts the date and time string to a date only string
  makeDate <- function(date) {
    dateClean <- sapply(strsplit(as.character(date), ' '), function(x) x[1])
    dateClean <- as.character(as.Date(dateClean, format = "%m/%d/%Y"))
    return(dateClean)
  }  # end function

  zipfiles <- dir("zipcache")
  
  # The data inside the zip is the zip file name + '.csv'
  crime  <- lapply(seq(zipfiles), function(n) {
    zipfile <- zipfiles[n]
    infile <- paste(substring(zipfile, 1, nchar(zipfile)-3), "csv", sep = "")
    read.zip(zipfile, infile, header = TRUE, sep = ",")
  })  # end lapply

  crime <- do.call("rbind.data.frame", crime)  # Convert crime list to crime frame
  crime <- unique(crime)                       # Originally duplicates existed; this clears them
  crime <- crime[crime$X_Coord != 0 &          # Remove points w/o reference location
                 crime$Y_Coord != 0, ]         # based on X or Y being 0
  crime <- transform(crime, 
    OccDate = makeDate(OccDate),               # Make Date only in POSIX format SQLite understands
    Code    = as.integer(substr(Code, 1, 4))   # Make Code 4 digit version of UOC
  )  # end transform
  
  # Create a ranked version of Code for analysis  
  BREAKS <- c(0, 900, 1000, 1100, 1200, 1300, 1400, 2000, 
              2100, 2200, 2400, 2500, 2700, 2800, 3000, 9000)
  BINS   <- c(8, 1, 3, 8, 4, 2, 8, 4, 5, 8, 6, 8, 5, 7, 8)
  crime <- transform(crime, SimpleCode = cut(Code, BREAKS, include.lowest = TRUE))
  levels(crime$SimpleCode) <- BINS
    
  
    # Create output file timestamp
  filename <- paste(filename, 
      format(Sys.time(), "%Y-%m-%d-%H-%M-%S"),
      "rda", sep = "."
  )  # end paste
  
  save(crime, file = filename, compress = "xz")
  return(filename)
}  # end function