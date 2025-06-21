
*-------------------------------------------------------------------------------
* Preparing data
*
*-------------------------------------------------------------------------------

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

* Merging the satellite imagery with folklore
use "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.dta", clear

drop if id=="" 

merge 1:1 id using `WDPA', keep(1 3) nogen
merge 1:1 id using `BII', keep(1 3) nogen 
merge 1:1 id using `TREES', keep(1 3) nogen

* Creating vars of interest 
gen sh_protected=protected_km2/area_km2
gen sh_treeloss=treeloss_km2/treecover_km2

encode c1, gen(country_code)

*-------------------------------------------------------------------------------
* Results 
*
*-------------------------------------------------------------------------------
END

reghdfe sh_protected sh_nature_any_motif_atl, abs(i.country_code) vce(r)
reghdfe bii sh_nature_any_motif_atl, abs(i.country_code) vce(r)
reghdfe sh_treeloss sh_nature_any_motif_atl, abs(i.country_code) vce(r)

reghdfe sh_protected sh_nature_any_motif_atl, abs(i.country_code) vce(cl country_code)
reghdfe bii sh_nature_any_motif_atl, abs(i.country_code) vce(cl country_code)
reghdfe sh_treeloss sh_nature_any_motif_atl, abs(i.country_code) vce(cl country_code)

reghdfe sh_protected sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(r)
reghdfe bii sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(r)
reghdfe sh_treeloss sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(r)

reghdfe sh_protected sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(cl country_code)
reghdfe bii sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(cl country_code)
reghdfe sh_treeloss sh_nature_smotif_atleast_nonexcl, abs(i.country_code) vce(cl country_code)

reghdfe sh_protected sh_nature_smotif_atleast_excl, abs(i.country_code) vce(r)
reghdfe bii sh_nature_smotif_atleast_excl, abs(i.country_code) vce(r)
reghdfe sh_treeloss sh_nature_smotif_atleast_excl, abs(i.country_code) vce(r)

reghdfe sh_protected sh_nature_smotif_atleast_excl, abs(i.country_code) vce(cl country_code)
reghdfe bii sh_nature_smotif_atleast_excl, abs(i.country_code) vce(cl country_code)
reghdfe sh_treeloss sh_nature_smotif_atleast_excl, abs(i.country_code) vce(cl country_code)


reghdfe sh_protected sh_nature_smotif_atleast_nonexcl, noabs vce(r)
reghdfe bii sh_nature_smotif_atleast_nonexcl, noabs vce(r)
reghdfe sh_treeloss sh_nature_smotif_atleast_nonexcl, noabs vce(r)

reghdfe sh_treeloss sh_nature_smotif_atleast_nonexcl, noabs vce(r)