/*******************************************************************************
RDMCPLOT: Regression discontinuity plots with multiple cutoffs
*!version 0.2 16-Jul-2018
Authors: Matias Cattaneo, Rocío Titiunik, Gonzalo Vazquez-Bare
*******************************************************************************/

capture program drop rdmcplot
program define rdmcplot, rclass
	syntax varlist (min=2 max=2) [if] [in], Cvar(string) [Hvar(string) Pvar(string) NOscatter NOdraw]
	
	
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

	tempvar treated
	gen double `treated' = `xvar'>=`cvar'

	qui levelsof `cvar' if `touse', local(clist)
	local n_cutoffs: word count `clist'
	
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
	
	local colorlist "navy maroon green dkorange gray khaki cranberry blue gold cyan"
	local colorlist1 "`colorlist'"
	
	
********************************************************************************
** Generate variables to plot
********************************************************************************	

	local i = 1
	local count = 0
	foreach c of numlist `clist'{
		
		tempvar yhat_`i' ybar_`i' xbar_`i'
		
		if "`colorlist1'"==""{
			local colorlist1 "`colorlist'"
			local count = `count' + 1
		}
		
		gettoken color colorlist1 : colorlist1
		
		local f = 1 - 0.2*`count'
		local color "`color'*`f'"
		
		if "`hvar'"!=""{
			local h = `hvar'[`i']
			local h_opt "h(`h')"
			local range_cond "& `c'-`h'<=`xvar' & `xvar'<=`c'+`h'"
		}
		
		if "`pvar'"!=""{
			local p = `pvar'[`i']
			local p_opt "p(`p')"
		}
		
		qui {
			capture drop rdplot_*
			rdplot `yvar' `xvar' if `cvar'==`c' & `touse' `range_cond', c(`c') `p_opt' `h_opt' genvars hide
			gen double `yhat_`i'' = rdplot_hat_y
			gen double `ybar_`i'' = rdplot_mean_y	
			gen double `xbar_`i'' = rdplot_mean_x
		}
		
		local scat_plots "`scat_plots' (scatter `ybar_`i'' `xbar_`i'', msize(small) mcolor(`color'))"
		local line_plots "`line_plots' (line `yhat_`i'' `xvar' if `cvar'==`c' & `treated'==1, sort lwidth(medthin) lcolor(`color'))(line `yhat_`i'' `xvar' if `cvar'==`c' & `treated'==0, sort lwidth(medthin) lcolor(`color'))"
		local xline_plots "`xline_plots' xline(`c', lcolor(`color') lwidth(medthin) lpattern(shortdash))"
		
		local ++i
	}
	
	
********************************************************************************
** Plot
********************************************************************************

	if "`nodraw'"==""{
		if "`noscatter'"==""{
			twoway `scat_plots' `line_plots', `xline_plots' legend(off)
		}
		else {
			twoway `line_plots', `xline_plots' legend(off)
		}
	}
	
	
********************************************************************************
** Return values
********************************************************************************
	
	drop rdplot_*
	
	ret local clist `clist'
	ret local cvar `cvar'
	ret scalar n_cutoffs = `n_cutoffs'

end
