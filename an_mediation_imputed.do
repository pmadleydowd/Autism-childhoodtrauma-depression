capture log close
log using "$Logdir\LOG_an_mediation_imputed.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2022-May-16
* Description: Mediation analysis for autism/triats, depression diagnosis at age 18 and 24 using trauma and ACEs as mediatiors
********************************************************************************
* Contents
********************************************************************************
* 1 - Create environment and load data
* 2 - Trauma 0-17 as a mediator - imputed analysis 

********************************************************************************
* 1 - Create environment and load data
********************************************************************************
* load data
use "$Datadir\ALSPAC_derived.dta", clear
keep if flag_inclusion == 1


********************************************************************************
* 2 - Trauma 0-17 as a mediator - imputed analysis
********************************************************************************
cap postutil clear 
tempname memhold
postfile `memhold' str20 outcome str20 exposure str20 mediator N ///
			   TCE TCE_se str20 TCE_str ///
			   NDE NDE_se str20 NDE_str ///
			   NIE NIE_se str20 NIE_str ///
			   PM  PM_se  str20 PM_str  ///
			   CDE CDE_se str20 CDE_str ///
			   using "$Datadir\Mediation\gformula_trauma_adjusted_imputed.dta" , replace 

local conflist "male parity matsoc mat_degree finprob ant_anx post_anx preg_EPDS_bin postpreg_EPDS_bin homeowner dwelltype matage"			   
local conflist_i "i.male i.parity i.matsoc i.mat_degree i.finprob c.ant_anx c.post_anx i.preg_EPDS_bin i.postpreg_EPDS_bin i.homeowner i.dwelltype c.matage"   
			   
foreach outcome in casediagtf4 casediagf24 {
	foreach exposure in /*ASD*/ bin_scdc /*bin_coherence bin_repbehaviour bin_sociability*/ {
		foreach mediator in TRA_any_0_17 TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17 {
			disp "outcome: `outcome', exposure:`exposure', mediator: `mediator'"
			
			if "`mediator'" == "TRA_any_0_17" {
				gformula bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
					mediation outcome(`outcome') exposure(`exposure') mediator(`mediator') base_confs(`conflist') ///
					commands(`outcome':logit, `mediator':logit) ///
					equations(`outcome': `exposure' `mediator' `conflist_i', `mediator': `exposure' `conflist_i') ///
					control(`mediator':0) obe  ///
					impute(bin_scdc ///
							casediagtf4 casediagf24 ///
							mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b  ///
							male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx ///
							homeowner dwelltype matage ///
							marital mathisdep income affordbin caruse ///
							TRA_any_0_17) ///
					imp_cmd(bin_scdc: logit,  ///
							casediagtf4: logit, casediagf24: logit, ///
							mfq_t1_b: logit, mfq_t2_b: logit, mfq_t3_b: logit, ///
							mfq_t4_b: logit, mfq_t5_b: logit, ///
							male: logit, parity: logit, matsoc: logit, mat_degree: logit, finprob: logit, ///
							preg_EPDS_bin: logit, postpreg_EPDS_bin: logit, ant_anx: logit, post_anx: logit, ///
							homeowner: logit, dwelltype: mlogit, matage: regress, ///
							marital: mlogit, mathisdep: logit, income: logit, affordbin: logit, caruse: logit, ///
							TRA_any_0_17: logit) ///) /// 
					imp_eq(bin_scdc: casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17 ,  ///
							casediagtf4: bin_scdc casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17 , ///
							casediagf24: bin_scdc casediagtf4 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17 , ///
							mfq_t1_b: bin_scdc casediagtf4 casediagf24 mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							mfq_t2_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							mfq_t3_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							mfq_t4_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							mfq_t5_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							male: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							parity: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							matsoc: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							mat_degree: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							finprob: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							preg_EPDS_bin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, /// 
							postpreg_EPDS_bin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							ant_anx: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							post_anx: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							homeowner: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx dwelltype matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							dwelltype: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner matage marital mathisdep income affordbin caruse TRA_any_0_17, ///
							matage: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype marital mathisdep income affordbin caruse TRA_any_0_17, ///
							marital: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage mathisdep income affordbin caruse TRA_any_0_17, ///
							mathisdep: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital income affordbin caruse TRA_any_0_17, /// 
							income: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep affordbin caruse TRA_any_0_17, ///
							affordbin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income caruse TRA_any_0_17, ///
							caruse: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin TRA_any_0_17, ///
							TRA_any_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse) ///
					 samples(10) seed(1234) moreMC sim(10) minsim logOR	
			}
			disp "test 1"
			
			/*if "`mediator'" != "TRA_any_0_17" {
				gformula bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b male parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
					mediation outcome(`outcome') exposure(`exposure') mediator(`mediator') base_confs(`conflist')  ///
					commands(`outcome':logit, `mediator':logit) ///
					equations(`outcome': `exposure' `mediator' `conflist_i', `mediator': `exposure' `conflist_i') ///
					control(`mediator':0) obe   ///
					impute(bin_scdc ///
							casediagtf4 casediagf24 ///
							mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
							parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx ///
							homeowner dwelltype matage ///
							marital mathisdep income affordbin caruse ///
							TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 ///
							TRA_dmvl_0_17 TRA_bull_0_17) ///
					imp_cmd(bin_scdc: logit,  ///
							casediagtf4: logit, casediagf24: logit, ///
							mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 ///
							parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx ///
							homeowner dwelltype matage ///
							marital mathisdep income affordbin caruse ///
							TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 ///
							TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17) /// 
					imp_eq(bin_scdc: casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17,  ///
							casediagtf4: bin_scdc casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17 , ///
							casediagf24: bin_scdc casediagtf4 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17 , ///
							mfq_t1_b: bin_scdc casediagtf4 casediagf24 mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mfq_t2_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mfq_t3_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mfq_t4_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mfq_t5_b: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							parity: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							matsoc: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mat_degree: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							finprob: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree preg_EPDS_bin postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							preg_EPDS_bin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob postpreg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, /// 
							postpreg_EPDS_bin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin ant_anx post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							ant_anx: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							post_anx: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							homeowner: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							dwelltype: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							matage: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							marital: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							mathisdep: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, /// 
							income: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							affordbin: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							caruse: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							TRA_phys_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							TRA_emot_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, /// 
							TRA_emng_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_sxab_0_17 TRA_dmvl_0_17 TRA_bull_0_17, /// 
							TRA_sxab_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_dmvl_0_17 TRA_bull_0_17, ///
							TRA_dmvl_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_bull_0_17, /// 
							TRA_bull_0_17: bin_scdc casediagtf4 casediagf24 mfq_t1_b mfq_t2_b mfq_t3_b mfq_t4_b mfq_t5_b parity matsoc mat_degree finprob preg_EPDS_bin postpreg_EPDS_bin post_anx ant_anx homeowner dwelltype matage marital mathisdep income affordbin caruse TRA_phys_0_17 TRA_emot_0_17 TRA_emng_0_17 TRA_sxab_0_17 TRA_dmvl_0_17) ///
					samples(10) seed(1234) moreMC sim(10) minsim logOR	
			} */
			
			disp "test 2"
	
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
						   
			disp "test 3"
			   
		}
	}
}			   
postclose `memhold'




********************************************************************************
log close