#
# Authors: Dan Wismer
#
# Date: Sept 27th, 2023
#
# Description: interect ECCC SAR with NCC Achievments
#
# Inputs:  1. NCC Achievments
#          2. ECCC SAR Range Map Extents
#
# Outputs: 1. intersection of NCC and SAR
#          2. dissolved intersection by property id
#
#===============================================================================

import arcpy

# Read-in source data
NCC = "C:/Data/NAT/NCC_Accomplishments/2023_09_22_request_for_Dan/Accomplishments_pull.gdb/GIS_NCC_Accomplishments_20220913"
ECCC_SAR = "C:/Data/NAT/ECCC/SAR/Species at Risk Range Map Extents.gdb/SpeciesAtRiskRangeMapExtents"

# Set environments
arcpy.env.workspace = "C:/Data/ANALYSIS/CHARITY_INTELLIEGENCE"
crs = arcpy.Describe(NCC).spatialReference
arcpy.env.overwriteOutput = True

# Project ECCC SAR
print("projecting ...")
eccc_sar = arcpy.Project_management(ECCC_SAR , "MyProject.gdb/eccc_sar_prj", crs)

# Intersect
print("intersecting THIS TAKES A LONG TIME...")
i = arcpy.analysis.Intersect([NCC, eccc_sar], "MyProject.gdb/ncc_eccc_sar")

# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(i, "Output/NCC_ECCC_SAR.csv")

# Dissolve by Property_ID
print("dissolving ...")
d = arcpy.management.Dissolve(i, "MyProject.gdb/ncc_eccc_sar_dis_prp_id", "Property_ID")

# Add Area HA field
arcpy.management.AddField(d,"SAR_HA","DOUBLE")
with arcpy.da.UpdateCursor(d, ["SAR_HA", "SHAPE@AREA"]) as cursor:
    for row in cursor:
      row[0] = (row[1] / 10000)
      cursor.updateRow(row)

# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(d, "Output/NCC_ECCC_SAR_DIS_PRP_ID.csv")
