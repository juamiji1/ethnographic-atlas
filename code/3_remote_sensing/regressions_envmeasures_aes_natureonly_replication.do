/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Regressions with Nature Exclusive Measures (REPLICATION)
DATE:

NOTES: This do-file replicates the results from regressions_envmeasures_aes_natureonly.do
       using the pre-prepared dataset created by create_data_natureonly.do
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
gl plots "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\plots"
gl tables "C:\Users\juami\Dropbox\Overleaf\Nathan-Maps\tables"

cd "${data}"

*Setting a pre-scheme for plots
set scheme s2mono
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray

*-------------------------------------------------------------------------------
* Load pre-prepared data
*-------------------------------------------------------------------------------
use "${data}/final/data_remote_sensing.dta", clear

*-------------------------------------------------------------------------------
* Standardize dependent variables
*-------------------------------------------------------------------------------
gl depvar "bii sh_treecover changewater hii"

foreach yvar of global depvar {
	cap drop std_`yvar'
	egen std_`yvar'= std(`yvar')
}

replace std_hii=-std_hii

*-------------------------------------------------------------------------------
* Create country fixed effects dummies
*-------------------------------------------------------------------------------
cap drop country_code_*
tab country_code, g(country_code_)

*Valid country codes (based on available data)
gl countrycodes "country_code_1 country_code_2 country_code_3 country_code_6 country_code_9 country_code_10 country_code_12 country_code_13 country_code_14 country_code_16 country_code_17 country_code_20 country_code_21 country_code_22 country_code_24 country_code_25 country_code_26 country_code_27 country_code_28 country_code_30 country_code_31 country_code_32 country_code_34 country_code_35 country_code_36 country_code_39 country_code_40 country_code_41 country_code_42 country_code_43 country_code_44 country_code_45 country_code_46 country_code_47 country_code_48 country_code_51 country_code_52 country_code_53 country_code_55 country_code_56 country_code_57 country_code_58 country_code_59 country_code_60 country_code_61 country_code_62 country_code_63 country_code_65 country_code_67 country_code_68 country_code_70 country_code_71 country_code_72 country_code_73 country_code_74 country_code_75 country_code_76 country_code_83 country_code_84 country_code_85 country_code_86 country_code_88 country_code_89 country_code_91 country_code_92 country_code_93 country_code_94 country_code_96 country_code_97 country_code_99 country_code_100 country_code_101 country_code_102 country_code_106 country_code_107 country_code_108 country_code_109 country_code_111 country_code_112 country_code_113 country_code_115 country_code_118 country_code_119 country_code_120 country_code_122 country_code_126 country_code_129 country_code_130 country_code_131 country_code_133 country_code_136 country_code_137 country_code_138 country_code_139 country_code_141 country_code_142 country_code_143 country_code_144 country_code_146 country_code_147 country_code_148 country_code_151 country_code_152 country_code_153 country_code_154 country_code_155 country_code_157 country_code_158 country_code_159 country_code_160 country_code_161 country_code_163 country_code_164 country_code_168 country_code_169 country_code_178 country_code_179 country_code_180 country_code_181 country_code_183 country_code_184 country_code_185 country_code_187 country_code_188 country_code_189 country_code_191 country_code_192 country_code_193 country_code_195 country_code_196 country_code_197 country_code_198 country_code_199 country_code_200 country_code_201 country_code_202 country_code_204 country_code_205 country_code_206 country_code_207 country_code_208 country_code_210 country_code_211 country_code_212 country_code_213 country_code_214 country_code_215 country_code_218 country_code_219 country_code_220 country_code_221 country_code_222 country_code_223 country_code_224 country_code_225 country_code_226"

*-------------------------------------------------------------------------------
* Set up regression specifications
*-------------------------------------------------------------------------------
gl X1_int "sh_nat_socl_atl"
gl X2_int "sh_nat_scl_atl sh_nat_ocl_atl"

gl X0 "${countrycodes}"
gl X1 "hii ${countrycodes}"
gl X2 "hii share_gc_* ${countrycodes}"

gl if " "

*-------------------------------------------------------------------------------
* Estimations + capture R2/mean/SD per model
*-------------------------------------------------------------------------------
eststo clear 

** Column 1 
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl)

eststo aes0: avg_effect bii sh_treecover changewater if missing_values==0, x(${X0} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n0 = "`e(N)'"
di $n0 

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl0="`r(ndistinct)'"
di $cl0 

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany0 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd0    = "`=string(round(r(sd), .0001), "%9.3f")'"
	di $meany0
	di $sd0
restore 

** Column 2
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii)

eststo aes1: avg_effect bii sh_treecover changewater if missing_values==0, x(${X1} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n1 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl1="`r(ndistinct)'"

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany1 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd1    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore 

** Column 3 
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_socl_atl hii)

eststo aes2: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X1_int}) effectvar(${X1_int}) controltest(missing_values==0) cl(eafolk_id)
gl n2 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl2="`r(ndistinct)'"

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany2 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd2    = "`=string(round(r(sd), .0001), "%9.3f")'"
restore 

** Column 4 
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl)

eststo aes3: avg_effect bii sh_treecover changewater if missing_values==0, x(${X0} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n3 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl3="`r(ndistinct)'"

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany3 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd3   = "`=string(round(r(sd), .0001), "%9.3f")'"
restore 

** Column 5 
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes4: avg_effect bii sh_treecover changewater if missing_values==0, x(${X1} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n4 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl4="`r(ndistinct)'"

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany4 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd4  = "`=string(round(r(sd), .0001), "%9.3f")'"
restore 

** Column 6 
drop missing_values
egen missing_values = rowmiss(bii sh_treecover changewater sh_nat_scl_atl sh_nat_ocl_atl hii)

eststo aes5: avg_effect bii sh_treecover changewater if missing_values==0, x(${X2} ${X2_int}) effectvar(${X2_int}) controltest(missing_values==0) cl(eafolk_id)
gl n5 = "`e(N)'"

*Number of clusters
distinct eafolk_id if missing_values==0
gl cl5="`r(ndistinct)'"

** Now save mean and standard deviation of all dependent variables together 
preserve  
	gen reg_sample = e(sample)
	keep if reg_sample == 1
** Standardize variables 
	drop std_bii std_sh_treecover std_changewater
	foreach var of varlist bii sh_treecover changewater {
	egen std_`var'= std(`var')
}
	rename (std_bii std_sh_treecover std_changewater) (std1 std2 std3)
	gen num=_n
	reshape long std, i(num) j(name)
	sum std
	gl meany5 = "`=string(round(r(mean), .0001), "%9.3f")'"
	gl sd5 = "`=string(round(r(sd), .0001), "%9.3f")'"
restore 


*-------------------------------------------------------------------------------
* Tables
*-------------------------------------------------------------------------------
*Exporting results dummy
esttab aes0 aes1 aes2 aes3 aes4 aes5 using "${tables}/Table_folklore_z_env_natureonly_replication.tex", keep(ae_sh_nat_socl_atl ae_sh_nat_scl_atl ae_sh_nat_ocl_atl) ///
	coeflabels( ///
    ae_sh_nat_socl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject or object in a triplet}}" ///
    ae_sh_nat_scl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}subject in a triplet}}" ///
    ae_sh_nat_ocl_atl "\multirow{2}{*}{\shortstack{Share of motifs with at least one nature-only\\ \hspace{1em}object in a triplet}}") ///
    se nocons star(* 0.10 ** 0.05 *** 0.01) ///
    label nolines fragment nomtitle nonumbers noobs nodep collabels(none) ///
    booktabs b(3) replace ///
	prehead(`"\begin{tabular}[t]{l*{6}{c}}"' ///
			`"\toprule"' ///
			`" & \multicolumn{6}{c}{Environmental Measures (AES) - Nature Exclusive} \\"' ///
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
			 `"Ethnic-folklore clusters & ${cl0} & ${cl1} & ${cl2} & ${cl3} & ${cl4} & ${cl5} \\"' ///
			 `"\bottomrule"' ///
			 `"\end{tabular}"')

di _n "Replication completed successfully!"
