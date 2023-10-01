**** Recreational Marijuana Event Study Figures ****
**** Afif Mazhar ****
**** 09/07/2023 ****


* do-file that creates graphs for poverty, gdp, and household_income without covariates

clear all

* import data
use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

* eventtime rename
rename approval_year eventtime

* generate the post-treatment dummy and the timeToTreat dummy

gen timeToTreat = year - eventtime
gen treatment = cond(year >= eventtime,1,0)



****************************
*** Graph 1: CDF by Year ***
****************************

* we want to count the amount of times treatment was applied per state by year and generate a cumulative distribution of the graph

cumul eventtime, gen(cumul_freq)
sort cumul_freq
line cumul_freq eventtime, title("Distribution of Approval Year") ytitle("Cumulative Frequency") ylab(, grid) xtitle("Event Time") xlab(, grid) xlabel(2012(3)2023)
graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Distribution_Approval_Year.png", as(png)





**********************************
**********************************
************ Poverty *************
**********************************
**********************************

* bacon decomp
reghdfe poverty treatment, absorb(state_fips year)
bacondecomp poverty treatment, ddetail


*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (poverty) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe poverty treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe poverty F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)

* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Unit) Change in Poverty") xlabel(-15(5)10, labsize(small)) ylabel(-2(0.5)1,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Poverty_TWFE_Event_Plot.png", as(png) replace


* truncated event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	trimlag(5) trimlead(5) ///
	graph_opt(ytitle("Estimated (Unit) Change in Poverty") xlabel(-5(1)5, labsize(small)) ylabel(-1.5(0.5)1,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Poverty_TWFE_Event_Plot_Truncated.png", as(png) replace


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation poverty state_fips year eventtime, autosample allhorizons pretrends(5) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid poverty, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract poverty L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt poverty state_fips year treatment, robust_dynamic dynamic(9) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) noautolegend ///
	graph_opt(title("Poverty Effects", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change") xlabel(-18(2)10, labsize(small)) ylabel(-3(0.5)3, labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Poverty_5_Estimators.png", as(png) replace

* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(5) noautolegend ///
	graph_opt(title("Poverty Effects", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change") xlabel(-5(1)5,labsize(small)) ylabel(-2(0.5)2,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs12) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs12)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Poverty_5_Estimators_Truncated.png", as(png) replace



***************************** natural log of poverty

gen ln_poverty = ln(poverty)

*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (ln_poverty) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe ln_poverty treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe ln_poverty F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)

* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Percent) Change in Poverty") xlabel(-15(5)10, labsize(small)) ylabel(, labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Poverty_TWFE_Event_Plot.png", as(png) replace


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation ln_poverty state_fips year eventtime, autosample allhorizons pretrends(5) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid ln_poverty, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract ln_poverty L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt ln_poverty state_fips year treatment, robust_dynamic dynamic(9) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) noautolegend ///
	graph_opt(title("Poverty Effects", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change") xlabel(-18(2)10,labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Poverty_5_Estimators.png", as(png) replace

* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(5) noautolegend ///
	graph_opt(title("Poverty Effects", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change") xlabel(-5(1)5, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Poverty_5_Estimators_Truncated.png", as(png)	replace



























*********************************
*********************************
******* Real GDP ********
*********************************
*********************************

clear all

* import data

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

* eventtime rename

rename approval_year eventtime

* generate the post-treatment dummy and the timeToTreat dummy

gen timeToTreat = year - eventtime
gen treatment = cond(year >= eventtime,1,0)



*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (gdp) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe gdp treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe gdp F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)

* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Unit) Change in Real GDP") xlabel(-15(5)10, labsize(small)) ylabel(,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_GDP_TWFE_Event_Plot.png", as(png)


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation gdp state_fips year eventtime, autosample allhorizons pretrends(3) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid gdp, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract gdp L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt gdp state_fips year treatment, robust_dynamic dynamic(8) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(10) trimlag(10) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change in Real GDP") xlabel(-10(1)10, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))


graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_GDP_5_Estimators.png", as(png) replace
	
* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(5) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change in Real GDP") xlabel(-5(1)5, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_GDP_5_Estimators_Truncated.png", as(png) replace
	
	
	
	
	
	
	

	
	
	
	
	

*********************************
*********************************
******* Log Real GDP ********
*********************************
*********************************

clear all

* import data

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

* eventtime rename

rename approval_year eventtime

* generate the post-treatment dummy and the timeToTreat dummy

gen ln_gdp = ln(gdp)
gen timeToTreat = year - eventtime
gen treatment = cond(year >= eventtime,1,0)


*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (ln_gdp) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe ln_gdp treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe ln_gdp F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)

* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Percent) Change in Real GDP") xlabel(-15(5)10, labsize(small)) ylabel(,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_GDP_TWFE_Event_Plot.png", as(png)


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation ln_gdp state_fips year eventtime, autosample allhorizons pretrends(3) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid ln_gdp, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract ln_gdp L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt ln_gdp state_fips year treatment, robust_dynamic dynamic(8) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(10) trimlag(10) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change in Real GDP") xlabel(-10(1)10, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))


graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_GDP_5_Estimators.png", as(png)	
	
* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(5) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change in Real GDP") xlabel(-5(1)5, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_GDP_5_Estimators_Truncated.png", as(png)
	
	
	
	
	
	

*********************************
*********************************
******* Household Income ********
*********************************
*********************************

clear all

* import data

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

* eventtime rename

rename approval_year eventtime

* generate the post-treatment dummy and the timeToTreat dummy

gen timeToTreat = year - eventtime
gen treatment = cond(year >= eventtime,1,0)



*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (household_income) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe household_income treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe household_income F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)


* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Unit) Change in Household Income") xlabel(-15(5)10, labsize(small)) ylabel(,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_Income_TWFE_Event_Plot.png", as(png)


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation household_income state_fips year eventtime, autosample allhorizons pretrends(3) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid household_income, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract household_income L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt household_income state_fips year treatment, robust_dynamic dynamic(8) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(10) trimlag(10) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change in Household Income") xlabel(-10(1)10, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))


graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_Income_5_Estimators.png", as(png)	
	
* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(5) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Unit) Change in Household Income") xlabel(-5(1)5, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Unit_Household_Income_5_Estimators_Truncated.png", as(png)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

*********************************
*********************************
******* Natural log Household Income ********
*********************************
*********************************

clear all

* import data

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

* eventtime rename

rename approval_year eventtime

* generate the post-treatment dummy and the timeToTreat dummy

gen ln_household_income = ln(household_income)
gen timeToTreat = year - eventtime
gen treatment = cond(year >= eventtime,1,0)



*************************
*** Graph 2: TWFE OLS ***
*************************

forvalues l = 0/9 { // manipulate based on time window
	gen L`l'event = timeToTreat==`l' 
}
forvalues l = 1/14 { // manipulate based on time window
	gen F`l'event = timeToTreat==-`l'
}
drop F1event // defines the counterfactual



* use didregress for the static two-way fixed effects OLS regression and get the ATET

didregress (ln_household_income) (treatment), group(state_fips) time(year) 

* Another way to run the static regression

reghdfe ln_household_income treatment, absorb(state_fips year) cluster(state_fips)

* use reghdfe to run the baseline two-way fixed effects OLS regression for dynamic effects

reghdfe ln_household_income F*event L*event, absorb(state_fips year) cluster(state_fips)
estimates store ols // saving the estimates for later

* quick event plot

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Years since the event") ytitle("OLS coefficients") xlabel(-15(1)10) title("Recreational Marijuana Legalization"))									

coefplot, vertical drop(_cons)


* full event plot ols

event_plot ols, ///
	stub_lag(L#event) stub_lead(F#event) plottype(scatter) ciplottype(rcap) ///
	graph_opt(ytitle("Estimated (Percent) Change in Household Income") xlabel(-15(5)10, labsize(small)) ylabel(,labsize(small)) xtitle("Years Before and After Treaty Enforcement") ///
		bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
		legend(order(2 "Pre-Trends" 4 "OLS") rows(1) position(12) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(black)) lag_ci_opt1(color(black)) 

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Income_TWFE_Event_Plot.png", as(png)


******************************************
*** Graph 3: DiD Estimator Comparisons ***
******************************************

* we will now compare the TWFE OLS estimator with the recently developed estimators by Callaway and Sant'Anna, Borusyak et al., Sun and Abraham, and de Chaisemartin-D'Haultfoeuille

*** Borusyak et al. ***

did_imputation ln_household_income state_fips year eventtime, autosample allhorizons pretrends(3) cluster(state_fips) // autosample allows for 114 observations to be dropped, can't be computed, allhorizons runs the regression unto all available periods, note that tau 10, 12, 14, and 15 are not computed because of a lack of observations (we don't have enough data for these periods) Also, the more pre-periods added, the more that the standard errors explode, it's necessary to identify a low amount of pre-periods, hence why 3 were used.
estimates store bjs // storing the estimates for later

* event plot to view the graph

event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") title("Borusyak et al. (2021) imputation estimator") xlabel(-28(1)15) legend(position(6)))

*** Callaway and San'Anna ***

gen gvar = cond(eventtime==., 0, eventtime) // group variable as required for the csdid command
csdid ln_household_income, ivar(state_fips) time(year) gvar(gvar) notyet event
estat event, estore(cs) // this produces and stores the estimates at the same time

* event plot to view the graph
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-28(1)15) title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

		
*** Sun and Abraham ***

gen lastcohort = eventtime==r(max)
eventstudyinteract ln_household_income L*event F*event, vce(cluster state_fips) absorb(state_fips year) cohort(eventtime) control_cohort(lastcohort)
matrix sa_b = e(b_iw) // storing the estimates for later
matrix sa_v = e(V_iw)

* event plot to view the graph

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-15(5)15) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

*** de Chaisemartin-D'Haultfoeuille ***

did_multiplegt ln_household_income state_fips year treatment, robust_dynamic dynamic(8) placebo(4) breps(100) cluster(state_fips) 
matrix dcdh_b = e(estimates) // storing the estimates for later
matrix dcdh_v = e(variances)

* event plot to view the graph

event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)12)) stub_lag(Effect_#) stub_lead(Placebo_#) together // estimate stops at 9 periods

// Combine all plots using the stored estimates
event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(10) trimlag(10) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change in Household Income") xlabel(-10(1)10, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))


graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Income_5_Estimators.png", as(png)	
	
* truncated

event_plot dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(Effect_# Tp# L#event L#event) stub_lead(Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) trimlag(3) noautolegend ///
	graph_opt(title("Real Gross Domestic Product", size(medlarge)) ///
		xtitle("Years Before and After Policy Enactment") ytitle("Estimated (Percent) Change in Household Income") xlabel(-5(1)3, labsize(small)) ylabel(,labsize(small)) ///
		legend(order( 2 "de Chaisemartin-D'Haultfoeuille" ///
				4 "Callaway-Sant'Anna" 6 "Sun-Abraham" 8 "OLS") rows(2) position(6) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lpattern(dash) lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(blue)) lag_ci_opt1(color(blue)) ///
	lag_opt2(msymbol(Dh) color(red)) lag_ci_opt2(color(red)) ///
	lag_opt3(msymbol(Th) color(emerald)) lag_ci_opt3(color(emerald)) ///
	lag_opt4(msymbol(Sh) color(black)) lag_ci_opt4(color(black)) ///	
	lag_opt5(msymbol(Oh) color(yellow)) lag_ci_opt5(color(yellow))

graph export "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Tables\Percent_Household_Income_5_Estimators_Truncated.png", as(png)