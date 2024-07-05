
*-------------------------------------------------------------------------------
* CREATING BEREZKIN TO WES+SEE CONCORDANCE (EXTENSION ON MICHALOUPOLUS DATA)
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Checking what groups are in the concordance table of Michalopoulous 
*-------------------------------------------------------------------------------
use "${data}/raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear
gen ea=1
keep v107 v114 ea

tempfile EA
save `EA', replace

use "${data}/raw\ethnographic_atlas\WES_final.dta", clear
gen wes=1
keep v107 v114 wes

tempfile WES
save `WES', replace

use "${data}/raw\ethnographic_atlas\Easternmost_Europe_final.dta", clear
append using "${data}/raw\ethnographic_atlas\Siberia_final.dta" 

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

use "${data}/raw\folklore_motifs\Motifs_EA_groups.dta", clear

merge 1:1 atlas using `WESEE'

tab _merge source, m 

*-------------------------------------------------------------------------------
* Adding the corresponding berezkin group to the WES+SEE sample 
*-------------------------------------------------------------------------------
*File with concordances and sources coming from "\interim\berezkin_WESEE_fix\fix_bereskin_WESEE_possible_match_FINAL.xlxs"
replace oid = 10 if atlas == "BAGIELLI"
replace oid = 72 if atlas == "BASHKIR"
replace oid = 93 if atlas == "BONDO"
replace oid = 10001 if atlas == "TAGALOG"
replace oid = 132 if atlas == "UNGAZIKMIT"
replace oid = 167 if atlas == "CHUVASH"
replace oid = 197 if atlas == "DANES"
replace oid = 232 if atlas == "ENGLISH 1600"
replace oid = 234 if atlas == "ESTONIANS"
replace oid = 816 if atlas == "EVENK"
replace oid = 242 if atlas == "FINNS"
replace oid = 248 if atlas == "FRENCH PROVENCE"
replace oid = 251 if atlas == "GAGAUZ"
replace oid = 256 if atlas == "GERMANS PRUSSIA"
replace oid = 265 if atlas == "CAWAHIB"
replace oid = 283 if atlas == "TAJIK (MOUNTAIN)"
replace oid = 306 if atlas == "INGRIANS"
replace oid = 306 if atlas == "VOTES"
replace oid = 313 if atlas == "ITALIANS SICILY"
replace oid = 236 if atlas == "ITELMEN"
replace oid = 338 if atlas == "KARELIANS"
replace oid = 409 if atlas == "LATVIANS"
replace oid = 424 if atlas == "LITHUANIAN KARAIM"
replace oid = 424 if atlas == "LITHUANIAN TATAR"
replace oid = 425 if atlas == "LIVS"
replace oid = 535 if atlas == "AETA"
replace oid = 451 if atlas == "MAANYAN"
replace oid = 465 if atlas == "MANSI"
replace oid = 516 if atlas == "ERZIA MORDVA"
replace oid = 534 if atlas == "NEGIDAL"
replace oid = 536 if atlas == "NEPALESE KIRANTI"
replace oid = 539 if atlas == "NGANASAN"
replace oid = 592 if atlas == "OROCH"
replace oid = 592 if atlas == "OROK"
replace oid = 592 if atlas == "ULCH"
replace oid = 651 if atlas == "MOLDOVANS"
replace oid = 739 if atlas == "ARGENTINIANS"
replace oid = 834 if atlas == "UDIHE"
replace oid = 836 if atlas == "BESERMYAN"
replace oid = 836 if atlas == "UDMURT"
replace oid = 853 if atlas == "VEPS"
replace oid = 351 if atlas == "KAZAN TATAR"
replace oid = 872 if atlas == "APALAI"
replace oid = 176 if atlas == "JAMAICANS"

*-------------------------------------------------------------------------------
* Filling the additional information on Motifs
*-------------------------------------------------------------------------------
drop v114 ee ea wes source _merge 
 
merge m:1 oid using "${data}/raw\folklore_motifs\Motifs_Berezkin_groups.dta", keep(1 3 4) update nogen

save "${data}/interim\Motifs_EA_WESEE_groups.dta", replace 




*END




