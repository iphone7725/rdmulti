/*******************************************************************************
RDMULTI: analysis of Regression Discontinuity Designs 
		 with multiple cutoffs or scores
* Illustration file
* Date: 16-Jul-2018
Authors: Matias Cattaneo, Rocío Titiunik, Gonzalo Vazquez-Bare
*******************************************************************************/
** hlp2winpdf, cdn(rdmc) replace
** hlp2winpdf, cdn(rdmcplot) replace
** hlp2winpdf, cdn(rdms) replace
*******************************************************************************/
** net install rdmulti, from(https://sites.google.com/site/rdpackages/rdmulti/stata) replace
********************************************************************************

clear all
set more off
set linesize 90

********************************************************************************
** MULTIPLE NON-CUMULATIVE CUTOFFS: Setup and summary stats
********************************************************************************

sjlog using output/rdmc_out0, replace
use simdata_multic, clear
sum 
tab c
sjlog close, replace


********************************************************************************
** RDMC
********************************************************************************

* Basic syntax

sjlog using output/rdmc_out1, replace
rdmc y x, c(c)
sjlog close, replace

* rdrobust pooled options 

sjlog using output/rdmc_out2, replace
rdmc y x, c(c) pooled_opt(h(20) p(2)) verbose
sjlog close, replace

* Cutoff-specific bandwidths

sjlog using output/rdmc_out3, replace
gen double h = 11 in 1
replace h = 10 in 2
rdmc y x, c(c) h(h)
sjlog close, replace

* Add plot

sjlog using output/rdmc_out4, replace
rdmc y x, c(c) plot
sjlog close, replace
graph export output/rdmc_coefs.pdf, name(coefs) replace
graph export output/rdmc_weights.pdf, name(weights) replace

* Post estimation testing

sjlog using output/rdmc_out5, replace
rdmc y x, c(c)
matlist e(b)
lincom c1-c2
sjlog close, replace


********************************************************************************
** RDMCPLOT
********************************************************************************

* Basic syntax

sjlog using output/rdmc_out6, replace
rdmcplot y x, c(c)
sjlog close, replace
graph export output/rdmc_multi.pdf, replace

* Omit scatter plot

sjlog using output/rdmc_out7, replace
rdmcplot y x, c(c) noscatter
sjlog close, replace
graph export output/rdmc_multi2.pdf, replace

* Plot TE

sjlog using output/rdmc_out8, replace
gen p = 1 in 1/2
rdmcplot y x, c(c) h(h) p(p)
sjlog close, replace
graph export output/rdmc_multi3.pdf, replace


********************************************************************************
** MULTIPLE CUMULATIVE CUTOFFS: Setup and summary stats
********************************************************************************

sjlog using output/cumul_out0, replace
use simdata_cumul, clear
sum 
tab c
sjlog close, replace


********************************************************************************
** RDMS
********************************************************************************

* Basic syntax

sjlog using output/cumul_out1, replace
rdms y x, c(c)
sjlog close, replace

* Cutoff-specific bandwidths

sjlog using output/cumul_out2, replace
gen double h = 11 in 1
replace h = 8 in 2
rdms y x, c(c) h(h)
sjlog close, replace

* Restricting the range

sjlog using output/cumul_out3, replace
gen double range_l = 33 in 1
replace range_l = 32.5 in 2
gen double range_r = 32.5 in 1
replace range_r = 100 in 2
rdms y x, c(c) range(range_l range_r)
sjlog close, replace

* Pooled estimate using rdmc

sjlog using output/cumul_out4, replace
gen double cutoff = c[1]*(x<=49.5) + c[2]*(x>49.5)
rdmc y x, c(cutoff)
sjlog close, replace

* Plot using rdmcplot

sjlog using output/cumul_out5, replace
rdmcplot y x, c(cutoff)
sjlog close, replace
graph export output/rdmc_cumul.pdf, replace


********************************************************************************
** BIVARIATE SCORE: Setup and summary stats
********************************************************************************

sjlog using output/multis_out0, replace
use simdata_multis, clear
sum 
list c1 c2 in 1/3
sjlog close, replace

sjlog using output/multis_out1, replace
gen xaux = 50 in 1/50
gen yaux = _n in 1/50
twoway (scatter x2 x1 if t==0, msize(small) mfcolor(white) msymbol(X)) ///
	   (scatter x2 x1 if t==1, msize(small) mfcolor(white) msymbol(T)) ///
	   (function y = 50, range(0 50) lcolor(black) lwidth(medthick)) ///
	   (line yaux xaux, lcolor(black) lwidth(medthick)) ///
	   (scatteri 50 25, msize(large) mcolor(black)) ///
   	   (scatteri 50 50, msize(large) mcolor(black)) ///
   	   (scatteri 25 50, msize(large) mcolor(black)), ///
	   text(25 25 "Treated", size(vlarge)) ///
	   text(60 60 "Control", size(vlarge)) ///
	   legend(off)
sjlog close, replace
graph export output/rdmc_multis.pdf, replace


********************************************************************************
** RDMS
********************************************************************************

* Basic syntax 

sjlog using output/multis_out2, replace
rdms y x1 x2 t, c(c1 c2)
sjlog close, replace

* Cutoff specific bandwidths

sjlog using output/multis_out3, replace
gen double h = 15 in 1
replace h = 13 in 2
replace h = 17 in 3
rdms y x1 x2 t, c(c1 c2) h(h)
sjlog close, replace

* Pooled effect

sjlog using output/multis_out4, replace
gen double aux1 = abs(.5 - x1)
gen double aux2 = abs(.5 - x2)
egen xnorm = rowmin(aux1 aux2)
replace xnorm = xnorm*(2*t-1)
rdms y x1 x2 t, c(c1 c2) xnorm(xnorm)
sjlog close, replace

