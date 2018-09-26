// set a working directory
cd "~/IO-women-empowerment"

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
label variable peaceyrs_majorwar "Peace years since previous major war"
label variable ldeath "War-related death(log)"
label variable urbanization "Urbanization rate"

gen postWWII = 1 if year > 1945
replace postWWII = 0 if postWWII ==.
label variable postWWII "Post-1946 period"

label variable neighboringcivilwar "Neigh.civil.war, count"
label variable neighboringcivilwar_Dummy "Neigh.civil.war" 

gen nbcivilwar2year_dummy=1 if l.neighboringcivilwar_Dummy==1 | l2.neighboringcivilwar_Dummy==1
replace nbcivilwar2year_dummy=0 if l.neighboringcivilwar_Dummy==0 & l2.neighboringcivilwar_Dummy==0
label variable nbcivilwar2year_dummy "Neigh.civil.war.last.two.years" 

label variable neighboringInterStateWar_Dummy "Neigh.interstate.war" 
label variable neighboringmajorWar_Dummy "Neigh.major.war" 
label variable neighboringWar_Dummy "Neighboring war" 
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

label variable majorWar "Major war"
label variable polity2 "Regime type"

//create binary variables of whether the country experienced war in last 5, 10, and 15 years (already have war in last 20 years)

gen war5yrs_dummy = 0 if peaceyrs_war > 5
replace war5yrs_dummy = 1 if war5yrs_dummy ==. | l.warDummy ==1 | l2.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1
label variable war5yrs_dummy "War in last five years"

gen war10yrs_dummy = 0 if peaceyrs_war > 10
replace war10yrs_dummy = 1 if war10yrs_dummy ==. | l.warDummy ==1 | l2.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1 | l5.warDummy ==1 | l6.warDummy ==1 | l7.warDummy ==1 | l8.warDummy ==1 | l9.warDummy ==1
label variable war10yrs_dummy "War in last 10 years"

gen war15yrs_dummy = 0 if peaceyrs_war > 15
replace war15yrs_dummy = 1 if war15yrs_dummy ==. | l.warDummy ==1 | l2.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1 | l5.warDummy ==1 | l6.warDummy ==1 | l7.warDummy ==1 | l8.warDummy ==1 | l9.warDummy ==1 | l10.warDummy ==1 | l11.warDummy ==1 | l12.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1 
label variable war15yrs_dummy "War in last 15 years"

gen war20yrs_dummy = 0 if peaceyrs_war > 20
replace war20yrs_dummy = 1 if war20yrs_dummy ==. | l.warDummy ==1 | l2.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1 | l5.warDummy ==1 | l6.warDummy ==1 | l7.warDummy ==1 | l8.warDummy ==1 | l9.warDummy ==1 | l10.warDummy ==1 | l11.warDummy ==1 | l12.warDummy ==1 | l3.warDummy ==1 | l4.warDummy ==1 | l5.warDummy ==1 | l16.warDummy ==1 | l17.warDummy ==1 | l18.warDummy ==1 | l19.warDummy ==1 
label variable war20yrs_dummy "War in last 20 years"

*Create some copies, to make the labeling easier
gen warDummy_copy=warDummy
gen warDummy_copy1=warDummy
gen warDummy_copy2=warDummy
gen warDummy_copy3=warDummy
gen warDummy_copy4=warDummy
gen warDummy_copy5=warDummy
gen warDummy_copy6=warDummy
gen warDummy_copy7=warDummy
gen warDummy_copy8=warDummy
gen warDummy_copy9=warDummy


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
gen l_WBfertility = l.WBfertility 
gen l_neighborWBfertility = l.neighborWBfertility
gen s_lpop = s.lpop
gen l_lpop = l.lpop
gen s_lWBmalepop = s.lWBmalepop
gen s_lWBfepop = s.lWBfepop

///// Save a copy of the data for simulation
save "Data/hierarchypaperdata_copy.dta",replace

**********************
*Stationarity tests: Can reject the null that all panels have unit roots
xtunitroot fisher s.polempowerment, pperron lags(0) 
xtunitroot fisher s.WBfertility, pperron lags(0) 


******************************************************************  
//All tables go to appendix; figures are created in R with the 
//estimated coefficient and variance-covariance (figs 3-7)
//save coefficient and variance-covariance for simulation
****************************************************************** 




**********************  Appendix Table A1: Models 1-8 (for Fig 3(a))********************** 
xtreg s.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempowerment_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem0")
		outsheet fe_polem0* in 1 using "Data/simulation/fe_polem0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem0vcv")
		outsheet fe_polem0* in 1/20 using "Data/simulation/fe_polem0-vcv.txt", replace 
	restore	
	
***future 1 year
xtreg fs2.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem1")
		outsheet fe_polem1* in 1 using "Data/simulation/fe_polem1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem1vcv")
		outsheet fe_polem1* in 1/20 using "Data/simulation/fe_polem1-vcv.txt", replace 
	restore	
	
*future 2 year
xtreg f2s3.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_2 
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem2")
		outsheet fe_polem2* in 1 using "Data/simulation/fe_polem2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem2vcv")
		outsheet fe_polem2* in 1/20 using "Data/simulation/fe_polem2-vcv.txt", replace 
	restore	
	
*future 3 year	
xtreg f3s4.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem3")
		outsheet fe_polem3* in 1 using "Data/simulation/fe_polem3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem3vcv")
		outsheet fe_polem3* in 1/20 using "Data/simulation/fe_polem3-vcv.txt", replace 
	restore			
*future 4 year		
xtreg f4s5.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempowerment_4 
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem4")
		outsheet fe_polem4* in 1 using "Data/simulation/fe_polem4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem4vcv")
		outsheet fe_polem4* in 1/20 using "Data/simulation/fe_polem4-vcv.txt", replace 
	restore	
	
*future 5 year
xtreg f5s6.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem5")
		outsheet fe_polem5* in 1 using "Data/simulation/fe_polem5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem5vcv")
		outsheet fe_polem5* in 1/20 using "Data/simulation/fe_polem5-vcv.txt", replace 
	restore	
*future 10 year
xtreg f10s11.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem10")
		outsheet fe_polem10* in 1 using "Data/simulation/fe_polem10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem10vcv")
		outsheet fe_polem10* in 1/20 using "Data/simulation/fe_polem10-vcv.txt", replace 
	restore	
*future 15 year	
xtreg f15s16.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polempowerment_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polem15")
		outsheet fe_polem15* in 1 using "Data/simulation/fe_polem15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polem15vcv")
		outsheet fe_polem15* in 1/20 using "Data/simulation/fe_polem15-vcv.txt", replace 
	restore	

********************************************** Table A1 to latex
esttab FE_polempowerment_0 FE_polempowerment_1 FE_polempowerment_2 FE_polempowerment_3 FE_polempowerment_4 ///
		FE_polempowerment_5 FE_polempowerment_10 FE_polempowerment_15 using "Tables/tab2.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 1\\(current)}" "\shortstack{Model 2\\(1-year)}" "\shortstack{Model 3\\(2-year)}" "\shortstack{Model 4\\(3-year)}" ///
	"\shortstack{Model 5\\(4-year)}" "\shortstack{Model 6\\(5-year)}" "\shortstack{Model 7\\(10-year)}" "\shortstack{Model 8\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war on future changes in women's political empowerment\label{tab2})  replace 


********************** Appendix Table A2: Models 9-16 (for Fig 3(b-d))********************** 	
xtreg s.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_interact_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact0")
		outsheet fe_interact0* in 1 using "Data/simulation/fe_interact0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact0vcv")
		outsheet fe_interact0* in 1/20 using "Data/simulation/fe_interact0-vcv.txt", replace 
	restore	

xtreg fs2.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact1")
		outsheet fe_interact1* in 1 using "Data/simulation/fe_interact1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact1vcv")
		outsheet fe_interact1* in 1/20 using "Data/simulation/fe_interact1-vcv.txt", replace 
	restore	


xtreg f2s3.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact2")
		outsheet fe_interact2* in 1 using "Data/simulation/fe_interact2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact2vcv")
		outsheet fe_interact2* in 1/20 using "Data/simulation/fe_interact2-vcv.txt", replace 
	restore	

xtreg f3s4.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact3")
		outsheet fe_interact3* in 1 using "Data/simulation/fe_interact3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact3vcv")
		outsheet fe_interact3* in 1/20 using "Data/simulation/fe_interact3-vcv.txt", replace 
	restore	

xtreg f4s5.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_4
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact4")
		outsheet fe_interact4* in 1 using "Data/simulation/fe_interact4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact4vcv")
		outsheet fe_interact4* in 1/20 using "Data/simulation/fe_interact4-vcv.txt", replace 
	restore	

xtreg f5s6.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact5")
		outsheet fe_interact5* in 1 using "Data/simulation/fe_interact5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact5vcv")
		outsheet fe_interact5* in 1/20 using "Data/simulation/fe_interact5-vcv.txt", replace 
	restore	

xtreg f10s11.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact10")
		outsheet fe_interact10* in 1 using "Data/simulation/fe_interact10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact10vcv")
		outsheet fe_interact10* in 1/20 using "Data/simulation/fe_interact10-vcv.txt", replace 
	restore	

xtreg f15s16.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_interact_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_interact15")
		outsheet fe_interact15* in 1 using "Data/simulation/fe_interact15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_interact15vcv")
		outsheet fe_interact15* in 1/20 using "Data/simulation/fe_interact15-vcv.txt", replace 
	restore	

********************************************** Table A2 to latex
esttab FE_polemp_interact_0 FE_polemp_interact_1 FE_polemp_interact_2 FE_polemp_interact_3 FE_polemp_interact_4 ///
		FE_polemp_interact_5 FE_polemp_interact_10 FE_polemp_interact_15 using "Tables/tab3.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 9\\(current)}" "\shortstack{Model 10\\(1-year)}" "\shortstack{Model 11\\(2-year)}" "\shortstack{Model 12\\(3-year)}" ///
	"\shortstack{Model 13\\(4-year)}" "\shortstack{Model 14\\(5-year)}" "\shortstack{Model 15\\(10-year)}" "\shortstack{Model 16\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war types on future changes in women's political empowerment\label{tab3})  replace 



********************** Appendix Table A3: Models 17-24 (for Fig 4)********************** 
etreg s.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)
estimates store IV_polempowerment_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("base")
		outsheet base* in 1 using "Data/simulation/base-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("basevcv")
		outsheet basevcv* in 1/29 using "Data/simulation/base-vcv.txt", replace 
	restore	

etreg fs2.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f1pol")
		outsheet f1pol* in 1 using "Data/simulation/f1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f1polvcv")
		outsheet f1polvcv* in 1/29 using "Data/simulation/f1-vcv.txt", replace 
	restore	


etreg f2s3.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f2pol")
		outsheet f2pol* in 1 using "Data/simulation/f2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f2polvcv")
		outsheet f2polvcv* in 1/29 using "Data/simulation/f2-vcv.txt", replace 
	restore	

etreg f3s4.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f3pol")
		outsheet f3pol* in 1 using "Data/simulation/f3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f3polvcv")
		outsheet f3polvcv* in 1/29 using "Data/simulation/f3-vcv.txt", replace 
	restore	

etreg f4s5.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_4
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f4pol")
		outsheet f4pol* in 1 using "Data/simulation/f4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f4polvcv")
		outsheet f4polvcv* in 1/29 using "Data/simulation/f4-vcv.txt", replace 
	restore	

etreg f5s6.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f5pol")
		outsheet f5pol* in 1 using "Data/simulation/f5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f5polvcv")
		outsheet f5polvcv* in 1/29 using "Data/simulation/f5-vcv.txt", replace 
	restore	

etreg f10s11.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f10pol")
		outsheet f10pol* in 1 using "Data/simulation/f10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f10polvcv")
		outsheet f10polvcv* in 1/29 using "Data/simulation/f10-vcv.txt", replace 
	restore	

etreg f15s16.polempowerment s.polity2 l.polity2 s.lpec l.lpec year, ///
	treat(warDummy=l.neighboringcivilwar l2.neighboringcivilwar l.neighboringInterStateWar_excldd ///
	l2.neighboringInterStateWar_excldd s.polity2 l.polity2 s.lpec l.lpec year) vce(cluster ccode)	
estimates store IV_polempowerment_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("f15pol")
		outsheet f15pol* in 1 using "Data/simulation/f15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("f15polvcv")
		outsheet f15polvcv* in 1/29 using "Data/simulation/f15-vcv.txt", replace 
	restore	
********************************************** Table A3 to latex
esttab IV_polempowerment_0 IV_polempowerment_1 IV_polempowerment_2 IV_polempowerment_3 IV_polempowerment_4 IV_polempowerment_5 IV_polempowerment_10 IV_polempowerment_15 ///
 using "Tables/IV_polempowerment.tex",se parentheses label star(* 0.10 ** 0.05 *** 0.01) ///
 nonumbers mtitles("\shortstack{Model 17\\(current)}" "\shortstack{Model 18\\(1-year)}" "\shortstack{Model 19\\(2-year)}" "\shortstack{Model 20\\(3-year)}" "\shortstack{Model 21\\(4-year)}" "\shortstack{Model 22\\(5-year)}" "\shortstack{Model 23\\(10-year)}" "\shortstack{Model 24\\(15-year)}") ///
 title(Endogenous treatment-regression models of the effect of war on future changes in women’s political empowerment\label{ivpolempowerment})  replace 
	

********************** Appendix Table A4: Models 25-32 (for Fig 5(a))********************** 	
xtreg s.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_wardur_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur0")
		outsheet fe_polemwardur0* in 1 using "Data/simulation/fe_polemwardur0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur0vcv")
		outsheet fe_polemwardur0* in 1/20 using "Data/simulation/fe_polemwardur0-vcv.txt", replace 
	restore	
	
xtreg fs2.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur1")
		outsheet fe_polemwardur1* in 1 using "Data/simulation/fe_polemwardur1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur1vcv")
		outsheet fe_polemwardur1* in 1/20 using "Data/simulation/fe_polemwardur1-vcv.txt", replace 
	restore	

xtreg f2s3.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur2")
		outsheet fe_polemwardur2* in 1 using "Data/simulation/fe_polemwardur2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur2vcv")
		outsheet fe_polemwardur2* in 1/20 using "Data/simulation/fe_polemwardur2-vcv.txt", replace 
	restore	

xtreg f3s4.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur3")
		outsheet fe_polemwardur3* in 1 using "Data/simulation/fe_polemwardur3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur3vcv")
		outsheet fe_polemwardur3* in 1/20 using "Data/simulation/fe_polemwardur3-vcv.txt", replace 
	restore	

xtreg f4s5.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_wardur_4 
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur4")
		outsheet fe_polemwardur4* in 1 using "Data/simulation/fe_polemwardur4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur4vcv")
		outsheet fe_polemwardur4* in 1/20 using "Data/simulation/fe_polemwardur4-vcv.txt", replace 
	restore	

xtreg f5s6.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur5")
		outsheet fe_polemwardur5* in 1 using "Data/simulation/fe_polemwardur5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur5vcv")
		outsheet fe_polemwardur5* in 1/20 using "Data/simulation/fe_polemwardur5-vcv.txt", replace 
	restore	

xtreg f10s11.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur10")
		outsheet fe_polemwardur10* in 1 using "Data/simulation/fe_polemwardur10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur10vcv")
		outsheet fe_polemwardur10* in 1/20 using "Data/simulation/fe_polemwardur10-vcv.txt", replace 
	restore	

xtreg f15s16.polempowerment wardur l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_wardur_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemwardur15")
		outsheet fe_polemwardur15* in 1 using "Data/simulation/fe_polemwardur15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemwardur15vcv")
		outsheet fe_polemwardur15* in 1/20 using "Data/simulation/fe_polemwardur15-vcv.txt", replace 
	restore	

********************************************** Table A4 to latex
esttab FE_polemp_wardur_0 FE_polemp_wardur_1 FE_polemp_wardur_2 FE_polemp_wardur_3 FE_polemp_wardur_4 ///
		FE_polemp_wardur_5 FE_polemp_wardur_10 FE_polemp_wardur_15 using "Tables/fepolwardur.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 25\\(current)}" "\shortstack{Model 26\\(1-year)}" "\shortstack{Model 27\\(2-year)}" "\shortstack{Model 28\\(3-year)}" ///
	"\shortstack{Model 29\\(4-year)}" "\shortstack{Model 30\\(5-year)}" "\shortstack{Model 31\\(10-year)}" "\shortstack{Model 32\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war duration on future changes in women's political empowerment\label{polwardur})  replace 



**********************  Appendix Table A5: Models 33-40 (for Fig 5(b))********************** 		
xtreg s.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_bd_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd0")
		outsheet fe_polembd0* in 1 using "Data/simulation/fe_polembd0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd0vcv")
		outsheet fe_polembd0* in 1/20 using "Data/simulation/fe_polembd0-vcv.txt", replace 
	restore	

xtreg fs2.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd1")
		outsheet fe_polembd1* in 1 using "Data/simulation/fe_polembd1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd1vcv")
		outsheet fe_polembd1* in 1/20 using "Data/simulation/fe_polembd1-vcv.txt", replace 
	restore	

xtreg f2s3.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd2")
		outsheet fe_polembd2* in 1 using "Data/simulation/fe_polembd2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd2vcv")
		outsheet fe_polembd2* in 1/20 using "Data/simulation/fe_polembd2-vcv.txt", replace 
	restore
	
xtreg f3s4.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd3")
		outsheet fe_polembd3* in 1 using "Data/simulation/fe_polembd3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd3vcv")
		outsheet fe_polembd3* in 1/20 using "Data/simulation/fe_polembd3-vcv.txt", replace 
	restore

xtreg f4s5.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_bd_4 
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd4")
		outsheet fe_polembd4* in 1 using "Data/simulation/fe_polembd4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd4vcv")
		outsheet fe_polembd4* in 1/20 using "Data/simulation/fe_polembd4-vcv.txt", replace 
	restore

xtreg f5s6.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd5")
		outsheet fe_polembd5* in 1 using "Data/simulation/fe_polembd5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd5vcv")
		outsheet fe_polembd5* in 1/20 using "Data/simulation/fe_polembd5-vcv.txt", replace 
	restore

xtreg f10s11.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd10")
		outsheet fe_polembd10* in 1 using "Data/simulation/fe_polembd10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd10vcv")
		outsheet fe_polembd10* in 1/20 using "Data/simulation/fe_polembd10-vcv.txt", replace 
	restore
	
xtreg f15s16.polempowerment ln_bdeaths l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polembd15")
		outsheet fe_polembd15* in 1 using "Data/simulation/fe_polembd15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polembd15vcv")
		outsheet fe_polembd15* in 1/20 using "Data/simulation/fe_polembd15-vcv.txt", replace 
	restore
********************************************** Table A5 to latex	
esttab FE_polemp_bd_0 FE_polemp_bd_1 FE_polemp_bd_2 FE_polemp_bd_3 FE_polemp_bd_4 ///
		FE_polemp_bd_5 FE_polemp_bd_10 FE_polemp_bd_15 using "Tables/fepolbdeath.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 33\\(current)}" "\shortstack{Model 34\\(1-year)}" "\shortstack{Model 35\\(2-year)}" "\shortstack{Model 36\\(3-year)}" ///
	"\shortstack{Model 37\\(4-year)}" "\shortstack{Model 38\\(5-year)}" "\shortstack{Model 39\\(10-year)}" "\shortstack{Model 40\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of battle deaths on future changes in women's political empowerment\label{polbdeath})  replace 
	

********************** Appendix Table A6: Models 41-48 (for Fig 6(a))********************** 	
xtreg s.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility0")
		outsheet fe_fertility0* in 1 using "Data/simulation/fe_fertility0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility0vcv")
		outsheet fe_fertility0* in 1/20 using "Data/simulation/fe_fertility0-vcv.txt", replace 
	restore	

xtreg fs2.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility1")
		outsheet fe_fertility1* in 1 using "Data/simulation/fe_fertility1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility1vcv")
		outsheet fe_fertility1* in 1/20 using "Data/simulation/fe_fertility1-vcv.txt", replace 
	restore	

xtreg f2s3.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year   l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility2")
		outsheet fe_fertility2* in 1 using "Data/simulation/fe_fertility2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility2vcv")
		outsheet fe_fertility2* in 1/20 using "Data/simulation/fe_fertility2-vcv.txt", replace 
	restore	

xtreg f3s4.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year   l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility3")
		outsheet fe_fertility3* in 1 using "Data/simulation/fe_fertility3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility3vcv")
		outsheet fe_fertility3* in 1/20 using "Data/simulation/fe_fertility3-vcv.txt", replace 
	restore	

xtreg f4s5.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_4
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility4")
		outsheet fe_fertility4* in 1 using "Data/simulation/fe_fertility4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility4vcv")
		outsheet fe_fertility4* in 1/20 using "Data/simulation/fe_fertility4-vcv.txt", replace 
	restore	

xtreg f5s6.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year   l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility5")
		outsheet fe_fertility5* in 1 using "Data/simulation/fe_fertility5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility5vcv")
		outsheet fe_fertility5* in 1/20 using "Data/simulation/fe_fertility5-vcv.txt", replace 
	restore	
	
xtreg f10s11.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility10")
		outsheet fe_fertility10* in 1 using "Data/simulation/fe_fertility10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility10vcv")
		outsheet fe_fertility10* in 1/20 using "Data/simulation/fe_fertility10-vcv.txt", replace 
	restore	

xtreg f15s16.WBfertility warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertility15")
		outsheet fe_fertility15* in 1 using "Data/simulation/fe_fertility15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertility15vcv")
		outsheet fe_fertility15* in 1/20 using "Data/simulation/fe_fertility15-vcv.txt", replace 
	restore	
********************************************** Table A6 to latex	
esttab FE_fertility_0 FE_fertility_1 FE_fertility_2 FE_fertility_3 FE_fertility_4 ///
		FE_fertility_5 FE_fertility_10 FE_fertility_15 using "Tables/fefertility.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 41\\(current)}" "\shortstack{Model 42\\(1-year)}" "\shortstack{Model 43\\(2-year)}" "\shortstack{Model 44\\(3-year)}" ///
	"\shortstack{Model 45\\(4-year)}" "\shortstack{Model 46\\(5-year)}" "\shortstack{Model 47\\(10-year)}" "\shortstack{Model 48\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war on future changes in fertility rates\label{fefertility})  replace 
	

********************** Appendix Table A7: Models 49-56 (for Fig 6(b))********************** 		
xtreg s.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_0
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist0")
		outsheet fe_fertilityexist0* in 1 using "Data/simulation/fe_fertilityexist0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist0vcv")
		outsheet fe_fertilityexist0* in 1/20 using "Data/simulation/fe_fertilityexist0-vcv.txt", replace 
	restore	
	
xtreg fs2.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_1
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist1")
		outsheet fe_fertilityexist1* in 1 using "Data/simulation/fe_fertilityexist1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist1vcv")
		outsheet fe_fertilityexist1* in 1/20 using "Data/simulation/fe_fertilityexist1-vcv.txt", replace 
	restore	
	
xtreg f2s3.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_2
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist2")
		outsheet fe_fertilityexist2* in 1 using "Data/simulation/fe_fertilityexist2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist2vcv")
		outsheet fe_fertilityexist2* in 1/20 using "Data/simulation/fe_fertilityexist2-vcv.txt", replace 
	restore	
	

xtreg f3s4.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_3
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist3")
		outsheet fe_fertilityexist3* in 1 using "Data/simulation/fe_fertilityexist3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist3vcv")
		outsheet fe_fertilityexist3* in 1/20 using "Data/simulation/fe_fertilityexist3-vcv.txt", replace 
	restore	

xtreg f4s5.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_4
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist4")
		outsheet fe_fertilityexist4* in 1 using "Data/simulation/fe_fertilityexist4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist4vcv")
		outsheet fe_fertilityexist4* in 1/20 using "Data/simulation/fe_fertilityexist4-vcv.txt", replace 
	restore	

xtreg f5s6.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_5
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist5")
		outsheet fe_fertilityexist5* in 1 using "Data/simulation/fe_fertilityexist5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist5vcv")
		outsheet fe_fertilityexist5* in 1/20 using "Data/simulation/fe_fertilityexist5-vcv.txt", replace 
	restore	

xtreg f10s11.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_10
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist10")
		outsheet fe_fertilityexist10* in 1 using "Data/simulation/fe_fertilityexist10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist10vcv")
		outsheet fe_fertilityexist10* in 1/20 using "Data/simulation/fe_fertilityexist10-vcv.txt", replace 
	restore	

xtreg f15s16.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_15
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fertilityexist15")
		outsheet fe_fertilityexist15* in 1 using "Data/simulation/fe_fertilityexist15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fertilityexist15vcv")
		outsheet fe_fertilityexist15* in 1/20 using "Data/simulation/fe_fertilityexist15-vcv.txt", replace 
	restore

********************************************** Table A7 to latex	
esttab FE_fertility_exist_0 FE_fertility_exist_1 FE_fertility_exist_2 FE_fertility_exist_3 FE_fertility_exist_4 ///
		FE_fertility_exist_5 FE_fertility_exist_10 FE_fertility_exist_15 using "Tables/fefertilityexistential.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 49\\(current)}" "\shortstack{Model 50\\(1-year)}" "\shortstack{Model 51\\(2-year)}" "\shortstack{Model 52\\(3-year)}" ///
	"\shortstack{Model 53\\(4-year)}" "\shortstack{Model 54\\(5-year)}" "\shortstack{Model 55\\(10-year)}" "\shortstack{Model 56\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of existential war on future changes in fertility rates\label{fefertilityexistential})  replace 
	

**********************Appendix Table A8: Models 57-61 (for Fig 7(a))********************** 			
*rescale population varibable
replace lpop = lpop*100
replace lWBmalepop = lWBmalepop*100
replace lWBfepop = lWBfepop*100
xtreg s.lmilper_pc warDummy l.lmilper_pc s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_milper
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_milper")
		outsheet fe_milper* in 1 using "Data/simulation/fe_milper-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_milpervcv")
		outsheet fe_milpervcv* in 1/20 using "Data/simulation/fe_milper-vcv.txt", replace 
	restore	

xtreg s.lpop warDummy l.lpop s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_pop
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_pop")
		outsheet fe_pop* in 1 using "Data/simulation/fe_pop-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_popvcv")
		outsheet fe_popvcv* in 1/20 using "Data/simulation/fe_pop-vcv.txt", replace 
	restore	

xtreg s.lWBmalepop warDummy l.lpop s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_mpop
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_mpop")
		outsheet fe_mpop* in 1 using "Data/simulation/fe_mpop-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_mpopvcv")
		outsheet fe_mpopvcv* in 1/20 using "Data/simulation/fe_mpop-vcv.txt", replace 
	restore

xtreg s.lWBfepop warDummy l.lpop s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_fpop
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_fpop")
		outsheet fe_fpop* in 1 using "Data/simulation/fe_fpop-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_fpopvcv")
		outsheet fe_fpopvcv* in 1/20 using "Data/simulation/fe_fpop-vcv.txt", replace 
	restore

xtreg irregular_dummy warDummy s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_irregular
	mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_irregular")
		outsheet fe_irregular* in 1 using "Data/simulation/fe_irregular-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_irregularvcv")
		outsheet fe_irregularvcv* in 1/20 using "Data/simulation/fe_irregular-vcv.txt", replace 
	restore

********************************************** Table A8 to latex
esttab FE_milper  FE_pop  FE_mpop FE_fpop FE_irregular ///
		using "Tables/FEintermed.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 57\\($\Delta$ mil. per)}" "\shortstack{Model 58\\($\Delta$ population)}" "\shortstack{Model 59\\($\Delta$ male population)}" "\shortstack{Model 60\\($\Delta$ female population)}" ///
	"\shortstack{Model 61\\(irregular leader change)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war on intermediate variables\label{FEintermed})  replace 
		
********************** Appendix Table A9: Models 62-69 (for Fig 7(b-e))	
xtreg s.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_intermed_0
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed0")
		outsheet fe_polemintermed0* in 1 using "Data/simulation/fe_polemintermed0-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed0vcv")
		outsheet fe_polemintermed0* in 1/20 using "Data/simulation/fe_polemintermed0-vcv.txt", replace 
		
xtreg fs2.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_1
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed1")
		outsheet fe_polemintermed1* in 1 using "Data/simulation/fe_polemintermed1-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed1vcv")
		outsheet fe_polemintermed1* in 1/20 using "Data/simulation/fe_polemintermed1-vcv.txt", replace 

xtreg f2s3.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_2
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed2")
		outsheet fe_polemintermed2* in 1 using "Data/simulation/fe_polemintermed2-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed2vcv")
		outsheet fe_polemintermed2* in 1/20 using "Data/simulation/fe_polemintermed2-vcv.txt", replace 


xtreg f3s4.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_3
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed3")
		outsheet fe_polemintermed3* in 1 using "Data/simulation/fe_polemintermed3-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed3vcv")
		outsheet fe_polemintermed3* in 1/20 using "Data/simulation/fe_polemintermed3-vcv.txt", replace 

xtreg f4s5.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_4
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed4")
		outsheet fe_polemintermed4* in 1 using "Data/simulation/fe_polemintermed4-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed4vcv")
		outsheet fe_polemintermed4* in 1/20 using "Data/simulation/fe_polemintermed4-vcv.txt", replace 

xtreg f5s6.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_5
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed5")
		outsheet fe_polemintermed5* in 1 using "Data/simulation/fe_polemintermed5-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed5vcv")
		outsheet fe_polemintermed5* in 1/20 using "Data/simulation/fe_polemintermed5-vcv.txt", replace 

xtreg f10s11.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intermed_10
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed10")
		outsheet fe_polemintermed10* in 1 using "Data/simulation/fe_polemintermed10-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed10vcv")
		outsheet fe_polemintermed10* in 1/20 using "Data/simulation/fe_polemintermed10-vcv.txt", replace 


xtreg f15s16.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_intermed_15
mat beta = e(b)
	mat vcov = e(V)	
	preserve
		svmat beta, names("fe_polemintermed15")
		outsheet fe_polemintermed15* in 1 using "Data/simulation/fe_polemintermed15-beta.txt", replace 
	restore		
	preserve
		svmat vcov, names("fe_polemintermed15vcv")
		outsheet fe_polemintermed15* in 1/20 using "Data/simulation/fe_polemintermed15-vcv.txt", replace 

********************************************** Table A9 to latex
esttab FE_polemp_intermed_0 FE_polemp_intermed_1 FE_polemp_intermed_2 FE_polemp_intermed_3 FE_polemp_intermed_4 FE_polemp_intermed_5 ///
		FE_polemp_intermed_10 FE_polemp_intermed_15 using "Tables/intermpolempowerment.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 62\\(current)}" "\shortstack{Model 63\\(1-year)}" "\shortstack{Model 64\\(2-year)}" "\shortstack{Model 65\\(3-year)}" ///
	"\shortstack{Model 66\\(4-year)}" "\shortstack{Model 67\\(5-year)}" "\shortstack{Model 68\\(10-year)}" "\shortstack{Model 69\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of intermediate variables on future changes in women's empowerment\label{intermpolempowerment})  replace 
	


**************************************************************************************** 
************************* Appendix B and C  ******************************************** 

********************** Appendix Table B1: Models 70-77********************** 
xtreg d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_d0
xtreg fd.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d1
xtreg f2d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d2
xtreg f3d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d3
xtreg f4d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d4
xtreg f5d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d5
xtreg f10d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_d10
xtreg f15d.polempowerment warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_d15	
esttab FE_polemp_d0 FE_polemp_d1 FE_polemp_d2 FE_polemp_d3 FE_polemp_d4 FE_polemp_d5 ///
		FE_polemp_d10 FE_polemp_d15 using "Tables/fyearonyearpolempower.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 70\\(current)}" "\shortstack{Model 71\\(1-year)}" "\shortstack{Model 72\\(2-year)}" "\shortstack{Model 73\\(3-year)}" ///
	"\shortstack{Model 74\\(4-year)}" "\shortstack{Model 75\\(5-year)}" "\shortstack{Model 76\\(10-year)}" "\shortstack{Model 77\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war on future year-on-year changes in women's empowerment\label{fyearonyearpolempower})  replace 
 

********************** Appendix Table B2: Models 78-85 ********************** 
xtreg s.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_bd_cum_0
xtreg fs2.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_1
xtreg f2s3.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_2
xtreg f3s4.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_3
xtreg f4s5.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_bd_cum_4 
xtreg f5s6.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_5
xtreg f10s11.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_10
xtreg f15s16.polempowerment ln_bdeaths_cum l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_bd_cum_15
esttab FE_polemp_bd_cum_0 FE_polemp_bd_cum_1 FE_polemp_bd_cum_2 FE_polemp_bd_cum_3 FE_polemp_bd_cum_4 ///
	FE_polemp_bd_cum_5 FE_polemp_bd_cum_10 FE_polemp_bd_cum_15 using "Tables/culmudeaths.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 78\\(current)}" "\shortstack{Model 79\\(1-year)}" "\shortstack{Model 80\\(2-year)}" "\shortstack{Model 81\\(3-year)}" ///
	"\shortstack{Model 82\\(4-year)}" "\shortstack{Model 83\\(5-year)}" "\shortstack{Model 84\\(10-year)}" "\shortstack{Model 85\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of cumulative battle deaths on future changes in women's empowerment\label{culmudeaths})  replace 


********************** Appendix Table B3: Models 86-93**********************  
xtreg s.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_intra_0
xtreg fs2.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_1
xtreg f2s3.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_2
xtreg f3s4.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_3
xtreg f4s5.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_4
xtreg f5s6.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_5
xtreg f10s11.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_10
xtreg f15s16.polempowerment newintra ongoingintra recentintra l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_intra_15
esttab FE_polemp_intra_0 FE_polemp_intra_1 FE_polemp_intra_2 FE_polemp_intra_3 FE_polemp_intra_4 /// 
	FE_polemp_intra_5 FE_polemp_intra_10 FE_polemp_intra_15 using "Tables/intrawarpolempower.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 86\\(current)}" "\shortstack{Model 87\\(1-year)}" "\shortstack{Model 88\\(2-year)}" "\shortstack{Model 89\\(3-year)}" ///
	"\shortstack{Model 90\\(4-year)}" "\shortstack{Model 91\\(5-year)}" "\shortstack{Model 92\\(10-year)}" "\shortstack{Model 93\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of intrastate war on future changes in women's empowerment\label{intrawarpolempower})  replace 


********************** Appendix Table B4: Models 94-101**********************  	
xtreg s.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_inter_0
xtreg fs2.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_1
xtreg f2s3.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_2
xtreg f3s4.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_3
xtreg f4s5.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_4
xtreg f5s6.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_5
xtreg f10s11.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_10
xtreg f15s16.polempowerment newinter ongoinginter recentinter l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_inter_15

esttab FE_polemp_inter_0 FE_polemp_inter_1 FE_polemp_inter_2 FE_polemp_inter_3 FE_polemp_inter_4 ///
 FE_polemp_inter_5 FE_polemp_inter_10 FE_polemp_inter_15 using "Tables/interwarpolempower.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 94\\(current)}" "\shortstack{Model 95\\(1-year)}" "\shortstack{Model 96\\(2-year)}" "\shortstack{Model 97\\(3-year)}" ///
	"\shortstack{Model 98\\(4-year)}" "\shortstack{Model 99\\(5-year)}" "\shortstack{Model 100\\(10-year)}" "\shortstack{Model 101\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of interstate war on future changes in women's empowerment\label{interwarpolempower})  replace 


********************** Appendix Table B5: Models 102-109**********************  
xtreg s.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_exist_0
xtreg fs2.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_1
xtreg f2s3.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_2
xtreg f3s4.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_3
xtreg f4s5.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_4
xtreg f5s6.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_5
xtreg f10s11.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_10
xtreg f15s16.polempowerment newexist ongoingexist recentexist l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_exist_15

esttab FE_polemp_exist_0 FE_polemp_exist_1 FE_polemp_exist_2 FE_polemp_exist_3 FE_polemp_exist_4 ///
 FE_polemp_exist_5 FE_polemp_exist_10 FE_polemp_exist_15 using "Tables/existentialwarpolempower.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 102\\(current)}" "\shortstack{Model 103\\(1-year)}" "\shortstack{Model 104\\(2-year)}" "\shortstack{Model 105\\(3-year)}" ///
	"\shortstack{Model 106\\(4-year)}" "\shortstack{Model 107\\(5-year)}" "\shortstack{Model 108\\(10-year)}" "\shortstack{Model 109\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of existential war on future changes in women's empowerment\label{existentialwarpolempower})  replace 


********************** Appendix Table B6: Models 110-117**********************  
xtreg s.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_0
xtreg fs2.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_1
xtreg f2s3.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_2
xtreg f3s4.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_3
xtreg f4s5.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_4
xtreg f5s6.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_5
xtreg f10s11.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_10
xtreg f15s16.civilparticip newwar ongoingwar recentwar l.civilparticip s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_civilparticip_15
esttab FE_civilparticip_0 FE_civilparticip_1 FE_civilparticip_2 FE_civilparticip_3 FE_civilparticip_4 ///
	FE_civilparticip_5 FE_civilparticip_10 FE_civilparticip_15 using "Tables/fecivilparticip.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 110\\(current)}" "\shortstack{Model 111\\(1-year)}" "\shortstack{Model 112\\(2-year)}" "\shortstack{Model 113\\(3-year)}" ///
	"\shortstack{Model 114\\(4-year)}" "\shortstack{Model 115\\(5-year)}" "\shortstack{Model 116\\(10-year)}" "\shortstack{Model 117\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of types of war on future changes in civil society participation \label{fecivilparticip})  replace 
 

********************** Appendix Table B7: Models 118-125 **********************  
xtreg s.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_0
xtreg fs2.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_1
xtreg f2s3.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_2
xtreg f3s4.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_3
xtreg f4s5.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_4
xtreg f5s6.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_5
xtreg f10s11.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_10
xtreg f15s16.WBfertility existentialwardum l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year s.WBinfantmortality l.WBinfantmortality s.lpop l.lpop  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_exist_rob_15
esttab FE_fertility_exist_rob_0 FE_fertility_exist_rob_1 FE_fertility_exist_rob_2 FE_fertility_exist_rob_3 FE_fertility_exist_rob_4 ///
 FE_fertility_exist_rob_5 FE_fertility_exist_rob_10 FE_fertility_exist_rob_15 using "Tables/fefertilityinfant.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 118\\(current)}" "\shortstack{Model 119\\(1-year)}" "\shortstack{Model 120\\(2-year)}" "\shortstack{Model 121\\(3-year)}" ///
	"\shortstack{Model 122\\(4-year)}" "\shortstack{Model 123\\(5-year)}" "\shortstack{Model 124\\(10-year)}" "\shortstack{Model 125\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of existential war on changes in fertility rates (controlling for infant mortality) \label{fefertilityinfant})  replace 
 

********************** Appendix Table B8: Models 126-133 ********************** 
xtreg s.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_0
xtreg fs2.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_1
xtreg f2s3.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_2
xtreg f3s4.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_3
xtreg f4s5.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_4
xtreg f5s6.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_5
xtreg f10s11.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_10
xtreg f15s16.WBfertility intra_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_intra_15

esttab FE_fertility_intra_0 FE_fertility_intra_1 FE_fertility_intra_2 FE_fertility_intra_3 FE_fertility_intra_4 ///
 FE_fertility_intra_5 FE_fertility_intra_10 FE_fertility_intra_15 using "Tables/intrawarfertility.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 126\\(current)}" "\shortstack{Model 127\\(1-year)}" "\shortstack{Model 128\\(2-year)}" "\shortstack{Model 129\\(3-year)}" ///
	"\shortstack{Model 130\\(4-year)}" "\shortstack{Model 131\\(5-year)}" "\shortstack{Model 132\\(10-year)}" "\shortstack{Model 133\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of intrastate war on future changes in fertility rates \label{intrawarfertility})  replace 
 

********************** Appendix Table B9: Models 134-141**********************  
xtreg s.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_0
xtreg fs2.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_1
xtreg f2s3.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_2
xtreg f3s4.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_3
xtreg f4s5.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_4
xtreg f5s6.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_5
xtreg f10s11.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_10
xtreg f15s16.WBfertility inter_warDummy l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_inter_15

esttab FE_fertility_inter_0 FE_fertility_inter_1 FE_fertility_inter_2 FE_fertility_inter_3 FE_fertility_inter_4 /// 
 FE_fertility_inter_5 FE_fertility_inter_10 FE_fertility_inter_15 using "Tables/interwarfertility.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 134\\(current)}" "\shortstack{Model 135\\(1-year)}" "\shortstack{Model 136\\(2-year)}" "\shortstack{Model 137\\(3-year)}" ///
	"\shortstack{Model 138\\(4-year)}" "\shortstack{Model 139\\(5-year)}" "\shortstack{Model 140\\(10-year)}" "\shortstack{Model 141\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of interstate war on future changes in fertility rates \label{interwarfertility})  replace 
 
 
********************** Appendix Table B10: Models 142-149 ********************** 
xtreg s.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_bd_0
xtreg fs2.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_bd_1
xtreg f2s3.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_bd_2
xtreg f3s4.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_bd_3
xtreg f4s5.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_bd_4
xtreg f5s6.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year  l.neighborWBfertility, fe  vce(cluster ccode)
estimates store FE_fertility_bd_5
xtreg f10s11.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_bd_10
xtreg f15s16.WBfertility ln_bdeaths l.WBfertility s.polity2 l.polity2 s.lpec l.lpec year l.neighborWBfertility , fe  vce(cluster ccode)
estimates store FE_fertility_bd_15
esttab FE_fertility_bd_0 FE_fertility_bd_1 FE_fertility_bd_2 FE_fertility_bd_3 FE_fertility_bd_4 ///
	FE_fertility_bd_5 FE_fertility_bd_10 FE_fertility_bd_15 using "Tables/fertilitybdeath.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 142\\(current)}" "\shortstack{Model 143\\(1-year)}" "\shortstack{Model 144\\(2-year)}" "\shortstack{Model 145\\(3-year)}" ///
	"\shortstack{Model 146\\(4-year)}" "\shortstack{Model 147\\(5-year)}" "\shortstack{Model 148\\(10-year)}" "\shortstack{Model 149\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of battle deaths on future changes in fertility rates \label{fertilitybdeath})  replace 

 
********************** Appendix Table B11: Models 150-158********************** 
xtreg s.lmilex_pc warDummy l.lmilex_pc s.polity2 l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store FE_lmilex
xtreg s.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_lmilex_0
xtreg fs2.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_1
xtreg f2s3.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_2
xtreg f3s4.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_3
xtreg f4s5.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_4
xtreg f5s6.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_5
xtreg f10s11.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_lmilex_10
xtreg f15s16.polempowerment warDummy l.polempowerment s.lmilex_pc l.lmilex_pc s.lpop l.lpop irregular_dummy s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_lmilex_15 
esttab FE_lmilex FE_polemp_lmilex_0 FE_polemp_lmilex_1 FE_polemp_lmilex_2 FE_polemp_lmilex_3 FE_polemp_lmilex_4 ///
	FE_polemp_lmilex_5 FE_polemp_lmilex_10 FE_polemp_lmilex_15 using "Tables/fepolemmilex.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 150\\(military expenditure)}"   "\shortstack{Model 151\\(current)}" "\shortstack{Model 152\\(1-year)}" "\shortstack{Model 153\\(2-year)}" "\shortstack{Model 154\\(3-year)}" ///
	"\shortstack{Model 155\\(4-year)}" "\shortstack{Model 156\\(5-year)}" "\shortstack{Model 157\\(10-year)}" "\shortstack{Model 158\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of war on future changes in women’s empowerment using military expenditures \label{fepolemmilex})  replace 

 
********************** Appendix Table B12: Models 159-166********************** 
xtreg s.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_0
xtreg fs2.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_1
xtreg f2s3.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_2
xtreg f3s4.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_3
xtreg f4s5.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_4
xtreg f5s6.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_5
xtreg f10s11.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_10
xtreg f15s16.polempowerment s.terrthreat l.terrthreat l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempnowar_15
esttab FE_polempnowar_0 FE_polempnowar_1 FE_polempnowar_2 FE_polempnowar_3 FE_polempnowar_4 ///
	FE_polempnowar_5 FE_polempnowar_10 FE_polempnowar_15 using "Tables/fepolempnowar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 159\\(current)}" "\shortstack{Model 160\\(1-year)}" "\shortstack{Model 161\\(2-year)}" "\shortstack{Model 162\\(3-year)}" ///
	"\shortstack{Model 163\\(4-year)}" "\shortstack{Model 164\\(5-year)}" "\shortstack{Model 165\\(10-year)}" "\shortstack{Model 166\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of territorial threat on future changes in women's empowerment (without controlling for war) \label{fepolempnowar})  replace 


********************** Appendix Table B13: Models 167-174********************** 
xtreg s.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_0
xtreg fs2.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_1
xtreg f2s3.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_2
xtreg f3s4.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_3
xtreg f4s5.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_4
xtreg f5s6.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_5
xtreg f10s11.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_10
xtreg f15s16.polempowerment s.terrthreat l.terrthreat warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polempwar_15
esttab FE_polempwar_0 FE_polempwar_1 FE_polempwar_2 FE_polempwar_3 FE_polempwar_4 ///
	FE_polempwar_5 FE_polempwar_10 FE_polempwar_15 using "Tables/fepolempwar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 167\\(current)}" "\shortstack{Model 168\\(1-year)}" "\shortstack{Model 169\\(2-year)}" "\shortstack{Model 170\\(3-year)}" ///
	"\shortstack{Model 171\\(4-year)}" "\shortstack{Model 172\\(5-year)}" "\shortstack{Model 173\\(10-year)}" "\shortstack{Model 174\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Fixed-effects models of the effect of territorial threat on future changes in women's empowerment (controlling for war) \label{fepolempwar})  replace 


********************** Appendix Table B14: Models 175-1 -- 175-8**********************  
xtreg s.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store interaction_0
xtreg fs2.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_1
xtreg f2s3.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_2
xtreg f3s4.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_3
xtreg f4s5.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store interaction_4
xtreg f5s6.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_5
xtreg f10s11.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_10
xtreg f15s16.polempowerment warDummy i.warDummy#c.s.lpec l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store interaction_15
esttab interaction_0 interaction_1 interaction_2 interaction_3 interaction_4 interaction_5 interaction_10 interaction_15 /// 
 using "Tables/interaction.tex",se parentheses label star(* 0.10 ** 0.05 *** 0.01) ///
 nonumbers mtitles("\shortstack{Model 175-1\\(current)}" "\shortstack{Model 175-2\\(1-year)}" "\shortstack{Model 175-3\\(2-year)}" "\shortstack{Model 175-4\\(3-year)}" ///
	"\shortstack{Model 175-5\\(4-year)}" "\shortstack{Model 175-6\\(5-year)}" "\shortstack{Model 175-7\\(10-year)}" "\shortstack{Model 175-8\\(15-year)}") ///
 title(Interaction effects between change in energy consumption and war on changes in women's empowerment \label{interaction})  replace 



**************************************************************************************** 
***********************Robustness Checks and Additional Mechanisms: Appendix C
******************************************** ********************** ********************** 

********************** Appendix Table C1: Models 176 -177 ********************** 
xtreg irregular_dummy warDummy s.lpec l.lpec year, fe vce(cluster ccode)
estimates store irregnopolity
xtreg s.polity2 warDummy l.polity2 s.lpec l.lpec year, fe vce(cluster ccode)
estimates store polity_intermed
esttab irregnopolity polity_intermed /// 
 using "Tables/intermedrbst.tex",se parentheses label star(* 0.10 ** 0.05 *** 0.01) ///
 nonumbers mtitles("\shortstack{Model 176\\(DV: Irregular leader change w/o polity)}"  "\shortstack{Model 177\\(DV: $\Delta$ polity2)}") ///
 title(Robustness Check: Irregular regime change and polity as intermediate variables \label{intermedrbst})  replace 
 

********************** Appendix Table C2: Models 178 -185********************** 
xtreg s.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polempnopolity_0
xtreg fs2.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_1
xtreg f2s3.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_2
xtreg f3s4.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_3
xtreg f4s5.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_4
xtreg f5s6.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_5
xtreg f10s11.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempnopolity_10
xtreg f15s16.polempowerment warDummy l.polempowerment s.lmilper_pc l.lmilper_pc s.lpop l.lpop irregular_dummy s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polempnopolity_15
esttab polempnopolity_0 polempnopolity_1 polempnopolity_2 polempnopolity_3 polempnopolity_4 ///
	polempnopolity_5 polempnopolity_10 polempnopolity_15 using "Tables/fepolempnopolity.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 178\\(current)}" "\shortstack{Model 179\\(1-year)}" "\shortstack{Model 180\\(2-year)}" "\shortstack{Model 181\\(3-year)}" ///
	"\shortstack{Model 182\\(4-year)}" "\shortstack{Model 183\\(5-year)}" "\shortstack{Model 184\\(10-year)}" "\shortstack{Model 185\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of irregular leadership change on future changes in women's empowerment(without polity) \label{fepolempnopolity})  replace 


********************** Appendix Table C3: Models 186 -193********************** 
xtreg s.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polempvdem_0
xtreg fs2.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_1
xtreg f2s3.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_2
xtreg f3s4.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_3
xtreg f4s5.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_4
xtreg f5s6.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_5
xtreg f10s11.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polempvdem_10
xtreg f15s16.polempowerment warDummy l.polempowerment s.civilsoci l.civilsoci s.cleanelec l.cleanelec s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polempvdem_15
esttab polempvdem_0 polempvdem_1 polempvdem_2 polempvdem_3 polempvdem_4 ///
	polempvdem_5 polempvdem_10 polempvdem_15 using "Tables/fepolempvdem.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 186\\(current)}" "\shortstack{Model 187\\(1-year)}" "\shortstack{Model 188\\(2-year)}" "\shortstack{Model 189\\(3-year)}" ///
	"\shortstack{Model 190\\(4-year)}" "\shortstack{Model 191\\(5-year)}" "\shortstack{Model 192\\(10-year)}" "\shortstack{Model 193\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of civil society index and clean election index on future changes in women's empowerment \label{fepolempvdem})  replace 


********************** Appendix Table C4: Models 194 -201********************** 
xtreg s.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemstriksnowar_0
xtreg fs2.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_1
xtreg f2s3.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_2
xtreg f3s4.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_3
xtreg f4s5.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_4
xtreg f5s6.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_5
xtreg f10s11.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstriksnowar_10
xtreg f15s16.polempowerment striksDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemstriksnowar_15
esttab polemstriksnowar_0 polemstriksnowar_1 polemstriksnowar_2 polemstriksnowar_3 polemstriksnowar_4 ///
	polemstriksnowar_5 polemstriksnowar_10 polemstriksnowar_15 using "Tables/fepolemstriksnowar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 194\\(current)}" "\shortstack{Model 195\\(1-year)}" "\shortstack{Model 196\\(2-year)}" "\shortstack{Model 197\\(3-year)}" ///
	"\shortstack{Model 198\\(4-year)}" "\shortstack{Model 199\\(5-year)}" "\shortstack{Model 200\\(10-year)}" "\shortstack{Model 201\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of strikes on future changes in women's empowerment \label{fepolemstriksnowar})  replace 


********************** Appendix Table C5: Models 202 -209********************** 
xtreg s.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemgovnowar_0
xtreg fs2.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_1
xtreg f2s3.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_2
xtreg f3s4.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_3
xtreg f4s5.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_4
xtreg f5s6.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_5
xtreg f10s11.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemgovnowar_10
xtreg f15s16.polempowerment gov_crisesDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemgovnowar_15
esttab polemgovnowar_0 polemgovnowar_1 polemgovnowar_2 polemgovnowar_3 polemgovnowar_4 ///
	polemgovnowar_5 polemgovnowar_10 polemgovnowar_15 using "Tables/fepolemgovnowar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 202\\(current)}" "\shortstack{Model 203\\(1-year)}" "\shortstack{Model 204\\(2-year)}" "\shortstack{Model 205\\(3-year)}" ///
	"\shortstack{Model 206\\(4-year)}" "\shortstack{Model 207\\(5-year)}" "\shortstack{Model 208\\(10-year)}" "\shortstack{Model 209\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of government crises on future changes in  women's empowerment \label{polemgovnowar})  replace 


********************** Appendix Table C6: Models 210 -217********************** 
xtreg s.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemriotnowar_0
xtreg fs2.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_1
xtreg f2s3.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_2
xtreg f3s4.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_3
xtreg f4s5.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_4
xtreg f5s6.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_5
xtreg f10s11.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemriotnowar_10
xtreg f15s16.polempowerment riotsDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemriotnowar_15
esttab polemriotnowar_0 polemriotnowar_1 polemriotnowar_2 polemriotnowar_3 polemriotnowar_4 ///
	polemriotnowar_5 polemriotnowar_10 polemriotnowar_15 using "Tables/fepolemriotnowar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 210\\(current)}" "\shortstack{Model 211\\(1-year)}" "\shortstack{Model 212\\(2-year)}" "\shortstack{Model 213\\(3-year)}" ///
	"\shortstack{Model 214\\(4-year)}" "\shortstack{Model 215\\(5-year)}" "\shortstack{Model 216\\(10-year)}" "\shortstack{Model 217\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of riots on future changes in women's empowerment \label{fepolemriotnowar})  replace 


********************** Appendix Table C7: Models 218 -225********************** 
xtreg s.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemdemonstrationnowar_0
xtreg fs2.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_1
xtreg f2s3.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_2
xtreg f3s4.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_3
xtreg f4s5.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_4
xtreg f5s6.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_5
xtreg f10s11.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationnowar_10
xtreg f15s16.polempowerment demonstrationDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemdemonstrationnowar_15
esttab polemdemonstrationnowar_0 polemdemonstrationnowar_1 polemdemonstrationnowar_2 polemdemonstrationnowar_3 polemdemonstrationnowar_4 ///
	polemdemonstrationnowar_5 polemdemonstrationnowar_10 polemdemonstrationnowar_15 using "Tables/fepolemdemonstrationnowar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 218\\(current)}" "\shortstack{Model 219\\(1-year)}" "\shortstack{Model 220\\(2-year)}" "\shortstack{Model 221\\(3-year)}" ///
	"\shortstack{Model 222\\(4-year)}" "\shortstack{Model 223\\(5-year)}" "\shortstack{Model 224\\(10-year)}" "\shortstack{Model 225\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of demonstrations on future changes in women's empowerment \label{polemdemonstrationnowar})  replace 


********************** Appendix Table C8: Models 226 -233********************** 
xtreg s.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemstrikswar_0
xtreg fs2.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_1
xtreg f2s3.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_2
xtreg f3s4.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_3
xtreg f4s5.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_4
xtreg f5s6.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_5
xtreg f10s11.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemstrikswar_10
xtreg f15s16.polempowerment striksDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemstrikswar_15
esttab polemstrikswar_0 polemstrikswar_1 polemstrikswar_2 polemstrikswar_3 polemstrikswar_4 ///
	polemstrikswar_5 polemstrikswar_10 polemstrikswar_15 using "Tables/fepolemstrikswar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 226\\(current)}" "\shortstack{Model 227\\(1-year)}" "\shortstack{Model 228\\(2-year)}" "\shortstack{Model 229\\(3-year)}" ///
	"\shortstack{Model 230\\(4-year)}" "\shortstack{Model 231\\(5-year)}" "\shortstack{Model 232\\(10-year)}" "\shortstack{Model 233\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of strikes on future changes in women's empowerment (controlling for war) \label{fepolemstrikswar})  replace 


********************** Appendix Table C9: Models 234 -241********************** 
xtreg s.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemdemonstrationwar_0
xtreg fs2.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_1
xtreg f2s3.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_2
xtreg f3s4.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_3
xtreg f4s5.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_4
xtreg f5s6.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_5
xtreg f10s11.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polemdemonstrationwar_10
xtreg f15s16.polempowerment demonstrationDummy warDummy l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polemdemonstrationwar_15
esttab polemdemonstrationwar_0 polemdemonstrationwar_1 polemdemonstrationwar_2 polemdemonstrationwar_3 polemdemonstrationwar_4 ///
	polemdemonstrationwar_5 polemdemonstrationwar_10 polemdemonstrationwar_15 using "Tables/fepolemdemonstrationwar.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 234\\(current)}" "\shortstack{Model 235\\(1-year)}" "\shortstack{Model 236\\(2-year)}" "\shortstack{Model 237\\(3-year)}" ///
	"\shortstack{Model 238\\(4-year)}" "\shortstack{Model 239\\(5-year)}" "\shortstack{Model 240\\(10-year)}" "\shortstack{Model 241\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of demonstrations on future changes in women's empowerment(controlling for war) \label{polemdemonstrationwar})  replace 


**********************Appendix Table C10: Models 242 -249********************** 
xtreg s.polempowerment warDummy warDummy#c.postWWII c.postWWII l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polem_wwII_0
xtreg fs2.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_1
xtreg f2s3.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_2
xtreg f3s4.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_3
xtreg f4s5.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store polem_wwII_4
xtreg f5s6.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_5
xtreg f10s11.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_10
xtreg f15s16.polempowerment warDummy warDummy#c.postWWII c.postWWII  l.polempowerment s.polity2 l.polity2 s.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store polem_wwII_15
esttab polem_wwII_0 polem_wwII_1 polem_wwII_2 polem_wwII_3 polem_wwII_4 ///
	polem_wwII_5 polem_wwII_10 polem_wwII_15 using "Tables/fepolemwwII.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 242\\(current)}" "\shortstack{Model 243\\(1-year)}" "\shortstack{Model 244\\(2-year)}" "\shortstack{Model 245\\(3-year)}" ///
	"\shortstack{Model 246\\(4-year)}" "\shortstack{Model 247\\(5-year)}" "\shortstack{Model 248\\(10-year)}" "\shortstack{Model 249\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of WWII on future changes in women's empowerment \label{fepolemwwII})  replace 


********************** Appendix Table C11: Models 250 -257********************** 
xtreg s.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_robust_0
xtreg fs2.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_1
xtreg f2s3.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_2
xtreg f3s4.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_3
xtreg f4s5.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_4
xtreg f5s6.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_5
xtreg f10s11.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_robust_10
xtreg f15s16.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_robust_15
esttab FE_polemp_robust_0 FE_polemp_robust_1 FE_polemp_robust_2 FE_polemp_robust_3 FE_polemp_robust_4 ///
 FE_polemp_robust_5 FE_polemp_robust_10 FE_polemp_robust_15 using "Tables/polemprobustls.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 250\\(current)}" "\shortstack{Model 251\\(1-year)}" "\shortstack{Model 252\\(2-year)}" "\shortstack{Model 253\\(3-year)}" ///
	"\shortstack{Model 254\\(4-year)}" "\shortstack{Model 255\\(5-year)}" "\shortstack{Model 256\\(10-year)}" "\shortstack{Model 257\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of war on future changes in women's empowerment using lags of changes in control variables\label{polemprobustls})  replace 


********************** Appendix Table C12: Models 258 -265**********************  
xtreg s.polempowerment newwar ongoingwar recentwar l.polempowerment ls.polity2 l.polity2 ls.lpec l.lpec i.year l.neighborpolempowerment, fe vce(cluster ccode)
estimates store FE_polemp_yearFE_0
xtreg fs2.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_1
xtreg f2s3.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_2
xtreg f3s4.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_3
xtreg f4s5.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_4
xtreg f5s6.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_5
xtreg f10s11.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_10
xtreg f15s16.polempowerment newwar ongoingwar recentwar l.polempowerment s.polity2 l.polity2 s.lpec l.lpec i.year l.neighborpolempowerment, fe  vce(cluster ccode)
estimates store FE_polemp_yearFE_15
esttab FE_polemp_yearFE_0 FE_polemp_yearFE_1 FE_polemp_yearFE_2 FE_polemp_yearFE_3 FE_polemp_yearFE_4 ///
 FE_polemp_yearFE_5 FE_polemp_yearFE_10 FE_polemp_yearFE_15 using "Tables/polemprobustyear.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 258\\(current)}" "\shortstack{Model 259\\(1-year)}" "\shortstack{Model 260\\(2-year)}" "\shortstack{Model 261\\(3-year)}" ///
	"\shortstack{Model 262\\(4-year)}" "\shortstack{Model 263\\(5-year)}" "\shortstack{Model 264\\(10-year)}" "\shortstack{Model 265\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of war on future changes in women's empowerment with year fixed effects\label{polemprobustyear})  replace 


********************** Appendix Table C13: Models 266 -273********************** 
xtreg s.polempowerment newwar ongoingwar recentwar, fe vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_0
xtreg fs2.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_1
xtreg f2s3.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_2
xtreg f3s4.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_3
xtreg f4s5.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_4
xtreg f5s6.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_5
xtreg f10s11.polempowerment newwar ongoingwar recentwar, fe  vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_10
xtreg f15s16.polempowerment newwar ongoingwar recentwar, fe vce(cluster ccode)
estimates store FE_polemp_robustwocontrs_15
esttab FE_polemp_robustwocontrs_0  FE_polemp_robustwocontrs_1 FE_polemp_robustwocontrs_2 FE_polemp_robustwocontrs_3 FE_polemp_robustwocontrs_4 ///
 FE_polemp_robustwocontrs_5 FE_polemp_robustwocontrs_10 FE_polemp_robustwocontrs_15 using "Tables/polemprobustwocontros.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 266\\(current)}" "\shortstack{Model 267\\(1-year)}" "\shortstack{Model 268\\(2-year)}" "\shortstack{Model 269\\(3-year)}" ///
	"\shortstack{Model 270\\(4-year)}" "\shortstack{Model 271\\(5-year)}" "\shortstack{Model 272\\(10-year)}" "\shortstack{Model 273\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of war on future changes in women's empowerment with control variables\label{polemprobustwocontros})  replace 


********************** Appendix Table C14: Models 274 -281**********************  
 *Simple model with year fixed effects
xtreg s.polempowerment newwar ongoingwar recentwar i.year, fe vce(cluster ccode)
estimates store FE_polemp_robustsimp_0
xtreg fs2.polempowerment newwar ongoingwar recentwar i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_1
xtreg f2s3.polempowerment newwar ongoingwar recentwar i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_2
xtreg f3s4.polempowerment newwar ongoingwar recentwar i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_3
xtreg f4s5.polempowerment newwar ongoingwar recentwar i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_4
xtreg f5s6.polempowerment newwar ongoingwar recentwa i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_5
xtreg f10s11.polempowerment newwar ongoingwar recentwar i.year, fe  vce(cluster ccode)
estimates store FE_polemp_robustsimp_10
xtreg f15s16.polempowerment newwar ongoingwar recentwar i.year, fe vce(cluster ccode)
estimates store FE_polemp_robustsimp_15
esttab FE_polemp_robustsimp_0 FE_polemp_robustsimp_1 FE_polemp_robustsimp_2 FE_polemp_robustsimp_3 FE_polemp_robustsimp_4 FE_polemp_robustsimp_5 ///
 FE_polemp_robustsimp_10 FE_polemp_robustsimp_15 using "Tables/polemprobustsimpyear.tex",se parentheses ///
	nonumbers mtitles("\shortstack{Model 274\\(current)}" "\shortstack{Model 275\\(1-year)}" "\shortstack{Model 276\\(2-year)}" "\shortstack{Model 277\\(3-year)}" ///
	"\shortstack{Model 278\\(4-year)}" "\shortstack{Model 279\\(5-year)}" "\shortstack{Model 280\\(10-year)}" "\shortstack{Model 281\\(15-year)}") ///
 label star(* 0.10 ** 0.05 *** 0.01) title(Robustness Check: Fixed-effects models of the effect of war on future changes in women's empowerment with control variables and year fixed effects\label{polemprobustsimpyear})  replace 


