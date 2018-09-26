rm(list = ls())
## libraries
library(foreign)
library(dplyr)
library(plyr)
library(reshape2)
library(readr)

##major power dyads
majorpower <- read_csv("./raw_data/majors2016.csv")
majorpower <- majorpower %>% 
       select(stateabb, ccode, styear, endyear)
##expand to time-series
library(plyr)
majorpowe_yearly <- plyr::ddply(majorpower, 
                                .(stateabb,ccode,styear,endyear), function(x){
                                       data.frame(stateabb = x$stateabb,
                                                  ccode=x$ccode,
                                                  styear = x$styear,
                                                  endyear = x$endyear,
                                                  year = seq(x$styear, x$endyear))
                                })
save(majorpowe_yearly, file = "./clean_data/majorpowe_yearly.RData")  


##interstate war and intrastate war
# for years after 2003, we use UCDP data 
cow_inter <- read.csv("./raw_data/Inter-StateWarData_v4.0.csv", header = TRUE)

###read inter-state war data from COW
cow_inter<- cow_inter %>% 
       mutate(StartDate1 = as.Date(as.character(paste(StartYear1, StartMonth1, StartDay1, sep ="-"))),
             EndDate1 = as.Date(as.character(paste(EndYear1, EndMonth1, EndDay1, sep = "-"))),
             StartDate2 =as.character(paste(StartYear2, StartMonth2, StartDay2, sep ="-")),
             EndDate2 = as.character(paste(EndYear2, EndMonth2, EndDay2, sep = "-"))) 

cow_inter<- cow_inter %>%
       mutate(StartDate2 = ifelse(StartDate2 =="-8--8--8", NA, StartDate2),
              EndDate2 = ifelse(EndDate2 == "-8--8--8", NA, EndDate2)) %>% 
       mutate(StartDate2 = as.Date(StartDate2),
              EndDate2 = as.Date(EndDate2)) %>%
       select(-StartYear1, -StartMonth1, -StartDay1,
             -EndYear1, -EndMonth1, -EndDay1,
              -StartYear2, -StartMonth2, -StartDay2,
              -EndYear2, -EndMonth2, -EndDay2) 


###create length of wars
cow_inter<- cow_inter %>% 
              mutate(WarDuration1 = as.integer(EndDate1 - StartDate1),
                   WarDuration2 = as.integer(EndDate2 - StartDate2)) %>% 
              mutate(StarYear1 = format(StartDate1, "%Y"),
                     EndYear1 = format(EndDate1, "%Y"),
                     StarYear2 = format(StartDate2, "%Y"),
                     EndYear2 = format(EndDate2, "%Y"))
       
##convert COW Inter War into country-war-year data  
cow_inter_yearly <- cow_inter %>%
                   select(WarNum,WarName,ccode,StateName,Side,
                            WhereFought,Initiator, Outcome, BatDeath,
                            StartDate1,EndDate1, StartDate2, EndDate2, 
                            WarDuration1,WarDuration2, StarYear1,
                          EndYear1, StarYear2,EndYear2) %>%
                     mutate(StarYear1 = as.integer(StarYear1),
                             EndYear1 = as.integer(EndYear1),
                             StarYear2 = as.integer(StarYear2),
                             EndYear2 = as.integer(EndYear2),
                            ccode = as.character(ccode))    

##filter 9 wars recurred  
cow_inter_yearly2 <- cow_inter_yearly %>% 
                     filter(!is.na(StarYear2) & !is.na(EndYear2)) %>%
                     filter(EndYear1!=EndYear2)
##fun the following twice
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

###expand recurred subset                                             
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
####combine two data
cow_inter_yearly <- rbind(cow_inter_yearly, cow_inter_yearly2)  
rm(cow_inter_yearly2)
cow_inter_yearly <- unique(cow_inter_yearly )##remove duplicated row    
save(cow_inter_yearly, file="./clean_data/cow_inter_yearly.RData") 

###convert to country-year-cow data
#####country-year data
country_year_cow <- expand.grid(ccode=cow_inter_yearly$ccode, 
                                year = cow_inter_yearly$year) 

country_year_cow$ccode <- as.integer(as.character(country_year_cow$ccode))
#create a dummy variable indicating interstate war in a given year
cow_inter_yearly$inter_war <- 1
cow_inter_yearly <- cow_inter_yearly %>%
              select(WarName, WarNum, ccode, year, 
                     BatDeath,inter_war, WhereFought) # %>% filter(year >= 1940)

##merge
cow_inter_yearly$ccode <- as.integer(as.character(cow_inter_yearly$ccode))

country_year_cow <- left_join(country_year_cow,cow_inter_yearly, by =c("ccode","year"))
#remove duplicates
country_year_cow <- unique(country_year_cow)
save(country_year_cow, file = "./clean_data/country_year_cow.RData")

###total battle death per year (Note: there are countries that were involved in multiple wars in a given year)
country_year_cow2 <- country_year_cow %>%
       mutate(BatDeath = ifelse(BatDeath == -9, 0, BatDeath)) %>% 
       mutate(BatDeath = ifelse(is.na(BatDeath), 0, BatDeath))
   
country_year_cow2  <- country_year_cow2 %>%
       dplyr::mutate(inter_war = ifelse(is.na(inter_war), 0, inter_war))
##aggregate to country-year-level
country_year_cow2.3 <- country_year_cow2 %>%
                     group_by(ccode, year) %>%
                    summarise(total_BatDeath = sum(BatDeath),
                            inter_war_total = sum(inter_war))


ucdp_intra <- read.csv("./raw_data/ucdp_IntrastateConflict.csv", header = TRUE)

### Intra-state war data from UCDP
### Note that there are two different versions of the UCDP Monadic Conflict Onset and Incidence Dataset.
### The data loaded here is the conflict level, not dyad level.
### From the codebook, this is the difference: 
### Two versions of the data exist, one containing conflict level variables and one containing dyad version
### datasets.
### The difference between the two is that the conflict level data treats all variables at UCDP conflict level,
### whereas the dyad level treats all variables at the UCDP conflict dyad level.
### For example, in the conflict level edition, nototconfv414 will record a 1 for entry 700 (Afghanistan) in
### 1991, since the only UCDP Conflict active is the Afghanistan: government.
### However, the same variable in the dyad-level edition will record a 4 for entry for entry 700 (Afghanistan) in
### 1991, since four UCDP conflict dyads (i.e. four non-state actors challenging the government) are involved
### in the UCDP conflict (Jam'iyyat-i Islami-yi Afghanistan, Hizb-i Islami-yi Afghanistan, Hizb-i
### Wahdat, Hizb-i Islami-yi Afghanistan - Khalis faction).

colnames(ucdp_intra) <- c("year", "ccode", "intra.war", "new.conflict", "years.since.onset", "onset.1year",
                          "onset.2year", "onset.5year", "onset.8year", "onset.20year", "max.intensity",
                          "number.terr.conflict", "number.gov.conflict", "number.total.conflict", 
                          "gov.only", "terr.only", "both.gov.terr", "number.total.conflict2")
save(ucdp_intra, file = "./clean_data/ucdp_intra.RData")


###load COW intra-state war
cow_intra <- read.csv("./raw_data/COW_intra_war.csv")

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


cow_intra <- cow_intra %>% 
       dplyr::mutate(StartDate1 = as.Date(as.character(paste(startyear1, startmonth1, startday1, sep ="-"))),
               EndDate1 = as.Date(as.character(paste(endyear1, endmonth1, endday1, sep = "-"))),
               StartDate2 =as.character(paste(startyear2, startmonth2, startday2, sep ="-")),
               EndDate2 = as.character(paste(endyear2, endmonth2, endday2, sep = "-"))) 


cow_intra  <- cow_intra %>%
       mutate(StartDate2 = ifelse(StartDate2 =="-8--8--8", NA, StartDate2),
               EndDate2 = ifelse(EndDate2 == "-8--8--8", NA, EndDate2)) %>% 
       mutate(StartDate2 = as.Date(StartDate2),
              EndDate2 = as.Date(EndDate2)) 


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

cow_intra$StarYear1<-format(cow_intra$StartDate1, "%Y")   
cow_intra$EndYear1<-format(cow_intra$EndDate1, "%Y")    
cow_intra$StarYear2<-format(cow_intra$StartDate2, "%Y")   
cow_intra$EndYear2<-format(cow_intra$EndDate2, "%Y") 

##convert COW Inter War into country-war-year data  

cow_intra_yearly <- cow_intra %>%
              select(warnum,warname,
                    wartype, ccodea,sidea,sideb,
                    wherefought,initiator, outcome,sideadeaths, sidebdeaths,
                  StartDate1,EndDate1, StartDate2, EndDate2, 
                    WarDuration1,WarDuration2, StarYear1,EndYear1, StarYear2,EndYear2) %>%
              mutate(StarYear1 = as.integer(StarYear1),
                            EndYear1 = as.integer(EndYear1),
                             StarYear2 = as.integer(StarYear2),
                              EndYear2 = as.integer(EndYear2),
                               ccodea = as.character(ccodea))   
#filter recurred 
cow_intra_yearly2 <- cow_intra_yearly %>%
       filter(!is.na(StarYear2) & !is.na(EndYear2)) %>%
       filter(EndYear1!=EndYear2)

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
###expand recurred subset  
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

####combine two data
cow_intra_yearly <- rbind(cow_intra_yearly, cow_intra_yearly2)    
cow_intra_yearly <- unique(cow_intra_yearly )    ##remove duplicated row
save(cow_intra_yearly, file="./clean_data/cow_intra_yearly.RData") 

#make a dummy intra-state war 
cow_intra_yearly$intra_war <- 1
cow_intra_yearly <- cow_intra_yearly %>% 
       select(warname, warnum, ccodea, year, sideadeaths, 
              sidebdeaths,intra_war) # %>% filter(year >= 1940)

#####country-year data
country_year_cow_intra <- expand.grid(ccodea=cow_intra_yearly$ccodea, year = cow_intra_yearly$year)      

##merge
country_year_cow_intra <- left_join(country_year_cow_intra, cow_intra_yearly, by =c("ccodea","year"))
country_year_cow_intra <- unique(country_year_cow_intra)
###total battle death per year (Note: there are countries that were involved in multiple wars in a given year)
country_year_cow_intra <- country_year_cow_intra %>%
       mutate(sideadeaths = ifelse(sideadeaths == -9, 0, sideadeaths),
                                   sidebdeaths = ifelse(sidebdeaths == -9, 0, sidebdeaths)) %>% 
       mutate(sideadeaths = ifelse(is.na(sideadeaths), 0, sideadeaths),
              sidebdeaths = ifelse(is.na(sidebdeaths), 0, sidebdeaths),
              intra_war = ifelse(is.na(intra_war), 0, intra_war))

country_year_cow_intra$ccodea <- as.integer(as.character(country_year_cow_intra$ccodea))

##aggreate
country_year_cow_intra <- country_year_cow_intra %>%
       group_by(ccodea, year) %>%
       dplyr::summarise(total_sideadeaths = sum(sideadeaths),
                        total_sidebdeaths = sum(sidebdeaths),
                        intra_war_total = sum(intra_war))

#we donot have data after year 2007 from COW, so recode as zero
country_year_cow_intra <- country_year_cow_intra %>% 
       dplyr::mutate(total_sideadeaths = ifelse(is.na(total_sideadeaths) & year < 2008, 0, total_sideadeaths),
                     total_sidebdeaths = ifelse(is.na(total_sidebdeaths) & year < 2008, 0, total_sidebdeaths),
                     intra_war_total = ifelse(is.na(intra_war_total) & year < 2008, 0, intra_war_total)) 

country_year_cow_intra <- country_year_cow_intra %>% 
       mutate(total_intrawardeath = total_sideadeaths + total_sidebdeaths) %>% 
       select(-total_sideadeaths, -total_sidebdeaths)




##Because COW only covers from 1816-2007. we supplement inter and intra war with UCDP armed conflict data from 2004 to 2015
#get the battle deaths from UCDP
load("raw_data/ucdp-brd-conf-171.Rdata")
names(ucdp.brd.conf)

ucdp.brd.conf <- ucdp.brd.conf %>% 
              select(ConflictID, BdBest, Year, GWNoA, GWNoA2nd, GwNoB, GWNoB2nd) %>% 
           filter(Year > 2003 & Year < 2016)


load("./raw_data/ucdp-prio-acd-172.RData") #2017 version
names(ucdp.conf)

ucdp.conf <- subset(ucdp.conf, select = c(conflict_id, location, gwno_a, year, type_of_conflict))

ucdp_interwar <- ucdp.conf %>%  
       dplyr::filter(type_of_conflict ==2) %>% 
       dplyr::filter(year > 2003 & year < 2016) %>% 
      left_join(., ucdp.brd.conf, by =c("conflict_id" = "ConflictID", "year" ="Year")) %>% 
       select(year,BdBest, GWNoA, GwNoB)

#wide to long
library(tidyr)
new_interwar <- gather(ucdp_interwar, group, ccode, GWNoA:GwNoB, factor_key = TRUE) 

new_interwar <- new_interwar %>% 
               select(ccode, year, BdBest) %>% 
              mutate(inter_war_total = 1) %>% 
              dplyr::rename(total_BatDeath = BdBest) %>% 
              mutate(ccode = as.integer(ccode))

country_year_cow2.3 <- bind_rows(country_year_cow2.3, new_interwar)
save(country_year_cow2.3, file="./clean_data/country_year_cow2.3.RData") 



ucdp_intrawar <- ucdp.conf %>%  
       dplyr::filter(type_of_conflict ==3) %>% 
       dplyr::filter(year > 2003 & year < 2016)%>% 
       left_join(., ucdp.brd.conf, by =c("conflict_id" = "ConflictID", "year" ="Year")) %>% 
       select(year, BdBest, GWNoA) %>% 
       dplyr::group_by(GWNoA, year) %>%
       dplyr::summarise(intra_war_total = n(),
                        total_BatDeath = sum(BdBest)) %>% 
       dplyr::ungroup() %>% 
       dplyr::rename(ccodea = GWNoA,
                     total_intrawardeath = total_BatDeath)
ucdp_intrawar$ccodea <- as.integer(as.character(ucdp_intrawar$ccodea))

country_year_cow_intra <- bind_rows(country_year_cow_intra, ucdp_intrawar)

save(country_year_cow_intra , file = "./clean_data/country_year_cow_intra.RData")



###################################################################
##################### Inter state war at homeland, between major power
##############################################
###################################################################


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
dim(cow_data)
cow_data <- unique(cow_data)

cow_inter_dyad <- left_join(cow_inter_dyad, cow_data, by = c("WarNum"))
cow_inter_dyad$ccode_A <- as.integer(as.character(cow_inter_dyad$ccode_A))
cow_inter_dyad$ccode_B <- as.integer(as.character(cow_inter_dyad$ccode_B))


Contiguity <- read.csv("./raw_data/DirectContiguity320/contdird.csv")
names(Contiguity)
Contiguity <- subset(Contiguity, select = c(state1no, state2no, year, conttype))

cow_inter_dyad <- left_join(cow_inter_dyad, Contiguity, by = c("ccode_A" = "state1no",
                                                               "ccode_B" = "state2no",
                                                               "year" = "year"))
cow_inter_dyad <- cow_inter_dyad %>%
       dplyr::mutate(conttype = ifelse(is.na(conttype), 0, conttype))
cow_inter_dyad <- unique(cow_inter_dyad)
save(cow_inter_dyad, file = "./clean_data/cow_inter_dyad.RData")


##homeland war and major power interstate war


load("./clean_data/majorpowe_yearly.RData")
load( "./clean_data/cow_inter_dyad.RData")
cow_inter_dyad2 <- subset(cow_inter_dyad, select = c(year, ccode_A, ccode_B, conttype))
##Because COW only covers from 1816-2007. we supplement inter and intra war with UCDP armed conflict data from 2004 to 2015
load("./raw_data/ucdp-prio-acd-4-2016.RData")
ucdp_interwar <- ucdp.prio.acd  %>%  dplyr::filter(TypeOfConflict ==2) %>%  dplyr::filter(Year > 2003)
head(cow_inter_dyad2)
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

cow_inter_dyad2 <- left_join(cow_inter_dyad2, majorpowe_A, by = c("year" = "year", "ccode_A" = "ccode"))

majorpowe_B <- majorpowe_yearly %>%
       dplyr::mutate(majorpwer_B = 1) %>% 
       dplyr::select(ccode, year, majorpwer_B)
cow_inter_dyad2 <- left_join(cow_inter_dyad2, majorpowe_B, by = c("year" = "year", "ccode_B" = "ccode"))

cow_inter_dyad2 <- cow_inter_dyad2 %>%
       dplyr::mutate(majorpwer_A = ifelse(is.na(majorpwer_A), 0, majorpwer_A),
                     majorpwer_B = ifelse(is.na(majorpwer_B), 0, majorpwer_B))

cow_inter_dyad2 <- cow_inter_dyad2 %>%
       dplyr::mutate(existentialwar_A = ifelse(interwarhomeland == 0 & majorpwer_A ==1 & majorpwer_B == 0, 0, 1),
                      existentialwar_B = ifelse(interwarhomeland == 0 & majorpwer_B ==1 & majorpwer_A == 0, 0, 1))
save(cow_inter_dyad2, file = "./clean_data/cow_inter_dyad2.RData") #existentialwar 





