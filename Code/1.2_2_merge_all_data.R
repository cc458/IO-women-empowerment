rm(list = ls())
library(dplyr)
#load base data
load("./clean_data/hierarchypaperdata.RData")

#load DV
load("./clean_data/vdem.RData")

hierarchypaperdata <- left_join(hierarchypaperdata, vdem, by = c("COWcode", "year"))

#load CINC
load("./clean_data/CINC.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, CINC, by = c("COWcode" = "ccode", "year" = "year"))

#replace with WDI 
load("./clean_data/wdi_urbanization.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, wdi_urbanization, by=c("ccode","year"))
hierarchypaperdata <- hierarchypaperdata %>% dplyr::mutate(urbanization = ifelse(year > 2012, WB12_urbanization, urbanization)) %>% 
       dplyr::mutate(urbanization = ifelse(ccode == 380 & year == 2001, 84.07, urbanization)) %>% 
       dplyr::mutate(urbanization = ifelse(ccode == 830 & year == 1998, 100, urbanization))   #fix sweden for 2001 using WB data & Singapore in 1998

# other WDI
load("./clean_data/wdi_clean.RData")
hierarchypaperdata <- left_join(hierarchypaperdata,wdi_clean, by=c("ccode","year"))


#polity
load("./clean_data/polity.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, polity, by = c("COWcode" = "ccode", "year"))

#archigos_irregular
load("./clean_data/archigos_irregular.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, archigos_irregular, by = c("COWcode" = "ccode", "year"))

#neighbor
load("./clean_data/ContiguityNum.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, ContiguityNum, by = c("COWcode", "year"))

##add total number of intra-state war
load("./clean_data/country_year_cow_intra.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, country_year_cow_intra, by = c("COWcode" = "ccodea", "year"))


#total number of interstate war
load("./clean_data/country_year_cow2.3.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, country_year_cow2.3, by = c("COWcode" = "ccode", "year"))

##terr threats
load("./clean_data/giblertirData.RData")
hierarchypaperdata <- left_join(hierarchypaperdata, giblertirData, by = c("COWcode" = "ccode", "year"))

save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")





