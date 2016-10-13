* CMAM program reporting scores. 

set more off
cap log close
cd C:\TEMP\Working\


* Use the CMAM database with all viable program and stock reports included
use CMAM_delete.dta, clear


* Quality Reporting Score
* at implementation site level ( no supervision level data ) 

* Complete reporting for Program and Stocks			40%
* Timely reporting									10%

* Program Reporting Errors  		25%
* 	 Ratio of new admissions to number of children in charge - Average Minimum Maximum of Admissions and In-Charge
* 	 Missing Exits

* Stock Reporting Errors
*	 Errors in calculations 		25%
* 		Errors in calculations (>1 carton) or neg starting balance	- Number of errors in past 8 weeks
* 		Reporting in decimal points or thousands of cartons			- Number of errors in past 8 weeks
* 		Excessive or minimal stocks use per case					- Number of errors in past 8 weeks

* There is no penalty for High Default rates and High Mortality rates but no punishments
* There is no penalty for STOCK-OUTS

* First provide reporting on current conditions
* Second provide data quality score on data from last eight weeks - need to provide older scores to show if improving or not. 
* keep a database of older data quality scores to show improvement or deterioration over time.

****** DATA CLEANING *********
* drop Tobi, Assaye and Elfriede
drop if URN == "+2347064019648"
drop if URN == "+2348067418765"
drop if URN == "+2348035351744"

* Analysis only for OTP and SCs.  Drop all supervision staff
drop if SiteID <101110001

* Week 22 of 2016 was the first week that we expected valid data to be sent.
drop if WeekNum < 22 

* Find out what is answer to this SiteID error
replace SiteID = 1731110034 if SiteID== 173110034

* 52 entries with no SiteName, state_code, lga_code
* This is a problem in IMAM Weekly Analysis

sort SiteID
format SiteID %12.0f
tab Type, m 

* Double check that program and stock entries by LGA personnel are coming through. 

destring lga_code, replace
save temp.dta, replace

gen current8 = 1 if WeekNum >=(CurrWeekNum - 8) & WeekNum <=(CurrWeekNum)
tab WeekNum current8, m 

bysort SiteID: egen most_recent_report = max(WeekNum)
tab most_recent_report, m 

sort SiteID Type WeekNum
save temp, replace

********************************
* INCLUDE MISSING REPORTS DATA
********************************
* enter the number of missing reports for the past 8 weeks
* the database missingrepttot.sav - contains one line for each person - there are more than one reports per site. 
* the data are only for the current week. 
* merge by SiteID and Type
* these data are produced by running IMAM Weekly Analysis
use "C:\TEMP\Working\missingrepttot.dta", clear
format SiteID %12.0f
destring lga_code, replace
cap drop _merge

* Data Cleaning on missing reports data. 
sort SiteID Type 

* Analysis only for OTP and SCs.  Drop all supervision staff
drop if SiteID <101110001

* drop Tobi, Assaye and Elfriede
drop if URN == "+2347064019648"
drop if URN == "+2348067418765"
drop if URN == "+2348035351744"

egen count_of_site=tag(SiteID Type)
order SiteID Type count_of_site
* Delete duplicates of sites
drop if count_of_site !=1

* Complete Reporting 
* ProRepTot  = number of complete program reports
tab ProReptTot, m
tab StoReptTot, m

gen comp_score = (16-(ProReptTot+StoReptTot))/16
* must subtract this % from the total score. 
gen complete_reporting = 100 - comp_score * 100
tab complete_reporting, m
table state, c(mean complete_reporting)

* List all sites with complete reporting < 80%
*list state lga SiteName complete_reporting ProMiss StoMiss if complete_reporting<80,abb(5) noobs 

keep SiteID Type ProMiss StoMiss complete_reporting comp_score state state_code lga lga_code
save "C:\TEMP\Working\missrepttemp.dta", replace

* MERGE IN MISSING REPORTS DATA
use temp, clear
merge m:m SiteID Type using "C:\TEMP\Working\missrepttemp.dta"
* missing merges
drop _merge
* save temp.dta, replace


* Program Reporting Errors  		25%

* 	 Excess number of TOTAL AT START OF THE WEEK (75% percentile of Beg = 233 children)
* only one error reported per 8 weeks
sum Beg if WeekNum == most_recent_report & current8==1, d
local seventyfive = r(p75)
recode Beg (`seventyfive'/max=1) (else=0), gen(excess_beg)
replace excess_beg=. if WeekNum != most_recent_report
replace excess_beg=. if current8!=1
* Should only have one report per site. 
tab excess_beg
gen diff_excess_beg = abs(Beg - `seventyfive')
egen max_diff_excess_beg = max(diff_excess_beg)
* Score for Ratio of new admissions to number of children in charge
* penalize everyone over the 75th percentile
gen excess_beg_score = 0.5 + ((diff_excess_beg / max_diff_excess_beg)/2)
hist excess_beg_score 


* 	Percent of sites with TOTAL AT START OF THE WEEK > 300 children - Unlikely
gsort -Beg
list state lga WeekNum SiteName Amar Beg if excess_beg==1 ,abb(5) noobs 

* 	Error - Sites that report New Admissions = Total Start of the Week
* all errors over past 8 weeks reported
gen equal_amar_beg = 1 if Amar==Beg & Amar>10 & Amar!=. & current8==1 
tab excess_beg
list state lga WeekNum SiteName Amar Beg if equal_amar_beg ==1 ,abb(5) noobs 

* 	 Ratio of new admissions to number of children in charge - Average Minimum Maximum of Admissions and In-Charge
* all errors over past 8 weeks reported
* Calculate normal ratio
gen ratio_amar_beg = Amar / Beg 
* 0 is no admission
* 1 is equal admissions to under Rx. 
* median of ratio_amar_beg
sum ratio_amar_beg if ratio_amar_beg<1 & ratio_amar_beg!=0 & current8==1 , d
* include all extreme values with gentle correction (set all from 0 to 1)
* Max difference from median (from 0 to 1) 
replace ratio_amar_beg = 1 if ratio_amar_beg>1
* difference from median
gen diff_ratio_amar_beg = abs(ratio_amar_beg-r(p50))
egen max_diff_ratio_amar_beg = max(diff_ratio_amar_beg)
* Score for Ratio of new admissions to number of children in charge
gen amar_beg_score = diff_ratio_amar_beg / max_diff_ratio_amar_beg
hist amar_beg_score 



* Missing Exits (over 8 weeks)
* Atot = Total Admissions to program
* Cin = Total entries to the facility
gen Cin = Amar + Tin
* End = Total end of the week in program
* Cout = Total exits from the facility
gen Cout= Dcur + Dead + Defu + Dmed + Tout
sort SiteID Type WeekNum
* calculate cumulative admissions and exits
by SiteID : egen tot_cin=total(Cin)
by SiteID : egen tot_cout=total(Cout)
gen diff_in_out = tot_cin - tot_cout
replace diff_in_out =. if WeekNum != most_recent_report
* How to account for increasing or decreasing caseloads - Take median of program 
* Better would be to take median of state
sum diff_in_out, d
gen median_in_out = r(p50)
gen adj_diff_in_out = abs(diff_in_out - median_in_out)
* Penalize all the maximum if the diff is more than 300
replace adj_diff_in_out = 250 if adj_diff_in_out >250 & diff_in_out!=.
egen max_diff_in_out = max(adj_diff_in_out)
gen in_out_score = adj_diff_in_out / max_diff_in_out
scatter diff_in_out in_out_score 


sort SiteID Type WeekNum 
*order SiteID Type WeekNum Beg Cin Cout tot_cin tot_cout diff_in_out adj_diff_in_out max_diff_in_out in_out_score


* Errors between Total Exits preceding week and TOTAL START OF THE WEEK. 
* Over the past 8 weeks
gen cout_lastweek = Cout[_n-1] if SiteID == SiteID[_n-1]
gen diff_lastweek = abs(Beg - cout_lastweek)
replace diff_lastweek=. if current8!=1
tab diff_lastweek

*order SiteID Type WeekNum Beg cout_lastweek diff_lastweek







gen CMAM_score = 100 - (comp_score * 40) - (excess_beg_score*10) - (equal_amar_beg * 5) - (amar_beg_score * 10)  
format CMAM_score %8.0f
sort CMAM_score
table lga, c(mean CMAM_score)


replace Amar =. if Amar> 300
replace Amar =. if  equal_amar_beg ==1
scatter Amar Beg if excess_beg==0

























* REPORT 

cap log

* Complete Reporting
* Listing of all sites with complete reporting < 80%
* add varnames and titles every page
list state lga SiteName complete_reporting ProMiss StoMiss if complete_reporting<80,abb(5) noobs 












End of File

* Calculate the average weight of a child with MUAC < 115. 
* using only data from Northern Nigeria - North East and North West
* Average weight of SAM child is 4.4 kg
* This is 10 sachets a week.  
use "D:\1 RobertWork\1 Country Work\Nigeria\Nutrition Surveys\2015 National Nutrition and Health Survey\Data\2015NNHS_Child_Final.dta", clear
encode zone, gen(zone_id)
tab zone_id, m
keep if zone_id ==2 | zone_id ==3
gen SAM=1 if chmuac<115 
svyset cluster
svy:  mean chwt if SAM==1
hist chwt, discrete by(SAM)
