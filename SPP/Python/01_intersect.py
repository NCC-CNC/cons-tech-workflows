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
NSC_END = "C:/Data/NAT/SPECIES_1km/NSC_END/SHP/NSC_END.shp"
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
print("intersecting ECCC SAR: THIS TAKES APPROX 9 MINS...")
i_sar = arcpy.analysis.Intersect([NCC, eccc_sar], "{}/ncc_eccc_sar".format(FGDB))
print("intersecting NSC END: THIS TAKES APPROX 9 MINS...")
i_end = arcpy.analysis.Intersect([NCC, NSC_END], "{}/ncc_nsc_end".format(FGDB))


# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(i_sar, "{}/NCC_ECCC_SAR.csv".format(OUT_CSV))
arcpy.conversion.ExportTable(i_end, "{}/NCC_NSC_END.csv".format(OUT_CSV))

# Dissolve by LIS_PARCEL_ID
print("dissolving SAR ...")
d_sar = arcpy.management.Dissolve(i_sar, "{}/ncc_eccc_sar_dis_parcel".format(FGDB), ["LIS_PARCEL_ID"])
print("dissolving END ...")
d_end = arcpy.management.Dissolve(i_end, "{}/ncc_nsc_end_dis_parcel".format(FGDB), ["LIS_PARCEL_ID"])


# Add Area HA field - SAR
arcpy.management.AddField(d_sar,"SAR_HA","DOUBLE")
with arcpy.da.UpdateCursor(d_sar, ["SAR_HA", "SHAPE@AREA"]) as cursor:
    for row in cursor:
      row[0] = (row[1] / 10000)
      cursor.updateRow(row)

# Add Area HA field - END      
arcpy.management.AddField(d_end,"END_HA","DOUBLE")
with arcpy.da.UpdateCursor(d_end, ["END_HA", "SHAPE@AREA"]) as cursor:
    for row in cursor:
      row[0] = (row[1] / 10000)
      cursor.updateRow(row)      

# Export attribute table as csv
print("exporting ...")
arcpy.conversion.ExportTable(d_sar, "{}/NCC_ECCC_SAR_DIS_PARCEL.csv".format(OUT_CSV))
arcpy.conversion.ExportTable(d_end, "{}/NCC_NSC_END_DIS_PARCEL.csv".format(OUT_CSV))
