rm(list = ls())
#make sure your working directory is in "/Replication"
setwd("../Analysis")
# Function to load &install packages
loadPkg=function(toLoad){
       for(lib in toLoad){
              if(! lib %in% installed.packages()[,1])
              {install.packages(lib, repos='http://cran.rstudio.com/')}
              suppressMessages( library(lib, character.only=TRUE))}}

#Load libraries
packs=c('rgeos','rgdal','sf','maptools','ggplot2','countrycode','dplyr','scales',
        'ggmap','ggthemes','cshapes','tidyquant','readstata13','arm','viridis',
        'ggridges','purrr','dplyr')
loadPkg(packs)
##load the paper data for simulations
data <- read.dta13("Data/hierarchypaperdata.dta") 
names(data)

################## Figure (3a)

#create a vector for dependent variables for forward effect
dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")
ivs <- c("warDummy", "l_polempowerment", "s_polity2", "l_polity2", 
  "s_lpec", "l_lpec", "year", "sl_neighborpolempowerment")

b <- c("fe_polem0", "fe_polem1", "fe_polem2", "fe_polem3",
       "fe_polem4", "fe_polem5", "fe_polem10", "fe_polem15")
vcv <- c("fe_polem0", "fe_polem1", "fe_polem2", "fe_polem3",
         "fe_polem4", "fe_polem5", "fe_polem10", "fe_polem15")


marginal <- list()
for (i in 1:length(b)){
  # extract data
  f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
  
  mydata2 <- model.matrix(f, data)
  mydata2 <- as.data.frame(mydata2[,c(2:9,1)])# move constant to last position
  
  # read coefficients and VCV matrix created by Stata
  pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
  vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
  # need only second equation
  pars <- pars[1:9]
  vc <- vc[1:9, 1:9]
  
  set.seed(321)
  k <- 1000
  
  # simulations for base model
  draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
  
  data0 <- data1 <- mydata2
  
  data0$warDummy <- 0
  data1$warDummy <- 1
  
  #empty containers
  X1 = as.matrix(data0)
  X2 = as.matrix(data1)
  
  marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                              apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}


df_plot <- map(marginal, data.frame) %>%
  map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

#### use ggplot to make figure 3
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
         geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
         scale_fill_viridis(discrete = TRUE) +
         geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
         theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
         theme(axis.title.y = element_blank(),
               plot.title = element_text(hjust = 0.5)) +
         scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                     "4-year", "3-year", "2-year", "1-year", "Current")) + 
         labs(title = "War and Women's Political Empowerment",
           x = "Average marginal effects")
ggsave("Figures/Fig3.jpg",units = "cm", width = 12, height = 12, dpi = 300)


################## Figure (3b, c, d)
### for war type
dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")

ivs <- c("newwar","ongoingwar"," recentwar", "l_polempowerment", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborpolempowerment")

varname <- c("newwar","ongoingwar","recentwar")
ttvarname <- c("New War","Ongoing War","Recent War")

b <- c("fe_interact0", "fe_interact1", "fe_interact2", "fe_interact3",
       "fe_interact4", "fe_interact5", "fe_interact10", "fe_interact15")
vcv <- c("fe_interact0", "fe_interact1", "fe_interact2", "fe_interact3",
         "fe_interact4", "fe_interact5", "fe_interact10", "fe_interact15")

## use a for loop for make three figs
for (j in 1:length(varname)){

marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:11,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:11]
       vc <- vc[1:11, 1:11]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2

       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       X1[, varname[j]] = 0
       X2[, varname[j]] = 1
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}


df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))


####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank(),
             plot.title = element_text(hjust = 0.5)) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = paste0(ttvarname[j], " and Women's Political Empowerment"),
            x = "Average marginal effects")
ggsave(paste0(paste("Figures/Fig3", varname[j], sep="_"),".jpg"),
       units = "cm", width = 12, height = 12,dpi = 300)
}



## Figure 4

#create a vector for dependent variables for forward effect
dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")
ivs <- c("s_polity2", "l_polity2", "s_lpec", "l_lpec", "year", "warDummy")


b <- c("base", "f1", "f2", "f3", "f4", "f5", "f10", "f15")
vcv <- c("base", "f1", "f2", "f3", "f4", "f5", "f10", "f15")


marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:7,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("./Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("./Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:7]
       vc <- vc[1:7, 1:7]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$warDummy <- 0
       data1$warDummy <- 1
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}

df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank()) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = "War and Women's Political Empowerment, IV Model",
            x = "Average marginal effects")
ggsave("Figures/Fig4.jpg",units = "cm", width = 13, height = 12,dpi = 300)


### Figure 5 (a)
#create a vector for dependent variables for forward effect
dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")
ivs <- c("wardur", "l_polempowerment", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborpolempowerment")

b <- c("fe_polemwardur0", "fe_polemwardur1", "fe_polemwardur2", "fe_polemwardur3",
       "fe_polemwardur4", "fe_polemwardur5", "fe_polemwardur10", "fe_polemwardur15")
vcv <- c("fe_polemwardur0", "fe_polemwardur1", "fe_polemwardur2", "fe_polemwardur3",
         "fe_polemwardur4", "fe_polemwardur5", "fe_polemwardur10", "fe_polemwardur15")

marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:9,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:9]
       vc <- vc[1:9, 1:9]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$wardur <- 0 #2.5%
       data1$wardur <- 5 # 97.5%
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}

df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank(),
             plot.title = element_text(hjust = 0.5)) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = "War Duration and Women's Political Empowerment",
            x = "Average marginal effects")
ggsave("Figures/Fig5-a.jpg",units = "cm", width = 12, height = 12,dpi = 300)


## Figure 5(b)
#create a vector for dependent variables for forward effect
dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")
ivs <- c("ln_bdeaths", "l_polempowerment", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborpolempowerment")

b <- c("fe_polembd0", "fe_polembd1", "fe_polembd2", "fe_polembd3",
       "fe_polembd4", "fe_polembd5", "fe_polembd10", "fe_polembd15")
vcv <- c("fe_polembd0", "fe_polembd1", "fe_polembd2", "fe_polembd3",
         "fe_polembd4", "fe_polembd5", "fe_polembd10", "fe_polembd15")

marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:9,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:9]
       vc <- vc[1:9, 1:9]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$ln_bdeaths <- 0 #2.5%
       data1$ln_bdeaths <- 8.9 # 97.5%
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}


df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank(),
             plot.title = element_text(hjust = 0.5)) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = "Battle Deaths and Women's Political Empowerment",
            x = "Average marginal effects")
ggsave("Figures/Fig5-b.jpg",units = "cm", width = 12, height = 12,dpi = 300)


## Figure 6(a)
#create a vector for dependent variables for forward effect
dvs <- c("s_WBfertility","fs_WBfertility", "f2s2_WBfertility",
         "f3s3_WBfertility", "f4s4_WBfertility","f5s5_WBfertility", 
         "f10s10_WBfertility", "f15s15_WBfertility")
ivs <- c("warDummy", "l_WBfertility", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborWBfertility")

b <- c("fe_fertility0", "fe_fertility1", "fe_fertility2", "fe_fertility3",
       "fe_fertility4", "fe_fertility5", "fe_fertility10", "fe_fertility15")
vcv <- c("fe_fertility0", "fe_fertility1", "fe_fertility2", "fe_fertility3",
         "fe_fertility4", "fe_fertility5", "fe_fertility10", "fe_fertility15")

marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:9,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:9]
       vc <- vc[1:9, 1:9]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$warDummy <- 0
       data1$warDummy <- 1
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}


df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank(),
             plot.title = element_text(hjust = 0.5)) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = "War and Fertility Rates",
            x = "Average marginal effects")
ggsave("Figures/Fig6-a.jpg",units = "cm", width = 12, height = 12,dpi = 300)

## Figure 6(b)
#create a vector for dependent variables for forward effect
dvs <- c("s_WBfertility","fs_WBfertility", "f2s2_WBfertility",
         "f3s3_WBfertility", "f4s4_WBfertility","f5s5_WBfertility", 
         "f10s10_WBfertility", "f15s15_WBfertility")
ivs <- c("existentialwardum", "l_WBfertility", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborWBfertility")

b <- c("fe_fertilityexist0", "fe_fertilityexist1", "fe_fertilityexist2", "fe_fertilityexist3",
       "fe_fertilityexist4", "fe_fertilityexist5", "fe_fertilityexist10", "fe_fertilityexist15")
vcv <- c("fe_fertilityexist0", "fe_fertilityexist1", "fe_fertilityexist2", "fe_fertilityexist3",
         "fe_fertilityexist4", "fe_fertilityexist5", "fe_fertilityexist10", "fe_fertilityexist15")

marginal <- list()
for (i in 1:length(b)){
       # extract data
       f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
       
       mydata2 <- model.matrix(f, data)
       mydata2 <- as.data.frame(mydata2[,c(2:9,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:9]
       vc <- vc[1:9, 1:9]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$existentialwardum <- 0
       data1$existentialwardum <- 1
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
}


df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))

####
ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank(),
             plot.title = element_text(hjust = 0.5)) +
       scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                   "4-year", "3-year", "2-year", "1-year", "Current")) + 
       labs(title = "Existential War and Fertility Rates",
            x = "Average marginal effects")
ggsave("Figures/Fig6-b.jpg",units = "cm", width = 12, height = 12,dpi = 300)


## Figure 7 (a)
## rescale population variables
data <- data %>% 
       dplyr::mutate(s_lpop = s_lpop*10,
                     l_lpop = l_lpop*10,
                     s_lWBmalepop = s_lWBmalepop*10,
                     s_lWBfepop = s_lWBfepop*10)

#create a vector for dependent variables for forward effect
f1 <- as.formula(s_lmilper_pc ~ warDummy + l_lmilper_pc + s_polity2 + l_polity2 + s_lpec + l_lpec +year)
f2 <- as.formula(s_lpop ~ warDummy + l_lpop + s_polity2 + l_polity2 + s_lpec + l_lpec +year)
f3 <- as.formula(s_lWBmalepop ~ warDummy + l_lpop + s_polity2 + l_polity2 + s_lpec + l_lpec +year)
f4 <- as.formula(s_lWBfepop ~ warDummy + l_lpop + s_polity2 + l_polity2 + s_lpec + l_lpec +year)
f5 <- as.formula(irregular_dummy ~ warDummy + s_polity2 + l_polity2 + s_lpec + l_lpec +year)
f <- list(f1, f2, f3, f4, f5)

b <- c("fe_milper", "fe_pop", "fe_mpop", "fe_fpop", "fe_irregular")
vcv <- c("fe_milper", "fe_pop", "fe_mpop", "fe_fpop", "fe_irregular")


marginal <- list()
for (i in 1:length(b)){
       # extract data
       mydata2 <- model.matrix(f[[i]], data)
       l = dim(mydata2)[2]
       mydata2 <- as.data.frame(mydata2[,c(2:l,1)])# move constant to last position
       
       # read coefficients and VCV matrix created by Stata
       pars <- as.matrix(read.delim(paste0(paste0("./Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
       vc <- data.matrix(read.delim(paste0(paste0("./Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
       # need only second equation
       pars <- pars[1:l]
       vc <- vc[1:l, 1:l]
       
       set.seed(321)
       k <- 1000
       
       # simulations for base model
       draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
       
       data0 <- data1 <- mydata2
       
       data0$warDummy <- 0
       data1$warDummy <- 1
       
       #empty containers
       X1 = as.matrix(data0)
       X2 = as.matrix(data1)
       
       marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                        apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns

       }

df_plot <- map(marginal, data.frame) %>%
       map2_df(., names(.), ~mutate(.x, type = .y))
names(df_plot)[1] <- "value"

##change the order of the variable
df_plot$type <- factor(df_plot$type, levels = rev(b))


####
p <- ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
       geom_density_ridges(col = "grey70", scale = .9, show.legend = F) +
       scale_fill_viridis(discrete = TRUE) +
       geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
       theme_ridges(font_size = 15, grid = F, center_axis_labels = T) +
       theme(axis.title.y = element_blank()) +
       labs(title = "War and Intermediate Variables",
            x = "Average marginal effects") 
p <- p + scale_y_discrete(labels = parse(text =c("Irregular~leadership~change", 
                                               "Log~of~female~population[list(Delta)]",
                                               "Log~of~male~population[list(Delta)]",
                                               "Log~of~population[list(Delta)]",
                                               "log~of~military~personel~\n~per~capita[list(Delta)]")))

ggsave("Figures/Fig7-a.jpg",units = "cm", width = 18, height = 12, dpi = 300)

## Figure 7(b, c, d, e)

dvs <- c("s_polempowerment", "fs_polempowerment", "f2s2_polempowerment",
         "f3s3_polempowerment", "f4s4_polempowerment", "f5s5_polempowerment",
         "f10s10_polempowerment", "f15s15_polempowerment")
  
ivs <- c("warDummy", "l_polempowerment", "s_lmilper_pc", "l_lmilper_pc", 
         "s_lpop", "l_lpop", "irregular_dummy", "s_polity2", "l_polity2", 
         "s_lpec", "l_lpec", "year", "sl_neighborpolempowerment")

varname <- c("s_lmilper_pc","s_lpop","irregular_dummy", "warDummy")
ttvarname <- c("Military Personnel Change and Women's Political Empowerment",
               "Population Change and Women's Political Empowerment",
               "Irregular Regime Change and Women's Political Empowerment",
               "War and Women's Political Empowerment with Intermediate Variables")

b <- c("fe_polemintermed0", "fe_polemintermed1", "fe_polemintermed2", "fe_polemintermed3",
       "fe_polemintermed4", "fe_polemintermed5", "fe_polemintermed10", "fe_polemintermed15")
vcv <- c("fe_polemintermed0", "fe_polemintermed1", "fe_polemintermed2", "fe_polemintermed3",
         "fe_polemintermed4", "fe_polemintermed5", "fe_polemintermed10", "fe_polemintermed15")

for (j in 1:length(varname)){
       marginal <- list()
       for (i in 1:length(b)){
              # extract data
              f <- as.formula(paste(dvs[i], paste(ivs, collapse=" + "), sep=" ~ "))
              
              mydata2 <- model.matrix(f, data)
              mydata2 <- as.data.frame(mydata2[,c(2:14,1)])# move constant to last position
              
              # read coefficients and VCV matrix created by Stata
              pars <- as.matrix(read.delim(paste0(paste0("Data/simulation/", b[i]), "-beta.txt"), sep = "\t"))
              vc <- data.matrix(read.delim(paste0(paste0("Data/simulation/", vcv[i]), "-vcv.txt"), sep = "\t"))
              # need only second equation
              pars <- pars[1:14]
              vc <- vc[1:14, 1:14]
              
              set.seed(321)
              k <- 1000
              
              # simulations for base model
              draw <- mvrnorm(k, data.matrix(pars), data.matrix(vc))
              X1 <- X2 <-  X <- as.matrix(mydata2)
              value = as.numeric(quantile(X[, varname[j]], c(0.025, 0.975)))
              X1[, varname[j]] = value[1]
              X2[, varname[j]] = value[2]
              
              marginal[[b[i]]] <- apply(apply(X2, 1, function (x) draw %*% x) - 
                                               apply(X1, 1, function (x) draw %*% x), 1, mean) #1 indicates row, 2= columns
       }

       df_plot <- map(marginal, data.frame) %>%
              map2_df(., names(.), ~mutate(.x, type = .y))
       names(df_plot)[1] <- "value"
       
       ##change the order of the variable
       df_plot$type <- factor(df_plot$type, levels = rev(b))

       ####
       ggplot(df_plot, aes(x = value, y = type, height=..density.., fill = type)) +
              geom_density_ridges(col = "grey70", scale = 1.2, show.legend = F) +
              scale_fill_viridis(discrete = TRUE) +
              geom_vline(xintercept = 0, colour = gray(1/2), lty = 2) +
              theme_ridges(font_size = 12, grid = F, center_axis_labels = T) +
              theme(axis.title.y = element_blank(),
                    plot.title = element_text(hjust = 0.5)) +
              scale_y_discrete(labels = c("15-year","10-year", "5-year",
                                          "4-year", "3-year", "2-year", "1-year", "Current")) + 
              labs(title = ttvarname[j],
                   x = "Average marginal effects")
       ggsave(paste0(paste("Figures/Fig7", varname[j], sep="_"),".jpg"),
              units = "cm", width = 18, height = 12, dpi = 300)
}
