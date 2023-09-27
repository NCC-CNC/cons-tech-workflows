#
# Authors: Dan Wismer
#
# Date: Sept 27th, 2023
#
# Description: Summaries unique species names, count and area (overlap dissolved)
#              regionally and nationally
#
# Inputs:  1. CSV outputs from Python/01_intersect.py
#
#
# Outputs: 1. national sumamry csv
#          2. regional summary csv
#
#===============================================================================

library(dplyr)
library(lubridate)

# Read-in ECCC SAR NCC csv
sar_csv <- read.csv("SPP/Output/NCC_ECCC_SAR.csv", encoding = "UTF-8")
sar_csv$FIRST_NCC_DATE <- as.Date(sar_csv$FIRST_NCC_DATE, format = "%Y-%m-%d")
prp_csv <- read.csv("SP/Output/NCC_ECCC_SAR_DIS_PRP_ID.csv", encoding = "UTF-8")

# Join csv
sar_df <- left_join(sar_csv, prp_csv, by = "Property_ID")

# Include only these fields:
fields <- c(
  "Region", "LIS_PARCEL_ID", "Property_ID", "Parcel_Interest", "Property_Name", 
  "ACTIVE","FIRST_NCC_DATE", "COSEWICID", "SCI_NAME", "COM_NAME_E", "SAR_HA"
)

# 2018 ---
## HA
sar_ha_df_lte2018 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2018-12-31")) %>%
  group_by(Property_ID, Region) %>%
  summarise(
    SAR_HA = first(SAR_HA),
  ) %>%
  group_by(Region) %>%
  summarise(
    SAR_HA = sum(SAR_HA)
  )

## NAT 
ncc_nat_sar_lte2018 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2018-12-31")) %>%
  summarise(
    DATE = "<= 2018-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sum(sar_ha_df_lte2018$SAR_HA), big.mark = ","))

## REG
ncc_region_sar_lte2018 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2018-12-31")) %>%
  group_by(Region) %>%
  summarise(
    DATE = "<= 2018-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sar_ha_df_lte2018$SAR_HA, big.mark = ","))


# 2019 ----
# HA
sar_ha_df_lte2019 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2019-12-31")) %>%
  group_by(Property_ID, Region) %>%
  summarise(
    SAR_HA = first(SAR_HA),
  ) %>%
  group_by(Region) %>%
  summarise(
    SAR_HA = sum(SAR_HA)
  )

## NAT 
ncc_nat_sar_lte2019 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2019-12-31")) %>%
  summarise(
    DATE = "<= 2019-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sum(sar_ha_df_lte2019$SAR_HA), big.mark = ","))

## REG
ncc_region_sar_lte2019 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2019-12-31")) %>%
  group_by(Region) %>%
  summarise(
    DATE = "<= 2019-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sar_ha_df_lte2019$SAR_HA, big.mark = ","))

# 2020 ---- 
## HA
sar_ha_df_lte2020 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2020-12-31")) %>%
  group_by(Property_ID, Region) %>%
  summarise(
    SAR_HA = first(SAR_HA),
  ) %>%
  group_by(Region) %>%
  summarise(
    SAR_HA = sum(SAR_HA)
  )

## NAT 
ncc_nat_sar_lte2020 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2020-12-31")) %>%
  summarise(
    DATE = "<= 2020-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sum(sar_ha_df_lte2020$SAR_HA), big.mark = ","))

## REG
ncc_region_sar_lte2020 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2020-12-31")) %>%
  group_by(Region) %>%
  summarise(
    DATE = "<= 2020-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sar_ha_df_lte2020$SAR_HA, big.mark = ","))

# 2021 
## HA
sar_ha_df_lte2021 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2021-12-31")) %>%
  group_by(Property_ID, Region) %>%
  summarise(
    SAR_HA = first(SAR_HA),
  ) %>%
  group_by(Region) %>%
  summarise(
    SAR_HA = sum(SAR_HA)
  )

## NAT 
ncc_nat_sar_lte2021 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2021-12-31")) %>%
  summarise(
    DATE = "<= 2021-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sum(sar_ha_df_lte2021$SAR_HA), big.mark = ","))

## REG
ncc_region_sar_lte2021 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2021-12-31")) %>%
  group_by(Region) %>%
  summarise(
    DATE = "<= 2021-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sar_ha_df_lte2021$SAR_HA, big.mark = ","))

# 2022
## HA
sar_ha_df_lte2022 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2022-12-31")) %>%
  group_by(Property_ID, Region) %>%
  summarise(
    SAR_HA = first(SAR_HA),
  ) %>%
  group_by(Region) %>%
  summarise(
    SAR_HA = sum(SAR_HA)
  )

## NAT
ncc_nat_sar_lte2022 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2022-12-31")) %>%
  summarise(
    DATE = "<= 2022-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sum(sar_ha_df_lte2022$SAR_HA), big.mark = ","))

## REF
ncc_region_sar_lte2022 <- sar_df %>%
  select(all_of(fields)) %>%
  filter(ymd(FIRST_NCC_DATE) <= ymd("2022-12-31")) %>%
  group_by(Region) %>%
  summarise(
    DATE = "<= 2022-12-31",
    SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
    SAR_COUNT = length(unique(COM_NAME_E))
  ) %>%
  mutate("SAR_HA" = prettyNum(sar_ha_df_lte2022$SAR_HA, big.mark = ","))


# Merge tables ----
## NAT
ncc_5yr_sar_nat <- rbind(
  ncc_nat_sar_lte2018, 
  ncc_nat_sar_lte2019,
  ncc_nat_sar_lte2020,
  ncc_nat_sar_lte2021,
  ncc_nat_sar_lte2022
  )
write.csv(ncc_5yr_sar_nat, "SPP/Output/NCC_5YR_SAR_NAT.csv")

## REG
ncc_5yr_sar_by_region <- rbind(
  ncc_region_sar_lte2018, 
  ncc_region_sar_lte2019,
  ncc_region_sar_lte2020,
  ncc_region_sar_lte2021,
  ncc_region_sar_lte2022
  ) %>%
  arrange(Region)
write.csv(ncc_5yr_sar_by_region, "SPP/Output/NCC_5YR_SAR_REG.csv")
