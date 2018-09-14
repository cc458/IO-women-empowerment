rm(list = ls())
#make sure your working directory is this IO-women-empowerment
#setwd("~/IO-women-empowerment")
library(rgdal)
library(maptools)
library(ggplot2)
library(countrycode)
library(dplyr)
library(scales)
library(ggmap)
library(ggthemes)
library(cshapes)
library(tidyquant)
library(readstata13)
hierarchypaperdata <- read.dta13("Data/hierarchypaperdata.dta")

###define a theme in ggplot2
theme_nothing <- function(base_size = 12, legend = FALSE){
       if (legend) {
              return(theme(line = element_blank(),rect = element_blank(), #defien the margin line
                           axis.text = element_blank(), axis.title = element_blank(), 
                           panel.background = element_blank(), panel.grid.major = element_blank(), 
                           panel.grid.minor = element_blank(), axis.ticks.length = unit(0,"cm"),
                           panel.spacing = unit(0, "lines"),
                           plot.margin = unit(c(0,  0, 0, 0), "lines")))
       }
       else {
              return(theme(line = element_blank(), rect = element_blank(), 
                           text = element_blank(), axis.ticks.length = unit(0,"cm"), 
                           legend.position = "none",
                           panel.spacing = unit(0, "lines"),
                           plot.margin = unit(c(0, 0, 0, 0), "lines")))
       }
}



#### Figure 1(a)
###make a map for our sample countries in the data
mapdata <- subset(hierarchypaperdata, select = c(ccode, year, polempowerment))

ccode1950 <- mapdata[mapdata$year == 1950,]
##change germany code from 255 to 260 (GWcode)
ccode1950 <- ccode1950 %>%
              dplyr::mutate(ccode = ifelse(ccode == 255, 260, ccode))
##create shape_file from cshapes as 2005
cshp <- cshp(date=as.Date("2005-01-01"), useGW=TRUE) ###use 2005 because there are only limited polygons in 1950; the missing will be filled with NA
map = fortify(cshp, region="GWCODE")
map$id <- as.numeric(map$id)
map <- left_join(map, ccode1950, by =c("id" = "ccode"))
map <- map[order(map$order), ] 
pdf("Figures/polempowerment1950.pdf", width = 15, height = 8.5)
ggplot() + geom_polygon(data = map, 
                        aes(x = long, y = lat, group = group, fill =  polempowerment), 
                        color = "black", size = 0.25) + coord_fixed() +
       scale_fill_distiller(name="Women's political empowerment",
                            palette = 1, na.value = "gray50", guide = "colourbar", breaks = pretty_breaks(n = 5))+
       theme_nothing(legend = T) #+
dev.off()

## Figure 1(b)
ccode2005 <- mapdata[mapdata$year == 2005,]
##change germany code from 255 to 260 (GWcode)
ccode2005 <- ccode2005 %>%
       dplyr::mutate(ccode = ifelse(ccode == 255, 260, ccode))
##create shape_file from cshapes as 2005
cshp <- cshp(date=as.Date("2005-1-01"), useGW=TRUE)
map = fortify(cshp, region="GWCODE")
map$id <- as.numeric(map$id)
map <- left_join(map, ccode2005, by =c("id" = "ccode"))
map <- map[order(map$order), ] 

pdf("Figures/polempowerment2005.pdf", width = 15, height = 8.5)
ggplot() + geom_polygon(data = map, 
                        aes(x = long, y = lat, group = group, fill =  polempowerment), 
                        color = "black", size = 0.25) + coord_fixed() +
       scale_fill_distiller(name="Women's political empowerment",
                            palette = 1, na.value = "gray50", 
                            guide = "colourbar", breaks = pretty_breaks(n = 5)) + 
              theme_nothing(legend = T)
dev.off()


## Figure 1(c)
######1946 and 2015
##slow moving average with width = 84 days (slow window = 3X fast window). To do this we apply two calls to tq_mutate(), the first for the 28 day (fast) and the second for the 84 day (slow) 
# Rolling mean
vdem2 <- hierarchypaperdata %>% 
       dplyr::select(ccode, year, polempowerment, warDummy, inter_warDummy, 
                     intra_warDummy, existentialwardum, majorWar) %>%
       dplyr::group_by(year) %>% 
       dplyr::summarise(avgpolempowerment = mean(polempowerment, na.rm = T),
                        war = sum(warDummy, na.rm = T),
                        interwar = sum(inter_warDummy, na.rm = T),
                        intrawar = sum(intra_warDummy, na.rm = T),
                        exsitentialwar = sum(existentialwardum, na.rm = T),
                        majorwar = sum(majorWar))
vdem2$date <- as.Date(paste(vdem2$year, "01-01", sep = "-"))

vdem_rollmean <- vdem2 %>%
       tq_mutate(
              # tq_mutate args
              select     = avgpolempowerment,
              mutate_fun = rollapply, 
              # rollapply args
              width      = 5,
              align      = "right",
              FUN        = mean,
              # mean args
              na.rm      = TRUE,
              # tq_mutate args
              col_rename = "mean_3yrs"
       ) %>%
       tq_mutate(
              # tq_mutate args
              select     = avgpolempowerment,
              mutate_fun = rollapply,
              # rollapply args
              width      = 10,
              align      = "right",
              FUN        = mean,
              # mean args
              na.rm      = TRUE,
              # tq_mutate args
              col_rename = "mean_10yrs"
       )


# ggplot
#0 = blank, 1 = solid, 2 = dashed, 3 = dotted, 4 = dotdash, 5 = longdash, 6 = twodash
vdem_rollmean %>%
       ggplot(aes(x = year, y = avgpolempowerment)) +
       # Data
       geom_line(aes(y = avgpolempowerment), color = "blue",linetype = 6, size = .5)+
      # geom_point(alpha = 0.1) +
       #geom_line(aes(y = mean_3yrs), color = "blue",linetype = 1, size = .5) +
       #geom_line(aes(y = mean_10yrs), color = "red",linetype = 2, size = .5) +
       #geom_line(aes(y = war/30), colour = "black", linetype = 1, size = .4) + 
       geom_line(aes(y = intrawar/25), colour = "grey69", linetype = 2, size = .8) + 
       #geom_line(aes(y = exsitentialwar/25), colour = "red", linetype = 1, size = .5) + 
       geom_line(aes(y = interwar/25), colour = "gray1", linetype = 5, size = .5) + 
       scale_y_continuous(sec.axis = sec_axis(~.*25, name = "War")) + 
       scale_x_continuous(breaks = seq(1900, 2015, 10)) +
       # Aesthetics
       labs(title = "Women's political empowerment index", x = "Year",
            y = "Political empowerment index",
            #caption="Source: V-Dem Version 6.2",
            subtitle = "Right y-axis: number of countries experiencing wars") +
       scale_color_tq() + 
     theme_tufte() +
       # annotate("segment", x = 2000, xend = 2008, y = 0.5, yend = 0.69,
        #        colour="red", arrow=arrow()) + 
       #annotate("text", x = 2000, y = 0.49, parse = F, 
        #        label = "Ten-Year Moving Average",size=4) + 
       annotate("segment", x = 1927, xend = 1927, y = 0.5, yend = 0.38,
                colour="blue", arrow=arrow(length=unit(0.2,"cm"))) + 
       annotate("text", x = 1928, y = 0.51, parse = F, 
                label = "Empowerment",size=4) + 
       annotate("segment", x = 1908, xend = 1916, y = 0.6, yend = 0.5,
                colour="gray1", arrow=arrow(length=unit(0.2,"cm"))) + 
       annotate("text", x = 1905, y = 0.61, parse = F, 
                label = "Inter-state war",size=4) + 
       annotate("segment", x = 2000, xend = 1993, y = 0.75, yend = 0.7,
                colour="gray1", arrow=arrow(length=unit(0.2,"cm"))) + 
       annotate("text", x = 2004, y = 0.76, parse = F, 
                label = "Intra-state war",size=4)
ggsave("./writing/figures/moving_avg.png", units = "cm", height =18 , width = 30)



#Figure 2
###make a graph on US, China, Russia, UK, India, Japan, El Salvador and Liberia 
country_list <- c("Russia", "United Kingdom", "United States of America", "China",
                  "Japan", "India", "El Salvador", "Liberia")
country_listcode <- countrycode(country_list, "country.name","cown") 
vdem <- mapdata %>% 
       dplyr::filter(ccode %in% country_listcode) %>% 
       mutate(country.name = countrycode(ccode, "cown","country.name")) %>% 
       mutate(country.name = ifelse(country.name == "Russian Federation", 
                                    "Russian Federation (USSR)", country.name)) %>% 
       mutate(country.name = ifelse(country.name == "United Kingdom of Great Britain and Northern Ireland", 
                                    "United Kingdom", country.name))
#plot
ggplot(vdem, aes(year, polempowerment)) +
       geom_point(colour = "pink", size = 2)+
       geom_line() + geom_smooth() +
       labs(x = "Year", y = "Women political empowerment",
            caption="Source: V-Dem Version 6.2") +
       facet_wrap(~country.name, scales = "free", nrow = 4, ncol = 2) + 
       theme_tufte()
ggsave("Figures/countryplot.png", units = "cm", height =15 , width = 20)




