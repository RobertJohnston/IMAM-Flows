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
* 		Excessive or minimal RUTF Sachets use per case				- Number of errors in past 8 weeks

* There is no penalty for High Default rates and High Mortality rates 
* There is no penalty for STOCK-OUTS

* First provide reporting on current conditions
* Second provide data quality score on data from last eight weeks - need to provide older scores to show if improving or not. 
* keep a database of older data quality scores to show improvement or deterioration over time.

****** DATA CLEANING *********
gen one=1
* drop Tobi, Assaye and Elfriede
drop if URN == "+2347064019648"
drop if URN == "+2348067418765"
drop if URN == "+2348035351744"

* Analysis only for OTP and SCs.  Drop all supervision staff
drop if SiteID <101110001
drop if SiteID== 351511007
drop if SiteID== 301110001

drop if WeekNum==.

* Week 22 of 2016 was the first week that we expected valid data to be sent.
drop if WeekNum < 22 
drop if WeekNum > CurrWeekNum

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

bysort SiteID Type: egen most_recent_report = max(WeekNum)
tab most_recent_report, m 

sort SiteID Type WeekNum
save temp, replace

gen lga_state = lga + " - " + state
* TEMPORARILY
drop if lga_state ==" - "
sort SiteID Type
tab lga_state, m 

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

* Analysis only for OTP and SCs.  Drop all supervision staff
drop if SiteID <101110002
drop if SiteID== 351511007
drop if SiteID== 301110001

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

* Delete all reports from the Future
drop if WeekNum > CurrWeekNum

***************************
* Program Reporting Errors  		
***************************
* Excess number or zero TOTAL AT START OF THE WEEK 
* We should not punish for this - if sites are ALIMA or MSF
hist Beg

sum Beg if WeekNum == most_recent_report & current8==1, d
local cutoff = r(p50)
recode Beg (`cutoff'/max=1) (else=0), gen(excess_beg)
replace excess_beg=. if WeekNum != most_recent_report
replace excess_beg=. if current8!=1

* Excessive start of the week compared to new admissions. 
* All reports from last 8 weeks
gen AmarX8 = Amar * 8
* Penalty for sites with out of whack that greatly less than amar*8. 
gen amx8_beg = AmarX8 / Beg
* scores more than 1 do not look suspicious

list state lga WeekNum SiteName Amar Beg AmarX8 amx8_beg excess_beg if excess_beg==1 ,abb(5) noobs 

replace amx8_beg=1 if amx8_beg>1
replace amx8_beg=. if current8!=1

* Sites with excess_beg!=1 are not out of whack.
gen out_of_whack_amar_beg = 1 - amx8_beg
hist out_of_whack_amar_beg

scatter complete_reporting out_of_whack_amar_beg

* Error - Sites that report New Admissions = Total Start of the Week
* all errors over past 8 weeks reported
gen equal_amar_beg = 1 if Amar==Beg & Amar>10 & Amar!=. & current8==1 
replace equal_amar_beg =0 if equal_amar_beg==.
list state lga WeekNum SiteName Amar Beg if equal_amar_beg ==1 ,abb(5) noobs 



* 	Excessive (high or low) ratio of new admissions to number of children in charge 
* all errors over past 8 weeks reported
* Normally the ratio of Amar / Beg should be 12%  (as cases stay for an average of 8 weeks)
* Calculate normal ratio
gen ratio_amar_beg = Amar / Beg 
* <0 is excessive reporting of TOTAL START OF THE WEEK
* >1 is more admissions than under Rx, which is possible at first week of RX and not after. 

* median of ratio_amar_beg
* Use median of program to judge ratio at OTP level 
sum ratio_amar_beg if ratio_amar_beg<1 & ratio_amar_beg!=0 & current8==1 , d
local med_amar_beg = r(p50)
local med_amar_b25= r(p25)
local med_amar_b75 = r(p75)
* difference from median
gen amar_beg_flag = 0 
replace amar_beg_flag=1 if ratio_amar_beg < `med_amar_b25' 
replace amar_beg_flag=1 if ratio_amar_beg > `med_amar_b75'
* if the number of admissions are small then the ratio is not an issue. 
replace amar_beg_flag=0 if Amar<30
replace amar_beg_flag=. if current8 !=1
tab amar_beg_flag

sort SiteID WeekNum Type
replace ratio_amar_beg = 1 if ratio_amar_beg>1
kdensity ratio_amar_beg, xline(`med_amar_beg') 	
*scatter Beg ratio_amar_beg 
*scatter Amar ratio_amar_beg 

* Score for Ratio of new admissions to number of children in charge
* take mean of all 8 weekly scores. 
* penalties start at 0.5
drop temp
bysort SiteID Type: egen temp = mean(amar_beg_flag)
gen amar_beg_score = 0
replace amar_beg_score = 0.5 + (temp/2) if amar_beg_flag==1 
replace amar_beg_score =. if current8 !=1
hist amar_beg_score 

* Which is more appropriate ?
scatter amar_beg_score out_of_whack_amar_beg
*bysort lga: egen count_lga = count(Amar)
* out_of_whack_amar_beg is better as it detects poor quality faster - for sites with higher than median admissions. 




* Missing Exits (over 8 weeks)
* Atot = Total Admissions to program
* Cin = Total entries to the facility
gen Cin = Amar + Tin
* End = Total end of the week in program
* Cout = Total exits from the facility
gen Cout= Dcur + Dead + Defu + Dmed + Tout
sort SiteID Type WeekNum
* calculate cumulative admissions and exits
by SiteID Type: egen tot_cin=total(Cin)
by SiteID Type: egen tot_cout=total(Cout)
gen diff_in_out = tot_cin - tot_cout

* How to account for increasing or decreasing caseloads - Take median of program 
* Better would be to take median of state
sum diff_in_out, d
gen median_in_out = r(p50)
gen adj_diff_in_out = abs(diff_in_out - median_in_out)
* Penalize all the maximum if the diff is more than 200
replace adj_diff_in_out = 200 if adj_diff_in_out >200 & diff_in_out!=.
egen max_diff_in_out = max(adj_diff_in_out)
gen in_out_score = adj_diff_in_out / max_diff_in_out
replace in_out_score =1 if Cin==0 & Cout==0
replace in_out_score =1 if Cin==. & Cout==.
* scatter diff_in_out in_out_score 

sort SiteID Type WeekNum 
*order SiteID Type WeekNum Beg Cin Cout tot_cin tot_cout diff_in_out adj_diff_in_out max_diff_in_out in_out_score

* Errors between Total Exits preceding week and TOTAL START OF THE WEEK. 
* Over the past 8 weeks
gen cout_lastweek = Cout[_n-1] if SiteID == SiteID[_n-1]
gen diff_lastweek = abs(Beg - cout_lastweek)
replace diff_lastweek=. if current8!=1
*tab diff_lastweek

* Penalty on max is too open - 500 errors in exits is problematic
* egen max_diff_lastweek = max(diff_lastweek)
gen max_diff_lastweek = 500

replace temp = diff_lastweek / max_diff_lastweek
replace temp = 1 if temp > 1

bysort SiteID Type: egen score_diff_lastweek= mean(temp)
replace score_diff_lastweek=1 if score_diff_lastweek==.
scatter diff_lastweek score_diff_lastweek 
*order SiteID Type WeekNum Beg cout_lastweek diff_lastweek

* NEED TO DOUBLE CHECK. 
gen tot_start_temp = Beg
* Beg should equal End - IS THIS ERROR ? 
order tot_start_temp cout_lastweek diff_lastweek max_diff_lastweek score_diff_lastweek, last



********
*STOCKS
********
* Back calculate RUTF_beg for validation. 
gen RUTF_beg= . 
sort SiteID WeekNum Type
* The replace code below will not work unless the data is sorted. 
replace RUTF_beg = RUTF_bal[_n-1] if SiteID==SiteID[_n-1] & Type==Type[_n-1] & WeekNum==WeekNum[_n-1]+1
* if RUTF_beg is missing then calculate. 
replace RUTF_beg = RUTF_bal - RUTF_in + RUTF_out if RUTF_beg ==.

gen calc_bal = RUTF_beg + RUTF_in - RUTF_out 
gen RUTF_diff = RUTF_bal - calc_bal
* Round all differences that are almost zero to zero. 
replace RUTF_diff = 0 if RUTF_diff < 0.01 & RUTF_diff > -0.01 

* Calculation errors are more than 1 carton.  
* in future, we would like to move to reporting only cartons and not sachets from OTP.
gen calc_error=0
gen neg_error=0
gen dec_error=0
replace calc_error =1 if abs(RUTF_diff)>=1.1 & RUTF_diff !=.
replace neg_error =1 if RUTF_beg<-0.1 | calc_bal<-0.1 
tab calc_error, m 
tab neg_error, m 

* Reporting in decimal points or in quantities over 150 sachets.
* Reporting on stock with decimal points at OTP and SC. 
* to include all sites in decimal point error, need to move this to IMAM Weekly Analysis 2
* all site level data will include decimal points. Refer to LGA_Stock_score if you want to re-insert this. 
* replace dec_error =1 if floor(RUTF_in)!=RUTF_in | floor(RUTF_out)!=RUTF_out | floor(RUTF_bal)!=RUTF_bal

* Only calc_error and neg_error 
replace temp = (calc_error + neg_error)/2
replace temp =. if current8!=1
bysort SiteID Type: egen overall_calc_error = mean(temp) 
replace overall_calc_error=1 if overall_calc_error==.
graph bar (count) one, over(overall_calc_error)

gen calc_flag = 1 if calc_error==1 | neg_error==1 | dec_error==1
replace calc_flag =. if current8!=1
replace calc_flag =. if RUTF_diff <=1

* Excessive or minimal RUTF sachet use per case (~10 sachets / child)
* over past 8 weeks
* Penalty for < 8 or > 20
* these are roughly equivalent to 25 and 75 percentile - or 3 to 9.9 KG average weight per child 
gen caseload = Beg + Amar + Tin - Cout
gen sachets_case_week = RUTF_out / caseload * 150
replace sachets_case_week =. if current8!=1
gen stock_use_flag = 0
replace stock_use_flag = 1 if sachets_case_week < 8 | sachets_case_week > 20
replace stock_use_flag =. if current8!=1
tab stock_use_flag
bysort SiteID Type: egen stock_use_score = mean(stock_use_flag) 
replace stock_use_score=1 if stock_use_score==.
hist stock_use_score



sort sachets_case_week
list state lga SiteName caseload RUTF_out sachets_case_week if stock_use_score ==1 & sachets_case_week<8
list state lga SiteName caseload RUTF_out sachets_case_week if stock_use_score ==1 & sachets_case_week>15

replace sachets_case_week =. if abs(sachets_case_week)>40
hist sachets_case_week

* If score is missing for any of the points below, then have to set to max penalty. 

* Should build up the score from zero, instead of decreasing for penalties. 
* Actually does that matter ?
* if site has perfect score for one report, but missing 7 reports, then this is not appropriate.

gen CMAM_score = 100 ///
	- (comp_score * 20) /// 		* COMPLETE REPORTING
	- (out_of_whack_amar_beg * 20) ///		* DISTORTED RATIO BETWEEN CHILDREN UNDER TREATMENT AND NEW ADMISSIONS
	- (in_out_score *20) ///		* PROBABLE MISSING EXITS
	- (score_diff_lastweek * 10) /// * ERRORS IN TOTAL END OF WEEK AND TOTAL START OF WEEK
	- (overall_calc_error * 20) /// * CALCULATION ERRORS IN STOCK REPORTING
	- (stock_use_score*10) ///      * DISTORTED NUMBER OF SACHETS USED TO TREAT ONE CHILD FOR ONE WEEK. 
	- 0
format CMAM_score %8.0f

* Removed penalty for equal_amar_beg in score. 
		
order comp_score amar_beg_score in_out_score score_diff_lastweek overall_calc_error stock_use_score CMAM_score, last
	
* table lga, c(mean CMAM_score)

* create color group for assignment of colors
recode CMAM_score (0/49.9999=1)(50/79.9999=2)(80/100=3), gen(tercile_score)
separate CMAM_score, by(tercile_score) veryshortlabel

sort SiteID Type WeekNum 

* STATE LEVEL STOCK REPORT SCORE - Tricolor
*graph hbar (mean) CMAM_score? , over(state, sort(CMAM_score)) /// 
*	bar(1, color(red)) bar(2, color(orange*.85)) bar(3,color(green*.75)) legend(off) ///
*	title("CMAM Site Reporting Scores by State", size(medium)) ///
*	ytitle("Score")  ///
*	saving(state_score, replace)
	
* STATE LEVEL STOCK REPORT SCORE 
graph hbar (mean) CMAM_score , over(state, sort(CMAM_score)) /// 
	bar(1, color(red)) legend(off) ///
	title("CMAM Site Reporting Scores by State", size(medium)) ///
	ytitle("Score") ysc(r(100)) ytick(0(20)100) ylabel(0(20)100) ///
	saving(state_score, replace)
	

* LGA LEVEL STOCK REPORT SCORE
graph hbar (mean) CMAM_score , over(lga, label(labs(tiny)) sort(CMAM_score)) /// 
	bar(1, color(red)) bar(2, color(orange*.85)) bar(3,color(green*.75)) legend(off) ///
	title("CMAM Site Reporting Scores by LGA", size(medium)) ///
	ytitle("Score") ///
	saving(lga_score, replace)
	
	
* LGA LEVEL STOCK REPORT SCORE
graph hbar (mean) CMAM_score if lga_code==3505  , over(SiteName, label(labs(small)) sort(CMAM_score)) /// 
	bar(1, color(red)) bar(2, color(orange*.85)) bar(3,color(green*.75)) legend(off) ///
	title("CMAM Site Reporting Scores by Site", size(medium)) ///
	ytitle("Score") ///
	saving(site_score, replace)

	
	
	

* LGA LEVEL STOCK REPORT SCORE
graph hbar (mean) CMAM_score if state_code=="33" , over(lga, label(labs(small)) sort(CMAM_score)) /// 
	legend(off) ///
	title("CMAM Site Reporting Scores by LGA", size(medium)) ///
	ytitle("Score") ///
	saving(cmam_score, replace)
	

























* REPORT 

cap log

* Complete Reporting
* Listing of all sites with complete reporting < 80%
* add varnames and titles every page
list state lga SiteName complete_reporting ProMiss StoMiss if complete_reporting<80,abb(5) noobs 












End of File

sum sachets_case_week, d
gen median_sach_week = r(p50)
egen mean = mean(sachets_case_week), by(WeekNum)
egen loq = pctile(sachets_case_week), p(25) by(WeekNum)
egen upq = pctile(sachets_case_week), p(75) by(WeekNum)
line mean loq upq WeekNum, sort
* Why no results from prior to week 33. 


graph bar (mean) caseload, over (WeekNum)



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
