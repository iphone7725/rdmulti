/*******************************************************************************
RDMS: analysis of Regression Discontinuity Designs with multiple scores
*!version 0.2 16-Jul-2018
Authors: Matias Cattaneo, Rocío Titiunik, Gonzalo Vazquez-Bare
*******************************************************************************/

capture program drop rdms
program define rdms, eclass sortpreserve

	syntax varlist (min=2 max=4) [if] [in], Cvar(string) [range(string) xnorm(string) pooled_opt(string) Hvar(string) Bvar(string) Pvar(string) KERNELvar(string) fuzzy(string) plot graph_opt(string)]

	
********************************************************************************
** Setup and error checking
********************************************************************************
	
	marksample touse, novarlist
	
	tokenize `varlist'
	local yvar `1' 
	local xvar `2' 
	local xvar2 `3'
	local zvar `4'
	
	if "`xvar2'"!="" & "`zvar'"==""{
		di as error "Need to specify zvar when xvar2 is specified"
		exit 102
	}
	
	tokenize `cvar'
	local cvar `1'
	local cvar2 `2'
	
	if "`cvar2'"=="" & "`xvar2'"!=""{
		di as error "Too few variables specified in cvar"
		exit 102
	}
		
	qui count if `cvar'!=.
	local n_cutoffs = r(N)
	
	if "`cvar2'"!=""{
		qui count if `cvar2'!=.
		local n_cutoffs2 = r(N)
		if `n_cutoffs'!=`n_cutoffs2' {
			di as error "cutoffs coordinates incorrectly specified"
			exit 198
		}
	}
	
	if "`range'"!=""{
		tokenize `range'
		local range_c `1'
		if "`2'"==""{
			local range_t `1'
		} 
		else {
			local range_t `2'
		}
		
		* some range error checking...	
	}
	
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
	
	if "`xnorm'"==""{
		mat `b' = J(1,`n_cutoffs',.)
		mat `V' = J(`n_cutoffs',`n_cutoffs',0)
		mat sampsis = J(1,`n_cutoffs',.)
		mat coefs = J(1,`n_cutoffs',.)
		mat CI_rb = J(2,`n_cutoffs',.)
		mat H = J(1,`n_cutoffs',.)
	} 
	else {
		mat `b' = J(1,`n_cutoffs'+1,.)
		mat `V' = J(`n_cutoffs'+1,`n_cutoffs'+1,0)
		mat sampsis = J(1,`n_cutoffs'+1,.)
		mat coefs = J(1,`n_cutoffs'+1,.)
		mat CI_rb = J(2,`n_cutoffs'+1,.)	
		mat H = J(1,`n_cutoffs'+1,.)
	}


********************************************************************************	
** Calculate cutoff-specific estimates
********************************************************************************

	if "`xvar2'"==""{
		
		forvalues c = 1/`n_cutoffs'{
		
			local cutoff_`c' = round(`cvar'[`c'],.001)
		
			tempvar xc_`c'
			qui gen double `xc_`c'' = `xvar' - `cvar'[`c']

			if "`range'"==""{
				tempvar range_c range_t
				qui gen double `range_c' = .
				qui gen double `range_t' = .
				qui sum `xc_`c''
				qui replace `range_c' = abs(r(min)) in `c'
				qui replace `range_t' = abs(r(max)) in `c'
			}
			
			if "`hvar'"!=""{
				local h = `hvar'[`c']
				local h_opt "h(`h')"
			}
			
			if "`bvar'"!=""{
				local b = `bvar'[`c']
				local b_opt "b(`b')"
			}
			
			if "`pvar'"!=""{
				local p = `pvar'[`c']
				local p_opt "p(`p')"
			}
			
			qui rdrobust `yvar' `xc_`c'' if -`range_c'[`c']<=`xc_`c'' & `xc_`c''<=`range_t'[`c'] & `touse', `h_opt' `b_opt' `p_opt' `fuzzy_opt'
			
			local h_`c' = e(h_l)
			local n_h_`c' = e(N_h_l) + e(N_h_r)
			local tau_`c' = e(tau_cl)
			local se_rb_`c' = e(se_tau_rb)
			local pv_rb_`c' = e(pv_rb)
			local ci_l_`c' = e(ci_l_rb)
			local ci_r_`c' = e(ci_r_rb)
			
			local colname "`colname' c`c'"
			
			mat `b'[1,`c'] = e(tau_bc)
			mat `V'[`c',`c'] = e(se_tau_rb)^2
			mat coefs[1,`c'] = e(tau_cl)
			mat CI_rb[1,`c'] = e(ci_l_rb)
			mat CI_rb[2,`c'] = e(ci_r_rb)
			mat sampsis[1,`c'] = e(N_h_l) + e(N_h_r)
			mat H[1,`c'] = e(h_l)

		}
	}
	
	else {
		
		forvalues c = 1/`n_cutoffs'{
		
			local cutoff_`c'_1 = round(`cvar'[`c'],.001)
			local cutoff_`c'_2 = round(`cvar2'[`c'],.001)
			local cutoff_`c' = abbrev("(`cutoff_`c'_1',`cutoff_`c'_2')",19)
		
			* Calculate (Euclidean) distance to cutoff
			tempvar xc_`c'
			qui gen double `xc_`c'' = sqrt((`xvar'-`cvar'[`c'])^2+(`xvar2'-`cvar2'[`c'])^2)*(2*`zvar'-1)
			
			if "`range'"==""{
				tempvar range_c range_t
				qui gen double `range_c' = .
				qui gen double `range_t' = .
				qui sum `xc_`c''
				qui replace `range_c' = abs(r(min)) in `c'
				qui replace `range_t' = abs(r(max)) in `c'
			}
			
			if "`hvar'"!=""{
				local h = `hvar'[`c']
				local h_opt "h(`h')"
			}
			
			if "`bvar'"!=""{
				local b = `bvar'[`c']
				local b_opt "b(`b')"
			}
			
			if "`pvar'"!=""{
				local p = `pvar'[`c']
				local p_opt "p(`p')"
			}
			
			if "`kernelvar'"!=""{
				local kernel = `kernelvar'[`count']
				local k_opt "kernel(`kernel')"
			}

			qui rdrobust `yvar' `xc_`c'' if -`range_c'[`c']<=`xc_`c'' & `xc_`c''<=`range_t'[`c'] & `touse', `h_opt' `b_opt' `p_opt' `k_opt' `fuzzy_opt'
			
			local h_`c' = e(h_l)
			local n_h_`c' = e(N_h_l) + e(N_h_r)
			local tau_`c' = e(tau_cl)
			local se_rb_`c' = e(se_tau_rb)
			local pv_rb_`c' = e(pv_rb)
			local ci_l_`c' = e(ci_l_rb)
			local ci_r_`c' = e(ci_r_rb)
			
			local colname "`colname' c`c'"
			
			mat `b'[1,`c'] = e(tau_bc)
			mat `V'[`c',`c'] = e(se_tau_rb)^2
			mat coefs[1,`c'] = e(tau_cl)
			mat CI_rb[1,`c'] = e(ci_l_rb)
			mat CI_rb[2,`c'] = e(ci_r_rb)
			mat sampsis[1,`c'] = e(N_h_l) + e(N_h_r)
			mat H[1,`c'] = e(h_l)
		}
		
	}
	
	
********************************************************************************	
** Calculate pooled estimate
********************************************************************************
	
	if "`xnorm'"!=""{
		
		qui rdrobust `yvar' `xnorm' if `touse', `pooled_opt'
		
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
		
		local colname "`colname' pooled"
		
		mat `b'[1,`n_cutoffs'+1] = e(tau_bc)
		mat `V'[`n_cutoffs'+1,`n_cutoffs'+1] = e(se_tau_rb)^2
		mat coefs[1,`n_cutoffs'+1] = e(tau_cl)
		mat CI_rb[1,`n_cutoffs'+1] = e(ci_l_rb)
		mat CI_rb[2,`n_cutoffs'+1] = e(ci_r_rb)
		mat sampsis[1,`n_cutoffs'+1] = e(N_h_l) + e(N_h_r)
		mat H[1,`n_cutoffs'+1] = e(h_l)
	}
	
********************************************************************************
** Display results
********************************************************************************

	di _newline
	di as text "Cutoff-specific RD estimation with robust bias-corrected inference"
	di as text "{hline 20}{c TT}{hline 59}"
	di as text "{ralign 20:Cutoff}" as text _col(19) "{c |}"	_col(27) "Coef." 					_col(36) "P>|z|"  				_col(47)  "[95% Conf. Int.]"	_col(69) "h"		_col(79) "Nh"
	di as text "{hline 20}{c +}{hline 59}"

	forvalues c = 1/`n_cutoffs'{
		*di as res "{lalign 2:`c'.}"  "{ralign 10: `cutoff_`c''}"		as text _col(10) "{c |}"	as res	_col(13) %9.3f `tau_`c'' 	_col(24)  %9.3f `pv_rb_`c''	_col(35) %9.3f `ci_l_`c'' %9.3f `ci_r_`c''	_col(55) %9.3f `h_`c'' 			_col(66) %6.0f `n_h_`c''
		di as res "{ralign 20: `cutoff_`c''}"		as text _col(19) "{c |}"	as res	_col(22) %9.3f `tau_`c'' 	_col(32)  %9.3f `pv_rb_`c''	_col(44) %9.3f `ci_l_`c'' %9.3f `ci_r_`c''	_col(64) %9.3f `h_`c'' 			_col(75) %6.0f `n_h_`c''
	}
		
	if "`xnorm'"!=""{
		di as text "{hline 20}{c +}{hline 59}"
		di as res "{ralign 20:Pooled}"  		as text _col(19) "{c |}"	as res	_col(22) %9.3f `tau_pooled' 	_col(32)  %9.3f `pv_rb_pooled'	_col(44) %9.3f `ci_l_pooled' %9.3f `ci_r_pooled' 	_col(64) %9.3f min(`h_l_pooled',`h_r_pooled') 	_col(75) %6.0f `N_eff_l_pooled'+`N_eff_r_pooled' 
		di as text "{hline 20}{c BT}{hline 59}"
	}
	else {
		di as text "{hline 20}{c BT}{hline 59}"
	}

********************************************************************************
** Plots
********************************************************************************
	
	if "`plot'"!=""{
	
		if "`xnorm'"!=""{	
			capture drop _aux_*
			tempvar aux_count aux_ci_l aux_ci_r aux_pooled aux_cutoffs aux_tag
			
			qui gen `aux_count' = _n in 1/`n_cutoffs'
			
			local xmax_range = `n_cutoffs'+.2
			
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
			twoway (rarea `aux_ci_r' `aux_ci_l' `aux_count', sort color(gs11)) ///
				   (rcap _aux_ci1 _aux_ci2 `aux_count', lcolor(navy)) ///
				   (scatter _aux_coefs1 `aux_count', mcolor(navy)) ///
				   (line `aux_pooled' `aux_count', lcolor(gs6)), ///
				   yline(0, lpattern(shortdash) lcolor(black)) ///
				   xtitle("Cutoff") ytitle("Treatment effect") ///
				   legend(order(3 "Estimate" 2 "95% CI" 4 "Pooled estimate" 1 "95% CI for pooled estimate" )) ///
				   xlabel(1(1)`n_cutoffs') xscale(range(0.8 `xmax_range')) `graph_opt'
			
			drop _aux_*
		}
		else {
			capture drop _aux_*
			tempvar aux_count
			qui gen `aux_count' = _n in 1/`n_cutoffs'
			local xmax_range = `n_cutoffs'+.2
			
			* Plot coefficients
					
			mat Ct = coefs
			mat Ct = Ct'
			mat CIt = CI_rb
			mat CIt = CIt'
			svmat Ct, names(_aux_coefs)
			svmat CIt, names(_aux_ci)
			twoway (rcap _aux_ci1 _aux_ci2 `aux_count', lcolor(navy)) ///
				   (scatter _aux_coefs1 `aux_count', mcolor(navy)), ///
				   yline(0, lpattern(shortdash) lcolor(black)) ///
				   xtitle("Cutoff") ytitle("Treatment effect") ///
				   legend(order(2 "Estimate" 1 "95% CI")) ///
				   xlabel(1(1)`n_cutoffs') xscale(range(0.8 `xmax_range')) `graph_opt'
			
			drop _aux_*
		}
	}
	
	
********************************************************************************
** Return values
********************************************************************************

	matname `b' `colname', columns(.) explicit
	matname `V' `colname', explicit
	
	ereturn post `b' `V'
	
	ereturn matrix sampsis = sampsis
	ereturn matrix CI_rb = CI_rb
	ereturn matrix coefs = coefs
	ereturn matrix H = H
	
end
