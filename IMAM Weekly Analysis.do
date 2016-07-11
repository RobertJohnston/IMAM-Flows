*IMAM RapidPro analysis



clear
set more off
cd C:\Temp

****************
* Registration Data
****************
* Must include in the downloaded data: 
* SiteID
* Double check all other vars. 

import excel "C:\TEMP\reg.xls", sheet("Contacts") firstrow

* Drop all contacts who are not involved with CMAM IYCF reporting
* All persons currently in registration flow are involved with CMAM

* Drop all contacts who are not in Sokoto
drop if substr(Site_inputValueIMAMRegiste,1, 2)!= "33"

gen state_code = substr(Site_inputValueIMAMRegiste,1, 2)
gen state = state_code
tostring state_code, replace

* Add names for state and LGA codes
replace 	state=	"Sokoto"			if state==	"33"

* Add names for state and LGA codes
gen lga_code = substr(Site_inputValueIMAMRegiste,3, 2)
gen lga = lga_code
tostring lga_code, replace

replace lga=	"Binji" if lga 		=="01"
replace lga=	"Bodinga" if lga  	=="02"
replace lga=	"Dange-Shuni" if lga=="03"
replace lga=	"Gada" if lga       =="04"
replace lga=	"Goronyo" if lga 	=="05"
replace lga=	"Gudu" if lga 		=="06"
replace lga=	"Gwadabawa" if lga 	=="07"
replace lga=	"Illela" if lga 	=="08"
replace lga=	"Isa" if lga 		=="09"
replace lga=	"Kebbe"	if lga 		=="10"
replace lga=	"Kware"	if lga 		=="11"
replace lga=	"Rabah"	if lga 		=="12"
replace lga=	"Sabon Birni" if lga=="13"
replace lga=	"Shagari" if lga 	=="14"
replace lga=	"Silame" if lga 	=="15"
replace lga=	"Sokoto North" if lga=="16"
replace lga=	"Sokoto South" if lga=="17"
replace lga=	"Tambuwal" if lga 	=="18"
replace lga=	"Tangaza" if lga 	=="19"
replace lga=	"Tureta" if lga 	=="20"
replace lga=	"Wamakko" if lga 	=="21"
replace lga=	"Wurno" if lga 		=="22"
replace lga=	"Yabo" if lga 		=="23"

tab lga, m 

replace Name = proper(Name)

*Email
cap gen Mail = ""
replace Mail = MailValueIMAMRegister if Mail==""
replace Mail = "no" if MailCategoryIMAMRegister=="no"

* Table of personnel working in LGA working in State.   
* if Type (OTP or SC) is recorded for 1st or 2nd level not implementation level, then delete
replace Type ="" if Level =="First" | Level == "Second"

sort state lga_code Level Name
* To remove any personnel with more than one phone add 'if num_tel ==1'
list state lga Name Level Post Type if num_tel ==1

* Address variable names AC, AD, AE
* Delete ?
*replace AH = PostValueIMAMRegister if AH ==""
*rename AH PostText

* Check all needed variables are present

tab Name, m
tab state, m
tab lga, m
tab SiteID, m 
tab Level , m 
tab Type , m 
tab Post, m
tab URN, m
tab num_tel , m
tab Mail , m

keep URN Name Post Level Mail SiteID Type FirstSeen LastSeen state_code state lga_code lga
order  Name state lga SiteID Level Type Post URN num_tel Mail 

save delete_reg, replace

* Enumerate the number of persons registered and number of telephones
bysort state lga Name: egen num_tel = seq()
* Number of phones that one person has registered with 
tab num_tel, m
* The total number of persons registered is first row in table - num_tel=1. 

* To Analyse Registration Date Use RegistrationDate and not LastSeen - LastSeen represents last time that they routed through to programme report. 
gen RegDate =date(RegistrationDate,"DMY")
format RegDate %td
gen one = 1
graph bar (sum) one, over (RegDate, label(labsize (1.5) alternate)) ytitle("count") title("Date of Registration") 
* Dates are not correctly presented in graphs. 
* This graph will present in order for one month blocks with RegistrationDate string as x axis variable. 




	
	
	
	
****************
* Programme Data	
****************
import excel "C:\TEMP\pro.xls", sheet("Contacts") firstrow clear
* YOU MUST INCLUDE in the download. 
* - SiteID 

* Remove excess text "IMAMPro*" from variable names. 
foreach var of varlist _all {
local newname = subinstr("`var'", "IMAMProgram", "", .)
rename `var' `newname'
}
* Remove excess text "IMAMPro*" from variable names. 
foreach var of varlist _all {
local newname = subinstr("`var'", "IMAMProgra", "", .)
rename `var' `newname'
}
* Remove excess text "IMAMPro*" from variable names. 
foreach var of varlist _all {
local newname = subinstr("`var'", "IMAMProgr", "", .)
rename `var' `newname'
}
* Remove excess text "IMAMPro*" from variable names. 
foreach var of varlist _all {
local newname = subinstr("`var'", "4R", "", .)
rename `var' `newname'
}

* How to use wildcard characters above? use regex

* Level (First, Second, or Implementation Site)
* Role (Supervision or Implementation)
gen Role = RoleCategory
gen Level = RoleValue

* Week Number
destring WeekNumValue, gen(WeekNum)
tab WeekNum, m

* Stata does not follow the ISO definition of weeknumber whereby week 1 always begins on 1 January and week 52 is always 8 or 9 days long.
* Cannot use week function in Stata on current date. To avoid this error, just convert weeknumbers into dates. 
gen report_date = dofc(LastSeen)
format report_date %td

gen Year = year(report_date)
la var Year "Year of Report"
*gen WeekNumYear = yw(RepYear, WeekNum)
*format WeekNumYear %tw

* Calculate ISO weeknumber of report date
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

* Calculate ISO current weeknum
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

* SiteID for programme data report
replace SiteID = ProSiteIDValue if Level !="Site"

* Type of site for programme data report (OTP or SC)
* You cannot assume that Type is correct for supervision level when it comes from the contact data. 
gen Type = TypeValue 
replace Type = ProTypeCategory if Level !="Site"
tab Type, m 

* Age Group (only used currently in SC)
gen AgeGroup = "6-59m" if Type =="OTP"
* When there is reporting for children 0-5m in OTP will have to change line above. 
replace AgeGroup =  agegroupCategory if Type =="SC"
tab AgeGroup, m 

* Data from OTP flow
gen Beg =  Beg_oValue
gen Amar = Amar_oValue
gen Tin =  Tin_oValue
gen Dcur = Dcur_oValue
gen Dead = Dead_oValue
gen Defu = DefU_oValue
gen Dmed = Dmed_oValue
gen Tout = Tout_oValue

* Data from In Patients (Stabilisation Centre) flow
replace Beg =  Beg_iValue  if Type=="SC"
replace Amar = Amar_iValue if Type=="SC"
replace Tin =  Tin_iValue  if Type=="SC"
replace Dcur = Dcur_iValue if Type=="SC"
replace Dead = Dead_iValue if Type=="SC"
replace Defu = DefU_iValue if Type=="SC"
replace Dmed = Dmed_iValue if Type=="SC"
replace Tout = Tout_iValue if Type=="SC"

* Drop data that are confirmed with NO
drop if ConfirmCategory =="No"

* Delete training data ( program and stock data that goes 1,2,4,6,8… ) 
drop if Beg=="2" & Amar =="4" & Tin=="6"
drop if Dead=="10" & Defu =="12" & Dmed=="14"

* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).
destring SiteID, gen(SiteIDn) force
gsort SiteIDn WeekNum -LastSeen
by SiteIDn WeekNum: egen unique = seq()
drop if unique !=1

* Calculate errors in data entry here. 

* Issmail explained that date LastSeen is the date of the reported flow. 
* Calculate difference between weeknum and report date. 
gen weekdiff =  WeekNum - RepWeekNum
gen rep_date_error = 1 if weekdiff < -8
replace rep_date_error = 2 if weekdiff > 0
la def date_error 1 "Report > 8 weeks in the past" 2 "Report week number in future"
label val rep_date_error date_error
tab rep_date_error, m 



* Site ID Error
gen SiteID_error =1 if strlen(SiteID) <9 
tab SiteID_error, m

* YOU CANNOT SEND DATA FOR WEEK NUMBERS IN THE FUTURE. 
*Error - Reports from the future
list Name URN LastSeen WeekNum if rep_date_error ==2 

* YOU CANNOT SEND DATA FOR WEEK NUMBERS MORE THAN 2 MONTHS IN PAST 
*Error - Reports from the future
list Name URN LastSeen WeekNum if rep_date_error ==1 

*Error in SiteID for Programme data
list Name URN SiteID WeekNum Beg if SiteID_error ==1

* Drop if error in SiteID for data for analysis
drop if strlen(SiteID) <9 

* Delete data if there is a reporting date error (in ancient past or future)
drop if rep_date_error ==1 | rep_date_error ==2 

keep ContactUUID URN Name SiteID FirstSeen LastSeen WeekNum ConfirmCategory Role Level report_date Year CurrWeekNum ///
      RepWeekNum weekdiff rep_date_error SiteID_error Type AgeGroup Beg Amar Tin Dcur Dead Defu Dmed Tout unique

order SiteID Type Year WeekNum report_date URN AgeGroup Beg Amar Tin Dcur Dead Defu Dmed Tout

save delete_pro, replace

* Missing program reports

* Enter current week number into local. 
sum CurrWeekNum, meanonly
local end = `r(mean)' - 1
* Change this to 8 or 7 (weeks in past of complete reporting) for next training
local start = `end' - 4

* Create dummy vars for daterange
forvalues week = `start'/`end' {
	gen dum`week' = 1 if WeekNum ==`week'
}
* Make sure that all sites are included. 
* Collapse by SiteID including all week numbers
* this removes only the one reported week number per line
collapse (mean) CurrWeekNum (sum) dum*, by(SiteID Type)

* The loop should produce a list of week numbers that site is expected to report for:
* for example, miss_pro_rept ="19 20 21 22 23 24 25 26"
gen str14 MissProRept = "" 
forvalues num = `start'/`end' {
	local temp = MissProRept + " " + "`num'"
	cap replace MissProRept = "`temp'"
	disp MissProRept
}
* Add a space to ensure that strip function works correctly. 
replace MissProRept = MissProRept + " " 

forvalues week = `start'/`end' {
	* If you don't add space in subinstr after week below, it makes the list messy. 
	capture replace MissProRept = subinstr(MissProRept,"`week' ","", .) if dum`week'==1
}
egen TotProgRept = rowtotal(dum*)
tab TotProgRept, m 


* Merge with missing programme data with SiteID with phone numbers and names to send reminders. 
merge 1:m SiteID using delete_reg


*Cleaning
* Drop if error in SiteID for data for analysis
drop if strlen(SiteID) <9 
gen Phone = URN

* If the SiteID was not included in the programme report, then assign all weeks as missing. 
gen str MissProReptAll = ""

gen length = length(MissProRept)
sort length
replace MissProRept = MissProRept[_N] if TotProgRept==.

keep Phone Name SiteID MissProRept TotProgRept
order Phone Name SiteID MissProRept TotProgRept
* add MissStoRept

export excel using "C:\TEMP\MissingReptWeeks.xls", firstrow(variables) replace

****************
* Stocks data - Site
****************
import excel "C:\TEMP\sto.xls", sheet("Contacts") firstrow clear
* MUST INCLUDE in the download. 
* SiteID 

* drop if data are not confirmed
drop if ConfirmCategoryIMAMStock =="No"

drop if SiteID =="Nat"

gen Role  = PostLevelCategory
gen Level = PostLevelValue

* Week Number
*destring WeekNumValue, gen(WeekNum)
destring Week_NumberValue, gen(WeekNum) force
tab WeekNum, m

gen report_date = dofc(LastSeen)
format report_date %td

gen Year = year(report_date)
la var Year "Year of Report"

replace SiteID = CheckSiteIDValue if SelfReportCategory =="No"
gen Type = stockreporttypeValue
gen RUTF_in = RUTF_inValue
gen RUTF_used_carton = RUTF_used_cartonValue
gen RUTF_used_sachet = RUTF_used_sachetValue
gen RUTF_bal_carton = RUTF_bal_cartonValue
gen RUTF_bal_sachet = RUTF_bal_sachetValue

gen F75_bal_carton = F75_bal_cartonValue
gen F75_bal_sachet  = F75_bal_sachetValue
gen F100_bal_carton = F100_bal_cartonValue 
gen F100_bal_sachet = F100_bal_sachetValue

* Drop if error in SiteID for Site level stock reports.  All site level stock reports must have a valid SiteID. 
drop if strlen(SiteID) <9 

keep ContactUUID URN Name SiteID FirstSeen LastSeen WeekNum Role Level Type RUTF_in RUTF_used_carton RUTF_used_sachet /// 
     RUTF_bal_carton RUTF_bal_sachet F75_bal_carton F75_bal_sachet F100_bal_carton F100_bal_sachet Year report_date

order SiteID Type Year WeekNum report_date URN RUTF_in RUTF_used_carton RUTF_used_sachet /// 
     RUTF_bal_carton RUTF_bal_sachet F75_bal_carton F75_bal_sachet F100_bal_carton F100_bal_sachet
	 
sort SiteID WeekNum

* Report date ? Year ?



* Merge programme and stocks data to the registration data

* Make Excel Dashboard Data. 

* Merge with missing programme data with SiteID with phone numbers and names to send reminders. 

* merge 


****************
* Stocks data - LGA STATE
****************

* Before exporting data, remove all incomplete and garbage data. 




* Create list of week numbers not reported for. 

*Saving graphs and log files. 

graph combine male_salary.gph female_salary.gph, col(1) saving(salary_by_sex,replace)
graph use salary_by_sex
graph export salary_by_sex.pdf

translate “Stata Log for module 2 exercises.smcl” “Stata Log for module 2 exercises.pdf”

* Graphlog
* https://ideas.repec.org/c/boc/bocode/s457778.html
* ssc install graphlog

* graphlog converts already existing log files (.txt, .log or .smcl format) to .pdf format. 
* It will embed figures saved during the logged session into the PDF document, as long as the 
* graphs have been saved in .png, .gph or .pdf format.

* Error writing PDF file: Check that you have installed LaTeX with pdflatex
* graphlog closed without generating PDF.



















































































































































































* Create report

* Who registered where with what details
* First, second, site level
