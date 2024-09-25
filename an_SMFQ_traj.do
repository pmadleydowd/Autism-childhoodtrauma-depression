capture log close
log using "$Logdir\LOG_an_SMFQ_traj.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-April-01
* Description: Model the SMFQ trajectories
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Reshape the data for used in mixed effects linear growth models
* 3 - Run mixed effects models and plot 
* 4 - Residuals plots for diagnostics
* 5 - Manipulate output to create table

********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion == 1

cd "$Datadir\Trajectories"

********************************************************************************
* 2 - Reshape the data for used in mixed effects linear growth models
********************************************************************************
* restrict to variables neccesary for analysis 
keep aln qlet ASD bin* ///
	mfq_t1-mfq_t11 ///
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


label define lb_figmargins 0 "No autism/autism trait" 1 "Autism/autism trait"
label values ASD lb_figmargins 

********************************************************************************
* 3 - Run mixed effects models and plot 
********************************************************************************
set scheme s2color

* run model and store estimates
foreach trait in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS {
	xtmixed mfq_t c.time##c.time##c.time##`trait' i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage, || number:c.time##c.time, cov(uns) var 
	estimates store est_`trait' 
	estimates save est_`trait', replace
}


* store predicted values and plot
cap postutil close
tempname memhold 

postfile `memhold' str30 trait_name ///
	notrait1  notrait_lci1  notrait_uci1 ///
	notrait2  notrait_lci2  notrait_uci2 ///
	notrait3  notrait_lci3  notrait_uci3 ///
	notrait4  notrait_lci4  notrait_uci4 ///
	notrait5  notrait_lci5  notrait_uci5 ///
	notrait6  notrait_lci6  notrait_uci6 ///
	notrait7  notrait_lci7  notrait_uci7 ///
	notrait8  notrait_lci8  notrait_uci8 ///
	notrait9  notrait_lci9  notrait_uci9 ///
	notrait10 notrait_lci10 notrait_uci10 ///
	trait1  trait_lci1  trait_uci1 ///
	trait2  trait_lci2  trait_uci2 ///
	trait3  trait_lci3  trait_uci3 ///
	trait4  trait_lci4  trait_uci4 ///
	trait5  trait_lci5  trait_uci5 ///
	trait6  trait_lci6  trait_uci6 ///
	trait7  trait_lci7  trait_uci7 ///
	trait8  trait_lci8  trait_uci8 ///
	trait9  trait_lci9  trait_uci9 ///
	trait10 trait_lci10 trait_uci10 ///
	diff1  diff_lci1  diff_uci1 ///
	diff2  diff_lci2  diff_uci2 ///
	diff3  diff_lci3  diff_uci3 ///
	diff4  diff_lci4  diff_uci4 ///
	diff5  diff_lci5  diff_uci5 ///
	diff6  diff_lci6  diff_uci6 ///
	diff7  diff_lci7  diff_uci7 ///
	diff8  diff_lci8  diff_uci8 ///
	diff9  diff_lci9  diff_uci9 ///
	diff10 diff_lci10 diff_uci10 ///	
	using "$Datadir\Trajectories\trajectories_output.dta", replace

		
foreach trait in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS {
	if "`trait'" == "ASD" {
		local gtext = "A - Autism diagnosis"
	}	
	if "`trait'" == "bin_scdc" {
		local gtext = "B - Social communication"
	}
	if "`trait'" == "bin_coherence" {
		local gtext = "C - Speech coherence"
	}
	if "`trait'" == "bin_repbehaviour" {
		local gtext = "D - Repetitive behaviour"
	}
	if "`trait'" == "bin_sociability" {
		local gtext = "E - Sociability" 
	} 
	if "`trait'" == "bin_afms"  {
		local gtext = "F - Autism factor mean score" 		
	}
	if "`trait'" == "bin_aPRS"  {
		local gtext = "G - Autism PRS" 		
	}
	disp "`trait': " "`gtext'"
	
	
	estimates use est_`trait'
	estimates esample:
	margins `trait', at(time=(10(2)28))
	matrix margin_`trait' = r(table)
	marginsplot, title(" ")  x(time) name(`trait'_plot, replace)    ///
		plotopts(yscale(range(0 10)) msize(vsmall)  ///
			ylabel(0(2)10, labsize(tiny) angle(0) tlength(*0.5)) xlabel(,labsize(tiny)) ///
			ytitle("Model-Predicted SMFQ Score", size(vsmall)) xtitle(,size(vsmall)) ///
			legend(size(tiny) cols(1) width(60)) ///
			graphregion(color(white)  margin(5 0 0 0)) ///
			text(11.2 9 "`gtext'", size(vsmall) place(e)) ///
		)

	margins , dydx(`trait') at(time=(10(2)28)) 
	matrix diff_`trait' = r(table)
	marginsplot, title(" ")  x(time) name(`trait'_diffplot, replace)    ///
		plotopts(yscale(range(-4 4.1)) msize(vsmall)  ///
			ylabel(-4(1)4, labsize(tiny) angle(0) tlength(*0.5)) xlabel(,labsize(tiny)) ///
			ytitle("Difference in" " " "Model-Predicted SMFQ Score", size(vsmall)) ///
			xtitle(,size(vsmall)) ///
			legend(off) ///
			graphregion(color(white) margin(5 0 0 0)) ///
			text(5 9 "`gtext'", size(vsmall) place(e)) ///
			yline(0, lp(-) lcol(gray)) ///
		)	
		
	post `memhold' ("`trait'")	///
		(margin_`trait'[1,1])  (margin_`trait'[5,1])  (margin_`trait'[6,1])  /// notrait
		(margin_`trait'[1,3])  (margin_`trait'[5,3])  (margin_`trait'[6,3])  /// 
		(margin_`trait'[1,5])  (margin_`trait'[5,5])  (margin_`trait'[6,5])  ///
		(margin_`trait'[1,7])  (margin_`trait'[5,7])  (margin_`trait'[6,7])  ///
		(margin_`trait'[1,9])  (margin_`trait'[5,9])  (margin_`trait'[6,9])  ///
		(margin_`trait'[1,11]) (margin_`trait'[5,11]) (margin_`trait'[6,11]) ///
		(margin_`trait'[1,13]) (margin_`trait'[5,13]) (margin_`trait'[6,13]) ///
		(margin_`trait'[1,15]) (margin_`trait'[5,15]) (margin_`trait'[6,15]) ///
		(margin_`trait'[1,17]) (margin_`trait'[5,17]) (margin_`trait'[6,17]) ///
		(margin_`trait'[1,19]) (margin_`trait'[5,19]) (margin_`trait'[6,19]) ///
		(margin_`trait'[1,2])  (margin_`trait'[5,2])  (margin_`trait'[6,2])  /// trait
		(margin_`trait'[1,4])  (margin_`trait'[5,4])  (margin_`trait'[6,4])  ///
		(margin_`trait'[1,6])  (margin_`trait'[5,6])  (margin_`trait'[6,6])  ///
		(margin_`trait'[1,8])  (margin_`trait'[5,8])  (margin_`trait'[6,8])  ///
		(margin_`trait'[1,10]) (margin_`trait'[5,10]) (margin_`trait'[6,10]) ///
		(margin_`trait'[1,12]) (margin_`trait'[5,12]) (margin_`trait'[6,12]) ///
		(margin_`trait'[1,14]) (margin_`trait'[5,14]) (margin_`trait'[6,14]) ///
		(margin_`trait'[1,16]) (margin_`trait'[5,16]) (margin_`trait'[6,16]) ///
		(margin_`trait'[1,18]) (margin_`trait'[5,18]) (margin_`trait'[6,18]) ///
		(margin_`trait'[1,20]) (margin_`trait'[5,20]) (margin_`trait'[6,20]) ///
		(diff_`trait'[1,11])   (diff_`trait'[5,11])   (diff_`trait'[6,11])  	 /// difference
		(diff_`trait'[1,12])   (diff_`trait'[5,12])   (diff_`trait'[6,12])  	 /// 
		(diff_`trait'[1,13])   (diff_`trait'[5,13])   (diff_`trait'[6,13])  	 ///
		(diff_`trait'[1,14])   (diff_`trait'[5,14])   (diff_`trait'[6,14])  	 ///
		(diff_`trait'[1,15])   (diff_`trait'[5,15])   (diff_`trait'[6,15])  	 ///
		(diff_`trait'[1,16])   (diff_`trait'[5,16])   (diff_`trait'[6,16]) 	 ///
		(diff_`trait'[1,17])   (diff_`trait'[5,17])   (diff_`trait'[6,17]) 	 ///
		(diff_`trait'[1,18])   (diff_`trait'[5,18])   (diff_`trait'[6,18]) 	 ///
		(diff_`trait'[1,19])   (diff_`trait'[5,19])   (diff_`trait'[6,19]) 	 ///
		(diff_`trait'[1,20])   (diff_`trait'[5,20])   (diff_`trait'[6,20]) 
				
}		
postclose `memhold'


* combine plots
	* trajectories
grc1leg ASD_plot bin_scdc_plot bin_coherence_plot bin_repbehaviour_plot bin_sociability_plot bin_afms_plot bin_aPRS_plot ///
	, cols(3) graphregion(color(white)) name("fig_traj", replace) ring(0) pos(4)

graph export "$Graphdir\Trajectories\fig_traj.png", name(fig_traj) replace width(3000) height(3000)
graph export "$Graphdir\Trajectories\fig_traj.pdf", name(fig_traj) replace


	* predicted difference
graph combine ASD_diffplot bin_scdc_diffplot bin_coherence_diffplot ///
			  bin_repbehaviour_diffplot bin_sociability_diffplot ///
			  bin_afms_diffplot bin_aPRS_diffplot ///
	, cols(3) graphregion(color(white)) name("fig_difftraj", replace) 

graph export "$Graphdir\Trajectories\fig_difftraj.png", ///
	name(fig_difftraj) replace width(3000) height(3000)
graph export "$Graphdir\Trajectories\fig_traj.pdf", ///
	name(fig_difftraj) replace
	

	
	
	
	
********************************************************************************	
* 4 - Residuals plots for diagnostics
********************************************************************************	

foreach trait in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS {
	preserve
	if "`trait'" == "ASD" {
		local gtext = "A - Autism diagnosis"
	}	
	if "`trait'" == "bin_scdc" {
		local gtext = "B - Social communication"
	}
	if "`trait'" == "bin_coherence" {
		local gtext = "C - Speech coherence"
	}
	if "`trait'" == "bin_repbehaviour" {
		local gtext = "D - Repetitive behaviour"
	}
	if "`trait'" == "bin_sociability" {
		local gtext = "E - Sociability" 
	} 
	if "`trait'" == "bin_afms"  {
		local gtext = "F - Autism factor mean score" 		
	}
	if "`trait'" == "bin_aPRS"  {
		local gtext = "G - Autism PRS" 		
	}
	disp "`trait': " "`gtext'"
	
	
	estimates use est_`trait'
	estimates esample:
	
	predict u1 u2 u0, reffects level(number)
	hist u1, title(`gtext', size(small)) xtitle("") name(u1_`trait', replace) 
	hist u2, title(`gtext', size(small)) xtitle("") name(u2_`trait', replace)
	hist u0, title(`gtext', size(small)) xtitle("") name(u0_`trait', replace)
	
	restore		
}		


foreach res in u1 u2 u0 {
	if "`res'" == "u1" {
		local ttl = "Residuals for random effect for time (group: subject ID)"
	}
	else if "`res'" == "u2" {
		local ttl = "Residuals for random effect for time squared (group: subject ID)"
	}
	else if "`res'" == "u0" {
		local ttl = "Residuals for random effect for intercept (group: subject ID)"
	}
	
	graph combine `res'_ASD `res'_bin_scdc `res'_bin_coherence ///
			  `res'_bin_repbehaviour `res'_bin_sociability ///
			  `res'_bin_afms `res'_bin_aPRS ///
	, cols(3) graphregion(color(white)) name("`res'_residuals", replace) ///
	  title("`ttl'", size(medsmall))
}

graph export "$Graphdir\Trajectories\u0_residuals.png", ///
	name(u0_residuals) replace 
graph export "$Graphdir\Trajectories\u1_residuals.png", ///
	name(u1_residuals) replace 
graph export "$Graphdir\Trajectories\u2_residuals.png", ///
	name(u2_residuals) replace 

	
	
	
********************************************************************************	
* 5 - Manipulate output to create table	
********************************************************************************
use "$Datadir\Trajectories\trajectories_output.dta", clear
reshape long notrait notrait_lci notrait_uci ///
			 trait trait_lci trait_uci ///
			 diff diff_lci diff_uci ///
		, i(trait_name) j(time)
	
gen age = . 
forvalues i = 1(1)10 {
	local j = `i'*2 + 8
	replace age = `j' if time == `i'	
}

gen trait_label = "Autism diagnosis" if trait_name == "ASD"
replace trait_label = "Social communication" if trait_name == "bin_scdc" 
replace trait_label = "Speech coherence" if trait_name == "bin_coherence" 
replace trait_label = "Repetitive behaviour" if trait_name == "bin_repbehaviour" 
replace trait_label = "Sociability" if trait_name == "bin_sociability" 
replace trait_label = "Autism factor mean score" if trait_name == "bin_afms" 
replace trait_label = "Autism PRS" if trait_name == "bin_aPRS"

gen trait_ord = 1 if trait_name == "ASD"
replace trait_ord = 2 if trait_name == "bin_scdc" 
replace trait_ord = 3 if trait_name == "bin_coherence" 
replace trait_ord = 4 if trait_name == "bin_repbehaviour" 
replace trait_ord = 5 if trait_name == "bin_sociability" 
replace trait_ord = 6 if trait_name == "bin_afms" 
replace trait_ord = 7 if trait_name == "bin_aPRS" 

sort trait_ord age

gen notrait_95CI = strofreal(notrait, "%5.2f") + " (" + strofreal(notrait_lci, "%5.2f") + ", " + strofreal(notrait_uci, "%5.2f") + ")" 
gen trait_95CI = strofreal(trait, "%5.2f") + " (" + strofreal(trait_lci, "%5.2f") + ", " + strofreal(trait_uci, "%5.2f") + ")" 
gen diff_95CI = strofreal(diff, "%5.2f") + " (" + strofreal(diff_lci, "%5.2f") + ", " + strofreal(diff_uci, "%5.2f") + ")" 

preserve 
order trait_label age 
keep trait_label age *95CI
rename trait_label trait_name
export excel using "$Datadir\Trajectories\Trajectories_estimates_long.xlsx", replace firstrow(var) 
restore

keep trait_name age *95CI
foreach trait in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS {
	preserve
	keep if trait_name == "`trait'"
	drop trait_name
	rename trait_95CI `trait'
	rename notrait_95CI no_`trait'
	rename diff_95CI diff_`trait'
	save "$Datadir\Trajectories\_temp\diff_`trait'.dta", replace
	restore
}

use "$Datadir\Trajectories\_temp\diff_ASD.dta", clear 
foreach trait in bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS {
	merge 1:1 age using "$Datadir\Trajectories\_temp\diff_`trait'.dta", nogen
}

export excel using "$Datadir\Trajectories\Trajectories_estimates.xlsx", replace firstrow(var) 


********************************************************************************
log close 