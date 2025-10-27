gl data "C:\Users\juami\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Analysis\1_data\clean_data"
gl plots "C:\Users\juami\Dropbox\RAships\2-Folklore-Nathan-Project\EA-Maps-Nathan-project\Measures_work\plots"

use "$data/ivs_clean_prepped.dta", clear 

*Bars
cap drop d_x_r
summ sh_nature_smotif_atleast_nonexcl, d
gen d_x_r=1 if sh_nature_smotif_atleast_nonexcl>=`r(p50)' & sh_nature_smotif_atleast_nonexcl!=.
replace d_x_r=0 if sh_nature_smotif_atleast_nonexcl<`r(p50)' 

eststo s1: reghdfe index1_all if d_x_r==1, noabs 
eststo s0: reghdfe index1_all if d_x_r==0, noabs 

coefplot (s0, color("gs9")) (s1, color("gs5")), ///
    vert recast(bar) barwidth(0.3) noci ///
    mlabel(string(@b, "%9.2fc")) mlabposition(12) mlabgap(*2) ///
    mlabcolor(black) mlabsize(medium) coeflabels(_cons=" ") ///
    l2title("Pro-Environment Support Index", size(medium)) ///
	b2title("Share of motifs with a triplet containing a nature subject", size(medium)) ///
    legend(off) ///
    xlabel(.85 "Below median" 1.15 "Above median", labsize(medsmall)) ///
    ylabel(.35(.01).39) 

gr export "${plots}/bars_sh_nature_subject.pdf", as(pdf) replace

*Binscatter 
reg index1_all sh_nature_acl_motif_atleast
matrix B = e(b)
global b = string(round(B[1,1], .001), "%9.3f")
	
binscatter index1_all sh_nature_acl_motif_atleast, nq(100) mcolor("gs9") lcolor("black") ///
xtitle("") b2title("Share of motifs with a triplet containing a nature subject or object", size(medium)) ///
ytitle("") l2title("Pro-Environment Support Index", size(medium))  ///
text(.33 .77 "{&beta} = ${b}", size(medsmall))

gr export "${plots}/binscatter_sh_nature_any.pdf", as(pdf) replace

reg index1_all sh_nature_smotif_atleast_nonexcl
matrix B = e(b)
global b = string(round(B[1,1], .001), "%9.3f")
	
binscatter index1_all sh_nature_smotif_atleast_nonexcl, nq(100) mcolor("gs9") lcolor("black") ///
xtitle("") b2title("Share of motifs with a triplet containing a nature subject", size(medium)) ///
ytitle("") l2title("Pro-Environment Support Index", size(medium))  ///
text(.35 .65 "{&beta} = ${b}", size(medsmall))

gr export "${plots}/binscatter_sh_nature_subject.pdf", as(pdf) replace

reg index1_all sh_nature_omotif_atleast_nonexcl
matrix B = e(b)
global b = string(round(B[1,1], .001), "%9.3f")

binscatter index1_all sh_nature_omotif_atleast_nonexcl if sh_nature_omotif_atleast_nonexcl<.6, nq(100) mcolor("gs9") lcolor("black") ///
xtitle("") b2title("Share of motifs with a triplet containing a nature object", size(medium)) ///
ytitle("") l2title("Pro-Environment Support Index", size(medium))  ///
text(.3 .43 "{&beta} = ${b}", size(medsmall))

gr export "${plots}/binscatter_sh_nature_object.pdf", as(pdf) replace




*END