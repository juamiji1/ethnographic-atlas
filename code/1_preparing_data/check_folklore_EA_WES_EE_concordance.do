cd "${data}"

use "raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear
gen ea=1
keep v107 v114 ea

tempfile EA
save `EA', replace

use "raw\ethnographic_atlas\WES_final.dta", clear
gen wes=1
keep v107 v114 wes

tempfile WES
save `WES', replace

use "raw\ethnographic_atlas\Easternmost_Europe_final.dta", clear
append using "raw\ethnographic_atlas\Siberia_final.dta" 

gen ee=1
keep v107 v114 ee

append using `WES' `EA'

rename v107 atlas 

gen source=1 if ea==1
replace source=2 if wes==1
replace source=3 if ee==1

la def from 1 "EA" 2 "WES" 3 "SEE"
la val source from

tab source

replace atlas=subinstr(atlas,".","",.)
replace atlas = trim(strupper(atlas))

tempfile WESEE
save `WESEE', replace

use "raw\folklore_motifs\Motifs_EA_groups.dta", clear

merge 1:1 atlas using `WESEE'

tab _merge source, m 