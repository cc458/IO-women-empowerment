rm(list = ls())
load("./clean_data/cntsdata2014.RData")

#check duplicates
cntsdata2014 <- cntsdata2014 %>%
       dplyr::group_by(ccode, year) %>% 
       dplyr::mutate(dup = n(),
                     cum = cumsum(dup)) %>% 
       dplyr::filter(dup == cum) %>% select(-dup, -cum)

library(dplyr)
load("./clean_data/hierarchypaperdata.RData")

hierarchypaperdata <- left_join(hierarchypaperdata, cntsdata2014, 
                                by = c("COWcode" = "ccode", "year"))


##interstate war in neighbors (not with neighbor in question)
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

##
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


##
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

###demonstration
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

save(hierarchypaperdata, file = "./clean_data/hierarchypaperdata.RData")#as of 1am, Feb20, 2018

