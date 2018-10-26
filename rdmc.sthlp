{smcl}
{* *! version 0.2 16-07-2018}{...}
{viewerjumpto "Syntax" "rdmc##syntax"}{...}
{viewerjumpto "Description" "rdmc##description"}{...}
{viewerjumpto "Options" "rdmc##options"}{...}
{viewerjumpto "Examples" "rdmc##examples"}{...}
{viewerjumpto "Saved results" "rdmc##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdmc} {hline 2} Analysis of Regression Discontinuity Designs with Multiple Cutoffs.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdmc} {it:depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:{opt c:var}(}{it:string}{cmd:)} 
{cmd:pooled_opt(}{it:string}{cmd:)} 
{cmd:{opt h:var}(}{it:string}{cmd:)} 
{cmd:{opt b:var}(}{it:string}{cmd:)} 
{cmd:{opt p:var}(}{it:string}{cmd:)} 
{cmd:{opt kernel:var}(}{it:string}{cmd:)} 
{cmd:fuzzy(}{it:string}{cmd:)} 
{cmd:plot} 
{cmd:graph_opt(}{it:string}{cmd:)} 
{cmd:verbose}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdmc} provides tools to analyze regression discontinuity designs with multiple cutoffs.
Companion command is: {help rdmcplot:rdmcplot} for plots.{p_end}

{p 8 8}A detailed introduction to this command is given in
{browse "https://sites.google.com/site/rdpackages/rdmulti/Cattaneo-Titiunik-VazquezBare_2018_rdmulti.pdf": Cattaneo, Titiunik and Gonzalo Vazquez-Bare (2018)}.{p_end}

{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://sites.google.com/site/rdpackages/rdmulti":here}.{p_end}

{p 8 8}This command employs the Stata (and R) package {help rdrobust:rdrobust} for underlying calculations. See
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Calonico, Cattaneo and Titiunik (2014)}
and
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Farrell-Titiunik_2017_Stata.pdf":Calonico, Cattaneo, Farrell and Titiunik (2017)}
for more details.{p_end}

{p 4 8}Related Stata and R packages useful for inference in RD designs are described in the following website:{p_end}

{p 8 8}{browse "https://sites.google.com/site/rdpackages/":https://sites.google.com/site/rdpackages/}{p_end}


{marker options}{...}
{title:Options}

{p 4 8}{cmd:{opt c:var}(}{it:string}{cmd:)} specifies the numeric variable containing the RD cutoff for {it:indepvar} for each unit in the sample.{p_end}

{p 4 8}{cmd:pooled_opt(}{it:string}{cmd:)} specifies the options to be passed to {cmd:rdrobust} to calculate pooled estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt h:var}(}{it:string}{cmd:)} specifies the bandwidths to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt b:var}(}{it:string}{cmd:)} specifies the bandwidths for the bias to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt p:var}(}{it:string}{cmd:)} specifies the order of the polynomials to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt kernel:var}(}{it:string}{cmd:)} specifies the kernels to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:fuzzy(}{it:string}{cmd:)} indicates a fuzzy design. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:plot} plots the pooled and cutoff-specific estimates and the weights given by the pooled estimate to each cutoff-specific estimate.{p_end}

{p 4 8}{cmd:graph_opt(}{it:string}{cmd:)} options to be passed to the graph when {cmd:plot} is specified.{p_end}

{p 4 8}{cmd:verbose} displays the output from {cmd:rdrobust} for estimating the pooled estimand.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Examples}

{p 4 8}Standard use of rdmc{p_end}
{p 8 8}{cmd:. rdmc yvar xvar, c(cvar)}{p_end}

{p 4 8}rdmc with plots of estimates and weights{p_end}
{p 8 8}{cmd:. rdmc yvar xvar, c(cvar) plot}{p_end}

{p 4 8}rdmc showing output from {cmd:rdrobust} and specifying uniform kernel{p_end}
{p 8 8}{cmd:. rdmc yvar xvar, c(cvar) verbose} pooled_opt(kernel(uniform)) {p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdmc} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(tau)}}pooled estimate {p_end}
{synopt:{cmd:e(se_rb)}}robust bias corrected s.e. for pooled estimate {p_end}
{synopt:{cmd:e(pv_rb)}}robust bias corrected p-value {p_end}
{synopt:{cmd:e(ci_rb_l)}}left limit of robust bias corrected confidence interval {p_end}
{synopt:{cmd:e(ci_rb_r)}}right limit of robust bias corrected confidence interval {p_end}
{synopt:{cmd:e(h_l)}}bandwidth to the left of the cutoff used to estimate pooled estimand {p_end}
{synopt:{cmd:e(h_r)}}bandwidth to the right of the cutoff used to estimate pooled estimand {p_end}
{synopt:{cmd:e(N_l)}}total sample size to the left of the cutoff used to estimate pooled estimand {p_end}
{synopt:{cmd:e(N_r)}}total sample size to the right of the cutoff used to estimate pooled estimand {p_end}
{synopt:{cmd:e(N_h_l)}}sample size within bandwidth to the left of the cutoff used to estimate pooled estimand {p_end}
{synopt:{cmd:e(N_h_r)}}sample size within bandwidth to the right of the cutoff used to estimate pooled estimand {p_end}


{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}bias corrected coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(coefs)}}conventional coefficient vector{p_end}
{synopt:{cmd:e(CI_rb)}}bias corrected confidence intervals{p_end}
{synopt:{cmd:e(weights)}}vector of weights for each cutoff-specific estimate{p_end}
{synopt:{cmd:e(sampsis)}}vector of sample sizes at each cutoff{p_end}
{synopt:{cmd:e(H)}}vector of bandwidths at each cutoff{p_end}


{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik. 2017.
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Farrell-Titiunik_2017_Stata.pdf":rdrobust: Software for Regression Discontinuity Designs}.{p_end}
{p 8 8}{it:Stata Journal} 17(2): 372-404.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik. 2014.
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Robust Data-Driven Inference in the Regression-Discontinuity Design}.{p_end}
{p 8 8}{it:Stata Journal} 14(4): 909-946.{p_end}


{title:Authors}

{p 4 8}Matias D. Cattaneo, University of Michigan, Ann Arbor, MI.
{browse "mailto:cattaneo@umich.edu":cattaneo@umich.edu}.{p_end}

{p 4 8}Rocio Titiunik, University of Michigan, Ann Arbor, MI.
{browse "mailto:titiunik@umich.edu":titiunik@umich.edu}.{p_end}

{p 4 8}Gonzalo Vazquez-Bare, University of Michigan, Ann Arbor, MI.
{browse "mailto:gvazquez@umich.edu":gvazquez@umich.edu}.{p_end}


