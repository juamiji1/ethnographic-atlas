import delimited "${data}/raw\folklore_motifs_Paul\motifs_ea.csv", varnames(1) clear

tempfile MOTIFS_EA
save `MOTIFS_EA', replace 

*-------------------------------------------------------------------------------
* FIXING CONVERSION FROM EA to ETHNOLOGUE (POSTCOLUMBIAN - Nunn & Giulianno, 2017)
*
*-------------------------------------------------------------------------------
use "${data}/raw\ethnologue\EthnoAtlas_Ethnologue16_extended_EE_Siberia_WES_by_language.dta", clear 

*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep id atlas v107
keep if atlas!=""

merge m:1 atlas using `MOTIFS_EA', keep(1 2 3) gen(merge_mea_wesee)		// 9 EA groups not found in the ethnologue

tab atlas if merge_mea==1
drop merge_mea

export delimited "${data}/interim\Motifs_EA_WESEE_Postcol_Paul.csv", replace

*-------------------------------------------------------------------------------
* FIXING EA MISSING VALUES OF SOME GROUPS (PRECOLUMBIAN)
*
*-------------------------------------------------------------------------------
use "raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear

*Dropping labels for ArcGIS
label drop _all

*Fixing locations 
replace v106=-72 if v106==72 & v107=="MISTASSIN"

*Dropping outliers in the "ethnographic_atlas_XY_geoutlier.xslx" file (many of them are europeans in other places)
drop if v107=="BOERS . ."
drop if v107=="BRAZILIAN"
drop if v107=="FRENCHCAN"
drop if v107=="NEWENGLAN"

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

*Dropping societies with information before 1001 AC (the date was chosen so we do not include Imperial Romans)
tab v107 if v102<1001
drop if v102<1001

export delimited using "raw\ethnographic_atlas\ethnographic_atlas_vfinal.csv", replace

*Appending the rest
append using "raw\ethnographic_atlas\Easternmost_Europe_final.dta" "raw\ethnographic_atlas\Siberia_final.dta" 

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "raw\ethnographic_atlas\ethnographic_atlas_east_siberia_vfinal.csv", replace

append using "raw\ethnographic_atlas\WES_final.dta"

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

*-------------------------------------------------------------------------------
* Merging the Folklore measures to the EA WESEE 
*-------------------------------------------------------------------------------
*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep atlas v107 v114
keep if atlas!=""

*Merging the data together
merge 1:1 atlas using `MOTIFS_EA', keep(1 3) nogen 


export delimited "${data}/interim\Motifs_EA_WESEE_Precol_Paul.csv", replace



*END