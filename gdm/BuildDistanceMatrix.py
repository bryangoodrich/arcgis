import arcpy, numpy

from arcpy.da  import FeatureClassToNumPyArray
from arcpy.da  import NumPyArrayToTable
from itertools import product
from os.path   import join as osjoin




# User-defined functions
def joinLocationFields(x, fields):
    '''
    Notes
    '''
    from urllib import quote_plus
    generator = [(quote_plus(str(xx)) for xx in row) for row in x[fields]]
    return ["+".join(gen) for gen in generator]


# Get parameters and set up variables
input_origin       = arcpy.GetParameterAsText(0)
origin_fields      = arcpy.GetParameter(1)
input_destination  = arcpy.GetParameterAsText(2)
destination_fields = arcpy.GetParameter(3)
output_directory   = arcpy.GetParameterAsText(4)
output_filename    = arcpy.GetParameterAsText(5)

# Combine output location from parameters
output_location    = osjoin(output_directory, output_filename)

# Prefix ObjectID to location fields
origin_fields      = ["OID@"] + [str(field) for field in origin_fields]
destination_fields = ["OID@"] + [str(field) for field in destination_fields]
#arcpy.AddMessage(origin_fields)
#arcpy.AddMessage(destination_fields)


# Convert origins and destination layers with selected fields to NumPy arrays
origins      = FeatureClassToNumPyArray(input_origin, origin_fields)
destinations = FeatureClassToNumPyArray(input_destination, destination_fields)



# Create pairs (2-tuples) from feature IDs and API parameter strings
input_pair = zip(origins["OID@"], joinLocationFields(origins, origin_fields[1:]))
near_pair  = zip(destinations["OID@"], joinLocationFields(destinations, destination_fields[1:]))



# Prepare output table based on total number of pairwise
# combinations and anticipated data types
nrows       = len(input_pair) * len(near_pair)
out = numpy.zeros(nrows, dtype = [('INPUT_FID', 'i8'), ('INPUT_PT', '|S50'), \
                                  ('NEAR_FID', 'i8'),  ('NEAR_PT', '|S50'),  \
                                  ('SECONDS', 'int'), ('METERS', 'int'), \
                                  ('FLAG', 'i1')])



# Loop through all pairwise combinations (cartesian product) 
# populating the rows appropriately with the paired content
for i, row in enumerate(product(input_pair, near_pair)):
    out[i] = row[0] + row[1] + (0, 0, 0)



# Delete output file if it exists and then create table from array
if arcpy.Exists(output_location):
    arcpy.management.Delete(output_location)

NumPyArrayToTable(out, output_location)




