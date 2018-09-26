rm(list = ls())
#load("./clean_data/hierarchypaperdata.RData")

library(dplyr)
library(readr)
library(haven)
library(foreign)
library(tidyverse)
library(readstata13)
###load vdem data
load("./raw_data/Country_Year_V-Dem_STATA_v6.2 2/V-Dem-DS-CY-v6.2.RData")

###load vdem data
###only keep year, COWcode, 
#1. Power distributed by gender (v2pepwrgen)
#2. women political empowerment index (v2x_gender)
#3. women’s civil liberties index (v2x_gencl)
#4. freedom from forced labor for women (v2clslavef)
#5. property rights for women (v2clprptyw)
#6. women’s civil society participation index (v2x_gencs),
#7. women’s political participation index (v2x_genpp)
#8. freedom of discussion for women (v2cldiscw), 
#9. access to justice for women (v2clacjstw)
#10. civil society organization women’s participation (v2csgender)
#11. clean election index (v2xel_frefair)
#12.civil society index(v2xcs_ccsi)

vdem <- vdem_raw %>% 
              select(COWcode, year, v2pepwrgen, v2x_gender, v2x_gencl, v2clslavef,v2clprptyw,
                     v2x_gencs,v2x_genpp, v2cldiscw, v2clacjstw,
                     v2csgender,v2xel_frefair,v2xcs_ccsi)

vdem <- vdem %>% mutate_at(vars(COWcode, year, v2pepwrgen, v2x_gender, v2x_gencl, v2clslavef,v2clprptyw,
                                v2x_gencs,v2x_genpp, v2cldiscw, v2clacjstw,
                                v2csgender,v2xel_frefair,v2xcs_ccsi), as.numeric)
rm(vdem_raw)
vdem <- vdem %>% dplyr::rename(powerbygender = v2pepwrgen,
                               polempowerment = v2x_gender,
                               civilliberty = v2x_gencl,
                               freeforcedlabor = v2clslavef,
                               propertyright = v2clprptyw,
                               civilparticip = v2x_gencs,
                               politicalparticip = v2x_genpp,
                               freediscussion = v2cldiscw,
                               justicaccess = v2clacjstw,
                               civilorgz = v2csgender,
                               cleanelec = v2xel_frefair,
                               civilsoci = v2xcs_ccsi)


save(vdem, file = "./clean_data/vdem.RData")

#save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")

