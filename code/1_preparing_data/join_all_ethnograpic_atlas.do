/*------------------------------------------------------------------------------
PROJECT: Guerrillas & Development
AUTHOR: JMJR
TOPIC: Master do-file
DATE:

NOTES: 
------------------------------------------------------------------------------*/

clear all 

*Setting directories 
if c(username) == "juami" {
	gl localpath "C:\Users/`c(username)'\Dropbox\EA-Maps-Nathan-project"
	*gl overleafpath "C:\Users/`c(username)'\Dropbox\Overleaf\GD-draft-slv"
	gl do "C:\Github\ethnographic-atlas\code"
	
}
else {
	*gl path "C:\Users/`c(username)'\Dropbox\"
}

gl data "${localpath}\data"
gl maps "${localpath}\maps"
gl tables "${overleafpath}\tables"
gl plots "${overleafpath}\plots"

cd "${data}"

*Setting a pre-scheme for plots
grstyle init
grstyle title color black
grstyle color background white
grstyle color major_grid dimgray


*-------------------------------------------------------------------------------
* Append all information together
*
*-------------------------------------------------------------------------------
use "raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear

*Dropping labels for ArcGIS
label drop _all

*Fixing locations 
replace v106=-72 if v106==72 & v107=="MISTASSIN"

*Dropping outliers in the "ethnographic_atlas_XY_geoutlier.xslx" file (many of them are europeans in other places)
drop if v107=="BOERS . ."
drop if v107=="BRAZILIAN"
drop if v107=="FRENCHCAN"
drop if v107=="NEWENGLAN"

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

*Dropping societies with information before 1001 AC (the date was chosen so we do not include Imperial Romans)
tab v107 if v102<1001
drop if v102<1001

export delimited using "raw\ethnographic_atlas\ethnographic_atlas_vfinal.csv", replace

*Appending the rest
append using "raw\ethnographic_atlas\Easternmost_Europe_final.dta" "raw\ethnographic_atlas\Siberia_final.dta" 

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "raw\ethnographic_atlas\ethnographic_atlas_east_siberia_vfinal.csv", replace

append using "raw\ethnographic_atlas\WES_final.dta"

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "raw\ethnographic_atlas\ethnographic_atlas_east_siberia_wes_vfinal.csv", replace


*-------------------------------------------------------------------------------
* Fixing apart each data set for the map
*
*-------------------------------------------------------------------------------
use "raw\ethnographic_atlas\Easternmost_Europe_final.dta", clear

*Appending the rest
append using "raw\ethnographic_atlas\Siberia_final.dta" 

*Dropping labels for ArcGIS
label drop _all

*Dropping societies with information before 1001 AC (the date was chosen so we do not include Imperial Romans)
drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "raw\ethnographic_atlas\east_siberia_vfinal.csv", replace


*WES
use "raw\ethnographic_atlas\WES_final.dta", clear

*Dropping labels for ArcGIS
label drop _all

*Dropping societies with information before 1001 AC (the date was chosen so we do not include Imperial Romans)
drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "raw\ethnographic_atlas\wes_vfinal.csv", replace



*END