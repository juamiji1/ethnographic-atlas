/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Create dataset for Nature Exclusive Regressions
DATE:

NOTES: This do-file creates a dataset with only the variables needed to run
       the regressions in regressions_envmeasures_aes_natureonly_replication.do
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work"
	gl do "C:\Github\ethnographic-atlas\code"
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl maps "${localpath}\maps"

cd "${data}"

*-------------------------------------------------------------------------------
* Preparing data
*
*-------------------------------------------------------------------------------
* Country and climatic zones (from Ancestral Characteristics paper)
import delimited "${data}/raw\ancestral_characteristics\countries_iso3.csv", varnames(1) clear

ren (country iso3) (c1 isocode)

tempfile ISO3
save `ISO3', replace

use "${data}/raw\ancestral_characteristics\EA_joined_to_KG.dta", clear

import delimited "${maps}/raw\KG_climatic_zones\ethnologue_KGshares.csv", varnames(1) clear

tempfile CLIMZ
save `CLIMZ', replace

use "${data}/raw\ancestral_characteristics\EA_joined_to_KG.dta", clear

tempfile CLIMZ1
save `CLIMZ1', replace

* Satellite imagery
import delimited "${maps}/raw\protected_land\ethnologue_wdpa.csv", clear

tempfile WDPA
save `WDPA', replace 

import delimited "${maps}/raw\BII\ethnologue_bii.csv", clear

tempfile BII
save `BII', replace 

import delimited "${maps}/raw\Hansen_forest\ethnologue_treecoverloss.csv", clear

tempfile TREES
save `TREES', replace 

import delimited "${maps}/raw\NL\ethnologue_nl.csv", clear

tempfile NL
save `NL', replace 

import delimited "${maps}/raw\Water_surface\perm_loss_water.csv", clear

tempfile WATER
save `WATER', replace 

import delimited "${maps}/raw\HII\ethnologue_hii.csv", clear

tempfile HII
save `HII', replace 

import delimited "${maps}/raw\CO2\ethnologue_ghg.csv", clear

tempfile GHG
save `GHG', replace 

* Merging the satellite imagery with folklore
use "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.dta", clear

drop if id=="" 

merge 1:1 id using `WDPA', keep(1 3) nogen
merge 1:1 id using `BII', keep(1 3) nogen 
merge 1:1 id using `TREES', keep(1 3) nogen
merge 1:1 id using `NL', keep(1 3) nogen 
merge 1:1 id using `WATER', keep(1 3) nogen 
merge 1:1 id using `HII', keep(1 3) nogen
merge 1:1 id using `GHG', keep(1 3) nogen 
merge m:1 id using `CLIMZ', keep(1 3) nogen 

merge m:1 c1 using `ISO3', keep(1 3) nogen 

* Creating vars of interest 
gen sh_protected=protected_km2*100/area_km2
gen sh_treeloss=treeloss_km2*100/treecover_km2
gen sh_treecover=treecover_km2*100/area_km2

replace sh_protected=. if sh_protected>100 & sh_protected!=.
replace sh_treeloss=. if sh_treeloss>100 & sh_treeloss!=.
replace sh_treecover=. if sh_treecover>100 & sh_treecover!=.

replace sh_treeloss=0 if sh_treeloss==.

gen tot_water=permwater_km2+losswater_km2
gen sh_losswater=losswater_km2*100/permwater_km2
replace sh_losswater=0 if sh_losswater==.

replace ghg=0 if ghg==.

gen sh_permwater=permwater_km2*100/area_km2
replace sh_permwater=0 if sh_permwater==.

replace bii=0 if bii==.

replace nl_mean=0 if nl_mean==.

encode c1, gen(country_code)
encode isocode, gen(isocode_num)

drop if area_km2==. 

*Nature exclusive variables 
gen sh_nat_socl_atl=sh_nature_scl_ocl_only_atl
gen sh_nat_scl_atl=sh_nature_scl_only_atl
gen sh_nat_ocl_atl=sh_nature_ocl_only_atl

*Labels
la var sh_nat_socl_atl `" "Share of motifs with nature-only" "subject or object" "'
la var sh_nat_scl_atl `" "Share of motifs with a" "nature-only subject" "'
la var sh_nat_ocl_atl `" "Share of motifs with a" "nature-only object" "'

*-------------------------------------------------------------------------------
* Keep only variables needed for the replication
*-------------------------------------------------------------------------------
* Identify all share_gc_* variables (climatic zones)
ds share_gc_*
local climvars `r(varlist)'

* Keep essential variables for replication
keep id c1 isocode country_code isocode_num eafolk_id ///
     bii sh_treecover changewater hii ///
     sh_nat_socl_atl sh_nat_scl_atl sh_nat_ocl_atl ///
     `climvars' ///
     area_km2

* Order variables
order id c1 isocode country_code isocode_num eafolk_id ///
      bii sh_treecover changewater hii ///
      sh_nat_socl_atl sh_nat_scl_atl sh_nat_ocl_atl

*-------------------------------------------------------------------------------
* Save the dataset
*-------------------------------------------------------------------------------
compress
save "${data}/final/data_remote_sensing.dta", replace

di _n "Dataset created successfully: data_natureonly_replication.dta"
di "Number of observations: " _N
describe, short
