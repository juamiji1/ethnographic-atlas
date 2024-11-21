
*-------------------------------------------------------------------------------
* FIXING CLASSIFICATIONS OF OBJECTS AND SUBJECTS
*
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Fixing subject classification with Triplets 
*-------------------------------------------------------------------------------
*Data coming from tabs_motifs_xls.do then classified by Asma 
import excel "${data}/interim\subjects_triplets_classification_Asma.xlsx", sheet("subject") firstrow clear

ren _all, low
replace subject=strtrim(lower(subject))
ren i n_cat 
tab n_cat

preserve
	keep if n_cat==0 
	export delimited "${data}/interim\subjects_triplets_unclass_Asma.csv", replace
restore  

foreach var in human nature supernatural hybrid manmade{
	replace `var'=0 if `var'==.	
}

drop frequency n_cat notes
rename (human nature supernatural hybrid manmade) (human_scl nature_scl supernatural_scl hybrid_scl manmade_scl)

tempfile Sclass
save `Sclass', replace 

*-------------------------------------------------------------------------------
* Fixing object classification with Triplets 
*-------------------------------------------------------------------------------
*Data coming from tabs_motifs_xls.do then classified by Asma 
import excel "${data}/interim\objects_triplets_classification_Asma.xlsx", sheet("object") firstrow clear

ren _all, low
replace object=strtrim(lower(object))

foreach var in human nature supernatural hybrid manmade{
	replace `var'=0 if `var'==.	
}

rename (human nature supernatural hybrid manmade) (human_ocl nature_ocl supernatural_ocl hybrid_ocl manmade_ocl)
drop frequency percent notes

tempfile Oclass
save `Oclass', replace 


*-------------------------------------------------------------------------------
* MERGING CLASSIFICATIONS WITH TRIPLETS 
*
*-------------------------------------------------------------------------------
*Triplets from Oscar 
import delimited "${data}/raw\ACT_measures\triplets_and_characterizations_unrolled_scores_merged.csv", varnames(1) clear
*import delimited "${data}/raw\triplets_and_characterizations_unrolled.csv", varnames(1) clear 

*Fixing strigns to lower to match the classification
gen original_subject=subject
replace subject=strtrim(lower(subject))
replace action=strtrim(lower(action))
replace object=strtrim(lower(object))

*Checking duplicates that comes from same sentence-motif
duplicates tag subject action object characterization sentence motif_id , g(dup)  //should I drop duplicates or each triplet means something different? different sentences?
tab dup

*Tagging the observations that I am using when there is duplicates (egen tag does not work with empty strings)
sort subject action object characterization sentence motif_id, stable 
by subject action object characterization sentence motif_id : gen obs_tag=_n
replace obs_tag=0 if obs_tag>1

preserve
	ren subject lowercap_subject
	order original_subject	lowercap_subject	action	object	characterization	motif_id sentence	desc_eng	

	sort lowercap_subject sentence motif_id
	keep if dup>0
	
	export delimited "${data}/interim\triplets_type1_duplicates.csv", replace
restore

drop dup

*Merging the classifications 
merge m:1 subject using `Sclass', gen(merge_sclass)
merge m:1 object using `Oclass', gen(merge_oclass)

*Fixing ATC measures
rename (e p a) (evaluation potency activity)
destring evaluation potency activity, replace force

*Keeping cvs for word cloud
preserve
	keep if human_scl==1
	keep subject
	export delimited using "${data}/interim\triplets_human_subject.csv", replace
restore

preserve
	keep if human_ocl==1 | manmade_ocl==1
	keep object
	export delimited using "${data}/interim\triplets_human_object.csv", replace
restore

preserve
	keep if nature_scl==1 
	keep subject
	export delimited using "${data}/interim\triplets_nature_subject.csv", replace
restore

preserve
	keep if nature_ocl==1
	keep object
	export delimited using "${data}/interim\triplets_nature_object.csv", replace
restore

preserve
	keep if evaluation<0
	keep action
	export delimited using "${data}/interim\triplets_action_evaluation_neg.csv", replace
restore

preserve
	keep if evaluation>=0
	keep action
	export delimited using "${data}/interim\triplets_action_evaluation_pos.csv", replace
restore

preserve
	keep if potency<0
	keep action
	export delimited using "${data}/interim\triplets_action_potency_neg.csv", replace
restore

preserve
	keep if potency>=0
	keep action
	export delimited using "${data}/interim\triplets_action_potency_pos.csv", replace
restore

preserve
	keep if activity<0
	keep action
	export delimited using "${data}/interim\triplets_action_activity_neg.csv", replace
restore

preserve
	keep if activity>=0
	keep action
	export delimited using "${data}/interim\triplets_action_activity_pos.csv", replace
restore

preserve
	keep if supernatural_scl==1 | hybrid_scl==1 
	keep subject
	export delimited using "${data}/interim\triplets_supernatural_subject.csv", replace
restore

preserve
	keep if supernatural_ocl==1 | hybrid_ocl==1
	keep object
	export delimited using "${data}/interim\triplets_supernatural_object.csv", replace
restore

preserve
	keep subject
	export delimited using "${data}/interim\triplets_all_subject.csv", replace
restore

preserve
	keep object
	export delimited using "${data}/interim\triplets_all_object.csv", replace
restore

preserve
	keep action
	export delimited using "${data}/interim\triplets_all_action.csv", replace
restore




*END

