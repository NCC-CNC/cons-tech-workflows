#
# Authors: Dan Wismer
#
# Date: July 14th, 2023
#
# Description: Sums the total NCC FS lands that intersect ECCC SAR Range Mape
#              extents by species. 
#
# Inputs:  1. NCC Achievments
#          2. ECCC SAR Range map
#          3. COSWEIWC ID field
#
# Outputs: 1. temp outputs saved to cons-tech-workflows/NHCP/NHCP.gdb
#          2. ECCC_SAR_RANGE_MAP_EXTENTS_NCC_ACHIEVMENTS.csv
#
#===============================================================================

import arcpy
import csv
import os

# Get user input
ncc = arcpy.GetParameterAsText(0)
hab = arcpy.GetParameterAsText(1)
cosewic = arcpy.GetParameterAsText(2)

# Get script path and parent directory
script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(script_dir)

# Get name
hab_name = arcpy.Describe(hab).name

# Project 
arcpy.AddMessage("Projecting: {} to Canada_Albers_WGS_1984".format(hab_name))
crs = arcpy.Describe(ncc).spatialReference
hab_prj = arcpy.Project_management(hab, "NHCP.gdb/{}_PRJ".format(hab_name), crs)

# Dissolve
arcpy.AddMessage("Dissolving: {} by {}".format(hab_name, cosewic))
fields = [cosewic, "SCI_NAME", "COM_NAME_E", "TAXON_E", "SAR_STAT_E", "SCHEDULE_E"]
hab_dis = arcpy.management.Dissolve(
  in_features = hab_prj, 
  out_feature_class = "NHCP.gdb/{}".format(hab_name),
  dissolve_field = fields
)

# Delete projection feature
arcpy.management.Delete("NHCP.gdb/{}_PRJ".format(hab_name))

# Add SPC_HA Field
arcpy.management.AddField(hab_dis,"RANGE_HA","DOUBLE")
with arcpy.da.UpdateCursor(hab_dis, ["Range_HA", "SHAPE@AREA"]) as cursor:
    for row in cursor:
      row[0] = round((row[1] / 10000), 2)
      cursor.updateRow(row)

# Add PRP_HA Field (to be populated later)
arcpy.management.AddField(hab_dis,"NCC_FS_HA","DOUBLE")

# Intersect NCC with habitat / range
arcpy.AddMessage("Intersecting: NCC Achievements with {}".format(hab_name))
ncc_hab_int = arcpy.analysis.PairwiseIntersect([ncc, hab_dis], "NHCP.gdb/NCC_{}_INT".format(hab_name))

# Filter for NCC Fee simple
arcpy.AddMessage("Filter for Fee Simple")
int_lyr = arcpy.MakeFeatureLayer_management(ncc_hab_int, "int_lyr")
where = "PCL_INTERE = 'Fee Simple'"
x = arcpy.management.SelectLayerByAttribute(int_lyr, "NEW_SELECTION", where)

# Build dictionary: HA
arcpy.AddMessage("... extract overlap area")
ha = {}
with arcpy.da.SearchCursor(x, [cosewic, "SHAPE@AREA"]) as cursor:
    for row in cursor:
        id, area = row[0], row[1]
        if id not in ha:
            ha[id] = round((area / 10000), 2) 
        else:
            ha[id] += round((area / 10000), 2)

# Join HA dictionary to habitat table 
with arcpy.da.UpdateCursor(hab_dis, [cosewic, "NCC_FS_HA"]) as cursor:
    for row in cursor:
        id = row[0]
        if id in ha:
            row[1] = ha[id]
        else:
            row[1] = 0
        cursor.updateRow(row) 

# Percent NCC protected
arcpy.management.AddField(hab_dis,"PCT_NCC","DOUBLE")
with arcpy.da.UpdateCursor(hab_dis, ["PCT_NCC", "NCC_FS_HA", "RANGE_HA"]) as cursor:
    for row in cursor:
      row[0] = (row[1] / row[2]) * 100
      cursor.updateRow(row)
        
# Export table
arcpy.AddMessage("Exporting to csv")
header = [cosewic, "SCI_NAME", "COM_NAME_E", 
          "TAXON_E",  "SAR_STAT_E", "SCHEDULE_E", 
          "RANGE_HA", "NCC_FS_HA", "PCT_NCC"] 

sheet = "{}/Excel/ECCC_SAR_RANGE_MAP_EXTENTS_NCC_ACHIEVMENTS.csv".format(parent_dir)
with open(sheet, 'w', newline='') as csvfile:
   # Create a CSV writer
    writer = csv.writer(csvfile)
    
    # Write the header row
    writer.writerow(header)

    # Write rows to the CSV file
    with arcpy.da.SearchCursor(hab_dis, header) as cursor:
        for row in cursor:
           # Convert all values to strings using map()
          row = list(map(str, row))
          writer.writerow(row)
