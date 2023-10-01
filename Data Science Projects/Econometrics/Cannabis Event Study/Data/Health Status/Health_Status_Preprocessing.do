*** Afif Mazhar ***
**** 08/28/2023 ****
***** Health Status Data Pre-Processing *****

* convert csv to dta

import delimited "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Percent of adults with fair or poor health status by Total (2005 to 2017).csv"
save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2005_to_2017.dta"

import delimited "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Percent of adults with fair or poor health status by Total (2017 to 2021).csv"
save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2017_to_2021.dta"

* import dta file and add state code

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2005_to_2017.dta"
drop datatype moe
rename location state
rename timeframe year
rename data health_status
rename fips state_code
save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2005_to_2017.dta", replace

clear all

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2017_to_2021.dta"
drop datatype moe
rename location state
rename timeframe year
rename data health_status
rename fips state_code
save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2017_to_2021.dta", replace


append using "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_2005_to_2017.dta"
bysort state year (health_status): keep if _n == _N // removes duplicate observations for 2017

* add state fips and state abbreviation for merging

ssc install statastates, replace
statastates, name(state)
drop _merge
drop state_code
drop if year ==.


save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_Final.dta", replace