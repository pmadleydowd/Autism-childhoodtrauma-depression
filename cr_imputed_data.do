cap log close
log using "$Logdir/LOG_cr_imputed_data.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-May_06
* Description: Create imputed data
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Prepare dataset 
* 3 - Prior diagnostics of imputation model 
* 4 - Run imputation model to create imputed datasets 
* 5 - Post imputation diagnostics
* 6 - Run imputation model to create imputed datasets including interacion term between social communication difficulties and any trauma 
********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir/ALSPAC_derived.dta", clear
keep if flag_inclusion == 1


********************************************************************************
* 2 - Prepare dataset 
********************************************************************************
mi set flong // prepares dataset as a multiple imputation dataset in wide format (one column per imputation per variable)
* idenpdfy which variables have missing data in them and will need to be imputed 
mi register imputed ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS ///
	casediagtf4 casediagf24 ///
	mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
	parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ///
	ant_anx post_anx homeowner dwelltype matage depression_PRS ///
	marital mathisdep income affordbin caruse ///
	TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17

mi register regular male 


********************************************************************************
* 3 - Prior diagnostics of imputation model 
********************************************************************************
	* check burn in is sufficient  
mi impute chained /// 
	(logit) ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS ///
			casediagtf4 casediagf24 ///
			parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin homeowner ///
			mathisdep income affordbin caruse ///
			TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 ///
	(pmm, knn(10)) mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
			ant_anx post_anx ///
	(mlogit) dwelltype marital /// 
	(regress) matage depression_PRS ///
	= male , burnin(200) rseed(1234) dots chainonly savetrace("$Datadir/Imputed/tracedat.dta", replace)


	* load data created above
preserve	
use "$Datadir/Imputed/tracedat.dta", clear

	* prepare dataset to trace plots 
tsset iter 

	* create line graph of the mean and SD of each variable against the iteration 
foreach var in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS casediagtf4 casediagf24 mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage depression_PRS marital mathisdep income affordbin caruse TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
	tsline `var'_mean, name(mgph_`var', replace)  
	tsline `var'_sd,   name(sdgph_`var', replace) 
}

	* exposure traces
graph combine mgph_ASD  mgph_bin_scdc  mgph_bin_coherence  mgph_bin_repbehaviour ///
			  mgph_bin_sociability mgph_bin_afms mgph_bin_aPRS ///
			  sdgph_ASD sdgph_bin_scdc sdgph_bin_coherence sdgph_bin_repbehaviour ///
			  sdgph_bin_sociability sdgph_bin_afms sdgph_bin_aPRS ///
			  , cols(2) colfirst
graph export "$Graphdir/Traceplots/exposure_traces.pdf", replace

	* outcome traces
graph combine mgph_casediagtf4  mgph_casediagf24    ///
			  sdgph_casediagtf4 sdgph_casediagf24   ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/outcome_traces.pdf", replace
	
	* confounder traces
graph combine mgph_parity mgph_matsoc mgph_mat_degree mgph_preg_EPDS_bin mgph_postpreg_EPDS_bin mgph_finprob   ///
			  sdgph_parity sdgph_matsoc sdgph_mat_degree sdgph_preg_EPDS_bin sdgph_postpreg_EPDS_bin sdgph_finprob  ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/confounder_traces1.pdf", replace

graph combine mgph_homeowner mgph_dwelltype mgph_matage mgph_ant_anx mgph_post_anx mgph_depression_PRS  ///
			  sdgph_homeowner sdgph_dwelltype sdgph_matage sdgph_ant_anx sdgph_post_anx sdgph_depression_PRS   ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/confounder_traces2.pdf", replace
	
	* auxiliary traces
graph combine mgph_marital mgph_mathisdep mgph_income mgph_affordbin mgph_caruse   ///
			  sdgph_marital sdgph_mathisdep sdgph_income sdgph_affordbin sdgph_caruse   ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/auxiliary_traces.pdf", replace

	* outcome auxiliaries
graph combine mgph_mfq_t1 mgph_mfq_t2 mgph_mfq_t3 mgph_mfq_t4 mgph_mfq_t5 mgph_mfq_t6     ///
			  sdgph_mfq_t1 sdgph_mfq_t2 sdgph_mfq_t3 sdgph_mfq_t4 sdgph_mfq_t5 sdgph_mfq_t6  ///
			  , cols(2) colfirst nodraw
graph export "$Graphdir/Traceplots/outcome_auxiliary_traces_1_6.pdf", replace

graph combine mgph_mfq_t7 mgph_mfq_t8 mgph_mfq_t9 mgph_mfq_t10 mgph_mfq_t11    ///
			  sdgph_mfq_t7 sdgph_mfq_t8 sdgph_mfq_t9 sdgph_mfq_t10 sdgph_mfq_t11  ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/outcome_auxiliary_traces_7_11.pdf", replace

	* mediator traces
graph combine mgph_TRA_phys_11_17 mgph_TRA_emot_11_17 mgph_TRA_emng_11_17 mgph_TRA_sxab_11_17 mgph_TRA_dmvl_11_17 mgph_TRA_bull_11_17 ///
			sdgph_TRA_phys_11_17 sdgph_TRA_emot_11_17 sdgph_TRA_emng_11_17 sdgph_TRA_sxab_11_17 sdgph_TRA_dmvl_11_17 sdgph_TRA_bull_11_17 ///
			  , cols(2) colfirst 
graph export "$Graphdir/Traceplots/mediator_traces.pdf", replace


	
restore			  

********************************************************************************
* 4 - Run imputation model to create imputed datasets 
********************************************************************************
mi impute chained /// 
	(logit) ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS ///
			casediagtf4 casediagf24 ///
			parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin homeowner ///
			mathisdep income affordbin caruse ///
			TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 ///
	(pmm, knn(10)) mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
			ant_anx post_anx ///
	(mlogit) dwelltype marital /// 
	(regress) matage depression_PRS ///
	= male, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed/Imputed_data.dta", replace


********************************************************************************
* 5 - Post imputation diagnostics
********************************************************************************
use "$Datadir/Imputed/Imputed_data.dta", clear

foreach var in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS casediagtf4 casediagf24 {
	preserve
	statsby mean=(r(mean)), by(_mi_m) clear: sum `var'
	save "$Datadir/Imputed/sumstats_`var'.dta", replace
	restore
}

local i = 0
foreach var in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS casediagtf4 casediagf24 {
	local i = `i' + 1
	disp `i'
	use "$Datadir/Imputed/sumstats_`var'.dta", clear 
	
	if "`var'" == "ASD" {
		local txt = "Autism diagnosis"
	}
	else if  "`var'" == "bin_scdc"{
		local txt = "Social communication difficulties"
	}	
	else if  "`var'" == "bin_coh"{
		local txt = "Coherence"
	}	
	else if  "`var'" == "bin_repbehaviour"{
		local txt = "Repetitive behaviour"
	}	
	else if  "`var'" == "bin_sociability"{
		local txt = "Sociability"
	}	
	else if  "`var'" == "bin_afms"{
		local txt = "Autism factor mean score"
	}	
	else if  "`var'" == "bin_aPRS"{
		local txt = "Autism PRS"
	}	
	else if  "`var'" == "casediagtf4"{
		local txt = "Depression diagnosis at age 18"
	}	
	else if  "`var'" == "casediagf24"{
		local txt = "Depression diagnosis at age 24"
	}		
		
	local observed = mean[1]
	two (bar mean _mi_m if _mi_m > 0, color(blue%25)), ///
		yline(`observed', lp(dash) lcol(red)) ///
		note(`txt', position(11)) ///
		xtitle("Imputation", size(small))  ///
		ytitle("Proportion", size(small))	///
		yscale(range(0 0.15))		///
		ylab(0 0.05 0.1 0.15, labsize(vsmall))  ///
		xlab(, labsize(vsmall)) ///
		graphregion(color(white))  ///
		name(fig`i', replace)
	
}
		
	
* Combine the plots in a single figure		
graph combine fig1 fig2 fig3 fig4 fig5 fig6 fig7 fig8 fig9, ///
	rows(3) graphregion(color(white)) name(fig_obs_imp, replace) ///
	caption("Dashed red line shows the proportion among the observed data", position(6) size(vsmall))

graph export "$Graphdir\Imputation_diagnostics\obs_imp.pdf", name(fig_obs_imp) replace 
graph export "$Graphdir\Imputation_diagnostics\obs_imp.png", name(fig_obs_imp) replace 


********************************************************************************
* 6 - Run imputation model to create imputed datasets including interacion term between social communication difficulties and any trauma 
********************************************************************************
use "$Datadir/ALSPAC_derived.dta", clear
keep if flag_inclusion == 1

mi set flong 
mi register imputed ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS ///
	casediagtf4 casediagf24 ///
	mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
	parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ///
	ant_anx post_anx homeowner dwelltype matage ///
	marital mathisdep income affordbin caruse ///
	TRA_any_11_17 

mi register regular male 


mi impute chained /// 
	(logit, include((casediagtf4*TRA_any_11_17) (casediagf24*TRA_any_11_17))) bin_scdc ///
	(logit, include((casediagtf4*bin_scdc) (casediagf24*bin_scdc))) TRA_any_11_17  ///
	(logit, include((bin_scdc*TRA_any_11_17))) casediagtf4 ///
	(logit, include((bin_scdc*TRA_any_11_17))) casediagf24 ///
	(logit) ASD bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS ///
			parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin homeowner ///
			mathisdep income affordbin caruse ///	
	(pmm, knn(10)) mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
			ant_anx post_anx ///
	(mlogit) dwelltype marital /// 
	(regress) matage ///
	= male, add(100) burnin(25) rseed(1234) dots 

save "$Datadir/Imputed/Imputed_data_interactions.dta", replace

		

********************************************************************************
log close 