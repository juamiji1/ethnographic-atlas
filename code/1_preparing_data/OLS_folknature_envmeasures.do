
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

import delimited "${maps}/raw\NL\ethnologue_nl.csv", clear

tempfile NL
save `NL', replace 

* Merging the satellite imagery with folklore
use "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.dta", clear

drop if id=="" 

merge 1:1 id using `WDPA', keep(1 3) nogen
merge 1:1 id using `BII', keep(1 3) nogen 
merge 1:1 id using `TREES', keep(1 3) nogen
merge 1:1 id using `NL', keep(1 3) nogen 

* Creating vars of interest 
gen sh_protected=protected_km2*100/area_km2
gen sh_treeloss=treeloss_km2*100/treecover_km2
gen sh_treecover=treecover_km2*100/area_km2

replace sh_protected=. if sh_protected>100
replace sh_treeloss=. if sh_treeloss>100
replace sh_treecover=. if sh_treecover>100
replace bii=0 if bii==.
replace nl_mean=0 if nl_mean==.

encode c1, gen(country_code)

drop if area_km2==. 


*-------------------------------------------------------------------------------
* Results 
*
*-------------------------------------------------------------------------------
eststo clear

gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl  sh_nature_scl_maj_ocl_motif_atl sh_nature_smotif_major_nonexcl sh_nature_human_acl_motif_atl"

gl X "i.v30 i.v31 nl_mean"
*i.v31 too many missings (50%)

local i=1

foreach xvar of global indepvar {
	
	eststo p`i': reghdfe sh_protected `xvar' ${X}, abs(i.country_code) vce(r)		
	eststo b`i': reghdfe bii `xvar' ${X}, abs(i.country_code) vce(r)	
	eststo c`i': reghdfe sh_treecover `xvar' ${X}, abs(i.country_code) vce(r)	
	eststo t`i': reghdfe sh_treeloss `xvar' ${X}, abs(i.country_code) vce(r)
	
	local i=`i'+1
} 

* Protected area 
summ sh_protected, d
gl mean_p=round(r(mean), .01)

coefplot p*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Protected Area (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_p}")

gr export "${plots}\coefplot_folknature_sh_protected_X1.pdf", as(pdf) replace 

*Biodiversity intactness
summ bii, d
gl mean_b=round(r(mean), .01)

coefplot b*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_b}")

gr export "${plots}\coefplot_folknature_bii_X1.pdf", as(pdf) replace 

*Tree cover 
summ sh_treecover, d
gl mean_c=round(r(mean), .01)

coefplot c*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_c}")

gr export "${plots}\coefplot_folknature_sh_treecover_X1.pdf", as(pdf) replace 


*-------------------------------------------------------------------------------
* Results 
*
*-------------------------------------------------------------------------------
eststo clear

gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl  sh_nature_scl_maj_ocl_motif_atl sh_nature_smotif_major_nonexcl sh_nature_human_acl_motif_atl"

gl X "i.v30 nl_mean"
*i.v31 too many missings (50%)

local i=1

foreach xvar of global indepvar {
	
	eststo p`i': reghdfe sh_protected `xvar' ${X}, abs(i.country_code) vce(r)		
	eststo b`i': reghdfe bii `xvar' ${X}, abs(i.country_code) vce(r)	
	eststo c`i': reghdfe sh_treecover `xvar' ${X}, abs(i.country_code) vce(r)	
	eststo t`i': reghdfe sh_treeloss `xvar' ${X}, abs(i.country_code) vce(r)
	
	local i=`i'+1
} 

* Protected area 
summ sh_protected, d
gl mean_p=round(r(mean), .01)

coefplot p*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Protected Area (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_p}")

gr export "${plots}\coefplot_folknature_sh_protected_X2.pdf", as(pdf) replace 

*Biodiversity intactness
summ bii, d
gl mean_b=round(r(mean), .01)

coefplot b*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_b}")

gr export "${plots}\coefplot_folknature_bii_X2.pdf", as(pdf) replace 

*Tree cover 
summ sh_treecover, d
gl mean_c=round(r(mean), .01)

coefplot c*, drop(_cons *.v30 *.v31 nl_mean) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (%)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
note("Dep. var mean: ${mean_c}")

gr export "${plots}\coefplot_folknature_sh_treecover_X2.pdf", as(pdf) replace 



*END