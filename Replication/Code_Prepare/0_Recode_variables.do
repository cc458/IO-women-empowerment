// set a working directory
cd "~Replication"

**load data
use "clean_data/hierarchypaperdata.dta",clear
sort ccode year
//set panel data format
xtset ccode year


// variable labels
label variable powerbygender "Gender power"
label variable polempowerment "Political empowerment"
label variable civilliberty "Civil liberties"
label variable freeforcedlabor "Freedom from forced labor"
label variable propertyright "Property rights"
label variable civilparticip "Civil participation" 
label variable politicalparticip "Political participation"
label variable freediscussion "Freedom of discussion"
label variable justicaccess "Access to justice"
label variable civilorgz  "Civil society organization"
label variable cleanelec "Clean election index"
label variable civilsoci "Civil society index"
label variable year "Year"
label variable intra_warDummy "Intra-state war"
label variable inter_warDummy "Inter-state war"
label variable lmilex_pc "Mil.ex.pc,log"
label variable lmilper_pc "Mil.per.pc,log"
label variable lpop "Population,log"
label variable lpec "Energy.consump,log"
label variable lpec_pc "Energy.consump.pc,log"
label variable lupop "Urban population"
label variable cinc "CINC score"
label variable land_neighbors "Land neighbors,count"
label variable terrthreat "Territorial threat"
label variable peaceyrs_interwar "Peace years since previous inter-state war"
label variable peaceyrs_intrawar "Peace years since previous intra-state war"
label variable peaceyrs_war "Peace years since last war"
label variable ldeath "War-related death(log)"
label variable urbanization "Urbanization rate"

*********************************************** do not run
gen postWWII = 1 if year > 1945
replace postWWII = 0 if postWWII ==.
label variable postWWII "Post-1946 period"
label variable neighboringcivilwar "Neigh.civil.war, count"
label variable neighboringcivilwar_Dummy "Neigh.civil.war" 
gen nbcivilwar2year_dummy=1 if l.neighboringcivilwar_Dummy==1 | l2.neighboringcivilwar_Dummy==1
replace nbcivilwar2year_dummy=0 if l.neighboringcivilwar_Dummy==0 & l2.neighboringcivilwar_Dummy==0
label variable nbcivilwar2year_dummy "Neigh.civil.war.last.two.years" 
label variable neighboringInterStateWar_Dummy "Neigh.interstate.war" 
label variable warDummy "War"
*neighboring interstate war(excluded war with the country in question)
label variable interstate_warNonneigh "Interstate.wars,count"
label variable interstate_warNonneigh_dummy "Interstate war"
label variable neighboringInterStateWar_excldd "Neigh.interstate.wars,count"
label variable neighboringInterSttWr_xclddDmmy "Neigh.interstate.war"
label variable neighboringstriks "Neigh.strikst"
label variable neighboringgov_crises "Neigh.gov.crises"
label variable neighboring_riots "Neigh.riots"
label variable neighboring_demonstration "neigh.demonstrations"
label variable neighborpolempowerment "Neighboring political empowerment" 
label variable WBlaborpartic_femal "Women.labor.force.part.rate"
label variable WBfertility "Fertility rate"
label variable lWBmalepop "Male.pop,log"
label variable lWBmalepop1564 "Male population(ages 15-64, log)"
label variable lWBfepop "Female.pop,log"
label variable lWBfepop1564 "Female population(ages 15-64, log)"
label variable irregular_count "Irregular.leadership.change,count"
label variable irregular_dummy "Irre.leade.change"
label variable existentialwardum "Existential war" // "experiencing civil war, or war with contiguous states, or war against a great power"
label variable polity2 "Regime type"

//create binary variables of whether the country experienced war in last 5, 10, and 15 years (already have war in last 20 years)
*New, ongoing and recent war dummies
gen newwar=0
replace newwar=1 if warDummy==1 & l.warDummy==0
label variable newwar "New war"
gen ongoingwar=0
replace ongoingwar=1 if warDummy==1 & l.warDummy==1
label variable ongoingwar "Ongoing war"
gen recentwar=0
replace recentwar=1 if warDummy==0 & l.warDummy==1
label variable recentwar "Recent war"
gen newintra=0
replace newintra=1 if intra_warDummy==1 & l.intra_warDummy==0
gen ongoingintra=0
replace ongoingintra=1 if intra_warDummy==1 & l.intra_warDummy==1
gen recentintra=0
replace recentintra=1 if intra_warDummy==0 & l.intra_warDummy==1
gen newinter=0
replace newinter=1 if inter_warDummy==1 & l.inter_warDummy==0
gen ongoinginter=0
replace ongoinginter=1 if inter_warDummy==1 & l.inter_warDummy==1
gen recentinter=0
replace recentinter=1 if inter_warDummy==0 & l.inter_warDummy==1
gen newexist=0
replace newexist=1 if existentialwardum==1 & l.existentialwardum==0
gen ongoingexist=0
replace ongoingexist=1 if existentialwardum==1 & l.existentialwardum==1
gen recentexist=0
replace recentexist=1 if existentialwardum==0 & l.existentialwardum==1

*War duration
sort ccode year
gen wardur=0 if warDummy==0
replace wardur=1 if newwar==1
replace wardur=wardur[_n-1]+1 if ongoingwar==1 & ccode==ccode[_n-1]
label variable wardur "War duration"

*Logged battle deaths
gen ln_bdeaths=ln(ucdp_deaths+1)
label variable ln_bdeaths "Battle deaths,log"

sort ccode year
gen bdeaths_cum=0 if ucdp_deaths!=.
replace bdeaths_cum=bdeaths_cum[_n-1]+ucdp_deaths if ucdp_deaths>=1 & ccode==ccode[_n-1]
gen ln_bdeaths_cum=ln(bdeaths_cum+1)
label variable ln_bdeaths_cum "Cumulative battle deaths, log"
gen ln_total_BatDeath=ln(total_BatDeath+1)


// copy variables and save for simulations 

// for curent base model	
gen s_polempowerment = s.polempowerment
gen s_lmilper_pc = s.lmilper_pc
gen l_lmilper_pc = l.lmilper_pc
gen s_polity2 = s.polity2
gen l_polity2 = l.polity2
gen s_lpec = s.lpec
gen l_lpec	= l.lpec
gen l_irregular_dummy = l.irregular_dummy

// for future  years
gen fs_polempowerment = fs2.polempowerment
gen f2s2_polempowerment = f2s3.polempowerment
gen f3s3_polempowerment = f3s4.polempowerment
gen f4s4_polempowerment = f4s5.polempowerment
gen f5s5_polempowerment = f5s6.polempowerment
gen f10s10_polempowerment = f10s11.polempowerment
gen f15s15_polempowerment = f15s16.polempowerment

gen s_WBfertility = s.WBfertility
gen fs_WBfertility = fs2.WBfertility
gen f2s2_WBfertility = f2s3.WBfertility
gen f3s3_WBfertility = f3s4.WBfertility
gen f4s4_WBfertility = f4s5.WBfertility
gen f5s5_WBfertility = f5s6.WBfertility
gen f10s10_WBfertility = f10s11.WBfertility
gen f15s15_WBfertility = f15s16.WBfertility
// fer

gen l_polempowerment = l.polempowerment
gen l_neighborpolempowerment = l.neighborpolempowerment
gen sl_neighborpolempowerment = sl.neighborpolempowerment
gen l_WBfertility = l.WBfertility 
gen l_neighborWBfertility = l.neighborWBfertility
gen sl_neighborWBfertility = sl.neighborWBfertility
gen s_lpop = s.lpop
gen l_lpop = l.lpop
gen s_lWBmalepop = s.lWBmalepop
gen s_lWBfepop = s.lWBfepop

///// Save a copy of the data for simulation
save "Data/hierarchypaperdata.dta",replace


