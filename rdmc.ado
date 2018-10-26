/*******************************************************************************
RDMC: analysis of Regression Discontinuity Designs with multiple cutoffs
*!version 0.2 16-Jul-2018
Authors: Matias Cattaneo, Rocío Titiunik, Gonzalo Vazquez-Bare
*******************************************************************************/

capture program drop rdmc
program define rdmc, eclass sortpreserve

	syntax varlist (min=2 max=2) [if] [in], Cvar(string) [pooled_opt(string) Hvar(string) Bvar(string) Pvar(string) KERNELvar(string) fuzzy(string) plot graph_opt(string) verbose]

	
********************************************************************************
** Setup and error checking
********************************************************************************
	
	marksample touse, novarlist
	
	tokenize `varlist'
	local yvar `1' 
	local xvar `2' 
	
	capture confirm numeric variable `cvar'
	if _rc!=0 {
		di as error "cutoff variable has to be numeric"
		exit 108
	}
	
	qui sum `xvar' if `touse'
	local xmax = r(max)
	local xmin = r(min)
	qui sum `cvar' if `touse'
	local cmax = r(max)
	local cmin = r(min)
	
	if `cmax'>=`xmax' | `cmin'<=`xmin' {
		di as error "cutoff variable outside range of running variable"
		exit 125
	}
	
	tempvar rv_norm
	qui gen double `rv_norm' = `xvar' - `cvar'
	
	qui levelsof `cvar' if `touse', local(cutoff_list)
	local n_cutoffs: word count `cutoff_list'
	
	if "`hvar'"!=""{
		capture confirm numeric variable `hvar'
		if _rc!=0 {
			di as error "h variable has to be numeric"
			exit 108
		}		
		qui count if `hvar'!=.
		local n_hvar = r(N)
		if `n_hvar' != `n_cutoffs' {
			di as error "lengths of cvar and hvar have to coincide"
			exit 125
		}
	}
	
	if "`bvar'"!=""{
		capture confirm numeric variable `bvar'
		if _rc!=0 {
			di as error "b variable has to be numeric"
			exit 108
		}
		qui count if `bvar'!=.
		local n_bvar = r(N)
		if `n_bvar' != `n_cutoffs' {
			di as error "lengths of cvar and bvar have to coincide"
			exit 125
		}
	}
	
	if "`pvar'"!=""{
		capture confirm numeric variable `pvar'
		if _rc!=0 {
			di as error "p variable has to be numeric"
			exit 108
		}
		qui count if `pvar'!=.
		local n_pvar = r(N)
		if `n_pvar' != `n_cutoffs' {
			di as error "lengths of cvar and pvar have to coincide"
			exit 125
		}
	}
	
	if "`kernelvar'"!=""{
		capture confirm string variable `kernelvar'
		if _rc!=0 {
			di as error "kernel variable has to be string"
			exit 108
		}
		qui count if `kernelvar'!=""
		local n_pvar = r(N)
		if `n_pvar' != `n_cutoffs' {
			di as error "lengths of kernelvar and pvar have to coincide"
			exit 125
		}
	}
	
	if "`fuzzy'"!=""{
		local fuzzy_opt "fuzzy(`fuzzy')"
	}
	
	tempname b V
	mat `b' = J(1,`n_cutoffs'+1,.)
	mat `V' = J(`n_cutoffs'+1,`n_cutoffs'+1,0)
	mat sampsis = J(1,`n_cutoffs',.)
	mat weights = J(1,`n_cutoffs',.)
	mat coefs = J(1,`n_cutoffs'+1,.)
	mat CI_rb = J(2,`n_cutoffs'+1,.)
	mat H = J(1,`n_cutoffs'+1,.)


********************************************************************************	
*** Calculate pooled estimate
********************************************************************************
	
	if "`verbose'"!=""{
		rdrobust `yvar' `rv_norm' if `touse', `pooled_opt' `fuzzy_opt'
	} 
	else {
		qui rdrobust `yvar' `rv_norm' if `touse', `pooled_opt' `fuzzy_opt'
	}
	
	local tau_pooled = e(tau_cl)
	local se_rb_pooled = e(se_tau_rb)
	local pv_rb_pooled = e(pv_rb)
	local ci_l_pooled = e(ci_l_rb)
	local ci_r_pooled = e(ci_r_rb)
	local h_l_pooled = e(h_l)
	local h_r_pooled = e(h_r)
	local N_l_pooled = e(N_l)
	local N_r_pooled = e(N_r)
	local N_eff_l_pooled = e(N_h_l)
	local N_eff_r_pooled = e(N_h_r)
	
	mat `b'[1,`n_cutoffs'+1] = e(tau_bc)
	mat `V'[`n_cutoffs'+1,`n_cutoffs'+1] = e(se_tau_rb)^2
	mat coefs[1,`n_cutoffs'+1] = e(tau_cl)
	mat CI_rb[1,`n_cutoffs'+1] = e(ci_l_rb)
	mat CI_rb[2,`n_cutoffs'+1] = e(ci_r_rb)
	mat H[1,`n_cutoffs'+1] = e(h_l)

	
********************************************************************************	
** Calculate cutoff-specific estimates and weights
********************************************************************************
	
	local count = 1
	foreach cutoff of local cutoff_list{

		* Compute weights
		
		qui count if `cvar'==`cutoff' & `rv_norm'>=-`h_l_pooled' & `rv_norm'<=`h_r_pooled' & `touse'
		
		local N_`count' = r(N)
		local weight_`count' = r(N)/(`N_eff_l_pooled'+`N_eff_r_pooled')
		
		mat sampsis[1,`count'] = `N_`count''
		mat weights[1,`count'] = `weight_`count''
		
		* Compute estimates
		
		if "`hvar'"!=""{
			local h = `hvar'[`count']
			local h_opt "h(`h')"
		}
		
		if "`bvar'"!=""{
			local b = `bvar'[`count']
			local b_opt "b(`b')"
		}
		
		if "`pvar'"!=""{
			local p = `pvar'[`count']
			local p_opt "p(`p')"
		}
		
		if "`kernelvar'"!=""{
			local kernel = `kernelvar'[`count']
			local k_opt "kernel(`kernel')"
		}
		
		capture rdrobust `yvar' `rv_norm' if `cvar'==`cutoff' & `touse', `h_opt' `b_opt' `p_opt' `k_opt' `fuzzy_opt'
		
		if _rc!=0{
			di as error "rdrobust could not run in cutoff `cutoff'. Please check this cutoff manually." 
			exit 2001
		}
		
		local h_`count' = e(h_l)
		local n_h_`count' = e(N_h_l) + e(N_h_r)
		local tau_`count' = e(tau_cl)
		local se_rb_`count' = e(se_tau_rb)
		local pv_rb_`count' = e(pv_rb)
		local ci_l_`count' = e(ci_l_rb)
		local ci_r_`count' = e(ci_r_rb)
		
		local colname "`colname' c`count'"
		
		mat `b'[1,`count'] = e(tau_bc)
		mat `V'[`count',`count'] = e(se_tau_rb)^2
		mat coefs[1,`count'] = e(tau_cl)
		mat CI_rb[1,`count'] = e(ci_l_rb)
		mat CI_rb[2,`count'] = e(ci_r_rb)
		mat H[1,`count'] = e(h_l)
		
		local ++count
	}
	
********************************************************************************
** Display results
********************************************************************************

	di _newline
	di as text "Cutoff-specific RD estimation with robust bias-corrected inference"
	local count = 1
	di as text "{hline 12}{c TT}{hline 67}"
	di as text "{ralign 12:Cutoff}" as text _col(10) "{c |}"	_col(18) "Coef." 					_col(28) "P>|z|"  				_col(38)  "[95% Conf. Int.]"	_col(60) "h"		_col(70) "Nh"				_col(75) "Weight"
	di as text "{hline 12}{c +}{hline 67}"

	foreach c of local cutoff_list{

		di as res "{ralign 12:`c'}"  		as text _col(10) "{c |}"	as res	_col(13) %9.3f `tau_`count'' 	_col(24)  %9.3f `pv_rb_`count''	_col(35) %9.3f `ci_l_`count'' %9.3f `ci_r_`count''	_col(55) %9.3f `h_`count'' 						_col(66) %6.0f `n_h_`count'' 					_col(72) %9.3f `weight_`count''			
		local ++count

	}
	di as text "{hline 12}{c +}{hline 67}"
	di as res "{ralign 12:Pooled}"  		as text _col(10) "{c |}"	as res	_col(13) %9.3f `tau_pooled' 	_col(24)  %9.3f `pv_rb_pooled'	_col(35) %9.3f `ci_l_pooled' %9.3f `ci_r_pooled' 	_col(55) %9.3f min(`h_l_pooled',`h_r_pooled') 	_col(66) %6.0f `N_eff_l_pooled'+`N_eff_r_pooled' 	_col(80) "."			

	di as text "{hline 12}{c BT}{hline 67}"

********************************************************************************	
** Plots
********************************************************************************	
	
	if "`plot'"!=""{
	
		capture drop _aux_*
		tempvar aux_count aux_ci_l aux_ci_r aux_pooled aux_cutoffs aux_tag
		
		qui egen `aux_tag' = tag(`cvar')
		qui gen `aux_cutoffs' = `cvar' if `aux_tag'==1
		sort `aux_cutoffs'
		
		qui gen `aux_count' = _n in 1/`n_cutoffs'		
		
		* Plot coefficients
				
		qui gen `aux_ci_l' = `ci_l_pooled' in 1/`n_cutoffs'
		qui gen `aux_ci_r' = `ci_r_pooled' in 1/`n_cutoffs'
		qui gen `aux_pooled' = `tau_pooled' in 1/`n_cutoffs'
		mat Ct = coefs[1,2...]
		mat Ct = Ct'
		mat CIt = CI_rb[1...,2...]
		mat CIt = CIt'
		svmat Ct, names(_aux_coefs)
		svmat CIt, names(_aux_ci)
		twoway (rarea `aux_ci_r' `aux_ci_l' `aux_cutoffs', sort color(gs11)) ///
			   (rcap _aux_ci1 _aux_ci2 `aux_cutoffs', lcolor(navy)) ///
			   (scatter _aux_coefs1 `aux_cutoffs', mcolor(navy)) ///
			   (line `aux_pooled' `aux_cutoffs', lcolor(gs6)), ///
			   name(coefs, replace) ///
			   xtitle("Cutoff") ytitle("Treatment effect") ///
			   legend(order(3 "Estimate" 2 "95% CI" 4 "Pooled estimate" 1 "95% CI for pooled estimate" )) `graph_opt'
		
		* Plot weights
		
		mat Wt = weights'
		svmat Wt, names(_aux_weights)
		twoway bar _aux_weights1 `aux_count', xtitle("Cutoff") ytitle("Weight") ///
											  ylabel(0(.2)1) ///
											  name(weights, replace) barwidth(.5)
		
		drop _aux_*
	}
	
	
********************************************************************************	
** Return values
********************************************************************************

	local colname "`colname' pooled"
	
	matname `b' `colname', columns(.) explicit
	matname `V' `colname', explicit
	
	ereturn post `b' `V'

	ereturn scalar tau = `tau_pooled' 
	ereturn scalar se_rb = `se_rb_pooled'
	ereturn scalar pv_rb = `pv_rb_pooled'
	ereturn scalar ci_rb_l = `ci_l_pooled'
	ereturn scalar ci_rb_r = `ci_r_pooled'
	ereturn scalar h_l = `h_l_pooled'
	ereturn scalar h_r = `h_r_pooled'
	ereturn scalar N_r = `N_r_pooled'
	ereturn scalar N_l = `N_l_pooled'
	ereturn scalar N_h_r = `N_eff_r_pooled'
	ereturn scalar N_h_l = `N_eff_l_pooled'
	
	ereturn matrix sampsis = sampsis
	ereturn matrix weights = weights
	ereturn matrix CI_rb = CI_rb
	ereturn matrix coefs = coefs
	ereturn matrix H = H
	
end
