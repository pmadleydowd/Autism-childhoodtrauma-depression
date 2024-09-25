********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		19 January 2022
* Description: 		Master file to run all do files in the correct order for Autism, depression and ACEs project 
********************************************************************************
* Contents
* 1 - Run global.do and library.do
* 2 - Create datasets
* 3 - Run descriptive analyses
* 4 - Run trajectories of depressive symptom scores


********************************************************************************
* 1 - Run global.do and library.do
********************************************************************************
do "DOFILE_DIRECTORY\global.do" 		 // sets the directories for project
do "$Dodir\library.do" 					// loads all the packages neccesary for the project 

********************************************************************************
* 2 - Create datasets
********************************************************************************
do "$Dodir\cr_initial_dataset.do"		// Create the initial ALSPAC sample
do "$Dodir\cr_derived_dataset.do"		// Create all derived variables 
do "$Dodir\cr_imputed_data.do" 			// Create imputed datasets for use in odds of diagnosis 

********************************************************************************
* 3 - Run descriptive analyses
********************************************************************************
do "$Dodir\an_flowchart.do"		 		// Create outputs for flowchart of cohort derivations
do "$Dodir\an_desc_stats.do"			// Create outputs for descriptive statistics
do "$Dodir\an_missingdesc_stats.do" 	// Create outputs for missing data descriptive statistics
do "$Dodir\an_incexc_desc_stats.do" 	// Create outputs for descriptive statistics of included versus excluded individuals
do "$Dodir\an_PRS_sumstats.do" 			// Check the association between the autism PRS and each autism trait

********************************************************************************
* 4 - Run trajectories of depressive symptom scores
********************************************************************************
do "$Dodir\an_SMFQ_traj.do" //	analyses of SMFQ trajectories

********************************************************************************
* 5 - Odds of diagnosis 
********************************************************************************
do "$Dodir\an_odds_of_diagnosis.do" // calculate odds ratios for depression diagnoses using complete case and multiple imputation models

********************************************************************************
* 6 - Mediation of associations
********************************************************************************
do "$Dodir\an_odds_of_trauma.do" // calculate odds ratios for trauma using complete case and multiple imputation models
do "$Dodir\an_mediation.do" 	 // runs mediation analyses for autism/traits and depression diagnoses via trauma variables


********************************************************************************
* 7 - Trajectories with and without childhood trauma
********************************************************************************
do "$Dodir\an_SMFQ_traj_TRA.do" //	analyses of SMFQ trajectories with and wihout childhood trauma