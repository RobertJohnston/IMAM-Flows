* LGA stocks analysis

set more off
cap log close
cd C:\TEMP\Working\

* Quality Reporting Score

* Complete reporting 			40%
* Timely reporting				5%
* Reports sent for future dates 5%
* Unaccounted for stocks 		25%
* 	State is punished for errors between State and LGA
* 	LGA is punished for errors between LGA and Site. 
* Errors in calculations 		25%
* 	Errors in calculations (>1 carton)
* 	Negative starting balance
* 	Reporting in decimal points


* the database with all viable program and stock reports included
use CMAM_delete.dta, clear

* if the variables are not complete - then include the following. 
sort SiteID
format SiteID %12.0f
tab Type, m 

* Define Level 
replace Level = "Site" if SiteID >101110000
replace Level = "Second" if SiteID < 9999 & SiteID > 99
replace Level = "First" if SiteID < 99
tab Level, m 

* Role
replace Role="Supervision" if Level=="First" | Level=="Second"
tab Role, m 

***************
* DATA CLEANING

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

***************

destring lga_code, replace
save temp.dta, replace

* LGA
* Sum of all LGA level RUTF receipts by week - collapse and merge data back into database
* For comparison to state_RUTF_out
gen lga_RUTF_in = RUTF_in if Level=="Second"
collapse (sum) lga_RUTF_in, by(WeekNum)
save collapse.dta, replace

use temp.dta, clear
merge m:m WeekNum using "C:\TEMP\Working\collapse.dta"
drop _merge
save temp.dta, replace

* Implementation site
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


* If there is one future report in past 8 weeks, then site loses points

*******
* drop if WeekNum > CurrWeekNum
* maybe drop data and record as data from future. 
* should analyse quality and then report. 
*******

* replace Role = "Implementation" if SiteID is 
replace Role= "Implementation" if SiteID >9999

* There should be no rows with Level ==""
list Type Level Role if Level ==""
 
* List sites with STOCK OUTS of RUTF F75 F100
* Stock is < 15 sachets RUTF or 1 sachet of F75 or F100
gen stockout = 1 if RUTF_bal<0.10 | F75_bal< 0.01 | F100_bal<0.011
* RUTF - Sachets per carton - 150 (0.1 = less than 15 sachets)
* F75 - Sachets per carton - 120 (0.0083 = less than 1 sachet)
* F100 - Sachets per carton - 90 (0.011 = less than 1 sachet)

* Variable Names
la var WeekNum "Week Number"

bysort SiteID: egen most_recent_report = max(WeekNum)
tab most_recent_report, m 

save temp, replace

* enter the number of missing reports
* the database missingrepttot.sav - contain one line for each person - there are more than one reports per site. 
* the data are only for the current week. 
* merge by SiteID and Type
use "C:\TEMP\Working\missingrepttot.dta", clear
destring lga_code, replace
* Why is there merge already defined ? 
cap drop _merge
sort SiteID Type
replace Type="Sup" if SiteID <101110000
egen count_of_site=tag(SiteID Type)
order SiteID Type count_of_site
drop if count_of_site !=1
gen comp_sto_score = StoReptTot * (50/8)
gen comp_pro_score = ProReptTot * (50/8)

tab comp_sto_score, m 
tab comp_sto_score state if Level=="First", m 
* You can't have two states. 
* Maybe an SC or OTP mixed in 

tab comp_pro_score, m 

save "C:\TEMP\Working\missingrepttot.dta", replace


use temp, clear
merge m:m SiteID Type using "C:\TEMP\Working\missingrepttot.dta"
* drop merge
drop if _merge==2
drop Pd* Sd* ProMiss StoMiss _merge
* save temp.dta, replace

* ProReptTot = number of complete program reports
* StoRepTot  = number of complete stock reports

***************
* Check report date in future.  
* If there is no report, then don't worry about report date in future. 
tab RepWeekNum if rep_date_error==2, m 
tab report_date if rep_date_error==2, m 
* 56 cases of missing data
***************




* Here remove the stockout warning if the report is not current. 
replace stockout=0 if most_recent_report != WeekNum

*list WeekNum state lga SiteName Type Name URN RUTF_in RUTF_out RUTF_bal if stockout==1 & Level!="Site"
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
order WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal F100_bal F75_bal
* if RUTF_beg is missing then calculate. 
replace RUTF_beg = RUTF_bal - RUTF_in + RUTF_out if RUTF_beg ==.

gen calc_bal = RUTF_beg + RUTF_in - RUTF_out 
gen rutf_diff = RUTF_bal - calc_bal
replace rutf_diff = 0 if rutf_diff < 0.01

* Types of Errors
* neg_error = RUTF_beg < 0  or  Calc_bal < 0
* calc_error = rutf_bal !=0
gen calc_error =1 if rutf_diff>1 & rutf_diff !=.
gen neg_error =1 if RUTF_beg<-0.1 | calc_bal<-0.1 
tab calc_error, m 
tab neg_error, m 
gen error = 0
replace error=1 if calc_error==1 | neg_error==1

format RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal rutf_diff %12.2g
order WeekNum RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal rutf_diff Type
* Should identify all errors first, then do analysis. 
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Level!="Site"
*list WeekNum state lga SiteName Type Name URN RUTF_beg RUTF_in RUTF_out RUTF_bal if error==1 & Type=="OTP"
*list WeekNum state lga SiteName Type Name URN F75_bal F100_bal 	     if error==1 & Type=="SC"


* Weekly Consumption of RUTF from ALL implementation sites
* graph bar (sum) RUTF_out if Type=="OTP", over(WeekNum) 
table WeekNum state, c(sum RUTF_out), if Type=="OTP"

* STATE weekly RUTF consumption from implementation sites
bysort WeekNum: egen state_cons_week = total(RUTF_out) if Type=="OTP"

sort SiteID WeekNum Type
order SiteID WeekNum Type RUTF_beg RUTF_in RUTF_out RUTF_bal calc_bal state_cons_week

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
label define lganame 1 Binji 4 Gada 5 Goronyo 6 Gudu 8 Illela 13 "Sabon Birni" 16 "Sokoto North" 17 "Sokoto South" 19 Tangaza  21 Wamakko 
la val lga_code lganame
tab lga_code
	




************************************
* Dispatches versus Receipts - STATE
************************************
gen state_RUTF_out = RUTF_out if Level=="First"
replace lga_RUTF_in=. if Level!="First"

* State level dispatches and LGA level receipts by weekly of RUTF 

* Graph below by month
* report date does not correspond to weeknum of report
* gen RepMonth = month(report_date)

gen RepMonth =  mofd(dofw(yw(Year,WeekNum)))
format RepMonth %tmMon
tab RepMonth, m 
* gen month_weeknum = RepMonth

sort SiteID RepMonth WeekNum Type
order SiteID RepMonth WeekNum Type

by SiteID: gen cum_state_des=sum(state_RUTF_out)
* this calculates cumulative sum for all data LGA RUTF in  - no need to select certain LGAs
by SiteID: gen cum_lga_rec=sum(lga_RUTF_in)

* To reset this graph every month use line below
* by SiteID RepMonth: gen cum_state_des=sum(state_RUTF_out)
* by SiteID RepMonth: gen cum_lga_rec=sum(lga_RUTF_in)

* Difference in state and LGA reports
gen state_diff = cum_state_des - cum_lga_rec
replace state_diff=. if state_diff==0

order state_RUTF_out lga_RUTF_in cum_state_des cum_lga_rec state_diff SiteID Level 

* How to report these data
*list WeekNum state state_RUTF_out lga_RUTF_in cum_state_des cum_lga_rec state_diff if Level=="First" 
* table WeekNum, c(sum state_RUTF_out sum lga_RUTF_in)
* graph bar (sum) state_RUTF_out lga_RUTF_in, over(WeekNum)
* graph bar (sum) cum_state_des cum_lga_rec state_diff , over(WeekNum) ///
*	bar(1,color(eltblue)) bar(2,color(edkblue)) bar(3,color(red))	///
*	title(State RUTF Dispatches and LGA Receipts) 					///
*	legend( label(1 "Cumulative State RUTF Distribution") label(2 "Cumulative LGA RUTF Receipts") label(3 "Difference") pos(6) cols(1))


* Weekly balance of RUTF at LGA level
* for the LGA level graph, report only the RUTF balance in the LGA stores
gen lga_rutf_bal = RUTF_bal if Level=="Second"




* RUTF DISTRIBUTION and RECEIPTS
************************************
* Dispatches versus Receipts - LGA
************************************
* LGA level dispatches and Implementation site level receipts of RUTF by week 
des lga_RUTF_out 
* calculate total site site_RUTF_in by week number
des site_RUTF_in

* These variables were calculated by aggregate / collapse function at beginning of this file. 
bysort SiteID: gen cum_lga_des=sum(lga_RUTF_out)
* this calculates cumulative sum for all data LGA RUTF in  - no need to select certain LGAs
gen site_RUTF_rec = site_RUTF_in if Level=="Second"
bysort SiteID : gen cum_site_rec=sum(site_RUTF_rec)
* Cannot use mean if site level data is 0 not missing. 
replace cum_site_rec=. if cum_site_rec==0

* Difference between state and LGA reports
gen lga_diff = cum_lga_des - cum_site_rec
format lga_diff %12.1f
* Cannot use mean if lga_diff site level data is 0 not missing. 
replace lga_diff=. if Level !="Second"

sort lga SiteID WeekNum Type
order lga SiteID lga_RUTF_out site_RUTF_in cum_lga_des cum_site_rec site_RUTF_rec lga_diff  Level WeekNum 

* no errors when SD = 0 
* table WeekNum lga, c(sd site_RUTF_rec) 
* table WeekNum lga, c(sd cum_site_rec) 

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
* We can do this graph by month / if desirable. 



* missing stock reports
gen comp_sto_rep = 100 if RUTF_in!=. & RUTF_out!=. & RUTF_bal!=. 
* one here represents the opportunity to send a stock report. 
gen one=1
bysort Level WeekNum: egen count_stock_rep = count(one)    
bysort Level: egen max_stock_rep = max(count_stock_rep)
gen miss_stock_rep = max_stock_rep - count_stock_rep
gen miss_stock_rep2= miss_stock_rep if Level=="Second"

* STATE level table. 
table WeekNum, c(sum state_RUTF_out sum lga_RUTF_in sum state_diff mean miss_stock_rep2) f(%8.0f)

* Need complete reporting table for STATE and LGA
la def complete_report 1 Yes
la val comp_sto_rep complete_report 

table WeekNum SiteName  if Role=="Supervision", c(sum comp_sto_rep)



*tab WeekNum comp_sto_rep if Level=="Second"

	
* Consumption of RUTF at LGA level 
* RUTF_in RUTF_out RUTF_bal F75_bal F100_bal
format RUTF_in RUTF_out RUTF_bal F75_bal F100_bal %8.1f

* Research project
* What is difference between reporting with or without sachets at OTP level

* How to calculate poor quality reporting
* keep only past 8 weeks of reporting - no past or future data accepted
* 8 weeks will create a moving block of data that allows to show improvements over time. 

* Score
* Complete Reporting
* Errors in balance reporting
* Reporting in decimal points
* cumulative difference between dispatch and receipt between State and LGA




***************
*  START HERE
***************

* Bauchi  5
* Gombe  16
* Jigawa 17
* Sokoto 33

local choosestate = 17

local currentweeknum = CurrWeekNum
* Reminders for LGA and State (only Stock)
local report_name = "CMAM_Report_Week" + "`currentweeknum'" 



***************
* STOCKS REPORT
***************

sort SiteID WeekNum

format lga_RUTF_out site_RUTF_in cum_lga_des cum_site_rec site_RUTF_rec lga_diff state_RUTF_out lga_RUTF_in /// 
	cum_state_des cum_lga_rec state_diff RUTF_beg RUTF_in RUTF_out RUTF_bal %8.1f

* log using "C:\Analysis\CMAMRep.log", replace

*******************************************************
* MANAGEMENT OF SEVERE ACUTE MALNUTRITION STOCKS REPORT
*******************************************************

graph bar (sum) RUTF_bal if SiteID==`choosestate', over(WeekNum) 	///
	yline(`twoweek', lcolor(red) lwidth(medthick)) 					///
	yline(`fourweek', lcolor(orange)) 								///
	ytitle("RUTF balance")  										///
	title("State Level RUTF Balance") 								///
	note("NOTE: orange line = 4 week stock margin - red line = 2 week stock margin") ///
	saving(state_rutf_bal,replace)


* MISSING STOCK REPORTS FROM STATE AND LGA

* 1 in table below means a report was submitted. A blank means that no report was received. 
table WeekNum SiteName if Role=="Supervision" & Type !="OTP" & Type !="SC", c(sum comp_sto_rep) cell(11)




* STATE AND LGA LEVEL STOCK OUTS

list WeekNum state lga SiteName Type Name URN RUTF_bal if stockout==1 & Level!="Site"


* OUTPATIENT THERAPEUTIC PROGRAMME LEVEL STOCK OUTS

list WeekNum SiteName Name URN RUTF_bal if stockout==1 & Type=="OTP"


* STABILISATION CENTRE LEVEL STOCK OUTS (F75 and F100 reported in cartons)

list WeekNum SiteName Name URN F75_bal F100_bal if stockout==1 & Type=="SC"



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
*cum_state_des 		= Cumulative total of RUTF distributed from STATE Warehouse to LGA stores
*cum_lga_rec 		= Cumulative total of RUTF received at LGA stores from STATE Warehouse
*state_diff 		= Difference between reports from State and LGA

list WeekNum state state_RUTF_out lga_RUTF_in cum_state_des cum_lga_rec state_diff if Level=="First" 

graph bar (sum) cum_state_des cum_lga_rec state_diff , over(WeekNum) ///
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
