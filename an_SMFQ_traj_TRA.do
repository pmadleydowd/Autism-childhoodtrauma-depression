capture log close
log using "$Logdir\LOG_an_SMFQ_traj_TRA.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-April-01
* Description: Model the SMFQ trajectories separated by trauma status
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


foreach trait in ASD scdc cohe repb soci afms aPRS {
	foreach TRA in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17  {

		gen `trait'_`TRA'	  = 0 if `trait' == 0 & `TRA' == 0 
		replace `trait'_`TRA' = 1 if `trait' == 1 & `TRA' == 0 
		replace `trait'_`TRA' = 2 if `trait' == 0 & `TRA' == 1 
		replace `trait'_`TRA' = 3 if `trait' == 1 & `TRA' == 1 

	}		
}


label define lb_figmargins_ASD 0 "No autism diagnosis, no trauma age 11-17" 1 "Autism diagnosis, no trauma age 11-17" 2 "No autism diagnosis, trauma age 11-17" 3 "Autism diagnosis and trauma age 11-17"
label values ASD_* lb_figmargins_ASD 

label define lb_figmargins_scdc 0 "No social communication difficulties, no trauma age 11-17" 1 "Social communication difficulties, no trauma age 11-17" 2 "No social communication difficulties, trauma age 11-17" 3 "Social communication difficulties and trauma age 11-17"
label values scdc_* lb_figmargins_scdc 

label define lb_figmargins_cohe 0 "No speech coherence difficulties, no trauma age 11-17" 1 "Speech coherence difficulties, no trauma age 11-17" 2 "No speech coherence difficulties, trauma age 11-17" 3 "Speech coherence difficulties and trauma age 11-17"
label values cohe_* lb_figmargins_cohe 

label define lb_figmargins_repb 0 "No repetitive behaviour, no trauma age 11-17" 1 "Repetitive behaviour, no trauma age 11-17" 2 "No repetitive behaviour, trauma age 11-17" 3 "Repetitive behaviour and trauma age 11-17"
label values repb_* lb_figmargins_repb 

label define lb_figmargins_soci 0 "Not low sociability, no trauma age 11-17" 1 "Low sociability, no trauma age 11-17" 2 "Not low sociability, trauma age 11-17" 3 "Low sociability and trauma age 11-17"
label values soci_* lb_figmargins_soci 

label define lb_figmargins_afms 0 "Not highest decile of AFMS, no trauma age 11-17" 1 "Highest decile of AFMS, no trauma age 11-17" 2 "Not highest decile of AFMS, trauma age 11-17" 3 "Highest decile of AFMS and trauma age 11-17"
label values afms* lb_figmargins_afms 

label define lb_figmargins_aPRS 0 "Not highest decile of autism PRS, no trauma age 11-17" 1 "Highest decile of autism PRS, no trauma age 11-17" 2 "Not highest decile of autism PRS, trauma age 11-17" 3 "Highest decile of autism PRS and trauma age 11-17"
label values aPRS* lb_figmargins_aPRS 


	
********************************************************************************
* 3 - Run mixed effects models and plot 
********************************************************************************
set scheme s2color

foreach trait in ASD scdc cohe repb soci afms aPRS {
	foreach TRA in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17  {
			
		xtmixed mfq_t c.time##c.time##c.time##`trait'_`TRA' i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage, || number:c.time##c.time, cov(uns) var difficult
	
		estimates save est_`trait'_`TRA', replace
	}
}

* store predicted values and plot
cap postutil close
tempname memhold 

postfile `memhold' str30 trait_name str30 trauma_name ///
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
	notrait_trauma1  notrait_trauma_lci1  notrait_trauma_uci1 ///
	notrait_trauma2  notrait_trauma_lci2  notrait_trauma_uci2 ///
	notrait_trauma3  notrait_trauma_lci3  notrait_trauma_uci3 ///
	notrait_trauma4  notrait_trauma_lci4  notrait_trauma_uci4 ///
	notrait_trauma5  notrait_trauma_lci5  notrait_trauma_uci5 ///
	notrait_trauma6  notrait_trauma_lci6  notrait_trauma_uci6 ///
	notrait_trauma7  notrait_trauma_lci7  notrait_trauma_uci7 ///
	notrait_trauma8  notrait_trauma_lci8  notrait_trauma_uci8 ///
	notrait_trauma9  notrait_trauma_lci9  notrait_trauma_uci9 ///
	notrait_trauma10 notrait_trauma_lci10 notrait_trauma_uci10 ///
	trait_trauma1  trait_trauma_lci1  trait_trauma_uci1 ///
	trait_trauma2  trait_trauma_lci2  trait_trauma_uci2 ///
	trait_trauma3  trait_trauma_lci3  trait_trauma_uci3 ///
	trait_trauma4  trait_trauma_lci4  trait_trauma_uci4 ///
	trait_trauma5  trait_trauma_lci5  trait_trauma_uci5 ///
	trait_trauma6  trait_trauma_lci6  trait_trauma_uci6 ///
	trait_trauma7  trait_trauma_lci7  trait_trauma_uci7 ///
	trait_trauma8  trait_trauma_lci8  trait_trauma_uci8 ///
	trait_trauma9  trait_trauma_lci9  trait_trauma_uci9 ///
	trait_trauma10 trait_trauma_lci10 trait_trauma_uci10 ///
	using "$Datadir\Trajectories\trajectories_trauma_output.dta", replace

foreach trait in ASD scdc cohe repb soci afms aPRS {
	graph drop _all

	if "`trait'" == "ASD" {
		local textpos = 27 
		local ymin = 0 
		local ymax = 26 
		local lb1 = "No autism diagnosis, no trauma age 11-17"
		local lb2 = "Autism diagnosis, no trauma age 11-17"
 		local lb3 = "No autism diagnosis, trauma age 11-17"
		local lb4 = "Autism diagnosis and trauma age 11-17"		
	}
	if "`trait'" == "scdc" { 
		local textpos = 15 
		local ymin = 0 
		local ymax = 14
		local lb1 = "No social communication difficulties, no trauma age 11-17"
		local lb2 = "Social communication difficulties, no trauma age 11-17"
 		local lb3 = "No social communication difficulties, trauma age 11-17"
		local lb4 = "Social communication difficulties and trauma age 11-17"	
	}
	if "`trait'" == "cohe" {
		local textpos = 15 
		local ymin = 0 
		local ymax = 14 
		local lb1 = "No speech coherence difficulties, no trauma age 11-17" 
		local lb2 = "Speech coherence difficulties, no trauma age 11-17" 
 		local lb3 = "No speech coherence difficulties, trauma age 11-17" 
		local lb4 = "Speech coherence difficulties and trauma age 11-17"	
	}
	if "`trait'" == "repb" {
		local textpos = 21 
		local ymin = 0 
		local ymax = 20 
		local lb1 = "No repetitive behaviour, no trauma age 11-17"  
		local lb2 = "Repetitive behaviour, no trauma age 11-17" 
 		local lb3 = "No repetitive behaviour, trauma age 11-17"
		local lb4 = "Repetitive behaviour and trauma age 11-17"
	}
	if "`trait'" == "soci" {
		local textpos = 17 
		local ymin = 0 
		local ymax = 16 
		local lb1 = "Not low sociability, no trauma age 11-17"  
		local lb2 = "Low sociability, no trauma age 11-17"  
 		local lb3 = "Not low sociability, trauma age 11-17"  
		local lb4 = "Low sociability and trauma age 11-17"
	}
	if "`trait'" == "afms" {
		local textpos = 17 
		local ymin = 0 
		local ymax = 16 
		local lb1 = "Not highest decile of AFMS, no trauma age 11-17" 
		local lb2 = "Highest decile of AFMS, no trauma age 11-17"
 		local lb3 = "Not highest decile of AFMS, trauma age 11-17"
		local lb4 = "Highest decile of AFMS and trauma age 11-17"
	}
	if "`trait'" == "aPRS" {
		local textpos = 15 
		local ymin = 0 
		local ymax = 14 
		local lb1 = "Not highest decile of autism PRS, no trauma age 11-17" 
		local lb2 = "Highest decile of autism PRS, no trauma age 11-17"
 		local lb3 = "Not highest decile of autism PRS, trauma age 11-17"
		local lb4 = "Highest decile of autism PRS and trauma age 11-17"	
	}

		
	foreach TRA in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		if "`TRA'" == "TRA_any_11_17" {
			local gtext = "A - Any trauma"
		}		
		if "`TRA'" == "TRA_phys_11_17" {
			local gtext = "B - Physical abuse"
		}
		if "`TRA'" == "TRA_emot_11_17" {
			local gtext = "C - Emotional abuse"
		}
		if "`TRA'" == "TRA_emng_11_17" {
			local gtext = "D - Emotional neglect"
		}
		if "`TRA'" == "TRA_sxab_11_17" {
			local gtext = "E - Sexual abuse" 
		} 
		if "`TRA'" == "TRA_dmvl_11_17" {
			local gtext = "F - Domestic violence" 
		} 
		if "`TRA'" == "TRA_bull_11_17" {
			local gtext = "G - Bullying victimization" 
		} 		
		
		disp "`TRA': `gtext'"
		

		estimates use est_`trait'_`TRA'
		estimates esample:
		margins , at(time=(10(2)28) `trait'_`TRA'==0) post
		estimates store notrait_notrauma
		matrix notrait_notrauma = r(table)

		estimates use est_`trait'_`TRA'
		estimates esample:
		margins , at(time=(10(2)28) `trait'_`TRA'==1) post
		estimates store trait_notrauma
		matrix trait_notrauma = r(table)

		estimates use est_`trait'_`TRA'
		estimates esample:
		margins , at(time=(10(2)28) `trait'_`TRA'==2) post
		estimates store notrait_trauma
		matrix notrait_trauma = r(table)

		estimates use est_`trait'_`TRA'
		estimates esample:
		margins , at(time=(10(2)28) `trait'_`TRA'==3) post
		estimates store trait_trauma
		matrix trait_trauma = r(table)


		coefplot notrait_notrauma trait_notrauma notrait_trauma trait_trauma  ///
				 , at recast(connected) ciopts(recast(rcap)) ///
				 transform(* = min(max(@,`ymin'),`ymax')) ///
				 msize(vsmall) ///
				 ylabel(`ymin'(2)`ymax', labsize(tiny) angle(0) tlength(*0.5)) xlabel(10(2)28, labsize(tiny) tlength(*0.5)) ///
				 ytitle("Model-Predicted SMFQ Score", size(vsmall)) xtitle("Age in years",size(vsmall)) ///
				 graphregion(color(white) margin(5 0 0 2)) ///
				 text(`textpos' 11 "`gtext'", size(vsmall) place(e)) ///	
				 legend(size(tiny) cols(1) width(80) ///
					label(2 "`lb1'") ///
					label(4 "`lb2'") ///
					label(6 "`lb3'") ///
					label(8 "`lb4'") ///
				 ) ///
				 name(`TRA'_plot)	
				 
		post `memhold' ("`trait'") ("`TRA'") ///
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
				(notrait_trauma[1,1])  (notrait_trauma[5,1])  (notrait_trauma[6,1]) ///
				(notrait_trauma[1,2])  (notrait_trauma[5,2])  (notrait_trauma[6,2]) ///
				(notrait_trauma[1,3])  (notrait_trauma[5,3])  (notrait_trauma[6,3]) ///
				(notrait_trauma[1,4])  (notrait_trauma[5,4])  (notrait_trauma[6,4]) ///
				(notrait_trauma[1,5])  (notrait_trauma[5,5])  (notrait_trauma[6,5]) ///
				(notrait_trauma[1,6])  (notrait_trauma[5,6])  (notrait_trauma[6,6]) ///
				(notrait_trauma[1,7])  (notrait_trauma[5,7])  (notrait_trauma[6,7]) ///
				(notrait_trauma[1,8])  (notrait_trauma[5,8])  (notrait_trauma[6,8]) ///
				(notrait_trauma[1,9])  (notrait_trauma[5,9])  (notrait_trauma[6,9]) ///
				(notrait_trauma[1,10]) (notrait_trauma[5,10]) (notrait_trauma[6,10]) ///
				(trait_trauma[1,1])  (trait_trauma[5,1])  (trait_trauma[6,1]) ///
				(trait_trauma[1,2])  (trait_trauma[5,2])  (trait_trauma[6,2]) ///
				(trait_trauma[1,3])  (trait_trauma[5,3])  (trait_trauma[6,3]) ///
				(trait_trauma[1,4])  (trait_trauma[5,4])  (trait_trauma[6,4]) ///
				(trait_trauma[1,5])  (trait_trauma[5,5])  (trait_trauma[6,5]) ///
				(trait_trauma[1,6])  (trait_trauma[5,6])  (trait_trauma[6,6]) ///
				(trait_trauma[1,7])  (trait_trauma[5,7])  (trait_trauma[6,7]) ///
				(trait_trauma[1,8])  (trait_trauma[5,8])  (trait_trauma[6,8]) ///
				(trait_trauma[1,9])  (trait_trauma[5,9])  (trait_trauma[6,9]) ///
				(trait_trauma[1,10]) (trait_trauma[5,10]) (trait_trauma[6,10]) 
		
		
	}		
		
	grc1leg TRA_any_11_17_plot TRA_phys_11_17_plot TRA_emot_11_17_plot ///
			TRA_emng_11_17_plot TRA_sxab_11_17_plot TRA_dmvl_11_17_plot TRA_bull_11_17_plot ///
		, cols(3) name("fig_traj", replace) ring(0) pos(4) legendfrom(TRA_any_11_17_plot) graphregion(color(white)) ycommon


	graph export "$Graphdir\Trajectories\fig_traj_`trait'.png", name(fig_traj) replace width(3000) height(3000)
	graph export "$Graphdir\Trajectories\fig_traj_`trait'.pdf", name(fig_traj) replace 	
			
}


postclose `memhold'




********************************************************************************	
* 4 - Residuals plots for diagnostics
********************************************************************************	
foreach trait in ASD scdc cohe repb soci afms aPRS {
	graph drop _all
	
	if "`trait'" == "ASD" {
		local gtext1 = "Autism diagnosis"
	}	
	if "`trait'" == "bin_scdc" {
		local gtext1 = "Social communication"
	}
	if "`trait'" == "bin_coherence" {
		local gtext1 = "Speech coherence"
	}
	if "`trait'" == "bin_repbehaviour" {
		local gtext1 = "Repetitive behaviour"
	}
	if "`trait'" == "bin_sociability" {
		local gtext1 = "Sociability" 
	} 
	if "`trait'" == "bin_afms"  {
		local gtext1 = "Autism factor mean score" 		
	}
	if "`trait'" == "bin_aPRS"  {
		local gtext1 = "Autism PRS" 		
	}

	foreach TRA in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		preserve
		if "`TRA'" == "TRA_any_11_17" {
			local gtext = "A - Any trauma"
		}		
		if "`TRA'" == "TRA_phys_11_17" {
			local gtext = "B - Physical abuse"
		}
		if "`TRA'" == "TRA_emot_11_17" {
			local gtext = "C - Emotional abuse"
		}
		if "`TRA'" == "TRA_emng_11_17" {
			local gtext = "D - Emotional neglect"
		}
		if "`TRA'" == "TRA_sxab_11_17" {
			local gtext = "E - Sexual abuse" 
		} 
		if "`TRA'" == "TRA_dmvl_11_17" {
			local gtext = "F - Domestic violence" 
		} 
		if "`TRA'" == "TRA_bull_11_17" {
			local gtext = "G - Bullying victimization" 
		} 		
		disp "`TRA': `gtext'"
		

		estimates use est_`trait'_`TRA'
		estimates esample:
		
		predict u1 u2 u0, reffects level(number)
		hist u1, title(`gtext', size(small)) xtitle("") name(u1_`trait'_`TRA', replace) 
		hist u2, title(`gtext', size(small)) xtitle("") name(u2_`trait'_`TRA', replace)
		hist u0, title(`gtext', size(small)) xtitle("") name(u0_`trait'_`TRA', replace)
		
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
		
		graph combine `res'_`trait'_TRA_any_11_17 /// 
					  `res'_`trait'_TRA_phys_11_17 ///
					  `res'_`trait'_TRA_emot_11_17 ///
					  `res'_`trait'_TRA_emng_11_17 ///
					  `res'_`trait'_TRA_sxab_11_17 ///
					  `res'_`trait'_TRA_dmvl_11_17 ///
					  `res'_`trait'_TRA_bull_11_17 ///
		, cols(3) graphregion(color(white)) name("`res'_residuals", replace) ///
		  title("`ttl'", size(medsmall)) subtitle("`gtext1'", size(small))
	}

	graph export "$Graphdir\Trajectories\u0_residuals_trauma_`trait'.png", ///
		name(u0_residuals) replace 
	graph export "$Graphdir\Trajectories\u1_residuals_trauma_`trait'.png", ///
		name(u1_residuals) replace 
	graph export "$Graphdir\Trajectories\u2_residuals_trauma_`trait'.png", ///
		name(u2_residuals) replace 

}


	
********************************************************************************	
* 5 - Manipulate output to create table	
********************************************************************************
use "$Datadir\Trajectories\trajectories_trauma_output.dta", clear
reshape long notrait_notrauma notrait_notrauma_lci notrait_notrauma_uci ///
			 trait_notrauma trait_notrauma_lci trait_notrauma_uci ///
			 notrait_trauma notrait_trauma_lci notrait_trauma_uci ///
			 trait_trauma trait_trauma_lci trait_trauma_uci ///
		, i(trait_name trauma_name) j(time)
	
gen age = . 
forvalues i = 1(1)10 {
	local j = `i'*2 + 8
	replace age = `j' if time == `i'	
}

gen trait = "Autism diagnosis" if trait_name == "ASD"
replace trait = "Social communication" if trait_name == "scdc" 
replace trait = "Speech coherence" if trait_name == "cohe" 
replace trait = "Repetitive behaviour" if trait_name == "repb" 
replace trait = "Sociability" if trait_name == "soci" 
replace trait = "Autism factor mean score" if trait_name == "afms" 
replace trait = "Autism PRS" if trait_name == "aPRS" 

gen trauma = "Any" if trauma_name == "TRA_any_11_17"
replace trauma = "Physical abuse" if trauma_name == "TRA_phys_11_17" 
replace trauma = "Emotional abuse" if trauma_name == "TRA_emot_11_17" 
replace trauma = "Emotional neglect" if trauma_name == "TRA_emng_11_17" 
replace trauma = "Sexual abuse" if trauma_name == "TRA_sxab_11_17" 
replace trauma = "Domestic violence" if trauma_name == "TRA_dmvl_11_17" 
replace trauma = "Bullying victimization" if trauma_name == "TRA_bull_11_17" 

gen trait_ord = 1 if trait_name == "ASD"
replace trait_ord = 2 if trait_name == "scdc" 
replace trait_ord = 3 if trait_name == "cohe" 
replace trait_ord = 4 if trait_name == "repb" 
replace trait_ord = 5 if trait_name == "soci" 
replace trait_ord = 6 if trait_name == "afms" 
replace trait_ord = 7 if trait_name == "aPRS" 

gen trauma_ord = 1 if trauma_name == "TRA_any_11_17"
replace trauma_ord = 2 if trauma_name == "TRA_phys_11_17" 
replace trauma_ord = 3 if trauma_name == "TRA_emot_11_17" 
replace trauma_ord = 4 if trauma_name == "TRA_emng_11_17" 
replace trauma_ord = 5 if trauma_name == "TRA_sxab_11_17" 
replace trauma_ord = 6 if trauma_name == "TRA_dmvl_11_17" 
replace trauma_ord = 7 if trauma_name == "TRA_bull_11_17" 

sort trait_ord trauma_ord age

gen notrait_notrauma_95CI = strofreal(notrait_notrauma, "%5.2f") + " (" + strofreal(notrait_notrauma_lci, "%5.2f") + ", " + strofreal(notrait_notrauma_uci, "%5.2f") + ")" 
gen trait_notrauma_95CI = strofreal(trait_notrauma, "%5.2f") + " (" + strofreal(trait_notrauma_lci, "%5.2f") + ", " + strofreal(trait_notrauma_uci, "%5.2f") + ")" 
gen notrait_trauma_95CI = strofreal(notrait_trauma, "%5.2f") + " (" + strofreal(notrait_trauma_lci, "%5.2f") + ", " + strofreal(notrait_trauma_uci, "%5.2f") + ")" 
gen trait_trauma_95CI = strofreal(trait_trauma, "%5.2f") + " (" + strofreal(trait_trauma_lci, "%5.2f") + ", " + strofreal(trait_trauma_uci, "%5.2f") + ")" 


order trait trauma age 
keep trait trauma age *95CI

export excel using "$Datadir\Trajectories\Trajectories_trauma_estimates.xlsx", replace firstrow(var) 


********************************************************************************
log close
