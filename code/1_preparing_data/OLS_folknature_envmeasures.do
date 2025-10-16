gl plots "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\plots"

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

gl depvar "sh_protected bii sh_treecover ghg sh_losswater hii sh_treeloss changewater"

foreach yvar of global depvar {
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
}
 
replace std_sh_losswater=-std_sh_losswater
replace std_hii=-std_hii

cap drop z_env
pca std_bii std_sh_treecover std_changewater, comp(1)
predict z_env, score

mat L=e(L)
mat rown L = "BII" "Tree Cover" "Water Persistence"
mat coln L = "Loadings"
mat l L

*Labels
la var sh_nature_any_motif_atl `" "Share of motifs with any" "nature subject or object" "'
la var sh_nature_smotif_atleast_nonexcl `" "Share of motifs with a" "nature subject" "'
la var sh_nature_omotif_atleast_nonexcl `" "Share of motifs with a" "nature object" "'

*Valid country codes
cap drop country_code_*
tab country_code, g(country_code_)

gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"


*-------------------------------------------------------------------------------
* Results
*
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* OLS no controls
*-------------------------------------------------------------------------------
eststo clear

gl indepvar `" "sh_nature_any_motif_atl" "sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl""'
gl X0 " "
gl if " "

local i=1
foreach xvar of global indepvar {
		
	eststo z`i': reghdfe z_env `xvar' ${X0} ${if}, abs(i.country_code) vce(r)					
	eststo b`i': reghdfe std_bii `xvar' ${X0} ${if}, abs(i.country_code) vce(r)	
	eststo c`i': reghdfe std_sh_treecover `xvar' ${X0} ${if}, abs(i.country_code) vce(r)	
	eststo w`i': reghdfe std_changewater `xvar' ${X0} ${if}, abs(i.country_code) vce(r)
	
	local i=`i'+1
}

*Environmental Index
coefplot z*, drop(_cons) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Environmental Index (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 1.2)) xlabel(0(0.2)1.2) 

gr export "${plots}\coefplot_folknature_z_env_X0.pdf", as(pdf) replace 

*Biodiversity intactness
coefplot b*, drop(_cons) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_bii_X0.pdf", as(pdf) replace 

*Tree cover 
coefplot c*, drop(_cons) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 1)) xlabel(0(0.2)1)

gr export "${plots}\coefplot_folknature_sh_treecover_X0.pdf", as(pdf) replace 

*Water loss
coefplot w*, drop(_cons) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Water Persistence (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_waterloss_X0.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* AES without Controls
*-------------------------------------------------------------------------------
gl X0 "${countrycodes}"
	
cap drop sh_nat_smotif_atleast sh_nat_omotif_atleast
gen sh_nat_smotif_atleast=sh_nature_smotif_atleast_nonexcl
gen sh_nat_omotif_atleast=sh_nature_omotif_atleast_nonexcl

eststo aes1: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X0} sh_nature_any_motif_atl) effectvar(sh_nature_any_motif_atl) controltest(z_env!=.) r 
eststo aes2: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X0} sh_nat_smotif_atleast sh_nat_omotif_atleast) effectvar(sh_nat_smotif_atleast sh_nat_omotif_atleast) controltest(z_env!=.) r

coefplot aes*, drop(_cons ${X0}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Average Effect (Std)", size(medium)) ylabel(1 `" "Share of motifs with any" "nature subject or object" "' ///
2 `" "Share of motifs with a" "nature subject" "' 3 `" "Share of motifs with a" "nature object" "',labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 .8)) xlabel(0(0.2).8) 

gr export "${plots}\coefplot_folknature_aes_X0.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* OLS with HII control
*-------------------------------------------------------------------------------
eststo clear

gl indepvar `" "sh_nature_any_motif_atl" "sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl""'
gl X1 "hii"

local i=1
foreach xvar of global indepvar {
		
	eststo z`i': reghdfe z_env `xvar' ${X1} ${if}, abs(i.country_code) vce(r)
	eststo b`i': reghdfe std_bii `xvar' ${X1} ${if}, abs(i.country_code) vce(r)	
	eststo c`i': reghdfe std_sh_treecover `xvar' ${X1} ${if}, abs(i.country_code) vce(r)	
	eststo w`i': reghdfe std_changewater `xvar' ${X1} ${if}, abs(i.country_code) vce(r)
		
	local i=`i'+1
}

*Environmental Index
coefplot z*, drop(_cons ${X1}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Environmental Index (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_z_env_X1.pdf", as(pdf) replace 

*Biodiversity intactness
coefplot b*, drop(_cons ${X1}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_bii_X1.pdf", as(pdf) replace 

*Tree cover 
coefplot c*, drop(_cons ${X1}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 1)) xlabel(0(0.2)1)

gr export "${plots}\coefplot_folknature_sh_treecover_X1.pdf", as(pdf) replace 

*Water loss
coefplot w*, drop(_cons ${X1}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Water Persistence (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_waterloss_X1.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* AES with Controls
*-------------------------------------------------------------------------------
gl X1 "${countrycodes} hii"

eststo aes1: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X1} sh_nature_any_motif_atl) effectvar(sh_nature_any_motif_atl) controltest(z_env!=.) r
eststo aes2: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X1} sh_nat_smotif_atleast sh_nat_omotif_atleast) effectvar(sh_nat_smotif_atleast sh_nat_omotif_atleast) controltest(z_env!=.) r

coefplot aes*, drop(_cons ${X1}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Average Effect (Std)", size(medium)) ylabel(1 `" "Share of motifs with any" "nature subject or object" "' ///
2 `" "Share of motifs with a" "nature subject" "' 3 `" "Share of motifs with a" "nature object" "',labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 .8)) xlabel(0(0.2).8) 

gr export "${plots}\coefplot_folknature_aes_X1.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* OLS with ALL controls
*-------------------------------------------------------------------------------
eststo clear

gl indepvar `" "sh_nature_any_motif_atl" "sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl""'
gl X2 "i.v30 i.v66 v102 v5 v3 v2 i.v95 area_km2 hii"

local i=1
foreach xvar of global indepvar {
		
	eststo z`i': reghdfe z_env `xvar' ${X2} ${if}, abs(i.country_code) vce(r)					
	eststo b`i': reghdfe std_bii `xvar' ${X2} ${if}, abs(i.country_code) vce(r)	
	eststo c`i': reghdfe std_sh_treecover `xvar' ${X2} ${if}, abs(i.country_code) vce(r)	
	eststo w`i': reghdfe std_changewater `xvar' ${X2} ${if}, abs(i.country_code) vce(r)
	
	local i=`i'+1
}

*Environmental Index
coefplot z*, drop(_cons *.v30 *.v66 v102 v5 v3 v2 *.v95 area_km2 hii) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Environmental Index (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_z_env_X2.pdf", as(pdf) replace 

*Biodiversity intactness
coefplot b*, drop(_cons *.v30 *.v66 v102 v5 v3 v2 *.v95 area_km2 hii) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_bii_X2.pdf", as(pdf) replace 

*Tree cover 
coefplot c*, drop(_cons *.v30 *.v66 v102 v5 v3 v2 *.v95 area_km2 hii) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) xscale(range(-.1 1)) xlabel(0(0.2)1)

gr export "${plots}\coefplot_folknature_sh_treecover_X2.pdf", as(pdf) replace 

*Water loss
coefplot w*, drop(_cons *.v30 *.v66 v102 v5 v3 v2 *.v95 area_km2 hii) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Water Persistence (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_waterloss_X2.pdf", as(pdf) replace

*-------------------------------------------------------------------------------
* AES with ALL Controls
*-------------------------------------------------------------------------------
foreach xvar in v30 v66 v95{
	tab `xvar', g(`xvar'_)
}

gl X2 "${countrycodes} v30_* v66_* v102 v5 v3 v2 v95_* area_km2 hii"

eststo aes1: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X2} sh_nature_any_motif_atl) effectvar(sh_nature_any_motif_atl) controltest(z_env!=.) r
eststo aes2: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X2} sh_nat_smotif_atleast sh_nat_omotif_atleast) effectvar(sh_nat_smotif_atleast sh_nat_omotif_atleast) controltest(z_env!=.) r

coefplot aes*, drop(_cons ${X2}) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Average Effect (Std)", size(medium)) ylabel(1 `" "Share of motifs with any" "nature subject or object" "' ///
2 `" "Share of motifs with a" "nature subject" "' 3 `" "Share of motifs with a" "nature object" "',labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_aes_X2.pdf", as(pdf) replace








/*-------------------------------------------------------------------------------
* Weights
*-------------------------------------------------------------------------------
eststo clear

*gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl sh_nature_scl_maj_ocl_motif_atl sh_nature_smotif_major_nonexcl sh_nature_human_acl_motif_atl"
gl indepvar "sh_nature_any_motif_atl sh_nature_smotif_atleast_nonexcl sh_nature_omotif_atleast_nonexcl"
gl X "i.v30 i.v66 v102 v5 v3 v2 i.v95 hii sh_protected"
*i.v31 too many missings (50%)

local i=1

foreach xvar of global indepvar {
		
	eststo p`i': reghdfe std_sh_protected `xvar' ${X} [aw=area_km2], abs(i.isocode_num) vce(r)		
	eststo b`i': reghdfe std_bii `xvar' ${X} [aw=area_km2], abs(i.isocode_num) vce(r)	
	eststo c`i': reghdfe std_sh_treecover `xvar' ${X} [aw=area_km2], abs(i.isocode_num) vce(r)	
	eststo w`i': reghdfe std_sh_losswater `xvar' ${X} [aw=area_km2], abs(i.isocode_num) vce(r)
	local i=`i'+1
} 

* Protected area 
coefplot p*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95 *hii sh_protected) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Protected Area (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_sh_protected_X2_weights.pdf", as(pdf) replace 

*Biodiversity intactness
coefplot b*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95 *hii sh_protected) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Biodiversity Intactness (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_bii_X2_weights.pdf", as(pdf) replace 

*Tree cover 
coefplot c*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95 *hii sh_protected) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Forest Cover (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_sh_treecover_X2_weights.pdf", as(pdf) replace 

*Water loss
coefplot w*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95 *hii sh_protected) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Water Loss Area (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall) 

gr export "${plots}\coefplot_folknature_waterloss_X2_weights.pdf", as(pdf) replace

eststo clear

local i=1
*z_env index
foreach xvar of global indepvar {
	
	eststo z`i': reghdfe z_env `xvar' ${X} [aw=area_km2], abs(i.country_code) vce(r)		
	
	local i=`i'+1
} 

coefplot z*, drop(_cons *.v30 *.v31 nl_mean v1 v4 v2 v3 v5 *.v66 v102 *.KG_code area_km2 *.v95 *hii sh_protected) ///
ciopts(recast(rcap)) xline(0, lc(maroon) lp(dash)) legend(off) ///
xtitle("Environmental Index (Std)", size(medium)) ylabel(,labsize(medium))  ///
mlabel(cond(@pval<=.01, string(@b, "%9.3fc") + "***", cond(@pval<=.05, string(@b, "%9.3fc") + "**", cond(@pval<=.1, string(@b, "%9.3fc") + "*", cond(@pval<=.15, string(@b, "%9.3fc") + "†", string(@b, "%9.3fc")))))) mlabposition(12) mlabgap(*2) mlabsize(medsmall)

gr export "${plots}\coefplot_folknature_z_env_X2_weights.pdf", as(pdf) replace





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