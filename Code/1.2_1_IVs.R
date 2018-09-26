rm(list = ls())
#load( "./clean_data/hierarchypaperdata.RData")

library(dplyr)
library(readr)
##CINC, 1816-2012
CINC <- read_csv("./raw_data/NMC_5_0.csv")
names(CINC)
#irst: Iron and steel production (thousands of tons)
# pec: Energy consumption (thousands of coal-ton equivalents)

CINC <- subset(CINC, select = c(ccode, year, milex, milper,
                                irst, pec, tpop, upop, cinc))

####################create Urbanization: urban pop as % of total pop
CINC <- CINC %>% 
       dplyr::mutate(upop = ifelse(upop == -9, NA, upop)) %>% 
       dplyr::mutate(urbanization = (upop / tpop)*100)

#merge by cow code and year

save(CINC, file = "./clean_data/CINC.RData")


####Territorial threats using gibler tir (2014) data

giblertirData <- read.table("./raw_data/gibler.tir.2013.repdata.tab", header = T, sep = "\t")
giblertirData <- subset(giblertirData, select = c(ccode, year,terrthreat))
save(giblertirData, file = "./clean_data/giblertirData.RData")
names(giblertirData)


###########WDI data
library(WDI)
##### SP.POP.TOTL = population; SP.URB.TOTL = urban population
wdi <- WDI(country = "all", indicator = c("SP.URB.TOTL","SP.POP.TOTL"),     
           start = 2013, end = 2015, extra = FALSE, cache = NULL)
head(wdi)  
library(countrycode)
wdi$scode <-  countrycode(wdi$iso2c,"iso2c","iso3c")    
wdi$ccode <-  countrycode(wdi$iso2c,"iso2c","cown")    

###rename variable names 
wdi_urbanization <- wdi %>% filter(!is.na(ccode)) %>% 
                     mutate(WBupop = SP.URB.TOTL,
                            WBpop = SP.POP.TOTL) %>%
                     mutate(WB12_urbanization = (WBupop / WBpop)*100) %>% 
                     select(year, ccode, WB12_urbanization) %>% 
                     mutate_at(vars(ccode), as.numeric)
save(wdi_urbanization, file = "./clean_data/wdi_urbanization.RData")
#
#hierarchypaperdata <- left_join(hierarchypaperdata,wdi_clean, by=c("ccode","year"))
#hierarchypaperdata <- hierarchypaperdata %>% dplyr::mutate(urbanization = ifelse(year > 2012, WB12_urbanization, urbanization)) %>% 
#       dplyr::mutate(urbanization = ifelse(ccode == 380 & year == 2001, 84.07, urbanization)) %>% 
#       dplyr::mutate(urbanization = ifelse(ccode == 830 & year == 1998, 100, urbanization))   #fix sweden for 2001 using WB data & Singapore in 1998


##wdi Labor force participation rate (SL.TLF.CACT.FE.ZS), female (% of female population ages 15+)  from 1990 to 2015
#Fertility rate, total (births per woman), from 1960-2015 (SP.DYN.TFRT.IN)* 
# add male female population (SP.POP.TOTL.MA.IN) female pop = SP.POP.TOTL.FE.IN
# female  total ages 15-64



wdi <- WDI(country = "all", indicator = c("MS.MIL.XPND.GD.ZS","MS.MIL.TOTL.P1",
                                          "SP.POP.TOTL", "NY.GDP.MKTP.KD",
                                          "SL.TLF.CACT.FE.ZS","SP.DYN.TFRT.IN",
                                          "SP.POP.TOTL.MA.IN",
                                          "SP.POP.1564.MA.IN",
                                          "SP.POP.TOTL.FE.IN",
                                          "SP.POP.1564.FE.IN",
                                          "EG.USE.PCAP.KG.OE"),     
           start = 1960, end = 2015, extra = FALSE, cache = NULL)
head(wdi)  
library(countrycode)
wdi$scode <-  countrycode(wdi$iso2c,"iso2c","iso3c")    
wdi$ccode <-  countrycode(wdi$iso2c,"iso2c","cown")    

###rename variable names 
wdi_clean <- wdi %>%dplyr::filter(!is.na(ccode)) %>% 
       dplyr::mutate(WBmilexPercentage = MS.MIL.XPND.GD.ZS,
                     WBarmedpersonnel = MS.MIL.TOTL.P1,
                     WBpop = SP.POP.TOTL, 
                     WBgdp = NY.GDP.MKTP.KD,
                     WBlaborpartic_femal = SL.TLF.CACT.FE.ZS,
                     WBfertility = SP.DYN.TFRT.IN,
                     WBmalepop = SP.POP.TOTL.MA.IN,
                     WBmalepop1564 = SP.POP.1564.MA.IN,
                     WBfepop = SP.POP.TOTL.FE.IN,
                     WBfepop1564 = SP.POP.1564.FE.IN,
                     WBenergy = EG.USE.PCAP.KG.OE) %>%
       dplyr::select(year, ccode, WBmilexPercentage, WBarmedpersonnel, WBpop, WBgdp,
                     WBlaborpartic_femal,WBfertility, WBmalepop, WBmalepop1564,
                     WBfepop,WBfepop1564, WBenergy)
save(wdi_clean, file = "./clean_data/wdi_clean.RData")
#hierarchypaperdata <- left_join(hierarchypaperdata,wdi_clean, by=c("ccode","year"))
#names(hierarchypaperdata);summary(hierarchypaperdata)







#### Using the Contiguity from COW because of the wide coverage (1916-2016)
#version 3.2
ContiguityNum <- read_csv("./raw_data/DirectContiguity320/contdirs.csv")
ContiguityNum <- subset(ContiguityNum, select =c(stateno, year, total, land, sea))
names(ContiguityNum) <- c("COWcode", "year", "total.neighbors",
                          "land.neighbors", "sea.neighbors")
save(ContiguityNum, file = "./clean_data/ContiguityNum.RData")

###Merge Polity data
library(foreign)
polity <- read.spss("./raw_data/p4v2015.sav", to.data.frame=TRUE)
polity <- polity %>%
       select(ccode, year, polity, polity2) 
save(polity, file = "./clean_data/polity.RData")

####read Archigos irregular leadership exits,
archigos_yearly <- read.delim("./raw_data/arch_annual.txt", header = T)

archigos_yearly  <- archigos_yearly %>%
              select(ccode, idacr, leader, startdate, enddate,
                     entry, exit, exitcode) %>% 
              mutate_at(vars(-ccode), as.character) %>% 
              mutate(year = substr(.$startdate, 1, 4))

archigos_yearly <- archigos_yearly %>% 
                     mutate(entry_irregular = ifelse(entry == "Irregular" | 
                                                 entry == "Foreign Imposition", 1, 0),
                            exit_irregular = ifelse(exit == "Irregular" |
                                                 exit == "Foreign", 1, 0)) %>% 
                    mutate(irregular = ifelse(entry_irregular ==1 |
                                          exit_irregular ==1, 1, 0 )) 

archigos_irregular <- archigos_yearly %>%
                     dplyr::group_by(ccode, year, idacr) %>% 
                     dplyr::summarise(irregular_count = sum(irregular)) %>% 
                     dplyr::ungroup() %>% 
                     dplyr::mutate(irregular_dummy = ifelse(irregular_count > 0, 1, 0)) %>% 
                     mutate_at(vars(year), as.integer)
rm(archigos_yearly)

save(archigos_irregular, file = "./clean_data/archigos_irregular.RData")


library(readstata13)
library(countrycode)
########### CNTS data
cntsdata2014 <- read.dta13("./raw_data/2014 Edition CNTSDATA Files with LINKS/cntsdata2014.dta")
cntsdata2014 <- cntsdata2014 %>% 
       dplyr::filter(year > 1899 & year < 2015)

cntsdata2014 <- cntsdata2014 %>% 
       dplyr::select(country, year,  domestic2,
                     domestic4, domestic6,
                     domestic8) %>% 
       dplyr::rename(striks = domestic2, 
                     gov_crises = domestic4, 
                     riots = domestic6,
                     demonstration = domestic8) %>% 
       dplyr::mutate(ccode = countrycode(.$country, "country.name", "cown"))

save(cntsdata2014, file = "./clean_data/cntsdata2014.RData")


