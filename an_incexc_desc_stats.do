capture log close
log using "$Logdir\LOG_an_incexcdesc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-03-16
* Description: Descriptive statistics of inclusion in the study population
********************************************************************************
* Contents
********************************************************************************
* 1 Create environment and load data
* 2 Create descriptive statistics using table1_mc package 

********************************************************************************
* 1 create environment and load data
********************************************************************************
* load required packages
* ssc install table1_mc

* load data
cd "$Datadir\Descriptives"
use "$Datadir\ALSPAC_derived.dta", clear

********************************************************************************
* 2 Create descriptive statistics using table1_mc package 
********************************************************************************
table1_mc,  by(flag_inclusion) ///
			vars( /// 
			casediagtf4  cat %5.1f \ /// 
			casediagf24  cat %5.1f \ /// 
			ASD  cat %5.1f \ /// 
			bin_scdc   cat %5.1f \ /// 
			bin_coherence   cat %5.1f \ /// 
			bin_repbehaviour   cat %5.1f \ /// 
			bin_sociability   cat %5.1f \ /// 
			bin_afms   cat %5.1f \ /// 
			bin_aPRS  cat %5.1f \ /// 
			male cat %5.1f \ ///
			parity cat %5.1f \ ///
			matsoc cat %5.1f \ ///
			mat_degree cat %5.1f \ ///
			finprob cat %5.1f \ ///
			ant_anx conts %5.1f \ ///
			post_anx conts  %5.1f \ ///
			preg_EPDS_bin cat %5.1f \ /// 
			postpreg_EPDS_bin cat %5.1f \ ///   
			homeowner cat %5.1f \ ///   
			dwelltype cat %5.1f \ ///   
			matage contn %5.1f \ ///
			depression_PRS contn %5.1f \ ///	
			mathisdep cat %5.1f \ ///   
			marital cat %5.1f \ ///
			income cat %5.1f \ ///   
			affordbin cat %5.1f \ ///   
			caruse cat %5.1f \ ///  
			TRA_any_11_17  cat %5.1f \ /// 
			TRA_bull_11_17  cat %5.1f \ /// 
			TRA_dmvl_11_17  cat %5.1f \ /// 
			TRA_sxab_11_17  cat %5.1f \ /// 
			TRA_emng_11_17  cat %5.1f \ /// 
			TRA_emot_11_17  cat %5.1f \ /// 
			TRA_phys_11_17  cat %5.1f \ /// 
			ACE_count_cat  cat %5.1f \ /// 
				) ///
			nospace onecol missing total(before) test ///
			saving("$Datadir\Descriptives\Incexc_desc.xlsx", replace)
 
log close

