clear all

use "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States\Master_States_Data.dta"

rename state_abbrev state
statastates, abbreviation(state)
drop _merge
tsset state_fips year

merge 1:m state_fips year using "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Health Status\Health_Status_Final.dta" 

drop if year == .
drop state_abbrev
rename state state_abbrev
rename state_name state
drop _merge

drop if year < 2005

save "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Master_States_Data_Final.dta"

merge 1:m state_fips state_abbrev using "C:\Users\12148\OneDrive\Desktop\Marijuana Event Study\Data\Marijuana_Event_Study_Final.dta"