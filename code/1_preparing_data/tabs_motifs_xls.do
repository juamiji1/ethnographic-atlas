
import delimited "${data}/raw\triplets_and_characterizations_unrolled.csv", varnames(1) clear 

replace subject=strtrim(lower(subject))
replace action=strtrim(lower(action))
replace object=strtrim(lower(object))

*Checking duplicates that comes from same sentence-motif
duplicates tag subject - desc_english_googleapi , g(dup)  //should I drop duplicates or each triplet means something different? different sentences?
tab dup

*Dropping duplicates by triplet-sentence-motif
duplicates drop subject - desc_english_googleapi, force 

gen freq=1 

*Exporting unique subject categories to be classified
preserve
	collapse (sum) freq, by(subject)

	egen total=sum(freq)
	gen percent=freq*100/total
	
	drop total 
	
	gsort -freq
	
	export excel using "${data}\interim\tabs_motifs.xlsx", sheet("subject") replace 
restore

*Exporting subject-motif information to be used as a source in classification
preserve
	keep subject action object sentence desc_eng motif_id title_english title_english_googleapi desc_english_googleapi
	sort subject motif_id sentence, stable 
	
	export delimited "${data}/interim\triplets_motifs_Asma.csv", replace 
restore 

preserve
	collapse (sum) freq, by(action)

	egen total=sum(freq)
	gen percent=freq*100/total
	
	drop total 
	
	export excel using "${data}\interim\tabs_motifs.xlsx", sheet("action", replace) 
restore

collapse (sum) freq, by(object)

egen total=sum(freq)
gen percent=freq*100/total

drop total 

export excel using "${data}\interim\tabs_motifs.xlsx", sheet("object", replace) 