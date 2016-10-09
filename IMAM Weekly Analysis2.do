* IMAM Weekly Analysis 2

use "C:\TEMP\Working\REG_delete", clear

* STOCK ALERTS
* Create list of all personnel with their LGA and SNO telnums for stock alerts
sort SiteID
drop if SiteID ==.

drop if SiteID > 99
gen SNOtelnum = URN
gen SNOname = Name
order SiteID Name state_code state SNOtelnum Post

gen SNO = 0
replace SNO=1 if Name=="Hamza Yakubu Sade ."
replace SNO=1 if Name=="Suleiman Mamman."
replace SNO=1 if Name=="Saidu Umar Adamu."
replace SNO=1 if Name=="Muhammad Ali Hamza."
drop if SNO==0

save "C:\TEMP\Working\SNO", replace

use "C:\TEMP\Working\REG_delete", clear
gen LGAtelnum = URN
gen LGAname = Name
keep if SiteID > 99 & SiteID < 9999
sort SiteID
order  SiteID Name state_code state lga_code lga LGAtelnum Post
keep if Post =="Coordinator" 
* Three edits - data cleaning
drop if Name =="Amina Bello."
drop if LGAtelnum=="+2348081798563"  

* When LGA nut foc points have two numbers have to find out which one works the best. 

list SiteID Name state lga Post

save "C:\TEMP\Working\LGA", replace

* Add LGA and SNO to implementation site level list. 
use "C:\TEMP\Working\REG_delete", clear
drop if SiteID ==. 
merge m:1 state_code using "C:\TEMP\Working\SNO"
drop _merge

merge m:1 lga_code using "C:\TEMP\Working\LGA"
sort SiteID
format SiteID %10.0f
gen Phone = URN

order Phone Name SiteID SiteName Name Post state_code state SNOtelnum SNOname lga_code lga LGAtelnum LGAname 
keep Phone Name SiteID SiteName Name Post state SNOtelnum SNOname lga LGAtelnum LGAname 

* Save IMAM Supervision
save "C:\TEMP\Working\IMAM_Supervision", replace
export excel using "IMAM_Supervision", firstrow(variables) replace

* why is this missing? 
use "C:\TEMP\Working\REG_delete", clear
* Site Level Data

*Include only one SiteID for merge with programme data. 
bysort SiteID Type: egen SiteIDord = seq()
tab SiteIDord, m
drop if SiteIDord !=1


*Remove uninterpretable data.
drop if SiteID ==.

drop if SiteName=="" & Type=="OTP" 
drop if SiteName=="" &  Type=="SC"

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
import excel "C:\TEMP\pro.xls", sheet("Runs") firstrow clear
* Do not use the tab "Contacts" as it is incomplete. 
* Make crash if SiteID is not included
* YOU MUST INCLUDE in the download. 
des SiteID

* Level (First, Second, or Implementation Site)
* Role (Supervision or Implementation)
gen Role = RoleCategory
gen Level = RoleValue
tab Role, m 
tab Level, m 

* SiteID for programme data report
* Replace SiteID if report is sent from LGA or State level 
replace SiteID = ProSiteIDValue if Level !="Site"

* Type of site for programme data report (OTP or SC)
* You cannot assume that Type is correct for supervision level when it comes from the contact data. 
gen Type = TypeValue 
replace Type = ProTypeCategory if Level !="Site"
tab Type, m 

* Week Number
destring WeekNumValue, gen(WeekNum) force
* someone entered weeknum 1.5
replace WeekNum = floor(WeekNum)
tab WeekNum, m

* Age Group (only used currently in SC)
gen AgeGroup = "6-59m" if Type =="OTP"
* When there is reporting for children 0-5m in OTP will have to change line above. 
replace AgeGroup =  agegroupCategory if Type =="SC"
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
drop if ConfirmCategory =="No"

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

* Remove duplicates
destring SiteID, replace force
format SiteID %10.0f
gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()
* Double check the selection of older entries to drop
* tab unique, m 
* order SiteID WeekNum Name unique LastSeen Beg Amar
drop if unique !=1 

keep URN Name SiteID WeekNum Role Level Type AgeGroup Beg Amar Tin Dcur Dead Defu Dmed Tout FirstSeen LastSeen

sort SiteID WeekNum

save "C:\TEMP\Working\PRO_delete", replace

****************
* Stocks data - Site
****************
import excel "C:\TEMP\sto.xls", sheet("Runs") firstrow clear
* MUST INCLUDE in the download. 
* SiteID 
drop if SiteID =="Nat"

* drop if data are not confirmed
drop if ConfirmCategoryIMAMStock =="No"

* Role (Implementation or Supervision)
gen Role  = PostLevelCategory
* Level (Site, Second, First, National
gen Level = PostLevelValue

* SiteID
tostring CheckSiteIDValue, replace
replace SiteID = CheckSiteIDValue if SelfReportCategory =="No"
destring SiteID, replace force
format SiteID %10.0f

* Type (OTP or SC)
gen Type = stockreporttypeValue
* WeekNum
destring WeekNumValue, gen(WeekNum) force
drop WeekNumCategoryIMAMStock WeekNumValueIMAMStock WeekNumTextIMAMStock

* Review RUTF stock
destring RUTF_inValue RUTF_used_cartonValue RUTF_used_sachetValue RUTF_bal_cartonValue RUTF_bal_sachetValue /// 
	F75_bal_cartonValue F75_bal_sachetValue F100_bal_cartonValue F100_bal_sachetValue, replace force
gen R_in  = RUTF_inValue
gen R_outCART = RUTF_used_cartonValue
gen R_outSACH = RUTF_used_sachetValue
gen R_balCART = RUTF_bal_cartonValue
gen R_balSACH = RUTF_bal_sachetValue

* If RUTF in Sachets is more than 149, then assume that they double reported and gave total in sachets. 
* this hides errors that need to be corrected. 
* Must leave errors visible. 
* replace RUTF_used_sachetValue = mod(RUTF_used_sachetValue,150) if RUTF_used_sachetValue > 149
* replace RUTF_bal_sachetValue = mod(RUTF_bal_sachetValue,150) if RUTF_bal_sachetValue > 149

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
gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()
* tab unique, m 
drop if unique !=1

keep URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen 
order URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen 
sort SiteID Type WeekNum

save "C:\TEMP\Working\STO_delete", replace

****************
* Stocks data - LGA STATE
****************
import excel "C:\TEMP\lga.xls", sheet("Runs") firstrow clear
* Crash if SiteID is not present - MUST INCLUDE in the download. 
des SiteID 

* The State and LGA stocks are only for the reporter's SiteID. 
* Remove all entries with incorrect SiteIDs
drop if strlen(SiteID)>4 

gen WeekNum = WeekNumValue
destring WeekNum, replace

gen RUTF_in = RUTF_inValue
gen RUTF_out = RUTF_outValue
gen RUTF_bal = RUTF_balValue
destring RUTF_in RUTF_out RUTF_bal, replace

* Drop if confirmation equals No or SiteID = X
drop if confirmCategory =="No"
drop if SiteID =="X"

* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).
destring SiteID, replace
gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()
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
drop if SiteID >9999
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

* Calculate ISO report week number
* Test if leap year
generate leap = cond(mdy(2,29,year(report_date)) < . , 1, 0)
gen dow = dow(report_date)
* Set sunday to 7 not zero. 
replace dow = 7 if dow==0
gen month = month(report_date)
* Calculate ordinal date
recode month (1=0)(2=31)(3=59)(4=90)(5=120)(6=151)(7=181)(8=212)(9=243)(10=273)(11=304)(12=334), gen(temp)
* for leap years
recode month (1=0)(2=31)(3=60)(4=91)(5=121)(6=152)(7=182)(8=213)(9=244)(10=274)(11=305)(12=335), gen(temp2)
gen ord_date = cond(leap==1, temp2 + day(report_date), temp + day(report_date))
gen RepWeekNum =  floor(((ord_date - dow) + 10 ) / 7)
*If a week number of 53 is obtained, one must check that the date is not actually in week 1 of the following year.

* Calculate ISO current week number
gen current_date = date("$S_DATE", "DMY") 
format current_date %td
replace leap = cond(mdy(2,29,year(current_date)) < . , 1, 0)
replace dow = dow(current_date)
* Set sunday to 7 not zero. 
replace dow = 7 if dow==0
replace month = month(current_date)
* Calculate ordinal date
drop temp temp2
recode month (1=0)(2=31)(3=59)(4=90)(5=120)(6=151)(7=181)(8=212)(9=243)(10=273)(11=304)(12=334), gen(temp)
* for leap years
recode month (1=0)(2=31)(3=60)(4=91)(5=121)(6=152)(7=182)(8=213)(9=244)(10=274)(11=305)(12=335), gen(temp2)
replace ord_date = cond(leap==1, temp2 + day(current_date), temp + day(current_date))
gen CurrWeekNum =  floor(((ord_date - dow) + 10 ) / 7)
* If a week number of 53 is obtained, one must check that the date is not actually in week 1 of the following year.
* If Thursday of first week of Jan day of week < 4 then assign week to following year. 
disp CurrWeekNum

* LastSeen in the RapidPro data is the date of the reported flow. 
* Calculate difference between weeknum and report date. 
gen weekdiff =  WeekNum - RepWeekNum
gen rep_date_error = 0
replace rep_date_error = 1 if weekdiff < -8
replace rep_date_error = 2 if weekdiff > 0
la def date_error 0 "No error" 1 "Report > 8 weeks in the past" 2 "Report week number in future"
label val rep_date_error date_error
tab rep_date_error, m 

save "C:\TEMP\Working\CMAM_delete", replace


* REMOVE LGA and STATE level data from CMAM dashboard 
* Include LGA and State data in dashboard data ? No.

****************************
* EXPORT FOR EXCEL DASHBOARD
****************************
sort SiteID Type WeekNum
* Drop STATE and LGA data
drop if SiteID < 9999

* Delete data if there is a reporting date error (in ancient past or future)
drop if rep_date_error ==1 | rep_date_error ==2 

gen id = [_n]
gen End = Beg + Amar + Tin - Dcur - Dead - Defu - Dmed - Tout

gen stockcode = "RUTF"
* Create instock variable. 
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

* Remove later
* To have cleaner data
drop if WeekNum<22
drop if URN ==""

export excel using "C:\TEMP\CMAMDashboard.xls", firstrow(variables) replace


***********
* REMINDERS
***********
use "C:\TEMP\Working\CMAM_delete", clear

* Gentle cleaning - Remove there should be no first and second level supervisors with Type = OTP or SC
sort SiteID
drop if SiteID < 9999 & Type=="OTP" 


* Create local variable of current WeekNum
sum CurrWeekNum, meanonly
local currentweeknum =  `r(mean)' 
local end = `r(mean)' - 1
* Change this to 8 or 7 (weeks in past of complete reporting) for next training
local start = `end' - 7

gen PROnodata = Beg==. & Amar==. & Tin==. & Dcur==. & Dead==. & Defu==. & Dmed==. & Tout==.
gen STOnodata = RUTF_in==. & RUTF_out==. & RUTF_bal==. & F75_bal==. & F100_bal==. 
* Note 1 = no data and 0 = data are in database. 
*tab Beg PROnodata,  m
*tab RUTF_in STOnodata , m

* Create dummy vars across daterange for presence of PROGRAMME and STOCKS data
forvalues week = `start'/`end' {
	gen Pdum`week' = 1 if WeekNum ==`week' & PROnodata!=1
}
* Create dummy vars for daterange for STOCKS data
forvalues week = `start'/`end' {
	gen Sdum`week' = 1 if WeekNum ==`week' & STOnodata!=1
}
* Make sure that all sites are included. 
* Collapse by SiteID including all week numbers
* this removes only the one reported week number per line
collapse (mean) CurrWeekNum (sum) Pdum* Sdum*, by(SiteID Type)

* The loop should produce a list of week numbers that site is expected to report for:
* for example, MissProRept ="19 20 21 22 23 24 25 26"
gen str14 ProMiss = "" 
forvalues num = `start'/`end' {
	local temp = ProMiss + " " + "`num'"
	cap replace ProMiss = "`temp'"
	disp ProMiss
}
* The loop should produce a list of week numbers that site is expected to report for:
* for example, MissProRept ="19 20 21 22 23 24 25 26"
gen str14 StoMiss = "" 
forvalues num = `start'/`end' {
	local temp = StoMiss + " " + "`num'"
	cap replace StoMiss = "`temp'"
	disp StoMiss
}
* Add a space to ensure that strip function works correctly. 
replace ProMiss = ProMiss + " " 
replace StoMiss = StoMiss + " " 

forvalues week = `start'/`end' {
	* If you don't add space in subinstr after week below, it makes the list into a mess. 
	capture replace ProMiss = subinstr(ProMiss,"`week' ","", .) if Pdum`week'==1
}
forvalues week = `start'/`end' {
	* If you don't add space in subinstr after week below, it makes the list into a mess. 
	capture replace StoMiss = subinstr(StoMiss,"`week' ","", .) if Sdum`week'==1
}
egen ProReptTot = rowtotal(Pdum*)
egen StoReptTot = rowtotal(Sdum*)

* Merge with missing programme data with SiteID with phone numbers and names to send reminders. 
merge 1:m SiteID Type using "C:\TEMP\Working\REG_delete"
gen Phone = URN

* Save ProReptTot & StoReptTot as MissingReptTot
* to merge with data quality score. 
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

gen Message = "Dear @contact from @contact.SiteName. Thank you for reporting. This is a REMINDER to send missing PROGRAMME reports for week numbers @contact.promiss and STOCK reports for week numbers @contact.stomiss"
replace Message =  "Dear @contact from @contact.SiteName. Thank you for reporting. This is a REMINDER to send missing STOCK reports for week numbers @contact.stomiss" if SiteID<9999

* Results - number of reports sent. 
tab ProReptTot, m 
tab StoReptTot, m 

* Remove personnel from the reminder who have already sent all reports. 
egen MaxProRept = max(ProReptTot)
egen MaxStoRept = max(StoReptTot)
drop if ProReptTot==ProReptTot & StoReptTot==MaxStoRept
* Remove personnel who are not registered for CMAM reporting
drop if SiteID==.

tostring SiteID, replace

keep Phone Name lga SiteName SiteID Type ProMiss StoMiss Message Level
order Phone Name lga SiteName SiteID Type ProMiss StoMiss Message Level 
sort SiteID Type 
save "C:\TEMP\Working\Reminder_delete", replace

* Reminders for LGA and State (only Stock)
local missreptfilename = "MissReptWeek" + "`currentweeknum'" 
drop if Level =="Site"
export excel using "STO`missreptfilename'.xls", firstrow(variables) replace

* Reminders for Implementation sites (Programme and Stock)
use "C:\TEMP\Working\Reminder_delete", clear
drop if Level !="Site"
export excel using "PRO`missreptfilename'.xls", firstrow(variables) replace




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
use "C:\TEMP\Working\REG_delete", clear

sort SiteID
tostring SiteID, replace
drop if state =="1"

log using "C:\Analysis\Personnel_List.log", replace

levelsof state, local(levels) 
foreach l of local levels {
	disp "Personnel of " "`l'"  " State"
	list Name URN Post SiteID state lga Level if state=="`l'"
} 
log close
