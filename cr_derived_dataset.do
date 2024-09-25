capture log close
log using "$Logdir\LOG_cr_derived_dataset.txt", replace text 
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		14/07/2021
* Description: 	Data derivations for vitamin D and autism project 
* Notes : 		Uses code written by Alex Kwong and Hein Heuvelman
********************************************************************************
* Contents
* 1 Create environment
* 2 Prepare exposure information
* 3 Prepare outcome information
* 	3.1 - SMFQ
* 	3.2 - CIS-R
* 4 Prepare adverse childhood event information - mediator
* 5 Prepare confounder information
* 6 Derive auxiliary variables for multiple imputation
* 7 Create exclusion flags
* 8 Create flags for inclusion in CCA

* Create labels
* Restrict to only necessary variables
* Save data
********************************************************************************
* 1 Create environment
********************************************************************************
use "$Rawdatdir\ALSPAC_init.dta", clear 


********************************************************************************
* 2 Prepare autism information - exposure
********************************************************************************
label define lb_yn 0 "No" 1 "Yes"


* Derive autistic trait measures to match https://www.nature.com/articles/srep46179.pdf - equivalent to top 15% 
	* scdc 
gen scdc = kr554b 
replace scdc = . if kr554b == -6 

	* speech coherence 
gen coherence = ku506b
replace coherence = . if coherence < 0 | coherence == .b

	* repetitive behaviour 
gen _rb1 = kn3110
gen _rb2 = kn3111
gen _rb3 = kn3112
gen _rb4 = kn5140
forvalues i = 1/4 {
	replace _rb`i' = . if _rb`i'<1
}	
replace _rb4 = 3 if _rb4 == 7 
recode _rb1 (3=1) (1=3)
recode _rb2 (3=1) (1=3)
recode _rb3	(3=1) (1=3)
gen repbehaviour = _rb1 + _rb2 + _rb3 + _rb4

	* sociability
gen sociability = kg623b
replace sociability = . if inlist(sociability, -6, -5, ., .b)
	

	* rename autism diagnosis variable 
rename autism_new_confirmed_ ASD
replace ASD = . if ASD == .a | ASD == .b | ASD == .z
label var ASD "Diagnosed Autism"


* Autism Factor Mean score
	*Inverse autism factor mean scores so that positive scores reflect more ASD difficulties
rename clon207 fm
replace fm = . if fm <-100
summarize fm
gen mf1= fm*(-1) if fm>0 & fm!=. 
gen mf2= abs(fm) if fm<0 & fm!=.
gen mf_asd = max(mf1, mf2) 
	*Standardize
egen zmf_asd= std(mf_asd)
label var zmf_asd "Mean Autism Factor Score"



* Autism PRS
gen autism_PRS = zscore_autism_child_prs_S1


* create deciles for all trait variables
xtile dec_scdc 			= scdc , n(10)
xtile dec_coherence 	= coherence, n(10)   
xtile dec_repbehaviour 	= repbehaviour, n(10)   
xtile dec_sociability 	= sociability, n(10)   
xtile dec_afms 			= zmf_asd, n(10)   
xtile dec_aPRS 			= autism_PRS, n(10)   


* create binary variable for each trait equivalent to "worst" decile 
gen bin_scdc = 1 if dec_scdc == 10 
replace bin_scdc = 0 if dec_scdc < 10 

gen bin_coherence = 1 if dec_coherence == 1
replace bin_coherence = 0 if  dec_coherence > 1 &  missing(dec_coherence) == 0

gen bin_repbehaviour = 1 if dec_repbehaviour == 10 
replace bin_repbehaviour = 0 if dec_repbehaviour < 10 

gen bin_sociability = 1 if dec_sociability == 1
replace bin_sociability = 0 if dec_sociability > 1 & missing(sociability) == 0 

gen bin_afms = dec_afms == 10 if missing(dec_afms) != 1

gen bin_aPRS = dec_aPRS == 10 if missing(dec_aPRS) != 1





label var bin_scdc "Social Communication Trait"
label var bin_coherence "Speech Coherence Trait"
label var bin_repbehaviour "Repetitive Behaviour Trait"
label var bin_sociability "Sociability Temperament Trait"
label var bin_afms "Autism Factor Mean Score"
label var bin_aPRS "Autism PRS"

tab bin_scdc
tab bin_coherence
tab bin_repbehaviour
tab bin_sociability
tab bin_afms
tab bin_aPRS

* label binary variable values 
label values ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS lb_yn


********************************************************************************
* 3 Prepare depression information - outcome
********************************************************************************
* 3.1 - SMFQ
*********************

* Section written by Alex Kwong
* I tend to create duplicates of the original variable in case I need to go back to the original variable in later analysis (for any reason).

*Essentially what i do is create a loop for each of this list of variables 
*For each of these variables, I create a new variable which is indexed with n and code that variable to be 0 if the original variable was or to equal 1 if the original variable is 2 or to eual 2 if the orignal varibale is 1. 
*Then I generate a total score which is the sum of the new variables
*There should be 13 items with a score ranging from 0-26

*This is for F10 now known as timepoint 1 or mfq_t1. 
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t1=fddp110n+ fddp112n+ fddp113n+ fddp114n+ fddp115n+ fddp116n+ fddp118n+ fddp119n+ fddp121n+ fddp122n+ fddp123n+ fddp124n+ fddp125n
label variable mfq_t1"Total MFQ score for timepoint 1 but F10"
***
*This is for TF1 now known as timepoint 2 or mfq_t2
foreach var of varlist ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509 ff6511 ff6512 ff6513 ff6514 ff6515{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t2=ff6500n+ ff6502n+ ff6503n+ ff6504n+ ff6505n+ ff6506n+ ff6508n+ ff6509n+ ff6511n+ ff6512n+ ff6513n+ ff6514n+ ff6515n
label variable mfq_t2"Total MFQ score for timepoint 2 but TF1"
***
*This is for TF2 now known as timepoint 3 or mfq_t3
foreach var of varlist fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t3=fg7210n+ fg7212n+ fg7213n+ fg7214n+ fg7215n+ fg7216n+ fg7218n+ fg7219n +fg7221n+ fg7222n+ fg7223n+ fg7224n+ fg7225n
label variable mfq_t3"Total MFQ score for timepoint 3 but TF2"
***
*This is for CCS now known as timepoint 4 or mfq_t4
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t4=ccs4500n+ ccs4502n+ ccs4503n+ ccs4504n+ ccs4505n+ ccs4506n+ ccs4508n+ ccs4509n+ ccs4511n+ ccs4512n+ ccs4513n+ ccs4514n+ ccs4515n
label variable mfq_t4"Total MFQ score for timepoint 4 but CCS"
***
*This is for CCXD now known as timepoint 5 or mfq_t5
foreach var of varlist CCXD900 CCXD902 CCXD903 CCXD904 CCXD905 CCXD906 CCXD908 CCXD909 CCXD911 CCXD912 CCXD913 CCXD914 CCXD915{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t5=CCXD900n+ CCXD902n+ CCXD903n+ CCXD904n+ CCXD905n+ CCXD906n+ CCXD908n+ CCXD909n+ CCXD911n+ CCXD912n+ CCXD913n+ CCXD914n+ CCXD915n
label variable mfq_t5"Total MFQ score for timepoint 5 but CCXD"
***
*This is for CCT now known as timepoint 6 or mfq_t6
foreach var of varlist cct2700 cct2701 cct2702 cct2703 cct2704 cct2705 cct2706 cct2707 cct2708 cct2709 cct2710 cct2711 cct2712{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t6=cct2700n+ cct2701n+ cct2702n+ cct2703n+ cct2704n+ cct2705n+ cct2706n+ cct2707n+ cct2708n+ cct2709n+ cct2710n+ cct2711n+ cct2712n
label variable mfq_t6"Total MFQ score for timepoint 6 but CCT"
***
*This is for YPA now known as timepoint 7 or mfq_t7
foreach var of varlist YPA2000 YPA2010 YPA2020 YPA2030 YPA2040 YPA2050 YPA2060 YPA2070 YPA2080 YPA2090 YPA2100 YPA2110 YPA2120{
	gen `var'n=0 if `var'==3
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==1
}
gen mfq_t7=YPA2000n+ YPA2010n+ YPA2020n+ YPA2030n+ YPA2040n+ YPA2050n+ YPA2060n+ YPA2070n+ YPA2080n+ YPA2090n+ YPA2100n+ YPA2110n+ YPA2120n
label variable mfq_t7"Total MFQ score for timepoint 7 but YPA"
***
*This is for YPB now known as timepoint 8 or mfq_t8 - NOT CODED LIKE PREVIOUS BUT NOW CORRECTED AND MATCHES ALSPAC YPB FILE
foreach var of varlist YPB5000 YPB5010 YPB5030 YPB5040 YPB5050 YPB5060 YPB5080 YPB5090 YPB5100 YPB5120 YPB5130 YPB5150 YPB5170{
	gen `var'n=0 if `var'==1
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==3
}
gen mfq_t8=YPB5000n+ YPB5010n+ YPB5030n+ YPB5040n+ YPB5050n+ YPB5060n+ YPB5080n+ YPB5090n+ YPB5100n+ YPB5120n+ YPB5130n+ YPB5150n+ YPB5170n
label variable mfq_t8"Total MFQ score for timepoint 8 but YPB"
***
*This is for YPC now known as timepoint 9 or mfq_t9 - NOT CODED LIKE PREVIOUS BUT THIS CODE NOW CORRECTS THIS AND MATCHES YPC FILE
foreach var of varlist YPC1650 YPC1651 YPC1653 YPC1654 YPC1655 YPC1656 YPC1658 YPC1659 YPC1660 YPC1662 YPC1663 YPC1665 YPC1667{
	gen `var'n=0 if `var'==1
	replace `var'n=1 if `var'==2
	replace `var'n=2 if `var'==3
}
gen mfq_t9=YPC1650n+ YPC1651n+ YPC1653n+ YPC1654n+ YPC1655n+ YPC1656n+ YPC1658n+ YPC1659n+ YPC1660n+ YPC1662n+ YPC1663n+ YPC1665n+ YPC1667n
label variable mfq_t9"Total MFQ score for timepoint 9 but YPC"
***
*This is for YPE now known as timepoint 10 or mfq_t10 - CODED PROPERLY
foreach var of varlist YPE4080 YPE4082 YPE4083 YPE4084 YPE4085 YPE4086 YPE4088 YPE4089 YPE4091 YPE4092 YPE4093 YPE4094 YPE4095{
	gen `var'n=0 if `var'==0
	replace `var'n=1 if `var'==1
	replace `var'n=2 if `var'==2
}
gen mfq_t10=YPE4080n + YPE4082n + YPE4083n + YPE4084n + YPE4085n + YPE4086n + YPE4088n + YPE4089n + YPE4091n + YPE4092n + YPE4093n + YPE4094n + YPE4095n
label variable mfq_t10"Total MFQ score for timepoint 10 but YPE"
***
*This is for YPH now known as timepoint 11 or mfq_t11 - CODED PROPERLY
* Note from Alex Kwong in email sent 20th Jan 2022: the Age 28 SMFQ is located under the COVID Q4 questions. Although they are in the COVID file, they were asked at the same time as the YPH questionnaire in the COVID section of that questionnaire, which is why they are hid. However, the questions are the same (i.e., how have you felt in the last two weeks... and not about COVID specifically). 
foreach var of varlist covid4yp_4050 covid4yp_4051 covid4yp_4052 covid4yp_4053 covid4yp_4054 covid4yp_4055 covid4yp_4056 covid4yp_4057 covid4yp_4058 covid4yp_4059 covid4yp_4060 covid4yp_4061 covid4yp_4062 {
	gen `var'n=0 if `var'==0
	replace `var'n=1 if `var'==1
	replace `var'n=2 if `var'==2
}
gen mfq_t11= covid4yp_4050n + covid4yp_4051n + covid4yp_4052n + covid4yp_4053n + covid4yp_4054n + covid4yp_4055n + covid4yp_4056n + covid4yp_4057n + covid4yp_4058n + covid4yp_4059n + covid4yp_4060n + covid4yp_4061n + covid4yp_4062n
label variable mfq_t11"Total MFQ score for timepoint 11 but YPH/COVIDQ4"

*Next I check to examine the frequencies of each of the variables. 

foreach var of varlist mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 ///
mfq_t8 mfq_t9 mfq_t10 mfq_t11 {
	tab `var'
}
///
foreach var of varlist mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 ///
mfq_t8 mfq_t9 mfq_t10 mfq_t11 {
	sum `var'
}

* Create binary version for each time point
foreach var of varlist mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 /// 
mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 {
	gen `var'_b=.
	replace `var'_b=0 if `var'<=10
	replace `var'_b=1 if `var'>=11 & `var'<=30
}

label var mfq_t1_b "Binary SMFQ (>=11) at T1"
label var mfq_t2_b "Binary SMFQ (>=11) at T2"
label var mfq_t3_b "Binary SMFQ (>=11) at T3"
label var mfq_t4_b "Binary SMFQ (>=11) at T4"
label var mfq_t5_b "Binary SMFQ (>=11) at T5"
label var mfq_t6_b "Binary SMFQ (>=11) at T6"
label var mfq_t7_b "Binary SMFQ (>=11) at T7"
label var mfq_t8_b "Binary SMFQ (>=11) at T8"
label var mfq_t9_b "Binary SMFQ (>=11) at T9"
label var mfq_t10_b "Binary SMFQ (>=11) at T10"
label var mfq_t11_b "Binary SMFQ (>=11) at T11"


foreach var of varlist fddp110n ff6500n fg7210n ccs4500n CCXD900n cct2700n  /// 
YPA2000n YPB5000n YPC1650n YPE4080n covid4yp_4050n {
label variable `var' "felt miserable `var'"
}
///

foreach var of varlist fddp112n ff6502n fg7212n ccs4502n CCXD902n cct2701n /// 
YPA2010n YPB5010n YPC1651n YPE4082n covid4yp_4051n {
label variable `var' "not enjoyed anything `var'"
}
///

foreach var of varlist fddp113n ff6503n fg7213n ccs4503n CCXD903n cct2702n /// 
YPA2020n YPB5030n YPC1653n YPE4083n covid4yp_4052n {
label variable `var' "felt tired, sat around `var'"
}
///

foreach var of varlist fddp114n ff6504n fg7214n ccs4504n CCXD904n cct2703n /// 
YPA2030n YPB5040n YPC1654n YPE4084n covid4yp_4053n {
label variable `var' "felt very restless `var'"
}
///

foreach var of varlist fddp115n ff6505n fg7215n ccs4505n CCXD905n cct2704n /// 
YPA2040n YPB5050n YPC1655n YPE4085n covid4yp_4054n {
label variable `var' "felt they were no good `var'"
}
///

foreach var of varlist fddp116n ff6506n fg7216n ccs4506n CCXD906n cct2705n /// 
YPA2050n YPB5060n YPC1656n YPE4086n covid4yp_4055n {
label variable `var' "cried alot `var'"
}
///

foreach var of varlist fddp118n ff6508n fg7218n ccs4508n CCXD908n cct2706n /// 
YPA2060n YPB5080n YPC1658n YPE4088n covid4yp_4056n {
label variable `var' "found it hard to think `var'"
}
///

foreach var of varlist fddp119n ff6509n fg7219n ccs4509n CCXD909n cct2707n ///
YPA2070n YPB5090n YPC1659n YPE4089n covid4yp_4057n {
label variable `var' "hated themselves `var'"
}
///

foreach var of varlist fddp121n ff6511n fg7221n ccs4511n CCXD911n cct2708n /// 
YPA2080n YPB5100n YPC1660n YPE4091n covid4yp_4058n {
label variable `var' "felt like a bad person `var'"
}
///

foreach var of varlist fddp122n ff6512n fg7222n ccs4512n CCXD912n cct2709n /// 
YPA2090n YPB5120n YPC1662n YPE4092n covid4yp_4059n {
label variable `var' "felt lonely `var'"
}
///

foreach var of varlist fddp123n ff6513n fg7223n ccs4513n CCXD913n cct2710n /// 
YPA2100n YPB5130n YPC1663n YPE4093n covid4yp_4060n {
label variable `var' "nobody loved them `var'"
}
///

foreach var of varlist fddp124n ff6514n fg7224n ccs4514n CCXD914n cct2711n /// 
YPA2110n YPB5150n YPC1665n YPE4094n covid4yp_4061n {
label variable `var' "not as good as others `var'"
}
///

foreach var of varlist fddp125n ff6515n fg7225n ccs4515n CCXD915n cct2712n ///
YPA2120n YPB5170n YPC1667n YPE4095n covid4yp_4062n {
label variable `var' "did everything wrong `var'"
}


*********************
* 3.2 - CIS-R
*********************
* Age 18 
*********************
* Written by Hein Heuvelan 

* set necessary variables to missing (values < 0 to indicate reason)
foreach var in FJCI350 FJCI363 FJCI150 FJCI250 FJCI200 {
	tab `var', mis
	replace `var' = . if `var' < 0 | missing(`var') == 1
	tab `var', mis
}

*diagnosis of depression, mild, mod, sev*
capture drop casediagtf4
gen casediagtf4 = .
replace casediagtf4 = 0 if FJCI603 == 0 & FJCI608 == 0 & FJCI609 == 0
replace casediagtf4 = 1 if FJCI603 == 1 | FJCI608 == 1 | FJCI609 == 1
replace casediagtf4 = . if FJCI350 == .
label variable casediag `"Diagnosis of depression at age 18"'
label define lblcasediagtf4 0 "No diagnosis" 1 "Depression diagnosis"
label values casediagtf4 lblcasediagtf4
tab casediagtf4, mis 

*4 or more depressed symptoms and total score 12 or more/depressive symptoms*
capture drop depsymptf4
capture drop combine_depr_depthtstf4
egen combine_depr_depthtstf4 = rowtotal (FJCI350 FJCI363) if FJCI350 !=.
gen depsymptf4 = 0
replace depsymptf4 = 1 if ( FJCI1000 >12 |  FJCI1000 == 12) & (combine_depr_depthtstf4 > 4 | combine_depr_depthtstf4 == 4) 
replace depsymptf4 = . if FJCI350 ==.
label variable depsymptf4 `"Symptoms of depression at age 18"'
label define lbldepsymptf4 0 "Low symptoms" 1 "High symptoms"
label values depsymptf4 lbldepsymptf4 
tab depsymptf4

* both these criteria, i.e. diagnosis of depression and depressive symptoms *
capture drop diagsymptf4
gen diagsymptf4 = depsymptf4
replace diagsymptf4 = 1 if casediagtf4 == 1
replace diagsymptf4 = . if FJCI350 ==.
label variable diagsymptf4 `"Symptoms or diagnosis of depression at age 18"'
label define lbldiagsymptf4 0 "Non case" 1 "Case"
label values diagsymptf4 lbldiagsymptf4
tab diagsymptf4

*combine the 5 depsymptoms*
egen deptotnomiss=rowmiss(FJCI350 FJCI363 FJCI150 FJCI250 FJCI200)
egen deptottf4=rowtotal (FJCI350 FJCI363 FJCI150 FJCI250 FJCI200) if deptotnomiss==0
label variable deptottf4 "Total symptoms of depression at age 18"
tab deptottf4

* Age 24 
*********************
/* Equivalence between TF4 and F24
FJCI350 = Depr: Depression score: TF4 									= 
FJCI363 = Depthts: Number of depressive thoughts: TF4					= 
FJCI150 = Fatigue: Fatigue score: TF4									= 
FJCI250 = Sleep: Sleep symptom score: TF4								= 
FJCI200 = Conc: Concentration score: TF4								= 
FJCI603 = Deprmild: Mild depressive episode: TF4						= FKDQ1000
FJCI608 = Deprmod: Moderate depressive episode: TF4						= FKDQ1010
FJCI609 = Deprsev: Severe depressive episode: TF4						= FKDQ1020
FJCI1000 = DV:Deptot:Sum of all the 5 depression symptom scores: TF4	=

*/
foreach var in FKDQ1000 FKDQ1010 FKDQ1020 FKDQ5000 FKDQ5010 FKDQ5040 FKDQ5050 FKDQ5060 FKDQ5080 FKDQ5100 {
	disp "`var'"
	tab `var', mis
}

* set necessary variables to missing (values < 0 to indicate reason)
foreach var in FKDQ1000 FKDQ1010 FKDQ1020  {
	tab `var', mis
	replace `var' = . if `var' < 0 | missing(`var') == 1
	tab `var', mis
}

*diagnosis of depression, mild, mod, sev*
capture drop casediagf24
gen casediagf24 = .
replace casediagf24 = 0 if FKDQ1000 == 0 & FKDQ1010 == 0 & FKDQ1020 == 0
replace casediagf24 = 1 if FKDQ1000 == 1 | FKDQ1010 == 1 | FKDQ1020 == 1
label variable casediagf24 `"Diagnosis of depression at age 24"'
label values casediagf24 lblcasediagtf4
tab casediagf24, mis 




********************************************************************************
* 4 Prepare trauma and adverse childhood event information - mediator
********************************************************************************
* Trauma information
gen TRA_phys_0_5 = clon140  // physical abuse age 0 - 5 
gen TRA_emot_0_5 = clon141 // emotional abuse age 0 - 5 
gen TRA_dmvl_0_5 = clon142 // domestic violence age 0 - 5
gen TRA_sxab_0_5 = clon143 // sexual abuse age 0 - 5 
gen TRA_bull_0_5 = clon144 // bullying age 0 - 5
gen TRA_any_0_5  = clon145 	// any trauma age 0 - 5 

gen TRA_emng_5_11 = clon146 // emotional neglect age 5 - 11 
gen TRA_bull_5_11 = clon147 // bullying age 5 - 11
gen TRA_phys_5_11 = clon148 // physical abuse age 5 - 11
gen TRA_emot_5_11 = clon149 // emotional abuse age 5 - 11 
gen TRA_dmvl_5_11 = clon150 // domestic violence age 5 - 11
gen TRA_sxab_5_11 = clon151 // sexual abuse age 5 - 11		
gen TRA_any_5_11  = clon152	 // any trauma age 5 - 11 

gen TRA_emng_11_17 = clon153 // emotional neglect age 11 - 17 
gen TRA_bull_11_17 = clon154 // bullying age 11 - 17 
gen TRA_emot_11_17 = clon155 // emotional abuse age 11 - 17
gen TRA_phys_11_17 = clon156 // physical abuse age 11 - 17
gen TRA_sxab_11_17 = clon157 // sexual abuse age 11 - 17 
gen TRA_dmvl_11_17 = clon158 // domestic violence age 11 - 17
gen TRA_any_11_17  = clon159 // any trauma age 11 - 17 

gen TRA_bull_0_17 = clon160  // bullying age 0 - 17 
gen TRA_dmvl_0_17 = clon161 // domestic violence age 0 - 17
gen TRA_sxab_0_17 = clon162 // sexual abuse age 0 - 17 
gen TRA_emng_0_17 = clon163 // emotional neglect age 0 - 17 
gen TRA_emot_0_17 = clon164 // emotional cruelty age 0 - 17 
gen TRA_phys_0_17 = clon165 // physical cruelty age 0 - 17 
gen TRA_any_0_17  = clon166 // any trauma age 0 - 17 

gen TRA_cnt_0_5   = clon167 // number of traumas age 0 - 5 
gen TRA_cnt_5_11  = clon168 // number of traumas age 5 - 11 
gen TRA_cnt_11_17 = clon169 // number of traumas age 11 - 17 
gen TRA_cnt_0_17  = clon170 // number of traumas age 0 - 17 

gen TRA_emng_0_5 = . // dummy variable to help forloop, will delete after 

foreach i in phys emot dmvl sxab bull emng any {
	foreach j in 0_5 5_11 11_17 0_17  {
		disp "TRA_`i'_`j'"
		replace TRA_`i'_`j' = . if TRA_`i'_`j' < 0 | TRA_`i'_`j' == .b 
		
		if "`i'" == "phys" {
			local ttype = "Physical abuse"
		}
		if "`i'" == "emot" {
			local ttype = "Emotional abuse"
		}
		if "`i'" == "dmvl" {
			local ttype = "Domestic violence"
		}
		if "`i'" == "sxab" {
			local ttype = "Sexual abuse"
		}
		if "`i'" == "bull" {
			local ttype = "Bullying victimization"
		}
		if "`i'" == "emng" {
			local ttype = "Emotional neglect"
		}
		if "`i'" == "any"  {
			local ttype = "Any trauma"
		}
		
		if "`j'" == "0_5" {
			local agrp = "age 0-5"
		}
		if "`j'" == "5_11" {
			local agrp = "age 5-11"
		}
		if "`j'" == "11_17" {
			local agrp = "age 11-17"
		}
		if "`j'" == "0_17" {
			local agrp = "age 0-17"
		}
		
		label variable TRA_`i'_`j' "`ttype' `agrp'"
		label values TRA_`i'_`j' lb_yn
	}
}
drop TRA_emng_0_5 // dummy variable being dropped


* Prepare ACEs information
gen ACE_count = clon122
gen ACE_count_cat = clon123

replace ACE_count 		= . if ACE_count < 0 | missing(ACE_count)
replace ACE_count_cat 	= . if ACE_count_cat < 0 | missing(ACE_count_cat)
label variable ACE_count "ACE score classic 0-16 years"
label variable ACE_count_cat "ACE score classic 0-16 years (categorised)"
label define lb_ACE_cat 1 "0" 2 "1" 3 "2-3" 4 "4+"
label values ACE_count_cat lb_ACE_cat



********************************************************************************
* 5 Prepare covariate and confounder information
********************************************************************************

	* Child sex
gen male = 1 if kz021 == 1
replace male = 0 if kz021 == 2	
label variable male "Child sex"
label define lb_sex 0 "Female" 1 "Male"
label values male lb_sex
	
	*Parity
tab b032
tab b032, nolabel
gen parity = .
replace parity=1 if b032==0
replace parity=1 if b032 ==1
replace parity=0 if b032 ==2 | b032 ==3 | b032 ==4 | b032 ==5 |b032 ==6| ///
b032 ==7 | b032 ==8 | b032 ==11 |b032 ==13 |b032==22
label variable parity "Parity ≤1"
label define lblparity 0 "≥1 child" 1 "≤1 child"
label values parity lblparity
tab parity, miss

	* Maternal education binary - degree educated
tab c645
tab c645, nolabel
gen mat_degree = .
replace mat_degree =. if c645==-1
replace mat_degree =0 if c645==0 | c645==1
replace mat_degree =0 if c645==2 | c645==3
replace mat_degree =0 if c645==4
replace mat_degree =1 if c645==5
label variable mat_degree "Mother’s university degree attainment"
label values mat_degree lb_yn
tab mat_degree
tab mat_degree, nolabel
tab c645 mat_degree, mis


	* Maternal social class binary
tab c755
tab c755, nolabel
gen matsoc = c755 if missing(c755)==0
replace matsoc =. if c755==-1 | c755==65
replace matsoc =1 if c755==1 | c755==2 | c755==3
replace matsoc =0 if c755==4 | c755==5 | c755==6
label variable matsoc "Maternal nonmanual occupational class"
label define lblmatsoc 0 "Manual" 1 "Non-manual" 
label values matsoc lblmatsoc
tab matsoc, mis 


	* Home ownership 
tab f304
tab f304, nolabel
gen homeowner = f304 if missing(f304)==0
replace homeowner =. if f304==-1 | f304==6 | f304==.
replace homeowner = 1 if f304==0 | f304==1
replace homeowner = 0 if f304==2 | f304==3 | f304==4 | f304==5
label variable homeowner "Home ownership"
label define lblhomeowner 1 "Owned/mortgaged" 0 "Private/council rented" 
label values homeowner lblhomeowner
tab f304 homeowner, miss



	*Type of accomodation
ta f306
gen dwelltype = f306 if missing(f306)==0
replace dwelltype=. if f306==-1 | f306 ==6
replace dwelltype=1 if f306 ==1
replace dwelltype=2 if f306 ==2 | f306 ==3
replace dwelltype=3 if f306 ==4 | f306 ==5
label variable dwelltype "Type of accomodation"
label define lbldwelltype 1 "Detached" 2 "Semi-detached/terraced" 3 "Flat"
label values dwelltype lbldwelltype  
tab dwelltype, miss



	* Financial problems since pregnancy
tab b594, miss
tab b594, nolabel
gen finprob = 1
replace finprob=0 if b594==5
replace finprob=. if b594==.
label variable finprob "Financial problems since pregnancy"
label define lblfinprob 0 "No financial problems" 1 "Financial problems"
label values finprob lblfinprob 
tab finprob, miss


	
	* Maternal depression in pregnancy (18 - 32wgest)
gen epds_b_sumscore = b371 if b371 >= 0 & missing(b371)==0
gen epds_c_sumscore = c601 if c601 >= 0 & missing(c601)==0
egen preg_EPDS_tot = rowmean( epds_b_sumscore epds_c_sumscore) if epds_b_sumscore !=. & epds_c_sumscore !=.
label variable preg_EPDS_tot "mat preg EPDS - avg 18 and 32 weeks" 
tab preg_EPDS_tot , mis
gen preg_EPDS_bin = preg_EPDS_tot >= 13 if preg_EPDS_tot != . 
label variable preg_EPDS_bin "Maternal EPDS score ≥12 in pregnancy" 
label values preg_EPDS_bin lb_yn
tab preg_EPDS_bin , mis

	* Maternal depression after pregnancy (8 weeks - 8 months post pregnanct)
gen epds_e_sumscore = e391 if e391 >= 0 & missing(e391)==0
gen epds_f_sumscore = f201 if f201 >= 0 & missing(f201)==0
egen postpreg_EPDS_tot = rowmean( epds_e_sumscore epds_f_sumscore) if epds_e_sumscore !=. & epds_f_sumscore !=.
label variable postpreg_EPDS_tot "mat postnatal EPDS - avg 18 and 32 weeks" 
tab postpreg_EPDS_tot , mis
gen postpreg_EPDS_bin = postpreg_EPDS_tot >= 13 if postpreg_EPDS_tot != . 
label variable postpreg_EPDS_bin "Maternal EPDS score ≥12 post pregnancy" 
label values postpreg_EPDS_bin lb_yn
tab postpreg_EPDS_bin , mis


	* Maternal age
tab mz028a
*hist mz028a
tab mz028a, nolabel
gen matage=mz028a if missing(mz028a)==0
replace matage=. if mz028a==-10 | mz028a==-3 
label variable matage "Maternal age" 
tab matage, miss
su matage



	* Maternal antenatal anxiety
		* 18w gest
tab b351
tab b351, nolabel
gen ant_anx=b351
replace ant_anx=. if b351==-1 | b351==-7 | missing(b351)
label variable ant_anx "Maternal anxiety score at 18weeks gestation"
tab ant_anx , miss

		*8w postnatal 
tab e371
tab e371, nolabel
gen post_anx=e371
replace post_anx=. if e371==-1 | missing(e371)
label variable post_anx "Maternal anxiety score at 8 weeks postnatal"
tab post_anx, miss
 

	* Depression PRS  
gen depression_PRS = zscore_depression_child_prs_S1
label variable depression_PRS "Standardised depression PRS"


********************************************************************************
* 6 Derive auxiliary variables for multiple imputation
********************************************************************************
	*History of maternal depression 
gen mathisdep = d171a if missing(d171a)==0
replace mathisdep = 0 if d171a==2
replace mathisdep = 1 if d171a==1
label variable mathisdep "History of maternal depression"
label define lblmathisdep 0 "No" 1 "Yes"
label values mathisdep lblmathisdep
tab mathisdep, miss

	* Marital status
gen marital = a525 if a525 >= 0 & missing(a525)==0 
recode marital (-1 = .) (1=1) (2/4=2) (5=3) (6=4) // 1 = never married, 2 = previously married (currently unmarried), 3 = 1st marriage, 4 = 2nd or 3rd marriage
label define lb_marital 1 "Never married" 2 "Previously married (currently unmarried)" 3 "1st marriage" 4"2nd or 3rd marriage"
label values marital lb_marital
label variable marital "Marital status"
tab marital, mis


	* Family weekly income
gen income = h470 if missing(h470)==0
replace income =. if h470==-1 
replace income= 0 if h470==4 | h470==5 
replace income=1 if h470==1 | h470==2 | h470==3
label variable income "Weekly income >£300"
label define lblincome 0 "<100-299" 1 "300->400"
label values income lblincome
tab income, miss  


	* Financial difficulties/affordability 
tab c525
tab c525, nolabel
gen afford = c525
gen affordbin = .
replace affordbin= 0 if afford== 0 | afford==1 |afford==2 | afford==3
replace affordbin=1 if  afford==4 | afford==5 | afford==6 ///
| afford==7 | afford==8 | afford==9 | afford==10 | afford==11 | afford ==12 | afford ==13 ///
| afford==14 | afford==15
label variable affordbin "Financial difficulties during pregnancy"
label define lblaffordbin 0 "No finance difficulties" 1 "Finance difficulties"
label values affordbin lblaffordbin
tab affordbin, miss

	* Mother/partner have use of car 
tab a053
tab a053, nolabel
gen caruse = a053 if missing(a053)==0
replace caruse =. if a053==-7 | a053==-1
replace caruse =1 if a053==1 
replace caruse =0 if a053==2
label variable caruse "Use of car"
label define lblcaruse 0 "No" 1 "Yes"
label values caruse lblcaruse
tab caruse, miss


********************************************************************************
* 7 Create exclusion flags
********************************************************************************
* alive at one year 
gen flag_alive1yr = kz011b == 1 if missing(kz011b) == 0  

* singleton
gen flag_singleton = mz010a == 1 if missing(mz010a) == 0

* first child 
gen flag_firstchild = qlet == "A" if missing(qlet) == 0

* any exposure information
egen miss_exposure = rowmiss(ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability bin_afms bin_aPRS)
gen flag_exposureany = miss_exposure < 7

* any outcome information
egen miss_outcome = rowmiss(mfq_t1 mfq_t2 mfq_t3 mfq_t4 mfq_t5 mfq_t6 mfq_t7 mfq_t8 mfq_t9 mfq_t10 mfq_t11 casediagtf4 casediagf24)
gen flag_outcomeany = miss_outcome < 13 

* missing any confounder information 
egen miss_confounder = rowmiss(male parity matsoc mat_degree finprob ant_anx post_anx preg_EPDS_bin postpreg_EPDS_bin homeowner dwelltype matage)
gen flag_conf_allnomiss = miss_conf<1
gen miss_matage = missing(matage)


* meet inclusion criteria sample
gen flag_inclusion =  flag_alive1yr 	 	== 1 & ///
					  flag_firstchild		== 1 & ///
					  flag_outcomeany 		== 1 & ///
					  flag_exposureany 		== 1 
replace flag_inclusion = 0 if flag_inclusion != 1
						  
				  



********************************************************************************
* 8 Create flags for inclusion in CCA
********************************************************************************
* Create missing data flags
gen miss_asd   = missing(ASD)
gen miss_scdc  = missing(bin_scdc)
gen miss_soci  = missing(bin_sociability)
gen miss_repb  = missing(bin_repbehaviour)
gen miss_cohe  = missing(bin_coherence)
gen miss_afms  = missing(bin_afms)
gen miss_aPRS  = missing(bin_aPRS) 
gen miss_dep18 = missing(casediagtf4)
gen miss_dep24 = missing(casediagf24)

* Create flags for inclusion in complete case analysis for each outcome
gen flag_cca_asd_18  = miss_confounder == 0 & miss_dep18 ==0 & miss_asd  ==0 if flag_inclusion == 1
gen flag_cca_scdc_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_scdc ==0 if flag_inclusion == 1
gen flag_cca_soci_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_soci ==0 if flag_inclusion == 1
gen flag_cca_repb_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_repb ==0 if flag_inclusion == 1
gen flag_cca_cohe_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_cohe ==0 if flag_inclusion == 1
gen flag_cca_afms_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_afms ==0 if flag_inclusion == 1
gen flag_cca_aPRS_18 = miss_confounder == 0 & miss_dep18 ==0 & miss_aPRS ==0 if flag_inclusion == 1

gen flag_cca_asd_24  = miss_confounder == 0 & miss_dep24 ==0 & miss_asd  ==0 if flag_inclusion == 1
gen flag_cca_scdc_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_scdc ==0 if flag_inclusion == 1
gen flag_cca_soci_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_soci ==0 if flag_inclusion == 1
gen flag_cca_repb_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_repb ==0 if flag_inclusion == 1
gen flag_cca_cohe_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_cohe ==0 if flag_inclusion == 1
gen flag_cca_afms_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_afms ==0 if flag_inclusion == 1
gen flag_cca_aPRS_24 = miss_confounder == 0 & miss_dep24 ==0 & miss_aPRS ==0 if flag_inclusion == 1


********************************************************************************
* Additions post review 
********************************************************************************
* add ethnicity 
* add ID status
* add new categorical variable - bullying and other traumas

* ethnicity 
gen child_ethnicity = 0 if c804 == 1
replace child_ethnicity = 1 if c804 == 2
label define lb_eth 0 "White" 1 "All other ethnic groups combined"
label values child_ethnicity lb_eth
label variable child_ethnicity "Child's ethnicity"

* ID status from IDI project 
merge 1:1 aln qlet using "$Rawdatdir\IDI_project_ID_F70_79.dta"
replace idi_id = 0 if idi_id!=1 & in_core == 1
label values idi_id lb_yn
label variable idi_id "Intellectual disability"

 * Categorical trauma variable for bullying vs other traumas vs no trauma 
gen TRA_bullying_vs_other_11_17 = . 
replace TRA_bullying_vs_other_11_17 = 0 if TRA_any_11_17 == 0 
replace TRA_bullying_vs_other_11_17 = 1 if TRA_any_11_17 == 1 & TRA_bull_11_17 == 0 
replace TRA_bullying_vs_other_11_17 = 2 if TRA_any_11_17 == 1 & TRA_bull_11_17 == 1
label define lb_tra_bull_any 0 "No trauma" 1 "Trauma, no bullying" 2 "Trauma, bullying"
label values TRA_bullying_vs_other_11_17 lb_tra_bull_any
 
********************************************************************************
*  Restrict to only necessary variables
********************************************************************************
keep aln qlet ///
ASD zmf_asd autism_PRS scdc coherence repbehaviour sociability bin*  /// exposures
mfq* casediag* depsympt* diagsympt* deptot*  ///  outcomes
TRA* ACE* ///  mediators
male parity matsoc mat_degree finprob ant_anx post_anx preg_EPDS* postpreg_EPDS* homeowner dwelltype matage depression_PRS /// covariates
mathisdep marital income affordbin caruse /// auxiliary variables
zscore_autism_child_prs_S* zscore_depression_child_prs_*  /// PRS
child_ethnicity idi_id TRA_bullying_vs_other_11_17 /// new variables post review
flag* miss* 




********************************************************************************
* Save data
********************************************************************************
save "$Datadir\ALSPAC_derived.dta", replace

log close
