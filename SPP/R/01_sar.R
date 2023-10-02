#
# Authors: Dan Wismer
#
# Date: Oct 2nd, 2023
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

OUTPUT <- "C:/Data/ANALYSIS/CHARITY_INTELLIEGENCE/Output"

# Read-in ECCC SAR NCC csv
sar_csv <- read.csv(paste0(OUTPUT, "/NCC_ECCC_SAR.csv"), encoding = "UTF-8")
sar_csv$PCLISUM_NCC_INT_FRST_START_DATE <- as.Date(sar_csv$PCLISUM_NCC_INT_FRST_START_DATE, format = "%Y-%m-%d")
parcel_csv <- read.csv(paste0(OUTPUT, "/NCC_ECCC_SAR_DIS_PARCEL.csv"), encoding = "UTF-8")

# Join csv
sar_df <- left_join(sar_csv, parcel_csv, by = "LIS_PARCEL_ID")

# Regional HA function ----
get_reg_ha_tbl <- function(yyyymmdd){
  sar_df %>%
    filter(ymd(PCLISUM_NCC_INT_FRST_START_DATE) <= ymd(yyyymmdd)) %>%
    group_by(LIS_PARCEL_ID, PCL_REGION_EN) %>%
    summarise(SAR_HA = first(SAR_HA)) %>%
    group_by(PCL_REGION_EN) %>%
    summarise(SAR_HA = sum(SAR_HA))
}

# NAT table function ----
get_nat_tbl <- function(yyyymmdd, regional_ha_tbl) {
  sar_df %>%
    filter(ymd(PCLISUM_NCC_INT_FRST_START_DATE) <= ymd(yyyymmdd)) %>%
    summarise(
      DATE = paste0("<= ", yyyymmdd),
      SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
      SAR_COUNT = length(unique(COM_NAME_E))
    ) %>%
    mutate("SAR_HA" = sum(regional_ha_tbl$SAR_HA))
}

# REG table function ----
get_reg_tbl <- function(yyyymmdd, regional_ha_tbl) {
  sar_df %>%
    group_by(PCL_REGION_EN) %>%
    summarise(
      DATE = paste0("<= ", yyyymmdd),
      SAR_NAME = paste(unique(COM_NAME_E), collapse = ", "),
      SAR_COUNT = length(unique(COM_NAME_E))
    ) %>%
    mutate("SAR_HA" = regional_ha_tbl$SAR_HA)
}

# Build tables ----
## 2018 ---
ha_lte2018 <- get_reg_ha_tbl("2018-12-31") 
nat_lte2018 <- get_nat_tbl("2018-12-31", ha_lte2018) 
reg_lte2018 <- get_reg_tbl("2018-12-31", ha_lte2018)

## 2019 ---
ha_lte2019 <- get_reg_ha_tbl("2019-12-31") 
nat_lte2019 <- get_nat_tbl("2019-12-31", ha_lte2019) 
reg_lte2019 <- get_reg_tbl("2019-12-31", ha_lte2019)

## 2020 ---
ha_lte2020 <- get_reg_ha_tbl("2020-12-31") 
nat_lte2020 <- get_nat_tbl("2020-12-31", ha_lte2020) 
reg_lte2020 <- get_reg_tbl("2020-12-31", ha_lte2020)

## 2021 ---
ha_lte2021 <- get_reg_ha_tbl("2021-12-31") 
nat_lte2021 <- get_nat_tbl("2021-12-31", ha_lte2021) 
reg_lte2021 <- get_reg_tbl("2021-12-31", ha_lte2021)

## 2022 ---
ha_lte2022 <- get_reg_ha_tbl("2022-12-31") 
nat_lte2022 <- get_nat_tbl("2022-12-31", ha_lte2022) 
reg_lte2022 <- get_reg_tbl("2022-12-31", ha_lte2022)

## 2023 ---
ha_lte2023 <- get_reg_ha_tbl("2023-12-31") 
nat_lte2023 <- get_nat_tbl("2023-12-31", ha_lte2023) 
reg_lte2023 <- get_reg_tbl("2023-12-31", ha_lte2023)

# Merge tables ----
## NAT
ncc_5yr_sar_nat <- rbind(
  nat_lte2018, 
  nat_lte2019,
  nat_lte2020,
  nat_lte2021,
  nat_lte2022,
  nat_lte2023
  )
write.csv(ncc_5yr_sar_nat, file = paste0(OUTPUT, "/NCC_5YR_SAR_NAT.csv"), fileEncoding = "ISO-8859-1", row.names = FALSE)

## REG
ncc_5yr_sar_by_region <- rbind(
  reg_lte2018, 
  reg_lte2019,
  reg_lte2020,
  reg_lte2021,
  reg_lte2022,
  reg_lte2023
  ) %>%
  rename(Region = PCL_REGION_EN) %>%
  arrange(Region)
write.csv(ncc_5yr_sar_by_region, file = paste0(OUTPUT,  "/NCC_5YR_SAR_REG.csv"), fileEncoding = "ISO-8859-1", row.names = FALSE)
