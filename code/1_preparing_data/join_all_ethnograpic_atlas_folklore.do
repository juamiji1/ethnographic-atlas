import delimited "${data}/interim\folklore_ea_nature.csv", clear 

tempfile FOLK
save `FOLK', replace

import delimited "${data}/raw\ethnographic_atlas\ethnographic_atlas_east_siberia_wes_vfinal.csv", clear 

*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

merge 1:1 atlas using `FOLK', keep(1 3) nogen 

keep v107 atlas group_berezkin-ancesplusgod_sh_med

*Imputing data on EA groups that are missing

foreach var of varlist motif_all-ancesplusgod_sh_med{
	
	gen temp_`var'=`var' if atlas=="PORTUGUES"
	egen m_temp_`var'=mean(temp_`var')
	replace `var'= m_temp_`var' if atlas=="BRAZILIAN"
	drop *temp_`var'

} 

replace group_berezkin="Portuguese" if atlas=="BRAZILIAN"

keep v107 ancestor_sh

*Export data
export delimited using "${data}/interim\EA_folklore_ancestor_sh.csv", replace 







