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
* 	 High Default rates if N > 10
*  	 High Mortality rates if N > 10
* 	 Missing Exits

* Stock Reporting Errors
*	 Errors in calculations 		25%
* 		Errors in calculations (>1 carton) or neg starting balance	- Number of errors in past 8 weeks
* 		Reporting in decimal points or thousands of cartons			- Number of errors in past 8 weeks
* 		Excessive or minimal stocks use per case					- Number of errors in past 8 weeks

* There is no punishment for STOCK-OUTS

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

keep SiteID Type ProMiss StoMiss complete_reporting state state_code lga lga_code
save "C:\TEMP\Working\missrepttemp.dta", replace

* MERGE IN MISSING REPORTS DATA
use temp, clear
merge m:m SiteID Type using "C:\TEMP\Working\missrepttemp.dta"
* missing merges
drop _merge
* save temp.dta, replace

* Program Reporting Errors  		25%

* 	 Excess number of TOTAL AT START OF THE WEEK (> 300 children)
* only one error reported per 8 weeks
recode Beg (min/299=0) (300/max=1), gen(excess_beg)
replace excess_beg=. if current8!=1 & WeekNum != most_recent_report
tab excess_beg

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
gen ratio_amar_beg_temp = ratio_amar_beg
replace ratio_amar_beg =. if ratio_amar_beg>1 | ratio_amar_beg==0
* 0 is no admission
* 1 is equal admissions to under Rx. 
replace ratio_amar_beg =. if current8!=1 
* median of ratio_amar_beg
sum ratio_amar_beg, d
* include all extreme values with gentle correction (from 0 to 1)
*replace ratio_amar_beg = ratio_amar_beg_temp if ratio_amar_beg_temp==0
*replace ratio_amar_beg = 1 if ratio_amar_beg_temp>1
* difference from median
gen diff_ratio_amar_beg = abs(ratio_amar_beg-r(p50))
hist diff_ratio_amar_beg

* Max difference from median (from 0 to 1) 
egen max_diff_ratio_amar_beg = max(diff_ratio_amar_beg)
* Score for Ratio of new admissions to number of children in charge
gen amar_beg_score = diff_ratio_amar_beg / max_diff_ratio_amar_beg
*hist adm_urx_score 

replace Amar =. if Amar> 300
replace Amar =. if  equal_amar_beg ==1
scatter Amar Beg if excess_beg==0


mean ratio_amar_beg, over(lga)




* 	 High Default rates if N > 10
*  	 High Mortality rates if N > 10
* 	 Missing Exits























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
