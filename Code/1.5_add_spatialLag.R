rm(list = ls())
library(rgdal)
library(maptools)
library(ggplot2)
library(countrycode)
library(dplyr)
library(scales)
library(ggmap)
library(cshapes)
library(readr)
library(readstata13)
hierarchypaperdata <- read.dta13("./clean_data/hierarchypaperdata.dta")

##interstate war in neighbors (not with neighbor in question)
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


#WBfertility1: spatial lag
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


## add infant mortality Mortality rate, infant (per 1,000 live births)

library(WDI)
infantmortality <- WDI(country = "all", indicator = c("SP.DYN.IMRT.IN"),     
           start = 1960, end = 2015, extra = FALSE, cache = NULL)
library(countrycode)
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

hierarchypaperdata <- left_join(hierarchypaperdata, spatial_lag, by = c("COWcode", "year"))

hierarchypaperdata <- hierarchypaperdata  %>% 
                     mutate(wardeaths = total_intrawardeath + total_BatDeath )
#hierarchypaperdata <- hierarchypaperdata %>% 
#                     mutate(neighborpolempowerment = ifelse(neighborpolempowerment==0,NA, neighborpolempowerment),
#                            neighborWBfertility = ifelse(neighborWBfertility == 0, NA, neighborWBfertility))
library(haven)
write_dta(hierarchypaperdata, "./clean_data/hierarchypaperdata.dta")
#hierarchypaperdata <- hierarchypaperdata[,1:98]

## use UCDP/PRIO battle death
library(readxl)
prio_battle <- read_xls("raw_data/PRIO Battle Deaths Dataset 3.1.xls")
prio_battles <- prio_battle %>% 
                     select(id, year, bdeadlow, bdeadhig, bdeadbes, gwnoloc, location)
#split gown locations into multiple rows
library(tidyr)
prio_battles <- prio_battles %>% 
               dplyr::mutate(gwnoloc = strsplit(as.character(gwnoloc), ","),
                             mean = bdeadlow + bdeadhig) %>% 
              dplyr::mutate(mean = round(mean/2,0)) %>% 
               tidyr::unnest(gwnoloc) 
##remove white space
library(stringr)
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

                                