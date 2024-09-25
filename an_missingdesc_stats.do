capture log close
log using "$Logdir\LOG_an_missingdesc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-04-29
* Description: Missing data descriptive statistics of ALSPAC Autism and autism traits
********************************************************************************
* Contents
********************************************************************************
* 1 Create environment and load data
* 2 Create missing data descriptive statistics using table1_mc package 
* 3 Create ORs for inclusion
* create formats in each dataset
********************************************************************************
* 1 create environment and load data
********************************************************************************
* load required packages
* ssc install table1_mc

* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion 		== 1

********************************************************************************
* 2 Create descriptive statistics using table1_mc package 
********************************************************************************
foreach expvar in asd scdc cohe repb soci afms aPRS {
	foreach outage in 18 24 {
		table1_mc,  by(flag_cca_`expvar'_`outage') ///
					vars( /// 
					casediagtf4  cat %5.1f \ /// 
					casediagf24  cat %5.1f \ /// 
					ASD cat %5.1f \ /// 
					bin_scdc cat %5.1f \ /// 
					bin_coh  cat %5.1f \ /// 
					bin_repbehaviour  cat %5.1f \ /// 
					bin_sociability cat %5.1f \ /// 
					bin_afms cat %5.1f \ /// 
					bin_aPRS cat %5.1f \ /// 
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
						) ///
					nospace onecol missing total(before) test ///
					saving("$Datadir\Missing_data_descriptives\MissDesc_`expvar'_`outage'.xlsx", replace)
	}				
}					 




********************************************************************************
* 3 Create ORs for inclusion
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' outage str20 stat statlev ///
				   asdOR asdLCI asdUCI ///
				   scdcOR scdcLCI scdcUCI ///
				   coheOR coheLCI coheUCI ///
				   repbOR repbLCI repbUCI ///
				   sociOR sociLCI sociUCI ///
				   afmsOR afmsLCI afmsUCI ///
				   aPRSOR aPRSLCI aPRSUCI ///				   
				   using "$Datadir\Missing_data_descriptives\Missdat_ORs.dta", replace

foreach outage in 18 24{
	foreach stat in "casediagtf4"  "casediagf24" "ASD" "bin_scdc" "bin_coh" "bin_repbehaviour" "bin_sociability" "bin_afms" "bin_aPRS" "male" "parity" "matsoc" "mat_degree" "finprob" "ant_anx" "post_anx" "preg_EPDS_bin" "postpreg_EPDS_bin" "homeowner" "dwelltype" "matage" "depression_PRS" "mathisdep" "marital" "income" "affordbin" "caruse" "TRA_any_11_17" "TRA_bull_11_17"  "TRA_dmvl_11_17"  "TRA_sxab_11_17"  "TRA_emng_11_17"  "TRA_emot_11_17"  "TRA_phys_11_17"  {
		disp "stat = `stat'"			
		
		if "`stat'" == "male"  | "`stat'" == "parity" | "`stat'" == "matsoc" |"`stat'" == "mat_degree" | "`stat'" == "finprob" | "`stat'" == "preg_EPDS_bin" | "`stat'" == "postpreg_EPDS_bin" | "`stat'" == "homeowner" | "`stat'" == "dwelltype" | "`stat'" == "mathisdep" | "`stat'" == "marital" | "`stat'" == "income" | "`stat'" == "affordbin" | "`stat'" == "caruse" | "`stat'" == "TRA_any_11_17"  | "`stat'" == "TRA_bull_11_17"  | "`stat'" == "TRA_dmvl_11_17"  | "`stat'" == "TRA_sxab_11_17"  | "`stat'" == "TRA_emng_11_17"  | "`stat'" == "TRA_emot_11_17"  | "`stat'" == "TRA_phys_11_17"  | "`stat'" == "ACE_count_cat" | "`stat'" == "casediagtf4"  | "`stat'" == "casediagf24" | "`stat'" == "ASD" | "`stat'" == "bin_scdc" | "`stat'" == "bin_coh" | "`stat'" == "bin_repbehaviour" | "`stat'" == "bin_sociability" | "`stat'" == "bin_afms" | "`stat'" == "bin_aPRS"  {
			tab `stat', matcell(matcountTotal)
			local nlevs = r(r)
			tab `stat' flag_cca_asd_`outage',  matcell(matcountasd) matrow(statlevs)

			logistic flag_cca_asd_`outage' i.`stat'
			est store A
			logistic flag_cca_scdc_`outage' i.`stat'
			est store B
			logistic flag_cca_cohe_`outage' i.`stat'
			est store C
			logistic flag_cca_repb_`outage' i.`stat'
			est store D
			logistic flag_cca_soci_`outage' i.`stat'
			est store E
			logistic flag_cca_afms_`outage' i.`stat'
			est store F
			logistic flag_cca_aPRS_`outage' i.`stat'
			est store G			

			forvalues lev = 1(1)`nlevs' {
				disp `lev'
				local statlev = statlevs[`lev',1]
				
				est restore A
				local asdOR    	 = exp(e(b)[1,`lev']) 
				local asdLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
				local asdUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

				est restore B
				local scdcOR 	 = exp(e(b)[1,`lev'])  
				local scdcLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
				local scdcUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

				est restore C
				local coheOR     = exp(e(b)[1,`lev'])  
				local coheLCI    = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				local coheUCI    = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

				est restore D	
				local repbOR 	 = exp(e(b)[1,`lev'])  
				local repbLCI  	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				local repbUCI  	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

				est restore E		
				local sociOR	 = exp(e(b)[1,`lev'])  
				local sociLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				local sociUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				
				est restore F		
				local afmsOR	 = exp(e(b)[1,`lev'])  
				local afmsLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				local afmsUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 				
				
				est restore G		
				local aPRSOR	 = exp(e(b)[1,`lev'])  
				local aPRSLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				local aPRSUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
				
				post `memhold' (`outage') ("`stat'") (`statlev') ///
							   (`asdOR')  (`asdLCI')  (`asdUCI')  ///
							   (`scdcOR') (`scdcLCI') (`scdcUCI') ///
							   (`coheOR') (`coheLCI') (`coheUCI') ///
							   (`repbOR') (`repbLCI') (`repbUCI') ///
							   (`sociOR') (`sociLCI') (`sociUCI') ///
							   (`afmsOR') (`afmsLCI') (`afmsUCI') ///
							   (`aPRSOR') (`aPRSLCI') (`aPRSUCI') 
							   
			}
		}
		else if "`stat'" == "ant_anx" | "`stat'" == "post_anx" | "`stat'" == "matage" | "`stat'" ==  "depression_PRS"  {
			
			logistic flag_cca_asd_`outage' `stat'
			est store A
			logistic flag_cca_scdc_`outage' `stat'
			est store B
			logistic flag_cca_cohe_`outage' `stat'
			est store C
			logistic flag_cca_repb_`outage' `stat'
			est store D
			logistic flag_cca_soci_`outage' `stat'
			est store E
			logistic flag_cca_afms_`outage' `stat'
			est store F
			logistic flag_cca_aPRS_`outage' `stat'
			est store G			

			est restore A
			local asdOR    	 = exp(e(b)[1,1]) 
			local asdLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
			local asdUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))

			est restore B
			local scdcOR 	 = exp(e(b)[1,1])  
			local scdcLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
			local scdcUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))

			est restore C
			local coheOR     = exp(e(b)[1,1])  
			local coheLCI    = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
			local coheUCI    = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 

			est restore D	
			local repbOR 	 = exp(e(b)[1,1])  
			local repbLCI  	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
			local repbUCI  	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 

			est restore E		
			local sociOR	 = exp(e(b)[1,1])  
			local sociLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
			local sociUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
			
			est restore F		
			local afmsOR	 = exp(e(b)[1,1])  
			local afmsLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
			local afmsUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
			
			est restore G		
			local aPRSOR	 = exp(e(b)[1,1])  
			local aPRSLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
			local aPRSUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 			
			
			post `memhold' (`outage') ("`stat'") (0) ///
				   (`asdOR')  (`asdLCI')  (`asdUCI')  ///
				   (`scdcOR') (`scdcLCI') (`scdcUCI') ///
				   (`coheOR') (`coheLCI') (`coheUCI') ///
				   (`repbOR') (`repbLCI') (`repbUCI') ///
				   (`sociOR') (`sociLCI') (`sociUCI') ///
				   (`afmsOR') (`afmsLCI') (`afmsUCI') ///			
				   (`aPRSOR') (`aPRSLCI') (`aPRSUCI') 			

		}
	}
}
postclose `memhold'



********************************************************************************
* create formats in each dataset
********************************************************************************
use "$Datadir\Missing_data_descriptives\Missdat_ORs.dta", clear

gen asdORCI  = strofreal(asdOR, "%5.2f") + " (" + strofreal(asdLCI, "%5.2f") + "-" + strofreal(asdUCI, "%5.2f") + ")" if asdOR != 1
replace asdORCI = "Ref" if asdORCI == ""

gen scdcORCI = strofreal(scdcOR, "%5.2f") + " (" + strofreal(scdcLCI, "%5.2f") + "-" + strofreal(scdcUCI, "%5.2f") + ")" if scdcOR != 1
replace scdcORCI = "Ref" if scdcORCI == ""

gen coheORCI = strofreal(coheOR, "%5.2f") + " (" + strofreal(coheLCI, "%5.2f") + "-" + strofreal(coheUCI, "%5.2f") + ")" if coheOR != 1
replace coheORCI = "Ref" if coheORCI == ""

gen repbORCI = strofreal(repbOR, "%5.2f") + " (" + strofreal(repbLCI, "%5.2f") + "-" + strofreal(repbUCI, "%5.2f") + ")" if repbOR != 1
replace repbORCI = "Ref" if repbORCI == ""

gen sociORCI = strofreal(sociOR, "%5.2f") + " (" + strofreal(sociLCI, "%5.2f") + "-" + strofreal(sociUCI, "%5.2f") + ")" if sociOR != 1
replace sociORCI = "Ref" if sociORCI == ""

gen afmsORCI = strofreal(afmsOR, "%5.2f") + " (" + strofreal(afmsLCI, "%5.2f") + "-" + strofreal(afmsUCI, "%5.2f") + ")" if afmsOR != 1
replace afmsORCI = "Ref" if afmsORCI == ""

gen aPRSORCI = strofreal(aPRSOR, "%5.2f") + " (" + strofreal(aPRSLCI, "%5.2f") + "-" + strofreal(aPRSUCI, "%5.2f") + ")" if aPRSOR != 1
replace aPRSORCI = "Ref" if aPRSORCI == ""

keep outage stat statlev *ORCI 
export delim using "$Datadir\Missing_data_descriptives\Missing_data_ORs.csv", delim(",") replace

log close

