#
# Authors: Dan Wismer
#
# Date: Oct 4th, 2023
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

# Read-in NSC END NCC csv
end_csv <- read.csv(paste0(OUTPUT, "/NCC_NSC_END.csv"), encoding = "UTF-8")
end_csv$PCLISUM_NCC_INT_FRST_START_DATE <- as.Date(end_csv$PCLISUM_NCC_INT_FRST_START_DATE, format = "%Y-%m-%d")
parcel_csv <- read.csv(paste0(OUTPUT, "/NCC_NSC_END_DIS_PARCEL.csv"), encoding = "UTF-8")

# Join csv
end_df <- left_join(end_csv, parcel_csv, by = "LIS_PARCEL_ID")

# Regional HA function ----
get_reg_ha_tbl <- function(yyyymmdd){
  end_df %>%
    filter(ymd(PCLISUM_NCC_INT_FRST_START_DATE) <= ymd(yyyymmdd)) %>%
    group_by(LIS_PARCEL_ID, PCL_REGION_EN) %>%
    summarise(END_HA = first(END_HA)) %>%
    group_by(PCL_REGION_EN) %>%
    summarise(END_HA = sum(END_HA))
}

# NAT table function ----
get_nat_tbl <- function(yyyymmdd, regional_ha_tbl) {
  end_df %>%
    filter(ymd(PCLISUM_NCC_INT_FRST_START_DATE) <= ymd(yyyymmdd)) %>%
    summarise(
      DATE = paste0("<= ", yyyymmdd),
      END_NAME = paste(unique(com_name), collapse = ", "),
      END_COUNT = length(unique(com_name))
    ) %>%
    mutate("END_HA" = sum(regional_ha_tbl$END_HA))
}

# REG table function ----
get_reg_tbl <- function(yyyymmdd, regional_ha_tbl) {
  end_df %>%
    group_by(PCL_REGION_EN) %>%
    summarise(
      DATE = paste0("<= ", yyyymmdd),
      END_NAME = paste(unique(com_name), collapse = ", "),
      END_COUNT = length(unique(com_name))
    ) %>%
    mutate("END_HA" = regional_ha_tbl$END_HA)
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
ncc_5yr_end_nat <- rbind(
  nat_lte2018, 
  nat_lte2019,
  nat_lte2020,
  nat_lte2021,
  nat_lte2022,
  nat_lte2023
)
write.csv(ncc_5yr_end_nat, file = paste0(OUTPUT, "/NCC_5YR_END_NAT.csv"), fileEncoding = "ISO-8859-1", row.names = FALSE)

## REG
ncc_5yr_end_by_region <- rbind(
  reg_lte2018, 
  reg_lte2019,
  reg_lte2020,
  reg_lte2021,
  reg_lte2022,
  reg_lte2023
) %>%
  rename(Region = PCL_REGION_EN) %>%
  arrange(Region)
write.csv(ncc_5yr_end_by_region, file = paste0(OUTPUT,  "/NCC_5YR_END_REG.csv"), fileEncoding = "ISO-8859-1", row.names = FALSE)



