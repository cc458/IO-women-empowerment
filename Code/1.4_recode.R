rm(list = ls())
library(dplyr)
library(Matrix)
library(readstata13)
library(zoo)
library(data.table)
library(foreign)
library(countrycode)
load("./clean_data/hierarchypaperdata.RData")

summary(hierarchypaperdata)

#####################################################
###recode & log
#irst: Iron and steel production (thousands of tons)
#pec: Energy consumption (thousands of coal-ton equivalents)
#milex: Military Expenditures (For 1816-1913: thousands of current year British Pounds. For 1914:thousandsof current year US Dollars.)
#milper: Military Personnel (thousands)
#tpop: Total Population (thousands)


# 1. we replace all CINC data with WDI data after 2012
### energe use, we use WDI's energe use which is `kg of oil equivalent per capita`) after 2012
#recode all -9 as NA
#### Use WDI pop (in person, need to divided by 1000)

#Armed forces personnel, total: 
# Military expenditure (% of GDP):

hierarchypaperdata <- hierarchypaperdata %>%
              dplyr::mutate(milex = ifelse(milex==-9L, NA, milex), 
                                   milper = ifelse(milper == -9L, NA, milper),
                                   pec = ifelse(pec ==-9L, NA, pec)) %>% 
              dplyr::mutate(tpop = ifelse(year > 2012, WBpop/1000, tpop),
                            milper = ifelse(year > 2012, WBarmedpersonnel/1000, milper),
                            milex = ifelse(year > 2012, (WBmilexPercentage*WBgdp)/1000, milex),
                            pec = ifelse(year > 2012, WBenergy*26+42500, pec),
                            urbanization = ifelse(year > 2012,WB12_urbanization, urbanization)) 
       
       
hierarchypaperdata <- hierarchypaperdata %>%      
                     dplyr::mutate(milex_pc = milex / tpop,
                                   milper_pc = 100*milper / tpop) %>%  
                     dplyr::mutate(pec_pc = pec /tpop,
                                   lpop = log(tpop+1),
                                   lpec = log(1 + pec),
                                   lupop = log(1 + upop),
                                   ldeath = log(1 + total_BatDeath)) %>% 
                     dplyr::mutate(lmilex_pc = log(1+ milex_pc),
                                   lmilper_pc = log(1 + milper_pc),
                                   lpec_pc = log(1 + pec_pc))
summary(hierarchypaperdata$lmilper_pc)
## population of WDI
hierarchypaperdata <- hierarchypaperdata %>% 
                            dplyr::mutate(lWBmalepop = log(WBmalepop),
                                          lWBfepop = log(WBfepop),
                                          lWBmalepop1564 = log(WBmalepop1564),
                                          lWBfepop1564 = log(WBfepop1564))
##write to stata
library(haven)
##change some variable names to keep consistent with stata

hierarchypaperdata <- hierarchypaperdata %>% 
                     dplyr::rename(country_name = country.name, 
                                   total_neighbors = total.neighbors,
                                   land_neighbors = land.neighbors,
                                   sea_neighbors = sea.neighbors,
                                   neighboringInterStateWar_excldd = neighboringInterStateWar_excluded,
                                   neighboringInterSttWr_xclddDmmy = neighboringInterStateWar_excludedDummy)

write_dta(hierarchypaperdata, "./clean_data/hierarchypaperdata.dta")



summary(hierarchypaperdata)
#####may be check if we need to keep pec as pec_pc and replace with WDI energy after 2013
library(ggplot2)
library(tidyr)

hierarchypaperdata %>% 
       select(year, ccode, pec_pc, WBenergy) %>% 
       filter(year > 1960) %>% 
       dplyr::group_by(year) %>% 
       dplyr::summarise(pec_pc = mean(pec_pc, na.rm = T),
                 WBenergy = mean(WBenergy,na.rm = T)) %>% 
       dplyr::mutate(WBenergy = WBenergy /1000) %>% 
       dplyr::ungroup() %>% 
       gather(key, value, pec_pc, WBenergy) %>% 
       ggplot(aes(x=year, y = value, colour = key)) + geom_line()





