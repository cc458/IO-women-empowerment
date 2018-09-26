rm(list = ls())
#load Andreas Beger's function to create country-year data frame
source("./Code/R_function_for_state_panel.R")
####creat state panel data frame from 1946 to 2015
state.panel <- state_panel("1946", "2015", by="year")


##create country.name
library(countrycode)
library(dplyr)
state.panel$country.name <- countrycode(state.panel$ccode,"cown","country.name")


###create year 
state.panel$year <- format(state.panel$date,format="%Y")
head(state.panel)
table(state.panel$year)

###read Gleditsch& ward country list
GWstates <- read.delim2("./raw_data/iisystem.dat", header = F, sep = "\t")
#rename
names(GWstates) <- c("ccode", "ISO3", "country.name", "start.date", "end.date")
GWstates <- GWstates %>% 
       dplyr::mutate_at(vars(ISO3, country.name,
                             start.date, end.date), as.character)

GWstates$start.year <- as.integer(substr(GWstates$start.date, 7, 10))
GWstates$end.year <- as.integer(substr(GWstates$end.date, 7, 10))
save(GWstates, file = "./clean_data/GWstates.RData")
GWstates <- GWstates %>% 
       dplyr::filter(end.year >= 1900) %>% 
       dplyr::group_by(ccode) %>%
       dplyr::mutate(dup = n(), cum = cumsum(dup))

GWstates$ccodeID <- paste(GWstates$ccode, GWstates$cum, sep="-")

library(plyr)
library(data.table)
dt <- data.table(GWstates)
#make it as a panel data format
GWstates_panel <- dt[, list(year = seq(start.year, end.year)), by = ccodeID]
GWstates <- subset(GWstates, select = c(ccode, ISO3, country.name, ccodeID))

##merge
GWstates_panel <- left_join(GWstates_panel, GWstates, by = "ccodeID")
GWstates_panel$ccodeID <- NULL

GWstates_panel <- GWstates_panel%>% 
                     dplyr::filter(year >=1900 & year < 1946) 

state.panel$year <- as.integer(state.panel$year)

GWstates_panel$ISO3 <- NULL

state.panel <- state.panel %>% 
       select(year, ccode, country.name)

hierarchypaperdata <- rbind(state.panel, GWstates_panel)
##add COW code
library(countrycode)wo
hierarchypaperdata$COWcode <- countrycode(hierarchypaperdata$country.name, "country.name", "cown")

save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")


