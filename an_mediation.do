capture log close
log using "$Logdir\LOG_an_mediation.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-May-16
* Description: Mediation analysis for autism/triats, depression diagnosis at age 18 and 24 using trauma and ACEs as mediatiors
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Trauma 0-17 as a mediator - complete case analysis 
* 3 - recalculate proportion mediated
********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion == 1


********************************************************************************
* 2 - Trauma 11-17 as a mediator - CCA
********************************************************************************
* unadjusted model
*********************
foreach outcome in casediagtf4 /*casediagf24*/ {
	foreach exposure in /*ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms*/ bin_aPRS {
		foreach mediator in /*TRA_any_11_17*/ TRA_phys_11_17 TRA_emot_11_17 /* TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17*/ {
			
			cap postutil clear 
			tempname memhold
			postfile `memhold' str20 outcome str20 exposure str20 mediator N ///
						   TCE TCE_se str20 TCE_str ///
						   NDE NDE_se str20 NDE_str ///
						   NIE NIE_se str20 NIE_str ///
						   PM  PM_se  str20 PM_str  ///
						   CDE CDE_se str20 CDE_str ///
						   using "$Datadir\Mediation\gformula_unadjusted_`outcome'_`exposure'_`mediator'.dta" , replace 
			
			gformula `outcome' `exposure' `mediator', ///
				mediation outcome(`outcome') exposure(`exposure') mediator(`mediator') ///
				commands(`outcome':logit, `mediator':logit) ///
				equations(`outcome': `exposure' `mediator', `mediator': `exposure') ///
				control(`mediator':0) obe  ///
				samples(1000) seed(1234) moreMC sim(10000) minsim logOR			
			
			post `memhold' ("`outcome'") ("`exposure'") ("`mediator'") (r(N)) ///
						   (r(tce)) (r(se_tce)) ///
						   (strofreal(exp(r(tce)),"%5.2f") + " (" + strofreal(exp(r(tce)-invnormal(0.975)*r(se_tce)),"%5.2f") + ", " + strofreal(exp(r(tce)+invnormal(0.975)*r(se_tce)),"%5.2f") + ")") ///
						   (r(nde)) (r(se_nde)) ///
						   (strofreal(exp(r(nde)),"%5.2f") + " (" + strofreal(exp(r(nde)-invnormal(0.975)*r(se_nde)),"%5.2f") + ", " + strofreal(exp(r(nde)+invnormal(0.975)*r(se_nde)),"%5.2f") + ")") ///
						   (r(nie)) (r(se_nie)) ///
						   (strofreal(exp(r(nie)),"%5.2f") + " (" + strofreal(exp(r(nie)-invnormal(0.975)*r(se_nie)),"%5.2f") + ", " + strofreal(exp(r(nie)+invnormal(0.975)*r(se_nie)),"%5.2f") + ")") ///
						   (r(pm)) (r(se_pm)) ///
						   (strofreal(r(pm),"%5.2f") + " (" + strofreal(r(pm)-invnormal(0.975)*r(se_pm),"%5.2f") + "," + strofreal(r(pm)+invnormal(0.975)*r(se_pm),"%5.2f") + ")") ///
						   (r(cde)) (r(se_cde)) ///
						   (strofreal(exp(r(cde)),"%5.2f") + " (" + strofreal(exp(r(cde)-invnormal(0.975)*r(se_cde)),"%5.2f") + ", " + strofreal(exp(r(cde)+invnormal(0.975)*r(se_cde)),"%5.2f") + ")") 
		}
	}
}			   
postclose `memhold'

	

* adjusted model 
******************
local conflist "male parity matsoc mat_degree finprob ant_anx post_anx preg_EPDS_bin postpreg_EPDS_bin homeowner dwelltype matage"			   
local conflist_i "i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage"   
			   
foreach outcome in casediagtf4 /*casediagf24*/ {
	foreach exposure in /*ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms*/ bin_aPRS {
		foreach mediator in /*TRA_any_11_17*/ TRA_phys_11_17 TRA_emot_11_17 /* TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17*/ {
		
			cap postutil clear 
			tempname memhold
			postfile `memhold' str20 outcome str20 exposure str20 mediator N ///
						   TCE TCE_se str20 TCE_str ///
						   NDE NDE_se str20 NDE_str ///
						   NIE NIE_se str20 NIE_str ///
						   PM  PM_se  str20 PM_str  ///
						   CDE CDE_se str20 CDE_str ///
						   using "$Datadir\Mediation\gformula_adjusted_`outcome'_`exposure'_`mediator'.dta" , replace 
			
			
			gformula `outcome' `exposure' `mediator' `conflist', ///
				mediation outcome(`outcome') exposure(`exposure') mediator(`mediator') base_confs(`conflist')  ///
				commands(`outcome':logit, `mediator':logit) ///
				equations(`outcome': `exposure' `mediator' `conflist_i', `mediator': `exposure' `conflist_i') ///
				control(`mediator':0) obe  ///
				samples(1000) seed(1234) moreMC sim(10000) minsim logOR			
			
			post `memhold' ("`outcome'") ("`exposure'") ("`mediator'") (r(N)) ///
						   (r(tce)) (r(se_tce)) ///
						   (strofreal(exp(r(tce)),"%5.2f") + " (" + strofreal(exp(r(tce)-invnormal(0.975)*r(se_tce)),"%5.2f") + ", " + strofreal(exp(r(tce)+invnormal(0.975)*r(se_tce)),"%5.2f") + ")") ///
						   (r(nde)) (r(se_nde)) ///
						   (strofreal(exp(r(nde)),"%5.2f") + " (" + strofreal(exp(r(nde)-invnormal(0.975)*r(se_nde)),"%5.2f") + ", " + strofreal(exp(r(nde)+invnormal(0.975)*r(se_nde)),"%5.2f") + ")") ///
						   (r(nie)) (r(se_nie)) ///
						   (strofreal(exp(r(nie)),"%5.2f") + " (" + strofreal(exp(r(nie)-invnormal(0.975)*r(se_nie)),"%5.2f") + ", " + strofreal(exp(r(nie)+invnormal(0.975)*r(se_nie)),"%5.2f") + ")") ///
						   (r(pm)) (r(se_pm)) ///
						   (strofreal(r(pm),"%5.2f") + " (" + strofreal(r(pm)-invnormal(0.975)*r(se_pm),"%5.2f") + "," + strofreal(r(pm)+invnormal(0.975)*r(se_pm),"%5.2f") + ")") ///
						   (r(cde)) (r(se_cde)) ///
						   (strofreal(exp(r(cde)),"%5.2f") + " (" + strofreal(exp(r(cde)-invnormal(0.975)*r(se_cde)),"%5.2f") + ", " + strofreal(exp(r(cde)+invnormal(0.975)*r(se_cde)),"%5.2f") + ")") 
		}
	}
}			   
postclose `memhold'


********************************************************************************
* 3 - Recalculate proportion mediated
********************************************************************************
foreach outcome in casediagtf4 /*casediagf24*/ {
	foreach exposure in /*ASD*/ bin_scdc /*bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS */ {
		foreach mediator in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 /*TRA_sxab_11_17 TRA_dmvl_11_17*/ TRA_bull_11_17 {

			use "$Datadir\Mediation\gformula_unadjusted_`outcome'_`exposure'_`mediator'.dta" , clear 
			gen PM_recalc = 100 * ((NDE*(NIE-1)) / (NDE*NIE-1))
			save "$Datadir\Mediation\gformula_unadjusted_`outcome'_`exposure'_`mediator'_PMrecalc.dta" , replace
	
		
			use "$Datadir\Mediation\gformula_adjusted_`outcome'_`exposure'_`mediator'.dta" , clear 
			gen PM_recalc = 100 * ((NDE*(NIE-1)) / (NDE*NIE-1))
			save "$Datadir\Mediation\gformula_adjusted_`outcome'_`exposure'_`mediator'_PMrecalc.dta" , replace

		}
	}
}



* adjusted
clear
use "$Datadir\Mediation\gformula_adjusted_casediagtf4_bin_scdc_TRA_any_11_17_PMrecalc.dta" , clear 
foreach exposure in /*ASD*/ bin_scdc /*bin_coherence */ bin_repbehaviour /*bin_sociability bin_afms*/ bin_aPRS {
	foreach outcome in casediagtf4 casediagf24 {
		foreach mediator in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		
			cap append using "$Datadir\Mediation\gformula_adjusted_`outcome'_`exposure'_`mediator'_PMrecalc.dta" 	
		
		}		
	}
}	

duplicates drop
save "$Datadir\Mediation\gformula_adjusted_combined.dta" 	



* unadjusted
clear
use "$Datadir\Mediation\gformula_unadjusted_casediagtf4_bin_scdc_TRA_any_11_17_PMrecalc.dta" , clear 
foreach exposure in /*ASD*/ bin_scdc /*bin_coherence */ bin_repbehaviour /*bin_sociability bin_afms*/ bin_aPRS {
	foreach outcome in casediagtf4 casediagf24 {
		foreach mediator in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		
			cap append using "$Datadir\Mediation\gformula_unadjusted_`outcome'_`exposure'_`mediator'_PMrecalc.dta" 	
		
		}		
	}
}	

duplicates drop
save "$Datadir\Mediation\gformula_unadjusted_combined.dta" 	


********************************************************************************
log close