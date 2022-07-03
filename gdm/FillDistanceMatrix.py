## Second Script Tool -- Populate Distance Matrix
##	(2)  Check time and set 100 counter and set day counter
##	(4)  Parse return JSON
##	(5)  Update matrix with values and set flag 1
##	(6)  Update query counter
##	(7)  If counter is 100, reset and update day counter
##	(8)  check time > 10 seconds, else wait remainder
##	(9)  Check if day counter is 25 (for 2500 in a day)
##	(10) Repeat until day counter is finished. Stop and report results
##


import arcpy, numpy, urllib, json, datetime

from arcpy.da import NumPyArrayToTable
from arcpy.da import TableToNumPyArray



# Get Script Parameters and initialize variables
input_table = arcpy.GetParameterAsText(0)

api_url     = "http://maps.googleapis.com/maps/api/distancematrix/json"
api_keys    = ('sensor', 'units', 'origins', 'destinations')
dmatrix     = TableToNumPyArray(input_table, "*")
NMAX        = 100


# Index Currently not flagged records
isZero = numpy.where(dmatrix["FLAG"] == 0)[0]

# If more flags than able to process in 24 hours (2500 queries/records), 
# limit index array on this call.
if len(isZero) > NMAX:
    isZero = isZero[0:NMAX]



# Loop through non flagged records
for index in isZero:
    arcpy.AddMessage("Processing NumPy Array Index: %d" % index)
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    arcpy.AddMessage("Processing Beginning at: %s" % timestamp)
    
    # Unpack elements of array tuple and construct parameter dictionary.
    # Use parameter to make API string and parse returned JSON
    oid, input_oid, origin, near_oid, destination, seconds, meters, flag = dmatrix[index]
    parameters = dict(zip(api_keys, ("false", "imperial", origin, destination)))
    doc = json.load(urllib.urlopen(api_url + "?" + urllib.urlencode(parameters)))
    
    if doc['status'] != "OK":
        arcpy.AddMessage(doc['status'])
        continue
    
    # Parse and Populate
    # Loop through rows (one for each origin)
    # In this design, always 1 row
    row = doc['rows'][0]  # for row in rows: ...
    
    # Loop through elements of row (one for each destination from given row-origin)
    # In this design, always 1 element
    element = row['elements'][0]  # for element in elements: ...
    
    if element['status'] != "OK":
        arcpy.AddMessage(element['status'])
        continue
    
    seconds = element['duration']['value']
    meters  = element['distance']['value']
    
    dmatrix[index] = (oid, input_oid, origin, near_oid, destination, seconds, meters, 1)
    
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    arcpy.AddMessage("Processing Index Finished at: %s" % timestamp)


arcpy.management.Delete(input_table)
NumPyArrayToTable(dmatrix, input_table)

