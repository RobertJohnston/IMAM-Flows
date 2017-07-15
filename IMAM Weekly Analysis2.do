* IMAM Weekly Analysis 2
set more off
use "C:\TEMP\Working\REG_delete", clear

* Crash if SiteID and Type were not selected in the download from RapidPro.
des SiteID
des Type

* Site Level Data

*Include only one SiteID for merge with programme data. 
bysort SiteID Type: egen SiteIDord = seq()
tab SiteIDord, m
drop if SiteIDord !=1

*Remove uninterpretable data.
drop if SiteID ==.

drop if SiteName=="" & Type=="OTP" 
drop if SiteName=="" & Type=="SC"

keep   SiteID SiteName Type state_code state lga_code lga 
order  SiteID SiteName Type state_code state lga_code lga 

tab Type, m
* This is not a unique list of SITES
* THERE ARE SITES DOUBLE COUNTED if the Type was not specified
* Run reminders to enter the site Type to those groups

save "C:\TEMP\Working\SITE_delete", replace
* Complete list of sites

	
****************
* Programme Data	
****************
import excel "C:\TEMP\pro.xlsx", sheet("Runs") firstrow clear
* Do not use the tab "Contacts" as it is incomplete. 
* Make crash if SiteID is not included
* YOU MUST INCLUDE in the download. 
des SiteID

destring SiteID, gen(SiteIDtemp)force
* This has been corrected in RapidPro
replace SiteIDtemp = 3301110008 if SiteID == "33 01 11 0008"

* Level (First, Second, or Implementation Site)
* Role (Supervision or Implementation)
* gen Role = RoleCategory
gen Role = SiteIDCategoryIMAMProgram
replace Role = "Implementation" if Role =="" & SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Role = "Implementation" if Role =="Other" & SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Role = "Supervision" if Role =="" & SiteIDtemp < 3699
replace Role = "Supervision" if Role =="Other" & SiteIDtemp < 3699
replace Role = "" if Role =="Other" 
replace Role = "" if SiteIDtemp ==99
tab Role, m 

gen Level = SiteIDValueIMAMProgram
replace Level = "Site" if SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Level = "Second" if SiteIDtemp > 101 & SiteIDtemp < 3699
replace Level = "First" if SiteIDtemp >= 1 & SiteIDtemp <= 36
replace Level = "" if SiteIDtemp ==99
tab Level, m 

* SiteID for programme data report
* Replace SiteID if report is sent from LGA or State level 
replace SiteID = ProSiteIDValue if Level !="Site"

* Type of site for programme data report (OTP or SC)
* You cannot assume that Type is correct for supervision level when it comes from the contact data. 
cap drop Type
gen Type = TypeValue 
replace Type = ProTypeCategory if Level !="Site"
tab Type, m 

* Week Number
destring WeekNumValue, gen(WeekNum) force
* delete entry if week number is not integer
drop if WeekNum != floor(WeekNum)
*replace WeekNum = floor(WeekNum)
tab WeekNum, m

gen report_date = dofc(LastSeen)
format report_date %td
gen Year = year(report_date)
* Unfortunate Error of poorly trained personnel
* Week 1 was reported as Week 53 at end of 2016 
*************
* don't reuse this code in 2018 or later
************* 
replace WeekNum = 1 if WeekNum ==53 

* Age Group (only used currently in SC)
gen AgeGroup = "6-59m" if Type =="OTP"
* When there is reporting for children 0-5m in OTP will have to change line above. 
replace AgeGroup = agegroupCategory if Type =="SC"
tab AgeGroup, m 

* Data from OTP flow (o stands for OTP)
gen Beg =  Beg_oValue
gen Amar = Amar_oValue
gen Tin =  Tin_oValue
gen Dcur = Dcur_oValue
gen Dead = Dead_oValue
gen Defu = DefU_oValue
gen Dmed = Dmed_oValue
gen Tout = Tout_oValue

* Data from In Patients (Stabilisation Centre) flow (i stands for IPF)
replace Beg =  Beg_iValue  if Type=="SC"
replace Amar = Amar_iValue if Type=="SC"
replace Tin =  Tin_iValue  if Type=="SC"
replace Dcur = Dcur_iValue if Type=="SC"
replace Dead = Dead_iValue if Type=="SC"
replace Defu = DefU_iValue if Type=="SC"
replace Dmed = Dmed_iValue if Type=="SC"
replace Tout = Tout_iValue if Type=="SC"

destring Beg Amar Tin Dcur Dead Defu Dmed Tout, replace force

* Drop data that are not confirmed, answered with NO
drop if ConfirmCategory !="Yes"
tab ConfirmCategory, m 

* Delete training data ( program and stock data that goes 1,2,4,6,8… ) 
* always review carefully after training.
drop if Beg==2 & Amar ==4 & Tin==6
drop if Dead==10 & Defu ==12 & Dmed==14

* Drop if SiteID = X
drop if SiteID =="X"

* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).
* Do not replace old data if the newer programme report is empty. 
gen PROnodata = Beg==. & Amar==. & Tin==. & Dcur==. & Dead==. & Defu==. & Dmed==. & Tout==.
* Note 1 = no data 
drop if PROnodata ==1

destring SiteID, replace force
format SiteID %10.0f

* Drop program data with SiteID's that are not correct. 
drop if SiteID < 101110001

* Remove duplicates
gsort SiteID Type WeekNum  -LastSeen
by SiteID Type WeekNum : egen unique = seq()
order SiteID Type WeekNum Level
* Double check the selection of older entries to drop
tab unique, m 
* order SiteID WeekNum Name unique LastSeen Beg Amar
drop if unique !=1 

keep URN Name SiteID WeekNum Role Level Type AgeGroup Beg Amar Tin Dcur Dead Defu Dmed Tout FirstSeen LastSeen

sort SiteID WeekNum

save "C:\TEMP\Working\PRO_delete", replace

****************
* Stocks data - Site
****************
import excel "C:\TEMP\sto.xlsx", sheet("Runs") firstrow clear
* MUST INCLUDE in the download. 
* SiteID 
des SiteID

drop if SiteID =="Nat"
drop if SiteID =="Aclo 1234567890"

* drop if data are reported as incorrect(confirmation)
drop if ConfirmCategoryIMAMStock !="Yes"
tab ConfirmCategoryIMAMStock, m 

destring SiteID, gen(SiteIDtemp) force

* Role (Implementation or Supervision)
* gen Role = PostLevelCategory

gen Role = SiteIDCategoryIMAMStock
replace Role = "Implementation" if Role =="" & SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Role = "Implementation" if Role =="Other" & SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Role = "Supervision" if Role =="" & SiteIDtemp < 3699
replace Role = "Supervision" if Role =="Other" & SiteIDtemp < 3699
replace Role = "" if Role =="Other" 
replace Role = "" if SiteIDtemp ==99
tab Role, m 

* Level (Site, Second, First, National
* gen Level = PostLevelValue
gen Level = SiteIDValueIMAMStock
replace Level = "Site" if SiteIDtemp > 101110001 & SiteIDtemp < 3699990999
replace Level = "Second" if SiteIDtemp > 101 & SiteIDtemp < 3699
replace Level = "First" if SiteIDtemp >= 1 & SiteIDtemp <= 36
replace Level = "" if SiteIDtemp ==99
tab Level, m 




* SiteID
tostring StoSiteIDValueIMAMStock, replace
* If LGA FP is reporting for a site. 
replace SiteID = StoSiteIDValueIMAMStock if SelfReportCategory =="No"
destring SiteID, replace force
format SiteID %10.0f

* Type (OTP or SC)
cap drop Type
* There is no Type var in data.
gen Type = route_by_typeCategoryIMAMS
replace Type="" if Type!="OTP" & Type!="SC"
*route_by_type  /// new var name
* replace Type if reported by LGA FP 
replace Type= StoTypeCategoryIMAMStock if Type==""

* DOUBLE CHECK IF THE TYPE VAR NAME IS CORRECT. 

* WeekNum
destring WeekNumValue, gen(WeekNum) force
replace WeekNum = floor(WeekNum)
tab WeekNum, m

gen report_date = dofc(LastSeen)
format report_date %td
gen Year = year(report_date)
* Unfortunate Error of poorly trained personnel
* Week 1 was reported as Week 53 at end of 2016 / don't reuse over years 
replace WeekNum = 1 if WeekNum ==53 


drop WeekNumCategoryIMAMStock WeekNumValueIMAMStock WeekNumTextIMAMStock

* Review RUTF stock
destring RUTF_inValue RUTF_used_cartonValue RUTF_used_sachetValue RUTF_bal_cartonValue RUTF_bal_sachetValue /// 
	F75_bal_cartonValue F75_bal_sachetValue F100_bal_cartonValue F100_bal_sachetValue, replace force
gen R_in  = RUTF_inValue
gen R_outCART = RUTF_used_cartonValue
gen R_outSACH = RUTF_used_sachetValue
gen R_balCART = RUTF_bal_cartonValue
gen R_balSACH = RUTF_bal_sachetValue

* DOUBLE COUNTING
* Test for double counting in RUTF reporting.
* If RUTF in Sachets is more than 149, then assume that they double reported and gave total in sachets. 
* this hides errors that need to be corrected. 
* Must leave errors visible. 
list RUTF_used_cartonValue RUTF_used_sachetValue if RUTF_used_sachetValue> 150 & RUTF_used_sachetValue!=. , abb(20)

gen dc_util = 0
la var dc_util "Double counting-RUTF utilisation"
replace dc_util = 1 if RUTF_used_sachetValue > 149
replace dc_util = 0 if RUTF_used_cartonValue==0
replace dc_util = 1 if RUTF_used_cartonValue==RUTF_used_sachetValue & RUTF_used_cartonValue>6
* next line not necessary
replace dc_util = 0 if RUTF_used_cartonValue==0 | RUTF_used_sachetValue==0
replace dc_util = 0 if RUTF_used_cartonValue==. | RUTF_used_sachetValue==. 
tab dc_util, m 
list RUTF_used_cartonValue RUTF_used_sachetValue dc_util if dc_util ==1  , abb(20)

gen dc_bal = 0
la var dc_bal "Double counting-RUTF balance"
replace dc_bal = 1 if RUTF_bal_sachetValue > 149
replace dc_bal = 0 if RUTF_bal_cartonValue==0
replace dc_bal = 1 if RUTF_bal_cartonValue==RUTF_bal_sachetValue & RUTF_bal_cartonValue>6
* next line not necessary
replace dc_bal = 0 if RUTF_bal_cartonValue==0 | RUTF_bal_sachetValue==0
replace dc_bal = 0 if RUTF_bal_cartonValue==. | RUTF_bal_sachetValue==. 
tab dc_bal, m 

* Save in final datafile for review in Report
gen RUTF_used_cart = RUTF_used_cartonValue
gen RUTF_used_sach = RUTF_used_sachetValue
gen RUTF_bal_cart = RUTF_bal_cartonValue
gen RUTF_bal_sach = RUTF_bal_sachetValue

* List WeekNum state 
list RUTF_used_cart RUTF_used_sach dc_util if dc_util ==1  , abb(20)
list RUTF_bal_cart RUTF_bal_sach dc_bal if dc_bal ==1  , abb(20)


* STOCKS REPORTING
* in OTP, we assume out is distributed to and used or consumed by beneficiaries. 
* in LGA and State warehouses out means despatched or distributed to the site level. 

* RUTF STOCKS
gen RUTF_in = RUTF_inValue
* Convert sachets to decimals
gen RUTF_out = RUTF_used_cartonValue + (RUTF_used_sachetValue/150)
gen RUTF_bal = RUTF_bal_cartonValue + (RUTF_bal_sachetValue/150)

* F75 & F100 STOCKS
* F75 - Sachets per carton - 120
gen F75_bal = F75_bal_cartonValue + (F75_bal_sachetValue/120)
* F100 - Sachets per carton - 90
gen F100_bal = F100_bal_cartonValue + (F100_bal_sachetValue/90)

* Cleaning.
* Drop if error in SiteID for Site level stock reports.  All site level stock reports must have a valid SiteID. 
drop if SiteID <101110002

* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).
* First drop empty reports
gen STOnodata = RUTF_in==. & RUTF_out==. & RUTF_bal==. & F75_bal==. & F100_bal==. 
* Note 1 = no data 
drop if STOnodata ==1

* Remove duplicates
gsort SiteID Type WeekNum -LastSeen
by SiteID Type WeekNum: egen unique = seq()
order SiteID Type WeekNum
tab unique, m 
drop if unique !=1

keep URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen dc_util dc_bal
order URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen 
sort SiteID Type WeekNum

save "C:\TEMP\Working\STO_delete", replace

****************
* Stocks data - LGA STATE
****************
import excel "C:\TEMP\lga.xlsx", sheet("Runs") firstrow clear
* Crash if SiteID is not present - MUST INCLUDE in the download. 
des SiteID 

* Drop if confirmation equals No or SiteID = X
drop if ConfirmCategory !="Yes"
tab ConfirmCategory, m 

* Saratu Aduwak of KADUNA was registered with SiteID 18/S 
replace SiteID = "18" if SiteID =="18/S"

destring SiteID, replace force
* tab SiteID, m

* tab WeekNumValueIMAMLGAState, m 
destring WeekNumValueIMAMLGAState, gen(WeekNum) force
* WeekNum
replace WeekNum = floor(WeekNum)
* tab WeekNum, m

* The State and LGA stocks are only for the reporter's SiteID. 
* Remove all entries with incorrect SiteIDs
sort SiteID WeekNum
order SiteID WeekNum


gen report_date = dofc(LastSeen)
format report_date %td
gen Year = year(report_date)
* Unfortunate Error of poorly trained personnel
* Week 1 was reported as Week 53 at end of 2016 / don't reuse over years 
replace WeekNum = 1 if WeekNum ==53 


* RUTF_in is string
gen RUTF_in = RUTF_inValue
gen RUTF_out = RUTF_outValue
gen RUTF_bal = RUTF_balValue
destring RUTF_in RUTF_out RUTF_bal, replace force



* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).

gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()
order SiteID WeekNum LastSeen report_date RUTF_in RUTF_out RUTF_bal unique
drop if unique !=1

keep URN Name SiteID WeekNum RUTF_in RUTF_out RUTF_bal LastSeen FirstSeen 
order URN Name SiteID WeekNum RUTF_in RUTF_out RUTF_bal LastSeen FirstSeen 

save "C:\TEMP\Working\LGA_delete", replace

*******
* MERGE ALL FOUR DATABASES TOGETHER
*******

* Add other SiteIDs that have no reporting to ensure that we send reports to all sites. 
use "C:\TEMP\Working\SITE_delete.dta", clear
merge 1:m SiteID Type using "C:\TEMP\Working\PRO_delete"
drop _merge
save "C:\TEMP\Working\PRO_delete", replace

use "C:\TEMP\Working\SITE_delete.dta", clear
merge 1:m SiteID Type using "C:\TEMP\Working\STO_delete"
drop _merge
save "C:\TEMP\Working\STO_delete", replace

use "C:\TEMP\Working\SITE_delete.dta", clear
* Drop errors in SiteID
drop if SiteID >9999 
* Drop National Level 
drop if SiteID ==0
* Drop reporters who are no longer working in IMAM
drop if SiteID ==99
* Error with Batsari LGA Katsina
drop if SiteID == 2003 & SiteName==""
* REmove IMAM supervision and check if this error still exists.


merge 1:m SiteID using "C:\TEMP\Working\LGA_delete"
drop _merge
save "C:\TEMP\Working\LGA_delete", replace

* Merge with Programme with Stocks Data
use "C:\TEMP\Working\PRO_delete.dta", clear
merge 1:1 SiteID Type WeekNum using "C:\TEMP\Working\STO_delete"
append using "C:\TEMP\Working\LGA_delete"
drop _merge

drop if SiteID ==.


* FINAL CLEANING

* Cannot use STATA command for week number
* Stata does not follow the ISO definition of weeknumber whereby week 1 always begins on 1 January and week 52 is always 8 or 9 days long.
* Cannot use week function in Stata on current date. To avoid this error, just convert weeknumbers into dates. 
gen report_date = dofc(LastSeen)
format report_date %td

gen Year = year(report_date)
la var Year "Year of Report"

* Calculate ISO REPORT week number
* RepWeekNum
* Test if leap year
generate leap = cond(mdy(2,29,year(report_date)) < . , 1, 0)
gen dow = dow(report_date)
* Set sunday to 7 not zero. Sunday is last day of week for ISO weeks.
replace dow = 7 if dow==0
gen month = month(report_date)
* Calculate ordinal date
recode month (1=0)(2=31)(3=59)(4=90)(5=120)(6=151)(7=181)(8=212)(9=243)(10=273)(11=304)(12=334), gen(temp)
* for leap years
recode month (1=0)(2=31)(3=60)(4=91)(5=121)(6=152)(7=182)(8=213)(9=244)(10=274)(11=305)(12=335), gen(temp2)
gen ord_date = cond(leap==1, temp2 + day(report_date), temp + day(report_date))
gen RepWeekNum =  floor(((ord_date - dow) + 10 ) / 7)
* If RepWeekNum = 0 then recode to 52 of 53
replace RepWeekNum = 52 if RepWeekNum==0 
replace RepWeekNum = 53 if RepWeekNum==0 & leap==1
* If a week number of 53 is obtained, one must check that the date is not actually in week 1 of the following year.


* Calculate ISO CURRENT week number
* CurrWeekNum
gen current_date = date("$S_DATE", "DMY") 
format current_date %td
replace leap = cond(mdy(2,29,year(current_date)) < . , 1, 0)
replace dow = dow(current_date)
* Set sunday to 7 not zero. 
replace dow = 7 if dow==0
replace month = month(current_date)
* Calculate ordinal date
drop temp temp2
* for normal years
recode month (1=0)(2=31)(3=59)(4=90)(5=120)(6=151)(7=181)(8=212)(9=243)(10=273)(11=304)(12=334), gen(temp)
* for leap years
recode month (1=0)(2=31)(3=60)(4=91)(5=121)(6=152)(7=182)(8=213)(9=244)(10=274)(11=305)(12=335), gen(temp2)
replace ord_date = cond(leap==1, temp2 + day(current_date), temp + day(current_date))
gen CurrWeekNum =  floor(((ord_date - dow) + 10 ) / 7)
* If a week number of 53 is obtained, one must check that the date is not actually in week 1 of the following year.
* If Thursday of first week of Jan day of week < 4 then assign week to following year. 
disp CurrWeekNum
local CurrWeekNumTemp = CurrWeekNum


* LastSeen in the RapidPro data is the date of the reported flow. 
* Calculate difference between weeknum and report date. 
gen weekdiff =  WeekNum - RepWeekNum
gen weekdifftemp = weekdiff
* majority of errors of reporting in future are only 2 weeks in future
* assume that report was made for past if more than 2 weeks in future. 
* THIS IS A BAD HACK - USE DATES
* here should use exact dates - year, weeknum
* we know that the year is within 8 weeks of report date.

* line below recodes the weekdiff for change of years - Between 44 and 52 (53) weeks of weekdiff
replace weekdiff = WeekNum - 52 - RepWeekNum if weekdifftemp > 2
drop weekdifftemp

* First calculate weekdiff
gen rep_date_error = 0
replace rep_date_error = 1 if weekdiff < -8
replace rep_date_error = 2 if weekdiff > 0 
replace rep_date_error = 9 if WeekNum ==.
la def date_error 0 "No error" 1 "Report > 8 weeks in the past" 2 "Report week number in future" 9 "Missing WeekNum"
label val rep_date_error date_error
tab rep_date_error, m 

* WeekNumDate is 7 days x # of week numbers difference from Report Date
* Remove number of weeks from report date
gen WeekNumDate = report_date + (weekdiff*7)
* weekdiff is a negative number
format WeekNumDate %td

* hack to correct dates of WeekNumDate
* replace january 1st to january 2nd (week 1 2017)
replace WeekNumDate = date("20170102","YMD") if WeekNumDate ==date("20170101","YMD")
* replace january 4th to january 2nd (week 1 2017)
replace WeekNumDate = date("20170102","YMD") if WeekNumDate ==date("20170104","YMD")
replace WeekNumDate = date("20161226","YMD") if WeekNum == 52
* Be careful these corrections may be too aggressive


* There are more than one dates per WeekNum - There should be only one for calculation purposes
*list WeekNumDate if WeekNum==1
gen WeekNumYear = year(WeekNumDate)
bysort WeekNum WeekNumYear: egen WeekNumDateTemp = min(WeekNumDate)
replace WeekNumDate = WeekNumDateTemp
drop WeekNumDateTemp
* check if calculation was correct
order SiteID WeekNum WeekNumDate WeekNumYear RepWeekNum report_date Year CurrWeekNum current_date weekdiff
tab WeekNumDate, m 


* double check correct logic error in weekdiff calculation
* order rep_date_error current_date CurrWeekNum Year report_date RepWeekNum WeekNum WeekNumDate weekdiff, last
* sort weekdiff

save "C:\TEMP\Working\CMAM_delete", replace

list if WeekNum == 53



* REMOVE LGA and STATE level data from CMAM dashboard 
* Include LGA and State data in dashboard data ? No.

****************************
* EXPORT FOR EXCEL DASHBOARD
****************************
sort SiteID Type WeekNum
* Drop STATE and LGA data
drop if SiteID < 9999

* Delete data if there is a reporting date error (in ancient past or future)
* no data are analysed from future or more than 8 weeks prior to report date. 
drop if rep_date_error ==1 | rep_date_error ==2 






gen id = [_n]
gen End = Beg + Amar + Tin - Dcur - Dead - Defu - Dmed - Tout

gen stockcode = "RUTF"

* Create instock variable. 
* RUTF_beg does not exist until it is created here - replace RUTF_beg with last weeks balance
* Stocks reporting is simplified, only RUTF in, out and balance. 
gen RUTF_beg= . 
replace RUTF_beg = RUTF_bal[_n-1] if SiteID==SiteID[_n-1] & Type==Type[_n-1] & WeekNum==WeekNum[_n-1]+1

* REMOVED F100 and F75 from Excel Dashboard

keep id state lga SiteName SiteID Type Year WeekNum report_date URN AgeGroup Beg Amar Tin Dcur ///
     Dead Defu Dmed Tout End stockcode RUTF_beg RUTF_in RUTF_out RUTF_bal  
order id state lga SiteName SiteID Type Year WeekNum report_date URN AgeGroup Beg Amar Tin Dcur ///
     Dead Defu Dmed Tout End stockcode RUTF_beg RUTF_in RUTF_out RUTF_bal  

tab AgeGroup
tab Beg 
tab Amar 
tab Tin 
tab Dcur
tab Dead
tab Defu
tab Dmed
tab Tout

* Data cleaning
drop if URN ==""

* Drop if WeekNum or State is missing
drop if WeekNum ==. 
drop if state ==""

* Keep only 2017 data
drop if Year <=2016

* Delete data from end of 2016 with incorrect week number
drop if Year ==2017 & WeekNum >`CurrWeekNumTemp' 

export excel using "C:\TEMP\CMAMDashboard.xlsx", firstrow(variables) replace

list if WeekNum == 53 

* analysis of stock data - utilization analysis by cartons versus weeks of available stock remaining in stores. 
* this should be separate do file
tostring SiteID, gen(SiteIDS)
sort SiteID Type WeekNum
order SiteIDS state lga SiteName Type WeekNum Year


***********
* REMINDERS
***********
use "C:\TEMP\Working\CMAM_delete", clear

format SiteID %10.0f

* Gentle cleaning - Remove there should be no first and second level supervisors with Type = OTP or SC
sort SiteID
drop if SiteID < 9999 & Type=="OTP" 


* Create local variable of current WeekNum
sum CurrWeekNum, meanonly
local currentweeknum =  `r(mean)' 
local end = `r(mean)' - 1

* Delete all data that is older than 8 weeks. 
drop if rep_date_error !=0
* this eliminated all the sites with no reports in past 8 weeks from receiving exact reminders. 

* Ensure smooth transition from old to new year

* Change this to 7 (weeks in past of complete reporting) 
local start = `end' - 7

gen PROnodata = Beg==. & Amar==. & Tin==. & Dcur==. & Dead==. & Defu==. & Dmed==. & Tout==.
gen STOnodata = RUTF_in==. & RUTF_out==. & RUTF_bal==. & F75_bal==. & F100_bal==. 
* Note 1 = no data and 0 = data are in database. 
*tab Beg PROnodata,  m
*tab RUTF_in STOnodata , m

* Create dummy vars across daterange for presence of PROGRAMME and STOCKS data
forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	gen Pdum`week' = 1 if WeekNum ==`week' & PROnodata!=1
}
* Must account for leap years in forvalues above when necessary. 

* Create dummy vars for daterange for STOCKS data
forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	gen Sdum`week' = 1 if WeekNum ==`week' & STOnodata!=1
}
* Must account for leap years in forvalues above when necessary. 

* Make sure that all sites are included. 
* COLLAPSE DATA by SiteID including all week numbers
* this removes only the one reported week number per line
collapse (mean) CurrWeekNum (sum) Pdum* Sdum*, by(SiteID Type)

* a better method might be to insert numbers instead of removing.  Try this in next version. 
* The loop should produce a list of week numbers that site is expected to report for:
* for example, MissProRept =" 19 20 21 22 23 24 25 26 "
gen str14 ProMiss = "" 
forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	local temp = ProMiss + "x" + "`week'"
	cap replace ProMiss = "`temp'"
	disp ProMiss
}
* The loop should produce a list of week numbers that site is expected to report for:
* for example, MissProRept =" 19 20 21 22 23 24 25 26 "
gen str14 StoMiss = "" 
forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	local temp = StoMiss + "x" + "`week'"
	cap replace StoMiss = "`temp'"
	disp StoMiss
}
* Add a space to ensure that strip function works correctly. 
replace ProMiss = ProMiss + "x" 
replace StoMiss = StoMiss + "x" 

forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	* If you don't add space in subinstr after week below, it makes the list into a mess. 
	capture replace ProMiss = subinstr(ProMiss,"x`week'","", .) if Pdum`week'==1
}
forvalues i = `start'/`end' {
	local week = cond(`i' < 1, `i'+52, `i')
	* If you don't add space in subinstr after week below, it makes the list into a mess. 
	capture replace StoMiss = subinstr(StoMiss,"x`week'","", .) if Sdum`week'==1
}
egen ProReptTot = rowtotal(Pdum*)
egen StoReptTot = rowtotal(Sdum*)

replace ProMiss = subinstr(ProMiss,"x"," ", .)
replace StoMiss = subinstr(StoMiss,"x"," ", .)

* Merge with missing programme data with SiteID with phone numbers and names to send reminders. 
merge 1:m SiteID Type using "C:\TEMP\Working\REG_delete"
gen Phone = URN

* Save ProReptTot & StoReptTot as MissingReptTot
* to merge with data quality score. 
destring lga_code, replace force
save C:\TEMP\Working\missingrepttot, replace


* If the SiteID was not included in the report, then assign all weeks as missing. 
gen str MissProReptAll = ""
gen str MissStoReptAll = ""

* Double check 
gen length = length(ProMiss)
sort length
replace MissProRept = MissProRept[_N] if ProReptTot==.

replace length = length(StoMiss)
sort length
replace MissStoRept = MissStoRept[_N] if StoReptTot==.

* Delete programme reports for supervision staff. 
replace ProMiss = "" if SiteID <9999
replace ProReptTot =. if SiteID <9999

gen Message = "Dear @contact from @contact.SiteName. REMINDER to send PROGRAMME reports for weeks @contact.promiss and STOCK reports for weeks @contact.stomiss"
replace Message =  "Dear @contact from @contact.SiteName. REMINDER to send STOCK reports for weeks @contact.stomiss" if SiteID<9999

* Results - number of reports sent. 
tab ProReptTot, m 
tab StoReptTot, m 

* Remove personnel from the reminder who have already sent all reports. 
egen MaxProRept = max(ProReptTot)
egen MaxStoRept = max(StoReptTot)

* There is a mistake above.  The max(ProReptTot)=9 
* There should only be 8 reports for past 8 weeks
drop if ProReptTot>=8 & StoReptTot>=8
* Remove personnel who are not registered for CMAM reporting
drop if SiteID==.

tostring SiteID, replace

keep Phone Name state lga SiteName SiteID Type ProMiss StoMiss Message Level
order Phone Name state lga SiteName SiteID Type ProMiss StoMiss Message Level 
sort SiteID Type 
save "C:\TEMP\Working\Reminder_delete", replace

* Reminders for LGA and State (only Stock)
local missreptfilename = "MissReptWeek" + "`currentweeknum'" 
* Drop erroneous entries
drop if Phone==""
drop if Level =="Site"
drop if Type =="OTP" | Type=="SC"
destring SiteID, gen(SiteIDtemp) force
drop if SiteIDtemp > 9999
drop SiteIDtemp
export excel using "STO`missreptfilename'.xlsx", firstrow(variables) replace

* Reminders for Implementation sites (Programme and Stock)
use "C:\TEMP\Working\Reminder_delete", clear
drop if Level !="Site"
export excel using "PRO`missreptfilename'.xlsx", firstrow(variables) replace




**************
*  Analysis
**************
* Create report

* Calculate errors in data entry here. 

* Site ID Error
*gen SiteID_error =1 if strlen(SiteID) <9 
*tab SiteID_error, m


* YOU CANNOT SEND DATA FOR WEEK NUMBERS IN THE FUTURE. 
*Error - Reports from the future
*list Name URN LastSeen WeekNum if rep_date_error ==2 

* YOU CANNOT SEND DATA FOR WEEK NUMBERS MORE THAN 2 MONTHS IN PAST 
*Error - Reports from the future
*list Name URN LastSeen WeekNum if rep_date_error ==1 

*Error in SiteID for Programme data
*list Name URN SiteID WeekNum Beg if SiteID_error ==1





*Saving graphs and log files. 


*graph combine male_salary.gph female_salary.gph, col(1) saving(salary_by_sex,replace)
*graph use salary_by_sex
*graph export salary_by_sex.pdf

*translate “Stata Log for module 2 exercises.smcl” “Stata Log for module 2 exercises.pdf”

* Graphlog
* https://ideas.repec.org/c/boc/bocode/s457778.html
* ssc install graphlog

* graphlog converts already existing log files (.txt, .log or .smcl format) to .pdf format. 
* It will embed figures saved during the logged session into the PDF document, as long as the 
* graphs have been saved in .png, .gph or .pdf format.

* Error writing PDF file: Check that you have installed LaTeX with pdflatex
* graphlog closed without generating PDF.
* http://miktex.org/download

* Analysis on Registration Data
* To Analyse Registration Date Use RegistrationDate - LastSeen represents last time that they routed through to programme report. 
cap gen RegDate =date(RegistrationDate,"DMY")
cap format RegDate %td
cap gen one = 1
* cap graph bar (sum) one, over (RegDate, label(labsize (1.5) alternate)) ytitle("count") title("Date of Registration") 
* Dates are not correctly presented in graphs. 
* This graph will present in order for one month blocks with RegistrationDate string as x axis variable. 


* End of Report - list all personnel
* Who registered where with what details
* First, second, site level
* Use registration data
cap log close
use "C:\TEMP\Working\REG_delete", clear

replace Level ="National" if Level=="N" | Level=="n" | Level=="Nat" | Level=="nat" 

gen SID = SiteID
replace Level ="Site" if SID > 9999
tostring SiteID, replace
drop if state_code =="1" | state_code=="4" | state_code=="30"

egen one_site = tag(SiteID)
tab one_site Level, m
destring URN, gen(phone) force

* Count LGAs and Sites
sort SiteID Type Post

log using "C:\Analysis\Personnel_List.log", replace

quietly: sum phone if num_tel==1, d 
local peepcount = r(N)
quietly: sum SID if one_site==1 & Level!="Site", d 
local lgacnt = r(N)- 1	
quietly: sum SID if one_site==1 & Level=="Site", d 

di %~59s "NATIONAL LEVEL"
di _newline "Across the north, there have been `peepcount' personnel registered in `r(N)' sites in `lgacnt' LGAs."
	
levelsof state, local(levels) 
foreach l of local levels {
	di as text "{hline 59}"
	di %~59s "STATE REPORT `l'"
	quietly: sum phone if num_tel==1 & state=="`l'", d 
	local peoplecount = r(N)
	quietly: sum SID if one_site==1 & Level!="Site" & state=="`l'", d 
	local lgacount = r(N)-1
	quietly: sum SID if one_site==1 & Level=="Site" & state=="`l'", d 
	di _newline "In `l', there are `peoplecount' personnel registered in `r(N)' sites in `lgacount' LGAs."
	disp _newline "Sites of " "`l'"  
	list state lga SiteName SiteID if one_site==1 & Level!="Site" & state=="`l'", noobs
	list state lga SiteName SiteID if one_site==1 & Level=="Site" & state=="`l'", noobs
	disp _newline "Personnel of " "`l'"  
	list Name URN Post SiteID state lga Level if state=="`l'", noobs
} 
log close


END

sort SiteID WeekNum 
order SiteID WeekNum 


*****************
* Borno registration 24- 28 April 2017
 use "C:\TEMP\Working\REG_delete", clear
 drop if state_code != "8"
 sort FirstSeen
 
* first registration in Borno on week of 24- 28 April 2017
* FirstSeen - 24apr2017 12:47:09

gen reg_date = dofc(FirstSeen)
format reg_date %td

*drop if reg_date < dmy(24, 4, 2017)
drop if reg_date < mdy(4,24,2017)

drop SiteID SiteTemp Site_inputCategoryIMAMRegi Site_inputTextIMAMRegister ContactUUID
rename Site_inputValueIMAMRegiste siteid
drop LastSeen NameCategoryIMAMRegister NameValueIMAMRegister NameTextIMAMRegister
drop Post_supCategoryIMAMRegist Post_supValueIMAMRegister Post_supTextIMAMRegister TypeCategoryIMAMRegister TypeValueIMAMRegister 
drop TypeTextIMAMRegister Post_impCategoryIMAMRegist Post_impValueIMAMRegister Post_impTextIMAMRegister MailCategoryIMAMRegister 
drop MailValueIMAMRegister MailTextIMAMRegister state_lgt Groups


sort Name
replace Name = subinstr(Name, ".", "",.)
replace Name=trim(Name)

replace Name = "Zakariyah Mohammed" if Name == "Zakariya Mohammed"
gen dupname = 0
replace dupname = 1 if Name == Name[_n-1]

export excel using "Borno_Apr17", firstrow(variables) replace

count if dupname ==0
* bysort reg_date: count  if dupname ==0
drop if dupname ==1
gen one = 1
table reg_date, c(count one) 

 