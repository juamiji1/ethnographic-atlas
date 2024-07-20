
*-------------------------------------------------------------------------------
* Merging ACT/Folkore data with EA
*
*-------------------------------------------------------------------------------
*Data coming from tabs_motifs_xls.do then classified by Asma 
import delimited "${data}/raw\ACT_measures\motif_ACT_scores.csv", varnames(1) clear 

foreach var in nat_mean_p nat_mean_e nat_mean_a nat_sum_p nat_sum_e nat_sum_a nat_n hum_mean_p hum_mean_e hum_mean_a hum_sum_p hum_sum_e hum_sum_a hum_n{
	
	destring `var', replace force
	
}

drop v1 

tempfile ACT
save `ACT', replace 


*-------------------------------------------------------------------------------
* MERGING TRIPLETS WITH MOTIFS-EA-WESEE CONVERSION DATA (Our Extension)
*
*-------------------------------------------------------------------------------
import delimited "${data}/interim\Motifs_EA_WESEE_groups_long.csv", encoding("utf8") clear 	// This data has the BRAZILIAN group already fixed.

merge m:1 motif_id using `ACT', keep(1 3) nogen 
*c41 m11b (not found in the EA MOTIFS)

collapse (mean) nat_mean_p nat_mean_e nat_mean_a nat_sum_p nat_sum_e nat_sum_a nat_n hum_mean_p hum_mean_e hum_mean_a hum_sum_p hum_sum_e hum_sum_a hum_n, by(atlas)

egen m=rowmiss(nat_mean_p nat_mean_e nat_mean_a nat_sum_p nat_sum_e nat_sum_a nat_n hum_mean_p hum_mean_e hum_mean_a hum_sum_p hum_sum_e hum_sum_a hum_n) // 14 ethnicities with all missing 
drop m 

tempfile ACT_Motifs_EA_WESEE
save `ACT_Motifs_EA_WESEE', replace 


*-------------------------------------------------------------------------------
* MERGING TO CONVERSION FROM EA to ETHNOLOGUE (POSTCOLUMBIAN - Nunn & Giulianno, 2017)
*
*-------------------------------------------------------------------------------
use "${data}/raw\ethnologue\ancestral_characteristics_database_language_level\Ancestral_Characteristics_Database_Language_Level\EthnoAtlas_Ethnologue16_extended_EE_Siberia_WES_by_language.dta", clear 

*Fixing strings
gen atlas=subinstr(v107,".","",.)
replace atlas=trim(atlas)

keep id atlas v107
keep if atlas!=""

merge m:1 atlas using `ACT_Motifs_EA_WESEE', keep(1 3) gen(merge_act_mea_wesee)		// 9 EA groups not found in the ethnologue

tab atlas if merge_act_mea_wesee==1
drop merge_act_mea_wesee

*Labels as persona reference 
la var nat_mean_p "Average Potency score of the actions of all nature entities"
la var nat_mean_a "Average Activity score of the actions of all nature entities"
la var nat_mean_e "Average Evaluation score of the actions of all nature entities"
la var nat_sum_p "Total Potency score of the actions of all nature entities"
la var nat_sum_a "Total Activity score of the actions of all nature entities"
la var nat_sum_e "Total Evaluation score of the actions of all nature entities"
la var nat_n "Number of occurrences of nature entities in the subject position within the folktale that were associated with a matchable verb"
la var hum_mean_p "Average Potency score of the actions of all human entities"
la var hum_mean_a "Average Activity score of the actions of all human entities"
la var hum_mean_e "Average Evaluation score of the actions of all human entities"
la var hum_sum_p "Total Potency score of the actions of all human entities"
la var hum_sum_a "Total Activity score of the actions of all human entities"
la var hum_sum_e "Total Evaluation score of the actions of all human entities"
la var hum_n "Number of occurrences of human entities in the subject position within the folktale that were associated with a matchable verb"

export delimited "${data}/interim\Motifs_EA_WESEE_Ethnologue_ACT.csv", replace



*END