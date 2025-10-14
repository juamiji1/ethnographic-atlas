
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

append using "${data}/raw\ancestral_characteristics\Eastern_Europeans_joined_to_KG.dta" "${data}/raw\ancestral_characteristics\Siberia_joined_to_KG.dta" "${data}/raw\ancestral_characteristics\WES_joined_to_KG.dta"

keep v107 KG_code

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

merge m:1 c1 using `ISO3', keep(1 3) nogen 
merge m:1 v107 using `CLIMZ', keep(1 3) nogen 

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

gl depvar "sh_protected bii sh_treecover ghg sh_losswater hii sh_treeloss"

foreach yvar of global depvar {
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
}
 
cap drop z_env
pca std_sh_protected std_bii std_sh_treecover std_sh_losswater std_ghg, comp(1)
predict z_env, score

*Labels
la var sh_nature_any_motif_atl `" "Share of motifs with any" "nature subject or object" "'
la var sh_nature_smotif_atleast_nonexcl `" "Share of motifs with a" "nature subject" "'
la var sh_nature_omotif_atleast_nonexcl `" "Share of motifs with a" "nature object" "'
la var sh_nature_scl_maj_ocl_motif_atl `" "Share of motifs with nature" "subjects greater than" "nature objects" "'
la var sh_nature_smotif_major_nonexcl `" "Share of motifs with nature" "subjects greater than" "human subjects" "'
la var sh_nature_human_acl_motif_atl `" "Share of motifs with any" "nature-human interaction" "'

*-------------------------------------------------------------------------------
* Results 
*
*-------------------------------------------------------------------------------
eststo clear

gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl sh_nature_scl_maj_ocl_motif_atl sh_nature_smotif_major_nonexcl sh_nature_human_acl_motif_atl"
gl X "i.v30 i.v66 v102 v5 v3 v2 i.v95 area_km2 nl_mean"
*i.v31 too many missings (50%)

local i=1

foreach xvar of global indepvar {
		
	eststo p`i': reghdfe std_sh_protected `xvar' ${X}, abs(i.isocode_num) vce(r)		
	eststo b`i': reghdfe std_bii `xvar' ${X}, abs(i.isocode_num) vce(r)	
	eststo c`i': reghdfe std_sh_treecover `xvar' ${X}, abs(i.isocode_num) vce(r)	
	eststo t`i': reghdfe std_sh_treeloss `xvar' ${X}, abs(i.isocode_num) vce(r)
	eststo h`i': reghdfe std_hii `xvar' ${X}, abs(i.isocode_num) vce(r)
	eststo g`i': reghdfe std_ghg `xvar' ${X}, abs(i.isocode_num) vce(r)
	eststo w`i': reghdfe std_sh_losswater `xvar' ${X}, abs(i.isocode_num) vce(r)
	local i=`i'+1
} 

* Protected area 
coefplot p*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Protected Area (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\coefplot_folknature_sh_protected_X2.pdf", as(pdf) replace 

*Biodiversity intactness
coefplot b*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) 

gr export "${plots}\coefplot_folknature_bii_X2.pdf", as(pdf) replace 

*Tree cover 
coefplot c*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\coefplot_folknature_sh_treecover_X2.pdf", as(pdf) replace 

*HII 
coefplot h*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Human Impact Index (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) 

gr export "${plots}\coefplot_folknature_hii_X2.pdf", as(pdf) replace 

*GHG
coefplot g*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Green House Gas (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\coefplot_folknature_ghg_X2.pdf", as(pdf) replace 

*Water loss
coefplot w*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Permanent Water Area (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) 

gr export "${plots}\coefplot_folknature_waterloss_X2.pdf", as(pdf) replace

*z_env index
foreach xvar of global indepvar {
	
	eststo z`i': reghdfe z_env `xvar' ${X}, abs(i.country_code) vce(r)		
	
	local i=`i'+1
} 

coefplot z*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Environmental Index (Std)", size(medsmall)) ylabel(,labsize(small))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2)

gr export "${plots}\coefplot_folknature_z_env_X2.pdf", as(pdf) replace





*END
//
//
// *-------------------------------------------------------------------------------
// * Results 
// *
// *-------------------------------------------------------------------------------
// eststo clear
//
// gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl  sh_nature_scl_maj_ocl_motif_atl sh_nature_smotif_major_nonexcl sh_nature_human_acl_motif_atl"
//
// gl X "i.v30 i.v31 nl_mean"
// *i.v31 too many missings (50%)
//
// local i=1
//
// foreach xvar of global indepvar {
//	
// 	eststo p`i': reghdfe sh_protected `xvar' ${X}, abs(i.country_code) vce(r)		
// 	eststo b`i': reghdfe bii `xvar' ${X}, abs(i.country_code) vce(r)	
// 	eststo c`i': reghdfe sh_treecover `xvar' ${X}, abs(i.country_code) vce(r)	
// 	eststo t`i': reghdfe sh_treeloss `xvar' ${X}, abs(i.country_code) vce(r)
//	
// 	local i=`i'+1
// } 
//
// * Protected area 
// summ sh_protected, d
// gl mean_p=round(r(mean), .01)
//
// coefplot p*, drop(_cons *.v30 *.v31 nl_mean) ///
// ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
// xtitle("Protected Area (%)", size(medsmall)) ylabel(,labsize(small))  ///
// mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
// note("Dep. var mean: ${mean_p}")
//
// gr export "${plots}\coefplot_folknature_sh_protected_X1.pdf", as(pdf) replace 
//
// *Biodiversity intactness
// summ bii, d
// gl mean_b=round(r(mean), .01)
//
// coefplot b*, drop(_cons *.v30 *.v31 nl_mean) ///
// ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
// xtitle("Biodiversity Intactness (%)", size(medsmall)) ylabel(,labsize(small))  ///
// mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
// note("Dep. var mean: ${mean_b}")
//
// gr export "${plots}\coefplot_folknature_bii_X1.pdf", as(pdf) replace 
//
// *Tree cover 
// summ sh_treecover, d
// gl mean_c=round(r(mean), .01)
//
// coefplot c*, drop(_cons *.v30 *.v31 nl_mean) ///
// ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
// xtitle("Forest Cover (%)", size(medsmall)) ylabel(,labsize(small))  ///
// mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) ///
// note("Dep. var mean: ${mean_c}")
//
// gr export "${plots}\coefplot_folknature_sh_treecover_X1.pdf", as(pdf) replace 