capture log close
log using "$Logdir\cr_initial_dataset.txt", text replace 
*** Syntax template for direct users preparing datasets using child and parent based datasets.

* Created 29th October 2014 - always create a datafile using the most up to date template.
* Updated 24th May 2018 - mothers questionnaire and clinic data now dealt with separately in order to take into account separate withdrawal of consent requests.
* Updated 1st October 2018 - adding partners withdrawal of control
* Updated 12th October 2018 - cohort profile dataset has been updated and so version number updated to reflect
* Updated 9th November 2018 - ends of file paths for A, B and C files
* Updated 13th February 2019 - added checks in each section for correct withdrawal of consent frequencies
* Updated 21st February 2019 - updated withdrawal of consent frequencies
* Updated 5th March 2019 - updated withdrawal of consent frequencies
* Updated 11th March 2019 - updated withdrawal of consent frequencies
* Updated 9th May 2019 - updated withdrawal of consent frequencies
* Updated 17th March 2019 - updated withdrawal of consent frequencies
* Updated 9th August 2019 - updated withdrawal of consent frequencies
* Updated 4th Sept 2019 - updated withdrawal of consent frequencies
* Updated 24th March 2020 - updated withdrawal of consent frequencies
* Updated 5th August 2020 - updated withdrawal of consent frequencies
* Updated 9th September 2020 - updated withdrawal of consent frequencies
* Updated 25th May 2021 - updated withdrawal of consent frequencies
* Updated 27th May 2021 - updated withdrawal of consent frequencies
* Updated 3rd June 2021 - added clarification of where to inlcude variable lists
* Updated 6th Sept 2021 - updated withdrawal of consent frequencies
* Updated 21st Sept 2021 - updated child-completed withdrawal of consent frequencies


****************************************************************************************************************************************************************************************************************************
* This template is based on that used by the data buddy team and they include a number of variables by default.
* To ensure the file works we suggest you keep those in and just add any relevant variables that you need for your project.
* To add data other than that included by default you will need to add the relvant files and pathnames in each of the match commands below.
* There is a separate command for mothers questionnaires, mothers clinics, partner, mothers providing data on the child and data provided by the child themselves.
* Each has different withdrawal of consent issues so they must be considered separately.
* You will need to replace 'YOUR PATHNAME' in each section with your working directory pathname.

*****************************************************************************************************************************************************************************************************************************.

* Mother questionnaire files - in this section the following file types need to be placed:
* Mother completed Qs about herself
* Maternal grandparents social class
* Partner_proxy social class

* ALWAYS KEEP THIS SECTION IF YOU ARE USING MOTHER-BASED DATA EVEN IF ONLY MOTHER CLINIC REQUESTED

clear
set maxvar 32767	
use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\a_3e.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\b_4f.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\c_8a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\d_4b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\e_4f.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\f_2b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\g_5c.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\h_6d.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\j_5b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\k_r1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\l_r1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\m_2a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\n_3a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\p_r1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\q_r1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\r_r1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\s_r1a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\t_2a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\u_1a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\xa_1b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\xb_2a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\bestgest\bestgest.dta", nogen

keep aln mz001 mz010a mz013 mz014 mz028a mz028b ///
a006 a053 a525 ///
b032 b351 e371 b360-b369 b370-b371 b594 b650 b663 - b667 ///
c525 c590-c599 c600-c601 c645 c645a c755 c765 c800 - c804 /// 
d171a ///
e390-e391 ///
f200-f201 f304 f306 ///
h470 ///  
bestgest

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before bestgest, so replace the *** line above with additional variables. 
* If none are required remember to delete the *** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that mother based WoCs are set to .a


order aln mz010a, first
order bestgest, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\mother_quest_WoC.do"

* Check withdrawal of consent frequencies mum quest=21
tab1 mz010a, mis

save "$Rawdatdir\Data_creation\motherQ.dta", replace


********************************************************************************************************
* Mother clinic files - in this section the following file types need to be placed:
* Mother clinc data
* Mother biosamples
* Obstetrics file OB
*mult_no

* If there are no mother clinic files, this section can be starred out *
* NOTE: having to keep mz010a bestgest just to make the withdrawal of consent work - these are dropped for this file as the ones in the Mother questionnaire file are the important ones and should take priority *

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\bestgest\bestgest.dta", nogen



keep aln mz001 mz010 mz010a ///
bestgest

* Removing withdrawl of consent cases *** FOR LARGE DATASETS THIS CAN TAKE A FEW MINUTES
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that mother based WoCs are set to .a


order aln mz010a, first
order bestgest mz001, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\mother_clinic_WoC.do"

* Check withdrawal of consent frequencies mum clinic=24
tab1 mz010a, mis

save "$Rawdatdir\Data_creation\motherC.dta", replace


*****************************************************************************************************************************************************************************************************************************.
* PARTNER - ***UNBLOCK SECTION WHEN REQUIRED***
* Partner files - in this section the following file types need to be placed:
* Partner completed Qs about themself
* Partner clinic data
* Partner biosamples data
* Paternal grandparents social class
* Partner_complete social class


* NOTE: having to keep mz010a bestgest just to make the withdrawal of consent work - these are dropped for this file *

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\bestgest\bestgest.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Partner\pb_4b.dta", nogen

keep aln mz001 mz010a ///
pb250 pb251 pb252 pb253 pb254 pb255 pb256 pb257 pb258 pb259 pb260 pb261 ///
bestgest

* Removing withdrawl of consent cases *** FOR LARGE DATASETS THIS CAN TAKE A FEW MINUTES
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that partner based WoCs are set to .c

order aln mz010a, first
order bestgest mz001, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\partner_WoC.do"

* Check withdrawal of consent frequencies partner=3
tab1 mz010a, mis

save "$Rawdatdir\Data_creation\partner.dta", replace 



*****************************************************************************************************************************************************************************************************************************.
* Child BASED files - in this section the following file types need to be placed:
* Mother completed Qs about YP
* Obstetrics file OA

* ALWAYS KEEP THIS SECTION EVEN IF ONLY CHILD COMPLETED REQUESTED, although you will need to remove the *****

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\kz_5c.dta", clear
sort aln qlet
gen in_kz=1
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\cohort profile\cp_2b.dta", nogen

keep aln qlet kz011b kz021 kz030 ///
in_core in_alsp in_phase2 in_phase3 in_phase4 tripquad


* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before in_core, so replace the ***** line with additional variables.
* If none are required remember to delete the ***** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that child based WoCs are set to .b


order aln qlet kz021, first
order in_alsp tripquad, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_based_WoC.do"

* Check withdrawal of consent frequencies child based=23 (two mums of twins have withdrawn consent)
tab1 kz021, mis

save "$Rawdatdir\Data_creation\childB.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* Child COMPLETED files - in this section the following file types need to be placed:
* YP completed Qs
* Puberty Qs
* Child clinic data
* Child biosamples data
* School Qs
* Obstetrics file OC

* If there are no child completed files, this section can be starred out.
* NOTE: having to keep kz021 tripquad just to make the withdrawal of consent work - these are dropped for this file as the ones in the child BASED file are the important ones and should take priority

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\kz_5c.dta", clear
sort aln qlet
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\cohort profile\cp_2b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\f10_6b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\tf1_3b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\tf2_5a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\tf4_6a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\F24_6a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\ccs_r1b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\ccxd_2a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\cct_1c.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\YPA_r1a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\YPB_r1e.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\YPC_2a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Completed\YPE_4a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\filestore\SSCM ALSPAC\Data\Current\Quest\COVID\Q4\COVID4_YP_1a.dta", nogen 
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Based\kg_5a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Based\kr_2a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Based\ku_r2b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Child Based\kn_2a.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Longitudinal\cLon_1a.dta", nogen
merge 1:1 aln qlet using "$Rawdatdir\autistic traits and ASD diagnoses_hh20170405.dta", nogen	
merge 1:1 aln qlet using "$Rawdatdir\Autism_PRS.dta", nogen 
merge 1:1 aln qlet using "$Rawdatdir\depression_child_prs.dta", nogen keepusing(aln qlet zscore_depression*)


keep aln qlet kz021 kz030 ///
fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 ///
ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509 ff6511 ff6512 ff6513 ff6514 ff6515 ///
fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225 ///
FJCI603 FJCI608 FJCI609 FJCI350 FJCI363 FJCI1000 FJCI150 FJCI250 FJCI200 ///
FKDQ1000-FKDQ1110 FKDQ2000-FKDQ7000 ///
ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515 ///
CCXD900 CCXD902 CCXD903 CCXD904 CCXD905 CCXD906 CCXD908 CCXD909 CCXD911 CCXD912 CCXD913 CCXD914 CCXD915 ///
cct2700 cct2701 cct2702 cct2703 cct2704 cct2705 cct2706 cct2707 cct2708 cct2709 cct2710 cct2711 cct2712 ///
YPA2000 YPA2010 YPA2020 YPA2030 YPA2040 YPA2050 YPA2060 YPA2070 YPA2080 YPA2090 YPA2100 YPA2110 YPA2120 ///
YPB5000 YPB5010 YPB5030 YPB5040 YPB5050 YPB5060 YPB5080 YPB5090 YPB5100 YPB5120 YPB5130 YPB5150 YPB5170 ///
YPC1650 YPC1651 YPC1653 YPC1654 YPC1655 YPC1656 YPC1658 YPC1659 YPC1660 YPC1662 YPC1663 YPC1665 YPC1667 ///
YPE4080 YPE4082 YPE4083 YPE4084 YPE4085 YPE4086 YPE4088 YPE4089 YPE4091 YPE4092 YPE4093 YPE4094 YPE4095 ///
covid4yp_4050 - covid4yp_4062 /// 
kr554b ku506b kn3110-kn3112 kn5140 kg623b ///
clon100-clon123 clon140-clon170 clon200-clon207  ///
autism_new_confirmed_hh ///
zscore_autism_child_prs_S1-zscore_autism_child_prs_S13 ///
zscore_depression_child_prs_S1-zscore_depression_child_prs_S13 ///
tripquad

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before tripquad, so replace the ***** line with additional variables.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file.  Note that mother based WoCs are set to .b

order aln qlet kz021, first
order tripquad, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_completed_WoC.do"

* Check withdrawal of consent frequencies child completed=27 
tab1 kz021, mis

drop kz021 tripquad
save "$Rawdatdir\Data_creation\childC.dta", replace

*****************************************************************************************************************************************************************************************************************************.
** Matching all data together and saving out the final file*.
* NOTE: any linkage data should be added here*.

use "$Rawdatdir\Data_creation\childB.dta", clear
merge 1:1 aln qlet using "$Rawdatdir\Data_creation\childC.dta", nogen
merge m:1 aln using "$Rawdatdir\Data_creation\motherQ.dta", nogen
* IF mother clinic data is required please unstar the following line
/* merge m:1 aln using "YOUR PATHWAY\motherC.dta", nogen */
merge m:1 aln using "$Rawdatdir\Data_creation\partner.dta", nogen 


* Remove non-alspac children.
drop if in_alsp!=1.

* Remove trips and quads.
drop if tripquad==1

drop in_alsp tripquad
save "$Rawdatdir\ALSPAC_init.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* QC checks*
use "$Rawdatdir\ALSPAC_init.dta", clear

* Check that there are 15645 records.
count
