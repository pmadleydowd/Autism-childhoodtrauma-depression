log using "$Logdir\LOG_an_flowchart.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 21 July 2022
* Description: Flow chart of data for ALSPAC vitamin D project
********************************************************************************
* Contents
************
* 1 Create environment and load data
* 2 Descriptives statistics for inclusion in analyses

********************************************************************************
* 1 create environment and load data
*************************************
use "$Datadir\ALSPAC_derived.dta", clear

********************************************************************************
* 2 Descriptives statistics for inclusion in analyses
*******************************************************
tab flag_alive1yr, mis // 14,865: 14,901 - 14865 = 36 withdrawn consent 
tab flag_firstchild if flag_alive1yr == 1 // 186 children removed as not the first child in a multiple pregnancy 
count if flag_firstchild & flag_alive1yr == 1

tab flag_exposureany if flag_alive1yr == 1 & flag_firstchild == 1 // 14,455 with any exposure data
tab flag_outcomeany if flag_alive1yr == 1 & flag_firstchild == 1 // 9,659 with any outcome data 
tab flag_inclusion // 9,517 included in the study 


log close