capture log close
log using "$Logdir\LOG_an_SMFQ_traj_TRA_REV1.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2024-August-02
* Description: Model the SMFQ trajectories separated by trauma or bullying status
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Reshape the data for used in mixed effects linear growth models
* 3 - Run mixed effects models and plot 


********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion == 1


cd "$Datadir\Trajectories_TRA"

********************************************************************************
* 2 - Reshape the data for used in mixed effects linear growth models
********************************************************************************
* restrict to variables neccesary for analysis 
keep aln qlet ASD bin* ///
	mfq_t1-mfq_t11 ///
	TRA* ///
	male parity matsoc mat_degree finprob ant_anx post_anx preg_EPDS_bin postpreg_EPDS_bin homeowner dwelltype matage 
	
* Generate an id variable to reshape the data 
gen number = _n

* Reshape the data wide to long  
reshape long mfq_t, i(number) j(tpoint) 

gen time = 10 if tpoint == 1
replace time = 12 if tpoint == 2
replace time = 13 if tpoint == 3
replace time = 16 if tpoint == 4 
replace time = 17 if tpoint == 5
replace time = 18 if tpoint == 6
replace time = 21 if tpoint == 7
replace time = 22 if tpoint == 8 
replace time = 23 if tpoint == 9
replace time = 25 if tpoint == 10 
replace time = 28 if tpoint == 11 


label variable time "Age in years"
label variable mfq_t "Model-Predicted SMFQ Score"

rename bin_scdc scdc
rename bin_coherence cohe
rename bin_repbehaviour repb
rename bin_sociability soci
rename bin_afms afms
rename bin_aPRS aPRS


foreach trait in scdc afms {

		gen     `trait'_tra_or_bull	= 0 if `trait' == 0 & TRA_bullying_vs_other_11_17 == 0 
		replace `trait'_tra_or_bull = 1 if `trait' == 0 & TRA_bullying_vs_other_11_17 == 1 
		replace `trait'_tra_or_bull = 2 if `trait' == 0 & TRA_bullying_vs_other_11_17 == 2 
		replace `trait'_tra_or_bull = 3 if `trait' == 1 & TRA_bullying_vs_other_11_17 == 0 
		replace `trait'_tra_or_bull = 4 if `trait' == 1 & TRA_bullying_vs_other_11_17 == 1 
		replace `trait'_tra_or_bull = 5 if `trait' == 1 & TRA_bullying_vs_other_11_17 == 2 

}


label define lb_figmargins 0 "No autism trait, trauma or bullying age 11-17" 1 "No autism trait or bullying age 11-17, other trauma experienced" 2 "No autism trait, bullying experienced age 11-17" 3 "Autism trait present, no trauma or bullying age 11-17" 4 "Autism trait present, no bullying age 11-17, other trauma experienced" 5 "Autism trait present, bullying experienced age 11-17"
label values scdc_* afms* lb_figmargins 

	
********************************************************************************
* 3 - Run mixed effects models and plot 
********************************************************************************
set scheme s2color

foreach var in scdc_tra_or_bull afms_tra_or_bull {
	xtmixed mfq_t c.time##c.time##c.time##`var' i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage, || number:c.time##c.time, cov(uns) var difficult
	estimates save est_`var', replace
}

* store predicted values and plot
cap postutil close
tempname memhold 

postfile `memhold' str30 trait_name ///
	notrait_notrauma1  notrait_notrauma_lci1  notrait_notrauma_uci1 ///
	notrait_notrauma2  notrait_notrauma_lci2  notrait_notrauma_uci2 ///
	notrait_notrauma3  notrait_notrauma_lci3  notrait_notrauma_uci3 ///
	notrait_notrauma4  notrait_notrauma_lci4  notrait_notrauma_uci4 ///
	notrait_notrauma5  notrait_notrauma_lci5  notrait_notrauma_uci5 ///
	notrait_notrauma6  notrait_notrauma_lci6  notrait_notrauma_uci6 ///
	notrait_notrauma7  notrait_notrauma_lci7  notrait_notrauma_uci7 ///
	notrait_notrauma8  notrait_notrauma_lci8  notrait_notrauma_uci8 ///
	notrait_notrauma9  notrait_notrauma_lci9  notrait_notrauma_uci9 ///
	notrait_notrauma10 notrait_notrauma_lci10 notrait_notrauma_uci10 ///
///
	notrait_trauma_nobull1  notrait_trauma_nobull_lci1  notrait_trauma_nobull_uci1 ///
	notrait_trauma_nobull2  notrait_trauma_nobull_lci2  notrait_trauma_nobull_uci2 ///
	notrait_trauma_nobull3  notrait_trauma_nobull_lci3  notrait_trauma_nobull_uci3 ///
	notrait_trauma_nobull4  notrait_trauma_nobull_lci4  notrait_trauma_nobull_uci4 ///
	notrait_trauma_nobull5  notrait_trauma_nobull_lci5  notrait_trauma_nobull_uci5 ///
	notrait_trauma_nobull6  notrait_trauma_nobull_lci6  notrait_trauma_nobull_uci6 ///
	notrait_trauma_nobull7  notrait_trauma_nobull_lci7  notrait_trauma_nobull_uci7 ///
	notrait_trauma_nobull8  notrait_trauma_nobull_lci8  notrait_trauma_nobull_uci8 ///
	notrait_trauma_nobull9  notrait_trauma_nobull_lci9  notrait_trauma_nobull_uci9 ///
	notrait_trauma_nobull10 notrait_trauma_nobull_lci10 notrait_trauma_nobull_uci10 ///
///	
	notrait_trauma_bull1  notrait_trauma_bull_lci1  notrait_trauma_bull_uci1 ///
	notrait_trauma_bull2  notrait_trauma_bull_lci2  notrait_trauma_bull_uci2 ///
	notrait_trauma_bull3  notrait_trauma_bull_lci3  notrait_trauma_bull_uci3 ///
	notrait_trauma_bull4  notrait_trauma_bull_lci4  notrait_trauma_bull_uci4 ///
	notrait_trauma_bull5  notrait_trauma_bull_lci5  notrait_trauma_bull_uci5 ///
	notrait_trauma_bull6  notrait_trauma_bull_lci6  notrait_trauma_bull_uci6 ///
	notrait_trauma_bull7  notrait_trauma_bull_lci7  notrait_trauma_bull_uci7 ///
	notrait_trauma_bull8  notrait_trauma_bull_lci8  notrait_trauma_bull_uci8 ///
	notrait_trauma_bull9  notrait_trauma_bull_lci9  notrait_trauma_bull_uci9 ///
	notrait_trauma_bull10 notrait_trauma_bull_lci10 notrait_trauma_bull_uci10 ///	
///
	trait_notrauma1  trait_notrauma_lci1  trait_notrauma_uci1 ///
	trait_notrauma2  trait_notrauma_lci2  trait_notrauma_uci2 ///
	trait_notrauma3  trait_notrauma_lci3  trait_notrauma_uci3 ///
	trait_notrauma4  trait_notrauma_lci4  trait_notrauma_uci4 ///
	trait_notrauma5  trait_notrauma_lci5  trait_notrauma_uci5 ///
	trait_notrauma6  trait_notrauma_lci6  trait_notrauma_uci6 ///
	trait_notrauma7  trait_notrauma_lci7  trait_notrauma_uci7 ///
	trait_notrauma8  trait_notrauma_lci8  trait_notrauma_uci8 ///
	trait_notrauma9  trait_notrauma_lci9  trait_notrauma_uci9 ///
	trait_notrauma10 trait_notrauma_lci10 trait_notrauma_uci10 ///
///	
	trait_trauma_nobull1  trait_trauma_nobull_lci1  trait_trauma_nobull_uci1 ///
	trait_trauma_nobull2  trait_trauma_nobull_lci2  trait_trauma_nobull_uci2 ///
	trait_trauma_nobull3  trait_trauma_nobull_lci3  trait_trauma_nobull_uci3 ///
	trait_trauma_nobull4  trait_trauma_nobull_lci4  trait_trauma_nobull_uci4 ///
	trait_trauma_nobull5  trait_trauma_nobull_lci5  trait_trauma_nobull_uci5 ///
	trait_trauma_nobull6  trait_trauma_nobull_lci6  trait_trauma_nobull_uci6 ///
	trait_trauma_nobull7  trait_trauma_nobull_lci7  trait_trauma_nobull_uci7 ///
	trait_trauma_nobull8  trait_trauma_nobull_lci8  trait_trauma_nobull_uci8 ///
	trait_trauma_nobull9  trait_trauma_nobull_lci9  trait_trauma_nobull_uci9 ///
	trait_trauma_nobull10 trait_trauma_nobull_lci10 trait_trauma_nobull_uci10 ///
///
	trait_trauma_bull1  trait_trauma_bull_lci1  trait_trauma_bull_uci1 ///
	trait_trauma_bull2  trait_trauma_bull_lci2  trait_trauma_bull_uci2 ///
	trait_trauma_bull3  trait_trauma_bull_lci3  trait_trauma_bull_uci3 ///
	trait_trauma_bull4  trait_trauma_bull_lci4  trait_trauma_bull_uci4 ///
	trait_trauma_bull5  trait_trauma_bull_lci5  trait_trauma_bull_uci5 ///
	trait_trauma_bull6  trait_trauma_bull_lci6  trait_trauma_bull_uci6 ///
	trait_trauma_bull7  trait_trauma_bull_lci7  trait_trauma_bull_uci7 ///
	trait_trauma_bull8  trait_trauma_bull_lci8  trait_trauma_bull_uci8 ///
	trait_trauma_bull9  trait_trauma_bull_lci9  trait_trauma_bull_uci9 ///
	trait_trauma_bull10 trait_trauma_bull_lci10 trait_trauma_bull_uci10 ///
///	
	using "$Datadir\Trajectories\trajectories_trauma_bull_comb_output.dta", replace

foreach trait in scdc afms {
	graph drop _all

	if "`trait'" == "scdc" { 
		local textpos = 11 
		local ymin = 0 
		local ymax = 11
		local gtext = "A - Social communication difficulties"

	}
	if "`trait'" == "afms" {
		local textpos = 11 
		local ymin = 0 
		local ymax = 11
		local gtext = "B - Autism Factor Mean Score"		
	}

	local lb1 = "No autism trait, trauma or bullying age 11-17"
	local lb2 = "No autism trait or bullying age 11-17, other trauma experienced"
 	local lb3 = "No autism trait, bullying experienced age 11-17"
	local lb4 = "Autism trait present, no trauma or bullying age 11-17" 	
	local lb5 = "Autism trait present, no bullying age 11-17, other trauma experienced"
	local lb6 = "Autism trait present, bullying experienced age 11-17"	

	disp "`trait': `gtext'"

	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==0) post
	estimates store notrait_notrauma
	matrix notrait_notrauma = r(table)

	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==1) post
	estimates store notrait_trauma_nobull
	matrix notrait_trauma_nobull = r(table)

	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==2) post
	estimates store notrait_trauma_bull
	matrix notrait_trauma_bull = r(table)
	
	
	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==3) post
	estimates store trait_notrauma
	matrix trait_notrauma = r(table)
	
	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==4) post
	estimates store trait_trauma_nobull
	matrix trait_trauma_nobull = r(table)

	estimates use est_`trait'_tra_or_bull
	estimates esample:
	margins , at(time=(10(2)28) `trait'_tra_or_bull==5) post
	estimates store trait_trauma_bull
	matrix trait_trauma_bull = r(table)
	
	disp "test1"

	coefplot notrait_notrauma notrait_trauma_nobull notrait_trauma_bull trait_notrauma trait_trauma_nobull trait_trauma_bull  ///
			 , at recast(connected) ciopts(recast(rcap)) ///
			 transform(* = min(max(@,`ymin'),`ymax')) ///
			 msize(vsmall) ///
			 ylabel(`ymin'(2)`ymax', labsize(tiny) angle(0) tlength(*0.5)) xlabel(10(2)28, labsize(tiny) tlength(*0.5)) ///
			 ytitle("Model-Predicted SMFQ Score", size(vsmall)) xtitle("Age in years",size(vsmall)) ///
			 graphregion(color(white) margin(5 0 0 2)) ///
			 text(`textpos' 11 "`gtext'", size(vsmall) place(e)) ///	
			 legend(size(tiny) cols(2) width(120) ///
			    order(2 8 4 10 6 12) ///
				label(2  "`lb1'") label(8  "`lb4'") ///
				label(4  "`lb2'") label(10 "`lb5'") ///
				label(6  "`lb3'") label(12 "`lb6'") ///			
			 ) ///
			 name(`trait'_plot)	
	graph save `trait'_plot, replace
		
    disp "test2"
	
	post `memhold' ("`trait'") ///
			(notrait_notrauma[1,1])  (notrait_notrauma[5,1])  (notrait_notrauma[6,1]) ///
			(notrait_notrauma[1,2])  (notrait_notrauma[5,2])  (notrait_notrauma[6,2]) ///
			(notrait_notrauma[1,3])  (notrait_notrauma[5,3])  (notrait_notrauma[6,3]) ///
			(notrait_notrauma[1,4])  (notrait_notrauma[5,4])  (notrait_notrauma[6,4]) ///
			(notrait_notrauma[1,5])  (notrait_notrauma[5,5])  (notrait_notrauma[6,5]) ///
			(notrait_notrauma[1,6])  (notrait_notrauma[5,6])  (notrait_notrauma[6,6]) ///
			(notrait_notrauma[1,7])  (notrait_notrauma[5,7])  (notrait_notrauma[6,7]) ///
			(notrait_notrauma[1,8])  (notrait_notrauma[5,8])  (notrait_notrauma[6,8]) ///
			(notrait_notrauma[1,9])  (notrait_notrauma[5,9])  (notrait_notrauma[6,9]) ///
			(notrait_notrauma[1,10]) (notrait_notrauma[5,10]) (notrait_notrauma[6,10]) ///
///
			(notrait_trauma_nobull[1,1])  (notrait_trauma_nobull[5,1])  (notrait_trauma_nobull[6,1]) ///
			(notrait_trauma_nobull[1,2])  (notrait_trauma_nobull[5,2])  (notrait_trauma_nobull[6,2]) ///
			(notrait_trauma_nobull[1,3])  (notrait_trauma_nobull[5,3])  (notrait_trauma_nobull[6,3]) ///
			(notrait_trauma_nobull[1,4])  (notrait_trauma_nobull[5,4])  (notrait_trauma_nobull[6,4]) ///
			(notrait_trauma_nobull[1,5])  (notrait_trauma_nobull[5,5])  (notrait_trauma_nobull[6,5]) ///
			(notrait_trauma_nobull[1,6])  (notrait_trauma_nobull[5,6])  (notrait_trauma_nobull[6,6]) ///
			(notrait_trauma_nobull[1,7])  (notrait_trauma_nobull[5,7])  (notrait_trauma_nobull[6,7]) ///
			(notrait_trauma_nobull[1,8])  (notrait_trauma_nobull[5,8])  (notrait_trauma_nobull[6,8]) ///
			(notrait_trauma_nobull[1,9])  (notrait_trauma_nobull[5,9])  (notrait_trauma_nobull[6,9]) ///
			(notrait_trauma_nobull[1,10]) (notrait_trauma_nobull[5,10]) (notrait_trauma_nobull[6,10]) ///
///
			(notrait_trauma_bull[1,1])  (notrait_trauma_bull[5,1])  (notrait_trauma_bull[6,1]) ///
			(notrait_trauma_bull[1,2])  (notrait_trauma_bull[5,2])  (notrait_trauma_bull[6,2]) ///
			(notrait_trauma_bull[1,3])  (notrait_trauma_bull[5,3])  (notrait_trauma_bull[6,3]) ///
			(notrait_trauma_bull[1,4])  (notrait_trauma_bull[5,4])  (notrait_trauma_bull[6,4]) ///
			(notrait_trauma_bull[1,5])  (notrait_trauma_bull[5,5])  (notrait_trauma_bull[6,5]) ///
			(notrait_trauma_bull[1,6])  (notrait_trauma_bull[5,6])  (notrait_trauma_bull[6,6]) ///
			(notrait_trauma_bull[1,7])  (notrait_trauma_bull[5,7])  (notrait_trauma_bull[6,7]) ///
			(notrait_trauma_bull[1,8])  (notrait_trauma_bull[5,8])  (notrait_trauma_bull[6,8]) ///
			(notrait_trauma_bull[1,9])  (notrait_trauma_bull[5,9])  (notrait_trauma_bull[6,9]) ///
			(notrait_trauma_bull[1,10]) (notrait_trauma_bull[5,10]) (notrait_trauma_bull[6,10]) ///
///			
			(trait_notrauma[1,1])  (trait_notrauma[5,1])  (trait_notrauma[6,1]) ///
			(trait_notrauma[1,2])  (trait_notrauma[5,2])  (trait_notrauma[6,2]) ///
			(trait_notrauma[1,3])  (trait_notrauma[5,3])  (trait_notrauma[6,3]) ///
			(trait_notrauma[1,4])  (trait_notrauma[5,4])  (trait_notrauma[6,4]) ///
			(trait_notrauma[1,5])  (trait_notrauma[5,5])  (trait_notrauma[6,5]) ///
			(trait_notrauma[1,6])  (trait_notrauma[5,6])  (trait_notrauma[6,6]) ///
			(trait_notrauma[1,7])  (trait_notrauma[5,7])  (trait_notrauma[6,7]) ///
			(trait_notrauma[1,8])  (trait_notrauma[5,8])  (trait_notrauma[6,8]) ///
			(trait_notrauma[1,9])  (trait_notrauma[5,9])  (trait_notrauma[6,9]) ///
			(trait_notrauma[1,10]) (trait_notrauma[5,10]) (trait_notrauma[6,10]) ///
///			
			(trait_trauma_nobull[1,1])  (trait_trauma_nobull[5,1])  (trait_trauma_nobull[6,1]) ///
			(trait_trauma_nobull[1,2])  (trait_trauma_nobull[5,2])  (trait_trauma_nobull[6,2]) ///
			(trait_trauma_nobull[1,3])  (trait_trauma_nobull[5,3])  (trait_trauma_nobull[6,3]) ///
			(trait_trauma_nobull[1,4])  (trait_trauma_nobull[5,4])  (trait_trauma_nobull[6,4]) ///
			(trait_trauma_nobull[1,5])  (trait_trauma_nobull[5,5])  (trait_trauma_nobull[6,5]) ///
			(trait_trauma_nobull[1,6])  (trait_trauma_nobull[5,6])  (trait_trauma_nobull[6,6]) ///
			(trait_trauma_nobull[1,7])  (trait_trauma_nobull[5,7])  (trait_trauma_nobull[6,7]) ///
			(trait_trauma_nobull[1,8])  (trait_trauma_nobull[5,8])  (trait_trauma_nobull[6,8]) ///
			(trait_trauma_nobull[1,9])  (trait_trauma_nobull[5,9])  (trait_trauma_nobull[6,9]) ///
			(trait_trauma_nobull[1,10]) (trait_trauma_nobull[5,10]) (trait_trauma_nobull[6,10]) ///
///			
			(trait_trauma_bull[1,1])  (trait_trauma_bull[5,1])  (trait_trauma_bull[6,1]) ///
			(trait_trauma_bull[1,2])  (trait_trauma_bull[5,2])  (trait_trauma_bull[6,2]) ///
			(trait_trauma_bull[1,3])  (trait_trauma_bull[5,3])  (trait_trauma_bull[6,3]) ///
			(trait_trauma_bull[1,4])  (trait_trauma_bull[5,4])  (trait_trauma_bull[6,4]) ///
			(trait_trauma_bull[1,5])  (trait_trauma_bull[5,5])  (trait_trauma_bull[6,5]) ///
			(trait_trauma_bull[1,6])  (trait_trauma_bull[5,6])  (trait_trauma_bull[6,6]) ///
			(trait_trauma_bull[1,7])  (trait_trauma_bull[5,7])  (trait_trauma_bull[6,7]) ///
			(trait_trauma_bull[1,8])  (trait_trauma_bull[5,8])  (trait_trauma_bull[6,8]) ///
			(trait_trauma_bull[1,9])  (trait_trauma_bull[5,9])  (trait_trauma_bull[6,9]) ///
			(trait_trauma_bull[1,10]) (trait_trauma_bull[5,10]) (trait_trauma_bull[6,10]) 		
		
}
postclose `memhold'

graph use scdc_plot

grc1leg scdc_plot afms_plot ///
	, cols(2) name("fig_traj", replace) graphregion(color(white)) ycommon
graph export "$Graphdir\Trajectories\fig_traj_trauma_or_bull.png", name(fig_traj) replace width(4000) height(3000)
graph export "$Graphdir\Trajectories\fig_traj_trauma_or_bull.pdf", name(fig_traj) replace 	






* manipulate table output and save as excel file 	
use "$Datadir\Trajectories\trajectories_trauma_bull_comb_output.dta", clear
reshape long notrait_notrauma notrait_notrauma_lci notrait_notrauma_uci ///
			 notrait_trauma_nobull notrait_trauma_nobull_lci notrait_trauma_nobull_uci ///
			 notrait_trauma_bull notrait_trauma_bull_lci notrait_trauma_bull_uci ///			 
			 trait_notrauma trait_notrauma_lci trait_notrauma_uci ///
			 trait_trauma_nobull trait_trauma_nobull_lci trait_trauma_nobull_uci ///
			 trait_trauma_bull trait_trauma_bull_lci trait_trauma_bull_uci ///			 
		, i(trait_name) j(time)
	
gen age = . 
forvalues i = 1(1)10 {
	local j = `i'*2 + 8
	replace age = `j' if time == `i'	
}

gen trait = "" 
replace trait = "Social communication" if trait_name == "scdc" 
replace trait = "Autism factor mean score" if trait_name == "afms" 

gen trait_ord = . 
replace trait_ord = 1 if trait_name == "scdc" 
replace trait_ord = 2 if trait_name == "afms" 

sort trait_ord age

foreach trait in "notrait" "trait" {
	foreach trauma in "notrauma" "trauma_nobull" "trauma_bull" {
		gen `trait'_`trauma'_95CI = strofreal(`trait'_`trauma', "%5.2f") ///
									+ " (" + ///
									strofreal(`trait'_`trauma'_lci, "%5.2f") ///
									+ ", " + ///
									strofreal(`trait'_`trauma'_uci, "%5.2f") ///
									+ ")" 

	} 
}

order trait age 
keep trait age *95CI

export excel using "$Datadir\Trajectories\Trajectories_trauma_estimates_bully_or_trauma.xlsx", replace firstrow(var) 


********************************************************************************
log close
