# IO-women-empowerment
Replication materials for Kaitlyn Webster, Chong Chen, and Kyle Beardsley, "Conflict, Peace, and the Evolution of Women's Empowerment", International Organization.


For questions contact the corresponding author: XXX 

All models are estimated using STATA 15SE; All Figures are created using R version 3.4.3

You need to set your working directories in Stata and R.

Files and scripts
------

`Data`
* `hierarchypaperdata.dta` - contains all variables used to estimate models   
* `simulation.dta` - a copy of the `hierarchypaperdata.dta` due to variable names switch between R and Stata
* `emp_imputeBays.dta` - imputed data for empowerment
* `fert_imputeBays.dta` - imputed data for fertility 


`Figures`
* Contains the graphics used in the article.

`Code`
* `1_Analysis.do` – Stata 15SE code to replicate all tables; State Code to generate simulation parameters
* `2_Figures_1-2.R` – R code to reproduce Figures 1-2
* `3_Figures_3-7.R` – R code to reproduce Figures 3-7



R sessionInfo()
R version 3.4.3 (2017-11-30)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS Sierra 10.12.6

Matrix products: default
BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] tidyquant_0.5.4            forcats_0.2.0              stringr_1.3.0             
 [4] readr_1.1.1                tidyr_0.8.0                tibble_1.4.2              
 [7] tidyverse_1.2.1            quantmod_0.4-11            TTR_0.23-2                
[10] PerformanceAnalytics_1.5.2 xts_0.10-0                 zoo_1.8-0                 
[13] lubridate_1.7.1            cshapes_0.6                plyr_1.8.4                
[16] ggmap_2.6.1                scales_0.5.0.9000          countrycode_1.00.0        
[19] maptools_0.9-2             rgdal_1.2-10               sp_1.2-7                  
[22] bindrcpp_0.2               dplyr_0.7.4                purrr_0.2.4               
[25] ggridges_0.4.1             viridis_0.4.0              viridisLite_0.3.0         
[28] ggthemes_3.4.0             ggplot2_2.2.1.9000         arm_1.9-3                 
[31] lme4_1.1-13                Matrix_1.2-12              MASS_7.3-47               
[34] readstata13_0.9.0         

loaded via a namespace (and not attached):
 [1] nlme_3.1-131       RColorBrewer_1.1-2 httr_1.3.1         tools_3.4.3        R6_2.2.2          
 [6] rgeos_0.3-23       lazyeval_0.2.1     colorspace_1.3-2   withr_2.1.2        gridExtra_2.3     
[11] mnormt_1.5-5       curl_2.8.1         compiler_3.4.3     cli_1.0.0          rvest_0.3.2       
[16] xml2_1.1.1         labeling_0.3       psych_1.8.3.3      quadprog_1.5-5     digest_0.6.15     
[21] foreign_0.8-69     minqa_1.2.4        jpeg_0.1-8         pkgconfig_2.0.1    maps_3.2.0        
[26] rlang_0.2.1        readxl_1.0.0       rstudioapi_0.7     bindr_0.1          jsonlite_1.5      
[31] magrittr_1.5       geosphere_1.5-7    Quandl_2.8.0       Rcpp_0.12.17       munsell_0.4.3     
[36] abind_1.4-5        proto_1.0.0        stringi_1.1.7      yaml_2.1.18        grid_3.4.3        
[41] parallel_3.4.3     crayon_1.3.4       lattice_0.20-35    haven_1.1.0        splines_3.4.3     
[46] mapproj_1.2.6      hms_0.4.0          pillar_1.2.1       rjson_0.2.15       reshape2_1.4.3    
[51] timetk_0.1.0       glue_1.2.0         modelr_0.1.1       png_0.1-7          nloptr_1.0.4      
[56] RgoogleMaps_1.4.1  cellranger_1.1.0   gtable_0.2.0       assertthat_0.2.0   broom_0.4.4       
[61] coda_0.19-1       
> 
