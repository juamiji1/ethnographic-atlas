gl plots "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\plots"
gl tables "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\tables"

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

*Valid country codes
cap drop country_code_*
tab country_code, g(country_code_)

gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"

cap drop sh_nat_smotif_atleast sh_nat_omotif_atleast
gen sh_nat_smotif_atleast=sh_nature_smotif_atleast_nonexcl
gen sh_nat_omotif_atleast=sh_nature_omotif_atleast_nonexcl

*Labels
la var sh_nature_any_motif_atl `" "Share of motifs with any" "nature subject or object" "'
la var sh_nat_smotif_atleast `" "Share of motifs with a" "nature subject" "'
la var sh_nat_omotif_atleast `" "Share of motifs with a" "nature object" "'

*-------------------------------------------------------------------------------
* Results 
*
*-------------------------------------------------------------------------------
gl X1_int "sh_nature_any_motif_atl"
gl X2_int "sh_nat_smotif_atleast sh_nat_omotif_atleast"

gl X0 "${countrycodes}"
gl X1 "hii ${countrycodes}"
gl X2 "hii share_gc_* ${countrycodes}"

gl if " "

*-------------------------------------------------------------------------------
* Estimations + capture R2/mean/SD per model
*-------------------------------------------------------------------------------
eststo aes0: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X0} ${X1_int}) effectvar(${X1_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X1_int} ${X0} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany0 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd0    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n0 = "`r(N)'"

eststo aes1: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X1} ${X1_int}) effectvar(${X1_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X1_int} ${X1} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany1 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd1    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n1 = "`r(N)'"

eststo aes2: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X2} ${X1_int}) effectvar(${X1_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X1_int} ${X2} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany2 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd2    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n2 = "`r(N)'"

eststo aes3: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X0} ${X2_int}) effectvar(${X2_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X2_int} ${X0} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany3 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd3    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n3 = "`r(N)'"

eststo aes4: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X1} ${X2_int}) effectvar(${X2_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X2_int} ${X1} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany4 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd4    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n4 = "`r(N)'"

eststo aes5: avg_effect std_bii std_sh_treecover std_changewater ${if}, x(${X2} ${X2_int}) effectvar(${X2_int}) controltest(z_env!=.) r
qui reghdfe z_env ${X2_int} ${X2} ${if}, noabs vce(r)
qui summ z_env if e(sample), d 
gl meany5 = "`=string(round(r(mean), .0001), "%9.4f")'"
gl sd5    = "`=string(round(r(sd), .0001), "%9.4f")'"
gl n5 = "`r(N)'"

*-------------------------------------------------------------------------------
* Tables
*-------------------------------------------------------------------------------
*Exporting results dummy
esttab aes0 aes1 aes2 aes3 aes4 aes5 using "${tables}/Table_folklore_z_env.tex", keep(ae_sh_nature_any_motif_atl ae_sh_nat_smotif_atleast ae_sh_nat_omotif_atleast) ///
	coeflabels( ///
    ae_sh_nature_any_motif_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature\\ \hspace{1em}subject or object in a triplet}}" ///
    ae_sh_nat_smotif_atleast "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature\\ \hspace{1em}subject in a triplet}}" ///
    ae_sh_nat_omotif_atleast "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature\\ \hspace{1em}object in a triplet}}") ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
    booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{6}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{6}{c}{Environmental Measures (AES)} \\"' ///
			`"\cmidrule(lr){2-7}"' ///
			`" & (1) & (2) & (3) & (4) & (5) & (6) \\"' ///
			`"\midrule"') ///
	postfoot(`" & & & & & & \\"' ///
			 `" HII control & No & Yes & Yes & No & Yes & Yes \\"' ///
			 `" Climatic zones control & No & No & Yes & No & No & Yes \\"' ///
			 `" Country fixed effects &  Yes & Yes & Yes & Yes & Yes & Yes \\"' ///			 
			 `" & & & & & & \\"' ///
			 `"Observations & ${n0} & ${n1} & ${n2} & ${n3} & ${n4} & ${n5} \\"' ///
			 `"Mean of dep. var. & ${meany0} & ${meany1} & ${meany2} & ${meany3} & ${meany4} & ${meany5} \\"' ///
			 `"Standard deviation of dep. var. & ${sd0} & ${sd1} & ${sd2} & ${sd3} & ${sd4} & ${sd5} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')


			 

			 
			 
*END
