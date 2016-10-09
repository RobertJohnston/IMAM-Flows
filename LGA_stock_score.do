* LGA stocks analysis

set more off
cap log close
cd C:\TEMP\Working\

* Quality Reporting Score

* Complete reporting 			40%
* Timely reporting				5%
* Reports sent for future dates 5%   - no punishment for reports >8 weeks in past. 
* Unaccounted for stocks 		25%
* 		State is punished for errors between State and LGA (total error over 8 weeks)
* 		LGA is punished for errors between LGA and Site (total error over 8 weeks)
* Errors in calculations 		25%
* 		Errors in calculations (>1 carton)  - Number of errors in past 8 weeks
* 		Negative starting balance			- Number of errors in past 8 weeks
* 		Reporting in decimal points			- Number of errors in past 8 weeks

* There is no punishment for STOCK-OUTS

* First provide reporting on current conditions
* Second provide data quality score on data from last eight weeks - need to provide older scores to show if improving or not. 
* worry about showing older data quality scores later.

* Use the database with all viable program and stock reports included
use CMAM_delete.dta, clear

* if the variables are not complete - then include the following. 
sort SiteID
format SiteID %12.0f
tab Type, m 

* Define Level 
replace Level = "Site" if SiteID >101110000
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99
order SiteID Level
tab Level, m 

* Role
replace Role="Supervision" if Level=="First" | Level=="Second"
tab Role, m 

****** DATA CLEANING *********
* some reports from LGA staff for sites are interpreted as LGA reports. 
* review and correct this in IMAM weekly analysis. 
list SiteID SiteName Name Type if Level=="Second" & Role=="Implementation"
drop if Level=="Second" & Role=="Implementation"
drop if Level=="Second" & Type=="OTP"

* All duplicate reports have been removed previously.
drop leap dow month temp temp2 weekdiff ord_date

* Remove Robert and Jacksons
drop if SiteID==1
drop if SiteID==225211001
drop if SiteID==301110001
drop if SiteID==504110001
* Drop junk data
drop if SiteID < 5
drop if SiteID ==101110001
* Week 22 of 2016 was the first week that we expected valid data to be sent.
drop if WeekNum < 22 
* Find out what is answer to this SiteID error
replace SiteID = 1731110034 if SiteID== 173110034
* Remove all the erroneous LGA attempts of Stock Reports at OTP or SC level
drop if SiteID<9999 & Type=="OTP" 
drop if SiteID<9999 & Type=="SC" 
* replace Role = "Implementation" if SiteID is 
replace Role= "Implementation" if SiteID >9999
* There should be no rows with Level ==""
list Type Level Role if Level ==""
****** END DATA CLEANING *********

destring lga_code, replace
save temp.dta, replace

* LGA STOCK RECEIPTS
* Sum of all LGA level RUTF receipts by week - collapse and merge data back into database
* For comparison to state_RUTF_out - which is just RUTF_out at state level 
gen lga_RUTF_in = RUTF_in if Level=="Second"
collapse (sum) lga_RUTF_in, by(WeekNum)
save collapse.dta, replace

* SOMETHING WIERD

use temp.dta, clear
merge m:m WeekNum using "C:\TEMP\Working\collapse.dta"
drop _merge
save temp.dta, replace

* OUTPATIENT THERAPEUTIC SITE STOCK RECEIPTS
* Sum of all site level RUTF receipts by week - collapse and merge data back into database
* Can this be done with egen? 
gen site_RUTF_in = RUTF_in if Level=="Site"
gen lga_RUTF_out = RUTF_out if Level=="Second"
collapse (sum) lga_RUTF_out site_RUTF_in, by(WeekNum lga)
save collapse.dta, replace

use temp.dta, clear
merge m:m WeekNum lga using "C:\TEMP\Working\collapse.dta"
drop _merge
* table WeekNum lga, c(m site_RUTF_in) 
* include only 1 case per lga & weeknum to make totals

*Penalty for Future Reporting
* value = 2 of rep_date_error is a record sent for the future
egen future_error = anycount(rep_date_error), values(2)
* Only include the data from last 8 weeks. 
gen current8 = 1 if WeekNum >=(CurrWeekNum - 8) & WeekNum <=(CurrWeekNum)
tab WeekNum current8, m 

* drop other cases of future_error if more than 8 weeks in past. 
replace future_error=. if current8!= 1
tab future_error current8, m 
*gen one = 1
*table current8 WeekNum , c (count one)

bysort SiteID Type: egen future_error_tot =  total(future_error) 
egen future_error_max = max(future_error_tot)
* Future reports is scored 5% 
gen future_rept_score = future_error_tot/future_error_max
drop future_error future_error_tot future_error_max
tab future_rept_score, m 
* must subtract this % from the total score. 
* now we can delete the reports from the future
drop if WeekNum > CurrWeekNum
 
* List sites with STOCK OUTS of RUTF F75 F100
* Stock is < 15 sachets RUTF or 1 sachet of F75 or F100
gen stockout = 1 if RUTF_bal<0.10 | F75_bal< 0.01 | F100_bal<0.011
* Include OTP, LGA and State
replace stockout = 1 if RUTF_bal==. & Type!="SC"
replace stockout = 1 if F75_bal==. & Type=="SC"
replace stockout = 1 if F100_bal==. & Type=="SC"
gen stockoutnote = "No Data" if RUTF_bal==. & Type!="SC"
replace stockoutnote = "No Data" if F75_bal==. & Type=="SC"
replace stockoutnote = "No Data" if F100_bal==. & Type=="SC"
tab stockoutnote, m 
* RUTF - Sachets per carton - 150 (0.1 = less than 15 sachets)
* F75 - Sachets per carton - 120 (0.0083 = less than 1 sachet)
* F100 - Sachets per carton - 90 (0.011 = less than 1 sachet)

list SiteID SiteName stockout stockoutnote if SiteID==504/507


lost Bauchi? 


bysort SiteID: egen most_recent_report = max(WeekNum)
tab most_recent_report, m 

* Here remove the stockout warning if the report is not current. 
replace stockout=0 if most_recent_report != WeekNum

* Variable Names
la var WeekNum "Week Number"

sort SiteID Type WeekNum
save temp, replace

* INCLUDE MISSING REPORTS DATA
* enter the number of missing reports for the past 8 weeks
* the database missingrepttot.sav - contains one line for each person - there are more than one reports per site. 
* the data are only for the current week. 
* merge by SiteID and Type
* these data come from running IMAM Weekly Analysis
use "C:\TEMP\Working\missingrepttot.dta", clear
destring lga_code, replace
cap drop _merge

* Data Cleaning on missing reports data. 
sort SiteID Type 
drop if SiteID ==1
* remove test data
drop if SiteID >100000000 & SiteID < 500000000
replace Type="Sup" if SiteID <101110000
replace Level = "Site" if SiteID >101110000
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99

egen count_of_site=tag(SiteID Type)
order SiteID Type count_of_site
* Delete duplicates of sites
drop if count_of_site !=1

* StoRepTot  = number of complete stock reports
gen comp_sto_score = (8-StoReptTot)/8
gen complete_stock_reporting = 100 - comp_sto_score * 100
* must subtract this % from the total score. 
la var StoMiss "Missing Stock Reports"
list state SiteID complete_stock_reporting StoMiss if Level=="First" ,abb(20) noobs 
list state lga SiteID complete_stock_reporting StoMiss if Level=="Second" ,abb(20) noobs 
***************
* DOUBLE CHECK
* MUST ADD IN MISSING LGAS HERE
* Check if these are available in reg data
***************
destring lga_code, replace
keep SiteID Type StoMiss comp_sto_score complete_stock_reporting Level state state_code lga lga_code
save "C:\TEMP\Working\missrepttemp.dta", replace

* MERGE IN MISSING REPORTS DATA
use temp, clear
replace Type="Sup" if SiteID <9999
merge m:m SiteID Type using "C:\TEMP\Working\missrepttemp.dta"
drop _merge
* save temp.dta, replace

* AGAIN reset Level
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99

* Test Complete Reporting - one report per week - need to select. 
list state SiteID complete_stock_reporting StoMiss if Level=="First" ,abb(20) noobs 

* Presentation of Stock-Outs
list WeekNum state lga SiteName Type Name URN RUTF_in RUTF_out RUTF_bal if stockout==1 & Level!="Site"
*list WeekNum state lga SiteName Type Name URN RUTF_in RUTF_out RUTF_bal if stockout==1 & Type=="OTP"
*list WeekNum state lga SiteName Type Name URN F75_bal F100_bal if stockout==1 & Type=="SC"

* STATE level table with 2 week and 4 week margins of stocks
* LGA level table with 2 week and 4 week margins of stocks
* Be careful - the excel dashboard presents 1 and 2 week margins of stock at site level- where the LGA and STATE shows 2 & 4 week margins. 

* Back calculate RUTF_beg for validation. 
gen RUTF_beg= . 
sort SiteID WeekNum Type
* The replace code below will not work unless the data is sorted. 
replace RUTF_beg = RUTF_bal[_n-1] if SiteID==SiteID[_n-1] & Type==Type[_n-1] & WeekNum==WeekNum[_n-1]+1
* order WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal F100_bal F75_bal
* if RUTF_beg is missing then calculate. 
replace RUTF_beg = RUTF_bal - RUTF_in + RUTF_out if RUTF_beg ==.

gen calc_bal = RUTF_beg + RUTF_in - RUTF_out 
gen rutf_diff = RUTF_bal - calc_bal
replace rutf_diff = 0 if rutf_diff < 0.01

* Types of Stock Reporting Errors
* neg_error = RUTF_beg < 0  or  Calc_bal < 0
* calc_error = rutf_bal !=0
* decimal point reporting

* Calculation errors are more than 1 carton.  We would like to move to reporting only cartons and not sachets.
gen calc_error=0
gen neg_error=0
gen dec_error=0
replace calc_error =1 if rutf_diff>1 & rutf_diff !=.
replace neg_error =1 if RUTF_beg<-0.1 | calc_bal<-0.1 
* to include all sites in decimal point error, need to move this to IMAM Weekly Analysis 2
replace dec_error =1 if floor(RUTF_in)!=RUTF_in | floor(RUTF_out)!=RUTF_out | floor(RUTF_bal)!=RUTF_bal
replace dec_error =. if Level=="Site"
*tab calc_error, m 
*tab neg_error, m 
*tab dec_error, m 
* Only calc_error and neg_error
gen temp = (calc_error + neg_error)/2
replace temp =. if current8!=1
bysort SiteID Type: egen overall_calc_error = mean(temp) 
tab overall_calc_error, m 

format RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal rutf_diff %12.2g
*order SiteID WeekNum RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal rutf_diff Type
* Should identify all errors first, then do analysis. 
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Level!="Site"
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Type=="OTP"
*list WeekNum state lga SiteName Type Name URN F75_bal F100_bal 	     		  if error==1 & Type=="SC"

* Weekly Consumption of RUTF from ALL implementation sites
* graph bar (sum) RUTF_out if Type=="OTP", over(WeekNum) 
table WeekNum state, c(sum RUTF_out), if Type=="OTP"

* STATE weekly RUTF consumption from implementation sites
bysort WeekNum: egen state_cons_week = total(RUTF_out) if Type=="OTP"

sort SiteID WeekNum Type
*order SiteID WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal state_cons_week

* Calculate STATE level median consumption over past 4 weeks
sum state_cons_week if WeekNum < CurrWeekNum - 1 & WeekNum > CurrWeekNum - 5 , d
local med_con_state = r(p50)
*di `med_con_state'
local twoweek = `med_con_state' *2
local fourweek = `med_con_state' *4

* Graph of weekly balance of stock at STATE level
* Insert line at 2 and 4 week margin stock levels 

* LGA weekly RUTF consumption from implementation sites

* Weekly Consumption of RUTF in cartons by LGA from all implementation sites
table WeekNum lga, c(sum RUTF_out) f(%8.1f) row col,  if Type=="OTP" 

* LGA weekly RUTF consumption from implementation sites
bysort lga WeekNum: egen lga_cons_week = total(RUTF_out) if Type=="OTP"
table WeekNum lga, c(m lga_cons_week) f(%8.1f) row, if Type=="OTP" 
* all sites consume about the same amount of RUTF per week - Strange

* Calculate median LGA consumption over past 4 weeks
gen med_con_lga =.
levelsof lga_code, local(levels)
foreach l of local levels {
	quietly: sum lga_cons_week if lga_code==`l' & WeekNum < CurrWeekNum - 1 & WeekNum > CurrWeekNum - 5 , d 
	di r(p50)
	replace med_con_lga = r(p50) if lga_code==`l'
}
* Median RUTF consumption in cartons over past 4 weeks
table lga, c(m med_con_lga) f(%8.1f), if Type=="OTP" 

* for LGA graph insert line at 2 and 4 week margin stock levels 
gen twoweeklga = med_con_lga*2
gen fourweeklga = med_con_lga*4

* This code: local lganame: label (lga_code) `l'
* in graph required definition of LGA value labels. 
* Use this trick to get state and LGA names to go through to graphs
* Four digit lga code
	
label define lganame 504	Dambam
label define lganame 512	Katagum, add
label define lganame 513	Kirfi, add
label define lganame 1604	Dukku, add
label define lganame 1606	Gombe, add
label define lganame 1609	Nafada, add
label define lganame 1702	Babura, add
label define lganame 1703	"Birnin Kudu", add
label define lganame 1704   Birniwa, add
label define lganame 1706   Dutse, add
label define lganame 1709   Gumel , add
label define lganame 1710	Guri, add
label define lganame 1712	Gwiwa, add
label define lganame 1713   Hadeija, add
label define lganame 1714   Jahun, add
label define lganame 1716	Kaugama, add
label define lganame 1717	Kazaure, add
label define lganame 1719   Kiyawa, add
label define lganame 1720   Maigatari, add
label define lganame 1724	Roni, add
label define lganame 1727	Yankwashi, add
label define lganame 3301	Binji, add
label define lganame 3304	Gada, add
label define lganame 3305	Goronyo, add
label define lganame 3306	Gudu, add
label define lganame 3308	Illela, add
label define lganame 3313	"Sabon Birni", add
label define lganame 3316	"Sokoto North", add
label define lganame 3317	"Sokoto South", add
label define lganame 3319	Tangaza, add
label define lganame 3321	Wamakko, add

la val lga_code lganame
tab lga_code

replace state ="Bauchi" if SiteID==5

************************************
* Dispatches versus Receipts - STATE
************************************
gen state_RUTF_out = RUTF_out if Level=="First"
replace lga_RUTF_in=. if Level!="First"

* State level dispatches and LGA level receipts by weekly of RUTF 

* Graph below by month is not interesting
* but then is analysis over past 8 weeks interesting? Yes, if we can show improvements
* Set to zero all reports older than 8 weeks in past
replace state_RUTF_out = 0 if current8!=1
replace lga_RUTF_in = 0 if current8!=1
* current8!=1 - is there any value of using current8 = yes then I do not make stupid mistakes

sort SiteID Type WeekNum
by SiteID : gen cum_state_out=sum(state_RUTF_out)
* this calculates cumulative sum for all data LGA RUTF in  - no need to select certain LGAs
by SiteID : gen cum_lga_in=sum(lga_RUTF_in)

* To reset this graph every month use line below
* by SiteID RepMonth: gen cum_state_out=sum(state_RUTF_out)
* by SiteID RepMonth: gen cum_lga_in=sum(lga_RUTF_in)

* Difference in state and LGA reports
gen state_diff = cum_state_out - cum_lga_in
replace state_diff=. if state_diff==0

order SiteID Type WeekNum state lga state_RUTF_out lga_RUTF_in cum_state_out cum_lga_in state_diff SiteID Level 

* Calculate State Level error of differences between dispatch and receipts
egen overall_state_diff = max(abs(state_diff))
* need state level score for last eight weeks
bysort state: egen max_state_diff = max(abs(state_diff))
gen diff_error = max_state_diff / overall_state_diff
table state if Level=="First", c (m diff_error) 
* Note missing data for Bauchi.

* How to report these data
la var state_RUTF_out "st-dist"

* levelsof 
* display only the cases from last 8 weeks
sort SiteID Type WeekNum
* state_RUTF_out- Weekly total of RUTF stock distributed (out)
* lga_RUTF_in  	- Weekly total of RUTF stock received (in)
* cum_state_out - Cumulative total of RUTF stock distributed from state in past 8 weeks
* cum_lga_in  	- Cumulative total of RUTF stock received by LGAs in past 8 weeks
* state_diff  	- Difference in accounts between state and LGAs
list WeekNum state state_RUTF_out lga_RUTF_in cum_state_out cum_lga_in state_diff if Level=="First" ,abb(16) noobs

* graph bar (sum) state_RUTF_out lga_RUTF_in, over(WeekNum)
* graph bar (sum) cum_state_out cum_lga_in state_diff , over(WeekNum) ///
*	bar(1,color(eltblue)) bar(2,color(edkblue)) bar(3,color(red))	///
*	title(State RUTF Dispatches and LGA Receipts) 					///
*	legend( label(1 "Cumulative State RUTF Distribution") label(2 "Cumulative LGA RUTF Receipts") label(3 "Difference") pos(6) cols(1))

* Weekly balance of RUTF at LGA level
* for the LGA level graph, report only the RUTF balance in the LGA stores

* Only LGA balance data from 2nd Level. 
 gen lga_rutf_bal = RUTF_bal if Level=="Second"


* RUTF DISTRIBUTION and RECEIPTS
************************************
* Dispatches versus Receipts - LGA
************************************
* LGA level dispatches and Implementation site level receipts of RUTF by week 
des lga_RUTF_out 
* calculate total site site_RUTF_in by week number
des site_RUTF_in

* Use only the data from past 8 Weeks - Set all else to missing
replace lga_RUTF_out =. if current8!=1
replace site_RUTF_in =. if current8!=1

* These variables were calculated by aggregate / collapse function at beginning of this file. 
bysort SiteID: gen cum_lga_out=sum(lga_RUTF_out)
* this calculates cumulative sum for all data LGA RUTF in  - no need to select certain LGAs
gen site_RUTF_rec = site_RUTF_in if Level=="Second"
bysort SiteID : gen cum_site_in=sum(site_RUTF_rec)
* ERROR IN site_RUTF_rec

* Set non LGA data to missing
replace cum_site_in=. if Level != "Second" 

* Difference between state and LGA reports
gen lga_diff = cum_lga_out - cum_site_in
* take abs difference in calculations below
format lga_diff %12.1f
* Cannot use mean if lga_diff site level data is 0 not missing. 
replace lga_diff=. if Level !="Second"

* Calculate State Level error of differences between dispatch and receipts
* DIFFERENCES IN STOCK REPORTING 
egen overall_lga_diff = max(abs(lga_diff))
* need lga level score for last eight weeks
bysort lga: egen max_lga_diff = max(abs(lga_diff))
replace diff_error = max_lga_diff / overall_lga_diff if Level=="Second"



sort SiteID Type WeekNum
*order SiteID lga_code lga WeekNum diff_error  

table lga if Level=="Second", c (m diff_error) 

sort lga SiteID WeekNum Type
*order lga SiteID WeekNum  lga_RUTF_out site_RUTF_in cum_lga_out cum_site_in site_RUTF_rec lga_diff  Level WeekNum 

* no errors when SD = 0 
*table WeekNum lga, c(sd site_RUTF_in) 
*table WeekNum lga, c(sd cum_site_in) 

* TAG only one case of each site
gsort -WeekNum
egen one_case=tag(SiteID Type) 
* include one case from 
tab one_case, m 
tab one_case if Level=="Site", m 


*Presentation of results
* list WeekNum lga lga_RUTF_out site_RUTF_in cum_lga_des cum_site_rec lga_diff if Level=="Second" 
* table WeekNum, c(sum state_RUTF_out sum lga_RUTF_in)
* graph bar (sum) state_RUTF_out lga_RUTF_in, over(WeekNum)
* graph bar (mean) cum_lga_des cum_site_rec lga_diff if lga_code==21, over(WeekNum) 

*levelsof lga_code, local(levels)
*foreach l of local levels {
*	local lganame: label (lga_code) `l'
*	local graph_name = "LGAdistSiteRec" + "`l'"
*	graph bar (mean) cum_lga_des cum_site_rec lga_diff if lga_code==`l', over(WeekNum) 	///
*		bar(1,color(eltblue)) bar(2,color(edkblue)) bar(3,color(red))					///
*		ytitle("RUTF Cartons")  														///
*		title(`lganame' RUTF Dispatches and OTP Receipts) 								///
*		legend( label(1 "Cumulative LGA RUTF Distribution") label(2 "Cumulative OTP RUTF Receipts") label(3 "Difference") pos(6) cols(1)) ///
*		note("NOTE: We can reset the cumulative sum by month if necessary") ///
*		saving(`graph_name',replace)
*}

* Force only 8 weeks to appear in tables and calculations
* Drop all if not from last 8 weeks? 

* Use only the data from past 8 Weeks - Set cumulative calculations to missing
replace lga_RUTF_out =. if current8!=1
replace site_RUTF_in =. if current8!=1


* STATE level table. 
table WeekNum, c(sum state_RUTF_out sum lga_RUTF_in sum state_diff ) f(%8.0f)
* previously included missing stock reports in table. 

	
* Consumption of RUTF at LGA level 
* RUTF_in RUTF_out RUTF_bal F75_bal F100_bal
format RUTF_in RUTF_out RUTF_bal F75_bal F100_bal %8.1f

* Research project
* What is difference between reporting with or without sachets at OTP level

* How to calculate poor quality reporting
* keep only past 8 weeks of reporting - no past or future data accepted
* 8 weeks will create a moving block of data that allows to show improvements over time. 

* Score is based on: 
* 	Complete Reporting
* 	Errors in balance reporting
* 	Reporting in decimal points
* 	Cumulative difference between dispatch and receipt between State and LGA

* corrections for missing data. 
replace future_rept_score=1 if future_rept_score==. 
* If there was no reporting at State or LGA then penalize LGA 100% for diff error. 
replace diff_error =1 if comp_sto_score ==1
* Remove duplicate stock error scores - set diff_error = missing if there was no reporting for 8 weeks
replace diff_error=. if current8!=1 & comp_sto_score !=1

replace overall_calc_error=1 if overall_calc_error==. 
* Why? 
* drop if SiteID > 9999

* DOUBLE CHECK THAT THESE ARE VALID FOR PAST 8 WEEKS
gen stock_report_score = round(100 - (comp_sto_score *40) - (future_rept_score * 5) - (diff_error * 25) - (overall_calc_error * 25))
* is diff error in reverse ?

* missing (timely * 5) a give away for now. 
table SiteID state if Level!="Site", c (m stock_report_score) 

gen lga_state = lga + " - " + state
	

* create color group for assignment of colors
recode stock_report_score (0/49=1)(50/79=2)(80/100=3), gen(tercile_score)
separate stock_report_score, by(tercile_score) veryshortlabel


	

***************
*  START HERE
***************

* Bauchi  5
* Gombe  16
* Jigawa 17
* Sokoto 33
* Yobe 	 35

local choosestate = 5
di `choosestate'

local currentweeknum = CurrWeekNum
* Reminders for LGA and State (only Stock)
local report_name = "CMAM_Report_Week" + "`currentweeknum'" 



***************
* STOCKS REPORT
***************

sort SiteID Type WeekNum

format lga_RUTF_out site_RUTF_in cum_lga_out cum_site_in site_RUTF_rec lga_diff state_RUTF_out lga_RUTF_in /// 
	cum_state_out cum_lga_in state_diff RUTF_beg RUTF_in RUTF_out RUTF_bal %8.1f
* At some point - change site_RUTF_rec to site_RUTF_in

	
destring state_code, replace

* log using "C:\Analysis\CMAMRep.log", replace

*******************************************************
* MANAGEMENT OF SEVERE ACUTE MALNUTRITION STOCKS REPORT
*******************************************************

* STATE LEVEL STOCK REPORT SCORE
graph hbar (mean) stock_report_score? if Level=="First" , over(state, sort(stock_report_score)) /// 
	bar(1, color(red))bar(2, color(orange*.85)) ///
	bar(3,color(green*.75)) legend(off) ///
	title("Stock Reporting Scores by STATE", size(medium)) ///
	ytitle("Score")
	
* LGA LEVEL STOCK REPORT SCORE
graph hbar (mean) stock_report_score? if Level=="Second" , over(lga_state, sort(stock_report_score)) /// 
	bar(1, color(red))bar(2, color(orange*.85)) ///
	bar(3,color(green*.75)) legend(off) ///
	title("Stock Reporting Scores by LGA", size(medium)) ///
	ytitle("Score")
	



* MISSING STOCK REPORTS FROM STATE AND LGA
* Table complete reporting
list state SiteID complete_stock_reporting StoMiss if Level=="First" & state_code==`choosestate' ,abb(20) noobs 

list lga SiteID complete_stock_reporting StoMiss if Level=="Second" & state_code==`choosestate' & one_case==1 ,abb(20) noobs 


* STATE AND LGA LEVEL STOCK OUTS (past 8 weeks)
list WeekNum state lga SiteName Name URN RUTF_bal stockoutnote if stockout==1 & Level!="Site" & state_code==`choosestate'


* OUTPATIENT THERAPEUTIC PROGRAMME LEVEL STOCK OUTS

list WeekNum SiteName Name URN RUTF_bal stockoutnote if stockout==1 & Type=="OTP"

* STABILISATION CENTRE LEVEL STOCK OUTS (F75 and F100 reported in cartons)

list WeekNum SiteName Name URN F75_bal F100_bal stockoutnote if stockout==1 & Type=="SC"

cap graph bar (sum) RUTF_bal if SiteID==`choosestate', over(WeekNum) 	///
	yline(`twoweek', lcolor(red) lwidth(medthick)) 					///
	yline(`fourweek', lcolor(orange)) 								///
	ytitle("RUTF balance")  										///
	title("State Level RUTF Balance") 								///
	note("NOTE: orange line = 4 week stock margin - red line = 2 week stock margin") ///
	saving(state_rutf_bal,replace)



* ERRORS IN STOCK REPORTS
* STATE AND LGA LEVEL ERRORS

* The errors are either calculation mistakes of greater than 1 carton of RUTF 
* or calculation mistakes leading negative balances. 

list WeekNum SiteName Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Level!="Site"


* OUTPATIENT THERAPEUTIC PROGRAMME ERRORS

* The errors are either calculation mistakes of greater than 1 carton of RUTF 
* or calculation mistakes leading negative balances. 

list WeekNum lga SiteName Type URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Type=="OTP"


* STABILISATION CENTRE LEVEL ERRORS

* The errors are either calculation mistakes of greater than 1 carton of RUTF 
* or calculation mistakes leading negative balances. 

list WeekNum lga SiteName Type Name URN F75_bal F100_bal if error==1 & Type=="SC"


	
* RUTF DISTRIBUTION and RECEIPTS

* STATE LEVEL DISPATCHES vs LGA LEVEL RECEIPTS
* Please see the following explanations of variable names for table below

*state_RUTF_out 	= RUTF distributed from STATE Warehouse to LGA stores
*lga_RUTF_in 		= RUTF received at LGA stores from STATE Warehouse
*cum_state_out 		= Cumulative total of RUTF distributed from STATE Warehouse to LGA stores
*cum_lga_in 		= Cumulative total of RUTF received at LGA stores from STATE Warehouse
*state_diff 		= Difference between reports from State and LGA

list WeekNum state state_RUTF_out lga_RUTF_in cum_state_out cum_lga_in state_diff if Level=="First" 

graph bar (sum) cum_state_out cum_lga_in state_diff , over(WeekNum) ///
	bar(1,color(eltblue)) bar(2,color(edkblue)) bar(3,color(red))	///
	title(State RUTF Dispatches and LGA Receipts) 					///
	legend( label(1 "Cumulative State RUTF Distribution") label(2 "Cumulative LGA RUTF Receipts") label(3 "Difference") pos(6) cols(1)) ///
	saving(STATEdistLGArec, replace)
 
 
* LGA Level - Weekly consumption of RUTF 

* Weekly Consumption of RUTF in cartons from all implementation sites by LGA 

table WeekNum lga, c(sum RUTF_out) f(%8.1f) col,  if Type=="OTP" 

* Weekly balance of RUTF at LGA level


levelsof lga_code, local(levels)
foreach l of local levels {
	su med_con_lga if lga_code==`l', meanonly 
	local twoweek = cond(r(mean),r(mean)*2,0,0) 
	local fourweek = cond(r(mean),r(mean)*4,0,0) 
	local lganame: label (lga_code) `l'
	local graph_name1 = "lga_rutf_bal" + "`l'" 
	graph bar (sum) lga_rutf_bal if lga_code==`l', over(WeekNum) 	///
		yline(`twoweek', lcolor(red) lwidth(medthick)) 							///
		yline(`fourweek', lcolor(orange)) 						///
		ytitle("RUTF balance")  								///
		title(`lganame' LGA Level RUTF Balance) 				///
		note("NOTE: red line = 2 week stock margin - orange line = 4 week stock margin") ///
		saving(`graph_name1',replace)
}
* 
* LGA LEVEL DISPATCHES vs IMPLEMENTATION SITE RECEIPTS
* Please see the following explanations of variable names for table below

*lga_RUTF_out 	= RUTF distributed from LGA Stores to OTPs
*site_RUTF_in 	= RUTF received at OTPs from LGA Stores
*cum_lga_des 	= Cumulative total of RUTF distributed from LGA Stores to OTPs
*cum_site_rec 	= Cumulative total of RUTF received at OTPs from LGA Stores
*lga_diff 		= Difference between reports from LGA and OTPs

list WeekNum lga lga_RUTF_out site_RUTF_in cum_lga_des cum_site_rec lga_diff if Level=="Second" 


* LGA LEVEL DISPATCHES vs OTP SITE LEVEL RECEIPTS

levelsof lga_code, local(levels)
foreach l of local levels {
	local graph_name2 = "LGAdistSiteRec" + "`l'"
	local lganame: label (lga_code) `l'
	graph bar (mean) cum_lga_des cum_site_rec lga_diff if lga_code==`l', over(WeekNum) 	///
		bar(1,color(eltblue)) bar(2,color(edkblue)) bar(3,color(red))					///
		ytitle("RUTF Cartons")  														///
		title(`lganame' RUTF Dispatches and OTP Receipts) 								///
		legend( label(1 "Cumulative LGA RUTF Distribution") label(2 "Cumulative OTP RUTF Receipts") label(3 "Difference") pos(6) cols(1)) ///
		note("NOTE: We can reset the cumulative sum by month if necessary") ///
		saving(`graph_name2',replace)
}
		
log close

graphlog using "C:\Analysis\CMAMRep.log", gdirectory(C:/TEMP/Working/) porientation(landscape) fsize(10) lspacing(1) keeptex replace

* Graphlog does not work when all graphs are in the same for loop

end






*graph combine male_salary.gph female_salary.gph, col(1) saving(salary_by_sex,replace)
*graph use salary_by_sex
*graph export salary_by_sex.pdf

*translate “Stata Log for module 2 exercises.smcl” “Stata Log for module 2 exercises.pdf”

* END OF FILE

* RUTF receipts, dispatches and balance
table WeekNum if Level == "First", c(m RUTF_in m RUTF_out m RUTF_bal)

* vertical format difficult to read
table WeekNum SiteName if Level == "Second", c(m RUTF_in m RUTF_out m RUTF_bal)

* F100 & F75
table WeekNum SiteName if Type=="SC", c(m F100_bal m F75_bal)
sort lga WeekNum
format F75_bal F100_bal %9.2f
list WeekNum SiteName F75_bal F100_bal if Type=="SC"
* error in F75 and F100 stocks at General Hosp Binji
* If there are errors in the stock reports, use the list above. 


* Stacked graph of stock at STATE level
graph bar RUTF_in RUTF_out RUTF_bal if SiteID==33, over(WeekNum) stack

graph bar (sum) RUTF_in if Type=="OTP", over(WeekNum) 


*graph bar (sum) RUTF_beg if SiteID==33 , over(WeekNum) name(beg, replace) nodraw
*graph bar (sum) RUTF_in RUTF_out RUTF_bal if SiteID==33, over(WeekNum) stack legend(pos(12)) name(end, replace) nodraw
*graph combine beg end, cols(2) title(“Stocks Graphs“)


* Compare receipts at LGA versus dispatches at State
* 2 Graphs side by side
*graph bar (sum) RUTF_out if Level=="First" , over(WeekNum) name(state_des, replace) nodraw
*graph bar (sum) RUTF_in if Level=="Second", over(WeekNum) stack legend(pos(12)) name(lga_rec, replace) nodraw
*graph combine state_des lga_rec, cols(2) title(Dispatches and Receipts)
* Difficult to interpret

* Does RUTF_in at LGA match RUTF_out from State ? 






* Insert one case for Gada, Sokoto North and Sokoto South
local nplus = _N + 1
set obs `nplus'
replace SiteID = 3304 in `nplus'
replace lga="Gada" in `nplus'
replace WeekNum = 32 in `nplus'
replace Role="Supervision" in `nplus'
replace Level="Second" in `nplus'
replace lga_code = SiteID - 3300 in `nplus'
local nplus = _N + 2
set obs `nplus'
replace SiteID = 3316 in `nplus'
replace lga="Sokoto North" in `nplus'
replace WeekNum = 32 in `nplus'
replace Role="Supervision" in `nplus'
replace Level="Second" in `nplus'
replace lga_code = SiteID - 3300 in `nplus'
local nplus = _N + 3
set obs `nplus'
replace SiteID = 3317 in `nplus'
replace lga="Sokoto South" in `nplus'
replace WeekNum = 32 in `nplus'
replace Role="Supervision" in `nplus'
replace Level="Second" in `nplus'
replace lga_code = SiteID - 3300 in `nplus'
* All completely non-functional.
