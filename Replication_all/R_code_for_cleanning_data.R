#############################################################################
rm(list = ls())
#### Load libraries 
library(cshapes)
library(countrycode)
library(dplyr)
library(plyr)
library(data.table)
library(countrycode)
library(readr)
library(haven)
library(foreign)
library(tidyverse)
library(readstata13)
library(foreign)
library(reshape2)
library(readr)
library(tidyr)
library(sqldf)
library(readr)
library(WDI)
library(Matrix)
library(zoo)
library(sf)
library(maptools)
library(ggplot2)
library(scales)
library(ggmap)
library(readr)
library(readxl)
library(stringr)

#make sure your working directory is this IO-women-empowerment
#setwd("IO-women-empowerment")

# Create clean_date directory for cleanning variables
invisible(sapply(c("clean_data"), function(d) {
       if (!dir.exists(d)) dir.create(d)
}))

#############################################################################
# Step 1: create time-series cross-sectiona data from 1900-2015
### for 1946-2015: use cshape data
### for 1900 -1945: use GW
#############################################################################

#load Andreas Beger's function to create country-year data frame
################################################################################
##
##    Create a blank panel data set based on Gleditsch and Ward or COW.
##    Andreas Beger
##    10 Dec. 2013
 ##https://raw.githubusercontent.com/andybega/R_utilities/master/data/state-panel.r
##
##    G&W: http://privatewww.essex.ac.uk/~ksg/statelist.html
##    COW: http://www.correlatesofwar.org/datasets.html
##
################################################################################

state_panel <- function(start.date, end.date, by="month", useGW=TRUE) {
  require(cshapes)
  panel.start <- attempt_date(start.date, by)
  panel.end <- attempt_date(end.date, by)
  
  # Create vector of desired dates
  date <- seq.Date(panel.start, panel.end, by=by)
  
  # Initialize results panel
  panel <- data.frame(NULL)
  
  # Get full data and subset by date; fill in results
  cshp.full <- cshp()@data
  max.cshp.date <- max(as.Date(paste(cshp.full$GWEYEAR, cshp.full$GWEMONTH, cshp.full$GWEDAY, sep = "-")), na.rm=T)
  
  # Progress bar
  pb <- txtProgressBar(1, length(date), initial=1, style=3, width=60)
  
  for (i in seq_along(date)) {
    if (useGW) {
      ctry.start <- as.Date(paste(cshp.full$GWSYEAR, cshp.full$GWSMONTH, cshp.full$GWSDAY, sep = "-"))
      ctry.end   <- as.Date(paste(cshp.full$GWEYEAR, cshp.full$GWEMONTH, cshp.full$GWEDAY, sep = "-"))
      if (date[i] <= max.cshp.date) {
      	date.slice <- cshp.full[ctry.start <= date[i] & ctry.end >= date[i], "GWCODE"]
        date.slice <- date.slice[!is.na(date.slice)]  # fix for NA dates in GW
      } else {
      	date.slice <- cshp.full[ctry.start <= max.cshp.date & ctry.end >= max.cshp.date, "GWCODE"]
      	date.slice <- date.slice[!is.na(date.slice)]  # fix for NA dates in GW
      	warning(paste0("Exceeding cshapes max date, using ", max.cshp.date, " instead of ", date[i]))
      }
    } else if (!useGW) {
      ctry.start <- as.Date(paste(cshp.full$COWSYEAR, cshp.full$COWSMONTH, cshp.full$COWSDAY, sep = "-"))
      ctry.end   <- as.Date(paste(cshp.full$COWEYEAR, cshp.full$COWEMONTH, cshp.full$COWEDAY, sep = "-"))
      if (date[i] <= max.cshp.date) {	
        date.slice <- cshp.full[ctry.start <= date[i] & ctry.end >= date[i], "COWCODE"]
      } else {
      	date.slice <- cshp.full[ctry.start <= max.cshp.date & ctry.end >= max.cshp.date, "COWCODE"]
      	warning(paste0("Exceeding cshapes max date, using ", max.cshp.date, " instead of ", date[i]))
      }
    }
    # Append to results panel
    panel <- rbind(panel, data.frame(ccode=date.slice, date=date[i]))
    
    # Update progress bar
    setTxtProgressBar(pb, i)
  }
  # Create unique ID
  panel$id <- paste(panel$date, panel$ccode)
  panel <- panel[order(panel$ccode, panel$date), ]
  close(pb)
  return(panel)
}

attempt_date <- function(date, by) {
  if (!class(date)=="Date") {
  	try(date <- as.Date(date), silent=TRUE)
  	if (class(date)=="Date") {
  	  warning("Converting to 'Date' class")
    } else if (by=="year") {
  	  try(date <- as.Date(paste0(date, "-06-30")), silent=TRUE)
  	  if (class(date)=="Date") {
  	  	warning("Converting to 'Date' class with yyyy-06-30")
  	  }
  	} else if (by=="month") {
  	  try(date <- as.Date(paste0(date, "-15")), silent=TRUE)
  	  if (class(date)=="Date") {
  	  	warning("Converting to 'Date' class with yyyy-mm-15")
  	  }
  	}
  }
  if (!class(date)=="Date") {
  	stop(paste("Could not convert to class 'Date'"))
  }
  return(date)
}

####creat state panel data frame from 1946 to 2015
state.panel <- state_panel("1946", "2015", by="year")
##create country.name
state.panel$country.name <- countrycode(state.panel$ccode,"cown","country.name")
##create year 
state.panel$year <- format(state.panel$date,format="%Y")
## check number of countries and years
head(state.panel)
table(state.panel$year)

### for 1900- 1945
###read Gleditsch& ward country list
GWstates <- read.delim2("./raw_data/iisystem.dat", header = F, sep = "\t")
#rename variables
names(GWstates) <- c("ccode", "ISO3", "country.name", "start.date", "end.date")
# make them as character 
GWstates <- GWstates %>% 
                dplyr::mutate_at(vars(ISO3, country.name,
                             start.date, end.date), as.character)
## get years
GWstates$start.year <- as.integer(substr(GWstates$start.date, 7, 10))
GWstates$end.year <- as.integer(substr(GWstates$end.date, 7, 10))

## check duplicates: some countries created in the same year
GWstates <- GWstates %>% 
                     dplyr::filter(end.year >= 1900) %>% 
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(dup = n(), cum = cumsum(dup))
## create a unique ID for duplicates
GWstates$ccodeID <- paste(GWstates$ccode, GWstates$cum, sep="-")
## Make it a panel data formart
dt <- data.table(GWstates)
## do the transformation to panel data based on their start and end year 
GWstates_panel <- dt[, list(year = seq(start.year, end.year)), by = ccodeID]
## select the interested variables only
GWstates <- subset(GWstates, select = c(ccode, ISO3, country.name, ccodeID))
## merge  
GWstates_panel <- left_join(GWstates_panel, GWstates, by = "ccodeID")
## remove the ID 
GWstates_panel$ccodeID <- NULL
## filter data only for 1900 - 1945
GWstates_panel <- GWstates_panel%>% 
                       dplyr::filter(year >=1900 & year < 1946) 
## transform variable as integer
state.panel$year <- as.integer(state.panel$year)
## remove ISO3
GWstates_panel$ISO3 <- NULL

#####: prepare for merging
state.panel <- state.panel %>% 
               dplyr::select(year, ccode, country.name)
### Merge the data for the entire period of 1900 - 2015
hierarchypaperdata <- rbind(state.panel, GWstates_panel)

## add the COW country code
hierarchypaperdata$COWcode <- countrycode(hierarchypaperdata$country.name,
                                          "country.name", "cown")
## remove uncessary data from the workspace
rm(dt, GWstates, state.panel, GWstates_panel)
save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")

#############################################################################
# Step 2: Load VDED data to create dependent variable on women's empowerment
### VDEM version: V-Dem-DS-CY-v6.2
#############################################################################

###load vdem data
load("./raw_data/Country_Year_V-Dem_STATA_v6.2 2/V-Dem-DS-CY-v6.2.RData")
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
                    dplyr::select(COWcode, year, v2pepwrgen, v2x_gender,
                                  v2x_gencl, v2clslavef,v2clprptyw,
                                 v2x_gencs,v2x_genpp, v2cldiscw, v2clacjstw,
                                v2csgender,v2xel_frefair,v2xcs_ccsi)

## transform selected variable as numeric
vdem <- vdem %>% mutate_at(vars(COWcode, year, v2pepwrgen, v2x_gender,
                                v2x_gencl, v2clslavef,v2clprptyw,
                                v2x_gencs,v2x_genpp, v2cldiscw, v2clacjstw,
                                v2csgender,v2xel_frefair,v2xcs_ccsi), as.numeric)
## reanme variables
vdem <- vdem %>% 
       dplyr::rename(powerbygender = v2pepwrgen,
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
## remove vedem raw data
rm(vdem_raw)
save(vdem, file = "./clean_data/vdem.RData")
#############################################################################
# Step 3: Clean war related variables
#############################################################################

##### Major Power List
##get the major power dyads from COW
majorpower <- read_csv("./raw_data/majors2016.csv")
## select variables of interests only
majorpower <- majorpower %>% 
                     dplyr::select(stateabb, ccode, styear, endyear)
##expand it as time-series
majorpowe_yearly <- plyr::ddply(majorpower, 
                               .(stateabb,ccode,styear,endyear), function(x){
                                      data.frame(stateabb = x$stateabb,
                                                 ccode=x$ccode,
                                                 styear = x$styear,
                                                 endyear = x$endyear,
                                                 year = seq(x$styear, x$endyear))
                                })
save(majorpowe_yearly, file = "./clean_data/majorpowe_yearly.RData")  

####### Clean Interstate war and intrastate war

##### for years after 2003, we use UCDP data 
## Load COW's Interstate; Version: v4.0
cow_inter <- read.csv("./raw_data/Inter-StateWarData_v4.0.csv", header = TRUE)

##### The following code is to clean the COW war data
cow_inter <- cow_inter %>% 
              dplyr::mutate(StartDate1 = as.Date(as.character(paste(StartYear1,StartMonth1,StartDay1, sep ="-"))),
                     EndDate1 = as.Date(as.character(paste(EndYear1,EndMonth1,EndDay1, sep = "-"))),
                     StartDate2 =as.character(paste(StartYear2,StartMonth2,StartDay2, sep ="-")),
                     EndDate2 = as.character(paste(EndYear2,EndMonth2, EndDay2,sep = "-"))) 
## fix dates
cow_inter<- cow_inter %>%
              dplyr::mutate(StartDate2 = ifelse(StartDate2 =="-8--8--8", NA, StartDate2),
                            EndDate2 = ifelse(EndDate2 == "-8--8--8", NA, EndDate2)) %>% 
              dplyr::mutate(StartDate2 = as.Date(StartDate2),
                            EndDate2 = as.Date(EndDate2)) %>%
              dplyr::select(-StartYear1, -StartMonth1, -StartDay1,
                            -EndYear1, -EndMonth1, -EndDay1,
                            -StartYear2, -StartMonth2, -StartDay2,
                            -EndYear2, -EndMonth2, -EndDay2) 

## create length of wars
cow_inter<- cow_inter %>% 
              dplyr::mutate(WarDuration1 = as.integer(EndDate1 - StartDate1),
                                   WarDuration2 = as.integer(EndDate2 - StartDate2)) %>% 
              dplyr::mutate(StarYear1 = format(StartDate1, "%Y"),
                                   EndYear1 = format(EndDate1, "%Y"),
                                   StarYear2 = format(StartDate2, "%Y"),
                                   EndYear2 = format(EndDate2, "%Y"))

## convert COW Inter War into country-war-year data format 
cow_inter_yearly <- cow_inter %>%
                     dplyr::select(WarNum,WarName,ccode,StateName,Side,
                            WhereFought,Initiator, Outcome, BatDeath,
                            StartDate1,EndDate1, StartDate2, EndDate2, 
                            WarDuration1,WarDuration2, StarYear1,
                            EndYear1, StarYear2,EndYear2) %>%
                     dplyr::mutate(StarYear1 = as.integer(StarYear1),
                            EndYear1 = as.integer(EndYear1),
                            StarYear2 = as.integer(StarYear2),
                            EndYear2 = as.integer(EndYear2),
                            ccode = as.character(ccode))    

## filter 9 wars that recurred  
cow_inter_yearly2 <- cow_inter_yearly %>% 
                     dplyr::filter(!is.na(StarYear2) & !is.na(EndYear2)) %>%
                     dplyr::filter(EndYear1!=EndYear2)

## Make as panel data by country
cow_inter_yearly <- plyr::ddply(cow_inter_yearly, 
                                .(ccode,WarNum,StartDate1), function(x){
                                       data.frame(WarName = x$WarName,
                                                  WarNum = x$WarNum,
                                                  ccode=x$ccode,
                                                  StateName = x$StateName,
                                                  year=seq(x$StarYear1, x$EndYear1),
                                                  StarYear2=x$StarYear2,
                                                  EndYear2 = x$EndYear2,                                             
                                                  StartDate1=x$StartDate1,
                                                  EndDate1=x$EndDate1,
                                                  StartDate2=x$StartDate2,
                                                  EndDate2=x$EndDate2, 
                                                  Side = x$Side,
                                                  WhereFought = x$WhereFought,
                                                  Initiator=x$Initiator,
                                                  Outcome = x$Outcome,
                                                  BatDeath =x$BatDeath,
                                                  WarDuration1 =x$WarDuration1,
                                                  WarDuration2 = x$WarDuration2)
                                }
)  

## expand recurred subset                                             
cow_inter_yearly2 <- plyr::ddply(cow_inter_yearly2,
                                 .(ccode,WarNum,StartDate1), function(x){
                                        data.frame(WarName = x$WarName,
                                                   WarNum = x$WarNum,
                                                   ccode=x$ccode,
                                                   StateName = x$StateName,
                                                   year=seq(x$StarYear2, x$EndYear2),
                                                   StarYear2=x$StarYear2,
                                                   EndYear2 = x$EndYear2,                                             
                                                   StartDate1=x$StartDate1,
                                                   EndDate1=x$EndDate1,
                                                   StartDate2=x$StartDate2,
                                                   EndDate2=x$EndDate2, 
                                                   Side = x$Side,
                                                   WhereFought = x$WhereFought,
                                                   Initiator=x$Initiator,
                                                   Outcome = x$Outcome,
                                                   BatDeath =x$BatDeath,
                                                   WarDuration1 =x$WarDuration1,
                                                   WarDuration2 = x$WarDuration2)
                                 }
)                                               
## combine two data to get interstate war at a yearly level 
cow_inter_yearly <- rbind(cow_inter_yearly, cow_inter_yearly2) 
## remove duplicated row 
cow_inter_yearly <- unique(cow_inter_yearly)
# remove uncessary data for saving workspace
rm(cow_inter_yearly2)
save(cow_inter_yearly, file="./clean_data/cow_inter_yearly.RData") 

###create country-year-cow data
country_year_cow <- expand.grid(ccode=cow_inter_yearly$ccode, 
                                year = cow_inter_yearly$year) 
## convert cow country code as integer
country_year_cow$ccode <- as.integer(as.character(country_year_cow$ccode))

## create a dummy variable indicating interstate war in a given year for merge
cow_inter_yearly$inter_war <- 1
## only select variables of interest
cow_inter_yearly <- cow_inter_yearly %>%
                     select(WarName, WarNum, ccode, year, 
                     BatDeath,inter_war, WhereFought)

##check country code forma as integer for merge
cow_inter_yearly$ccode <- as.integer(as.character(cow_inter_yearly$ccode))

## merge to create country year war data
country_year_cow <- left_join(country_year_cow,cow_inter_yearly, by =c("ccode","year"))
#remove duplicates
country_year_cow <- unique(country_year_cow)
save(country_year_cow, file = "./clean_data/country_year_cow.RData")

## clean battel deaths resulting from war
###total battle death per year (Note: there are countries that were involved in multiple wars in a given year)
country_year_cow2 <- country_year_cow %>%
                     mutate(BatDeath = ifelse(BatDeath == -9, 0, BatDeath)) %>% 
                     mutate(BatDeath = ifelse(is.na(BatDeath), 0, BatDeath)) %>% 
                     mutate(inter_war = ifelse(is.na(inter_war), 0, inter_war)) # binary variable for inter state war

## aggregate to country-year-level
country_year_cow2.3 <- country_year_cow2 %>%
                     group_by(ccode, year) %>%
                     summarise(total_BatDeath = sum(BatDeath),
                               inter_war_total = sum(inter_war))

## Clean COW Intra-state war
###load COW intra-state war
cow_intra <- read.csv("./raw_data/COW_intra_war.csv")
## fix dates
cow_intra <- cow_intra %>% 
              dplyr::mutate(startmonth1 = ifelse(startmonth1 == -9, 1, startmonth1),
                            startday1 = ifelse(startday1 == -9, 1, startday1),
                            endmonth1 = ifelse(endmonth1 == -9, 12, endmonth1),
                            endday1 = ifelse(endday1 == -9, 28, endday1)) %>%
              dplyr::mutate(endmonth1 = ifelse(warnum == 940, 5,endmonth1), #sri lankan civil war end on May 18, 2009
                            endday1 = ifelse(warnum == 940, 18,endday1),
                            endyear1 = ifelse(warnum == 940, 2009, endyear1)) %>% 
              dplyr::mutate(endmonth1 = ifelse(warnum == 856, 12,endmonth1),
                            endday1 = ifelse(warnum == 856, 31,endday1),
                            endyear1 = ifelse(warnum == 856, 2012, endyear1)) ##Colombia FARC & Drug Lords end on 2 Feb 2016
## convert variable formats
cow_intra <- cow_intra %>% 
              mutate(StartDate1 = as.Date(as.character(paste(startyear1, startmonth1, startday1, sep ="-"))),
                     EndDate1 = as.Date(as.character(paste(endyear1, endmonth1, endday1, sep = "-"))),
                     StartDate2 =as.character(paste(startyear2, startmonth2, startday2, sep ="-")),
                     EndDate2 = as.character(paste(endyear2, endmonth2, endday2, sep = "-"))) 

## fix NA dates
cow_intra  <- cow_intra %>%
              mutate(StartDate2 = ifelse(StartDate2 =="-8--8--8", NA, StartDate2),
                     EndDate2 = ifelse(EndDate2 == "-8--8--8", NA, EndDate2)) %>% 
              mutate(StartDate2 = as.Date(StartDate2),
                     EndDate2 = as.Date(EndDate2)) 

## only keep 1900 onward
cow_intra <- cow_intra %>%
              dplyr::filter(endyear1 > 1899) %>% 
              dplyr::select(-startyear1, -startmonth1, -startday1,
                            -endyear1, -endmonth1, -endday1,
                            -startyear2, -startmonth2, -startday2,
                            -endyear2, -endmonth2, -endday2) 
###create length of wars
cow_intra<- cow_intra %>%
       mutate(WarDuration1 = as.integer(EndDate1 - StartDate1),
              WarDuration2 = as.integer(EndDate2 - StartDate2))    
## formatting date
cow_intra$StarYear1 <- format(cow_intra$StartDate1, "%Y")   
cow_intra$EndYear1 <- format(cow_intra$EndDate1, "%Y")    
cow_intra$StarYear2 <-format(cow_intra$StartDate2, "%Y")   
cow_intra$EndYear2 <- format(cow_intra$EndDate2, "%Y") 

##convert COW Intra-state War into country-war-year data  
cow_intra_yearly <- cow_intra %>%
                     select(warnum,warname,
                            wartype, ccodea,sidea,sideb,
                            wherefought,initiator, outcome,sideadeaths, sidebdeaths,
                            StartDate1,EndDate1, StartDate2, EndDate2, 
                            WarDuration1,WarDuration2, StarYear1,EndYear1,
                            StarYear2,EndYear2) %>%
                     mutate(StarYear1 = as.integer(StarYear1),
                            EndYear1 = as.integer(EndYear1),
                            StarYear2 = as.integer(StarYear2),
                            EndYear2 = as.integer(EndYear2),
                            ccodea = as.character(ccodea))   
# subset recurred intrastate war 
cow_intra_yearly2 <- cow_intra_yearly %>%
                     filter(!is.na(StarYear2) & !is.na(EndYear2)) %>%
                     filter(EndYear1!=EndYear2)
# make it as a time-series format
cow_intra_yearly <- plyr::ddply(cow_intra_yearly, 
                                .(ccodea,warnum,StartDate1), function(x){
                                      data.frame(warname = x$warname,
                                                 warnum = x$warnum,
                                                 ccodea=x$ccodea,
                                                 sidea = x$sidea,
                                                 sideb = x$sideb,
                                                 year=seq(x$StarYear1, x$EndYear1),
                                                 StarYear2=x$StarYear2,
                                                 EndYear2 = x$EndYear2,                                             
                                                 StartDate1=x$StartDate1,
                                                 EndDate1=x$EndDate1,
                                                 StartDate2=x$StartDate2,
                                                 EndDate2=x$EndDate2, 
                                                 wherefought = x$wherefought,
                                                 initiator=x$initiator,
                                                 outcome = x$outcome,
                                                 sideadeaths =x$sideadeaths,
                                                 sidebdeaths = x$sidebdeaths,
                                                 WarDuration1 =x$WarDuration1,
                                                 WarDuration2 = x$WarDuration2)
                                }
)  
###expand recurred subset as time-series 
cow_intra_yearly2 <- plyr::ddply(cow_intra_yearly2, 
                                 .(ccodea,warnum,StartDate1), function(x){
                                        data.frame(warname = x$warname,
                                                   warnum = x$warnum,
                                                   ccodea=x$ccodea,
                                                   sidea = x$sidea,
                                                   sideb = x$sideb,
                                                   year=seq(x$StarYear1, x$EndYear1),
                                                   StarYear2=x$StarYear2,
                                                   EndYear2 = x$EndYear2,                                             
                                                   StartDate1=x$StartDate1,
                                                   EndDate1=x$EndDate1,
                                                   StartDate2=x$StartDate2,
                                                   EndDate2=x$EndDate2, 
                                                   wherefought = x$wherefought,
                                                   initiator=x$initiator,
                                                   outcome = x$outcome,
                                                   sideadeaths =x$sideadeaths,
                                                   sidebdeaths = x$sidebdeaths,
                                                   WarDuration1 =x$WarDuration1,
                                                   WarDuration2 = x$WarDuration2)
                                 }
) 

####combine two data to create the intra-state war
cow_intra_yearly <- rbind(cow_intra_yearly, cow_intra_yearly2)    
##remove duplicated row
cow_intra_yearly <- unique(cow_intra_yearly)   
save(cow_intra_yearly, file="./clean_data/cow_intra_yearly.RData") 
#creat a dummy intra-state war 
cow_intra_yearly$intra_war <- 1
cow_intra_yearly <- cow_intra_yearly %>% 
                     select(warname, warnum, ccodea, year, sideadeaths, 
                            sidebdeaths,intra_war) 
###make it as country-year data
country_year_cow_intra <- expand.grid(ccodea=cow_intra_yearly$ccodea,
                                      year = cow_intra_yearly$year)      

##merge to get the full data
country_year_cow_intra <- left_join(country_year_cow_intra, cow_intra_yearly, by =c("ccodea","year"))
# remove duplicates
country_year_cow_intra <- unique(country_year_cow_intra)
## create death from intra-stat wars
###total battle death per year (Note: there are countries that were involved in multiple wars in a given year)
country_year_cow_intra <- country_year_cow_intra %>%
                     mutate(sideadeaths = ifelse(sideadeaths == -9, 0, sideadeaths),
                            sidebdeaths = ifelse(sidebdeaths == -9, 0, sidebdeaths)) %>% 
                     mutate(sideadeaths = ifelse(is.na(sideadeaths), 0, sideadeaths),
                            sidebdeaths = ifelse(is.na(sidebdeaths), 0, sidebdeaths),
                            intra_war = ifelse(is.na(intra_war), 0, intra_war))
# convert country code type
country_year_cow_intra$ccodea <- as.integer(as.character(country_year_cow_intra$ccodea))

##aggreate to country year level
country_year_cow_intra <- country_year_cow_intra %>%
                            group_by(ccodea, year) %>%
                            dplyr::summarise(total_sideadeaths = sum(sideadeaths),
                                             total_sidebdeaths = sum(sidebdeaths),
                                             intra_war_total = sum(intra_war))

#we do not have data after year 2007 from COW, so recode as zero
country_year_cow_intra <- country_year_cow_intra %>% 
              dplyr::mutate(total_sideadeaths = ifelse(is.na(total_sideadeaths) & year < 2008, 0, total_sideadeaths),
                     total_sidebdeaths = ifelse(is.na(total_sidebdeaths) & year < 2008, 0, total_sidebdeaths),
                     intra_war_total = ifelse(is.na(intra_war_total) & year < 2008, 0, intra_war_total)) 

country_year_cow_intra <- country_year_cow_intra %>% 
       mutate(total_intrawardeath = total_sideadeaths + total_sidebdeaths) %>% 
       select(-total_sideadeaths, -total_sidebdeaths)




##Because COW only covers from 1816-2007.we supplement inter and intra war with
## UCDP armed conflict data from 2004 to 2015
#get the battle deaths from UCDP
load("raw_data/ucdp-brd-conf-171.Rdata")
names(ucdp.brd.conf)
## subset for 2003- 2015
ucdp.brd.conf <- ucdp.brd.conf %>% 
                     select(ConflictID, BdBest, Year, GWNoA, GWNoA2nd,
                            GwNoB, GWNoB2nd) %>% 
                     filter(Year > 2003 & Year < 2016)

## load the UCDP armed conflict data 2017 version
load("./raw_data/ucdp-prio-acd-172.RData") #2017 version
names(ucdp.conf)

ucdp.conf <- subset(ucdp.conf, select = c(conflict_id, location, gwno_a, year,
                                          type_of_conflict))
## subset for 2003- 2015 for wars 
ucdp_interwar <- ucdp.conf %>%  
                     dplyr::filter(type_of_conflict ==2) %>% 
                     dplyr::filter(year > 2003 & year < 2016) %>% 
                     left_join(., ucdp.brd.conf, by =c("conflict_id" = "ConflictID",
                                                       "year" ="Year")) %>% 
                     select(year,BdBest, GWNoA, GwNoB)

#transform it from wide to long
new_interwar <- gather(ucdp_interwar, group, ccode, GWNoA:GwNoB, factor_key = TRUE) 
# creat dinary variable
new_interwar <- new_interwar %>% 
                     select(ccode, year, BdBest) %>% 
                     mutate(inter_war_total = 1) %>% 
                     dplyr::rename(total_BatDeath = BdBest) %>% 
                     mutate(ccode = as.integer(ccode))
## merge with the COW inter-state war (get wars between 2003-105)
country_year_cow2.3 <- bind_rows(country_year_cow2.3, new_interwar)
save(country_year_cow2.3, file="./clean_data/country_year_cow2.3.RData") 

## for civil wars between 2003-2015: supplement with UCDP 
ucdp_intrawar <- ucdp.conf %>%  
              dplyr::filter(type_of_conflict ==3) %>% 
              dplyr::filter(year > 2003 & year < 2016)%>% 
              left_join(., ucdp.brd.conf, by =c("conflict_id" = "ConflictID",
                                                "year" ="Year")) %>% 
              select(year, BdBest, GWNoA) %>% 
              dplyr::group_by(GWNoA, year) %>%
              dplyr::summarise(intra_war_total = n(),
                               total_BatDeath = sum(BdBest)) %>% 
              dplyr::ungroup() %>% 
              dplyr::rename(ccodea = GWNoA,
                            total_intrawardeath = total_BatDeath)
ucdp_intrawar$ccodea <- as.integer(as.character(ucdp_intrawar$ccodea))
## merge
country_year_cow_intra <- bind_rows(country_year_cow_intra, ucdp_intrawar)
save(country_year_cow_intra , file = "./clean_data/country_year_cow_intra.RData")


## Inter state war at homeland, between major power

######using COW inter-state data
load("./clean_data/cow_inter_yearly.RData")
names(cow_inter_yearly)
#using SQL
library(sqldf)

cow_inter_dyad <- sqldf("select WarNum, A.ccode ccode_A, B.ccode ccode_B,
                        A.StateName StateName_A,B.StateName StateName_B,
                        A.Side Side_A, B.Side Side_B, A.Initiator Initiator_A, B.Initiator Initiator_B,
                        A.BatDeath BatDeath_A, B.BatDeath BatDeath_B,
                        A.WhereFought WhereFought_A, B.WhereFought WhereFought_B
                        from cow_inter_yearly A join cow_inter_yearly B using (WarNum)
                        where A.ccode !=B.ccode and A.Side!=B.Side
                        order by A.ccode, B.ccode")
cow_data <- subset(cow_inter_yearly, select = c(WarNum, year))
## check duplicates
cow_data <- unique(cow_data)
## merge with the yearly data
cow_inter_dyad <- left_join(cow_inter_dyad, cow_data, by = c("WarNum"))
cow_inter_dyad$ccode_A <- as.integer(as.character(cow_inter_dyad$ccode_A))
cow_inter_dyad$ccode_B <- as.integer(as.character(cow_inter_dyad$ccode_B))

## load the contiguity data from COW Version 3.20
Contiguity <- read.csv("./raw_data/DirectContiguity320/contdird.csv")
names(Contiguity)
#subset the contiguity data
Contiguity <- subset(Contiguity, select = c(state1no, state2no, year, conttype))
# merge to indicate whether the warring parties are neighbors
cow_inter_dyad <- left_join(cow_inter_dyad, Contiguity, by = c("ccode_A" = "state1no",
                                                               "ccode_B" = "state2no",
                                                               "year" = "year"))
# binary variable to code dyad type
cow_inter_dyad <- cow_inter_dyad %>%
                     dplyr::mutate(conttype = ifelse(is.na(conttype), 0, conttype))
# remove duplicate
cow_inter_dyad <- unique(cow_inter_dyad)
save(cow_inter_dyad, file = "./clean_data/cow_inter_dyad.RData")

##homeland war and major power interstate war
load("./clean_data/majorpowe_yearly.RData")
load( "./clean_data/cow_inter_dyad.RData")
#subeset
cow_inter_dyad2 <- subset(cow_inter_dyad, select = c(year, ccode_A, ccode_B, conttype))
##Because COW only covers from 1816-2007. we supplement inter and intra war with UCDP armed conflict data from 2004 to 2015
load("./raw_data/ucdp-prio-acd-4-2016.RData")
ucdp_interwar <- ucdp.prio.acd  %>%
              dplyr::filter(TypeOfConflict ==2) %>%  dplyr::filter(Year > 2003)
head(cow_inter_dyad2)
# create inter-state way dyad
interwar2003 <- data.frame(year = c(2011, 2008, 2014, 2015, 2012),
                           ccode_A = c(811, 522,750,750,626),
                           ccode_B = c(800, 531, 770, 770, 625),
                           conttype = rep(1, 5))
interwar2003.2 <- data.frame(year = c(2011, 2008, 2014, 2015, 2012),
                             ccode_A = c(800, 531, 770, 770, 625),
                             ccode_B = c(811, 522,750,750,626),
                             conttype = rep(1, 5))
interwar2003 <- bind_rows(interwar2003, interwar2003.2)
#combined with interstate war after 2003
cow_inter_dyad2 <- bind_rows(cow_inter_dyad2, interwar2003)
#creat homeland war dummy if the war was fightign between neighbors
cow_inter_dyad2 <- cow_inter_dyad2 %>% 
                       dplyr::mutate(interwarhomeland = ifelse(conttype == 1, 1, 0))

##merg with major power data
majorpowe_A <- majorpowe_yearly %>%
                     dplyr::mutate(majorpwer_A = 1) %>% 
                     dplyr::select(ccode, year, majorpwer_A)

cow_inter_dyad2 <- left_join(cow_inter_dyad2, majorpowe_A, 
                             by = c("year" = "year", "ccode_A" = "ccode"))

majorpowe_B <- majorpowe_yearly %>%
                     dplyr::mutate(majorpwer_B = 1) %>% 
                     dplyr::select(ccode, year, majorpwer_B)
cow_inter_dyad2 <- left_join(cow_inter_dyad2, majorpowe_B, 
                             by = c("year" = "year", "ccode_B" = "ccode"))

cow_inter_dyad2 <- cow_inter_dyad2 %>%
              dplyr::mutate(majorpwer_A = ifelse(is.na(majorpwer_A), 0, majorpwer_A),
                            majorpwer_B = ifelse(is.na(majorpwer_B), 0, majorpwer_B))
## create variables for existential war
cow_inter_dyad2 <- cow_inter_dyad2 %>%
              dplyr::mutate(existentialwar_A = ifelse(interwarhomeland == 0 & majorpwer_A ==1 & majorpwer_B == 0, 0, 1),
                            existentialwar_B = ifelse(interwarhomeland == 0 & majorpwer_B ==1 & majorpwer_A == 0, 0, 1))
save(cow_inter_dyad2, file = "./clean_data/cow_inter_dyad2.RData") #existentialwar 


#############################################################################
# Step 4: Clean other related variables
#############################################################################

## CINC, 1816-2012
CINC <- read_csv("./raw_data/NMC_5_0.csv")
names(CINC)
#irst: Iron and steel production (thousands of tons)
#pec: Energy consumption (thousands of coal-ton equivalents)
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


########### WDI data
##### SP.POP.TOTL = population; SP.URB.TOTL = urban population
wdi <- WDI(country = "all", indicator = c("SP.URB.TOTL","SP.POP.TOTL"),     
           start = 2013, end = 2015, extra = FALSE, cache = NULL)
head(wdi)  
wdi$scode <-  countrycode(wdi$iso2c,"iso2c","iso3c")    
wdi$ccode <-  countrycode(wdi$iso2c,"iso2c","cown")    
##rename variable names 
wdi_urbanization <- wdi %>% filter(!is.na(ccode)) %>% 
                     mutate(WBupop = SP.URB.TOTL,
                            WBpop = SP.POP.TOTL) %>%
                     mutate(WB12_urbanization = (WBupop / WBpop)*100) %>% 
                     select(year, ccode, WB12_urbanization) %>% 
                     mutate_at(vars(ccode), as.numeric)
rm(wdi)
save(wdi_urbanization, file = "./clean_data/wdi_urbanization.RData")

## WDI for populaton, et al
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
wdi$scode <- countrycode(wdi$iso2c,"iso2c","iso3c")    
wdi$ccode <- countrycode(wdi$iso2c,"iso2c","cown")    

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


#### Using the Contiguity from COW because of the wide coverage (1916-2016)
#version 3.2
ContiguityNum <- read_csv("./raw_data/DirectContiguity320/contdirs.csv")
ContiguityNum <- subset(ContiguityNum, select =c(stateno, year, total, land, sea))
# rename variables
names(ContiguityNum) <- c("COWcode", "year", "total.neighbors",
                          "land.neighbors", "sea.neighbors")
save(ContiguityNum, file = "./clean_data/ContiguityNum.RData")

###Merge Polity data: version 2015
polity <- read.spss("./raw_data/p4v2015.sav", to.data.frame=TRUE)
polity <- polity %>%
               select(ccode, year, polity, polity2) 
save(polity, file = "./clean_data/polity.RData")

####read Archigos irregular leadership exits,
archigos_yearly <- read.delim("./raw_data/arch_annual.txt", header = T)
# clean 
archigos_yearly  <- archigos_yearly %>%
                     select(ccode, idacr, leader, startdate, enddate,
                            entry, exit, exitcode) %>% 
                     mutate_at(vars(-ccode), as.character) %>% 
                     mutate(year = substr(.$startdate, 1, 4))
## create binary
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

########### CNTS data: Banks's data
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



#############################################################################
# Step 5: merge all IV
#############################################################################

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


#############################################################################
# Step 6: creat neighboring wars
#############################################################################

load("./clean_data/hierarchypaperdata.RData")
## create binary variabls for inter-state and intra-state wars
hierarchypaperdata <- hierarchypaperdata %>% 
              dplyr::mutate(inter_war_total = ifelse(is.na(inter_war_total), 0, inter_war_total),
                            intra_war_total = ifelse(is.na(intra_war_total), 0, intra_war_total)) %>% 
              dplyr::mutate(inter_warDummy = ifelse(inter_war_total >0,1,0),
                            intra_warDummy = ifelse(intra_war_total >0,1,0)) %>% 
              dplyr::mutate(warDummy = ifelse(inter_warDummy == 0 & intra_war_total == 0, 0, 1))

#### load inter-state war dyads
load("./clean_data/cow_inter_dyad2.RData")
##  neigboring war (not with the country in questions)
cow_inter_dyad2 <- cow_inter_dyad2 %>%
                       filter(conttype == 0)
#aggregate to country level
cow_inter <- cow_inter_dyad2 %>%
                     dplyr::group_by(year, ccode_A) %>% 
                     dplyr::summarise(interstate_warNonneigh = n())
# only for 1900- 2015
cow_inter <- cow_inter %>% 
       dplyr::filter(year >= 1900)
## merge with base data
hierarchypaperdata <- left_join(hierarchypaperdata, cow_inter, by = c("ccode" = "ccode_A",
                                                                      "year" = "year"))
## creat dinary variables to indicate whether wars with neighbors 
hierarchypaperdata <- hierarchypaperdata %>% 
                     dplyr::mutate(interstate_warNonneigh = ifelse(is.na(interstate_warNonneigh), 0, interstate_warNonneigh)) %>% 
                     dplyr::mutate(interstate_warNonneigh_dummy = ifelse(interstate_warNonneigh > 0, 1, 0))
#check duplicates
hierarchypaperdata <- hierarchypaperdata %>%
              dplyr::group_by(ccode, year) %>% 
              dplyr::mutate(dup = n(),
                            cum = cumsum(dup)) %>% 
              dplyr::filter(dup == cum) %>% 
              select(-dup, -cum)

##### use for loop to create neighboring interestate wars 
##interstate war in neighbors (not with neighbor in question)
Contiguity <- read.csv("./raw_data/DirectContiguity320/contdird.csv")
names(Contiguity)
library(Matrix)
year <- c('1900':'2015')
year <- as.character(year)
contiguousinterwar1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"interstate_warNonneigh_dummy"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousinterwar <- m %*% war
       contiguousinterwar1[[i]] <- data.frame(contiguousinterwar) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousinterwar = do.call(rbind, contiguousinterwar1)

contiguousinterwar$COWcode <- as.integer(contiguousinterwar$COWcode)
contiguousinterwar$year <- as.numeric(contiguousinterwar$year)
contiguousinterwar <- dplyr::rename(contiguousinterwar, 
                                    neighboringInterStateWar_excluded = interstate_warNonneigh_dummy)
##interstate war in neighbors (not with neighbor in question)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousinterwar, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboringInterStateWar_excludedDummy = ifelse(neighboringInterStateWar_excluded > 0, 1, 0))

###for existential war
load("./clean_data/cow_inter_dyad2.RData")
## aggregate and subset
cow_existentialwar <- cow_inter_dyad2 %>% 
                     dplyr::group_by(year, ccode_A) %>% 
                     dplyr::summarise(existentialwar = sum(existentialwar_A)) %>% 
                     dplyr::filter(year >= 1900)
## merge
hierarchypaperdata <- left_join(hierarchypaperdata, cow_existentialwar, by = c("COWcode"= "ccode_A", "year"))
## create binary exitential war
hierarchypaperdata  <- hierarchypaperdata  %>% 
              mutate(existentialwar = ifelse(is.na(existentialwar), 0, existentialwar)) %>% 
              mutate(existentialwardum = ifelse(existentialwar>0, 1, 0))

##neighboring war (any war)
year <- c('1900':'2015')
year <- as.character(year)
contiguouswar1 <- list()
for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM,matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       row.names(war) <- matchM
       war <- war[,"warDummy"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguouswar <- m %*% war
       contiguouswar1[[i]] <- data.frame(contiguouswar) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguouswarlist = do.call(rbind, contiguouswar1)
contiguouswarlist$COWcode <- as.integer(contiguouswarlist$COWcode)
contiguouswarlist$year <- as.numeric(contiguouswarlist$year)
contiguouswarlist <- dplyr::rename(contiguouswarlist, 
                                   neighboringWar = warDummy)
##interstate war in neighbors (not with neighbor in question)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguouswarlist, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboringWar_Dummy = ifelse(neighboringWar > 0, 1, 0))


####### define a major war 
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(total_BatDeath = ifelse(is.na(total_BatDeath), 0, total_BatDeath)) %>% 
       dplyr::mutate(majorWar = ifelse(total_BatDeath >50000 & warDummy ==1, 1, 0))

#####Major war in neighboring states
contiguousMajorwar1 <- list()
for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM,matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       row.names(war) <- matchM
       war <- war[,"majorWar"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousMajorwar <- m %*% war
       contiguousMajorwar1[[i]] <- data.frame(contiguousMajorwar) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousMajorwar = do.call(rbind, contiguousMajorwar1)
contiguousMajorwar$COWcode <- as.integer(contiguousMajorwar$COWcode)
contiguousMajorwar$year <- as.numeric(contiguousMajorwar$year)
contiguousMajorwar <- dplyr::rename(contiguousMajorwar, 
                                    neighboringmajorWar = majorWar)
##major war in neighbors (not with neighbor in question)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousMajorwar, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboringmajorWar_Dummy = ifelse(neighboringmajorWar > 0, 1, 0))

##Civil war in neighbors
contiguousintrawar1 <- list()
for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM,matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       row.names(war) <- matchM
       war <- war[,"intra_warDummy"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousintrawar <- m %*% war
       contiguousintrawar1[[i]] <- data.frame(contiguousintrawar) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousintrawar = do.call(rbind, contiguousintrawar1)
contiguousintrawar$COWcode <- as.integer(contiguousintrawar$COWcode)
contiguousintrawar$year <- as.numeric(contiguousintrawar$year)
contiguousintrawar <- dplyr::rename(contiguousintrawar, neighboringcivilwar = intra_warDummy)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousintrawar, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboringcivilwar_Dummy = ifelse(neighboringcivilwar > 0, 1, 0))

##interstate war in neighbors
contiguousinterwar1 <- list()
for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM,matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       row.names(war) <- matchM
       war <- war[,"inter_warDummy"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousinterwar <- m %*% war
       contiguousinterwar1[[i]] <- data.frame(contiguousinterwar) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousinterwar = do.call(rbind, contiguousinterwar1)
contiguousinterwar$COWcode <- as.integer(contiguousinterwar$COWcode)
contiguousinterwar$year <- as.numeric(contiguousinterwar$year)
contiguousinterwar <- dplyr::rename(contiguousinterwar,
                                    neighboringInterStateWar = inter_warDummy)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousinterwar, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboringInterStateWar_Dummy = ifelse(neighboringInterStateWar > 0, 1, 0))


#####add variable: years since last last**majorwar** (peace years)
#http://stackoverflow.com/questions/26553638/calculate-elapsed-time-since-last-event

##peace year since last interstate war
hierarchypaperdata <- hierarchypaperdata %>%  
              dplyr::arrange(ccode, year) %>% 
              dplyr::group_by(ccode) %>%
              dplyr::mutate(tmpG = cumsum(c(FALSE, as.logical(diff(inter_warDummy))))) %>%
              arrange(ccode, year) %>% 
              dplyr::group_by(ccode) %>%
              dplyr::mutate(tmp_a = c(0, diff(year)) * !inter_warDummy) %>%
              dplyr::group_by(ccode, tmpG) %>%
              dplyr::mutate(peaceyrs_interwar = cumsum(tmp_a)) %>%
              dplyr::ungroup() %>%
              dplyr::select(-c(tmp_a, tmpG))


###peace year since last intra-state war
hierarchypaperdata <- hierarchypaperdata %>% 
                     dplyr::arrange(ccode, year) %>% 
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmpG = cumsum(c(FALSE, as.logical(diff(intra_warDummy))))) %>%
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmp_a = c(0, diff(year)) * !intra_warDummy) %>%
                     dplyr::group_by(ccode,tmpG) %>%
                     dplyr::mutate(peaceyrs_intrawar = cumsum(tmp_a)) %>%
                     dplyr::ungroup() %>%
                     dplyr::select(-c(tmp_a, tmpG))

###year since last war
hierarchypaperdata <- hierarchypaperdata %>% 
                     dplyr::arrange(ccode, year) %>% 
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmpG = cumsum(c(FALSE, as.logical(diff(warDummy))))) %>%
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmp_a = c(0, diff(year)) * !warDummy) %>%
                     dplyr::group_by(ccode,tmpG) %>%
                     dplyr::mutate(peaceyrs_war = cumsum(tmp_a)) %>%
                     dplyr::ungroup() %>%
                     dplyr::select(-c(tmp_a, tmpG))

###years since last major war
hierarchypaperdata <- hierarchypaperdata %>% 
                     dplyr::arrange(ccode, year) %>% 
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmpG = cumsum(c(FALSE, as.logical(diff(majorWar))))) %>%
                     dplyr::group_by(ccode) %>%
                     dplyr::mutate(tmp_a = c(0, diff(year)) * !majorWar) %>%
                     dplyr::group_by(ccode,tmpG) %>%
                     dplyr::mutate(peaceyrs_majorwar = cumsum(tmp_a)) %>%
                     dplyr::ungroup() %>%
                     dplyr::select(-c(tmp_a, tmpG))

save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")


#############################################################################
# Step 7: creat neighboring instability variables
#############################################################################

load("./clean_data/hierarchypaperdata.RData")
load("./clean_data/cntsdata2014.RData")

#check duplicates
cntsdata2014 <- cntsdata2014 %>%
       dplyr::group_by(ccode, year) %>% 
       dplyr::mutate(dup = n(),
                     cum = cumsum(dup)) %>% 
       dplyr::filter(dup == cum) %>% select(-dup, -cum)

## merge with CNTS
hierarchypaperdata <- left_join(hierarchypaperdata, cntsdata2014, 
                                by = c("COWcode" = "ccode", "year"))


##strike in neighbors (not with neighbor in question)
Contiguity <- read.csv("./raw_data/DirectContiguity320/contdird.csv")
names(Contiguity)
library(Matrix)
year <- c('1900':'2013')
year <- as.character(year)
contiguousinterstriks1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"striks"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousinterstriks <- m %*% war
       contiguousinterstriks1[[i]] <- data.frame(contiguousinterstriks) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousinterstriks= do.call(rbind, contiguousinterstriks1)

contiguousinterstriks$COWcode <- as.integer(contiguousinterstriks$COWcode)
contiguousinterstriks$year <- as.numeric(contiguousinterstriks$year)
contiguousinterstriks <- dplyr::rename(contiguousinterstriks, 
                                       neighboringstriks = striks)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousinterstriks, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate( neighboringstriks_Dummy = ifelse( neighboringstriks > 0 &year < 2014, 1, 0))

## government crisis in neighboring states
contiguousintergov_crises1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"gov_crises"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousintergov_crises <- m %*% war
       contiguousintergov_crises1[[i]] <- data.frame(contiguousintergov_crises) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousintergov_crises= do.call(rbind, contiguousintergov_crises1)
contiguousintergov_crises$COWcode <- as.integer(contiguousintergov_crises$COWcode)
contiguousintergov_crises$year <- as.numeric(contiguousintergov_crises$year)
contiguousintergov_crises <- dplyr::rename(contiguousintergov_crises, 
                                           neighboringgov_crises = gov_crises)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousintergov_crises, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate( neighboringgov_crises_Dummy = ifelse( neighboringgov_crises > 0 &year < 2014, 1, 0))


## riots in neighboring states
contiguousinter_riots1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"riots"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousinter_riots <- m %*% war
       contiguousinter_riots1[[i]] <- data.frame(contiguousinter_riots) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

contiguousinter_riots= do.call(rbind, contiguousinter_riots1)
contiguousinter_riots$COWcode <- as.integer(contiguousinter_riots$COWcode)
contiguousinter_riots$year <- as.numeric(contiguousinter_riots$year)
contiguousinter_riots <- dplyr::rename(contiguousinter_riots, 
                                       neighboring_riots = riots)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousinter_riots, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate( neighboring_riots_Dummy = ifelse( neighboring_riots > 0 &year < 2014, 1, 0))

###demonstration in neighboring states
contiguousinter_demonstration1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L")
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"demonstration"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       contiguousinter_demonstration <- m %*% war
       contiguousinter_demonstration1[[i]] <- data.frame(contiguousinter_demonstration) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       
contiguousinter_demonstration= do.call(rbind, contiguousinter_demonstration1)
contiguousinter_demonstration$COWcode <- as.integer(contiguousinter_demonstration$COWcode)
contiguousinter_demonstration$year <- as.numeric(contiguousinter_demonstration$year)
contiguousinter_demonstration <- dplyr::rename(contiguousinter_demonstration, 
                                               neighboring_demonstration = demonstration)
hierarchypaperdata <- left_join(hierarchypaperdata, contiguousinter_demonstration, by = c("COWcode", "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(neighboring_demonstration_Dummy = ifelse( neighboring_demonstration > 0 &year < 2014, 1, 0))
save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")


#############################################################################
# Step 8: Recode and write to stata
#############################################################################

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
## population of WDI
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(lWBmalepop = log(WBmalepop),
                     lWBfepop = log(WBfepop),
                     lWBmalepop1564 = log(WBmalepop1564),
                     lWBfepop1564 = log(WBfepop1564))
##write to stata
##change some variable names to keep consistent with stata
hierarchypaperdata <- hierarchypaperdata %>% 
              dplyr::rename(country_name = country.name, 
                            total_neighbors = total.neighbors,
                            land_neighbors = land.neighbors,
                            sea_neighbors = sea.neighbors,
                            neighboringInterStateWar_excldd = neighboringInterStateWar_excluded,
                            neighboringInterSttWr_xclddDmmy = neighboringInterStateWar_excludedDummy)
write_dta(hierarchypaperdata, "./clean_data/hierarchypaperdata.dta")


#############################################################################
# Step 9:  add spatial lags for DV``
#############################################################################
hierarchypaperdata <- read.dta13("./clean_data/hierarchypaperdata.dta")

## political empowerment in neighboring states
Contiguity <- read.csv("./raw_data/DirectContiguity320/contdird.csv")
names(Contiguity)
library(Matrix)
year <- c('1900':'2015')
year <- as.character(year)
polempowerment1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L" )
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       # Create a row-standardized weights matrix
       m <- m/apply(m, 1 , sum)
       ###replace NA with 0 in row-standardized matrix
       m <- ifelse(is.na(m), 0, m)
       
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"polempowerment"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       polempowerment <- m %*% war
       polempowerment1[[i]] <- data.frame(polempowerment) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

polempowerment = do.call(rbind, polempowerment1)
polempowerment$COWcode <- as.integer(polempowerment$COWcode)
polempowerment$year <- as.numeric(polempowerment$year)
polempowerment <- dplyr::rename(polempowerment, 
                                neighborpolempowerment = polempowerment)

## Fertility in neighboring states
######## #WBfertility1: spatial lag
year <- c('1900':'2015')
year <- as.character(year)
WBfertility1 <- list()

for (i in 1:length(year)){
       contiguity <- Contiguity %>% dplyr::filter(year == year[i]) %>%
              dplyr::mutate(conttype = ifelse(conttype ==1, 1, 0)) %>% 
              dplyr::select(state1no, state2no, conttype) %>% 
              dplyr::mutate(state1no = as.character(state1no),
                            state2no = as.character(state2no))
       
       r <- sort(unique(c(contiguity$state1no,contiguity$state2no)))
       f1 <- as.numeric(factor(contiguity$state1no,levels=r))
       f2 <- as.numeric(factor(contiguity$state2no,levels=r))
       m <- Matrix(0,nrow=length(r),ncol=length(r),dimnames=list(r,r))
       m[cbind(f1,f2)] <- contiguity$conttype
       m <-  forceSymmetric(m,uplo="L" )
       m <-  as.matrix(m)   
       
       indexM <- hierarchypaperdata$COWcode[hierarchypaperdata$year==year[i]]
       indexM <- as.character(indexM)
       matchM <- intersect(indexM, rownames(m))
       m <- m[matchM, matchM]
       # Create a row-standardized weights matrix
       m <- m/apply(m, 1 , sum)
       ###replace NA with 0 in row-standardized matrix
       m <- ifelse(is.na(m), 0, m)
       
       war <- hierarchypaperdata[hierarchypaperdata$year==year[i],]
       war$COWcode <- as.character(war$COWcode)
       war <- war[which(war$COWcode %in% matchM),]
       war <- war[,"WBfertility"]
       war <- as.matrix(war)
       war <- ifelse(is.na(war), 0, war)
       WBfertility <- m %*% war
       WBfertility1[[i]] <- data.frame(WBfertility) %>% 
              dplyr::mutate(year = year[i],
                            COWcode = matchM) %>% 
              dplyr::as_data_frame()
}       

WBfertility = do.call(rbind, WBfertility1)
WBfertility$COWcode <- as.integer(WBfertility$COWcode)
WBfertility$year <- as.numeric(WBfertility$year)
WBfertility <- dplyr::rename(WBfertility, 
                             neighborWBfertility = WBfertility)
WBfertility <- WBfertility %>% filter(year > 1959)
##merge spatial lag
spatial_lag <- left_join(polempowerment, WBfertility, by = c("COWcode", "year"))


##add infant mortality Mortality rate, infant (per 1,000 live births)

infantmortality <- WDI(country = "all", indicator = c("SP.DYN.IMRT.IN"),     
                       start = 1960, end = 2015, extra = FALSE, cache = NULL)
infantmortality$ccode <-  countrycode(infantmortality$iso2c,"iso2c","cown")    
###rename variable names 
infantmortality <- infantmortality %>%
              filter(!is.na(ccode)) %>% 
              mutate(WBinfantmortality = SP.DYN.IMRT.IN) %>%
              mutate_at(vars(ccode), as.numeric) %>% 
              select(ccode, year, WBinfantmortality)
#merge all
spatial_lag <- left_join(spatial_lag, infantmortality, by = c("COWcode" = "ccode",
                                                              "year" ="year"))
save(spatial_lag, file = "./clean_data/spatial_lag.RData")
## merge with the main data
hierarchypaperdata <- left_join(hierarchypaperdata, spatial_lag, by = c("COWcode", "year"))
write_dta(hierarchypaperdata, "./clean_data/hierarchypaperdata.dta")


## use UCDP/PRIO battle death
prio_battle <- read_xls("raw_data/PRIO Battle Deaths Dataset 3.1.xls")
prio_battles <- prio_battle %>% 
                select(id, year, bdeadlow, bdeadhig, bdeadbes, gwnoloc, location)
#split gown locations into multiple rows
prio_battles <- prio_battles %>% 
              dplyr::mutate(gwnoloc = strsplit(as.character(gwnoloc), ","),
                            mean = bdeadlow + bdeadhig) %>% 
              dplyr::mutate(mean = round(mean/2,0)) %>% 
              tidyr::unnest(gwnoloc) 
##remove white space
prio_battles$gwnoloc <- str_trim(prio_battles$gwnoloc)
prio_battles$gwnoloc <- as.numeric(prio_battles$gwnoloc)
prio_battles <- prio_battles %>% 
                     filter(gwnoloc!=-99) %>% 
                     dplyr::mutate(bdeadbes = ifelse(bdeadbes == -999, mean, bdeadbes)) %>% 
                     select(id, year,bdeadbes, gwnoloc) %>% 
                     group_by(gwnoloc, year) %>% 
                     dplyr::summarise(ucdp_deaths = sum(bdeadbes)) %>% 
                     ungroup()
save(prio_battles, file = "./clean_data/prio_battles.RData")

hierarchypaperdata <- left_join(hierarchypaperdata, prio_battles, by = c("ccode" = "gwnoloc","year" = "year"))
hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(ucdp_deaths = ifelse(year >1945 & year< 2009 & is.na(ucdp_deaths), 0, ucdp_deaths))
hierarchypaperdata <- hierarchypaperdata  %>% 
       mutate(wardeaths = ucdp_deaths + total_BatDeath )

write_dta(hierarchypaperdata, "./clean_data/hierarchypaperdata.dta")



sessionInfo()
