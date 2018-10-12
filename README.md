# IO-women-empowerment
Replication materials for Kaitlyn Webster, Chong Chen, and Kyle Beardsley, "Conflict, Peace, and the Evolution of Women's Empowerment," International Organization.


For questions contact the authors: Kaitlyn Webster (kaitlyn.webster@duke.edu), Chong Chen (chong.chen@duke.edu) and Kyle Beardsley (kyle.beardsley@duke.edu).

All models are estimated using STATA 15SE; All Figures are created using R version 3.4.3

You need to set your working directories in both Stata and R.

There are two parts of replication process: (1) The `Code` folder contains all R and Stata scripts that are used to produce the tables and figures; (2) The `Code_Prepare` folder contains R and Stata scripts that are used to prepare the data from scratch. 

Notice that if readers are interested in the data preparation and cleaning, they need to put all original data files in the `raw_data` folder. However, we are not allowed to upload the raw data from Banks(2014), World Banks, COW, etc. Readers are recommended to download them directly. Please contact the authors if you have problems finding them. We've provided references to get them in the R script.

In cases where readers are only interested in the analysis part, the scripts in `Code_Analysis` folder will be enough. 


Files and scripts
------
`Data`
* `hierarchypaperdata.dta` - contains all variables used to estimate models and for simulation effects.  
* `simulation` folder: txt files stored from the estimated results using the Stata `do file`, which will be used for making figures.

`Code`
* `1_Analysis.do` – Stata 15SE code to replicate all tables; State Code to generate simulation parameters
* `2_Figures_1-2.R` – R code to reproduce Figures 1-2
* `3_Figures_3-7.R` – R code to reproduce Figures 3-7

`Code_Prepare`
* `0_Prepare_Data.R`– R code to clean the raw data. To run this script, you need to get all the raw data listed in the script. 
*`0_Recode_variables.do`– Stata code to recode variables. 

`raw_data`
* All original data downloaded from COW, Polity, VDEM, etc. You will need this data folder only if you want to use the script `0_Prepare_Data.R`. 

`clean_data`
* Folder to store the data output from the `0_Prepare_Data.R` script.

`figures`
* Contains the graphics used in the article.

`tables`
* Contains the latex tables in the appendix

`R sessionInfo()`

**R version 3.4.3 (2017-11-30)**

**Platform:** x86_64-apple-darwin15.6.0 (64-bit) 

**locale:**
en_US.UTF-8||en_US.UTF-8||en_US.UTF-8||C||en_US.UTF-8||en_US.UTF-8

**attached base packages:** 
_stats_, _graphics_, _grDevices_, _utils_, _datasets_, _methods_ and _base_

**other attached packages:** 
_rgdal(v.1.2-10)_, _tidyquant(v.0.5.4)_, _forcats(v.0.2.0)_, _stringr(v.1.3.0)_, _readr(v.1.1.1)_, _tidyr(v.0.8.0)_, _tibble(v.1.4.2)_, _tidyverse(v.1.2.1)_, _quantmod(v.0.4-11)_, _TTR(v.0.23-2)_, _PerformanceAnalytics(v.1.5.2)_, _xts(v.0.10-0)_, _zoo(v.1.8-0)_, _lubridate(v.1.7.1)_, _cshapes(v.0.6)_, _plyr(v.1.8.4)_, _ggmap(v.2.6.1)_, _scales(v.0.5.0.9000)_, _countrycode(v.1.00.0)_, _maptools(v.0.9-2)_, _sp(v.1.2-7)_, _dplyr(v.0.7.4)_, _purrr(v.0.2.4)_, _ggridges(v.0.4.1)_, _viridis(v.0.4.0)_, _viridisLite(v.0.3.0)_, _ggthemes(v.3.4.0)_, _ggplot2(v.2.2.1.9000)_, _arm(v.1.9-3)_, _lme4(v.1.1-13)_, _Matrix(v.1.2-12)_, _MASS(v.7.3-47)_, _readstata13(v.0.9.0)_ and _pander(v.0.6.2)_

**loaded via a namespace (and not attached):** 
_httr(v.1.3.1)_, _maps(v.3.2.0)_, _jsonlite(v.1.5)_, _splines(v.3.4.3)_, _modelr(v.0.1.1)_, _assertthat(v.0.2.0)_, _cellranger(v.1.1.0)_, _yaml(v.2.1.18)_, _pillar(v.1.2.1)_, _lattice(v.0.20-35)_, _glue(v.1.2.0)_, _quadprog(v.1.5-5)_, _digest(v.0.6.15)_, _rvest(v.0.3.2)_, _minqa(v.1.2.4)_, _colorspace(v.1.3-2)_, _psych(v.1.8.3.3)_, _pkgconfig(v.2.0.1)_, _broom(v.0.4.4)_, _haven(v.1.1.0)_, _jpeg(v.0.1-8)_, _withr(v.2.1.2)_, _lazyeval(v.0.2.1)_, _cli(v.1.0.0)_, _mnormt(v.1.5-5)_, _proto(v.1.0.0)_, _crayon(v.1.3.4)_, _readxl(v.1.0.0)_, _magrittr(v.1.5)_, _nlme(v.3.1-131)_, _xml2(v.1.1.1)_, _foreign(v.0.8-69)_, _tools(v.3.4.3)_, _hms(v.0.4.0)_, _geosphere(v.1.5-7)_, _RgoogleMaps(v.1.4.1)_, _munsell(v.0.4.3)_, _bindrcpp(v.0.2)_, _compiler(v.3.4.3)_, _rlang(v.0.2.1)_, _grid(v.3.4.3)_, _nloptr(v.1.0.4)_, _rstudioapi(v.0.7)_, _rjson(v.0.2.15)_, _gtable(v.0.2.0)_, _abind(v.1.4-5)_, _curl(v.2.8.1)_, _reshape2(v.1.4.3)_, _R6(v.2.2.2)_, _gridExtra(v.2.3)_, _bindr(v.0.1)_, _Quandl(v.2.8.0)_, _stringi(v.1.1.7)_, _parallel(v.3.4.3)_, _Rcpp(v.0.12.17)_, _mapproj(v.1.2.6)_, _png(v.0.1-7)_ and _coda(v.0.19-1)_