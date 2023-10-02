#
# Authors: Dan Wismer
#
# Date: Oct 2nd, 2023
#
# Description: interect ECCC SAR with NCC Achievments
#
# Inputs:  1. NCC Achievments - pulled from AGOL?
#          2. ECCC SAR Range Map Extents
#
# Outputs: 1. intersection of NCC and SAR
#          2. dissolved intersection by LIS_PARCEL_ID
#
#===============================================================================

import arcpy

# Read-in source data
# NCC = "C:/Data/NAT/NCC_Accomplishments/2023_09_22_request_for_Dan/Accomplishments_pull.gdb/GIS_NCC_Accomplishments_20220913"
NCC = "C:/Data/NAT/NCC_Accomplishments/Accomplishments_20230928.gdb/Accomplishments_20230928"
ECCC_SAR = "C:/Data/NAT/ECCC/SAR/Species at Risk Range Map Extents.gdb/SpeciesAtRiskRangeMapExtents"
FGDB = "C:/Data/ANALYSIS/CHARITY_INTELLIEGENCE/MyProject.gdb"
OUT_CSV = "C:/Data/ANALYSIS/CHARITY_INTELLIEGENCE/Output"

# Set environments
arcpy.env.workspace = "C:/Data/ANALYSIS/CHARITY_INTELLIEGENCE"
crs = arcpy.Describe(NCC).spatialReference
arcpy.env.overwriteOutput = True

# Project ECCC SAR
print("projecting ...")
eccc_sar = arcpy.Project_management(ECCC_SAR , "{}/eccc_sar_prj".format(FGDB), crs)

# Intersect
print("intersecting THIS TAKES APPROX 9 MINS...")
i = arcpy.analysis.Intersect([NCC, eccc_sar], "{}/ncc_eccc_sar".format(FGDB))

# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(i, "{}/NCC_ECCC_SAR.csv".format(OUT_CSV))

# Dissolve by LIS_PARCEL_ID
print("dissolving ...")
d = arcpy.management.Dissolve(i, "{}/ncc_eccc_sar_dis_parcel".format(FGDB), ["LIS_PARCEL_ID"])

# Add Area HA field
arcpy.management.AddField(d,"SAR_HA","DOUBLE")
with arcpy.da.UpdateCursor(d, ["SAR_HA", "SHAPE@AREA"]) as cursor:
    for row in cursor:
      row[0] = (row[1] / 10000)
      cursor.updateRow(row)

# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(d, "{}/NCC_ECCC_SAR_DIS_PARCEL.csv".format(OUT_CSV))
