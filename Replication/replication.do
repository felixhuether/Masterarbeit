/* Replication script:

Universität Potsdam
Wirtschafts- und Sozialwissenschaftliche Fakultät
Lehrstuhl Methoden der empirischen Sozialforschung

	Masterarbeit
"Der Einfluss von US-Wirtschaftssanktionen auf die Demokratisierung in den Zielländern seit 1945"

	eingereicht von:
	Felix Hüther
	Master Politikwissenschaft, 6. Fachsemester; Matrikelnummer: 777301
	E-Mail: huether@uni-potsdam.de

	im Sommersemester 2021 bei
	Prof. Dr. Ulrich Kohler (Erstbegutachtung)
	Dr. Anna Fruhstorfer (Zweitbegutachtung)

 Last modified: August, 2021 */

/*	Use the following commands in this section only if you start with the excel file.
	If you start with the stata .dta file please skip this section and continue with section 2. */


	
** SECTION 1

/* this section generates the replication.dta file from the excel file replication.xlsx.
Please skip this section and continue with section 2 if you start with the Stata file right away. */


* import excel "/workking directory path/filename.xlsx", sheet("Sheet1") firstrow

version 17
set more off

** encode string variables to be numeric; drop string variables
encode c_name, gen(country)
drop c_name

encode ccode, gen(c_code)
drop ccode
rename c_code ccode

encode cowc, gen(cow_c)
drop cowc
rename cow_c cowc

encode e_regionpol, gen(e_regionpol1)
drop e_regionpol
rename e_regionpol1 e_regionpol

encode e_regionpol_6C, gen(e_regionpol_6C1)
drop e_regionpol_6C
rename e_regionpol_6C1 e_regionpol_6C

encode v2x_regime_amb, gen(v2x_regime_amb1)
drop v2x_regime_amb
rename v2x_regime_amb1 v2x_regime_amb


** order variables for better readability in the browse window
order country
order year
order ccode, after(country)
order cowc, after(ccode)
order e_regionpol, after(e_regiongeo)
order e_regionpol_6C, after(e_regionpol)
order v2x_regime_amb, after(e_area)
order v2x_regime, after(e_area)


** ensure better readability of variables
label var year "Time"
label var country "Country Name"
label var ccode "Country Code"
label var cowc "COW Country Code"
label var cow "COW"

label var v2x_libdem "Liberal Democracy Index"
label var e_p_polity "Polity Combined Score"
label var e_polity2 "Polity Revised Combined Score"

label var e_regiongeo "Region (Geographic)"
label var e_regionpol "Region (Politico-Geographic)"
label var e_regionpol_6C "Region (Politico-Geographic 6-category)"
label var e_area "Land area (in square kilometers)"

label var v2x_regime_amb "Regime Type (with categories for ambiguous cases)"

label var wb_gdp "GDP per capita (2020 US$)"
label var e_migdppc "GDP per capita (in 2011 US$)"
label var cow_pec "Primary Energy Consumption"
label var cow_tpop "Population, total (COW, thousands)"
label var wb_pop "Population, total (World Bank)"

label var e_total_resources_income_pc "Petroleum, coal, natural gas, and metals production per capita (thousands of 2007 dollars)"
rename e_total_resources_income_pc e_total_resources_pc
label var wb_resources "Total natural resources rents"

label var e_cow_exports "Exports (Total exports in 2014 US millions of US$)"
label var e_cow_imports "Imports (Total imports in 2014 US millions of US$)"
label var exp_us "Exports to the USA in 2012 US millions of dollars"
rename exp_us cow_exp_us
label var imp_us "Imports from the USA in 2012 US millions of dollars"
rename imp_us cow_imp_us

label var cow_milex "Military Expenditures"
label var cow_milper "Military Personnel (thousands)"

label var e_civil_war "Civil war"
label var e_miinterc "Armed conflict (internal)"
label var e_pt_coup "Coups d’etat"

label var v2x_clphy "Physical violence index"
label var v2caviol "Political violence"
label var v2cacamps "Political polarization"

label var treatment1 "Treatment (5yrs.)"
label var treatment1 "Treatment (5yrs.) adjusted"

label var alliance "Country is in an alliance with the USA in a given year"
rename alliance cow_alliance
label var sev_o_san "Severity of sanctions"
label var tar_dem_pa "Target used to be a democracy in the past"


** declare data to be panel data
xtset country year

** add numbers to count variables
numlabel, add

/* adjust inflation of trade and gdp data to 2020 US Dollar
- better comparability
- IHS-transformation (see section 3) largely depends on the magnitude of the values of the transformed variable (Aïhounton, Henningsen 2019)
Source: https://www.inflationtool.com/us-dollar/1990-to-present-value */

** transform e_migdppc (2011 US$) to 2020 US$
gen e_migdppc_c = e_migdppc*1.1724
label variable e_migdppc_c "GDP per capita (2020 US$)"

** transform e_total_resources_pc (thousands of 2007 US$) to 2020 US$
gen e_total_resources_pc_c = e_total_resources_pc*1.2734*1000
label variable e_total_resources_pc_c "Petroleum, coal, natural gas, and metals production per capita (2020 US$)"

** transform exp_us (2012 milions of US$) to 2020 US$
gen cow_exp_us_c = cow_exp_us*1.1387*1000000
label variable cow_exp_us_c "Exports to the USA (2020 US$)"

** transform imp_us (2012 millions of US$) to 2020 US$
gen cow_imp_us_c = cow_imp_us*1.1387*1000000
label variable cow_imp_us_c "Imports from the USA (2020 US$)"

** transform e_cow_exports (2014 millions of US$) to 2020 US$
gen e_cow_exports_c = e_cow_exports*1.1027*1000000
label variable e_cow_exports_c "Total exports (2020 US$)"

** transform e_cow_imports (2014 millions of US$) to 2020 US$
gen e_cow_imports_c = e_cow_imports*1.1027*1000000
label variable e_cow_imports_c "Total imports (2020 US$)"

** drop outdated variables
drop e_migdppc e_total_resources_pc cow_exp_us cow_imp_us e_cow_exports e_cow_imports

** reorder variables
order e_migdppc_c, after(v2x_regime_amb)
order e_total_resources_pc_c, after(wb_fdi)
order cow_exp_us_c, after(e_total_resources_pc_c)
order cow_imp_us_c, after(cow_exp_us_c)
order e_cow_exports_c, after(cow_imp_us_c)
order e_cow_imports_c, after(e_cow_exports_c)



** SECTION 2

***********************************
** Install user-written programs **
***********************************
ssc install mdesc // displays number and proportion of missing values
ssc install midiagplots // diagnostics after multiple imputation
ssc install mibeta // adds R-squared to linear regression output with multiply-imputed data
ssc install asdoc // creating and exporting tables
ssc install xtqptest // bias-corrected LM-based test for panel serial correlation
ssc install xttest3 // modified Wald statistic for groupwise heteroskedasticity in FE model
ssc install xtscc // Driscoll-Kraay SE regression


** Control distribution of continuous variables
qnorm v2x_libdem, name(var1)
qnorm e_migdppc_c, name(var2)
qnorm e_total_resources_pc_c, name(var3)
qnorm v2cacamps, name(var4)
graph combine var1 var2 var3 var4, col(2) row(2)
graph export qnorm1.pdf, replace

qnorm e_cow_exports_c, name(var5)
qnorm e_cow_imports_c, name(var6)
qnorm cow_exp_us_c, name(var7)
qnorm cow_imp_us_c, name(var8)
graph combine var5 var6 var7 var8, col(2) row(2)
graph export qnorm2.pdf, replace

graph drop _all


** To receive a distribution that follows more closely a normal distribution while not loosing observations with zero variables will be transformed using the inverse hyperbolic sine
* I do not transform the dependent variable because the distribution is not too bad and a transformation would make the interpretation of the treatment coefficient more complicated
gen ihs_e_migdppc_c = asinh(e_migdppc_c)
gen ihs_cow_exp_us_c = asinh(cow_exp_us_c)
gen ihs_cow_imp_us_c = asinh(cow_imp_us_c)
gen ihs_e_cow_exports_c = asinh(e_cow_exports_c)
gen ihs_e_cow_imports_c = asinh(e_cow_imports_c)
gen ihs_e_total_resources_pc_c = asinh(e_total_resources_pc_c)

label var ihs_e_migdppc_c "GDP per capita (2020 US$), asinh transformed"
label var ihs_cow_exp_us_c "Exports to the USA (2020 US$), asinh transformed"
label var ihs_cow_imp_us_c "Imports from the USA (2020 US$), asinh transformed"
label var ihs_e_cow_exports_c "Total exports (2020 US$), asinh transformed"
label var ihs_e_cow_imports_c "Total imports (2020 US$), asinh transformed"
label var ihs_e_total_resources_pc_c "Petroleum, coal, natural gas, and metals production per capita (2020 US$), asinh transformed"

** order variables
order ihs_e_migdppc_c, after(e_migdppc_c)
order ihs_e_total_resources_pc_c, after(e_total_resources_pc_c)
order ihs_cow_exp_us_c, after(cow_exp_us_c)
order ihs_cow_imp_us_c, after(cow_imp_us_c)
order ihs_e_cow_exports_c, after(e_cow_exports_c)
order ihs_e_cow_imports_c, after(e_cow_imports_c)


** Drop Kosovo, Montenegro and Serbia from the analysis to gain more instruments because the three countries only provide 3 resp. 5 yearly observations.
drop in 4264/4266
drop in 5278/5282
drop in 6901/6905


** Summary Statistics TABLE 1
bys treatment2: asdoc sum v2x_libdem e_migdppc_c e_cow_exports_c e_cow_imports_c cow_exp_us_c cow_imp_us_c e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa, stat(N mean sd) label save(baseline.doc) title(TABLE 1 Summary Statistics for the Main Variables Used in the Analysis)

sort country year


*************
** Testing **
*************

** Heteroskedasticity
** Modified Wald statistic for groupwise heteroskedasticity in the residuals of a fixed effect regression; H0 assumes homoskedasticity
xtreg v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year, fe
xttest3

** Serial Correlation
** Bias-corrected LM-based test for panel serial correlation; H0 assumes no serial correlation
qui xtreg v2x_libdem, fe
predict ue_resid, ue
xtqptest ue_resid, lags(1) // looks for autocorrelation up to one lag.
xtqptest ue_resid, order(1) // looks for autocorrelation of order 1.
drop ue_resid

** Multicollinearity
corr v2x_libdem treatment2 e_migdppc_c e_total_resources_pc_c cow_exp_us_c cow_imp_us_c e_cow_exports_c e_cow_imports_c v2cacamps cow_alliance tar_dem_pa

** Stationarity
* With a visual approach we can get a first idea if some of the variables follow a non-linear time trend

qui xtreg v2x_libdem, fe
predict res_lib, resid
tsline res_lib, name(lib_res)
tsline v2x_libdem, name(lib)
graph combine lib lib_res

qui xtreg ihs_e_migdppc_c, fe
predict res_gdp, resid
tsline res_gdp, name(gdp_res)
tsline ihs_e_migdppc_c, name(gdp)
graph combine gdp gdp_res

qui xtreg ihs_e_cow_exports_c, fe
predict res_exports, resid
tsline res_exports, name(exports_res)
tsline ihs_e_cow_exports_c, name(exports)
graph combine exports exports_res

qui xtreg ihs_e_cow_imports_c, fe
predict res_imports, resid
tsline res_imports, name(imports_res)
tsline ihs_e_cow_imports_c, name(imports)
graph combine imports imports_res

qui xtreg ihs_cow_exp_us_c, fe
predict res_exp_us, resid
tsline res_exp_us, name(exp_us_res)
tsline ihs_cow_exp_us_c, name(exp_us)
graph combine exp_us exp_us_res

qui xtreg ihs_cow_imp_us_c, fe
predict res_imp_us, resid
tsline res_imp_us, name(imp_us_res)
tsline ihs_cow_imp_us_c, name(imp_us)
graph combine imp_us imp_us_res

qui xtreg ihs_e_total_resources_pc_c, fe
predict res_ressources, resid
tsline res_ressources, name(ressources_res)
tsline ihs_e_total_resources_pc_c, name(ressources)
graph combine ressources ressources_res

qui xtreg v2cacamps, fe
predict res_v2cacamps, resid
tsline res_v2cacamps, name(v2cacamps_res)
tsline v2cacamps, name(v2cacamps)
graph combine v2cacamps v2cacamps_res


drop res_lib res_gdp res_exports res_imports res_exp_us res_imp_us res_ressources res_v2cacamps
graph drop _all


** as expected, the macroeconomic coefficients GDP and imports and exports seem to follow, on average, a non-stationary process which is still visible after the transformation of the variables. We can investigate this further by conducting a unit root test.

** Unit Root tests
** Among the various tests Im-Peasaran-Shin (IMP) and Fisher-type allow unbalanced panel data but the normality of the Z-t-tilde-bar requires at least 10 observations per panel with unbalanced data in IMP to provide p-values which would, due to the heterogenous structure, discard even more panels in the sample. I therefore use the Fisher-type Augmented-Dickey-Fuller Test which accounts for the panel-specific structure and allows T going to infinity and N to be finite or infinite.
* Drift accounts for the potential drift structure of the variable while demean controls for cross-sectional dependence.
* As mentioned in the Stata manual: "Choi's (2001) simulation results suggest that the inverse normal Z statistic offers the best trade-off between size and power", I therefore focus on this p-value specifically

** Example code for IPS and Fisher-type Unit Root tests. Replace variable name to test for other variable.

** Fisher-type Augmented Dickey Fuller Panel Unit Root Test
** Testing for random walk with drift
xtunitroot fisher e_migdppc_c, dfuller drift lags(1) demean
xtunitroot fisher d.e_migdppc_c, dfuller drift lags(1) demean
tsline d.e_migdppc_c

xtunitroot fisher ihs_e_migdppc_c, dfuller drift lags(1) demean
xtunitroot fisher d.ihs_e_migdppc_c, dfuller drift lags(1) demean
tsline d.ihs_e_migdppc_c

** Testing for deterministic trend
xtunitroot fisher e_migdppc_c, dfuller trend lags(1) demean
qui xtreg e_migdppc_c year
predict r_migdppc_c, resid
xtunitroot fisher r_migdppc_c, dfuller trend lags(1) demean
tsline r_migdppc_c
drop r_migdppc_c

xtunitroot fisher ihs_e_migdppc_c, dfuller trend lags(1) demean
qui xtreg ihs_e_migdppc_c year
predict r_ihs_migdppc_c, resid
xtunitroot fisher r_ihs_migdppc_c, dfuller trend lags(1) demean
tsline r_ihs_migdppc_c
drop r_ihs_migdppc_c


** Fisher-type Phillips-Perron Panel Unit Root Test
** Testing for random walk
xtunitroot fisher e_migdppc_c, pperron lags(1) demean
xtunitroot fisher d.e_migdppc_c, pperron lags(1) demean
tsline d.e_migdppc_c

xtunitroot fisher ihs_e_migdppc_c, dfuller drift lags(1) demean
xtunitroot fisher d.ihs_e_migdppc_c, dfuller drift lags(1) demean
tsline d.ihs_e_migdppc_c

** Testing for deterministic trend
xtunitroot fisher e_migdppc_c, pperron trend lags(1) demean
qui xtreg e_migdppc_c year
predict r_migdppc_c, resid
xtunitroot fisher r_migdppc_c, pperron trend lags(1) demean
tsline r_migdppc_c
drop r_migdppc_c

xtunitroot fisher ihs_e_migdppc_c, pperron trend lags(1) demean
qui xtreg ihs_e_migdppc_c year
predict r_ihs_migdppc_c, resid
xtunitroot fisher r_ihs_migdppc_c, pperron trend lags(1) demean
tsline r_ihs_migdppc_c
drop r_ihs_migdppc_c


** Im-Pesaran-Shin Panel Unit Root Test
** Testing for random walk
xtunitroot ips e_migdppc_c, lags(1) demean
xtunitroot ips d.e_migdppc_c, lags(1) demean
tsline d.e_migdppc_c

xtunitroot ips ihs_e_migdppc_c, lags(1) demean
xtunitroot d.ihs_e_migdppc_c, lags(1) demean
tsline d.ihs_e_migdppc_c

** Testing for deterministic trend
xtunitroot ips e_migdppc_c, trend lags(1) demean
qui xtreg e_migdppc_c year
predict r_migdppc_c, resid
xtunitroot ips r_migdppc_c, trend lags(1) demean
tsline r_migdppc_c
drop r_migdppc_c

xtunitroot ips ihs_e_migdppc_c, trend lags(1) demean
qui xtreg ihs_e_migdppc_c year
predict r_ihs_migdppc_c, resid
xtunitroot ips r_ihs_migdppc_c, trend lags(1) demean
tsline r_ihs_migdppc_c
drop r_ihs_migdppc_c



** SECTION 3 ** Linear Regression ** TABLE 3 - 5

*************************
** Analysis of Model 1 **
*************************

** Pooled OLS
reg v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa

estimates table, star(.05 .01 .001)


*************************
** Analysis of Model 2 **
*************************

** Two-way Fixed effects with cluster robust SE
xtreg v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year, fe cluster(country)

** Show significance level
estimates table, star(.05 .01 .001)

** Display adjusted R-squared
display `e(r2_a)'


*************************
** Analysis of Model 3 **
*************************

** Two-way Fixed effects with cluster robust SE and a lagged dependent variable
xtreg v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa l.v2x_libdem i.year, fe cluster(country)

estimates table, star(.05 .01 .001)
display `e(r2_a)'


*************************
** Analysis of Model 4 **
*************************

* generate the within estimator to use with the prais command
egen v2x_libdem_m = mean(v2x_libdem), by(country)
egen treatment2_m = mean(treatment2), by(country)
egen ihs_e_migdppc_c_m = mean(ihs_e_migdppc_c), by(country)
egen ihs_e_cow_exports_c_m = mean(ihs_e_cow_exports_c), by(country)
egen ihs_e_cow_imports_c_m = mean(ihs_e_cow_imports_c), by(country)
egen ihs_cow_exp_us_c_m = mean(ihs_cow_exp_us_c), by(country)
egen ihs_cow_imp_us_c_m = mean(ihs_cow_imp_us_c), by(country)
egen ihs_e_total_resources_pc_c_m = mean(ihs_e_total_resources_pc_c), by(country)
egen v2cacamps_m = mean(v2cacamps), by(country)
egen cow_alliance_m = mean(cow_alliance), by(country)
egen tar_dem_pa_m = mean(tar_dem_pa), by(country)

gen v2x_libdem_fe = v2x_libdem - v2x_libdem_m
gen treatment2_fe = treatment2 - treatment2_m
gen ihs_e_migdppc_c_fe = ihs_e_migdppc_c - ihs_e_migdppc_c_m
gen ihs_e_cow_exports_c_fe = ihs_e_cow_exports_c - ihs_e_cow_exports_c_m
gen ihs_e_cow_imports_c_fe = ihs_e_cow_imports_c - ihs_e_cow_imports_c_m
gen ihs_cow_exp_us_c_fe = ihs_cow_exp_us_c - ihs_cow_exp_us_c_m
gen ihs_cow_imp_us_c_fe = ihs_cow_imp_us_c - ihs_cow_imp_us_c_m
gen ihs_e_total_resources_pc_c_fe = ihs_e_total_resources_pc_c - ihs_e_total_resources_pc_c_m
gen v2cacamps_fe = v2cacamps - v2cacamps_m
gen cow_alliance_fe = cow_alliance - cow_alliance_m
gen tar_dem_pa_fe = tar_dem_pa - tar_dem_pa_m

label var v2x_libdem_fe "Liberal Democracy Index FE-estimator"
label var treatment2_fe "Treatment (5yrs.) adjusted FE-estimator"
label var ihs_e_migdppc_c_fe "GDP per capita (2020 US$) ihs-transformed, FE-estimator"
label var ihs_e_cow_exports_c_fe "Total exports (2020 US$) ihs-transformed, FE-estimator"
label var ihs_e_cow_imports_c_fe "Imports from the USA (2020 US$) ihs-transformed, FE-estimator"
label var ihs_cow_exp_us_c_fe "Exports to the USA (2020 US$) ihs-transformed, FE-estimator"
label var ihs_cow_imp_us_c_fe "Imports from the USA (2020 US$) ihs-transformed, FE-estimator"
label var ihs_e_total_resources_pc_c_fe "Petroleum, coal, natural gas, and metals production per capita (2020 US$) ihs-transformed, FE-estimator"
label var v2cacamps_fe "Political polarization, FE-estimator"
label var cow_alliance_fe "Country is in an alliance with the USA in a given year, FE-estimator"
label var tar_dem_pa_fe "Target used to be a democracy in the past, FE-estimator"

** drop outdated variables
drop v2x_libdem_m treatment2_m ihs_e_migdppc_c_m ihs_e_cow_exports_c_m ihs_e_cow_imports_c_m ihs_cow_exp_us_c_m ihs_cow_imp_us_c_m ihs_e_total_resources_pc_c_m v2cacamps_m cow_alliance_m tar_dem_pa_m

** reorder variables
order v2x_libdem_fe, after(v2x_regime)
order treatment2_fe, after(treatment2)
order ihs_e_migdppc_c_fe, after(e_migdppc_c)
order ihs_e_cow_exports_c_fe, after(e_cow_exports_c)
order ihs_e_cow_imports_c_fe, after(e_cow_imports_c)
order ihs_cow_exp_us_c_fe, after(cow_exp_us_c)
order ihs_cow_imp_us_c_fe, after(cow_imp_us_c)
order ihs_e_total_resources_pc_c_fe, after(e_total_resources_pc_c)
order v2cacamps_fe, after(v2cacamps)
order cow_alliance_fe, after(cow_alliance)
order tar_dem_pa_fe, after(tar_dem_pa)

** Two-way Fixed effects with Prais-Winsten transformation and cluster robust SE
prais v2x_libdem_fe treatment2_fe ihs_e_migdppc_c_fe ihs_e_cow_exports_c_fe ihs_e_cow_imports_c_fe ihs_cow_exp_us_c_fe ihs_cow_imp_us_c_fe ihs_e_total_resources_pc_c_fe v2cacamps_fe cow_alliance_fe tar_dem_pa_fe, vce(cluster country)

estimates table, star(.05 .01 .001)
display `e(r2_a)'


*************************
** Analysis of Model 5 **
*************************

** Anderson-Hsiao IV Estimator
xtivreg v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year (l.v2x_libdem=l2.v2x_libdem), fd vce(cluster country)

estimates table, star(.05 .01 .001)


*************************
** Analysis of Model 6 **
*************************

** Regression with Driscoll-Kraay SE and period dummies
* Instead of the otherwise popular Newey-West SE Driscoll-Kraay SE can handle heterogenous panels
xtscc v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year, fe

estimates table, star(.05 .01 .001)



** SECTION 2 ** Linear Regression ** Controlling for equation balance with first differences (except Model one which is a basic first difference estimator) ** TABLE 2

*************************
** Analysis of Model 7 **
*************************

** First Difference Estimator with period dummies
reg d.(v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa) i.year, cluster(country)

estimates table, star(.05 .01 .001)


*************************
** Analysis of Model 8 **
*************************

** Two-way Fixed effects with cluster robust SE and first differences
xtreg v2x_libdem treatment2 d.(ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_imp_us_c ihs_cow_exp_us_c) ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year, fe cluster(country)

estimates table, star(.05 .01 .001)
display `e(r2_a)'


*************************
** Analysis of Model 9 **
*************************

** Two-way Fixed effects with cluster robust SE, a lagged dependent variable and first differences
xtreg v2x_libdem treatment2 d.(ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c) ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa l.v2x_libdem i.year, fe cluster(country)

estimates table, star(.05 .01 .001)
display `e(r2_a)'


**************************
** Analysis of Model 10 **
**************************

** Regression with Driscoll-Kraay SE, period dummies and first differences

xtscc v2x_libdem treatment2 d.(ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c) ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa i.year, fe

estimates table, star(.05 .01 .001)



** SECTION 4 ** Linear Regression with imputed data TABLE 6

** Show distribution of missing values - TABLE 2
preserve
drop if treatment2==.

mdesc v2x_libdem treatment2 e_migdppc_c e_cow_exports_c e_cow_imports_c cow_exp_us_c cow_imp_us_c e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa

bys treatment2: mdesc v2x_libdem treatment2 e_migdppc_c e_cow_exports_c e_cow_imports_c cow_exp_us_c cow_imp_us_c e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa

restore


** Multiple Imputation

** MI is designed for normally distributed variables (Lee, Carlin 2010) which is taken care of by the IHS-transformation.

** It is important to include all regressors from the model and especially the regressors that predict the missing data. MI has problems though with regressors not being imputed but included in the estimation that contain missing values. In this case this are the dependent variable and the adjusted treatment. I therefore drop the few observations with missing values on the dependent variable (+ 4 additional observations to avoid gaps in the dataset). I also use the unadjusted treatment as a regressor and exchange it with the adjusted treatment in the estimation.
drop in 456/486
drop in 1342/1347
drop in 5304/5322

** Indicating how the additional imputations should be stored
xtset, clear
mi set flong
mi xtset country year

** "mi register imputed" specifies the variables to be imputed in the procedure. "mi register regular" specifies the variables that should not be imputed (either because they have no missing values or because there is no need).
mi register imputed ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps
mi register regular v2x_libdem treatment1 cow_alliance tar_dem_pa


/* mi impute chained" specifies that the variable with the fewest missing values is imputed first followed by the variable 	with the next fewest missing values and so on.
Regress is specified for continuous variables, logit for binary variables.
Equal separates imputed and regular variables as specified above.
The "add" option specifies the number of datasets to be imputed. I use 5 imputations following Schafer (1999) who states that the use of more than 5 to 10 imputations offers little or no practical benefit.
The "rseed()" option is used for results reproducibility.
Data is assumed to be MAR */

** sequential imputation using chained equations
mi impute chained (reg) ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps = v2x_libdem treatment1 cow_alliance tar_dem_pa, add(5) rseed(1234) replace

** Controlling the fit of the imputed data
midiagplots ihs_e_migdppc_c, m(1/5) combine
midiagplots ihs_e_cow_exports_c, m(1/5) combine
midiagplots ihs_e_cow_imports_c , m(1/5) combine
midiagplots ihs_cow_exp_us_c, m(1/5) combine
midiagplots ihs_cow_imp_us_c, m(1/5) combine
midiagplots ihs_e_total_resources_pc_c, m(1/5) combine


** Imputed Data models are estimated using the inverse hyperbolic sine transformed variables as recommended by von Hippel (2009) and as the particular interest lies in the coefficient of the treatment only. ** Table 4

**************************
** Analysis of Model 11 **
**************************

** First Difference Estimator with period dummies and imputed data
mibeta d.(v2x_libdem treatment2 ihs_e_migdppc_c ihs_e_cow_exports_c ihs_e_cow_imports_c ihs_cow_exp_us_c ihs_cow_imp_us_c ihs_e_total_resources_pc_c v2cacamps cow_alliance tar_dem_pa) i.year, vce(cluster country) miopts(post)

* collect information of the analysis stored by post option
collect get e(B_mi) e(V_mi)
estimates table, star(.05 .01 .001)
display `e(r2_a)'


** The user-written mibeta command only works with the regress command. Therefore, the within-estimator for the fixed-effects regression needs to be computed by hand again.

egen v2x_libdem_m = mean(v2x_libdem), by(country)
egen treatment2_m = mean(treatment2), by(country)
egen ihs_e_migdppc_c_m = mean(ihs_e_migdppc_c), by(country)
egen ihs_e_cow_exports_c_m = mean(ihs_e_cow_exports_c), by(country)
egen ihs_e_cow_imports_c_m = mean(ihs_e_cow_imports_c), by(country)
egen ihs_cow_exp_us_c_m = mean(ihs_cow_exp_us_c), by(country)
egen ihs_cow_imp_us_c_m = mean(ihs_cow_imp_us_c), by(country)
egen ihs_e_total_resources_c_m = mean(ihs_e_total_resources_pc_c), by(country)
egen v2cacamps_m = mean(v2cacamps), by(country)
egen cow_alliance_m = mean(cow_alliance), by(country)
egen tar_dem_pa_m = mean(tar_dem_pa), by(country)

gen v2x_libdem_fe_mi = v2x_libdem - v2x_libdem_m
gen treatment2_fe_mi = treatment2 - treatment2_m
gen ihs_e_migdppc_c_fe_mi = ihs_e_migdppc_c - ihs_e_migdppc_c_m
gen ihs_e_cow_exports_c_fe_mi = ihs_e_cow_exports_c - ihs_e_cow_exports_c_m
gen ihs_e_cow_imports_c_fe_mi = ihs_e_cow_imports_c - ihs_e_cow_imports_c_m
gen ihs_cow_exp_us_c_fe_mi = ihs_cow_exp_us_c - ihs_cow_exp_us_c_m
gen ihs_cow_imp_us_c_fe_mi = ihs_cow_imp_us_c - ihs_cow_imp_us_c_m
gen ihs_e_total_resources_c_fe_mi = ihs_e_total_resources_pc_c - ihs_e_total_resources_c_m
gen v2cacamps_fe_mi = v2cacamps - v2cacamps_m
gen cow_alliance_fe_mi = cow_alliance - cow_alliance_m
gen tar_dem_pa_fe_mi = tar_dem_pa - tar_dem_pa_m

label var v2x_libdem_fe_mi "Liberal Democracy Index FE-estimator MI"
label var treatment2_fe_mi "Treatment (5yrs.) adjusted FE-estimator MI"
label var ihs_e_migdppc_c_fe_mi "GDP per capita (2020 US$) ihs-transformed, FE-estimator MI"
label var ihs_e_cow_exports_c_fe_mi "Total exports (2020 US$) ihs-transformed, FE-estimator MI"
label var ihs_e_cow_imports_c_fe_mi "Imports from the USA (2020 US$) ihs-transformed, FE-estimator MI"
label var ihs_cow_exp_us_c_fe_mi "Exports to the USA (2020 US$) ihs-transformed, FE-estimator MI"
label var ihs_cow_imp_us_c_fe_mi "Imports from the USA (2020 US$) ihs-transformed, FE-estimator MI"
label var ihs_e_total_resources_c_fe_mi "Petroleum, coal, natural gas, and metals production per capita (2020 US$) ihs-transformed, FE-estimator MI"
label var v2cacamps_fe_mi "Political polarization, FE-estimator MI"
label var cow_alliance_fe_mi "Country is in an alliance with the USA in a given year, FE-estimator MI"
label var tar_dem_pa_fe_mi "Target used to be a democracy in the past, FE-estimator MI"

** drop outdated variables
drop v2x_libdem_m treatment2_m ihs_e_migdppc_c_m ihs_e_cow_exports_c_m ihs_e_cow_imports_c_m ihs_cow_exp_us_c_m ihs_cow_imp_us_c_m ihs_e_total_resources_c_m v2cacamps_m cow_alliance_m tar_dem_pa_m


**************************
** Analysis of Model 12 **
**************************

** Two-way fixed effects with cluster robust standard errors, imputed data and first differences
mibeta v2x_libdem_fe_mi treatment2_fe_mi d.(ihs_e_migdppc_c_fe_mi ihs_e_cow_exports_c_fe_mi ihs_e_cow_imports_c_fe_mi ihs_cow_exp_us_c_fe_mi ihs_cow_imp_us_c_fe_mi) ihs_e_total_resources_c_fe_mi v2cacamps_fe_mi cow_alliance_fe_mi tar_dem_pa_fe_mi i.year, vce(cluster country) miopts(post)

* collect information of the analysis stored by post option
collect get e(B_mi) e(V_mi)
estimates table, star(.05 .01 .001)


**************************
** Analysis of Model 13 **
**************************

** Two-way fixed effects with cluster robust SE, a lagged dependent variable, imputed data and first differences.
mibeta v2x_libdem_fe_mi treatment2_fe_mi d.(ihs_e_migdppc_c_fe_mi ihs_e_cow_exports_c_fe_mi ihs_e_cow_imports_c_fe_mi ihs_cow_exp_us_c_fe_mi ihs_cow_imp_us_c_fe_mi) ihs_e_total_resources_c_fe_mi v2cacamps_fe_mi cow_alliance_fe_mi tar_dem_pa_fe_mi i.year l.v2x_libdem_fe_mi, vce(cluster country) miopts(post)

collect get e(B_mi) e(V_mi)
estimates table, star(.05 .01 .001)


**************************
** Analysis of Model 14 **
**************************

** Two-way fixed effects with cluster robust standard errors and imputed data.
* Post stores the information gained by the analysis to built a table afterwards
mibeta v2x_libdem_fe_mi treatment2_fe_mi ihs_e_migdppc_c_fe_mi ihs_e_cow_exports_c_fe_mi ihs_e_cow_imports_c_fe_mi ihs_cow_exp_us_c_fe_mi ihs_cow_imp_us_c_fe_mi ihs_e_total_resources_c_fe_mi v2cacamps_fe_mi cow_alliance_fe_mi tar_dem_pa_fe_mi i.year, vce(cluster country) miopts(post)

collect get e(B_mi) e(V_mi)
estimates table, star(.05 .01 .001)


**************************
** Analysis of Model 15 **
**************************

** Two-way fixed effects with cluster robust SE, a lagged dependent variable and imputed data.
mibeta v2x_libdem_fe_mi treatment2_fe_mi ihs_e_migdppc_c_fe_mi ihs_e_cow_exports_c_fe_mi ihs_e_cow_imports_c_fe_mi ihs_cow_exp_us_c_fe_mi ihs_cow_imp_us_c_fe_mi ihs_e_total_resources_c_fe_mi v2cacamps_fe_mi cow_alliance_fe_mi tar_dem_pa_fe_mi l.v2x_libdem_fe_mi i.year, vce(cluster country) miopts(post)

collect get e(B_mi) e(V_mi)
estimates table, star(.05 .01 .001)



/* Literature

Aïhounton, Ghislain B. D., & Arne Henningsen. 2019. "Units of Measurement and the Inverse Hyperbolic Sine Transformation." IFRO Working Paper 2019/10.

Choi, In. 2001. "Unit root tests for panel data." Journal of International Money and Finance 20: 249–272.

Lee, Katherine J., & John B. Carlin. 2010. "Multiple Imputation for Missing Data: Fully Conditional Specification Versus Multivariate Normal Imputation." American Journal of Epidemiology 171 (5): 624-632.

Schafer, Joseph L. 1999. "Multiple Imputation: a primer." Statistical Methods in Medical Research 8 (1): 3-15.

Von Hippel, Paul T. 2009. "How to Impute Interactions, Squares, and Other Transformed Variables." Sociological Methodology 39 (1): 265-291.

*/
