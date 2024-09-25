capture log close
log using "$Logdir\LOG_an_PRS_sumstats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-11-29
* Description: Summary statistics of Autism PRS and autism traits
********************************************************************************
* Contents
********************************************************************************
* 1 Create environment and load data
* 2 Create summary statistics for autism PRS 
* 3 Create plots

********************************************************************************
* 1 create environment and load data
********************************************************************************
* load required packages

* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion 		== 1

********************************************************************************
* 2 Create summary statistics for autism PRS 
********************************************************************************
capture postutil close 
tempname memhold
postfile `memhold' str20 exposure PRS_threshold N OR LCI UCI p using "$Datadir\PRS_sumstats\PRS_sumstats.dta", replace


foreach exp in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms {
	forvalues thresh = 1(1)13 {
		logistic `exp' zscore_autism_child_prs_S`thresh' 
		post `memhold' ("`exp'") (`thresh') (e(N)) (r(table)[1,1]) (r(table)[5,1]) (r(table)[6,1]) (r(table)[4,1])
	}	
}	

postclose `memhold'


********************************************************************************
* 3 Create plots
********************************************************************************
use "$Datadir\PRS_sumstats\PRS_sumstats.dta", clear

label define lb_threshold 1 "0.5" 2 "0.4" 3 "0.3" 4 "0.2" 5 "0.1" 6 "0.05" 7 "0.01" 8 "0.001" 9 "0.0001" 10 "0.00001" 11 "0.000001" 12 "1E-07" 13 "1E-08"
label values PRS_threshold lb_threshold 

graph drop _all
foreach trait in ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms {
	tab N if exposure == "`trait'", matrow(matnobs)
	local nobs = matnobs[1,1]

	if "`trait'" == "ASD" {
		local gtext = "A - Autism diagnosis; N = `nobs'"
	}
	if "`trait'" == "bin_scdc" {
		local gtext = "B - Social communication; N = `nobs'"
	}
	if "`trait'" == "bin_coherence" {
		local gtext = "C - Speech coherence; N = `nobs'"
	}
	if "`trait'" == "bin_repbehaviour" {
		local gtext = "D - Repetitive behaviour; N = `nobs'"
	}
	if "`trait'" == "bin_sociability" {
		local gtext = "E - Sociability; N = `nobs'"
	} 
	if "`trait'" == "bin_afms"  {
		local gtext = "F - Autism factor mean score; N = `nobs'"		
	}
	if "`trait'" == "bin_aPRS"  {
		local gtext = "G - Autism PRS; N = `nobs'" 		
	}
	disp "`trait'    " "`gtext'"
	
	
	graph twoway ///
		(rcap LCI UCI PRS_threshold if exposure =="`trait'") ///
		(scatter OR PRS_threshold   if exposure == "`trait'") , ///
		yline(1, lp(dash)) ///
		ytitle("OR for autism trait" "(95% CI)", size(small)) ///
		xtitle("Autism PRS threshold", size(small)) ///
		ylabel(, labsize(vsmall)) ///
		xlabel(1(1)13, labsize(vsmall) angle(45) valuelabel) ///
		legend(off) ///
		graphregion(color(white)) ///
		text(1.7 1 "`gtext'", size(small) place(e)) ///
		name(`trait'_plot)

}

graph combine ASD_plot bin_scdc_plot bin_coherence_plot bin_repbehaviour_plot bin_sociability_plot bin_afms_plot ///
	, cols(3) graphregion(color(white)) name("fig_PRS", replace) ycommon

graph export "$Graphdir\PRS\fig_PRS.png", name(fig_PRS) replace width(3000) height(3000)
graph export "$Graphdir\PRS\fig_PRS.pdf", name(fig_PRS) replace
	

********************************************************************************
log close

