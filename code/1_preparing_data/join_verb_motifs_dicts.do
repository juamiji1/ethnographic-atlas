
*Using EPA dataset
import delimited "${data}\raw\verbs_dictionaries\EPA.csv", varnames(1) clear 

ren term action 

tempfile EPA
save `EPA', replace 

*Using SAP_dict
import delimited "${data}\raw\verbs_dictionaries\SAP_dict.csv", varnames(1) clear 

ren term action 

tempfile SAP
save `SAP', replace 

*Using verb_dictionaries
import delimited "${data}\raw\verbs_dictionaries\verb_dictionaries.csv", varnames(1) clear 

ren all_actions action 

duplicates drop 					// 2 exact duplicates 

duplicates tag action, g(dup)		// 4 duplicate words with different connotations 
tab dup
br if dup ==1
sort action 

duplicates drop action, force 

tempfile ACT
save `ACT', replace 

*Grammar from Motifs data 
import delimited "${data}\raw\triplets_and_characterizations_unrolled.csv", varnames(1) clear 

gen freq=1 

collapse (sum) freq, by(action)

preserve

	merge 1:1 action using `EPA', gen(merge_motifs_epa) 

	tab merge_motifs_epa
	tab merge_motifs_epa if merge_motifs_epa==1 | merge_motifs_epa==3

	save "${data}\interim\triplets_and_characterizations_unrolled_EPA,dta", replace 

restore

preserve

	merge 1:1 action using `SAP', gen(merge_motifs_sap) 

	tab merge_motifs_sap
	tab merge_motifs_sap if merge_motifs_sap==1 | merge_motifs_sap==3

	save "${data}\interim\triplets_and_characterizations_unrolled_SAP,dta", replace 

restore

merge 1:1 action using `ACT', gen(merge_motifs_act) 

tab merge_motifs_act
tab merge_motifs_act if merge_motifs_act==1 | merge_motifs_act==3

save "${data}\interim\triplets_and_characterizations_unrolled_ACT,dta", replace 




*END