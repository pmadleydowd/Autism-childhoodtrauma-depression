capture log close
log using "$Logdir\LOG_an_odds_of_trauma.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-May-16
* Description: Model the odds of trauma
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Complete case analysis
* 3 - Multiple imputation analysis 

********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion == 1


********************************************************************************
* 2 - Complete case analysis
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str20 outcome str50 model modn modn_wout or lci uci str30 OR_CI  ///
	using "$Datadir\Odds_of_trauma\CCA_output.dta", replace

foreach exposure in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS { 
	local i = 0
	foreach outcome in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		local i = `i' + 1
		
		logistic `outcome' `exposure' if miss_confounder == 0 
		local or  = r(table)[1,1]  
		local lci = r(table)[5,1]
		local uci = r(table)[6,1]
		local modn = e(N)
		count if e(sample) & `outcome' == 1 
		local modn_wout = r(N)
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") (`modn') (`modn_wout') ///
			(`or') (`lci') (`uci') ///
			(strofreal(`or', "%5.2f") + " (" + strofreal(`lci',"%5.2f") + "-" + strofreal(`uci',"%5.2f") + ")") 		

		logistic `outcome' `exposure' i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage if miss_confounder == 0 
		local or  = r(table)[1,1]  
		local lci = r(table)[5,1]
		local uci = r(table)[6,1]		
		local modn = e(N)
		count if e(sample) & `outcome' == 1 
		local modn_wout = r(N)
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Adjusted for confounders") (`modn') (`modn_wout') ///
			(`or') (`lci') (`uci') ///
			(strofreal(`or', "%5.2f") + " (" + strofreal(`lci',"%5.2f") + "-" + strofreal(`uci',"%5.2f") + ")") 		
			

	}
}
	
postclose `memhold'



********************************************************************************
* 3 - Multiple imputation analysis 
********************************************************************************
* Load data 
***********************************
use "$Datadir\Imputed\Imputed_data.dta", clear 

cap drop TRA_any_11_17
egen TRA_any_11_17 = rowmax(TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17)


* Run analysis models
***********************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str20 outcome str50 model or lci uci str30 OR_CI fmi_exp fmi_large ///
	using "$Datadir\Odds_of_trauma\MI_output.dta", replace

foreach exposure in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability bin_afms bin_aPRS { 
	local i = 0
	foreach outcome in TRA_any_11_17 TRA_phys_11_17 TRA_emot_11_17 TRA_emng_11_17 TRA_sxab_11_17 TRA_dmvl_11_17 TRA_bull_11_17 {
		local i = `i' + 1
		
		mi estimate, eform: logistic `outcome' `exposure' 
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ///
			(r(table)[1,1]) (r(table)[5,1]) (r(table)[6,1]) ///
			(strofreal(r(table)[1,1], "%5.2f") + " (" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") ///
			(e(fmi_mi)[1,1]) (e(fmi_max_mi))


		mi estimate, eform: logistic `outcome' `exposure' i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage 
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Adjusted for confounders") ///
			(r(table)[1,1]) (r(table)[5,1]) (r(table)[6,1]) ///
			(strofreal(r(table)[1,1], "%5.2f") + " (" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") ///
			(e(fmi_mi)[1,1]) (e(fmi_max_mi))

			
			
	}
}
	
postclose `memhold'


********************************************************************************
log close 