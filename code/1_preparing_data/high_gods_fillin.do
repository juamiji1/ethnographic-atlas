/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: 
------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* Append all information together
*
*-------------------------------------------------------------------------------
*use "raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear
import delimited using "raw\ethnographic_atlas\ethnographic_atlas_east_siberia_wes_vfinal.csv", clear

*tab2xl v114 v34 using cluster_variation, col(1) row(1) replace

gen m_v34=(v34==0)

bys v114: egen mean_m_v34=mean(m_v34) 

tab mean_m_v34 if v34==0
count if mean_m_v34<1 & mean_m_v34>0 & v34==0
gen pfill=1 if mean_m_v34<1 & mean_m_v34>0 & v34==0


tab v34, g(d_v34_)
bys v114: egen max_d_v34_2 = max(d_v34_2)
bys v114: egen max_d_v34_3 = max(d_v34_3)
bys v114: egen max_d_v34_4 = max(d_v34_4)
bys v114: egen max_d_v34_5 = max(d_v34_5)
egen rtotal_max_d_v34= rowtotal(max_d_v34_2 max_d_v34_3 max_d_v34_4 max_d_v34_5)

tab rtotal_max_d_v34 if pfill==1

replace v34=. if v34==0
bys v114: egen mode_v34 = mode(v34), minmode

gen v34_fill=v34
replace v34_fill=mode_v34 if v34==. & rtotal_max_d_v34==1 & pfill==1

replace v34=0 if v34==.
replace v34_fill=0 if v34_fill==.

keep v107 v34_fill
export delimited using "${data}\interim\high_gods_fillin_thiessen.csv", replace

*Filling current data
import excel "${data}\interim\langa_no_overlap_biggest_clean.xls", sheet("langa_no_overlap_biggest_clean.") firstrow clear

gen m_v34=(v34==0)

bys v114: egen mean_m_v34=mean(m_v34) 

tab mean_m_v34 if v34==0
count if mean_m_v34<1 & mean_m_v34>0 & v34==0
gen pfill=1 if mean_m_v34<1 & mean_m_v34>0 & v34==0


tab v34, g(d_v34_)
bys v114: egen max_d_v34_2 = max(d_v34_2)
bys v114: egen max_d_v34_3 = max(d_v34_3)
bys v114: egen max_d_v34_4 = max(d_v34_4)
bys v114: egen max_d_v34_5 = max(d_v34_5)
egen rtotal_max_d_v34= rowtotal(max_d_v34_2 max_d_v34_3 max_d_v34_4 max_d_v34_5)

tab rtotal_max_d_v34 if pfill==1

gen flag_m=1 if v34==.

replace v34=. if v34==0
bys v114: egen mode_v34 = mode(v34), minmode

gen v34_fill=v34
replace v34_fill=mode_v34 if v34==. & rtotal_max_d_v34==1 & pfill==1

replace v34=0 if v34==.
replace v34_fill=0 if v34_fill==. & flag_m!=1

keep ID v34_fill
export delimited using "${data}\interim\high_gods_fillin_current.csv", replace








*END
