{smcl}
{* *! version 0.2 16-07-2018}{...}
{viewerjumpto "Syntax" "rdms##syntax"}{...}
{viewerjumpto "Description" "rdms##description"}{...}
{viewerjumpto "Options" "rdms##options"}{...}
{viewerjumpto "Examples" "rdms##examples"}{...}
{viewerjumpto "Saved results" "rdms##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdms} {hline 2} Analysis of Regression Discontinuity Designs with Multiple Scores.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdms} {it:depvar} {it:runvar1} [{it:runvar2 treatvar}] {ifin} 
[{cmd:,} 
{cmd:{opt c:var}(}{it:cvar1 [cvar2]}{cmd:)} 
{cmd:range(}{it:range1 [range2]}{cmd:)} 
{cmd:xnorm(}{it:string}{cmd:)} 
{cmd:pooled_opt(}{it:string}{cmd:)} 
{cmd:{opt h:var}(}{it:string}{cmd:)} 
{cmd:{opt b:var}(}{it:string}{cmd:)} 
{cmd:{opt p:var}(}{it:string}{cmd:)} 
{cmd:{opt kernel:var}(}{it:string}{cmd:)} 
{cmd:fuzzy(}{it:string}{cmd:)} 
{cmd:plot} 
{cmd:graph_opt(}{it:string}{cmd:)} 
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdms} provides tools to analyze regression discontinuity designs with multiple scores. If only {it:runvar1} is specified, {cmd:rdms} analyzes an RD design with
cumulative cutoffs in which a unit gets different dosages of a treatment depending on the value of {it:runvar1}. If {it:runvar1}, {it:runvar2} and {it:treatvar}
are specified, {cmd:rdms} analyzes an RD design with two running variables in which units with {it:treatvar} equal to one are treated.{p_end}

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

{p 4 8}{cmd:{opt c:var}(}{it:string}{cmd:)} specifies the numeric variable {it:cvar1} containing the RD cutoff for {it:indepvar} in a cumulative cutoffs setting,
or the two scores {it:cvar1} and {it:cvar2} in a two-score setting.{p_end}

{p 4 8}{cmd:range(}{it:range1 [range2]}{cmd:)} specifies the range of the running variable to be used for estimation around each cutoff.  Specifying only one variable implies using the same range at each side of the cutoff.{p_end}

{p 4 8}{cmd:xnorm(}{it:string}{cmd:)} specifies the normalized running variable to estimate pooled effect.{p_end}

{p 4 8}{cmd:pooled_opt(}{it:string}{cmd:)} specifies the options to be passed to {cmd:rdrobust} to calculate pooled estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt h:var}(}{it:string}{cmd:)} specifies the bandwidths to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt b:var}(}{it:string}{cmd:)} specifies the bandwidths for the bias to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt p:var}(}{it:string}{cmd:)} specifies the order of the polynomials to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt kernel:var}(}{it:string}{cmd:)} specifies the kernels to be passed to {cmd:rdrobust} to calculate cutoff-specific estimates. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:fuzzy(}{it:string}{cmd:)} indicates a fuzzy design. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:plot} plots the pooled and cutoff-specific estimates and the weights given by the pooled estimate to each cutoff-specific estimate.{p_end}

{p 4 8}{cmd:graph_opt(}{it:string}{cmd:)} options to be passed to the graph when {cmd:plot} is specified.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Examples}

{p 4 8}Standard use of rdms for cumulative cutoffs{p_end}
{p 8 8}{cmd:. rdms yvar xvar, c(cvar)}{p_end}

{p 4 8}rdms with plot{p_end}
{p 8 8}{cmd:. rdms yvar xvar, c(cvar) plot}{p_end}

{p 4 8}Standard use of rdms for multiple scores{p_end}
{p 8 8}{cmd:. rdms yvar xvar1 xvar2 treatvar, c(cvar)}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdms} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}bias corrected coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(coefs)}}conventional coefficient vector{p_end}
{synopt:{cmd:e(CI_rb)}}bias corrected confidence intervals{p_end}
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


