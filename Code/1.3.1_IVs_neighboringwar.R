rm(list = ls())
library(dplyr)
load("./clean_data/hierarchypaperdata.RData")

hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(inter_war_total = ifelse(is.na(inter_war_total), 0, inter_war_total),
                     intra_war_total = ifelse(is.na(intra_war_total), 0, intra_war_total)) %>% 
       dplyr::mutate(inter_warDummy = ifelse(inter_war_total >0,1,0),
                     intra_warDummy = ifelse(intra_war_total >0,1,0)) %>% 
       dplyr::mutate(warDummy = ifelse(inter_warDummy == 0 & intra_war_total == 0, 0, 1))

#### neigboring war (not with the country in questions)

load("./clean_data/cow_inter_dyad2.RData")

cow_inter_dyad2 <- cow_inter_dyad2 %>% filter(conttype == 0)
#make to country level
cow_inter <- cow_inter_dyad2 %>%
       dplyr::group_by(year, ccode_A) %>% 
       dplyr::summarise(interstate_warNonneigh = n())
cow_inter <- cow_inter %>% 
       dplyr::filter(year >= 1900)
##
hierarchypaperdata <- left_join(hierarchypaperdata, cow_inter, by = c("ccode" = "ccode_A",
                                                                      "year" = "year"))



hierarchypaperdata <- hierarchypaperdata %>% 
       dplyr::mutate(interstate_warNonneigh = ifelse(is.na(interstate_warNonneigh), 0, interstate_warNonneigh)) %>% 
       dplyr::mutate(interstate_warNonneigh_dummy = ifelse(interstate_warNonneigh > 0, 1, 0))
#check duplicates
hierarchypaperdata <- hierarchypaperdata %>%
                     dplyr::group_by(ccode, year) %>% 
                     dplyr::mutate(dup = n(),
                                   cum = cumsum(dup)) %>% 
                     dplyr::filter(dup == cum) %>% select(-dup, -cum)

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

###existential war
load("./clean_data/cow_inter_dyad2.RData")

cow_existentialwar <- cow_inter_dyad2 %>% 
       dplyr::group_by(year, ccode_A) %>% 
       dplyr::summarise(existentialwar = sum(existentialwar_A)) %>% 
       dplyr::filter(year >= 1900)
##
hierarchypaperdata <- left_join(hierarchypaperdata, cow_existentialwar, by = c("COWcode"= "ccode_A", "year"))

hierarchypaperdata  <- hierarchypaperdata  %>% 
                     mutate(existentialwar = ifelse(is.na(existentialwar), 0, existentialwar)) %>% 
                     mutate(existentialwardum = ifelse(existentialwar>0, 1, 0))

## (2) neighboring war
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
##interstate war in neighbors (not with neighbor in question)
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


save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")#as of 1am, Feb20, 2018




