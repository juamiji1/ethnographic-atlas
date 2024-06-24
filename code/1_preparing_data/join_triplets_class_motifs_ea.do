
*-------------------------------------------------------------------------------
* Merging classification with Triplets 
*-------------------------------------------------------------------------------

*Data coming from tabs_motifs_xls.do then classified by JM (TOP 50)
import delimited "${data}/interim\tabs_motifs_subjects_classified_JM.csv", encoding("utf8") clear

replace subject=strtrim(lower(subject))

tempfile Class1
save `Class1', replace 

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
rename (human nature supernatural hybrid manmade) (human_cl2 nature_cl2 supernatural_cl2 hybrid_cl2 manmade_cl2)

tempfile Class2
save `Class2', replace 

*-------------------------------------------------------------------------------
* Merging classification with Triplets 
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
merge m:1 subject using `Class1', gen(merge_class1)
merge m:1 subject using `Class2', gen(merge_class2)

*Correlation between classifications 
reg nature nature_cl2, nocons 
tab nature nature_cl2
pwcorr nature nature_cl2

*Keeping only triplets classified at either human or nature (making exclusive categories so the indexes are complements)
preserve
	keep if (human==1 | nature==1) & obs_tag==1
	
	*Checking they add up to one
	gen x=human+nature
	tab x 
	
	collapse (sum) n_triplets_v2=obs_tag human_v2=human nature_v2=nature, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_v2=(human_v2>0) if human_v2!=.
	gen d_nature_v2=(nature_v2>0) if nature_v2!=.
	gen d_nature_major_v2=(nature_v2>human_v2) if nature_v2!=. & human_v2!=.

	tempfile Triplets_v2
	save `Triplets_v2', replace
restore 

preserve
	keep if (human_cl2==1 | nature_cl2==1) & obs_tag==1
	
	*Checking they add up to one
	gen x=human_cl2+nature_cl2
	tab x 
	
	collapse (sum) n_triplets_v2_cl2=obs_tag human_v2_cl2=human nature_v2_cl2=nature, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_v2_cl2=(human_v2_cl2>0) if human_v2_cl2!=.
	gen d_nature_v2_cl2=(nature_v2_cl2>0) if nature_v2_cl2!=.
	gen d_nature_major_v2_cl2=(nature_v2_cl2>human_v2_cl2) if nature_v2_cl2!=. & human_v2_cl2!=.

	tempfile Triplets_v2_cl2
	save `Triplets_v2_cl2', replace
restore 


*Keeping all triplets (indexes will not add up to one)
preserve
	keep if obs_tag==1

	collapse (sum) n_triplets_cl2=obs_tag human_cl2 nature_cl2, by(motif_id)	// Number of words per motif related to human vs nature 

	gen d_human_cl2=(human_cl2>0) if human_cl2!=.
	gen d_nature_cl2=(nature_cl2>0) if nature_cl2!=.
	gen d_nature_major_cl2=(nature_cl2>human_cl2) if nature_cl2!=. & human_cl2!=.

	tempfile Triplets_cl2
	save `Triplets_cl2', replace
restore 

keep if obs_tag==1

collapse (sum) n_triplets=obs_tag human nature, by(motif_id)	// Number of words per motif related to human vs nature 

gen d_human=(human>0) if human!=.
gen d_nature=(nature>0) if nature!=.
gen d_nature_major=(nature>human) if nature!=. & human!=.

tempfile Triplets
save `Triplets', replace


*-------------------------------------------------------------------------------
* Merging Triplets with Motifs-EA conversion data (Michalopoilus)
*-------------------------------------------------------------------------------
import delimited "${data}/interim\Motifs_EA_groups_long.csv", encoding("utf8") clear 	// This data has the BRAZILIAN group already fixed.

merge m:1 motif_id using `Triplets', keep(1 3) gen(merge_triplet)
merge m:1 motif_id using `Triplets_v2', keep(1 3) gen(merge_triplet_v2)
merge m:1 motif_id using `Triplets_cl2', keep(1 3) gen(merge_triplet_cl2)
merge m:1 motif_id using `Triplets_v2_cl2', keep(1 3) gen(merge_triplet_v2_cl2)

unique motif_id if merge_triplet==1	// 80 motifs that do not have a triplet.... 

ren share n_motifs

collapse (sum) n_motifs n_triplets* human* nature* d_human* d_nature*, by(atlas group_berezkin)

*Creating different measures 
gen ratio_human_nature=human/nature
gen shwrds_human=human/n_triplets
gen shwrds_nature=nature/n_triplets
gen shmotifs_human=d_human/n_motifs
gen shmotifs_nature=d_nature/n_motifs
gen ratiod_human_nature=d_human/d_nature

gen ratio_human_nature_v2=human_v2/nature_v2
gen shwrds_human_v2=human_v2/n_triplets_v2
gen shwrds_nature_v2=nature_v2/n_triplets_v2
gen shmotifs_human_v2=d_human_v2/n_motifs
gen shmotifs_nature_v2=d_nature_v2/n_motifs
gen ratiod_human_nature_v2=d_human_v2/d_nature_v2

gen shwrds_human_cl2=human_cl2/n_triplets_cl2
gen shwrds_nature_cl2=nature_cl2/n_triplets_cl2
gen shmotifs_human_cl2=d_human_cl2/n_motifs
gen shmotifs_nature_cl2=d_nature_cl2/n_motifs
*gen shmotifs_human_major_cl2=d_human_major_cl2/n_motifs
gen shmotifs_nature_major_cl2=d_nature_major_cl2/n_motifs

gen shwrds_human_v2_cl2=human_v2_cl2/n_triplets_v2_cl2
gen shwrds_nature_v2_cl2=nature_v2_cl2/n_triplets_v2_cl2
gen shmotifs_human_v2_cl2=d_human_v2_cl2/n_motifs
gen shmotifs_nature_v2_cl2=d_nature_v2_cl2/n_motifs
*gen shmotifs_human_major_v2_cl2=d_human_major_v2_cl2/n_motifs
gen shmotifs_nature_major_v2_cl2=d_nature_major_v2_cl2/n_motifs

*Renaming to follow Nathan's criteria
ren (shwrds_nature_cl2 shwrds_nature_v2_cl2 shmotifs_nature_cl2 shmotifs_nature_v2_cl2 shmotifs_nature_major_cl2 shmotifs_nature_major_v2_cl2) (sh_nature_subjects_nonexcl sh_nature_subjects_excl sh_nature_motifs_atleast_nonexcl sh_nature_motifs_atleast_excl sh_nature_motifs_major_nonexcl sh_nature_motifs_major_excl)

*Labeling vars 
la var sh_nature_subjects_nonexcl "Share of triplets with a nature subject (Non-Exclusive)"
la var sh_nature_subjects_excl "Share of triplets with a nature subject (Exclusive)"
la var sh_nature_motifs_atleast_nonexcl "Share of motifs with at least one nature subject in a triplet (Non-Exclusive)"
la var sh_nature_motifs_atleast_excl "Share of motifs with at least one nature subject in a triplet (Exclusive)"
la var sh_nature_motifs_major_nonexcl "Share of motifs in which nature subjects are greater than human (Non-Exclusive)"
la var sh_nature_motifs_major_excl "Share of motifs in which nature subjects are greater than human (Exclusive)"

tempfile Motifs_EA
save `Motifs_EA', replace 


*-------------------------------------------------------------------------------
* Making correlation plots for Nathan between measures at the EA lvl
*-------------------------------------------------------------------------------
local i=1
foreach var1 in sh_nature_subjects_nonexcl sh_nature_subjects_excl sh_nature_motifs_atleast_nonexcl sh_nature_motifs_atleast_excl sh_nature_motifs_major_nonexcl sh_nature_motifs_major_excl{
	
	foreach var2 in sh_nature_subjects_nonexcl sh_nature_subjects_excl sh_nature_motifs_atleast_nonexcl sh_nature_motifs_atleast_excl sh_nature_motifs_major_nonexcl sh_nature_motifs_major_excl{
	
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


*-------------------------------------------------------------------------------
* Fixing conversion from EA to Ethnologue (Nunn & Giulianno, 2017)
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


export delimited "${data}/interim\Motifs_EA_Ethnologue_humanvsnature.csv", replace




*END




