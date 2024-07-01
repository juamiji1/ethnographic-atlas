
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
import delimited "${data}/raw\triplets_and_characterizations_unrolled.csv", varnames(1) clear 

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

	collapse (sum) n_triplets_scl=obs_tag human_scl nature_scl, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_scl=(human_scl>0) if human_scl!=.
	gen d_nature_scl=(nature_scl>0) if nature_scl!=.
	gen d_nature_major_scl=(nature_scl>human_scl) if nature_scl!=. & human_scl!=.

	tempfile Triplets_scl
	save `Triplets_scl', replace
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
	egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
	egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)
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

egen stotal=rowtotal(manmade_scl hybrid_scl supernatural_scl nature_scl human_scl)
egen ototal=rowtotal(manmade_ocl hybrid_ocl supernatural_ocl nature_ocl human_ocl)

*keeping only triplets with some sort ofclassification 
keep if (stotal!=0 | ototal!=0) & obs_tag==1

*Looking at triplets where subjec=nature & object=human/manmade. 
gen nature_scl_human_ocl=1 if nature_scl==1 & (human_ocl==1 | manmade_ocl==1)
gen human_scl_nature_ocl=1 if human_scl==1 & nature_ocl==1 

collapse (sum) n_triplets_socl=obs_tag nature_scl_human_ocl human_scl_nature_ocl, by(motif_id)

gen d_nature_scl_human_ocl=(nature_scl_human_ocl>0) if nature_scl_human_ocl!=.
gen d_human_scl_nature_ocl=(human_scl_nature_ocl>0) if human_scl_nature_ocl!=.
gen d_nature_scl_human_ocl_major=(nature_scl_human_ocl>human_scl_nature_ocl) if nature_scl_human_ocl!=. & human_scl_nature_ocl!=.

tempfile Triplets_socl
save `Triplets_socl', replace


*-------------------------------------------------------------------------------
* MERGING TRIPLETS WITH MOTIFS-EA CONVERSION DATA (Michalopolous)
*
*-------------------------------------------------------------------------------
import delimited "${data}/interim\Motifs_EA_groups_long.csv", encoding("utf8") clear 	// This data has the BRAZILIAN group already fixed.

merge m:1 motif_id using `Triplets_scl', keep(1 3) gen(merge_triplet_scl)
merge m:1 motif_id using `Triplets_excl_scl', keep(1 3) gen(merge_triplet_excl_scl)
merge m:1 motif_id using `Triplets_socl', keep(1 3) gen(merge_triplet_socl)
merge m:1 motif_id using `Triplets_excl_socl', keep(1 3) gen(merge_triplet_excl_socl)

unique motif_id if merge_triplet_scl==1	// 80 motifs that do not have a triplet.... 

ren share n_motifs

collapse (sum) n_motifs n_triplets* human* nature* d_human* d_nat* , by(atlas group_berezkin)

*Creating different measures 
gen sh_human_subj_nonexcl=human_scl/n_triplets_scl
gen sh_nature_subj_nonexcl=nature_scl/n_triplets_scl
gen sh_human_smotif_atleast_nonexcl=d_human_scl/n_motifs
gen sh_nature_smotif_atleast_nonexcl=d_nature_scl/n_motifs
gen sh_nature_smotif_major_nonexcl=d_nature_major_scl/n_motifs

gen sh_human_subj_excl=human_excl_scl/n_triplets_excl_scl
gen sh_nature_subj_excl=nature_excl_scl/n_triplets_excl_scl
gen sh_human_smotif_atleast_excl=d_human_excl_scl/n_motifs
gen sh_nature_smotif_atleast_excl=d_nature_excl_scl/n_motifs
gen sh_nature_smotif_major_excl=d_nature_major_excl_scl/n_motifs

*Creating measures regarding subject and object 
gen sh_nature_subj_human_obj=nature_scl_human_ocl/n_triplets_socl
gen sh_human_subj_nature_obj=human_scl_nature_ocl/n_triplets_socl
gen sh_natsubj_humobj_motif_atleast=d_nature_scl_human_ocl/n_motifs
gen sh_humsubj_natobj_motif_atleast=d_human_scl_nature_ocl/n_motifs
gen sh_natsubj_humobj_motif_major=d_nature_scl_human_ocl_major/n_motifs

gen sh_nature_subj_human_obj_excl=nature_scl_human_ocl_excl/n_triplets_excl_socl
gen sh_natsubj_humobj_motif_atl_excl=d_nature_scl_human_ocl_excl/n_motifs
gen sh_natsubj_humobj_motif_maj_excl=d_nat_scl_hum_ocl_excl_major/n_motifs

*Labeling vars 
la var sh_nature_subj_nonexcl "Share of triplets with a nature subject (Non-Exclusive)"
la var sh_nature_subj_excl "Share of triplets with a nature subject (Exclusive)"
la var sh_nature_smotif_atleast_nonexcl "Share of motifs with at least one nature subject in a triplet (Non-Exclusive)"
la var sh_nature_smotif_atleast_excl "Share of motifs with at least one nature subject in a triplet (Exclusive)"
la var sh_nature_smotif_major_nonexcl "Share of motifs in which nature subjects are greater than human (Non-Exclusive)"
la var sh_nature_smotif_major_excl "Share of motifs in which nature subjects are greater than human (Exclusive)"

la var sh_nature_subj_human_obj "Share of triplets with a nature subject and a human object (Non-Exclusive)"
la var sh_human_subj_nature_obj "Share of triplets with a human subject and a nature object (Non-Exclusive)"
la var sh_natsubj_humobj_motif_atleast "Share of motifs with at least one triplet with a nature subject and a human object (Non-Exclusive)"
la var sh_humsubj_natobj_motif_atleast "Share of motifs with at least one triplet with a human subject and a nature object (Non-Exclusive)"
la var sh_natsubj_humobj_motif_major "Share of motifs in which nature subject and human object are greater than the opposite (Non-Exclusive)"

la var sh_nature_subj_human_obj_excl "Share of triplets with a nature subject and a human object (Exclusive)"
la var sh_natsubj_humobj_motif_atl_excl "Share of motifs with at least one triplet with a nature subject and a human object (Exclusive)"
la var sh_natsubj_humobj_motif_maj_excl "Share of motifs in which nature subject and human object are greater than the opposite (Exclusive)"

tempfile Motifs_EA
save `Motifs_EA', replace 


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
* FIXING CONVERSION FROM EA to ETHNOLOGUE (Nunn & Giulianno, 2017)
*
*-------------------------------------------------------------------------------
use "${data}/raw\ethnologue\ancestral_characteristics_database_language_level\Ancestral_Characteristics_Database_Language_Level\EthnoAtlas_Ethnologue16_baseline_by_language.dta", clear 

*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep id atlas v107
keep if atlas!=""

merge m:1 atlas using `Motifs_EA', keep(1 3) gen(merge_mea)		// 9 EA groups not found in the ethnologue

tab atlas if merge_mea==1
drop merge_mea


export delimited "${data}/interim\Motifs_EA_Ethnologue_humanvsnature_subjs_objs.csv", replace




*END

