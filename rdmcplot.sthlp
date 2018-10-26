{smcl}
{* *! version 0.2 16-07-2018}{...}
{viewerjumpto "Syntax" "rdmcplot##syntax"}{...}
{viewerjumpto "Description" "rdmcplot##description"}{...}
{viewerjumpto "Options" "rdmcplot##options"}{...}
{viewerjumpto "Examples" "rdmcplot##examples"}{...}
{viewerjumpto "Saved results" "rdmcplot##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:rdmcplot} {hline 2} Plots for Regression Discontinuity Designs with Multiple Cutoffs.{p_end}


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:rdmcplot} {it:depvar} {it:runvar} {ifin} 
[{cmd:,} 
{cmd:{opt c:var}(}{it:string}{cmd:)} 
{cmd:{opt h:var}(}{it:string}{cmd:)} 
{cmd:{opt p:var}(}{it:string}{cmd:)} 
{cmd:noscatter} 
{cmd:nodraw}
]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 8}{cmd:rdmcplot} plots estimated regression functions at each cutoff in regression discontinuity designs with multiple cutoffs.{p_end}

{p 8 8}A detailed introduction to this command is given in
{browse "https://sites.google.com/site/rdpackages/rdmulti/Cattaneo-Titiunik-VazquezBare_2018_rdmulti.pdf": Cattaneo, Titiunik and Gonzalo Vazquez-Bare (2018)}.{p_end}

{p 8 8}Companion {browse "www.r-project.org":R} functions are also available {browse "https://sites.google.com/site/rdpackages/rdmc":here}.{p_end}

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

{p 4 8}{cmd:{opt h:var}(}{it:string}{cmd:)} specifies the bandwidths to be passed to {cmd:rdplot}. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:{opt p:var}(}{it:string}{cmd:)} specifies the order of the polynomials to be passed to {cmd:rdplot}. See {cmd:help rdrobust} for details.{p_end}

{p 4 8}{cmd:noscatter} omits the scatter plot.{p_end}

{p 4 8}{cmd:nodraw} omits plot.{p_end}


    {hline}
	
		
{marker examples}{...}
{title:Examples}

{p 4 8}Standard use of rdmcplot{p_end}
{p 8 8}{cmd:. rdmcplot yvar xvar, c(cvar)}{p_end}

{p 4 8}rdmcplot without scatter plot{p_end}
{p 8 8}{cmd:. rdmcplot yvar xvar, c(cvar) noscatter}{p_end}

{marker saved_results}{...}
{title:Saved results}

{p 4 8}{cmd:rdmcplot} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(p)}}order of the polynomial{p_end}
{synopt:{cmd:r(cnum)}}number of cutoffs{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cvar)}}cutoff variable{p_end}
{synopt:{cmd:r(clist)}}cutoff list{p_end}

{title:References}

{p 4 8}Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik. 2017.
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Farrell-Titiunik_2017_Stata.pdf":rdrobust: Software for Regression Discontinuity Designs}.{p_end}
{p 8 8}{it:Stata Journal} 17(2): 372-404.{p_end}

{p 4 8}Calonico, S., M. D. Cattaneo, and R. Titiunik. 2014.
{browse "https://sites.google.com/site/rdpackages/rdrobust/Calonico-Cattaneo-Titiunik_2014_Stata.pdf":Robust Data-Driven Inference in the Regression-Discontinuity Design}.{p_end}
{p 8 8}{it:Stata Journal} 14(4): 909-946.{p_end}

{p 4 8}Cattaneo, M. D., Frandsen, B., and R. Titiunik. 2015.
{browse "https://sites.google.com/site/rdpackages/rdlocrand/Cattaneo-Frandsen-Titiunik_2015_JCI.pdf":Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the U.S. Senate}.{p_end}
{p 8 8}{it:Journal of Causal Inference} 3(1): 1-24.{p_end}

{p 4 8}Cattaneo, M. D., R. Titiunik, and G. Vazquez-Bare. 2018.
{browse "https://sites.google.com/site/rdpackages/rdpower/Cattaneo-Titiunik-VazquezBare_2018_Stata.pdf":Power Calculations for Regression Discontinuity Designs}.{p_end}
{p 8 8}Working paper, University of Michigan.{p_end}


{title:Authors}

{p 4 8}Matias D. Cattaneo, University of Michigan, Ann Arbor, MI.
{browse "mailto:cattaneo@umich.edu":cattaneo@umich.edu}.{p_end}

{p 4 8}Rocio Titiunik, University of Michigan, Ann Arbor, MI.
{browse "mailto:titiunik@umich.edu":titiunik@umich.edu}.{p_end}

{p 4 8}Gonzalo Vazquez-Bare, University of Michigan, Ann Arbor, MI.
{browse "mailto:gvazquez@umich.edu":gvazquez@umich.edu}.{p_end}


