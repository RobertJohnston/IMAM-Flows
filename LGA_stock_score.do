* LGA stocks analysis

set more off
cap log close
cd C:\TEMP\Working\

***************
*  START HERE
***************
* Adamawa 2
* Bauchi  5
* Borno   8
* Gombe   16
* Jigawa  17
* Kaduna  18
* Kano    19
* Katsina 20
* Kebbi   21
* Sokoto  33
* Yobe 	  35
* Zamfara 36

local choosestate = 33


* Quality Reporting Score

* Complete reporting 			40%

* Errors in calculations 		30%
* 		Errors in calculations (>1 carton)  - Number of errors in past 8 weeks (15%)
*          or negative starting balance
* 		Double counting						- Number of errors in past 8 weeks (15%)

* Unaccounted for stocks 		30%
* 		State is punished for errors between State and LGA (total error over 8 weeks)
* 		LGA is punished for errors between LGA and Site (total error over 8 weeks)

* There is no punishment for STOCK-OUTS

* Removed penalties for: 
* Timely reporting				
* Reports sent for future dates  - no punishment for reports >8 weeks in past. 

* First provide reporting on current conditions
* Second provide data quality score on data from last eight weeks - need to provide older scores to show if improving or not. 
* worry about showing older data quality scores later.

* Base penalty for gross errors - even if small
* should just rank all errors and then score by magnitude of ranking - not size of error
local basepen = 0.3


* Use the database with all viable program and stock reports included
use CMAM_delete.dta, clear

* if the variables are not complete - then include the following. 
sort SiteID
format SiteID %12.0f
tab Type, m 

* Define Level 
replace Level = "Site" if SiteID > 101110000
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99
order SiteID Level
tab Level, m 

* Role
replace Role="Supervision" if Level=="First" | Level=="Second"
replace Role="Implementation" if Level=="Site"
drop if Role==""
tab Role, m 

tab Level Role, m 



****** DATA CLEANING *********
* some reports from LGA staff for OTP/SC sites are interpreted as LGA reports. 
* review and correct this in IMAM weekly analysis. 
list SiteID SiteName Name Type if Level=="Second" & Role=="Implementation"
drop if Level=="Second" & Role=="Implementation"
drop if Level=="Second" & Type=="OTP"

* All duplicate reports have been removed previously.
drop dow month temp temp2 ord_date

* Remove Robert and Jacksons
drop if SiteID==0
drop if SiteID==1
drop if SiteID==225211001
drop if SiteID==301110001
*drop if SiteID==504110001

* Drop junk data
drop if SiteID ==101110001
* Week 22 of 2016 was the first week that we expected valid data to be sent.
drop if WeekNumDate < date("20160601","YMD")


* Remove all the erroneous LGA attempts of Stock Reports at OTP or SC level

* There should be no rows with Level ==""
list Type Level Role if Level ==""

* Error in registration - SiteID = 36
* list if state_code=="36"
drop if state_code=="36" & WeekNum==.
sort SiteID WeekNum

***** END DATA CLEANING *********


destring lga_code, replace
save temp.dta, replace

* LGA STOCK RECEIPTS
* Sum of all LGA level RUTF receipts by week - collapse and merge data back into database
* For comparison to state_RUTF_out - which is just RUTF_out at state level 
gen lga_RUTF_in = RUTF_in if Level=="Second"
collapse (sum) lga_RUTF_in, by(WeekNum state)
save collapse.dta, replace

use temp.dta, clear
merge m:m  WeekNum state using "C:\TEMP\Working\collapse.dta"
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

**************************
* Future Reporting - No penalty
**************************
* value = 2 of rep_date_error is a record sent for the future
egen future_error = anycount(rep_date_error), values(2)

* Only include the data from last 8 weeks. 
gen diff =  WeekNum - CurrWeekNum 
replace diff = WeekNum - 52 - CurrWeekNum if diff>0
gen current8 = 1 if diff<=0 & diff>-9
order SiteID Type WeekNum CurrWeekNum diff current8
tab WeekNum current8, m 

* drop other cases of future_error if more than 8 weeks in past. 
replace future_error=. if current8!= 1
tab future_error current8, m 

bysort SiteID Type: egen future_error_tot =  total(future_error) 
egen future_error_max = max(future_error_tot)

* Future reports no penalty score
gen future_rept_score = future_error_tot/future_error_max
drop future_error future_error_tot future_error_max
tab future_rept_score, m 
* in future, consider if this should be subtracted % from the total score. 


* now we can delete the reports from the future
* must delete reports by date and not week number
* should convert week number into date and specify the exact time span. 

* The RapidPro reporting started in July so delete all prior data. 
drop if WeekNumDate < date("20160601","YMD") & WeekNum !=.
* must included WeekNum !=. so not to delete all cases where state and LGAs should report. 
 
*************
* STOCK OUTS
*************
* List sites with STOCK OUTS of RUTF F75 F100
* Stock is < 15 sachets RUTF or 1 sachet of F75 or F100
gen stockout = 1 if RUTF_bal<0.10 | F75_bal< 0.01 | F100_bal<0.011
* Include OTP, LGA and State
replace stockout = 1 if RUTF_bal==. & Type!="SC"
replace stockout = 1 if F75_bal==. & Type=="SC"
replace stockout = 1 if F100_bal==. & Type=="SC"
gen stocknote = "No Data" if RUTF_bal==. & Type!="SC"
replace stocknote = "No Data" if F75_bal==. & Type=="SC"
replace stocknote = "No Data" if F100_bal==. & Type=="SC"
tab stocknote, m 
*list SiteID SiteName stockout stocknote if SiteID>500 & SiteID<520
* RUTF - Sachets per carton - 150 (0.1 = less than 15 sachets)
* F75 - Sachets per carton - 120 (0.0083 = less than 1 sachet)
* F100 - Sachets per carton - 90 (0.011 = less than 1 sachet)

bysort SiteID Type: egen most_recent_report_date = max(WeekNumDate)
gen most_recent_report_temp = WeekNum if most_recent_report_date == WeekNumDate
* copy value of WeekNum to all records from same Site
bysort SiteID Type: egen most_recent_report = max(most_recent_report_temp)
drop most_recent_report_temp
replace most_recent_report =. if most_recent_report==53 & leap!=1
tab most_recent_report, m

* Here remove the stockout warning if the report is not current. 
replace stockout=0 if most_recent_report != WeekNum

* Variable Names
la var WeekNum "Week Number"

sort SiteID Type WeekNum
save temp, replace

********************************
* INCLUDE MISSING REPORTS DATA
********************************
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
drop if SiteID >100000000 & SiteID < 200000000
replace Type="Sup" if SiteID <100000000
replace Level = "Site" if SiteID >101110000
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99
drop if state_code=="30"
drop if state_code=="0"
drop if state_code=="61"
drop if state=="N" 

* reset the state_code and lga_code
tostring SiteID, gen(temp)
replace state_code = substr(temp,1, 2) if state_lgt==. & state_code==""
drop temp
replace lga_code = SiteID if lga_code==. 

* Add names for state and LGA codes
replace state="Adamawa" if state_code=="2"
replace state="Bauchi" if state_code=="5"
replace state="Borno"  if state_code=="8"
replace state="Gombe"  if state_code=="16"
replace state="Jigawa" if state_code=="17"
replace state="Kaduna" if state_code=="18"
replace state="Kano"   if state_code=="19"
replace state="Katsina" if state_code=="20"
replace state="Kebbi"  if state_code=="21"
replace state="Sokoto" if state_code=="33"
replace state="Yobe"   if state_code=="35"
replace state="Zamfara" if state_code=="36"


* I don't know why, but Yobe LGA names are not coming through
* IS THIS NEEDED HERE ? YES
* Yobe State
replace lga ="BADE" if lga_code==3501
replace lga ="BUSARI" if lga_code==3502
replace lga ="DAMATURU" if lga_code==3503
replace lga ="FIKA" if lga_code==3504
replace lga ="FUNE" if lga_code==3505
replace lga ="GEIDAM" if lga_code==3506
replace lga ="GUJBA" if lga_code==3507
replace lga ="GULANI" if lga_code==3508
replace lga ="JAKUSKO" if lga_code==3509
replace lga ="KARASUWA" if lga_code==3510
replace lga ="MACHINA" if lga_code==3511
replace lga ="NANGERE" if lga_code==3512
replace lga ="NGURU" if lga_code==3513
replace lga ="POTISKUM" if lga_code==3514
replace lga ="TARMUWA" if lga_code==3515
replace lga ="YUNUSARI" if lga_code==3516
replace lga ="YUSUFARI" if lga_code==3517
* TEST Yobe LGA names
replace lga = proper(lga)
* list state lga_code lga if SiteID > 3508 & SiteID<3600

tab state, m 
list lga_code state if SiteID > 3508 & SiteID<3600
egen count_of_site=tag(SiteID Type)
order SiteID Type count_of_site
* Delete duplicates of sites
drop if count_of_site !=1


***************
* DOUBLE CHECK
* MUST ADD IN MISSING LGAS HERE
* Check if these are available in reg data
***************
destring lga_code, replace
keep SiteID Type ProMiss StoMiss Level state state_code lga lga_code ProReptTot StoReptTot
save "C:\TEMP\Working\missrepttemp.dta", replace

* MERGE IN MISSING REPORTS DATA
use temp, clear
replace Type="Sup" if SiteID <9999
merge m:m SiteID Type using "C:\TEMP\Working\missrepttemp.dta"

* Adamawa Implementation is not being merged here.  Missing data in one file. 
* Adamawa Implementation data is not in missrepttemp - other states OTPs are

* AGAIN reset Level
replace Level = "Second" if SiteID  > 99 & SiteID < 9999 
replace Level = "First" if SiteID < 99

* ProRepTot = number of complete program reports
gen comp_pro_score = (8-ProReptTot)/8
gen complete_prog_reporting = 100 - comp_pro_score * 100
* StoRepTot  = number of complete stock reports
gen comp_sto_score = (8-StoReptTot)/8
gen complete_stock_reporting = 100 - comp_sto_score * 100
* must subtract this % from the total score. 
la var StoMiss "Missing Stock Reports"
*list state SiteID complete_stock_reporting StoMiss if Level=="First" ,abb(20) noobs 
*list state lga SiteID complete_stock_reporting StoMiss if Level=="Second" ,abb(20) noobs 
la var ProMiss "Missing Program Reports"
*list state lga SiteName SiteID complete_prog_reporting ProMiss if Type=="OTP" ,abb(20) noobs 


* Test Complete Reporting 

sort SiteID
* all STATE level stock reports 
* There is one report per state per week - need to select only one 
* the missing reports are aggregated over the past 8 weeks. Take max of most recent.
list state SiteID WeekNum complete_stock_reporting StoMiss if Level=="First" ,abb(20) noobs 



* Presentation of Stock-Outs
*list WeekNum state lga SiteName Type Name URN RUTF_in RUTF_out RUTF_bal if stockout==1 & Level!="Site"
*list WeekNum state lga SiteName Type Name URN RUTF_in RUTF_out RUTF_bal if stockout==1 & Type=="OTP"
*list WeekNum state lga SiteName Type Name URN F75_bal F100_bal if stockout==1 & Type=="SC"

* STATE level table with 2 week and 4 week margins of stocks
* LGA level table with 2 week and 4 week margins of stocks
* Be careful - the excel dashboard presents 1 and 2 week margins of stock at site level- where the LGA and STATE shows 2 & 4 week margins. 

* Back calculate RUTF_beg for validation. 
gen RUTF_beg= . 
sort SiteID WeekNumDate Type
* The replace code below will not work unless the data is sorted. 
replace RUTF_beg = RUTF_bal[_n-1] if SiteID==SiteID[_n-1] & Type==Type[_n-1] & WeekNum==WeekNum[_n-1]+1
* order WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal F100_bal F75_bal
* if RUTF_beg is missing then calculate. 
replace RUTF_beg = RUTF_bal - RUTF_in + RUTF_out if RUTF_beg ==.

gen calc_bal = RUTF_beg + RUTF_in - RUTF_out 
gen RUTF_diff = RUTF_bal - calc_bal
replace RUTF_diff = 0 if RUTF_diff < 0.01 & RUTF_diff > -0.01 

*************************
* Stock Reporting Errors
*************************
* neg_error = RUTF_beg < 0  or  Calc_bal < 0
* calc_error = rutf_bal !=0
* double counting

* Calculation errors are more than 1 carton.  We would like to move to reporting only cartons and not sachets.
gen calc_error=0
gen neg_error=0
gen decimal_error=0
replace calc_error =1 if RUTF_diff>=1.1 & RUTF_diff !=.
replace neg_error =1 if RUTF_beg<-0.1 | calc_bal<-0.1 

* Decimal point reporting
* this will be accepted in some cases
* to include all sites in decimal point error, need to move this to IMAM Weekly Analysis 2
replace decimal_error =1 if floor(RUTF_in)!=RUTF_in | floor(RUTF_out)!=RUTF_out | floor(RUTF_bal)!=RUTF_bal
replace decimal_error =. if Level=="Site"




*tab calc_error, m 
*tab neg_error, m 
*tab decimal_error, m 
* Only calc_error and neg_error
gen temp = (calc_error + neg_error)/2
replace temp =. if current8!=1
bysort SiteID Type: egen overall_calc_error = mean(temp) 
tab overall_calc_error, m 
gen calc_flag = 1 if calc_error==1 | neg_error==1 | decimal_error==1
replace calc_flag =. if current8!=1
replace calc_flag =. if RUTF_diff <=1


* Create base penalty if there are errors
replace overall_calc_error = overall_calc_error + `basepen' if overall_calc_error!=0
replace overall_calc_error = 1 if overall_calc_error>1
tab overall_calc_error, m




order SiteID SiteName WeekNum calc_error neg_error decimal_error temp overall_calc_error
sort SiteID WeekNumDate Type

format RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal RUTF_diff %12.2g
*order SiteID WeekNum RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal RUTF_diff Type
* Should identify all errors first, then do analysis. 
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Level!="Site"
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Type=="OTP"
*list WeekNum state lga SiteName Type Name URN F75_bal F100_bal 	     		  if error==1 & Type=="SC"

* Weekly Consumption of RUTF from ALL implementation sites
* graph bar (sum) RUTF_out if Type=="OTP", over(WeekNum) 
table WeekNum state, c(sum RUTF_out), if Type=="OTP"

* STATE weekly RUTF consumption from implementation sites
bysort WeekNumDate: egen state_cons_week = total(RUTF_out) if Type=="OTP"

sort SiteID WeekNumDate Type
*order SiteID WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal state_cons_week

* Calculate STATE level median consumption over past 4 weeks
destring state_code, replace
* For graph of weekly balance of stock at STATE level
table WeekNum state if current8==1 & state_code==`choosestate', c(mean state_cons_week)
* GENERATE med_con_state
gen med_con_state =. 
quietly: sum state_cons_week if weekdiff>=-4 & weekdiff<=0 & state_code==`choosestate' , d
replace med_con_state  = r(p50) if state_code==`choosestate'
table WeekNum state if current8==1 & state_code==`choosestate', c(mean med_con_state)
*******
* Does not correspond to results presented in CMAM Dashboard
* Need to double check
*******







* LGA weekly RUTF consumption from implementation sites

* Weekly Consumption of RUTF in cartons by LGA from all implementation sites
table WeekNum lga, c(sum RUTF_out) f(%8.1f) row col,  if Type=="OTP" 

* LGA weekly RUTF consumption from implementation sites
bysort lga WeekNumDate: egen lga_cons_week = total(RUTF_out) if Type=="OTP"
table WeekNum lga, c(m lga_cons_week) f(%8.1f) row, if Type=="OTP" 
* all sites consume about the same amount of RUTF per week - Strange

* Calculate median LGA consumption over past 4 weeks
gen med_con_lga =.
levelsof lga_code, local(levels)

* REPLACED
* WeekNum < CurrWeekNum - 1 & WeekNum > CurrWeekNum - 5
* if weekdiff>=-4 & weekdiff<=0

foreach l of local levels {
	quietly: sum lga_cons_week if lga_code==`l' & weekdiff>=-4 & weekdiff<=0 , d 
	di r(p50)
	replace med_con_lga = r(p50) if lga_code==`l'
}
* Median RUTF consumption in cartons over past 4 weeks
table lga, c(m med_con_lga) f(%8.1f), if Type=="OTP" 

* for LGA graph insert line at 2 and 4 week margin stock levels 
gen twoweeklga = med_con_lga*2
gen fourweeklga = med_con_lga*4

* LABEL GRAPHS IN FOR LOOP
* This code: local lganame: label (lga_code) `l'
* in graph required definition of LGA value labels. 
* Use this trick to get state and LGA names to go through to graphs
* Four digit lga code

* DOUBLE COUNTING OF RUTF STOCK at OTP
* Any double counting penalized full amount - 15%

* double counting utilization
gen temp_dc_util= dc_util*100
* double counting balance
gen temp_dc_bal= dc_bal*100
format temp_dc_util temp_dc_bal %8.1f
table state, c(m temp_dc_util m temp_dc_bal)
* Add score/penalty for double counting
gen dc_temp=0
replace dc_temp = 1 if dc_util==1 | dc_bal==1
bysort SiteID Type: egen dc_score = max(dc_temp)
drop dc_temp



************************************
* Dispatches versus Receipts - STATE
************************************
gen state_RUTF_out = RUTF_out if Level=="First"
replace lga_RUTF_in=. if Level!="First"

* State level dispatches and LGA level receipts by weekly of RUTF 

* Graph below by month is not interesting
* but then is analysis over past 8 weeks interesting? Yes, if we can show improvements
* Set to zero all reports older than 8 weeks in past
replace state_RUTF_out = 0 if current8 !=1
replace lga_RUTF_in    = 0 if current8 !=1
* current8 !=1 - is there any value of using the var current8 = yes then I do not make stupid mistakes

sort SiteID Type WeekNum
by SiteID : gen cum_state_out=sum(state_RUTF_out)
* this calculates cumulative sum for all data LGA RUTF in  - no need to select certain LGAs
by SiteID : gen cum_lga_in=sum(lga_RUTF_in)

* Present the data from the last 8 weeks. 

* Difference in state and LGA reports
gen state_diff = cum_state_out - cum_lga_in
replace state_diff=. if state_diff==0



* order SiteID Type WeekNum state lga state_RUTF_out lga_RUTF_in cum_state_out cum_lga_in state_diff SiteID Level 

* Calculate State Level error of differences between dispatch and receipts
egen overall_state_diff = max(abs(state_diff))
* need state level score for last eight weeks
bysort state: egen max_state_diff = max(abs(state_diff))
gen diff_error = max_state_diff / overall_state_diff
table state if Level=="First", c (m diff_error) 
* Note missing data for Bauchi.

* How to report these data
la var state_RUTF_out "state distribution"

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


* Create base penalty if there are errors
replace diff_error = diff_error + `basepen' if diff_error!=0
replace diff_error = 1 if diff_error >1
tab diff_error, m
* hist diff_error


sort SiteID Type WeekNumDate
*order SiteID lga_code lga WeekNum diff_error  

table lga if Level=="Second", c (m diff_error) 

sort lga SiteID WeekNumDate Type
*order lga SiteID WeekNum  lga_RUTF_out site_RUTF_in cum_lga_out cum_site_in site_RUTF_rec lga_diff  Level WeekNum 

* no errors when SD = 0 
*table WeekNum lga, c(sd site_RUTF_in) 
*table WeekNum lga, c(sd cum_site_in) 

* TAG only one case of each site
gsort -WeekNumDate
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

* 	Cumulative difference between dispatch and receipt between State and LGA

* corrections for missing data. 
replace future_rept_score=1 if future_rept_score==. 

* If there was no reporting at State or LGA then penalize LGA 100% for diff error. 
replace diff_error =1 if comp_sto_score ==1
* Remove duplicate stock error scores - set diff_error = missing if there was no reporting for 8 weeks
replace diff_error=. if current8 !=1 & comp_sto_score !=1

* if there are no data, then give full penalty
replace overall_calc_error=1 if overall_calc_error==. 





* DOUBLE CHECK THAT THESE ARE VALID FOR PAST 8 WEEKS
gen stock_report_score = round(100 - (comp_sto_score *40)  - (diff_error * 30) - (overall_calc_error * 15) - (dc_score *15))
* is diff error in reverse ?
replace stock_report_score = round(100 - (comp_sto_score *50) - (overall_calc_error * 25) - (dc_score *25)) if Type=="OTP"

order SiteID state lga SiteName comp_sto_score  diff_error overall_calc_error dc_score stock_report_score


* have to make score = same number for site so that recode works - sd must = 0.

* missing - a give away for now. 
table SiteID state if Level!="Site", c (m stock_report_score) 

gen lga_state = lga + " - " + state
* TEMPORARILY
drop if lga_state ==" - "


* Weeknumber for document name
quietly: sum CurrWeekNum, d 
local currentweek = r(p50)
replace CurrWeekNum = `currentweek' 

* create color group for assignment of colors
recode stock_report_score (0/49=1)(50/79=2)(80/100=3), gen(tercile_score)
separate stock_report_score, by(tercile_score) veryshortlabel

format lga_RUTF_out site_RUTF_in cum_lga_out cum_site_in site_RUTF_rec lga_diff state_RUTF_out lga_RUTF_in /// 
	cum_state_out cum_lga_in state_diff RUTF_beg RUTF_in RUTF_out RUTF_bal %8.1f
format twoweeklga fourweeklga med_con_lga %8.0f

* At some point - change site_RUTF_rec to site_RUTF_in
sort SiteID Type WeekNumDate
destring state_code, replace
gen weekly_use = med_con_lga
format weekly_use %8.0f

tab state_code, m 
drop if state_code==0
drop if state_code==3
drop if state_code==7
drop if state_code==30
drop if state_code > 36


* Force graph on state and LGA level stocks to appear
replace WeekNum = CurrWeekNum if WeekNum==. & Level=="First"
list SiteID WeekNum Level if SiteID <= 36


replace RUTF_bal = 0 if WeekNum==CurrWeekNum & Level=="First"	

la var URN "Phone Number"
la var RUTF_bal "RUTF Balance Cartons"
la var weekly_use "Weekly Use Cartons"
la var stocknote "Note"
la var complete_stock_reporting "Percent complete reporting"
la var StoMiss "Missing week reports"

egen one_person = tag(URN)
tab one_person Level, m



* PROBABLE DATA ENTRY ERRORS: 
* - Total number of cases under treatment at the beginning of the week - BEG
* - Total number of new admissions
* - Total RUTF received
* - Total RUTF used
* - Total RUTF in balance 

* drop if report is for future date
replace current8=. if rep_date_error!=0

* create median over past 8 weeks 
bysort SiteID Type: egen med_beg = median(Beg)           if current8==1 & Level =="Site"
bysort SiteID Type: egen med_amar = median(Amar)         if current8==1 & Level =="Site"
bysort SiteID Type: egen med_rutf_in = median(RUTF_in)   if current8==1 & Level =="Site"
bysort SiteID Type: egen med_rutf_out = median(RUTF_out) if current8==1 & Level =="Site"
bysort SiteID Type: egen med_rutf_bal = median(RUTF_bal) if current8==1 & Level =="Site"

sum med_beg, d
local med_beg95 = r(p95)
sum med_amar, d
local med_amar95 = r(p95)
sum med_rutf_in, d
local med_rutf_in99 = r(p99)
sum med_rutf_out, d
local med_rutf_out95 = r(p95)
sum med_rutf_bal, d
local med_rutf_bal99 = r(p99)

gen str20 begnote = "Possible Error - BEG"
gen str24 amarnote = "Possible Error - New Adm"
gen str25 rutfinnote = "Possible Error - RUTF in "
gen str25 rutfoutnote = "Possible Error - RUTF out"
gen str25 rutfbalnote = "Possible Error - RUTF bal"




* Reminders for LGA and State (only Stock)
* Create save file name, for example Sokoto CMAM Report - Week 32

local SITE ="calc_flag==1 & Level!="Site" & current*==1 & state_code==`choosestate'"

* THis is half of the calculation
list med_con_state if WeekNum==1 & state_code==`choosestate'
sum med_con_state if state_code==`choosestate', d
di r(p50)
local twoweek = r(p50)
local fourweek = r(p50) * 2
di `twoweek'
di `fourweek'

sort SiteID Type WeekNumDate

* if below is commented out, does the graph x axis correct itself? 
tostring WeekNum, replace
tostring WeekNumYear, gen(WeekNumYearstr)

gen wn_year = WeekNum +"-"+ WeekNumYearstr






cap log close
 
***************
* STOCKS REPORT
***************



log using "C:\Analysis/`choosestate'_CMAM_Stock_Week`currentweek'.log", replace
set linesize 200
*******************************************************
* MANAGEMENT OF SEVERE ACUTE MALNUTRITION STOCKS REPORT
*******************************************************

list SiteID state CurrWeekNum if SiteID == `choosestate' & one_case==1

* STATE WAREHOUSE STOCK LEVELS
graph bar (sum) RUTF_bal if SiteID==`choosestate', over(WeekNum, sort(diff))	///
	yline(`twoweek', lcolor(red) lwidth(medthick)) 					///
	yline(`fourweek', lcolor(orange)) 								///
	ytitle("RUTF balance")  										///
	title("State Level RUTF Balance") 								///
	note("NOTE: orange line = 4 week stock margin - red line = 2 week stock margin") ///
	saving(state_rutf_bal,replace)

* LGA WAREHOUSE STOCK LEVELS

list WeekNum SiteName Name URN RUTF_bal weekly_use stocknote if Level=="Second" & state_code==`choosestate' & one_case==1, subvar abb(20) noobs 

* STATE AND LGA LEVEL STOCK OUTS (past 8 weeks)

list WeekNum state lga SiteName Name URN RUTF_bal stocknote if stockout==1 & Level!="Site" & state_code==`choosestate', subvar noobs

* OUTPATIENT THERAPEUTIC PROGRAMME LEVEL STOCK OUTS (past 8 weeks)

list WeekNum SiteName Name URN RUTF_bal stocknote if stockout==1 & Type=="OTP" & state_code==`choosestate', subvar noobs

* STABILISATION CENTRE LEVEL STOCK OUTS (F75 and F100 reported in cartons) during past 8 weeks

list WeekNum SiteName Name URN F75_bal F100_bal stocknote if stockout==1 & Type=="SC" & state_code==`choosestate', subvar noobs

* STOCK REPORT SCORES
* are based on 
* 1.  Complete Reporting for all of the previous 8 weeks
* 2.  No errors in STOCK Reports over previous 8 weeks (Ending balance from previous week = opening balance of current week)
* 3.  No errors in accounting STOCK movement from state to LGA or from LGA to OTP. 

* STATE WAREHOUSE STOCK REPORT SCORE
graph hbar (mean) stock_report_score? if Level=="First" , over(state, label(labs(small)) sort(stock_report_score)) /// 
	bar(1, color(red))bar(2, color(orange*.85)) ///
	bar(3,color(green*.75)) legend(off) ///
	title("Stock Reporting Scores at STATE WAREHOUSE", size(medium)) ///
	ytitle("Score") ysc(r(100)) ytick(0(20)100) ylabel(0(20)100) blabel(total) ///
	saving(state_score, replace)

* LGA WAREHOUSE STOCK REPORT SCORE
graph hbar (mean) stock_report_score? if Level=="Second" & state_code==`choosestate' , over(lga_state,  label(labs(small)) sort(stock_report_score)) /// 
	bar(1, color(red))bar(2, color(orange*.85)) ///
	bar(3,color(green*.75)) legend(off) ///
	title("Stock Reporting Scores at LGA WAREHOUSE", size(medium)) ///
	ytitle("Score") ysc(r(100)) ytick(0(20)100) ylabel(0(20)100) blabel(total) ///
	saving(lga_score, replace)

* ALL LGAs in country
*graph hbar (mean) stock_report_score? if Level=="Second" , over(lga_state,  label(labs(small)) sort(stock_report_score)) /// 
*	bar(1, color(red))bar(2, color(orange*.85)) ///
*	bar(3,color(green*.75)) legend(off) ///
*	title("Stock Reporting Scores at LGA WAREHOUSE", size(medium)) ///
*	ytitle("Score") ysc(r(100)) ytick(0(20)100) ylabel(0(20)100) blabel(total) ///
*	saving(lga_score, replace)



* MISSING STOCK REPORTS FROM STATE AND LGA
* Table of Percent of Complete Reporting & Missing Weekly Reports. 
sort complete_stock_reporting

list state SiteID complete_stock_reporting StoMiss if Level=="First" & state_code==`choosestate' & one_case==1,subvar abb(20) noobs 

list lga SiteID complete_stock_reporting StoMiss if Level=="Second" & state_code==`choosestate' & one_case==1, subvar abb(20) noobs 

	

* MISSING PROGRAMME and STOCK REPORTS from OTPs 
* Table of Percent of % Complete Reporting & Missing Weekly Reports for programme and stock data

list lga SiteName SiteID complete_prog_reporting ProMiss complete_stock_reporting StoMiss if Type=="OTP" & state_code==`choosestate' & one_case==1,subvar noobs 



* MISSING PROGRAMME and STOCK REPORTS from FROM SCs
* Table of Percent of % Complete Reporting & Missing Weekly Reports for programme and stock data 

list lga SiteName SiteID complete_prog_reporting ProMiss complete_stock_reporting StoMiss if Type=="SC" & state_code==`choosestate' & one_case==1, subvar noobs 


* PROBABLE DATA ENTRY ERRORS: 
* BEG is the abbreviation for total number of cases under treatment at the beginning of the week
* If there is no table below, then no problems were found.

gsort -med_beg -WeekNum 
list WeekNum lga SiteName URN Type Beg begnote if Beg !=. & Beg > `med_beg95' & state_code==`choosestate' & current8==1 & Level=="Site", noobs


* PROBABLE DATA ENTRY ERRORS: 
* - Total number of new admissions
* If there is no table below, then no problems were found.

gsort -med_amar +WeekNum 
list WeekNum lga SiteName URN Type Amar amarnote if Amar !=. & Amar > `med_amar95' & state_code==`choosestate' & current8==1 & Level=="Site", noobs


* PROBABLE DATA ENTRY ERRORS: 
* - Total RUTF received (RUTF_in)
* If there is no table below, then no problems were found.

gsort -med_rutf_in +WeekNum 
list WeekNum lga SiteName URN RUTF_in rutfinnote if RUTF_in !=. & RUTF_in > `med_rutf_in99' & state_code==`choosestate' & current8==1 & Level=="Site", noobs


* PROBABLE DATA ENTRY ERRORS: 
* - Total RUTF used (RUTF_out)
* If there is no table below, then no problems were found.

gsort -med_rutf_out +WeekNum 
list WeekNum lga SiteName URN RUTF_out rutfoutnote if RUTF_out !=. & RUTF_out > `med_rutf_out95' & state_code==`choosestate' & current8==1 & Level=="Site", noobs


* PROBABLE DATA ENTRY ERRORS: 
* - Total RUTF in balance (RUTF_bal)
* If there is no table below, then no problems were found.

gsort -med_rutf_bal +WeekNum 
list WeekNum lga SiteName URN RUTF_bal rutfbalnote if RUTF_bal !=. & RUTF_bal > `med_rutf_bal99' & state_code==`choosestate' & current8==1 & Level=="Site", noobs




* ERRORS IN STOCK REPORTS
* STATE AND LGA LEVEL ERRORS
sort SiteID Type WeekNum

* The errors are either calculation mistakes of greater than 1 carton of RUTF or calculation mistakes leading negative balances. 
gsort - RUTF_diff

list WeekNum SiteName Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal RUTF_diff if calc_flag==1 & Level!="Site" & current8==1 & state_code==`choosestate', ///
	sepby(SiteID) abb(18) noobs 

* SITE LEVEL ERRORS
sort SiteID Type WeekNumDate
list WeekNum SiteName Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal RUTF_diff if calc_flag==1 & Level=="Site" & current8==1 & state_code==`choosestate',  ///
   sepby(SiteID Type) abb(18) noobs 

sort SiteID Type WeekNumDate

* RUTF DISTRIBUTION and RECEIPTS

* STATE LEVEL DISPATCHES vs LGA LEVEL RECEIPTS
* Please see the following explanations of variable names for table below

*state_RUTF_out 	= RUTF distributed from STATE Warehouse to LGA stores
*lga_RUTF_in 		= RUTF received at LGA stores from STATE Warehouse
*cum_state_out 		= Cumulative total of RUTF distributed from STATE Warehouse to LGA stores
*cum_lga_in 		= Cumulative total of RUTF received at LGA stores from STATE Warehouse
*state_diff 		= Difference between reports from State and LGA
list WeekNum state state_RUTF_out lga_RUTF_in cum_state_out cum_lga_in state_diff if Level=="First" & current8==1 & state_code==`choosestate' , ///
	sepby(SiteID ) abb(18) noobs 

* LGA LEVEL DISPATCHES vs OTP LEVEL RECEIPTS
* Please see the following explanations of variable names for table below

*lga_RUTF_out 	    = RUTF distributed from STATE Warehouse to LGA stores
*site_RUTF_in 		= RUTF received at LGA stores from STATE Warehouse
*cum_lga_out 		= Cumulative total of RUTF distributed from STATE Warehouse to LGA stores
*cum_site_in 		= Cumulative total of RUTF received at LGA stores from STATE Warehouse
*lga_diff 		    = Difference between reports from State and LGA
list WeekNum lga lga_RUTF_out site_RUTF_in cum_lga_out cum_site_in lga_diff if Level=="Second" & current8==1 & state_code==`choosestate' , ///
	sepby(SiteID Type) abb(18) noobs 

	
* PERSONNEL LIST

list Name URN SiteName SiteID state lga Level if state_code==`choosestate' & one_person==1 , noobs

log close

graphlog using /// 
	"C:\Analysis/`choosestate'_CMAM_Stock_Week`currentweek'.log", /// 
	gdirectory(C:/TEMP/Working/) porientation(landscape) fsize(10) lspacing(1) replace
	
* INSTALL graphlog
* ssc install graphlog

* INSTALL pdflatex
* Preferred version is MikTek
* https://miktex.org/howto/install-miktex
	
* add keeptex to option if you want edited latex file. 
* graphlog using "C:\Analysis\CMAMRep.log", gdirectory(C:/TEMP/Working/) porientation(landscape) fsize(10) lspacing(1) keeptex replace

* Graphlog does not work when all graphs are in the same for loop

* If the problem persists, increase the number of characters Stata writes to the log file before creating a line break.  
* Type set linesize # (without the quotes), where # is the maximum number of characters on each line.


END OF Analysis










* should have an overall score not just a stock report score.
* OTP STOCK REPORT SCORE
graph hbar (mean) stock_report_score? if Type=="OTP" & state_code==`choosestate' , over(SiteName, label(labs(half_tiny)) sort(stock_report_score)) /// 
	bar(1, color(red)) bar(2, color(orange*.85)) bar(3,color(green*.75)) legend(off) ///
	title("Stock Reporting Scores at OTP", size(medium)) ///
	ytitle("Score") ysc(r(100)) ytick(0(20)100) ylabel(0(20)100)  ///
	saving(otp_score, replace)



*graph combine male_salary.gph female_salary.gph, col(1) saving(salary_by_sex,replace)
*graph use salary_by_sex
*graph export salary_by_sex.pdf

*translate “Stata Log for module 2 exercises.smcl” “Stata Log for module 2 exercises.pdf”



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



END

graphlog using C:\Analysis/2_CMAM_Stock_Week46.log, gdirectory(C:/TEMP/Working/) porientation(landscape) fsize(10) lspacing(1) replace

destring WeekNum, gen(weeknumns)
sort SiteID weeknumns
order SiteID weeknumns
