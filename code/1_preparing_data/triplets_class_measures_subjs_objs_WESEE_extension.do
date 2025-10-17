
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
*ACT scores from Talha 
import delimited "${data}/raw\ACT_measures\motif_epa_merge.csv", varnames(1) clear

ren term action

tempfile EPAV2
save `EPAV2', replace

*Triplets from Oscar 
import delimited "${data}/raw\ACT_measures\triplets_and_characterizations_unrolled_scores_merged.csv", varnames(1) clear
*import delimited "${data}/raw\triplets_and_characterizations_unrolled.csv", varnames(1) clear 

*Fixing strigns to lower to match the classification
gen original_subject=subject
replace subject=strtrim(lower(subject))
replace action=strtrim(lower(action))
replace object=strtrim(lower(object))

replace action=subinstr(action,"-"," ",.)

*Merging EPA interpolation measures (Talha's)
merge m:1 action motif_id using `EPAV2', keep(1 3) keepus(e_v2 p_v2 a_v2)

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
rename (e p a e_v2 p_v2 a_v2) (evaluation potency activity evaluation_v2 potency_v2 activity_v2)
destring evaluation potency activity, replace force

*-------------------------------------------------------------------------------
* Calculating total type of triplet per motif (only for SUBJECTS)
*-------------------------------------------------------------------------------
*Keeping only triplets classified at either human or nature (making exclusive categories so the indexes are complements)
preserve
	keep if (human_scl==1 | nature_scl==1) & obs_tag==1
	
	*Checking they add up to one
	gen x=human_scl+nature_scl
	tab x 
	
	collapse (sum) n_triplets_excl_scl=obs_tag human_excl_scl=human_scl nature_excl_scl=nature_scl, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_excl_scl=(human_excl_scl>0) if human_excl_scl!=.
	gen d_nature_excl_scl=(nature_excl_scl>0) if nature_excl_scl!=.
	gen d_nature_major_excl_scl=(nature_excl_scl > human_excl_scl) if nature_excl_scl!=. & human_excl_scl!=.

	tempfile Triplets_excl_scl
	save `Triplets_excl_scl', replace
restore 

*Keeping all triplets (indexes will not add up to one)
preserve 
	keep if (human_scl==1 | nature_scl==1 | supernatural_scl==1 | hybrid_scl==1 | manmade_scl==1) & obs_tag==1 
	
	gen supernatural_hybrid_scl=1 if supernatural_scl==1 | hybrid_scl==1
		
	collapse (sum) n_triplets_scl=obs_tag human_scl nature_scl supernatural_hybrid_scl, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_scl=(human_scl>0) if human_scl!=.
	gen d_nature_scl=(nature_scl>0) if nature_scl!=.
	gen d_nature_major_scl=(nature_scl>human_scl) if nature_scl!=. & human_scl!=.
	gen d_supernatural_hybrid_scl=(supernatural_hybrid_scl>0) if supernatural_hybrid_scl!=.
	
	tempfile Triplets_scl
	save `Triplets_scl', replace
restore 

*-------------------------------------------------------------------------------
* Calculating total type of triplet per motif (only for OBJECTS)
*-------------------------------------------------------------------------------
*Keeping only triplets classified at either human or nature (making exclusive categories so the indexes are complements)
preserve
	keep if (human_ocl==1 | nature_ocl==1) & obs_tag==1
	
	*Checking they add up to one
	gen x=human_ocl+nature_ocl
	tab x 
	
	collapse (sum) n_triplets_excl_ocl=obs_tag human_excl_ocl=human_ocl nature_excl_ocl=nature_ocl, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_excl_ocl=(human_excl_ocl>0) if human_excl_ocl!=.
	gen d_nature_excl_ocl=(nature_excl_ocl>0) if nature_excl_ocl!=.
	gen d_nature_major_excl_ocl=(nature_excl_ocl > human_excl_ocl) if nature_excl_ocl!=. & human_excl_ocl!=.

	tempfile Triplets_excl_ocl
	save `Triplets_excl_ocl', replace
restore 

*Keeping all triplets (indexes will not add up to one)
preserve 
	keep if (human_ocl==1 | nature_ocl==1 | supernatural_ocl==1 | hybrid_ocl==1 | manmade_ocl==1) & obs_tag==1 
	
	gen supernatural_hybrid_ocl=1 if supernatural_ocl==1 | hybrid_ocl==1
	
	collapse (sum) n_triplets_ocl=obs_tag human_ocl nature_ocl supernatural_hybrid_ocl, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_ocl=(human_ocl>0) if human_ocl!=.
	gen d_nature_ocl=(nature_ocl>0) if nature_ocl!=.
	gen d_nature_major_ocl=(nature_ocl>human_ocl) if nature_ocl!=. & human_ocl!=.
	gen d_supernatural_hybrid_ocl=(supernatural_hybrid_ocl>0) if supernatural_hybrid_ocl!=.
	
	tempfile Triplets_ocl
	save `Triplets_ocl', replace
restore 

*-------------------------------------------------------------------------------
* Calculating total type of triplet per motif (for SUBJECTS and OBJECTS)
*-------------------------------------------------------------------------------
preserve
	*keeping only triplets with some sort ofclassification 
	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)
	
	la var stotal "Total Categories (SUBJECT)"
	la var ototal "Total Categories (OBJECT)"
	
	tab stotal, m
	tab ototal, m
	
	keep if (stotal!=0 & ototal!=0) & obs_tag==1

	*Looking at triplets where subjec=nature & object=human/manmade. 
	gen nature_scl_human_ocl=1 if nature_scl==1 & (human_ocl==1 | manmade_ocl==1)
	gen human_scl_nature_ocl=1 if human_scl==1 & nature_ocl==1 
	gen nature_scl_nature_ocl=1 if nature_scl==1 & nature_ocl==1 
	gen human_scl_human_ocl=1 if human_scl==1 & (human_ocl==1 | manmade_ocl==1) 	//WE CAN GET MORE INFO FROM SUPERNATURAL!
	
	gen classOfTriplet=1 if nature_scl_human_ocl==1
	replace classOfTriplet=2 if human_scl_nature_ocl==1 
	replace classOfTriplet=3 if nature_scl_nature_ocl==1 
	replace classOfTriplet=4 if human_scl_human_ocl==1 
	
	lab def kindoftriplet 1 "Subj=Nature & Obj=Human" 2 "Subj=Human & Obj=Nature" 3 "Subj=Nature & Obj=Nature" 4 "Subj=Human & Obj=Human"
	lab val classOfTriplet kindoftriplet
	
	tab classOfTriplet, m
restore 

preserve 	
	*keeping only triplets with some sort ofclassification 
	egen stotal=rowtotal(manmade_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl nature_ocl human_ocl)
	keep if (stotal!=0 | ototal!=0) & obs_tag==1

	*Looking at triplets where subjec=nature & object=human/manmade. 
	gen nature_scl_human_ocl=1 if nature_scl==1 & (human_ocl==1 | manmade_ocl==1)
	gen human_scl_nature_ocl=1 if human_scl==1 & nature_ocl==1 
	gen nature_scl_nature_ocl=1 if nature_scl==1 & nature_ocl==1 
	gen human_scl_human_ocl=1 if human_scl==1 & (human_ocl==1 | manmade_ocl==1) 	//WE CAN GET MORE INFO FROM SUPERNATURAL!
	
	*keeping only triplets with to be exclusive within these categories
	keep if (nature_scl_human_ocl==1 | human_scl_nature_ocl==1) & obs_tag==1
	
	collapse (sum) n_triplets_excl_socl=obs_tag nature_scl_human_ocl_excl=nature_scl_human_ocl human_scl_nature_ocl_excl=human_scl_nature_ocl, by(motif_id)

	gen d_nature_scl_human_ocl_excl=(nature_scl_human_ocl_excl>0) if nature_scl_human_ocl_excl!=.
	gen d_human_scl_nature_ocl_excl=(human_scl_nature_ocl_excl>0) if human_scl_nature_ocl_excl!=.
	gen d_nat_scl_hum_ocl_excl_major=(nature_scl_human_ocl_excl>human_scl_nature_ocl_excl) if nature_scl_human_ocl_excl!=. & human_scl_nature_ocl_excl!=.

	tempfile Triplets_excl_socl		
	save `Triplets_excl_socl', replace
restore 

preserve 
	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)

	*keeping only triplets with some sort ofclassification 
	keep if (stotal!=0 | ototal!=0) & obs_tag==1

	*Looking at triplets where subjec=nature & object=human/manmade. 
	gen nature_scl_human_ocl=1 if nature_scl==1 & (human_ocl==1 | manmade_ocl==1)
	gen human_scl_nature_ocl=1 if human_scl==1 & nature_ocl==1 
	gen nature_scl_or_ocl=1 if nature_scl==1 | nature_ocl==1 
	gen nature_scl_major_ocl=1 if (nature_scl > nature_ocl) & nature_scl!=. & nature_ocl!=.

	collapse (sum) n_triplets_socl=obs_tag nature_scl_human_ocl human_scl_nature_ocl nature_scl_or_ocl nature_scl_major_ocl, by(motif_id)

	gen d_nature_scl_human_ocl=(nature_scl_human_ocl>0) if nature_scl_human_ocl!=.
	gen d_human_scl_nature_ocl=(human_scl_nature_ocl>0) if human_scl_nature_ocl!=.
	gen d_nature_scl_human_ocl_major=(nature_scl_human_ocl>human_scl_nature_ocl) if nature_scl_human_ocl!=. & human_scl_nature_ocl!=.
	
	gen d_nature_scl_or_ocl=(nature_scl_or_ocl>0) if nature_scl_or_ocl!=.	
	gen d_nature_scl_major_ocl=(nature_scl_major_ocl>0) if nature_scl_major_ocl!=.
	
	tempfile Triplets_socl
	save `Triplets_socl', replace
restore

*-------------------------------------------------------------------------------
* Calculating total type of triplet per motif (Special cases)
*-------------------------------------------------------------------------------
preserve
	*Keeping triplets with any kind of nature mentioning or nature-human interaction
	gen nature_acl= 1 if nature_scl==1 | nature_ocl==1 
	gen nature_scl_human_ocl=1 if nature_scl==1 & (human_ocl==1 | manmade_ocl==1)
	gen human_scl_nature_ocl=1 if human_scl==1 & nature_ocl==1 
	gen nature_human_acl=1 if human_scl_nature_ocl==1 | nature_scl_human_ocl==1

	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)

	*keeping only triplets with some sort ofclassification 
	keep if (stotal!=0 | ototal!=0) & obs_tag==1

	collapse (sum) n_triplets_acl=obs_tag nature_acl nature_human_acl, by(motif_id)

	gen d_nature_acl=(nature_acl>0) if nature_acl!=.
	gen d_nature_human_acl=(nature_human_acl>0) if nature_human_acl!=.

	tempfile Triplets_acl
	save `Triplets_acl', replace
restore

*-------------------------------------------------------------------------------
* Calculating ACT measures per motif (for SUBJECTS and OBJECTS)
*-------------------------------------------------------------------------------
preserve

	*Where (1) subject is nature (2) potency is positive or negative
	gen nature_ppos=1 if nature_scl==1 & potency>=0 & potency!=.
	gen nature_pneg=1 if nature_scl==1 & potency<0

	*Where (1) subject is nature (2) activity is positive or negative
	gen nature_apos=1 if nature_scl==1 & activity>=0 & activity!=.
	gen nature_aneg=1 if nature_scl==1 & activity<0

	*Where (1) subject is nature (2) activity is positive or negative
	gen nature_epos=1 if nature_scl==1 & evaluation>=0 & evaluation!=.
	gen nature_eneg=1 if nature_scl==1 & evaluation<0

	*Where (1) subject is human (2) nature is object, (3) potency is positive or negative
	gen human_scl_nature_ocl_ppos=1 if human_scl==1 & nature_ocl==1 & potency>=0 & potency!=.
	gen human_scl_nature_ocl_pneg=1 if human_scl==1 & nature_ocl==1 & potency<0

	*keeping only triplets with some sort ofclassification 
	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)
	keep if (stotal!=0 | ototal!=0) & obs_tag==1

	collapse (sum) n_triplets_act=obs_tag nature_ppos nature_pneg nature_apos nature_aneg nature_epos nature_eneg human_scl_nature_ocl_ppos human_scl_nature_ocl_pneg, by(motif_id)

	gen d_nature_ppos=(nature_ppos>0) if nature_ppos!=.
	gen d_nature_pneg=(nature_pneg>0) if nature_pneg!=.
	gen d_nature_apos=(nature_apos>0) if nature_apos!=.
	gen d_nature_aneg=(nature_aneg>0) if nature_aneg!=.
	gen d_nature_epos=(nature_epos>0) if nature_epos!=.
	gen d_nature_eneg=(nature_eneg>0) if nature_eneg!=.

	gen d_nature_human_ppos=(human_scl_nature_ocl_ppos>0) if human_scl_nature_ocl_ppos!=.
	gen d_nature_human_pneg=(human_scl_nature_ocl_pneg>0) if human_scl_nature_ocl_pneg!=.

	tempfile Triplets_act
	save `Triplets_act', replace

restore

preserve
	
	summ potency, d 
	gen pospotency=1 if potency>=`r(p50)' & potency!=.
	replace pospotency=0 if potency<`r(p50)'
	
	summ activity, d 
	gen posactivity=1 if activity>=`r(p50)' & activity!=.
	replace posactivity=0 if activity<`r(p50)'
	
	summ evaluation, d 
	gen posevaluation=1 if evaluation>=`r(p50)' & evaluation!=.
	replace posevaluation=0 if evaluation<`r(p50)'
	
	*Where (1) subject is nature (2) potency is positive or negative
	gen nature_ppos_v3=1 if nature_scl==1 & pospotency==1
	gen nature_pneg_v3=1 if nature_scl==1 & pospotency==0

	*Where (1) subject is nature (2) activity is positive or negative
	gen nature_apos_v3=1 if nature_scl==1 & posactivity==1
	gen nature_aneg_v3=1 if nature_scl==1 & posactivity==0

	*Where (1) subject is nature (2) activity is positive or negative
	gen nature_epos_v3=1 if nature_scl==1 & posevaluation==1
	gen nature_eneg_v3=1 if nature_scl==1 & posevaluation==0

	*Where (1) subject is human (2) nature is object, (3) potency is positive or negative
	gen human_scl_nature_ocl_ppos_v3=1 if human_scl==1 & nature_ocl==1 & pospotency==1
	gen human_scl_nature_ocl_pneg_v3=1 if human_scl==1 & nature_ocl==1 & pospotency==0

	*keeping only triplets with some sort ofclassification 
	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)
	keep if (stotal!=0 | ototal!=0) & obs_tag==1

	collapse (sum) n_triplets_act=obs_tag nature_ppos nature_pneg nature_apos nature_aneg nature_epos nature_eneg human_scl_nature_ocl_ppos human_scl_nature_ocl_pneg, by(motif_id)

	gen d_nature_ppos_v3=(nature_ppos_v3>0) if nature_ppos_v3!=.
	gen d_nature_pneg_v3=(nature_pneg_v3>0) if nature_pneg_v3!=.
	gen d_nature_apos_v3=(nature_apos_v3>0) if nature_apos_v3!=.
	gen d_nature_aneg_v3=(nature_aneg_v3>0) if nature_aneg_v3!=.
	gen d_nature_epos_v3=(nature_epos_v3>0) if nature_epos_v3!=.
	gen d_nature_eneg_v3=(nature_eneg_v3>0) if nature_eneg_v3!=.

	gen d_nature_human_ppos_v3=(human_scl_nature_ocl_ppos_v3>0) if human_scl_nature_ocl_ppos_v3!=.
	gen d_nature_human_pneg_v3=(human_scl_nature_ocl_pneg_v3>0) if human_scl_nature_ocl_pneg_v3!=.

	tempfile Triplets_act_v3
	save `Triplets_act_v3', replace

restore

*-------------------------------------------------------------------------------
* Calculating ACT measures per motif (for SUBJECTS and OBJECTS) - VERSION 3 
*-------------------------------------------------------------------------------
*Where (1) subject is nature (2) potency is positive or negative
gen nature_ppos_v2=1 if nature_scl==1 & potency_v2>=0 & potency_v2!=.
gen nature_pneg_v2=1 if nature_scl==1 & potency_v2<0

*Where (1) subject is nature (2) activity is positive or negative
gen nature_apos_v2=1 if nature_scl==1 & activity_v2>=0 & activity_v2!=.
gen nature_aneg_v2=1 if nature_scl==1 & activity_v2<0

*Where (1) subject is nature (2) activity is positive or negative
gen nature_epos_v2=1 if nature_scl==1 & evaluation_v2>=0 & evaluation_v2!=.
gen nature_eneg_v2=1 if nature_scl==1 & evaluation_v2<0

*Where (1) subject is human (2) nature is object, (3) potency is positive or negative
gen human_scl_nature_ocl_ppos_v2=1 if human_scl==1 & nature_ocl==1 & potency_v2>=0 & potency_v2!=.
gen human_scl_nature_ocl_pneg_v2=1 if human_scl==1 & nature_ocl==1 & potency_v2<0

*keeping only triplets with some sort ofclassification 
egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)
keep if (stotal!=0 | ototal!=0) & obs_tag==1

collapse (sum) n_triplets_act=obs_tag nature_ppos* nature_pneg* nature_apos* nature_aneg* nature_epos* nature_eneg* human_scl_nature_ocl_ppos* human_scl_nature_ocl_pneg*, by(motif_id)

gen d_nature_ppos_v2=(nature_ppos_v2>0) if nature_ppos_v2!=.
gen d_nature_pneg_v2=(nature_pneg_v2>0) if nature_pneg_v2!=.
gen d_nature_apos_v2=(nature_apos_v2>0) if nature_apos_v2!=.
gen d_nature_aneg_v2=(nature_aneg_v2>0) if nature_aneg_v2!=.
gen d_nature_epos_v2=(nature_epos_v2>0) if nature_epos_v2!=.
gen d_nature_eneg_v2=(nature_eneg_v2>0) if nature_eneg_v2!=.

gen d_nature_human_ppos_v2=(human_scl_nature_ocl_ppos_v2>0) if human_scl_nature_ocl_ppos_v2!=.
gen d_nature_human_pneg_v2=(human_scl_nature_ocl_pneg_v2>0) if human_scl_nature_ocl_pneg_v2!=.

tempfile Triplets_act_v2
save `Triplets_act_v2', replace


*-------------------------------------------------------------------------------
* MERGING TRIPLETS WITH MOTIFS-EA-WESEE CONVERSION DATA (Our Extension)
*
*-------------------------------------------------------------------------------
import delimited "${data}/interim\Motifs_EA_WESEE_groups_long.csv", encoding("utf8") clear 	// This data has the BRAZILIAN group already fixed.

merge m:1 motif_id using `Triplets_scl', keep(1 3) gen(merge_triplet_ocl)
merge m:1 motif_id using `Triplets_excl_scl', keep(1 3) gen(merge_triplet_excl_ocl)
merge m:1 motif_id using `Triplets_ocl', keep(1 3) gen(merge_triplet_scl)
merge m:1 motif_id using `Triplets_excl_ocl', keep(1 3) gen(merge_triplet_excl_scl)
merge m:1 motif_id using `Triplets_socl', keep(1 3) gen(merge_triplet_socl)
merge m:1 motif_id using `Triplets_excl_socl', keep(1 3) gen(merge_triplet_excl_socl)
merge m:1 motif_id using `Triplets_acl', keep(1 3) gen(merge_triplet_acl)
merge m:1 motif_id using `Triplets_act', keep(1 3) gen(merge_triplet_act)
merge m:1 motif_id using `Triplets_act_v2', keep(1 3) gen(merge_triplet_act_v2)
merge m:1 motif_id using `Triplets_act_v3', keep(1 3) gen(merge_triplet_act_v3)

unique motif_id if merge_triplet_scl==1	// 80 motifs that do not have a triplet.... 

ren share n_motifs

collapse (sum) n_motifs n_triplets* human* nature* d_human* d_nat* d_super* super*, by(atlas group_berezkin)

*Creating different measures regarding subject
gen sh_human_subj_nonexcl=human_scl/n_triplets_scl
gen sh_nature_subj_nonexcl=nature_scl/n_triplets_scl
gen sh_human_smotif_atleast_nonexcl=d_human_scl/n_motifs
gen sh_nature_smotif_atleast_nonexcl=d_nature_scl/n_motifs
gen sh_nature_smotif_major_nonexcl=d_nature_major_scl/n_motifs

gen sh_supernat_subj_nonexcl= supernatural_hybrid_scl/n_triplets_scl
gen sh_supernat_smotif_atl_nonexcl=d_supernatural_hybrid_scl/n_motifs

gen sh_human_subj_excl=human_excl_scl/n_triplets_excl_scl
gen sh_nature_subj_excl=nature_excl_scl/n_triplets_excl_scl
gen sh_human_smotif_atleast_excl=d_human_excl_scl/n_motifs
gen sh_nature_smotif_atleast_excl=d_nature_excl_scl/n_motifs
gen sh_nature_smotif_major_excl=d_nature_major_excl_scl/n_motifs

*Creating different measures regarding object
gen sh_human_obj_nonexcl=human_ocl/n_triplets_ocl
gen sh_nature_obj_nonexcl=nature_ocl/n_triplets_ocl
gen sh_human_omotif_atleast_nonexcl=d_human_ocl/n_motifs
gen sh_nature_omotif_atleast_nonexcl=d_nature_ocl/n_motifs
gen sh_nature_omotif_major_nonexcl=d_nature_major_ocl/n_motifs

gen sh_supernat_obj_nonexcl= supernatural_hybrid_ocl/n_triplets_ocl
gen sh_supernat_omotif_atl_nonexcl=d_supernatural_hybrid_ocl/n_motifs

gen sh_human_obj_excl=human_excl_ocl/n_triplets_excl_ocl
gen sh_nature_obj_excl=nature_excl_ocl/n_triplets_excl_ocl
gen sh_human_omotif_atleast_excl=d_human_excl_ocl/n_motifs
gen sh_nature_omotif_atleast_excl=d_nature_excl_ocl/n_motifs
gen sh_nature_omotif_major_excl=d_nature_major_excl_ocl/n_motifs

*Creating measures regarding subject and object 
gen sh_nature_subj_human_obj=nature_scl_human_ocl/n_triplets_socl
gen sh_human_subj_nature_obj=human_scl_nature_ocl/n_triplets_socl
gen sh_natsubj_humobj_motif_atleast=d_nature_scl_human_ocl/n_motifs
gen sh_humsubj_natobj_motif_atleast=d_human_scl_nature_ocl/n_motifs
gen sh_natsubj_humobj_motif_major=d_nature_scl_human_ocl_major/n_motifs

gen sh_nature_any_motif_atl=d_nature_scl_or_ocl/n_motifs
gen sh_nature_scl_maj_ocl_motif_atl=d_nature_scl_major_ocl/n_motifs

gen sh_nature_subj_human_obj_excl=nature_scl_human_ocl_excl/n_triplets_excl_socl
gen sh_natsubj_humobj_motif_atl_excl=d_nature_scl_human_ocl_excl/n_motifs
gen sh_natsubj_humobj_motif_maj_excl=d_nat_scl_hum_ocl_excl_major/n_motifs

*Creating special measures (asked by Nathan)
gen sh_nature_acl=nature_acl/n_triplets_acl
gen sh_nature_human_acl=nature_human_acl/n_triplets_acl

gen sh_nature_acl_motif_atleast=d_nature_acl/n_motifs 	// same as sh_nature_any_motif_atl
gen sh_nature_human_acl_motif_atl=d_nature_human_acl/n_motifs

*Creating special act measures
gen sh_nature_ppos_act=nature_ppos/n_triplets_act
gen sh_nature_pneg_act=nature_pneg/n_triplets_act
gen sh_nature_apos_act=nature_apos/n_triplets_act
gen sh_nature_aneg_act=nature_aneg/n_triplets_act
gen sh_nature_epos_act=nature_epos/n_triplets_act
gen sh_nature_eneg_act=nature_eneg/n_triplets_act

gen sh_hum_nat_ppos_act=human_scl_nature_ocl_ppos/n_triplets_act
gen sh_hum_nat_pneg_act=human_scl_nature_ocl_pneg/n_triplets_act

gen sh_nature_ppos_act_atl=d_nature_ppos/n_motifs
gen sh_nature_pneg_act_atl=d_nature_pneg/n_motifs
gen sh_nature_apos_act_atl=d_nature_apos/n_motifs
gen sh_nature_aneg_act_atl=d_nature_aneg/n_motifs
gen sh_nature_epos_act_atl=d_nature_epos/n_motifs
gen sh_nature_eneg_act_atl=d_nature_eneg/n_motifs

gen sh_hum_nat_ppos_act_atl=d_nature_human_ppos/n_motifs
gen sh_hum_nat_pneg_act_atl=d_nature_human_pneg/n_motifs

*Creating V2 of ACT measures 
gen sh_nature_ppos_act_atl_v2=d_nature_ppos_v2/n_motifs
gen sh_nature_pneg_act_atl_v2=d_nature_pneg_v2/n_motifs
gen sh_nature_apos_act_atl_v2=d_nature_apos_v2/n_motifs
gen sh_nature_aneg_act_atl_v2=d_nature_aneg_v2/n_motifs
gen sh_nature_epos_act_atl_v2=d_nature_epos_v2/n_motifs
gen sh_nature_eneg_act_atl_v2=d_nature_eneg_v2/n_motifs

gen sh_hum_nat_ppos_act_atl_v2=d_nature_human_ppos_v2/n_motifs
gen sh_hum_nat_pneg_act_atl_v2=d_nature_human_pneg_v2/n_motifs

*Creating V3 of ACT measures 
gen sh_nature_ppos_act_atl_v3=d_nature_ppos_v3/n_motifs
gen sh_nature_pneg_act_atl_v3=d_nature_pneg_v3/n_motifs
gen sh_nature_apos_act_atl_v3=d_nature_apos_v3/n_motifs
gen sh_nature_aneg_act_atl_v3=d_nature_aneg_v3/n_motifs
gen sh_nature_epos_act_atl_v3=d_nature_epos_v3/n_motifs
gen sh_nature_eneg_act_atl_v3=d_nature_eneg_v3/n_motifs

gen sh_hum_nat_ppos_act_atl_v3=d_nature_human_ppos_v3/n_motifs
gen sh_hum_nat_pneg_act_atl_v3=d_nature_human_pneg_v3/n_motifs

*Labeling vars 
la var sh_nature_subj_nonexcl "Share of triplets with a nature subject (Non-Exclusive)"
la var sh_nature_subj_excl "Share of triplets with a nature subject (Exclusive)"
la var sh_nature_smotif_atleast_nonexcl "Share of motifs with at least one nature subject in a triplet (Non-Exclusive)"
la var sh_nature_smotif_atleast_excl "Share of motifs with at least one nature subject in a triplet (Exclusive)"
la var sh_nature_smotif_major_nonexcl "Share of motifs in which nature subjects are greater than human (Non-Exclusive)"
la var sh_nature_smotif_major_excl "Share of motifs in which triplets with nature subjects are greater than human (Exclusive)"

la var sh_supernat_subj_nonexcl "Sh of triplets w a supernatural or hybrid subject (Non-Exclusive)"
la var sh_supernat_smotif_atl_nonexcl "Sh of motifs w at least one supernatural or hybrid subject (Non-Exclusive)"

la var sh_nature_obj_nonexcl "Share of triplets with a nature object (Non-Exclusive)"
la var sh_nature_obj_excl "Share of triplets with a nature object (Exclusive)"
la var sh_nature_omotif_atleast_nonexcl "Share of motifs with at least one nature object in a triplet (Non-Exclusive)"
la var sh_nature_omotif_atleast_excl "Share of motifs with at least one nature object in a triplet (Exclusive)"
la var sh_nature_omotif_major_nonexcl "Share of motifs in which triplets with nature objects are greater than human (Non-Exclusive)"
la var sh_nature_omotif_major_excl "Share of motifs in which triplets with nature objects are greater than human (Exclusive)"

la var sh_supernat_obj_nonexcl "Sh of triplets w a supernatural or hybrid object (Non-Exclusive)"
la var sh_supernat_omotif_atl_nonexcl "Sh of motifs w at least one supernatural or hybrid object (Non-Exclusive)"

la var sh_nature_subj_human_obj "Share of triplets with a nature subject and a human object (Non-Exclusive)"
la var sh_human_subj_nature_obj "Share of triplets with a human subject and a nature object (Non-Exclusive)"
la var sh_natsubj_humobj_motif_atleast "Share of motifs with at least one triplet with a nature subject and a human object"
la var sh_humsubj_natobj_motif_atleast "Share of motifs with at least one triplet with a human subject and a nature object"
la var sh_natsubj_humobj_motif_major "Share of motifs in which triplets with nature subject and human object are greater than the opposite"

la var sh_nature_any_motif_atl "Sh of motifs w at least a nature subject or object in a triplet"
la var sh_nature_scl_maj_ocl_motif_atl "Sh of motifs w nature subject greater than nature object"

la var sh_nature_subj_human_obj_excl "Share of triplets with a nature subject and a human object (Exclusive)"
la var sh_natsubj_humobj_motif_atl_excl "Share of motifs with at least one triplet with a nature subject and a human object"
la var sh_natsubj_humobj_motif_maj_excl "Share of motifs in which triplets with nature subject and human object are greater than the opposite"

la var sh_nature_acl "Share of triplets with a nature subject or object"
la var sh_nature_human_acl "Share of triplets with any nature-human interaction"
la var sh_nature_acl_motif_atleast "Share of motifs with at least one triplet with a nature subject or object"
la var sh_nature_human_acl_motif_atl "Share of motifs with at least one triplet with any nature-human interaction"

la var sh_nature_subj_nonexcl "Sh of triplets w a nature subject (non-excl)"
la var sh_human_subj_nonexcl "Sh of triplets w a human subject (non-excl)"
la var sh_nature_subj_excl "Sh of triplets w a nature subject (excl)"
la var sh_human_subj_excl "Sh of triplets w a human subject (excl)"
la var sh_nature_smotif_atleast_nonexcl "Sh of motifs w at least one nature subject in a triplet (non-excl)"
la var sh_human_smotif_atleast_nonexcl "Sh of motifs w at least one human subject in a triplet (non-excl)"
la var sh_nature_smotif_atleast_excl "Sh of motifs w at least one nature subject in a triplet (excl)"
la var sh_human_smotif_atleast_excl "Sh of motifs w at least one human subject in a triplet (excl)"
la var sh_nature_smotif_major_nonexcl "Sh of motifs in which nature subjects are greater than human (non-excl)"
la var sh_nature_smotif_major_excl "Sh of motifs in which triplets w nature subjects are greater than human (excl)"
la var sh_nature_obj_nonexcl "Sh of triplets w a nature object (non-excl)"
la var sh_human_obj_nonexcl "Sh of triplets w a human object (non-excl)"
la var sh_nature_obj_excl "Sh of triplets w a nature object (excl)"
la var sh_human_obj_excl "Sh of triplets w a human object (excl)"
la var sh_nature_omotif_atleast_nonexcl "Sh of motifs w at least one nature object in a triplet (non-excl)"
la var sh_human_omotif_atleast_nonexcl "Sh of motifs w at least one human object in a triplet (non-excl)"
la var sh_nature_omotif_atleast_excl "Sh of motifs w at least one nature object in a triplet (excl)"
la var sh_human_omotif_atleast_excl "Sh of motifs w at least one human object in a triplet (excl)"
la var sh_nature_omotif_major_nonexcl "Sh of motifs in which triplets w nature objects are greater than human (non-excl)"
la var sh_nature_omotif_major_excl "Sh of motifs in which triplets w nature objects are greater than human (excl)"
la var sh_nature_subj_human_obj "Sh of triplets w a nature subject and a human object (non-excl)"
la var sh_human_subj_nature_obj "Sh of triplets w a human subject and a nature object (non-excl)"
la var sh_natsubj_humobj_motif_atleast "Sh of motifs w at least one triplet w a nature subject and a human object"
la var sh_humsubj_natobj_motif_atleast "Sh of motifs w at least one triplet w a human subject and a nature object"
la var sh_natsubj_humobj_motif_major "Sh of motifs in which triplets w nature subject and human object are greater than the opposite"
la var sh_nature_subj_human_obj_excl "Sh of triplets w a nature subject and a human object (excl)"
la var sh_natsubj_humobj_motif_atl_excl "Sh of motifs w at least one triplet w a nature subject and a human object"
la var sh_natsubj_humobj_motif_maj_excl "Sh of motifs in which triplets w nature subject and human object are greater than the opposite"
la var sh_nature_acl "Sh of triplets w a nature subject or object"
la var sh_nature_human_acl "Sh of triplets w any nature-human interaction"
la var sh_nature_acl_motif_atleast "Sh of motifs w at least one triplet w a nature subject or object"
la var sh_nature_human_acl_motif_atl "Sh of motifs w at least one triplet w any nature-human interaction"

la var sh_nature_ppos_act "Sh of triplets w a nature subject and potency positive"
la var sh_nature_pneg_act "Sh of triplets w a nature subject and potency negative"
la var sh_nature_apos_act "Sh of triplets w a nature subject and activity positive"
la var sh_nature_aneg_act "Sh of triplets w a nature subject and activity negative"
la var sh_nature_epos_act "Sh of triplets w a nature subject and evaluation positive"
la var sh_nature_eneg_act "Sh of triplets w a nature subject and evaluation negative"

la var sh_hum_nat_ppos_act "Sh of triplets w a human subject, nature object, and potency positive"
la var sh_hum_nat_pneg_act "Sh of triplets w a human subject, nature object, and potency negative"

la var sh_nature_ppos_act_atl "Sh of motifs w at least one triplet w nature subject and positive potency"
la var sh_nature_pneg_act_atl "Sh of motifs w at least one triplet w nature subject and negative potency"
la var sh_nature_apos_act_atl "Sh of motifs w at least one triplet w nature subject and positive activity"
la var sh_nature_aneg_act_atl "Sh of motifs w at least one triplet w nature subject and negative activity"
la var sh_nature_epos_act_atl "Sh of motifs w at least one triplet w nature subject and positive evaluation"
la var sh_nature_eneg_act_atl "Sh of motifs w at least one triplet w nature subject and negative evaluation"

la var sh_hum_nat_ppos_act_atl "Sh of motifs w one triplet w human subj, nature obj, and positive potency"
la var sh_hum_nat_pneg_act_atl "Sh of motifs w one triplet w human subj, nature obj, and negative potency"

la var sh_nature_ppos_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and positive potency (V2)"
la var sh_nature_pneg_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and negative potency (V2)"
la var sh_nature_apos_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and positive activity (V2)"
la var sh_nature_aneg_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and negative activity (V2)"
la var sh_nature_epos_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and positive evaluation (V2)"
la var sh_nature_eneg_act_atl_v2 "Sh of motifs w at least one triplet w nature subject and negative evaluation (V2)"

la var sh_hum_nat_ppos_act_atl_v2 "Sh of motifs w one triplet w human subj, nature obj, and positive potency (V2)"
la var sh_hum_nat_pneg_act_atl_v2 "Sh of motifs w one triplet w human subj, nature obj, and negative potency (V2)"

la var sh_nature_ppos_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and positive potency (V3)"
la var sh_nature_pneg_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and negative potency (V3)"
la var sh_nature_apos_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and positive activity (V3)"
la var sh_nature_aneg_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and negative activity (V3)"
la var sh_nature_epos_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and positive evaluation (V3)"
la var sh_nature_eneg_act_atl_v3 "Sh of motifs w at least one triplet w nature subject and negative evaluation (V3)"

la var sh_hum_nat_ppos_act_atl_v3 "Sh of motifs w one triplet w human subj, nature obj, and positive potency (V3)"
la var sh_hum_nat_pneg_act_atl_v3 "Sh of motifs w one triplet w human subj, nature obj, and negative potency (V3)"

*la var sh_hum_nat_ppos_act_atl "Sh of motifs w at least one triplet w human subject, nature object, and positive potency"
*la var sh_hum_nat_pneg_act_atl "Sh of motifs w at least one triplet w human subject, nature object, and negative potency"

tempfile Motifs_EA_WESEE
save `Motifs_EA_WESEE', replace 


/*-------------------------------------------------------------------------------
* Making correlation plots for Nathan between measures at the EA lvl
*
*-------------------------------------------------------------------------------
local i=1
foreach var1 in sh_nature_subj_nonexcl sh_nature_subj_excl sh_nature_smotifs_atleast_nonexcl sh_nature_smotifs_atleast_excl sh_nature_smotifs_major_nonexcl sh_nature_smotifs_major_excl{
	
	foreach var2 in sh_nature_subj_nonexcl sh_nature_subj_excl sh_nature_smotifs_atleast_nonexcl sh_nature_smotifs_atleast_excl sh_nature_smotifs_major_nonexcl sh_nature_smotifs_major_excl{
	
		reg `var1' `var2'
		mat b= e(b)
		local coef=round(b[1,1],0.001)

		local lbl1 : var label `var1'
		local lbl2 : var label `var2'
		
		twoway (scatter `var1' `var2') (lfit `var1' `var2'), legend(off) ytitle("`lbl1'", size(vsmall)) xtitle("`lbl2'", size(medsmall))  note("Slope-Coeff: `coef'")
		gr export "${plots}/shwrds_nature_vars_corr`i'.pdf", as(pdf) replace 
		
		local ++i
		
	}
	
}

gr close 
*/


*-------------------------------------------------------------------------------
* FIXING EA MISSING VALUES OF SOME GROUPS (PRECOLUMBIAN)
*
*-------------------------------------------------------------------------------
use "${data}/raw\ethnographic_atlas\ethnographic_atlas_fixed.dta", clear

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

drop if v100==.

export delimited using "${data}/raw\ethnographic_atlas\ethnographic_atlas_vfinal.csv", replace

*Appending the rest
append using "${data}/raw\ethnographic_atlas\Easternmost_Europe_final.dta" "raw\ethnographic_atlas\Siberia_final.dta" 

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."

export delimited using "${data}/raw\ethnographic_atlas\ethnographic_atlas_east_siberia_vfinal.csv", replace

append using "${data}/raw\ethnographic_atlas\WES_final.dta"

drop if v102<1001

replace v91=strtrim(v91)
replace v92=strtrim(v92)
label drop _all

drop if v107=="ARGENTINIANS"
drop if v107=="JAMAICANS"
drop if v107=="HAITIANS."
drop if v107=="TRISTAN ."
drop if v107=="FRENCHCAN"

*Fixing some categories for maps
replace v54=. if v54>6

gen d_v66=1 if v66>1 & v66!=.
replace d_v66=0 if v66==1

tempfile EA_VFINAL
save `EA_VFINAL', replace

export delimited using "${data}/raw\ethnographic_atlas\ethnographic_atlas_east_siberia_wes_vfinal.csv", replace

*-------------------------------------------------------------------------------
* Characteristics of most representative group in ethnic cluster
*-------------------------------------------------------------------------------
forval c=1/8{
	
	preserve
		import delimited using "${data}/interim\ethnographic_atlas_east_siberia_wes_vfinal_ethnclusters.csv", clear
		
		replace v114_order=v114_corrected if v114_corrected!=.
		
		keep if v114_order==`c'
		merge 1:1 v107 using `EA_VFINAL', keep(1 3) nogen

		ren (v1-v113) =_clust`c'

		tempfile EA_CLUST`c'
		save `EA_CLUST`c'', replace 
	restore 
	
}

*-------------------------------------------------------------------------------
* Imputing missings using the most representative 
*-------------------------------------------------------------------------------
forval c=1/8{
	merge m:1 v114 using `EA_CLUST`c'', keep(1 3) nogen 
}

foreach var of varlist v1-v90 v95 v96 {
	
	forval c=1/8{
		replace `var'=`var'_clust`c' if `var'==0 | `var'==.
	}
	
}

drop *_clust*

export delimited using "${data}/raw\ethnographic_atlas\ethnographic_atlas_east_siberia_wes_vfinal_input_ethnclusters.csv", replace

*-------------------------------------------------------------------------------
* Merging the Folklore measures to the EA WESEE 
*-------------------------------------------------------------------------------
*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep atlas v107 v114 v91 v92 v93
keep if atlas!=""

*Merging the data together
merge 1:1 atlas using `Motifs_EA_WESEE', keep(1 3) nogen 

*Fixing the missing values
foreach var in sh_nature_smotif_atleast_excl sh_human_smotif_atleast_excl{
	
	bys v114: egen x = mean(`var')
	replace `var'= x if `var'==.
	drop x
	
}

export delimited "${data}/interim\Motifs_EA_WESEE_humanvsnature_all.csv", replace

preserve
	keep atlas group_berezkin v91 v92 v93
	order atlas group_berezkin v91 v92 v93
	keep if v91=="E" & (v92=="a" | v92=="e" | v92=="f" | v92=="g" | v92=="h" | v92=="i" )
	
	export delimited "${data}/interim\Motifs_EA_WESEE_Bereskin_SA.csv", replace	
restore 


*-------------------------------------------------------------------------------
* FIXING CONVERSION FROM EA to ETHNOLOGUE (POSTCOLUMBIAN - Nunn & Giulianno, 2017)
*
*-------------------------------------------------------------------------------
import delimited "${data}/interim\folklore_ea_nature.csv", clear

*Fixing strings
replace atlas=subinstr(atlas,".","",.)
replace atlas=trim(atlas)

keep atlas ancestor_sh

tempfile ANCES
save `ANCES', replace

use "${data}/raw\ethnologue\EthnoAtlas_Ethnologue16_extended_EE_Siberia_WES_by_language.dta", clear 

*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep if atlas!=""

foreach var in v112-v90 v94-v97 {
	cap nois la val `var'
}

forval c=1/8{
	merge m:1 v114 using `EA_CLUST`c'', keep(1 3) nogen 
}

foreach var of varlist v6-v90 v95 v96 v102 {
	
	forval c=1/8{
		replace `var'=`var'_clust`c' if `var'==0 | `var'==.
	}
	
}

keep id atlas v107 v30 v31 v32 v33 v34 v66 v54 v114 nam_label c1 v1 v2 v3 v4 v5 v102 v95 v96

*Fixing the v32 variable
recode v32 (2=1) (3=2) (4=3)

*Fixing the values for Portuguese and Afrikaans
foreach var in v30 v31 v32 v33 v34 v54 v66 {
	
	gen x=`var' if id=="POR-BRA"
	bys v114: egen mean_x=mean(x)

	replace `var'=mean_x if id=="POR-PRT"
	
	drop x mean_x
	
}

foreach var in v30 v31 v32 v33 v34 v54 v66 {
	
	gen x=`var' if atlas=="DUTCH"
	egen mean_x=mean(x)

	replace `var'=mean_x if nam_label=="Afrikaans"
	
	drop x mean_x
	
}

*Fixing the missing values
recode v30 v31 v95 v96 (0=.)

replace v95=v96 if v95==.
	
foreach var in v30 v31 v95 {
	
	bys v114: egen x = mode(`var'), max
	replace `var'= x if `var'==.
	*replace `var'=ceil(`var')
	drop x
}

/*egen x = mean(v95) // IMPROVE THIS VARIABLE!!! (ASK NATHAN)
replace x = ceil(x)
replace v95= x if v95==.
drop x
*/
	
merge m:1 atlas using `Motifs_EA_WESEE', keep(1 2 3) gen(merge_mea_wesee)		// 9 EA groups not found in the ethnologue
merge m:1 atlas using `ANCES', keep(1 3) nogen

tab atlas if merge_mea==1
drop merge_mea

*Fixing some categories for maps
replace v54=. if v54>6

gen d_v66=1 if v66>1 & v66!=.
replace d_v66=0 if v66==1


save "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.dta", replace
export delimited "${data}/interim\Motifs_EA_WESEE_Ethnologue_humanvsnature_all.csv", replace


*END