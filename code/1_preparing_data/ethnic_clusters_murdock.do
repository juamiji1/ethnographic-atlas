
import delimited "C:\Users\juami\Dropbox\Nathan project\ethnic_clusters.txt", delimiter("&") clear

gen s = ustrregexra(v1,"\(.+?\)","")

replace s = subinstr(s,"Others:","",.)
replace s = subinstr(s,";",",",.)
replace s = subinstr(s,":",",",.)
replace s = subinstr(s,".",",",.)
replace s = subinstr(s,"'","",.)

split s, parse(,) gen(stub_)

drop v1 s stub_1

ren stub_2 ethcluster

reshape long stub_, i(ethcluster) j(n)
ren stub_ ethgroup

drop n 
drop if ethgroup==""

replace ethgroup=strtrim(ethgroup)

bys ethgroup: gen x=_n

reshape wide ethcluster, i(ethgroup) j(x)

replace ethgroup=upper(ethgroup)

save "C:\Users\juami\Dropbox\Nathan project\data\interim\ethnic_clusters_murdock.dta", replace


use "C:\Users\juami\Dropbox\Nathan project\data\raw\ethnographic_atlas\ethnographic_atlas_fixed.dta" , clear

gen ethgroup = subinstr(v107,".","",.)
replace ethgroup=strtrim(ethgroup)

merge 1:1 ethgroup using "C:\Users\juami\Dropbox\Nathan project\data\interim\ethnic_clusters_murdock.dta", keep(1 3)

tab _merge



