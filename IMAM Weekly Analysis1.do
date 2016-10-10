*IMAM RapidPro analysis


* Store all current RapidPro downloaded data in C:\Temp
* All working data that will be frequently rewritten and can be deleted is stored in C:\Temp\Working
* Output is available from C:\Temp

* Prepare all four databases, remove repeated entries for same week, errors in SiteID and all unneccessary variables. 
* Merge registration, programme and stocks data together
* Make Final Reporting database. 
* Make Reminders
* Remove LGA and State stocks data
* Make Excel Dashboard database

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
* do we want the tab of runs or contacts here ?
* CONTACTS, as that corresponds to everyone registered

* Drop all contacts who are not involved with CMAM IYCF reporting
* All persons currently in registration flow are involved with CMAM

* SiteID
* Crash program if SiteID is not included in reg.
sort SiteID

* CLEAN ALL THE FOLLOWING IN THE RAPIDPRO DATABASE. 

*One person entered a SiteID with oooo' s instead of zeros. 

* Correction for Bashiru Abubakar
* replace Site_inputCategory ="Second" if SiteID=="3308"


* The inputed text for SITE is - Site_inputTextIMAMRegister
order SiteID Site_inputCategoryIMAMRegi Site_inputValueIMAMRegiste Site_inputTextIMAMRegister

* DATA CLEANING
replace SiteID ="1703110025" if Site_inputTextIMAMRegister =="17 03110025"
replace SiteID ="3301110015" if Site_inputTextIMAMRegister =="33 01 110015"
replace SiteID ="1609110007" if Site_inputTextIMAMRegister =="1609110007"
replace SiteID ="504110027" if Site_inputTextIMAMRegister =="504110027"
replace SiteID ="1710110003" if Site_inputTextIMAMRegister =="1710110003"
replace SiteID ="1609110017" if Site_inputTextIMAMRegister =="1609110017"
replace SiteID ="1714110022" if Site_inputTextIMAMRegister =="1714110022"
replace SiteID ="1719110015" if Site_inputTextIMAMRegister =="1719110015"
replace SiteID ="1709210009" if Site_inputTextIMAMRegister =="1709210009"
replace SiteID ="1714110008" if Site_inputTextIMAMRegister =="1714110008"
replace SiteID ="3304" 		if Site_inputTextIMAMRegister =="3304"
replace SiteID ="3317110023" if Site_inputTextIMAMRegister =="33 17 11 0023"
replace SiteID ="1609110004" if Site_inputTextIMAMRegister =="MOH'D M.MOH'D SAM 1609110004"
replace SiteID ="3301" 		if Site_inputTextIMAMRegister =="33o1"

* this SiteID is not in the register database
replace SiteID ="1703110034" if Site_inputTextIMAMRegister == "1731110034"
* figure out where the problem is coming from. 
replace SiteID ="3301110011" if Site_inputTextIMAMRegister =="330110011"
replace SiteID ="3301110017" if Site_inputTextIMAMRegister =="330111017"
replace SiteID ="1720110001" if Site_inputTextIMAMRegister =="1720110001"
replace SiteID ="1720110001" if Site_inputTextIMAMRegister =="SitelD  1720110001"
replace SiteID ="1727110010" if Site_inputTextIMAMRegister =="1727110010"

replace SiteID ="1716110002" if Site_inputTextIMAMRegister =="1716110002"
replace SiteID ="1716110003" if Site_inputTextIMAMRegister =="1716110003"
replace SiteID ="1717110001" if Site_inputTextIMAMRegister =="1717110001"
replace SiteID ="1701110007" if SiteID =="170110007"
replace SiteID ="1702210001" if SiteID =="172210001"

* 1727110014




sort SiteID

* Level 
cap gen Level = Site_inputCategory 
replace Level ="" if Level=="Other"
tab Level, m 

* Type 
tab Type, m 
* Crash program if Type is not included in reg.xls
replace Type ="" if Type=="Other"
* drop attempts to send data from LGA to RapidPro for OTP/SC in register db. 
drop if Type==","

* if Type (OTP or SC) is recorded for 1st or 2nd level not implementation level, then delete
replace Type ="" if Level =="First" | Level == "Second"
* Post
capture gen Post = Post_impCategory
replace Post = Post_supCategory if Level !="Site"
replace Post ="" if Post=="Other"
tab Post, m 

* for some strange reason - decimal and zero added to SiteID, which causes problems to identify state and LGA. 
* Strip out ".0" from all SiteIDs
replace SiteID = subinstr(SiteID,".0","",1)

* Data cleaning
replace SiteID = subinstr(SiteID," OTP","",1)
* SiteID strips out numbers from data entry, but if garbage is included, like "OTP" that remains in the var. 
* Should have a test for any SiteID that is not a number. 

* State code ( can be 9 or 10 digits ) 
* Calculate length - take first one or two numbers
gen state_lgt = strlen(SiteID)
tab state_lgt, m


gen state_code = substr(SiteID,1, 2) if state_lgt==10
replace state_code = substr(SiteID,1, 1) if state_lgt==9
replace state_code = substr(SiteID,1, 2) if state_lgt==4
replace state_code = substr(SiteID,1, 1) if state_lgt==3
replace state_code = SiteID if state_lgt< 3

gen state = state_code
tostring state_code, replace
tab state_code, m 

* Add names for state and LGA codes

replace state="Bauchi" if state=="5"
replace state="Gombe" if state=="16"
replace state="Jigawa" if state=="17"
replace state="Sokoto" if state=="33"
replace state="Yobe" if state=="35"
tab state, m 
tab state Level, m 

* state and lga are not coded


* Add names for state and LGA codes
* NEED TO CHANGE THIS TO FIRST THREE OR FOUR DIGITS


gen lga_lgt = strlen(SiteID)
tab lga_lgt, m
list SiteID lga_lgt if lga_lgt==3

gen lga_code = substr(SiteID,1, 4) if state_lgt==10
replace lga_code = substr(SiteID,1, 3) if state_lgt==9
replace lga_code = substr(SiteID,1, 4) if lga_lgt==4
replace lga_code = substr(SiteID,1, 3) if lga_lgt==3
gen lga = lga_code
tostring lga_code, replace
tab lga Level, m 

replace lga="Binji" if lga 		=="3301"
replace lga="Bodinga" if lga  	=="3302"
replace lga="Dange-Shuni" if lga=="3303"
replace lga="Gada" if lga       =="3304"
replace lga="Goronyo" if lga 	=="3305"
replace lga="Gudu" if lga 		=="3306"
replace lga="Gwadabawa" if lga 	=="3307"
replace lga="Illela" if lga 	=="3308"
replace lga="Isa" if lga 		=="3309"
replace lga="Kebbe"	if lga 		=="3310"
replace lga="Kware"	if lga 		=="3311"
replace lga="Rabah"	if lga 		=="3312"
replace lga="Sabon Birni" if lga=="3313"
replace lga="Shagari" if lga 	=="3314"
replace lga="Silame" if lga 	=="3315"
replace lga="Sokoto North" if lga=="3316"
replace lga="Sokoto South" if lga=="3317"
replace lga="Tambuwal" if lga 	=="3318"
replace lga="Tangaza" if lga 	=="3319"
replace lga="Tureta" if lga 	=="3320"
replace lga="Wamakko" if lga 	=="3321"
replace lga="Wurno" if lga 		=="3322"
replace lga="Yabo" if lga 		=="3323"

replace lga="AKKO" if lga =="1601"
replace lga="BALANGA" if lga =="1602"
replace lga="BILILIRI" if lga =="1603"
replace lga="DUKKU" if lga =="1604"
replace lga="FUNA KAYE" if lga =="1605"
replace lga="GOMBE" if lga =="1606"
replace lga="KALTUNGO" if lga =="1607"
replace lga="KWAMI" if lga =="1608"
replace lga="NAFADA" if lga =="1609"
replace lga="SHONGOM" if lga =="1610"
replace lga="YAMALTU/DEBA" if lga =="1611"

replace lga="ALKALERI" if lga =="501"
replace lga="BAUCHI" if lga =="502"
replace lga="BOGORO" if lga =="503"
replace lga="DAMBAM" if lga =="504"
replace lga="DARAZO" if lga =="505"
replace lga="DASS" if lga =="506"
replace lga="GAMAWA" if lga =="507"
replace lga="GANJUWA" if lga =="508"
replace lga="GIADE" if lga =="509"
replace lga="ITAS-GADAU" if lga =="510"
replace lga="JAMA'ARE" if lga =="511"
replace lga="KATAGUM" if lga =="512"
replace lga="KIRFI" if lga =="513"
replace lga="MISAU" if lga =="514"
replace lga="NINGI" if lga =="515"
replace lga="SHIRA" if lga =="516"
replace lga="TAFAWA-BALEWA" if lga =="517"
replace lga="TORO" if lga =="518"
replace lga="WARJI" if lga =="519"
replace lga="ZAKI" if lga =="520"

replace lga= "AUYO" if lga =="1701"
replace lga="BABURA" if lga =="1702"
replace lga="BIRNIN KUDU" if lga =="1703"
replace lga="BIRNIWA" if lga =="1704"
replace lga="BUJI" if lga =="1705"
replace lga="DUTSE" if lga =="1706"
replace lga="GAGARAWA" if lga =="1707"
replace lga="GARKI" if lga =="1708"
replace lga="GUMEL" if lga =="1709"
replace lga="GURI" if lga =="1710"
replace lga="GWARAM" if lga =="1711"
replace lga="GWIWA" if lga =="1712"
replace lga="HADEJIA" if lga =="1713"
replace lga="JAHUN" if lga =="1714"
replace lga="KAFIN HAUSA" if lga =="1715"
replace lga="KAUGAMA" if lga =="1716"
replace lga="KAZAURE" if lga =="1717"
replace lga="KIRI KASAMMA" if lga =="1718"
replace lga="KIYAWA" if lga =="1719"
replace lga="MAIGATARI" if lga =="1720"
replace lga="MALAM MADORI" if lga =="1721"
replace lga="MIGA" if lga =="1722"
replace lga="RINGIM" if lga =="1723"
replace lga="RONI" if lga =="1724"
replace lga="SULE TANKARKAR" if lga =="1725"
replace lga="TAURA" if lga =="1726"
replace lga="YANKWASHI" if lga =="1727"
* Yobe State
replace lga ="BADE" if lga=="3501"
replace lga ="BUSARI" if lga=="3502"
replace lga ="DAMATURU" if lga=="3503"
replace lga ="FIKA" if lga=="3504"
replace lga ="FUNE" if lga=="3505"
replace lga ="GEIDAM" if lga=="3506"
replace lga ="GUJBA" if lga=="3507"
replace lga ="GULANI" if lga=="3508"
replace lga ="JAKUSKO" if lga=="3509"
replace lga ="KARASUWA" if lga=="3510"
replace lga ="MACHINA" if lga=="3511"
replace lga ="NANGERE" if lga=="3512"
replace lga ="NGURU" if lga=="3513"
replace lga ="POTISKUM" if lga=="3514"
replace lga ="TARMUWA" if lga=="3515"
replace lga ="YUNUSARI " if lga=="3516"
replace lga ="YUSUFARI " if lga=="3517"

replace lga = proper(lga)
tab lga, m 




* SiteName
destring SiteID, replace force
gen SiteName = ""

replace SiteName = "Binji Up-Graded Dispensary"	if SiteID==	3301110001
replace SiteName = "General Hospital Binji"		if SiteID==	3301210002
replace SiteName = "Birni wari Dispensary"			if SiteID==	3301110003
replace SiteName = "Kalgo Dispensary"				if SiteID==	3301110004
replace SiteName = "Karani Dispensary"				if SiteID==	3301110005
replace SiteName = "Kura Up-Graded Dispensary"		if SiteID==	3301110006
replace SiteName = "Dalijam Dispensary"			if SiteID==	3301110007
replace SiteName = "Jamali Dispensary"				if SiteID==	3301110008
replace SiteName = "Jamali Tsohuwa Dispensary"		if SiteID==	3301110009
replace SiteName = "Danmali Dispensary"			if SiteID==	3301110010
replace SiteName = "Model PHC Bunkari"				if SiteID==	3301110011
replace SiteName = "Fako Dispensary"				if SiteID==	3301110012
replace SiteName = "Kandiza Dispensary"			if SiteID==	3301110013
replace SiteName = "Gwahitto Dispensary"			if SiteID==	3301110014
replace SiteName = "Soro Dispensary"			if SiteID==	3301110015
replace SiteName = "Tumuni Dispensary"			if SiteID==	3301110016
replace SiteName = "Gawazai Dispensary"		if SiteID==	3301110017
replace SiteName = "Matabare Dispensary"		if SiteID==	3301110018
replace SiteName = "Yardewu Dispensary"		if SiteID==	3301110019
replace SiteName = "Ginjo Dispensary"			if SiteID==	3301110020
replace SiteName = "Inname Dispensary"			if SiteID==	3301110021
replace SiteName = "Kunkurwa Dispensary"		if SiteID==	3301110022
replace SiteName = "Maikulki Up-Graded Disp"		if SiteID==	3301110023
replace SiteName = "Margai Dispensary"			if SiteID==	3301110024
replace SiteName = "Samama Dispensary"			if SiteID==	3301110025
replace SiteName = "Tudun Kose Dispensary"		if SiteID==	3301110026
replace SiteName = "Gidan Maidebe Dispensary"		if SiteID==	3301110027
replace SiteName = "Twaidi Dikko Dispensary"	if SiteID==	3301110028
replace SiteName = "Twaidi Zaidi Dispensary"	if SiteID==	3301110029
replace SiteName = "Abdulsalami Dispensary"	if SiteID==	3302110001
replace SiteName = "Lukuyaw Dispensary"		if SiteID==	3302110002
replace SiteName = "Sifawa Dispensary"		if SiteID==	3302110003
replace SiteName = "Badau Dispensary"		if SiteID==	3302110004
replace SiteName = "Darhela Up-Graded Disp"	if SiteID==	3302110005
replace SiteName = "Badawa Dispensary"		if SiteID==	3302110006
replace SiteName = "Bagarawa Dispensary"	if SiteID==	3302110007
replace SiteName = "PHC Bagarawa"			if SiteID==	3302110008
replace SiteName = "Zangalawa Dispensary"	if SiteID==	3302110009
replace SiteName = "Bangi Dispensary"	if SiteID==	3302110010
replace SiteName = "Dabaga Dsipensary"	if SiteID==	3302110011
replace SiteName = "Tulluwa Dispensary"	if SiteID==	3302110012
replace SiteName = "Wumumu Dispensary"	if SiteID==	3302110013
replace SiteName = "Dan Ajwa Dispensary"	if SiteID==	3302110014
replace SiteName = "K/Wwasau"					if SiteID==	3302110015
replace SiteName = "Dingyadi Up-Graded Disp"	if SiteID==	3302110016
replace SiteName = "PHC Dingyadi"	if SiteID==	3302110017
replace SiteName = "Gidan Kijo Dispensary"	if SiteID==	3302110018
replace SiteName = "General Hospital Bodinga"	if SiteID==	3302210019
replace SiteName = "Town Dispensary Bodinga"	if SiteID==	3302110020
replace SiteName = "Gidan Tsara Dispensary"	if SiteID==	3302110021
replace SiteName = "Kaura Buba Dispensary"	if SiteID==	3302110022
replace SiteName = "Jabe Dispensary"	if SiteID==	3302110023
replace SiteName = "Jirga Dsipensary"	if SiteID==	3302110024
replace SiteName = "Kaurarmangala Dispensary"	if SiteID==	3302110025
replace SiteName = "Mazangari Dispensary"	if SiteID==	3302110026
replace SiteName = "Modorawa Dispensary"	if SiteID==	3302110027
replace SiteName = "Takatuku Dispensary"	if SiteID==	3302110028
replace SiteName = "PHC Danchadi"	if SiteID==	3302110029
replace SiteName = "Town Dispensary Danchadi"	if SiteID==	3302110030
replace SiteName = "1 Battalion Military Hosp"	if SiteID==	3303210001
replace SiteName = "Shuni Dispensary"	if SiteID==	3303110002
replace SiteName = "Amanawa Lep/General Hosp"	if SiteID==	3303210003
replace SiteName = "Rudu Dispensary"	if SiteID==	3303110004
replace SiteName = "Basic Health Centre Amanawa"	if SiteID==	3303110005
replace SiteName = "Bodai Kaura Dispensary"	if SiteID==	3303110006
replace SiteName = "Bodai Sajo Dispensary"	if SiteID==	3303110007
replace SiteName = "Danbuwa Dispensary"	if SiteID==	3303110008
replace SiteName = "Tsefe Dispensary"	if SiteID==	3303110009
replace SiteName = "Tuntube Dispensary"	if SiteID==	3303110010
replace SiteName = "Kwanawa Dispensary"	if SiteID==	3303110011
replace SiteName = "Dange Up-Graded Disp"	if SiteID==	3303110012
replace SiteName = "Model PHC Dange"	if SiteID==	3303110013
replace SiteName = "Marina Dispensary"	if SiteID==	3303110014
replace SiteName = "Fajaldu Dispensary"	if SiteID==	3303110015
replace SiteName = "Dabagin Ardo Up-Graded Disp"	if SiteID==	3303110016
replace SiteName = "Gajara Dispensary"	if SiteID==	3303110017
replace SiteName = "Ge-Ere Dispensary"	if SiteID==	3303110018
replace SiteName = "Wababe Dispensary"	if SiteID==	3303110019
replace SiteName = "Rikina Dispensary"	if SiteID==	3303110020
replace SiteName = "Ruggar Dudu Dispensary"	if SiteID==	3303110021
replace SiteName = "Laffi Dispensary"	if SiteID==	3303110022
replace SiteName = "Staff clinic Rima"	if SiteID==	3303110023
replace SiteName = "Tsafanade Dispensary"	if SiteID==	3303110024
replace SiteName = "Alibawa Community Disp"	if SiteID==	3304110001
replace SiteName = "Gidan Gyado Com Dispensary"	if SiteID==	3304110002
replace SiteName = "PHC Kaffe"	if SiteID==	3304110003
replace SiteName = "General Hospital Gada"	if SiteID==	3304210004
replace SiteName = "Baredi Community Dispensary"	if SiteID==	3304110005
replace SiteName = "Gidan Madugu Comm Disp"	if SiteID==	3304110006
replace SiteName = "Town Dispensary Gada"	if SiteID==	3304110007
replace SiteName = "Dagindi Dispensary"	if SiteID==	3304110008
replace SiteName = "Kaddi Up-Graded Dispensary"	if SiteID==	3304110009
replace SiteName = "PHC Kadadi"	if SiteID==	3304110010
replace SiteName = "Inga boro Dispensary"	if SiteID==	3304110011
replace SiteName = "Kadadi Dispensary"	if SiteID==	3304110012
replace SiteName = "Sagera Dispensary"	if SiteID==	3304110013
replace SiteName = "Gadabo Dispensary"	if SiteID==	3304110014
replace SiteName = "Gidan Hashimu Dispensary"	if SiteID==	3304110015
replace SiteName = "Tsitse Dispensary"	if SiteID==	3304110016
replace SiteName = "Gidan Albakari Dispensary"	if SiteID==	3304110017
replace SiteName = "Illah Dispensary"	if SiteID==	3304110018
replace SiteName = "PHC Dukamaje"	if SiteID==	3304110019
replace SiteName = "Rabamawa Dispensary"	if SiteID==	3304110020
replace SiteName = "Tsagal gale Dispensary"	if SiteID==	3304110021
replace SiteName = "Gidan Amamata Dispensary"	if SiteID==	3304110022
replace SiteName = "Holai Dispensary"	if SiteID==	3304110023
replace SiteName = "Kyadawa Dispensary"	if SiteID==	3304110024
replace SiteName = "PHC Wauru"	if SiteID==	3304110025
replace SiteName = "Safiyal Dispensary"	if SiteID==	3304110026
replace SiteName = "Gidan Dabo Dispensary"	if SiteID==	3304110027
replace SiteName = "Kiri Dispensary"	if SiteID==	3304110028
replace SiteName = "Gilbadi Dispensary"	if SiteID==	3304110029
replace SiteName = "Tsaro Dispensary"	if SiteID==	3304110030
replace SiteName = "Kadassaka Dispensary"	if SiteID==	3304110031
replace SiteName = "Tudun Bulus Dispensary"	if SiteID==	3304110032
replace SiteName = "Kwarma Dispensary"	if SiteID==	3304110033
replace SiteName = "Rafin Duma Dispensary"	if SiteID==	3304110034
replace SiteName = "Tufai Baba Dispensary"	if SiteID==	3304110035
replace SiteName = "Takalmawa Community Disp"	if SiteID==	3304110036
replace SiteName = "Sabon Gida Dispensary"	if SiteID==	3304110037
replace SiteName = "Bare Dispensary"	if SiteID==	3305110001
replace SiteName = "Darbabiya Dispensary"	if SiteID==	3305110002
replace SiteName = "Kojiyo Dispensary"	if SiteID==	3305110003
replace SiteName = "Birjingo Dispensary"	if SiteID==	3305110004
replace SiteName = "Gidan Mata Dispensary"	if SiteID==	3305110005
replace SiteName = "Ganza Dispensary"	if SiteID==	3305110006
replace SiteName = "Boyekai Dispensary"	if SiteID==	3305110007
replace SiteName = "Gamiha Kawara Dispensary"	if SiteID==	3305110008
replace SiteName = "Dantasakko Dsipensary"	if SiteID==	3305110009
replace SiteName = "Danwaru Dispensary"	if SiteID==	3305110010
replace SiteName = "Kamitau Dispensary"	if SiteID==	3305110011
replace SiteName = "Sabon  Gari Dole Dispensary"	if SiteID==	3305110012
replace SiteName = "Kubutta Dispensary"	if SiteID==	3305110013
replace SiteName = "T/G Dole Dispensary"	if SiteID==	3305110014
replace SiteName = "Facilaya Dsipensary"	if SiteID==	3305110015
replace SiteName = "Kaikazzaka Dsipensary"	if SiteID==	3305110016
replace SiteName = "Rimawa Dispensary"	if SiteID==	3305110017
replace SiteName = "Fadarawa Dispensary"	if SiteID==	3305110018
replace SiteName = "Gidan Barau Dispensary"	if SiteID==	3305110019
replace SiteName = "Kwakwazo Dispensary"	if SiteID==	3305110020
replace SiteName = "Miyal Yako Dispensary"	if SiteID==	3305110021
replace SiteName = "Giyawa Dispensary"	if SiteID==	3305110022
replace SiteName = "Gorau Dispensary"	if SiteID==	3305110023
replace SiteName = "Takakume Dispensary"	if SiteID==	3305110024
replace SiteName = "Kagara Dispensary"	if SiteID==	3305110025
replace SiteName = "Illela Dawagari Dispensary"	if SiteID==	3305110026
replace SiteName = "PHC Goronyo"	if SiteID==	3305110027
replace SiteName = "Taloka Dispensary"	if SiteID==	3305110028
replace SiteName = "Illela Huda Dispensary"	if SiteID==	3305110029
replace SiteName = "PHC Shinaka"	if SiteID==	3305110030
replace SiteName = "Tuluske Dispensary"	if SiteID==	3305110031
replace SiteName = "Zamace Dsipensary"	if SiteID==	3305110032
replace SiteName = "Zamace Dsipensary"	if SiteID==	3305110033
replace SiteName = "Bachaka Dispensary"	if SiteID==	3306110001
replace SiteName = "Salewa Dispensary"	if SiteID==	3306110002
replace SiteName = "Boto Dispensary"	if SiteID==	3306110003
replace SiteName = "Yaka Dispensary"	if SiteID==	3306110004
replace SiteName = "Chilas Dispensary"	if SiteID==	3306110005
replace SiteName = "Dangadabro Dispensary"	if SiteID==	3306110006
replace SiteName = "Makuya Dispenary"	if SiteID==	3306110007
replace SiteName = "Bungel Dispensary"	if SiteID==	3306110008
replace SiteName = "Karfen Chana Dispensary"	if SiteID==	3306110009
replace SiteName = "Katsura Dispensary"	if SiteID==	3306110010
replace SiteName = "PHC Kurdula"	if SiteID==	3306110011
replace SiteName = "Darusa Gawo Dispensary"	if SiteID==	3306110012
replace SiteName = "Bare-bari dispensary"	if SiteID==	3306110013
replace SiteName = "Kukoki Dispensary"	if SiteID==	3306110014
replace SiteName = "Jima-Jimi Dispensary"	if SiteID==	3306110015
replace SiteName = "Marake Dispensary"	if SiteID==	3306110016
replace SiteName = "PHC Balle"	if SiteID==	3306110017
replace SiteName = "Rafin kubu Dispensary"	if SiteID==	3306110018
replace SiteName = "PHC Karfen Sarki"	if SiteID==	3306110019
replace SiteName = "Filasko Dispensary"	if SiteID==	3306110020
replace SiteName = "Tullun-Doya Dispensary"	if SiteID==	3306110021
replace SiteName = "Illela Dispensary"	if SiteID==	3306110022
replace SiteName = "Asara Dispensary"	if SiteID==	3307110001
replace SiteName = "Rumbuje Dispensary"	if SiteID==	3307110002
replace SiteName = "Tungar Tudu Biga Dispensary"	if SiteID==	3307110003
replace SiteName = "Attakwanyo Dispensary"	if SiteID==	3307110004
replace SiteName = "Burdi Dispensary"	if SiteID==	3307110005
replace SiteName = "Kangiye Dispensary"	if SiteID==	3307110006
replace SiteName = "Katalla Dispensary"	if SiteID==	3307110007
replace SiteName = "Chimmola Dispensary"	if SiteID==	3307110008
replace SiteName = "Kwankwanbilo Dispensary"	if SiteID==	3307110009
replace SiteName = "Kiliya Dispensary"	if SiteID==	3307110010
replace SiteName = "Dan Abba Dispensary"	if SiteID==	3307110011
replace SiteName = "Salame Dispensary"	if SiteID==	3307110012
replace SiteName = "Galadanchi Dispensary"	if SiteID==	3307110013
replace SiteName = "Gidan Dogaza Dipsensary"	if SiteID==	3307110014
replace SiteName = "Gidan kaya Dispensary"	if SiteID==	3307110015
replace SiteName = "Gwara Dispensary"	if SiteID==	3307110016
replace SiteName = "Kililawa Dispensary"	if SiteID==	3307110017
replace SiteName = "Yar Gada Dispensary"	if SiteID==	3307110018
replace SiteName = "Gigane Up-Graded Dispensary"	if SiteID==	3307110019
replace SiteName = "Meli Dispensary"	if SiteID==	3307110020
replace SiteName = "Sakamaru Dispensary"	if SiteID==	3307110021
replace SiteName = "Tunkura Dispensary"	if SiteID==	3307110022
replace SiteName = "Huchi Dispensary"	if SiteID==	3307110023
replace SiteName = "Fadan Kai Dsipensary"	if SiteID==	3307110024
replace SiteName = "Makina Dispensary"	if SiteID==	3307110025
replace SiteName = "Mamman Suka Dispensary"	if SiteID==	3307110026
replace SiteName = "Chancha Disppensary "	if SiteID==	3307110027
replace SiteName = "Ranganda Dispensary"	if SiteID==	3307110028
replace SiteName = "RHC Gwadabawa"	if SiteID==	3307110029
replace SiteName = "Tudun Doki Dispensary"	if SiteID==	3307110030
replace SiteName = "Tambagarka Dispensary"	if SiteID==	3307110031
replace SiteName = "Kalaba Dsiepnsary"	if SiteID==	3307110032
replace SiteName = "Wadai Dispensary"	if SiteID==	3307110033
replace SiteName = "Bamana Dispensary"	if SiteID==	3307110034
replace SiteName = "Mammande Dispensary"	if SiteID==	3307110035
replace SiteName = "Zugana Dispensary"	if SiteID==	3307110036
replace SiteName = "Amarawa Dispensary"	if SiteID==	3308110001
replace SiteName = "Aminchi Nursing Home"	if SiteID==	3308110002
replace SiteName = "Daboe Clinic & Maternity"	if SiteID==	3308110003
replace SiteName = "General Hospital Illela"	if SiteID==	3308210004
replace SiteName = "Nasiha Clinic"	if SiteID==	3308210005
replace SiteName = "Sonane Dispensary"	if SiteID==	3308110006
replace SiteName = "Staff clinic"	if SiteID==	3308110007
replace SiteName = "Town Dsipensary"	if SiteID==	3308110008
replace SiteName = "Tudun Gudale Dispensary"	if SiteID==	3308110009
replace SiteName = "Araba Up-Graded Dispensary"	if SiteID==	3308110010
replace SiteName = "Bakin Dutsi Dispensary"	if SiteID==	3308110011
replace SiteName = "Dan Boka Dispensary"	if SiteID==	3308110012
replace SiteName = "Dango Dispensary"	if SiteID==	3308110013
replace SiteName = "Basanta Dispensary"	if SiteID==	3308110014
replace SiteName = "Gaidau Dispensary"	if SiteID==	3308110015
replace SiteName = "Gidan katta Up-Graded Dispensary"	if SiteID==	3308110016
replace SiteName = "Buwade Dispensary"	if SiteID==	3308110017
replace SiteName = "Damba Up-Graded Dispensary"	if SiteID==	3308110018
replace SiteName = "Gudun Gudun Dispensary"	if SiteID==	3308110019
replace SiteName = "Tarke Dispensary"	if SiteID==	3308110020
replace SiteName = "Tsauna Dispensary"	if SiteID==	3308110021
replace SiteName = "Tumbulumkum Dispensary"	if SiteID==	3308110022
replace SiteName = "Darna Kiliya Dispensary"	if SiteID==	3308110023
replace SiteName = "Darna Sabon Gari Dispensary"	if SiteID==	3308110024
replace SiteName = "Gidan Tudu Dispensary"	if SiteID==	3308110025
replace SiteName = "Mullela Dispensary"	if SiteID==	3308110026
replace SiteName = "Dabagin Tankari Dispensary"	if SiteID==	3308110027
replace SiteName = "Darna Tsolawa Dispensary"	if SiteID==	3308110028
replace SiteName = "Garu Up-Graded Dispensary"	if SiteID==	3308110029
replace SiteName = "Tsangalandam Dispensary"	if SiteID==	3308110030
replace SiteName = "Gidan bango Dispensary"	if SiteID==	3308110031
replace SiteName = "Tozai Dispensary"	if SiteID==	3308110032
replace SiteName = "Ambarura Up-Graded Dispensary"	if SiteID==	3308110033
replace SiteName = "Gidan Hamma Dispensary"	if SiteID==	3308110034
replace SiteName = "Here Dispensary"	if SiteID==	3308110035
replace SiteName = "Jagai Dispensary"	if SiteID==	3308110036
replace SiteName = "Jema Dispensary"	if SiteID==	3308110037
replace SiteName = "Kalmalo Dispensary"	if SiteID==	3308110038
replace SiteName = "Runji Dispensary"	if SiteID==	3308110039
replace SiteName = "Lafani Dispensary"	if SiteID==	3308110040
replace SiteName = "Gidan Chiwake Dispensary"	if SiteID==	3308110041
replace SiteName = "Rungumawar  Gatti  Dispensary"	if SiteID==	3308110042
replace SiteName = "Rungumawar  Jao Dispensary"	if SiteID==	3308110043
replace SiteName = "Harigawa Dispensary"	if SiteID==	3308110044
replace SiteName = "Adarawa Dispensary"	if SiteID==	3309110001
replace SiteName = "Chohi Dispensary"	if SiteID==	3309110002
replace SiteName = "Gamaroji Community Dispensary"	if SiteID==	3309110003
replace SiteName = "KaiKairu Dispensary"	if SiteID==	3309110004
replace SiteName = "Tidibali Dispensary"	if SiteID==	3309110005
replace SiteName = "Katanga Dispensary"	if SiteID==	3309110006
replace SiteName = "Dan Adamma Community Dispensary"	if SiteID==	3309110007
replace SiteName = "Satiru Up-graded Dispensary"	if SiteID==	3309110008
replace SiteName = "Tozai Dispensary"	if SiteID==	3309110009
replace SiteName = "Bargaja  Dispensary"	if SiteID==	3309110010
replace SiteName = "Danzanke Up-graded Dispensary"	if SiteID==	3309110011
replace SiteName = "Gazau Dispensary"	if SiteID==	3309110012
replace SiteName = "Kalage Community Dispensary"	if SiteID==	3309110013
replace SiteName = "Modachi Dispensary"	if SiteID==	3309110014
replace SiteName = "Dan Yada Dispensary"	if SiteID==	3309110015
replace SiteName = "Gari Ubandawaki Comm. Disp"	if SiteID==	3309110016
replace SiteName = "Tafkin Fili Up-graded Dispensary"	if SiteID==	3309110017
replace SiteName = "Yanfako Dispensary"	if SiteID==	3309110018
replace SiteName = "Gebe Upgraded Dispensary"	if SiteID==	3309110019
replace SiteName = "Manawa Dispensary"	if SiteID==	3309110020
replace SiteName = "Sabon Gari Dangwandi Community Dispensary"	if SiteID==	3309110021
replace SiteName = "Sabon Gari Kamarawa Dispensary"	if SiteID==	3309110022
replace SiteName = "PHC Bafarawa"	if SiteID==	3309110023
replace SiteName = "Suruddubu Dispensary"	if SiteID==	3309110024
replace SiteName = "General  Hospital Isa"	if SiteID==	3309210025
replace SiteName = "MCH  Isa"	if SiteID==	3309210026
replace SiteName = "Gidan Dikko Dispensary"	if SiteID==	3309110027
replace SiteName = "Girnashe Dispensary"	if SiteID==	3309110028
replace SiteName = "Tsabre Dispensary"	if SiteID==	3309110029
replace SiteName = "Gumal Up-graded Dispensary"	if SiteID==	3309110030
replace SiteName = "Shallah Dispensary"	if SiteID==	3309110031
replace SiteName = "Turba Dispensary"	if SiteID==	3309110032
replace SiteName = "Kaurar Mota Up-graded Dispensary"	if SiteID==	3309110033
replace SiteName = "Kwanar Isa  community Dispensary"	if SiteID==	3309110034
replace SiteName = "Tudunwada Up-graded Dispensary"	if SiteID==	3309110035
replace SiteName = "Fakku Up-Graded Dispensary"	if SiteID==	3310110001
replace SiteName = "Rara Dispensary"	if SiteID==	3310110002
replace SiteName = "Girkau Up-Graded Dispensary"	if SiteID==	3310110003
replace SiteName = "Jabga Dispensary"	if SiteID==	3310110004
replace SiteName = "Zugu Dispensary"	if SiteID==	3310110005
replace SiteName = "Jigawa dispensary"	if SiteID==	3310110006
replace SiteName = "Sabon Birni Dispensary"	if SiteID==	3310110007
replace SiteName = "Sangi Dispensary"	if SiteID==	3310110008
replace SiteName = "Jigiri Dispensary"	if SiteID==	3310110009
replace SiteName = "Karma Dispensary"	if SiteID==	3310110010
replace SiteName = "Gadacce Dispensary"	if SiteID==	3310110011
replace SiteName = "Margai Dispensary"	if SiteID==	3310110012
replace SiteName = "General Hospital Kebbe"	if SiteID==	3310210013
replace SiteName = "Kebbe Up-Graded Dispensary"	if SiteID==	3310110014
replace SiteName = "Umbutu Dispensary"	if SiteID==	3310110015
replace SiteName = "Kuchi Up-Graded Dispensary"	if SiteID==	3310110016
replace SiteName = "PHC Kuchi"	if SiteID==	3310110017
replace SiteName = "Ungushi Dispensary"	if SiteID==	3310110018
replace SiteName = "Nasagudu Dispensary"	if SiteID==	3310110019
replace SiteName = "Kunduttu Dispensary"	if SiteID==	3310110020
replace SiteName = "Maikurfuna Dispensary "	if SiteID==	3310110021
replace SiteName = "Dukura Dispensary"	if SiteID==	3310110022
replace SiteName = "Sha Alwashi Dispensary"	if SiteID==	3310110023
replace SiteName = "Basansan community Dispensary"	if SiteID==	3311110001
replace SiteName = "Lemi Dispensary"	if SiteID==	3311110002
replace SiteName = "Comprehensive Health Center Kware"	if SiteID==	3311110003
replace SiteName = "Kalalawa Dispensary "	if SiteID==	3311110004
replace SiteName = "Kasgada Dispensary"	if SiteID==	3311110005
replace SiteName = "Durbawa Up-Graded Dispensary"	if SiteID==	3311110006
replace SiteName = "Federal Psychiatric Hospital"	if SiteID==	3311310007
replace SiteName = "PHC Kware"	if SiteID==	3311110008
replace SiteName = "Ruggar Liman Dispensary"	if SiteID==	3311110009
replace SiteName = "Runji Dispensary"	if SiteID==	3311110010
replace SiteName = "Federal Science School Clinic "	if SiteID==	3311110011
replace SiteName = "Gundunga  Dispensary"	if SiteID==	3311110012
replace SiteName = "Ihi Dispensary"	if SiteID==	3311110013
replace SiteName = "Model PHC Balkore"	if SiteID==	3311110014
replace SiteName = "T/Galadima Dispensary"	if SiteID==	3311110015
replace SiteName = "Gidan Maikara Dispensary"	if SiteID==	3311110016
replace SiteName = "Hamma Ali Up-Graded Dispensary"	if SiteID==	3311110017
replace SiteName = "Hausawa Dispensary"	if SiteID==	3311110018
replace SiteName = "Karandai Dispensary"	if SiteID==	3311110019
replace SiteName = "Marbawa Upgraded Dispensary"	if SiteID==	3311110020
replace SiteName = "Kabanga Dispensary"	if SiteID==	3311110021
replace SiteName = "Malamawa Adada Dispensary"	if SiteID==	3311110022
replace SiteName = "Mallamawa Yari Dispensary"	if SiteID==	3311110023
replace SiteName = "Tunga Dispensary"	if SiteID==	3311110024
replace SiteName = "Siri Jalo Dispensary"	if SiteID==	3311110025
replace SiteName = "Tsaki Community Dispensary"	if SiteID==	3311110026
replace SiteName = "Lambo Community Dispensary"	if SiteID==	3311110027
replace SiteName = "Wallakae Dispensary"	if SiteID==	3311110028
replace SiteName = "Zammau Dispensary"	if SiteID==	3311110029
replace SiteName = "PHC Gandi"	if SiteID==	3312110001
replace SiteName = "Alikiru Dispensary"	if SiteID==	3312110002
replace SiteName = "Dankarmawa Dispensary"	if SiteID==	3312110003
replace SiteName = "Angamba Dispensary"	if SiteID==	3312110004
replace SiteName = "Gidan Buwai Dispensary"	if SiteID==	3312110005
replace SiteName = "Gododdi Dispensary"	if SiteID==	3312110006
replace SiteName = "Kurya Dispensary"	if SiteID==	3312110007
replace SiteName = "Maikujera Dispensary"	if SiteID==	3312110008
replace SiteName = "Riji Dispensary"	if SiteID==	3312110009
replace SiteName = "Gidan Doka Dispensary"	if SiteID==	3312110010
replace SiteName = "Burmawa Dispensary"	if SiteID==	3312110011
replace SiteName = "Gawakuke Dispensary"	if SiteID==	3312110012
replace SiteName = "Tofa Dispensary"	if SiteID==	3312110013
replace SiteName = "General Hospital Rabah"	if SiteID==	3312210014
replace SiteName = "Town Dispensary Rabah"	if SiteID==	3312110015
replace SiteName = "PHC Rara"	if SiteID==	3312110016
replace SiteName = "Sabaru Dispensary"	if SiteID==	3312110017
replace SiteName = "Tursa Dispensary"	if SiteID==	3312110018
replace SiteName = "Tsamiya Dispensary"	if SiteID==	3312110019
replace SiteName = "Yartsakuwa Dispensary"	if SiteID==	3312110020
replace SiteName = "Badama Dispensary"	if SiteID==	3312110021
replace SiteName = "Dudu-Barade Dispensary"	if SiteID==	3312110022
replace SiteName = "Gidan Almajir Dispensary"	if SiteID==	3312110023
replace SiteName = "Gidan Dan'Ayya Dispensary"	if SiteID==	3312110024
replace SiteName = "Rawkwamni Dispensary"	if SiteID==	3312110025
replace SiteName = "Sabon Gari"	if SiteID==	3312110026
replace SiteName = "Tabanni Dispensary"	if SiteID==	3312110027
replace SiteName = "Warwanna Dispensary"	if SiteID==	3312110028
replace SiteName = "Bachaka Dispensary"	if SiteID==	3313110001
replace SiteName = "D/Kware Dispensary"	if SiteID==	3313110002
replace SiteName = "Gidan Umaru Dispensary"	if SiteID==	3313110003
replace SiteName = "Kalage Dispensary"	if SiteID==	3313110004
replace SiteName = "Kyara Dispensary "	if SiteID==	3313110005
replace SiteName = "T/Tsaba Dispensary"	if SiteID==	3313110006
replace SiteName = "Tara Dispensary"	if SiteID==	3313110007
replace SiteName = "Bambadawa Dispensary"	if SiteID==	3313110008
replace SiteName = "Burkusuma Dispensary"	if SiteID==	3313110009
replace SiteName = "Gangara Dispensary"	if SiteID==	3313110010
replace SiteName = "Dama Dispensary"	if SiteID==	3313110011
replace SiteName = "Dan Kura Dispensary"	if SiteID==	3313110012
replace SiteName = "Dabugi Dispensary"	if SiteID==	3313110013
replace SiteName = "Dakwaro Dispensary"	if SiteID==	3313110014
replace SiteName = "Kurawa Dispensary"	if SiteID==	3313110015
replace SiteName = "Dan Maliki Dispensary"	if SiteID==	3313110016
replace SiteName = "Kalgo Dispensary"	if SiteID==	3313110017
replace SiteName = "Teke Dispensary"	if SiteID==	3313110018
replace SiteName = "Dantudu Dispensary"	if SiteID==	3313110019
replace SiteName = "Lanjego Dispensary"	if SiteID==	3313110020
replace SiteName = "Lanjinge Dispensary"	if SiteID==	3313110021
replace SiteName = "Garin Gado Dispensary"	if SiteID==	3313110022
replace SiteName = "Gayya Dakwari Dispensary"	if SiteID==	3313110023
replace SiteName = "Kiratawa Dispensary"	if SiteID==	3313110024
replace SiteName = "Magarau Dispensary"	if SiteID==	3313110025
replace SiteName = "Mallamawa Dispensary"	if SiteID==	3313110026
replace SiteName = "Sangarawa Dispensary"	if SiteID==	3313110027
replace SiteName = "Ungwar Lalle Dispensary"	if SiteID==	3313110028
replace SiteName = "Yar Bulutu Dispensary"	if SiteID==	3313110029
replace SiteName = "Garin Idi dispensary"	if SiteID==	3313110030
replace SiteName = "Kwatsal Dispensary"	if SiteID==	3313110031
replace SiteName = "Nasara Clinic Sabon Birni"	if SiteID==	3313110032
replace SiteName = "PHC Sabon Birni"	if SiteID==	3313110033
replace SiteName = "Son Allah Clinic"	if SiteID==	3313110034
replace SiteName = "Garin Abara Dispensary"	if SiteID==	3313110035
replace SiteName = "Gawo Dispensary"	if SiteID==	3313110036
replace SiteName = "Tsamaye Dispensary"	if SiteID==	3313110037
replace SiteName = "Labau Dispensary"	if SiteID==	3313110038
replace SiteName = "Magira Dispensary"	if SiteID==	3313110039
replace SiteName = "Model PHC Gatawa"	if SiteID==	3313110040
replace SiteName = "Makuwana Dispensary"	if SiteID==	3313110041
replace SiteName = "Aggur Dispensary"	if SiteID==	3314110001
replace SiteName = "Kajiji Up-Graded Dispensary"	if SiteID==	3314110002
replace SiteName = "Kesoje Dispensary"	if SiteID==	3314110003
replace SiteName = "Ruggar Dispensary"	if SiteID==	3314110004
replace SiteName = "Dan Baro Dispensary Horo"	if SiteID==	3314110005
replace SiteName = "Ginga Dispensary"	if SiteID==	3314110006
replace SiteName = "Model PHC Horo"	if SiteID==	3314110007
replace SiteName = "Dandin Mahe Up-Graded Dispensary"	if SiteID==	3314110008
replace SiteName = "Mabera Dispensary"	if SiteID==	3314110009
replace SiteName = "Ruggar Mallam Dispensary"	if SiteID==	3314110010
replace SiteName = "Darin Guru Dispensary"	if SiteID==	3314110011
replace SiteName = "Gidan Tudu Dispensary"	if SiteID==	3314110012
replace SiteName = "Tungar Barki Dispensary"	if SiteID==	3314110013
replace SiteName = "Gam-Gam Dispensary"	if SiteID==	3314110014
replace SiteName = "Doruwa Dispensary"	if SiteID==	3314110015
replace SiteName = "Jandutsi Dispensary"	if SiteID==	3314110016
replace SiteName = "Lambara Dsipensary"	if SiteID==	3314110017
replace SiteName = "Mandera Dispensary"	if SiteID==	3314110018
replace SiteName = "Jaredi Dispensary"	if SiteID==	3314110019
replace SiteName = "Bullan Yaki Dispensary"	if SiteID==	3314110020
replace SiteName = "Kalangu Dispensary"	if SiteID==	3314110021
replace SiteName = "PHC Sanyinnawal Dispensary"	if SiteID==	3314110022
replace SiteName = "Runji Kaka Dispensary"	if SiteID==	3314110023
replace SiteName = "Sullubawa Dispensary"	if SiteID==	3314110024
replace SiteName = "Kambama Up-Graded Dispensary"	if SiteID==	3314110025
replace SiteName = "PHC Shagari"	if SiteID==	3314110026
replace SiteName = "Wanke Dispensary"	if SiteID==	3314110027
replace SiteName = "Chofal Dispensary"	if SiteID==	3315110001
replace SiteName = "Gaukai Dispensary"	if SiteID==	3315110002
replace SiteName = "Dankala Dsipensary"	if SiteID==	3315110003
replace SiteName = "Kaya Dispensary"	if SiteID==	3315110004
replace SiteName = "Zarengo Dispensary"	if SiteID==	3315110005
replace SiteName = "PHC Gande"	if SiteID==	3315110006
replace SiteName = "G.Magaji Dispensary"	if SiteID==	3315110007
replace SiteName = "Male Dispensary"	if SiteID==	3315110008
replace SiteName = "Galadi Dispensary"	if SiteID==	3315110009
replace SiteName = "Kwagyal Dispensary"	if SiteID==	3315110010
replace SiteName = "Rundi Dispensary"	if SiteID==	3315110011
replace SiteName = "Betare Dispensary"	if SiteID==	3315110012
replace SiteName = "Katami Up-Graded Dispensary"	if SiteID==	3315110013
replace SiteName = "Gandanbe Dispensary"	if SiteID==	3315110014
replace SiteName = "Tanera Dispensary"	if SiteID==	3315110015
replace SiteName = "Tungar Isah Dispensary"	if SiteID==	3315110016
replace SiteName = "Ruggar Fulani Dispensary"	if SiteID==	3315110017
replace SiteName = "Gujiya Dispensary"	if SiteID==	3315110018
replace SiteName = "Gunki Dispensary"	if SiteID==	3315110019
replace SiteName = "Marafa Dispensary"	if SiteID==	3315110020
replace SiteName = "Gungu Dispensary"	if SiteID==	3315110021
replace SiteName = "Danjawa Dispensary"	if SiteID==	3315110022
replace SiteName = "Jekanadu Dispensary"	if SiteID==	3315110023
replace SiteName = "Kubodu Dispensary"	if SiteID==	3315110024
replace SiteName = "Shabra Dispensary"	if SiteID==	3315110025
replace SiteName = "Kubodu B"	if SiteID==	3315110026
replace SiteName = "Labani Dispensary"	if SiteID==	3315110027
replace SiteName = "Maje Dispensary"	if SiteID==	3315110028
replace SiteName = "Tungar Abdu Dispensary"	if SiteID==	3315110029
replace SiteName = "PHC Silame"	if SiteID==	3315110030
replace SiteName = "Tozo Dispensary"	if SiteID==	3315110031
replace SiteName = "Gabbuwa Dispensary"	if SiteID==	3315110032
replace SiteName = "Alkamawa Basic Health Clinic"	if SiteID==	3316110001
replace SiteName = "Helele  Basic Health Clinic"	if SiteID==	3316110002
replace SiteName = "Assada Dispensary"	if SiteID==	3316110003
replace SiteName = "Central Market Clinic"	if SiteID==	3316110004
replace SiteName = "Kofar kade Basic Health Clinic"	if SiteID==	3316110005
replace SiteName = "Sokoto Clinic"	if SiteID==	3316220006
replace SiteName = "Rumbunkawa Basic Health Clinic"	if SiteID==	3316110007
replace SiteName = "Kofar Rini Basic Health Clinic"	if SiteID==	3316110008
replace SiteName = "Runji Sambo Basaic Health Clinic"	if SiteID==	3316110009
replace SiteName = "Noma Hospital"	if SiteID==	3316210010
replace SiteName = "Sultan Palace Clinic"	if SiteID==	3316110011
replace SiteName = "Women and Children Welfare Clinic"	if SiteID==	3316210012
replace SiteName = "Rini Tawaye Clinic"	if SiteID==	3316110013
replace SiteName = "Holy Family Clinic"	if SiteID==	3316210014
replace SiteName = "Alfijir Specialist hospital"	if SiteID==	3317220001
replace SiteName = "Marina Clinic"	if SiteID==	3317220002
replace SiteName = "Tudunwada Clinic"	if SiteID==	3317110003
replace SiteName = "Anas Private Hospital"	if SiteID==	3317220004
replace SiteName = "Standard Hospital"	if SiteID==	3317220005
replace SiteName = "Gidan Masau Dispensary"	if SiteID==	3317110006
replace SiteName = "Gagi Basic health Clinic"	if SiteID==	3317110007
replace SiteName = "Devine Health Clinic"	if SiteID==	3317220008
replace SiteName = "Mabera Mujaya Dispensary"	if SiteID==	3317110009
replace SiteName = "Freehand Specialist Hospital"	if SiteID==	3317220010
replace SiteName = "Gidan Dahala Dispensary"	if SiteID==	3317110011
replace SiteName = "Mabera Basic Health Clinic"	if SiteID==	3317110012
replace SiteName = "Police Clinic"	if SiteID==	3317110013
replace SiteName = "Saraki Specialist Hospital"	if SiteID==	3317220014
replace SiteName = "Sheperd Clinic"	if SiteID==	3317220015
replace SiteName = "Wali Bako Clinic"	if SiteID==	3317220016
replace SiteName = "Maryam Abacha Women & Children Hospital"	if SiteID==	3317210017
replace SiteName = "Godiya Clinic"	if SiteID==	3317220018
replace SiteName = "Sahel Specialist Hospital"	if SiteID==	3317220019
replace SiteName = "Aliyu Jodi Clinic"	if SiteID==	3317220020
replace SiteName = "Hussein Medical Center"	if SiteID==	3317220021
replace SiteName = "Hamdala Clinic"	if SiteID==	3317220022
replace SiteName = "Yar Akija basic Health Clinic"	if SiteID==	3317110023
replace SiteName = "Zafari Hospital"	if SiteID==	3317220024
replace SiteName = "Karaye Clinic"	if SiteID==	3317220025
replace SiteName = "PPFN Clinic"	if SiteID==	3317110026
replace SiteName = "Rijiya Clinic"	if SiteID==	3317220027
replace SiteName = "Specialist Hospital, Sokoto"	if SiteID==	3317210028
replace SiteName = "Toraro Clinic"	if SiteID==	3317220029
replace SiteName = "Bagida Dispensary"	if SiteID==	3318110001
replace SiteName = "Danmadi Dispensary"	if SiteID==	3318110002
replace SiteName = "Dogon Marke Dispensary"	if SiteID==	3318110003
replace SiteName = "Ganuwa Dispensary"	if SiteID==	3318110004
replace SiteName = "Bancho Dispensary"	if SiteID==	3318110005
replace SiteName = "General Hospital  Dogon Daji"	if SiteID==	3318210006
replace SiteName = "Kalgo Magaji Dispensary"	if SiteID==	3318110007
replace SiteName = "Maikada Dispensary"	if SiteID==	3318110008
replace SiteName = "MaiKade Dispensary"	if SiteID==	3318110009
replace SiteName = "Salah Dispensary"	if SiteID==	3318110010
replace SiteName = "Town Dispensary Dogon Daji"	if SiteID==	3318110011
replace SiteName = "Nabaguda Community Dispensary"	if SiteID==	3318110012
replace SiteName = "Sabawa Dispensary"	if SiteID==	3318110013
replace SiteName = "Kaura Dispensary"	if SiteID==	3318110014
replace SiteName = "Faga Dispensary"	if SiteID==	3318110015
replace SiteName = "Model PHC Faga"	if SiteID==	3318110016
replace SiteName = "Bashire Up-Graded Dispensary"	if SiteID==	3318110017
replace SiteName = "Masu dispensary"	if SiteID==	3318110018
replace SiteName = "Modo Dispensary"	if SiteID==	3318110019
replace SiteName = "PHC Jabo"	if SiteID==	3318110020
replace SiteName = "Charai Dispensary"	if SiteID==	3318110021
replace SiteName = "Hiliya Dispensary"	if SiteID==	3318110022
replace SiteName = "G/salodi Dispensary"	if SiteID==	3318110023
replace SiteName = "H/Guraye Dispensary"	if SiteID==	3318110024
replace SiteName = "Kagara Dispensary "	if SiteID==	3318110025
replace SiteName = "Bangala Dispensary"	if SiteID==	3318110026
replace SiteName = "Gambuwa Dispensary"	if SiteID==	3318110027
replace SiteName = "Garan Dispensary"	if SiteID==	3318110028
replace SiteName = "Goshe Dispensary"	if SiteID==	3318110029
replace SiteName = "Gudun Dispensary"	if SiteID==	3318110030
replace SiteName = "General Hospital Tambuwal"	if SiteID==	3318210031
replace SiteName = "PHC Tambuwal"	if SiteID==	3318110032
replace SiteName = "Shinfiri Dispensary"	if SiteID==	3318110033
replace SiteName = "Romo Dispensary"	if SiteID==	3318110034
replace SiteName = "Romon Liman Dispensary"	if SiteID==	3318110035
replace SiteName = "Illoje Dispensary"	if SiteID==	3318110036
replace SiteName = "Bakaya Dispensary"	if SiteID==	3318110037
replace SiteName = "Madacci Community Dispensary"	if SiteID==	3318110038
replace SiteName = "Kaya Dispensary"	if SiteID==	3318110039
replace SiteName = "Barga Dispensary"	if SiteID==	3318110040
replace SiteName = "PHC Sayinna"	if SiteID==	3318110041
replace SiteName = "Saida Dispensary"	if SiteID==	3318110042
replace SiteName = "Tandamare Dispensary"	if SiteID==	3318110043
replace SiteName = "Buwade Dispensary"	if SiteID==	3318110044
replace SiteName = "Tsiwa dispensary"	if SiteID==	3318110045
replace SiteName = "Ungwar D/Kande Dispensary"	if SiteID==	3318110046
replace SiteName = "Gozama dispensary"	if SiteID==	3318110047
replace SiteName = "Tunga Community dispensary"	if SiteID==	3318110048
replace SiteName = "Gambu dispensary"	if SiteID==	3318110049
replace SiteName = "Alela Dispensary"	if SiteID==	3319110001
replace SiteName = "Bararahe Up-graded Dispensary"	if SiteID==	3319110002
replace SiteName = "Kwaraka Dispensary"	if SiteID==	3319110003
replace SiteName = "Rini Dispensary"	if SiteID==	3319110004
replace SiteName = "Sakkwai Up-graded Dispensary"	if SiteID==	3319110005
replace SiteName = "Alkasum Dispensary"	if SiteID==	3319110006
replace SiteName = "Kandam Dispensary"	if SiteID==	3319110007
replace SiteName = "Mano Dispensary"	if SiteID==	3319110008
replace SiteName = "Wasaniya Dispensary"	if SiteID==	3319110009
replace SiteName = "Baidi Dispensary"	if SiteID==	3319110010
replace SiteName = "General Hospital Tangaza"	if SiteID==	3319210011
replace SiteName = "Gurdam Up-graded Dispensary"	if SiteID==	3319110012
replace SiteName = "Labsani Dispensary"	if SiteID==	3319110013
replace SiteName = "Town Dispensary Tangaza"	if SiteID==	3319110014
replace SiteName = "Gidan Dadi Up-graded Dispensary"	if SiteID==	3319110015
replace SiteName = "PHC Gidan madi"	if SiteID==	3319110016
replace SiteName = "Gidima Dispensary"	if SiteID==	3319110017
replace SiteName = "Kalanjeni Dispensary"	if SiteID==	3319110018
replace SiteName = "Kaura Dispensary"	if SiteID==	3319110019
replace SiteName = "Araba Dispensary"	if SiteID==	3319110020
replace SiteName = "Kwacce Huro Dispensary"	if SiteID==	3319110021
replace SiteName = "Kwanawa Up-graded Dispensary"	if SiteID==	3319110022
replace SiteName = "Ginjo Dispensary"	if SiteID==	3319110023
replace SiteName = "Masallachi  Dispensary"	if SiteID==	3319110024
replace SiteName = "Mogonho Up-graded Dispensary"	if SiteID==	3319110025
replace SiteName = "Sanyinna Dispensary"	if SiteID==	3319110026
replace SiteName = "Takkau Dispensary"	if SiteID==	3319110027
replace SiteName = "Gandaba Dispensary"	if SiteID==	3319110028
replace SiteName = "Raka Up-graded Dispensary"	if SiteID==	3319110029
replace SiteName = "Manja Up-graded Dispensary"	if SiteID==	3319110030
replace SiteName = "PHC Ruwa Wuri"	if SiteID==	3319110031
replace SiteName = "Sarma A Dispensary"	if SiteID==	3319110032
replace SiteName = "Sarma B Dispensary"	if SiteID==	3319110033
replace SiteName = "Tunigara Dispensary"	if SiteID==	3319110034
replace SiteName = "Salewa Dispensary"	if SiteID==	3319110035
replace SiteName = "Bauni Up-graded Dispensary"	if SiteID==	3319110036
replace SiteName = "Zurmuku Dispensary"	if SiteID==	3319110037
replace SiteName = "Bimasa Dispensary"	if SiteID==	332011001
replace SiteName = "Dorawa Dispensary"	if SiteID==	332011002
replace SiteName = "Gidan kare Dispensary"	if SiteID==	332011003
replace SiteName = "Dangulbi Dispensary"	if SiteID==	332011004
replace SiteName = "Duma Dispensary"	if SiteID==	332011005
replace SiteName = "Fura Girke Dispensary"	if SiteID==	332011006
replace SiteName = "Garbe Kanni Dispensary"	if SiteID==	332011007
replace SiteName = "General Hospital Tureta"	if SiteID==	332021008
replace SiteName = "Town Dispensary Tureta"	if SiteID==	332011009
replace SiteName = "Rafin Bude Dispensary"	if SiteID==	332011010
replace SiteName = "Tsamiya Up-Graded Dispensary"	if SiteID==	332011011
replace SiteName = "Gidan Dangiwa Dispensary"	if SiteID==	332011012
replace SiteName = "Gidan Garkuwa"	if SiteID==	332011013
replace SiteName = "Lambar Tureta Up-Graded Dispensary"	if SiteID==	332011014
replace SiteName = "Galadima Dispensary"	if SiteID==	332011015
replace SiteName = "Kawara Dispensary"	if SiteID==	332011016
replace SiteName = "Kuruwa Dispensary"	if SiteID==	332011017
replace SiteName = "Kwarare Dispensary"	if SiteID==	332011018
replace SiteName = "Lofa Dispensary"	if SiteID==	332011019
replace SiteName = "Randa Dispensary"	if SiteID==	332011020
replace SiteName = "Arkilla Basic Health Clinic"	if SiteID==	3321110001
replace SiteName = "Government House Clinic"	if SiteID==	3321110002
replace SiteName = "Guiwa Community Dispensary"	if SiteID==	3321110003
replace SiteName = "Guiwa Primary Health Centre"	if SiteID==	3321110004
replace SiteName = "Kontagora Bsaic Health Clinic"	if SiteID==	3321110005
replace SiteName = "Jama’a Clinic"	if SiteID==	3321220006
replace SiteName = "Usman DanFodio UTH"	if SiteID==	3321310007
replace SiteName = "Asari Dipsensary"	if SiteID==	3321110008
replace SiteName = "Badano Dispensary"	if SiteID==	3321110009
replace SiteName = "Daraye Dispensary"	if SiteID==	3321110010
replace SiteName = "Gedawa dsiepnsary"	if SiteID==	3321110011
replace SiteName = "Liggyare Dispensary"	if SiteID==	3321110012
replace SiteName = "Yarume Dispensary"	if SiteID==	3321110013
replace SiteName = "Bado Dispensary"	if SiteID==	3321110014
replace SiteName = "Bini Basic Health Clinic"	if SiteID==	3321110015
replace SiteName = "Farfaru Basic Health Clinic"	if SiteID==	3321110016
replace SiteName = "Bagaya Dispensary"	if SiteID==	3321110017
replace SiteName = "Boyen Dutsi"	if SiteID==	3321110018
replace SiteName = "Yaurawa Dispensary"	if SiteID==	3321110019
replace SiteName = "Gidan  Habibu Dispensary"	if SiteID==	3321110020
replace SiteName = "Bakin Kusu Dispensary"	if SiteID==	3321110021
replace SiteName = "Danjawa Dispensary"	if SiteID==	3321110022
replace SiteName = "Dundaye Up-Graded Dispensary"	if SiteID==	3321110023
replace SiteName = "Yarlabe Dispensary"	if SiteID==	3321110024
replace SiteName = "Tambaraga Dispensary"	if SiteID==	3321110025
replace SiteName = "University Permanent Site Clinic"	if SiteID==	3321110026
replace SiteName = "Dankyal Dispensary"	if SiteID==	3321110027
replace SiteName = "Gwamatse Dispensary"	if SiteID==	3321110028
replace SiteName = "Fanari Dispensary"	if SiteID==	3321110029
replace SiteName = "Gatare Dispensary"	if SiteID==	3321110030
replace SiteName = "Ruggar monde Dispensary"	if SiteID==	3321110031
replace SiteName = "Gidan Sarki Dunki Dispensary"	if SiteID==	3321110032
replace SiteName = "Gidan Bubu Dsiepnsary"	if SiteID==	3321110033
replace SiteName = "Gidan Tudu Dispensary"	if SiteID==	3321110034
replace SiteName = "Gidan Yaro Dispensary"	if SiteID==	3321110035
replace SiteName = "Kasarawa  Community Dispensary"	if SiteID==	3321110036
replace SiteName = "Maganawa Dispensary"	if SiteID==	3321110037
replace SiteName = "Gumbi Dispensary"	if SiteID==	3321110038
replace SiteName = "Wajake Dispensary"	if SiteID==	3321110039
replace SiteName = "Yarabba Dispensary"	if SiteID==	3321110040
replace SiteName = "Mankeri Dispensary"	if SiteID==	3321110041
replace SiteName = "Wamakko Up-graded Dispensary"	if SiteID==	3321110042
replace SiteName = "Kaura Kimba Dsipensary "	if SiteID==	3321110043
replace SiteName = "Lafiya Clinic"	if SiteID==	3321220044
replace SiteName = "Lagau Dispensary"	if SiteID==	3321110045
replace SiteName = "Mobile Police  Clinic"	if SiteID==	3321110046
replace SiteName = "Samalu Dispensary"	if SiteID==	3321110047
replace SiteName = "Alkammu Dsipensary"	if SiteID==	3322110001
replace SiteName = "Gyalgyal Dispensary"	if SiteID==	3322110002
replace SiteName = "Barayar Zaki Up-graded Disp"	if SiteID==	3322110003
replace SiteName = "Kwargaba Dispensary"	if SiteID==	3322110004
replace SiteName = "Lugu Up-graded Dispensary"	if SiteID==	3322110005
replace SiteName = "Marnona Dispensary"	if SiteID==	3322110006
replace SiteName = "Chacho Dispensary"	if SiteID==	3322110007
replace SiteName = "Gawo Dispensary"	if SiteID==	3322110008
replace SiteName = "Kadagiwa Dispensary"	if SiteID==	3322110009
replace SiteName = "Munki Dispensary"	if SiteID==	3322110010
replace SiteName = "Dimbisu Dispensary"	if SiteID==	3322110011
replace SiteName = "Duhuwa Dispensary"	if SiteID==	3322110012
replace SiteName = "Dinawa Up-graded Dispensary"	if SiteID==	3322110013
replace SiteName = "General Hospital Wurno"	if SiteID==	3322210014
replace SiteName = "Kwasare Dispensary"	if SiteID==	3322110015
replace SiteName = "Sisawa Dispensary"	if SiteID==	3322110016
replace SiteName = "Lahodu Up-graded Dispensary"	if SiteID==	3322110017
replace SiteName = "Model PHC Achida"	if SiteID==	3322110018
replace SiteName = "PHC Achida"	if SiteID==	3322110019
replace SiteName = "Town Dispensary Wurno"	if SiteID==	3322110020
replace SiteName = "Tunga Up-graded Dispensary"	if SiteID==	3322110021
replace SiteName = "Gidan Bango Dispensary"	if SiteID==	3322110022
replace SiteName = "Government Secondary School Clinic"	if SiteID==	3322110023
replace SiteName = "Kandam Dispensary"	if SiteID==	3322110024
replace SiteName = "Sabon Gari Liman"	if SiteID==	3322110025
replace SiteName = "Sakketa Dispensary"	if SiteID==	3322110026
replace SiteName = "Tambaraga Dispensary"	if SiteID==	3322110027
replace SiteName = "Yantabau  Dispensary"	if SiteID==	3322110028
replace SiteName = "Bengaje Dispensary"	if SiteID==	3323110001
replace SiteName = "Dono Dispensary"	if SiteID==	3323110002
replace SiteName = "Birni Ruwa Dispensary"	if SiteID==	3323110003
replace SiteName = "Kamfatare Dsipensary"	if SiteID==	3323110004
replace SiteName = "Fakka Dispensary"	if SiteID==	3323110005
replace SiteName = "Gudurega Dispensary"	if SiteID==	3323110006
replace SiteName = "Binji Muza Dispensary"	if SiteID==	3323110007
replace SiteName = "Kibiyare Dispensary"	if SiteID==	3323110008
replace SiteName = "PHC Binji Muza"	if SiteID==	3323110009
replace SiteName = "PHC Kilgori"	if SiteID==	3323110010
replace SiteName = "Dagawa Dispensary"	if SiteID==	3323110011
replace SiteName = "Ruggar Kijo Dispensary"	if SiteID==	3323110012
replace SiteName = "Toronkawa Dispensary "	if SiteID==	3323110013
replace SiteName = "General Hospital Yabo"	if SiteID==	3323210014
replace SiteName = "Town Dispensary Yabo"	if SiteID==	3323110015
replace SiteName = "Shabra Dispensary"	if SiteID==	3323110016
replace SiteName = "Alkalije Dispensary"	if SiteID==	3323110017
replace SiteName = "Bakale Dispensary"	if SiteID==	3323110018
replace SiteName = "W.C.W.C Yabo"	if SiteID==	3323110019

replace SiteName ="Alkaleri G H" if SiteID ==501210001
replace SiteName ="Alkaleri Town Maternity" if SiteID==	501110002
replace SiteName ="Alkaleri Town Dispensary" if SiteID==	501110003
replace SiteName ="Bajama Com. Hlth. Centre" if SiteID==	501110004
replace SiteName ="Gigyara Health Centre" if SiteID==	501110005
replace SiteName ="Yankari Health Clinic" if SiteID==	501110006
replace SiteName ="Badaram Dutsi" if SiteID==	501110007
replace SiteName ="Jamda Dispensary" if SiteID==	501110008
replace SiteName ="Yalwan Duguri MPHC" if SiteID==	501110009
replace SiteName ="Dan Health Post" if SiteID==	501110010
replace SiteName ="Futuk Health Centre" if SiteID==	501110011
replace SiteName ="Garin Hamza Dispensary" if SiteID==	501110012
replace SiteName ="Gar Maternity" if SiteID==	501110013
replace SiteName ="Gangar Dispensary" if SiteID==	501110014
replace SiteName ="Guruntun Dispensary" if SiteID==	501110015
replace SiteName ="Gwana Maternity" if SiteID==	501110016
replace SiteName ="Gobirawa Health Centre" if SiteID==	501110017
replace SiteName ="Gwaram Maternity" if SiteID==	501110018
replace SiteName ="Gwaram Dispensary" if SiteID==	501110019
replace SiteName ="Gokaru Health Clinic" if SiteID==	501110020
replace SiteName ="Kaciciya Dispensary" if SiteID==	501110021
replace SiteName ="Shira Maternity" if SiteID==	501110022
replace SiteName ="Galen Duguri Health Centre" if SiteID==	501110023
replace SiteName ="Mainamaji Dispensary" if SiteID==	501110024
replace SiteName ="Kumbala Health Centre" if SiteID==	501110025
replace SiteName ="Mundamiyo Health Centre" if SiteID==	501110026
replace SiteName ="Kundak Dispensary" if SiteID==	501110027
replace SiteName ="Maimadi Health Centre" if SiteID==	501110028
replace SiteName ="Mari-Ari Health Centre" if SiteID==	501110029
replace SiteName ="Kwaimawa Health Post" if SiteID==	501110030
replace SiteName ="Jada Dispensary" if SiteID==	501110031
replace SiteName ="Mansur Health Centre" if SiteID==	501110032
replace SiteName ="Galen Mansur Health Centre" if SiteID==	501110033
replace SiteName ="Pali Health centre" if SiteID==	501110034
replace SiteName ="Bakin Kogi MPHC" if SiteID==	501110035
replace SiteName ="Yalo Health Centre" if SiteID==	501110036
replace SiteName ="Digare Dispensary" if SiteID==	501110037
replace SiteName ="Duguri HC" if SiteID==	501110038
replace SiteName ="Bojos Dispensary" if SiteID==	501110039
replace SiteName ="Duguri Dispensary" if SiteID==	501110040
replace SiteName ="Gaji Dispensary" if SiteID==	501110041
replace SiteName ="Moscow Health Clinic" if SiteID==	501120042
replace SiteName ="General Hospital Bayara" if SiteID==	502210001
replace SiteName ="Yolan Health Centre" if SiteID==	502110002
replace SiteName ="Buarnawa Dispensary" if SiteID==	502110003
replace SiteName ="Kadage" if SiteID==	502110004
replace SiteName ="Lusgi Dispensary" if SiteID==	502110005
replace SiteName ="Doya PHC" if SiteID==	502110006
replace SiteName ="Town Maternity" if SiteID==	502110007
replace SiteName ="Kofar Dumi Maternal & Child Health Clinic" if SiteID==	502110008
replace SiteName ="Ung. Mahaukata Health Centre" if SiteID==	502110009
replace SiteName ="Afor Clinic & Maternity" if SiteID==	502120010
replace SiteName ="Albishir Clinic" if SiteID==	502120011
replace SiteName ="Alheri Medical Clinic" if SiteID==	502120012
replace SiteName ="Alhissan MCH Clinic" if SiteID==	502120013
replace SiteName ="Almanzoor Diag. Center" if SiteID==	502120014
replace SiteName ="Alwadata Consult. Clinic" if SiteID==	502120015
replace SiteName ="Aminchi Clinic" if SiteID==	502120016
replace SiteName ="Amsad Clinic" if SiteID==	502120017
replace SiteName ="City Specialist" if SiteID==	502120018
replace SiteName ="Dambam Nursing Home" if SiteID==	502120019
replace SiteName ="Darussalam Health Clinic" if SiteID==	502120020
replace SiteName ="Kainuwa Clinic" if SiteID==	502120021
replace SiteName ="Keffi Clinic" if SiteID==	502120022
replace SiteName ="Maijama’a Clinic" if SiteID==	502120023
replace SiteName ="Makkah Eye Clinic" if SiteID==	502120024
replace SiteName ="Nagarta Clinic" if SiteID==	502120025
replace SiteName ="Nasara Health Clinic" if SiteID==	502120026
replace SiteName ="Ni'ima Consult. Clinic" if SiteID==	502120027
replace SiteName ="Peoples Clinic" if SiteID==	502120028
replace SiteName ="Phalicon Clinic" if SiteID==	502120029
replace SiteName ="Reemee Med. Care" if SiteID==	502120030
replace SiteName ="Royel Clinic" if SiteID==	502120031
replace SiteName ="Sabo Clinic" if SiteID==	502120032
replace SiteName ="Sauki Clinic" if SiteID==	502120033
replace SiteName ="Taimako Health Clinic" if SiteID==	502120034
replace SiteName ="Ubani Dental Clinic" if SiteID==	502120035
replace SiteName ="Yelwa Clinic & Maternity" if SiteID==	502120036
replace SiteName ="Gudun PHC" if SiteID==	502110037
replace SiteName ="Dandango Maternity" if SiteID==	502110038
replace SiteName ="Kir Maternity" if SiteID==	502110039
replace SiteName ="Abubakar Tafawa Balewa Teaching Hospital" if SiteID==	502310040
replace SiteName ="St Low Cost Maternal & Child Health Clinic" if SiteID==	502110041
replace SiteName ="Federal Low Cost Health Centre" if SiteID==	502110042
replace SiteName ="Police Clinic" if SiteID==	502110043
replace SiteName ="School of Armour Clinic" if SiteID==	502110044
replace SiteName ="33 Army Brigade Clinic " if SiteID==	502110045
replace SiteName ="Tashan Babiye PHC" if SiteID==	502110046
replace SiteName ="Azare Urban Maternity" if SiteID==	502110047
replace SiteName ="Dawaki Dispensary" if SiteID==	502110048
replace SiteName ="Badakoshi Maternal & Child Health Clinic" if SiteID==	502110049
replace SiteName ="Tudun Gambo Health Clinic" if SiteID==	502110050
replace SiteName ="Dindima Dispensary" if SiteID==	502110051
replace SiteName ="Galambi Dispensary" if SiteID==	502110052
replace SiteName ="Kurwala Dispensary" if SiteID==	502110053
replace SiteName ="Jalingo Dispensary" if SiteID==	502110054
replace SiteName ="Kwagal Dispensary" if SiteID==	502110055
replace SiteName ="Gwaskawaram Health Centre" if SiteID==	502110056
replace SiteName ="Jitar Health Clinic" if SiteID==	502110057
replace SiteName ="U/Dashi Dispensary" if SiteID==	502110058
replace SiteName ="Kobi Dispensary" if SiteID==	502110059
replace SiteName ="Durum PHC" if SiteID==	502110060
replace SiteName ="Yalwan Kunlun Health Clinic" if SiteID==	502110061
replace SiteName ="Kundum Dispensary" if SiteID==	502110062
replace SiteName ="Dumin Zungur Dispensary" if SiteID==	502110063
replace SiteName ="Gubi Dispensary" if SiteID==	502110064
replace SiteName ="Balanshi PHC" if SiteID==	502110065
replace SiteName ="Benu Health Centre" if SiteID==	502110066
replace SiteName ="Kagere Maternity" if SiteID==	502110067
replace SiteName ="Bamanu Maternity" if SiteID==	502110068
replace SiteName ="Kagere Dispensary" if SiteID==	502110069
replace SiteName ="Bishi Dispensary" if SiteID==	502110070
replace SiteName ="Mararraban /L Katagum Health Clinic" if SiteID==	502110071
replace SiteName ="L/Katagum CHC" if SiteID==	502110072
replace SiteName ="Jamda" if SiteID==	502110073
replace SiteName ="Gangu" if SiteID==	502110074
replace SiteName ="L/Kitagum" if SiteID==	502110075
replace SiteName ="Under 5 clinic" if SiteID==	502110076
replace SiteName ="Family Planning Clinic" if SiteID==	502110077
replace SiteName ="Rimin Jalum Dispensary" if SiteID==	502110078
replace SiteName ="Miri PHC" if SiteID==	502110079
replace SiteName ="W/ Dada Maternal & Child Health Clinic" if SiteID==	502110080
replace SiteName ="Buzaye Dispensary" if SiteID==	502110081
replace SiteName ="Dungal Dispensary" if SiteID==	502110082
replace SiteName ="Rijiyan Dispensary" if SiteID==	502110083
replace SiteName ="Juwara Maternity" if SiteID==	502110084
replace SiteName ="Munsal Maternity" if SiteID==	502110085
replace SiteName ="Mun Dispensary" if SiteID==	502110086
replace SiteName ="Gamawa Dispensary" if SiteID==	502110087
replace SiteName ="Gwambe Dispensary" if SiteID==	502110088
replace SiteName ="Yola Doka Dispensary" if SiteID==	502110089
replace SiteName ="Tirwun Maternal & Child Health Clinic" if SiteID==	502110090
replace SiteName ="Ibrahim Bako Health Centre" if SiteID==	502110091
replace SiteName ="Habli Dispensary" if SiteID==	502110092
replace SiteName ="Luda Maternity" if SiteID==	502110093
replace SiteName ="Luda Dispensary" if SiteID==	502110094
replace SiteName ="Lekka Dispensary" if SiteID==	502110095
replace SiteName ="Palla Dispensary" if SiteID==	502110096
replace SiteName ="Hammadad Dispensary" if SiteID==	502110097
replace SiteName ="Zungur PHC" if SiteID==	502110098
replace SiteName ="Kusada Dispensary" if SiteID==	502110099
replace SiteName ="Sabon Garin Garkuwa Dispensary" if SiteID==	502110100
replace SiteName ="Giraka Dispensary" if SiteID==	502110101
replace SiteName ="Gungu Dispensary" if SiteID==	502110102
replace SiteName ="Datsang HC" if SiteID==	503110001
replace SiteName ="Bar HC" if SiteID==	503110002
replace SiteName ="Gen: Hospital " if SiteID==	503210003
replace SiteName ="Bogoro Maternal & Child Health Clinic " if SiteID==	503110004
replace SiteName ="Ginzum HC" if SiteID==	503110005
replace SiteName ="PHC BOI" if SiteID==	503110006
replace SiteName ="Danshem Yelwa" if SiteID==	503110007
replace SiteName ="COCIN Clinic BOI" if SiteID==	503120008
replace SiteName ="Tongrate Health Clinic" if SiteID==	503120009
replace SiteName ="Bazanshi HC" if SiteID==	503110010
replace SiteName ="Dutsen Lawan HC" if SiteID==	503110011
replace SiteName ="Ungwan Rimi HC" if SiteID==	503110012
replace SiteName ="Gambar HC" if SiteID==	503110013
replace SiteName ="Dambar HC" if SiteID==	503110014
replace SiteName ="Ungwan Gyada HC" if SiteID==	503110015
replace SiteName ="Gobbiya MPCH" if SiteID==	503110016
replace SiteName ="Gyara HC" if SiteID==	503110017
replace SiteName ="Lusa Maternal and Child Health Clinic" if SiteID==	503110018
replace SiteName ="Dunga HC" if SiteID==	503110019
replace SiteName ="Bonga HC" if SiteID==	503110020
replace SiteName ="Mwari MCH" if SiteID==	503110021
replace SiteName ="Lafiyan-Sara  Maternal & Child Health Clinic" if SiteID==	503110022
replace SiteName ="Dalanga HC" if SiteID==	503110023
replace SiteName ="Mwari PMSS Clinic" if SiteID==	503120024
replace SiteName ="Tadnum Maternal & Child Health Clinic" if SiteID==	503110025
replace SiteName ="Banram HC" if SiteID==	503110026
replace SiteName ="Dagauda PHC" if SiteID==	504110001
replace SiteName ="Dambam Maternity" if SiteID==	504110002
replace SiteName ="Dambam Dispensary" if SiteID==	504110003
replace SiteName ="Gen. Hosp. Dambam" if SiteID==	504210004
replace SiteName ="Birniwa Dispensary" if SiteID==	504110005
replace SiteName ="Fagam Dispensary" if SiteID==	504110006
replace SiteName ="Fagarau Dispensary" if SiteID==	504110007
replace SiteName ="Gaina Dispensary" if SiteID==	504110008
replace SiteName ="Luchambi Dispensary" if SiteID==	504110009
replace SiteName ="Chadi Dispensary" if SiteID==	504110010
replace SiteName ="Wahu Dispensary" if SiteID==	504110011
replace SiteName ="Garuza Dispensary" if SiteID==	504110012
replace SiteName ="Gurbana Dispensary" if SiteID==	504110013
replace SiteName ="Jalam PHC" if SiteID==	504110014
replace SiteName ="Dorawa Dispensary" if SiteID==	504110015
replace SiteName ="G/Jarma" if SiteID==	504110016
replace SiteName ="K/Shinge" if SiteID==	504110017
replace SiteName ="Badakoshi Dispensary" if SiteID==	504110018
replace SiteName ="G/Sura Dispensary" if SiteID==	504110019
replace SiteName ="Janda Dispensary" if SiteID==	504110020
replace SiteName ="Tale Dispensary" if SiteID==	504110021
replace SiteName ="Minchika Dispensary" if SiteID==	504110022
replace SiteName ="Madawa Dispensary" if SiteID==	504110023
replace SiteName ="Durwari Dispensary" if SiteID==	504110024
replace SiteName ="Muzuwa Dispensary" if SiteID==	504110025
replace SiteName ="Yayari Dispensary" if SiteID==	504110026
replace SiteName ="Gwaramawa Dispensary" if SiteID==	504110027
replace SiteName ="Yame Dispensary" if SiteID==	504110028
replace SiteName ="Malatin Dispensary" if SiteID==	504110029
replace SiteName ="Yanda Dispensary" if SiteID==	504110030
replace SiteName ="Lailai Dispensary" if SiteID==	504110031
replace SiteName ="G/Jalo Dispensary" if SiteID==	504110032
replace SiteName ="Lubai Dispensary" if SiteID==	504110033
replace SiteName ="Yayari Dispensary" if SiteID==	504110034
replace SiteName ="Ngaima Dispensary" if SiteID==	504110035
replace SiteName ="Biniyu Dispensary" if SiteID==	504110036
replace SiteName ="Taiyu Dispensary" if SiteID==	504110037
replace SiteName ="General Hospital Darazo" if SiteID==	505210001
replace SiteName ="Under five Clinic" if SiteID==	505110002
replace SiteName ="Sabu Maternity" if SiteID==	505110003
replace SiteName ="Zobo Maternity" if SiteID==	505110004
replace SiteName ="Lemari Maternity" if SiteID==	505110005
replace SiteName ="Tauya Maternity Health Centre" if SiteID==	505110006
replace SiteName ="Darazo Health Centre" if SiteID==	505110007
replace SiteName ="S/G/Papa Health Centre" if SiteID==	505110008
replace SiteName ="Sade Health Centre" if SiteID==	505110009
replace SiteName ="Duwo Health Centre" if SiteID==	505110010
replace SiteName ="Yalwal Health Centre" if SiteID==	505110011
replace SiteName ="Yautare Health Centre" if SiteID==	505110012
replace SiteName ="Tsamiya Maternity Clinic" if SiteID==	505110013
replace SiteName ="Darazo Med. Clinic" if SiteID==	505120014
replace SiteName ="Nasiha Med. Center" if SiteID==	505120015
replace SiteName ="Kanya Dispensary" if SiteID==	505110016
replace SiteName ="Gabarin Health Centre" if SiteID==	505110017
replace SiteName ="Kili Dispensary" if SiteID==	505110018
replace SiteName ="Jimin Dispensary" if SiteID==	505110019
replace SiteName ="Gangulawai Dispensary" if SiteID==	505110020
replace SiteName ="Bula Dispensary" if SiteID==	505110021
replace SiteName ="Gabchiyari Health Centre" if SiteID==	505110022
replace SiteName ="Konkiyal Health Centre" if SiteID==	505110023
replace SiteName ="Lago Health Centre" if SiteID==	505110024
replace SiteName ="Kari Health Centre" if SiteID==	505110025
replace SiteName ="Diggiri Dispensary" if SiteID==	505110026
replace SiteName ="Lanzai Health Centre" if SiteID==	505110027
replace SiteName ="Lamba Dispensary" if SiteID==	505110028
replace SiteName ="Kaugama Dispensary" if SiteID==	505110029
replace SiteName ="S/G/Lanzai" if SiteID==	505110030
replace SiteName ="Papa MPHC" if SiteID==	505110031
replace SiteName ="Garin Abare Health Centre" if SiteID==	505110032
replace SiteName ="Wahu Health Centre" if SiteID==	505110033
replace SiteName ="Lagon Wahu Dispensary" if SiteID==	505110034
replace SiteName ="Indabu Dispensary" if SiteID==	505110035
replace SiteName ="Kawuri Dispensary" if SiteID==	505110036
replace SiteName ="Gakulan Audi Dispensary" if SiteID==	505110037
replace SiteName ="Wuro Dole Dispensary" if SiteID==	505110038
replace SiteName ="Makafiya Dispensary" if SiteID==	505110039
replace SiteName ="Aliya Dispensary" if SiteID==	505110040
replace SiteName ="Nahutan Sade Dispensary" if SiteID==	505110041
replace SiteName ="Zandam Dispensary" if SiteID==	505110042
replace SiteName ="Yunbunga Dispensary" if SiteID==	505110043
replace SiteName ="Dalagobe Dispensary" if SiteID==	505110044
replace SiteName ="Zoro Dispensary" if SiteID==	505110045
replace SiteName ="Nahuta Darazo" if SiteID==	505110046
replace SiteName ="Shadarki Dispensary" if SiteID==	505110047
replace SiteName ="Dayi Dispensary" if SiteID==	505110048
replace SiteName ="Kuka Biyu Dispensary" if SiteID==	505110049
replace SiteName ="Jiro Dispensary" if SiteID==	505110050
replace SiteName ="Gerin Lesa Dispensary" if SiteID==	505110051
replace SiteName ="S/G/Yautare Dispensary" if SiteID==	505110052
replace SiteName ="Dambiji Dispensary" if SiteID==	505110053
replace SiteName ="Bagel Dispensary" if SiteID==	506110001
replace SiteName ="Bajar Health Clinic" if SiteID==	506110002
replace SiteName ="Lirr Maternity" if SiteID==	506110003
replace SiteName ="Baraza PHC" if SiteID==	506110004
replace SiteName ="Gala Health Clinic" if SiteID==	506110005
replace SiteName ="Bandas Dispensary" if SiteID==	506110006
replace SiteName ="Gamki Dispensary" if SiteID==	506110007
replace SiteName ="Dass General Hospital" if SiteID==	506210008
replace SiteName ="Dabardak Maternity" if SiteID==	506110009
replace SiteName ="ECWA Health Clinic" if SiteID==	506120010
replace SiteName ="Town Maternity" if SiteID==	506110011
replace SiteName ="Dass Town Dispensary" if SiteID==	506110012
replace SiteName ="Shalgwantar Dispensary" if SiteID==	506110013
replace SiteName ="Bashi Mat/Clinic" if SiteID==	506110014
replace SiteName ="Bangin Maternity" if SiteID==	506110015
replace SiteName ="Nahuta Dispensary" if SiteID==	506110016
replace SiteName ="Garam Dispensary" if SiteID==	506110017
replace SiteName ="Gajiwal Dispensary" if SiteID==	506110018
replace SiteName ="Pegin Doka Dispensary" if SiteID==	506110019
replace SiteName ="Butur Dispensary" if SiteID==	506110020
replace SiteName ="Yelwan Bashi Dispensary" if SiteID==	506110021
replace SiteName ="Badel Maternity" if SiteID==	506110022
replace SiteName ="Dott Maternity" if SiteID==	506110023
replace SiteName ="Durr Mat/PHC" if SiteID==	506110024
replace SiteName ="Lukshi Maternity" if SiteID==	506110025
replace SiteName ="Bazali PHC" if SiteID==	506110026
replace SiteName ="Jalbang Dispensary" if SiteID==	506110027
replace SiteName ="Dumba Dispensary" if SiteID==	506110028
replace SiteName ="G/Dutse Dispensary" if SiteID==	506110029
replace SiteName ="Wandi Maternity" if SiteID==	506110030
replace SiteName ="Gwaltukurwa Dispensary" if SiteID==	506110031
replace SiteName ="Zumbul Maternity" if SiteID==	506110032
replace SiteName ="S/G/Zumbul Dispensary" if SiteID==	506110033
replace SiteName ="Zunbul Danri" if SiteID==	506110034
replace SiteName ="Alagarno maternity" if SiteID==	507110001
replace SiteName ="Alagarno dispensary" if SiteID==	507110002
replace SiteName ="Sabon garin dispensary" if SiteID==	507110003
replace SiteName ="Gadiya modern health centre" if SiteID==	507110004
replace SiteName ="Gadiya dispensary" if SiteID==	507110005
replace SiteName ="General Hospital  Gamawa" if SiteID==	507210006
replace SiteName ="Gamawa maternity clinic" if SiteID==	507110007
replace SiteName ="Gamawa maternity" if SiteID==	507110008
replace SiteName ="Gololo modl health clinic" if SiteID==	507110009
replace SiteName ="Gololo Dispensary" if SiteID==	507110010
replace SiteName ="Garin J Saleh Dispensary" if SiteID==	507110011
replace SiteName ="Karba dispensary" if SiteID==	507110012
replace SiteName ="Bundujara dispensary" if SiteID==	507110013
replace SiteName ="Gatattara dispensary" if SiteID==	507110014
replace SiteName ="Kaisawa dispensary" if SiteID==	507110015
replace SiteName ="Kafiromi maternity" if SiteID==	507110016
replace SiteName ="Kafiromi dispensary" if SiteID==	507110017
replace SiteName ="Supa dispensary" if SiteID==	507110018
replace SiteName ="Kore dispensary" if SiteID==	507110019
replace SiteName ="Adabda dispensary" if SiteID==	507110020
replace SiteName ="Gangawa dispensary" if SiteID==	507110021
replace SiteName ="Kubdiya maternity" if SiteID==	507110022
replace SiteName ="Kubdiya dispensary" if SiteID==	507110023
replace SiteName ="Marana dispensary" if SiteID==	507110024
replace SiteName ="G/mallam dispensary" if SiteID==	507110025
replace SiteName ="Raga maternity" if SiteID==	507110026
replace SiteName ="Raga dispensary" if SiteID==	507110027
replace SiteName ="Bakori dispensary" if SiteID==	507110028
replace SiteName ="Gayawa dispensary" if SiteID==	507110029
replace SiteName ="Aido dispensary" if SiteID==	507110030
replace SiteName ="Buraburi dispensary" if SiteID==	507110031
replace SiteName ="Taranka dispensary" if SiteID==	507110032
replace SiteName ="Buraburi dispensary" if SiteID==	507110033
replace SiteName ="Tarsawa maternity" if SiteID==	507110034
replace SiteName ="Tarsawa dispensary" if SiteID==	507110035
replace SiteName ="Tumbi dispensary clinic" if SiteID==	507110036
replace SiteName ="Bullana dispensary clinic" if SiteID==	507110037
replace SiteName ="Kidikadi dispensary clinic" if SiteID==	507110038
replace SiteName ="Tumbi dispensary clinic" if SiteID==	507110039
replace SiteName ="Bullana dispensary clinic" if SiteID==	507110040
replace SiteName ="Kadikadi dispensary clinic" if SiteID==	507110041
replace SiteName ="Wabu maternity clinic" if SiteID==	507110042
replace SiteName ="Wabu dispensary clinic" if SiteID==	507110043
replace SiteName ="Yada dispensary clinic" if SiteID==	507110044
replace SiteName ="Kesa dispensary clinic" if SiteID==	507110045
replace SiteName ="Duwaru dispensary clinic" if SiteID==	507110046
replace SiteName ="Udubo maternity clinic" if SiteID==	507110047
replace SiteName ="Ubudo maternity clinic" if SiteID==	507110048
replace SiteName ="Ubudo dispensary clinic" if SiteID==	507110049
replace SiteName ="Gwarbatu dispensary clinic" if SiteID==	507110050
replace SiteName ="Udubo dispensary clinic" if SiteID==	507110051
replace SiteName ="Zindiwa Maternity" if SiteID==	507110052
replace SiteName ="Zindiwa Dispensary" if SiteID==	507110053
replace SiteName ="Garin Kure Dispensary" if SiteID==	507110054
replace SiteName ="Nabayi maternity" if SiteID==	508110001
replace SiteName ="Baya health post" if SiteID==	508110002
replace SiteName ="Manga dispensary" if SiteID==	508110003
replace SiteName ="Nabayi dispensary" if SiteID==	508110004
replace SiteName ="Marbin dispensary" if SiteID==	508110005
replace SiteName ="Yanda Dispensary" if SiteID==	508110006
replace SiteName ="Soro PHC" if SiteID==	508110007
replace SiteName ="Hameed Health Clinic" if SiteID==	508120008
replace SiteName ="Soro Nursing Home" if SiteID==	508120009
replace SiteName ="Gangura MATERNITY" if SiteID==	508110010
replace SiteName ="Gangura DISPENSARY" if SiteID==	508110011
replace SiteName ="Buri-buri dispensary" if SiteID==	508110012
replace SiteName ="Gabi DISPENSARY" if SiteID==	508110013
replace SiteName ="Kediya DISPENSARY" if SiteID==	508110014
replace SiteName ="Danduwo maternity" if SiteID==	508110015
replace SiteName ="Danduwo dispensary" if SiteID==	508110016
replace SiteName ="UNG YAMMA Health clinic" if SiteID==	508110017
replace SiteName ="L/liman dispensary" if SiteID==	508110018
replace SiteName ="Tafazuwa dispensary" if SiteID==	508110019
replace SiteName ="Ringim dispensary" if SiteID==	508110020
replace SiteName ="General Hospital Kafin Madaiki" if SiteID==	508210021
replace SiteName ="S/kariya maternity" if SiteID==	508110022
replace SiteName ="H/tafi maternity " if SiteID==	508110023
replace SiteName ="Wushi H Post" if SiteID==	508110024
replace SiteName ="Mararraba Health Post" if SiteID==	508110025
replace SiteName ="Kariya dispensary" if SiteID==	508110026
replace SiteName ="S/kariya dispensary" if SiteID==	508110027
replace SiteName ="Y/gada dispensary" if SiteID==	508110028
replace SiteName ="Zida dispensary" if SiteID==	508110029
replace SiteName ="H/tafi dispensary" if SiteID==	508110030
replace SiteName ="G/kawari maternity" if SiteID==	508110031
replace SiteName ="Maizuma dispensary" if SiteID==	508110032
replace SiteName ="T/tabo dispensary" if SiteID==	508110033
replace SiteName ="Bunga dispensary" if SiteID==	508110034
replace SiteName ="Kubi maternity" if SiteID==	508110035
replace SiteName ="Kubi dispensary" if SiteID==	508110036
replace SiteName ="Shila dispensary" if SiteID==	508110037
replace SiteName ="Damaguza dispensary" if SiteID==	508110038
replace SiteName ="Duma dispensary" if SiteID==	508110039
replace SiteName ="Zalanga MATERNITY" if SiteID==	508110040
replace SiteName ="Zalanga DISPENSARY" if SiteID==	508110041
replace SiteName ="Dirya DISPENSARY" if SiteID==	508110042
replace SiteName ="Wailo DISPENSARY" if SiteID==	508110043
replace SiteName ="Yaga DISPENSARY" if SiteID==	508110044
replace SiteName ="Miya health clinic" if SiteID==	508110045
replace SiteName ="Hameed Health Clinic" if SiteID==	508120046
replace SiteName ="Miya MPHC" if SiteID==	508110047
replace SiteName ="Zara maternity" if SiteID==	508110048
replace SiteName ="Burku maternity" if SiteID==	508110049
replace SiteName ="Zara dispensary" if SiteID==	508110050
replace SiteName ="Tsagu dispensary" if SiteID==	508110051
replace SiteName ="K/wudufa dispensary" if SiteID==	508110052
replace SiteName ="Lulai dispensary" if SiteID==	508110053
replace SiteName ="Gameru dispensary" if SiteID==	508110054
replace SiteName ="Dabe maternity" if SiteID==	508110055
replace SiteName ="Gidan waya maternity" if SiteID==	508110056
replace SiteName ="Dabe dispensary" if SiteID==	508110057
replace SiteName ="Gidan waya dispensary" if SiteID==	508110058
replace SiteName ="Nassarawa maternity" if SiteID==	508110059
replace SiteName ="Siyi dispensary" if SiteID==	508110060
replace SiteName ="Loyi dispensary" if SiteID==	508110061
replace SiteName ="Buzim dispensary" if SiteID==	508110062
replace SiteName ="Lafiyari dispensary" if SiteID==	508110063
replace SiteName ="Yali maternity" if SiteID==	508110064
replace SiteName ="Firo maternity" if SiteID==	508110065
replace SiteName ="Sakarumbu Health Post" if SiteID==	508110066
replace SiteName ="Digawan Maigari Health Post" if SiteID==	508110067
replace SiteName ="Dumun dispensary" if SiteID==	508110068
replace SiteName ="Yuli dispensary" if SiteID==	508110069
replace SiteName ="Badaromo dispensary" if SiteID==	508110070
replace SiteName ="Abunari Maternity" if SiteID==	509110001
replace SiteName ="Abunari Dispensary" if SiteID==	509110002
replace SiteName ="Mailamalari Dispensary" if SiteID==	509110003
replace SiteName ="Chinkani Dispensary" if SiteID==	509110004
replace SiteName ="Jarmawo Dispensary" if SiteID==	509110005
replace SiteName ="Dogiwa Dispensary" if SiteID==	509110006
replace SiteName ="Takwaye Dispensary" if SiteID==	509110007
replace SiteName ="Gulbun Dispensary" if SiteID==	509110008
replace SiteName ="Faguji Maternity" if SiteID==	509110009
replace SiteName ="Faguji Dispensary" if SiteID==	509110010
replace SiteName ="Giade General Hospital" if SiteID==	509210011
replace SiteName ="Giade Maternity" if SiteID==	509110012
replace SiteName ="Giade Dispensary" if SiteID==	509110013
replace SiteName ="Namu Clinic & Maternity" if SiteID==	509120014
replace SiteName ="Yandore Maternity" if SiteID==	509110015
replace SiteName ="Zindiri Dispensary" if SiteID==	509110016
replace SiteName ="Yandore Dispensary" if SiteID==	509110017
replace SiteName ="Kafin Hardo Dispensary" if SiteID==	509110018
replace SiteName ="Isawa PHC" if SiteID==	509110019
replace SiteName ="Ganduha Dispensary" if SiteID==	509110020
replace SiteName ="Jawo Dispensary" if SiteID==	509110021
replace SiteName ="Yarimari Dispensary" if SiteID==	509110022
replace SiteName ="Jugugu Dispensary" if SiteID==	509110023
replace SiteName ="Kurba Maternity" if SiteID==	509110024
replace SiteName ="Kurba Dispensary" if SiteID==	509110025
replace SiteName ="Kayakaya Dispensary" if SiteID==	509110026
replace SiteName ="Sabon Sara Dispensary" if SiteID==	509110027
replace SiteName ="Bombiyo Dispensary" if SiteID==	509110028
replace SiteName ="Uzum Dispensary" if SiteID==	509110029
replace SiteName ="Jahuri Dispensary" if SiteID==	509110030
replace SiteName ="Korawa Dispensary" if SiteID==	509110031
replace SiteName ="Zabi Model PHC" if SiteID==	509110032
replace SiteName ="Kimari Dispensary" if SiteID==	509110033
replace SiteName ="Rumbuna Dispensary" if SiteID==	509110034
replace SiteName ="Zirami Dispensary" if SiteID==	509110035
replace SiteName ="Magarya Dispensary" if SiteID==	509110036
replace SiteName ="Laila Dispensary" if SiteID==	509110037
replace SiteName ="Jarmawa Dispensary" if SiteID==	509110038
replace SiteName ="G/Kwari Health Post" if SiteID==	510110001
replace SiteName ="Abdallawa Dispensary" if SiteID==	510110002
replace SiteName ="Garin Dole Health Post" if SiteID==	510110003
replace SiteName ="Duhuwa " if SiteID==	510110004
replace SiteName ="Bambal Dispensary" if SiteID==	510110005
replace SiteName ="G/Ganji Maternity" if SiteID==	510110006
replace SiteName ="Yarayi Health post" if SiteID==	510110007
replace SiteName ="Buzawa Health Post" if SiteID==	510110008
replace SiteName ="G/Ganji Dispensary" if SiteID==	510110009
replace SiteName ="Babuguchi Dispensary" if SiteID==	510110010
replace SiteName ="Gadau Maternity" if SiteID==	510110011
replace SiteName ="Walai Dispensary" if SiteID==	510110012
replace SiteName ="Gululu Health Post" if SiteID==	510110013
replace SiteName ="Gamsha Dispensary" if SiteID==	510110014
replace SiteName ="Gayara Dispensary" if SiteID==	510110015
replace SiteName ="Kofata Health Post" if SiteID==	510110016
replace SiteName ="Fango Health Post" if SiteID==	510110017
replace SiteName ="Gwarai Dispensary" if SiteID==	510110018
replace SiteName ="General Hospital" if SiteID==	510210019
replace SiteName ="Itas Town Maternity" if SiteID==	510110020
replace SiteName ="Itas Town Dispensary" if SiteID==	510110021
replace SiteName ="Surfe Health Post" if SiteID==	510110022
replace SiteName ="Kana Deri Health Post" if SiteID==	510110023
replace SiteName ="Kashuri Dispensary" if SiteID==	510110024
replace SiteName ="Lizai Dipensary" if SiteID==	510110025
replace SiteName ="Magarya P.H.C" if SiteID==	510110026
replace SiteName ="Majiya Health Post" if SiteID==	510110027
replace SiteName ="Mashema Maternity" if SiteID==	510110028
replace SiteName ="Momari Health Post" if SiteID==	510110029
replace SiteName ="Melamdige Dispenary" if SiteID==	510110030
replace SiteName ="Atafowa Maternity" if SiteID==	510110031
replace SiteName ="Zubuki Health Post" if SiteID==	510110032
replace SiteName ="Gulmo Health Post" if SiteID==	510110033
replace SiteName ="Sharifari Health Post" if SiteID==	510110034
replace SiteName ="Atafowa Dispensary" if SiteID==	510110035
replace SiteName ="Dogon Jeji Health Clinic" if SiteID==	511110001
replace SiteName ="Mabai Maternity" if SiteID==	511110002
replace SiteName ="Sabon Kafi Dispensary" if SiteID==	511110003
replace SiteName ="Marmaniji Dispensary" if SiteID==	511110004
replace SiteName ="Arawa Dispensary" if SiteID==	511110005
replace SiteName ="Gongo Dispensary" if SiteID==	511110006
replace SiteName ="Gilar Dispensary" if SiteID==	511110007
replace SiteName ="Galdimari Health Clinic" if SiteID==	511110008
replace SiteName ="Baburti Dispensary" if SiteID==	511110009
replace SiteName ="Beddorgel Dispensary" if SiteID==	511110010
replace SiteName ="Sharaba Dispensary" if SiteID==	511110011
replace SiteName ="Hanafari MPHC" if SiteID==	511110012
replace SiteName ="Gudu Dispensary" if SiteID==	511110013
replace SiteName ="Kunjeri Dispensary" if SiteID==	511110014
replace SiteName ="Town Maternity" if SiteID==	511110015
replace SiteName ="Yahaya Clinic & Mat." if SiteID==	511120016
replace SiteName ="Jama’are Health Clinic" if SiteID==	511120017
replace SiteName ="Government Health Office" if SiteID==	511210018
replace SiteName ="Jurara Maternity" if SiteID==	511110019
replace SiteName ="Jurara Dispensary" if SiteID==	511110020
replace SiteName ="Garin Babani Dispensary" if SiteID==	511110021
replace SiteName ="Fetere Dispensary" if SiteID==	511110022
replace SiteName ="Lariye Dispensary" if SiteID==	511110023
replace SiteName ="Kamaku Dispensary" if SiteID==	511110024
replace SiteName ="Yan'gamai Dispensary" if SiteID==	511110025
replace SiteName ="Yola Dispensary" if SiteID==	511110026
replace SiteName ="Jobbori Dispensary" if SiteID==	511110027
replace SiteName ="Bidir Maternity" if SiteID==	512110001
replace SiteName ="Bidir Dispensary" if SiteID==	512110002
replace SiteName ="Bulkachuwa Mat/PHC" if SiteID==	512110003
replace SiteName ="Busuri Dispensary" if SiteID==	512110004
replace SiteName ="Buskuri Maternity" if SiteID==	512110005
replace SiteName ="Buskuri Dispensary" if SiteID==	512110006
replace SiteName ="Gambaki Dispensary" if SiteID==	512110007
replace SiteName ="Adamoyel Dispensary" if SiteID==	512110008
replace SiteName ="Chinade PHC" if SiteID==	512110009
replace SiteName ="Chinade Maternity" if SiteID==	512110010
replace SiteName ="Badderi" if SiteID==	512110011
replace SiteName ="Dagaro" if SiteID==	512110012
replace SiteName ="Maderi" if SiteID==	512110013
replace SiteName ="Gangai Maternity" if SiteID==	512110014
replace SiteName ="Gangai Dispensary" if SiteID==	512110015
replace SiteName ="Zindi Dispensary" if SiteID==	512110016
replace SiteName ="Dagayari Dispensary" if SiteID==	512110017
replace SiteName ="General Hospital Azare" if SiteID==	512210018
replace SiteName ="Makarahuta Maternity" if SiteID==	512110019
replace SiteName ="Urban Maternity" if SiteID==	512110020
replace SiteName ="Katsalle Dispensary" if SiteID==	512110021
replace SiteName ="Madachi Dispensary" if SiteID==	512110022
replace SiteName ="Masaku Dispensary" if SiteID==	512110023
replace SiteName ="Madangala Dispensary" if SiteID==	512110024
replace SiteName ="Kazunu Dispensary" if SiteID==	512110025
replace SiteName ="Chara Chara Dispensary" if SiteID==	512110026
replace SiteName ="Madara Health Centre" if SiteID==	512110027
replace SiteName ="Madara Maternity" if SiteID==	512110028
replace SiteName ="Madara Dispensary" if SiteID==	512110029
replace SiteName ="Lariski Dispensary" if SiteID==	512110030
replace SiteName ="Jumberi Dispensary" if SiteID==	512110031
replace SiteName ="Garin Kauli Dispensary" if SiteID==	512110032
replace SiteName ="Matsango Maternity" if SiteID==	512110033
replace SiteName ="Fed. Medical centre Azare" if SiteID==	512310034
replace SiteName ="Jidy Surgical Center" if SiteID==	512120035
replace SiteName ="Jama’are Clinic Azare" if SiteID==	512120036
replace SiteName ="Shifa’a Med. Clinic" if SiteID==	512120037
replace SiteName ="Amana Med. Clinic" if SiteID==	512120038
replace SiteName ="Maini’ima Consult. Clinic" if SiteID==	512120039
replace SiteName ="Gwasamai MPHC" if SiteID==	512110040
replace SiteName ="Ragwam Maternity" if SiteID==	512110041
replace SiteName ="Ragwam Dispensary" if SiteID==	512110042
replace SiteName ="Town Maternity" if SiteID==	512110043
replace SiteName ="Yayu MPHC" if SiteID==	512110044
replace SiteName ="Kafin Margai Maternity" if SiteID==	513110001
replace SiteName ="Dembori Maternity" if SiteID==	513110002
replace SiteName ="Badara Health Clinic" if SiteID==	513110003
replace SiteName ="Kalajanga matermity" if SiteID==	513110004
replace SiteName ="Balankanawa maternity" if SiteID==	513110005
replace SiteName ="Ribangarmu maternity" if SiteID==	513110006
replace SiteName ="Guyaba Health Clinic" if SiteID==	513110007
replace SiteName ="Kafin-iya Health Clinic" if SiteID==	513110008
replace SiteName ="Kwagal maternity" if SiteID==	513110009
replace SiteName ="Kaloma maternity" if SiteID==	513110010
replace SiteName ="Sharfuri maternity" if SiteID==	513110011
replace SiteName ="Lomi  maternity" if SiteID==	513110012
replace SiteName ="Shongo maternity" if SiteID==	513110013
replace SiteName ="Tubule Health Clinic" if SiteID==	513110014
replace SiteName ="Tashan Turmi Maternity" if SiteID==	513110015
replace SiteName ="Bani Maternity" if SiteID==	513110016
replace SiteName ="Bara Health Centre" if SiteID==	513110017
replace SiteName ="Beni Health Center" if SiteID==	513110018
replace SiteName ="Garin Sale Maimaciji HC" if SiteID==	513110019
replace SiteName ="Boli Maternity" if SiteID==	513110020
replace SiteName ="Dewu health center" if SiteID==	513110021
replace SiteName ="Golo Maternity" if SiteID==	513110022
replace SiteName ="Kirfi General Hospital" if SiteID==	513210023
replace SiteName ="School Clinic GESKA" if SiteID==	513110024
replace SiteName ="Lariski Health Clinic" if SiteID==	513110025
replace SiteName ="Shongo Health Clinic" if SiteID==	513110026
replace SiteName ="Kafin Sarkin Yaki HC" if SiteID==	513110027
replace SiteName ="Wanka Health Clinic" if SiteID==	513110028
replace SiteName ="Baba dispensary" if SiteID==	513110029
replace SiteName ="Kumbi dispensary" if SiteID==	513110030
replace SiteName ="Balankanawa dispensary" if SiteID==	513110031
replace SiteName ="Sharaba dispensary" if SiteID==	513110032
replace SiteName ="Rugar-jalo dispensary" if SiteID==	513110033
replace SiteName ="Gula dispensary" if SiteID==	513110034
replace SiteName ="Kirfi-sama dispensary" if SiteID==	513110035
replace SiteName ="Garin muazu dispensary" if SiteID==	513110036
replace SiteName ="Kadolli dispensary" if SiteID==	513110037
replace SiteName ="Bure dispensary" if SiteID==	513110038
replace SiteName ="Taure dispensary" if SiteID==	513110039
replace SiteName ="Zongoma dispensary" if SiteID==	513110040
replace SiteName ="Feltum Dispensary" if SiteID==	513110041
replace SiteName ="Kirfi Town Maternity" if SiteID==	513110042
replace SiteName ="Mainari PHC" if SiteID==	514110001
replace SiteName ="Ajili Dispensary" if SiteID==	514110002
replace SiteName ="Zindi Dispensary" if SiteID==	514110003
replace SiteName ="Dunkin Kasuwa Dispensary" if SiteID==	514110004
replace SiteName ="Tumfure Dispensary" if SiteID==	514110005
replace SiteName ="Zindi Maternity" if SiteID==	514110006
replace SiteName ="Akuyam Maternity" if SiteID==	514110007
replace SiteName ="Akuyam Dispensary" if SiteID==	514110008
replace SiteName ="Madakiri Maternity" if SiteID==	514110009
replace SiteName ="Shalon Maternity" if SiteID==	514110010
replace SiteName ="Beti Dispensary" if SiteID==	514110011
replace SiteName ="Koftara Dispensary" if SiteID==	514110012
replace SiteName ="Nylebajam Dispensary" if SiteID==	514110013
replace SiteName ="Jarmari Dispensary" if SiteID==	514110014
replace SiteName ="Shelon Dispensary" if SiteID==	514110015
replace SiteName ="Madakiri Dispensary" if SiteID==	514110016
replace SiteName ="Dunkurami Dispensary" if SiteID==	514110017
replace SiteName ="Gainan Hausa Maternity" if SiteID==	514110018
replace SiteName ="Gugulin Dispensary" if SiteID==	514110019
replace SiteName ="Balen Hausa Dispensary" if SiteID==	514110020
replace SiteName ="Gainan Fulani Dispensary" if SiteID==	514110021
replace SiteName ="Diggeri Dispensary" if SiteID==	514110022
replace SiteName ="Gwaram PHC" if SiteID==	514110023
replace SiteName ="Barmo Dispensary" if SiteID==	514110024
replace SiteName ="Farin Ruwa Dispensary" if SiteID==	514110025
replace SiteName ="Kafin Bubari Dispensary" if SiteID==	514110026
replace SiteName ="Gwaram Dispensary" if SiteID==	514110027
replace SiteName ="Hardawa Maternity" if SiteID==	514110028
replace SiteName ="Hardawa Dispensary" if SiteID==	514110029
replace SiteName ="Jarkasa Dispensary" if SiteID==	514110030
replace SiteName ="Jabdo Dispensary" if SiteID==	514110031
replace SiteName ="Hausari Dispensary" if SiteID==	514110032
replace SiteName ="Kafin Suleh Dispensary" if SiteID==	514110033
replace SiteName ="General Hospital Misau" if SiteID==	514210034
replace SiteName ="North Dispensary" if SiteID==	514110035
replace SiteName ="Misau Town Maternity" if SiteID==	514110036
replace SiteName ="Bangarati Dispensary" if SiteID==	514110037
replace SiteName ="Dabsi Dispensary" if SiteID==	514110038
replace SiteName ="Chabai Dispensary" if SiteID==	514110039
replace SiteName ="Central Dispensary" if SiteID==	514110040
replace SiteName ="Sarma Dispensary" if SiteID==	514110041
replace SiteName ="Kafin Zaka Dispensary" if SiteID==	514110042
replace SiteName ="Yelwa Sarman Dispensary" if SiteID==	514110043
replace SiteName ="Sirko Dispensary" if SiteID==	514110044
replace SiteName ="Ngoyinga Dispensary" if SiteID==	514110045
replace SiteName ="Waliya Dispensary" if SiteID==	514110046
replace SiteName ="Dabji Dispensary" if SiteID==	514110047
replace SiteName ="Dallari Dispensary" if SiteID==	514110048
replace SiteName ="Jabalya Dispensary" if SiteID==	514110049
replace SiteName ="Zadawa Maternity" if SiteID==	514110050
replace SiteName ="Zadawa Dispensary" if SiteID==	514110051
replace SiteName ="Nammare Dispensary" if SiteID==	514110052
replace SiteName ="General Hospital Burra" if SiteID==	515210001
replace SiteName ="Tsangaya Muel Health HC" if SiteID==	515110002
replace SiteName ="Ari Health Clinic" if SiteID==	515110003
replace SiteName ="Masussuka Health Clinic" if SiteID==	515110004
replace SiteName ="Kafin Lemo Dispensary" if SiteID==	515110005
replace SiteName ="Shuwaki Dispensary" if SiteID==	515110006
replace SiteName ="Aguwar Maji Dispensary" if SiteID==	515110007
replace SiteName ="T/Jarkoya Dispensary" if SiteID==	515110008
replace SiteName ="Deru Dispensary" if SiteID==	515110009
replace SiteName ="Balma Maternity" if SiteID==	515110010
replace SiteName ="Nasaru Model P.H.C. Centre" if SiteID==	515110011
replace SiteName ="Iyayi Dispensary" if SiteID==	515110012
replace SiteName ="Kauyen Kayel Dispensary" if SiteID==	515110013
replace SiteName ="Ruwan Kanki Dispensary" if SiteID==	515110014
replace SiteName ="Nasaru Dispensary" if SiteID==	515110015
replace SiteName ="Zazika Dispensary" if SiteID==	515110016
replace SiteName ="Gidan Baki Dispensary" if SiteID==	515110017
replace SiteName ="Balma Dispensary" if SiteID==	515110018
replace SiteName ="Gadarmaiwa Health Clinic" if SiteID==	515120019
replace SiteName ="Nasaru Health Clinic" if SiteID==	515120020
replace SiteName ="Ningi General Hospital Ningi" if SiteID==	515210021
replace SiteName ="Ningi Town Maternity" if SiteID==	515110022
replace SiteName ="Magami Dispensary" if SiteID==	515110023
replace SiteName ="Kajala Dispensary" if SiteID==	515110024
replace SiteName ="Ningi Town Dispensary" if SiteID==	515110025
replace SiteName ="Burra Dispensary" if SiteID==	515110026
replace SiteName ="Ningi Clinic & Mat" if SiteID==	515120027
replace SiteName ="Danbaba Clinic & Mat" if SiteID==	515120028
replace SiteName ="Yadagungume Model  HC" if SiteID==	515110029
replace SiteName ="Bashe Maternity" if SiteID==	515110030
replace SiteName ="Ung. Madaki Dispensary" if SiteID==	515110031
replace SiteName ="Dabarbaga Dispensary" if SiteID==	515110032
replace SiteName ="Diwa Dispensary" if SiteID==	515110033
replace SiteName ="Ringya Dispensary" if SiteID==	515110034
replace SiteName ="Yadagungume Dispensary" if SiteID==	515110035
replace SiteName ="Kwangi Dispensary" if SiteID==	515110036
replace SiteName ="Bashe Dispensary" if SiteID==	515110037
replace SiteName ="Gadar Maiwa Maternity" if SiteID==	515110038
replace SiteName ="Kwalangwadi Maternity" if SiteID==	515110039
replace SiteName ="Katsinawa Health Clinic" if SiteID==	515110040
replace SiteName ="Gwam Health Clinic" if SiteID==	515110041
replace SiteName ="Rumbu Dispensary" if SiteID==	515110042
replace SiteName ="Tuwashi Dispensary" if SiteID==	515110043
replace SiteName ="Tashar Majee Dispensary" if SiteID==	515110044
replace SiteName ="Gadar Maiwa Dispensary" if SiteID==	515110045
replace SiteName ="Zakara Dispensary" if SiteID==	515110046
replace SiteName ="Kafin Zaki Dispensary" if SiteID==	515110047
replace SiteName ="Dingis Dispensary" if SiteID==	515110048
replace SiteName ="Jimi Maternity" if SiteID==	515110049
replace SiteName ="Kurmi Maternity" if SiteID==	515110050
replace SiteName ="Batu Health Clinic" if SiteID==	515110051
replace SiteName ="Tabula Dispensary" if SiteID==	515110052
replace SiteName ="Rafin Ciyawa Dispensary" if SiteID==	515110053
replace SiteName ="Dogon Ruwa Dispensary" if SiteID==	515110054
replace SiteName ="Kurim Dispensary" if SiteID==	515110055
replace SiteName ="Dana Dispensary" if SiteID==	515110056
replace SiteName ="Ganji Dispensary" if SiteID==	515110057
replace SiteName ="Jimi Dispensary" if SiteID==	515110058
replace SiteName ="Andubun maternity" if SiteID==	516110001
replace SiteName ="Andubun dispensary" if SiteID==	516110002
replace SiteName ="Isore dispensary" if SiteID==	516110003
replace SiteName ="Bangire dispensary" if SiteID==	516110004
replace SiteName ="Dago dispensary" if SiteID==	516110005
replace SiteName ="Jahn dispensary" if SiteID==	516110006
replace SiteName ="Beli maternity" if SiteID==	516110007
replace SiteName ="Beli dispensary" if SiteID==	516110008
replace SiteName ="Bukul dispensary" if SiteID==	516110009
replace SiteName ="Baliam dispensary" if SiteID==	516110010
replace SiteName ="Dango dispensary" if SiteID==	516110011
replace SiteName ="Rimi dispensary" if SiteID==	516110012
replace SiteName ="Disina PHC" if SiteID==	516110013
replace SiteName ="Disina dispensary" if SiteID==	516110014
replace SiteName ="Gurmaw dispensary" if SiteID==	516110015
replace SiteName ="Adamani dispensary" if SiteID==	516110016
replace SiteName ="Sawi dispensary" if SiteID==	516110017
replace SiteName ="Foggo mat/PHC" if SiteID==	516110018
replace SiteName ="Nahuce maternity" if SiteID==	516110019
replace SiteName ="Zigan dispensary" if SiteID==	516110020
replace SiteName ="Gargidiba dispensary" if SiteID==	516110021
replace SiteName ="Ganuwa dispensary" if SiteID==	516110022
replace SiteName ="Bono dispensary" if SiteID==	516110023
replace SiteName ="Kilbori dispensary" if SiteID==	516110024
replace SiteName ="Kargo dispensary" if SiteID==	516110025
replace SiteName ="Jama'a dispensary" if SiteID==	516110026
replace SiteName ="Sambumal dispensary" if SiteID==	516110027
replace SiteName ="Katabuwa dispensary" if SiteID==	516110028
replace SiteName ="Kafin gara dispensary" if SiteID==	516110029
replace SiteName ="Shira dispensary" if SiteID==	516110030
replace SiteName ="Eldewo dispensary" if SiteID==	516110031
replace SiteName ="Tsafi maternity" if SiteID==	516110032
replace SiteName ="Tsafi dispensary" if SiteID==	516110033
replace SiteName ="Ligada dispensary" if SiteID==	516110034
replace SiteName ="Zawabari dispensary" if SiteID==	516110035
replace SiteName ="Sorodo maternity" if SiteID==	516110036
replace SiteName ="Tumfafi dispensary" if SiteID==	516110037
replace SiteName ="Gazan tumfafi dispensary" if SiteID==	516110038
replace SiteName ="Yana General Hospital" if SiteID==	516210039
replace SiteName ="Yana maternity" if SiteID==	516110040
replace SiteName ="Yana health clinic" if SiteID==	516110041
replace SiteName ="Zubo dispensary" if SiteID==	516110042
replace SiteName ="Darajiya dispensary" if SiteID==	516110043
replace SiteName ="Kwanjin dispensary" if SiteID==	516110044
replace SiteName ="Darajiwo dispensary" if SiteID==	516110045
replace SiteName ="Bulan Gawo Maternity" if SiteID==	517110001
replace SiteName ="Bulan Gawo Dispensary" if SiteID==	517110002
replace SiteName ="Jambil Dispensary" if SiteID==	517110003
replace SiteName ="Gital Maternity" if SiteID==	517110004
replace SiteName ="Shall Dispensary" if SiteID==	517110005
replace SiteName ="Gital Dispensary" if SiteID==	517110006
replace SiteName ="Bununu PHC" if SiteID==	517110007
replace SiteName ="Bununu Maternity" if SiteID==	517110008
replace SiteName ="Bar Maternity" if SiteID==	517110009
replace SiteName ="Bar Dispensary" if SiteID==	517110010
replace SiteName ="Lim Dispensary" if SiteID==	517110011
replace SiteName ="Bamja Dipensary" if SiteID==	517110012
replace SiteName ="Dajin Maternity" if SiteID==	517110013
replace SiteName ="Katsinawa Maternity" if SiteID==	517110014
replace SiteName ="Dajin Dispensary" if SiteID==	517110015
replace SiteName ="Katsinawa Dispensary" if SiteID==	517110016
replace SiteName ="Dull PHC" if SiteID==	517110017
replace SiteName ="Burga Maternity" if SiteID==	517110018
replace SiteName ="Wurno Health Clinic" if SiteID==	517110019
replace SiteName ="Kardam Maternity" if SiteID==	517110020
replace SiteName ="Kundum Maternity" if SiteID==	517110021
replace SiteName ="Kardam Dispensary" if SiteID==	517110022
replace SiteName ="Kundum Dispensary" if SiteID==	517110023
replace SiteName ="Boto General Hospital" if SiteID==	517210024
replace SiteName ="Boto Dispensary" if SiteID==	517110025
replace SiteName ="Maijuju Dispensary" if SiteID==	517110026
replace SiteName ="Zari Dispensary" if SiteID==	517110027
replace SiteName ="Darahji Dispensary" if SiteID==	517110028
replace SiteName ="Lere PHC" if SiteID==	517110029
replace SiteName ="Sigdin Shehu Dispensary" if SiteID==	517110030
replace SiteName ="Ngebiji Dispensary" if SiteID==	517110031
replace SiteName ="Sara Dispensary" if SiteID==	517110032
replace SiteName ="Martin Daji Dispensary" if SiteID==	517110033
replace SiteName ="Mball Maternity" if SiteID==	517110034
replace SiteName ="S/Gida Health Centre" if SiteID==	517110035
replace SiteName ="Wurogeje Dispensary" if SiteID==	517110036
replace SiteName ="Mball Dispensary" if SiteID==	517110037
replace SiteName ="Yola Nora Dispensary" if SiteID==	517110038
replace SiteName ="Burwat Dispensary" if SiteID==	517110039
replace SiteName ="Yola Nora Maternity" if SiteID==	517110040
replace SiteName ="Tapshin MPHC" if SiteID==	517110041
replace SiteName ="Duklin Bauchi Maternity" if SiteID==	517110042
replace SiteName ="Gambar Health Clinic" if SiteID==	517110043
replace SiteName ="Zwall Maternity" if SiteID==	517110044
replace SiteName ="Gori Maternity" if SiteID==	517110045
replace SiteName ="Gwashe Dispensary" if SiteID==	517110046
replace SiteName ="Zwall Dispensary" if SiteID==	517110047
replace SiteName ="Gori Dispensary" if SiteID==	517110048
replace SiteName ="Tafawa-Balewa General Hospital" if SiteID==	517210049
replace SiteName ="T/Balewa Maternity" if SiteID==	517110050
replace SiteName ="Tafore Health Clinic" if SiteID==	517110051
replace SiteName ="GGSS Health Clinic" if SiteID==	517110052
replace SiteName ="Jama'a maternity" if SiteID==	518110001
replace SiteName ="Tashin dirimi maternity" if SiteID==	518110002
replace SiteName ="Jama'a dispensary" if SiteID==	518110003
replace SiteName ="Wom dispensary" if SiteID==	518110004
replace SiteName ="Tashan dirimi dispensary" if SiteID==	518110005
replace SiteName ="Mainasara Nursing Home" if SiteID==	518120006
replace SiteName ="Kowa Health Clinic" if SiteID==	518120007
replace SiteName ="Amarks Health Clinic" if SiteID==	518120008
replace SiteName ="Rinji Health Clinic" if SiteID==	518120009
replace SiteName ="Lame maternity" if SiteID==	518110010
replace SiteName ="Jonge maternity" if SiteID==	518110011
replace SiteName ="Saminakan gwa maternity" if SiteID==	518110012
replace SiteName ="Lame dispensary" if SiteID==	518110013
replace SiteName ="Gukka dispensary" if SiteID==	518110014
replace SiteName ="Shau dispensary" if SiteID==	518110015
replace SiteName ="Jonge dispensary" if SiteID==	518110016
replace SiteName ="Fatira dispensary" if SiteID==	518110017
replace SiteName ="Rimin zayam maternity" if SiteID==	518110018
replace SiteName ="Rimin zdyan dispensary" if SiteID==	518110019
replace SiteName ="Taka bunde dispensary" if SiteID==	518110020
replace SiteName ="Sutumi dispensary" if SiteID==	518110021
replace SiteName ="Rinjin gingin dispensary" if SiteID==	518110022
replace SiteName ="Mara dispensary" if SiteID==	518110023
replace SiteName ="Zakshi maternity" if SiteID==	518110024
replace SiteName ="Gandi maternity" if SiteID==	518110025
replace SiteName ="Kufai maternity" if SiteID==	518110026
replace SiteName ="Zakshi dispensary" if SiteID==	518110027
replace SiteName ="Sabon garin zakshi dispensary" if SiteID==	518110028
replace SiteName ="Zari maku dispensary" if SiteID==	518110029
replace SiteName ="Kufai dispensary" if SiteID==	518110030
replace SiteName ="Palama dispensary" if SiteID==	518110031
replace SiteName ="Nasarawa samanja" if SiteID==	518110032
replace SiteName ="Matawai" if SiteID==	518110033
replace SiteName ="Rahama" if SiteID==	518110034
replace SiteName ="Makana Dispensary" if SiteID==	518110035
replace SiteName ="Gana" if SiteID==	518110036
replace SiteName ="Wurno" if SiteID==	518110037
replace SiteName ="Samanja" if SiteID==	518110038
replace SiteName ="Rauta maternity" if SiteID==	518110039
replace SiteName ="Nahuta maternity" if SiteID==	518110040
replace SiteName ="Felun abba maternity" if SiteID==	518110041
replace SiteName ="Gasuro maternity" if SiteID==	518110042
replace SiteName ="Rauta dispensary" if SiteID==	518110043
replace SiteName ="Nahuta dispensary" if SiteID==	518110044
replace SiteName ="Runtu dispensary" if SiteID==	518110045
replace SiteName ="Felun abba dispensary" if SiteID==	518110046
replace SiteName ="Geji dispensary" if SiteID==	518110047
replace SiteName ="Natsira dispensary" if SiteID==	518110048
replace SiteName ="Bakin ruwa dispensary" if SiteID==	518110049
replace SiteName ="Biciti dispensary" if SiteID==	518110050
replace SiteName ="Rinji maternity" if SiteID==	518110051
replace SiteName ="Rinji dispensary" if SiteID==	518110052
replace SiteName ="Danmaigoro Hospital" if SiteID==	518120053
replace SiteName ="Khadija M. Health Clinic" if SiteID==	518120054
replace SiteName ="Salarma dispensary" if SiteID==	518110055
replace SiteName ="Ganye maternity" if SiteID==	518110056
replace SiteName ="Gwalfada maternity" if SiteID==	518110057
replace SiteName ="Tudun wada ribina dispensary" if SiteID==	518110058
replace SiteName ="Ganye dispensary" if SiteID==	518110059
replace SiteName ="Rishi PHC" if SiteID==	518110060
replace SiteName ="Wundi maternity" if SiteID==	518110061
replace SiteName ="Dababe dispensary" if SiteID==	518110062
replace SiteName ="Zukku dispensary" if SiteID==	518110063
replace SiteName ="Tulu maternity" if SiteID==	518110064
replace SiteName ="Guraka Dispensary" if SiteID==	518110065
replace SiteName ="Tulu dispensary" if SiteID==	518110066
replace SiteName ="Sabongari dispensary" if SiteID==	518110067
replace SiteName ="Dinga dispensary" if SiteID==	518110068
replace SiteName ="Burku dispensary" if SiteID==	518110069
replace SiteName ="Makana Dispensary" if SiteID==	518110070
replace SiteName ="Tilde maternity" if SiteID==	518110071
replace SiteName ="Tilde dispensary" if SiteID==	518110072
replace SiteName ="Sabon garin dispensary" if SiteID==	518110073
replace SiteName ="Tumu dispensary" if SiteID==	518110074
replace SiteName ="Bujiyel dispensary" if SiteID==	518110075
replace SiteName ="Lafiya Nursing Home" if SiteID==	518120076
replace SiteName ="Taimako Nursing Home" if SiteID==	518120077
replace SiteName ="Rahusa Clinic & Mat." if SiteID==	518120078
replace SiteName ="Kowa Health Clinic & Mat." if SiteID==	518120079
replace SiteName ="Nasabi Clinic & Mat" if SiteID==	518120080
replace SiteName ="Toro General Hospital" if SiteID==	518210081
replace SiteName ="Toro maternity" if SiteID==	518110082
replace SiteName ="Magama maternity" if SiteID==	518110083
replace SiteName ="Polchi Maternity" if SiteID==	518110084
replace SiteName ="Toro dispensary" if SiteID==	518110085
replace SiteName ="Loro dispensary" if SiteID==	518110086
replace SiteName ="Kere Dispensary" if SiteID==	518110087
replace SiteName ="Buka tulai Maternity" if SiteID==	518110088
replace SiteName ="Buka tulai dispensary" if SiteID==	518110089
replace SiteName ="Balorabe dispensary" if SiteID==	518110090
replace SiteName ="Polchi dispensary" if SiteID==	518110091
replace SiteName ="Tashan mai allo" if SiteID==	518110092
replace SiteName ="Magamu cari dispensary" if SiteID==	518110093
replace SiteName ="Tashan maitolare dispensary" if SiteID==	518110094
replace SiteName ="Kochey dispensary el" if SiteID==	518110095
replace SiteName ="Yakanaji dispensary" if SiteID==	518110096
replace SiteName ="Rinjin murur dispensary" if SiteID==	518110097
replace SiteName ="Gumau maternity" if SiteID==	518110098
replace SiteName ="Gumau dispensary" if SiteID==	518110099
replace SiteName ="Pingel dispensary" if SiteID==	518110100
replace SiteName ="Ririwan dalma dispensary" if SiteID==	518110101
replace SiteName ="Didin dispensary" if SiteID==	518110102
replace SiteName ="Gel joule maternity" if SiteID==	518110103
replace SiteName ="Badikko dispensary" if SiteID==	518110104
replace SiteName ="Bakin Kogi dispensary" if SiteID==	518110105
replace SiteName ="Primary health centre" if SiteID==	518110106
replace SiteName ="Moho Maternity" if SiteID==	518110107
replace SiteName ="Chidiya Dispensary" if SiteID==	518110108
replace SiteName ="Rinjin Dispensary" if SiteID==	518110109
replace SiteName ="Moho Dispensary" if SiteID==	518110110
replace SiteName ="Zaranda maternity" if SiteID==	518110111
replace SiteName ="Makera maternity" if SiteID==	518110112
replace SiteName ="Nabordo maternity" if SiteID==	518110113
replace SiteName ="Yuga maternity" if SiteID==	518110114
replace SiteName ="Sabon gari health clinic" if SiteID==	518110115
replace SiteName ="Zaranda dispensary" if SiteID==	518110116
replace SiteName ="Kwambo dispensary" if SiteID==	518110117
replace SiteName ="Makera dispensary" if SiteID==	518110118
replace SiteName ="Galda dispensary" if SiteID==	518110119
replace SiteName ="Nabordo dispensary" if SiteID==	518110120
replace SiteName ="Mundu dispensary" if SiteID==	518110121
replace SiteName ="Yuga dispensary" if SiteID==	518110122
replace SiteName ="Kafin dilimi dispensary" if SiteID==	518110123
replace SiteName ="Takandan Giwa dispensary" if SiteID==	518110124
replace SiteName ="Baima Maternity" if SiteID==	519110001
replace SiteName ="K/Bubuna Maternity" if SiteID==	519110002
replace SiteName ="Baima Dispensary" if SiteID==	519110003
replace SiteName ="Lan-Lan Dispensary" if SiteID==	519110004
replace SiteName ="Gawa" if SiteID==	519110005
replace SiteName ="Dagu Maternity" if SiteID==	519110006
replace SiteName ="Badi-Yeso Maternity" if SiteID==	519110007
replace SiteName ="Bunga Maternity" if SiteID==	519110008
replace SiteName ="Dagu Dispensary" if SiteID==	519110009
replace SiteName ="Badi-Yeso Dispensary" if SiteID==	519110010
replace SiteName ="Bunga Dispensary" if SiteID==	519110011
replace SiteName ="K/Mada" if SiteID==	519110012
replace SiteName ="Dallaji Dispensary" if SiteID==	519110013
replace SiteName ="Marasuwa Dispensary" if SiteID==	519110014
replace SiteName ="Wuha Dispensary" if SiteID==	519110015
replace SiteName ="K/Kanawa Maternity" if SiteID==	519110016
replace SiteName ="K/Kanawa Dispensary" if SiteID==	519110017
replace SiteName ="Gabanga Maternity" if SiteID==	519110018
replace SiteName ="Gabnga Health Post" if SiteID==	519110019
replace SiteName ="Bura Dispensary" if SiteID==	519110020
replace SiteName ="Town Dispensary" if SiteID==	519110021
replace SiteName ="Warji General Hospital" if SiteID==	519210022
replace SiteName ="Danina Dispensary" if SiteID==	519110023
replace SiteName ="Jawa Maternity" if SiteID==	519110024
replace SiteName ="Tuya Dispensary" if SiteID==	519110025
replace SiteName ="ECWA Clinic" if SiteID==	519120026
replace SiteName ="Kankare Maternity" if SiteID==	519110027
replace SiteName ="Aru Dispensary" if SiteID==	519110028
replace SiteName ="Rumba Model Primary Health Care Center" if SiteID==	519110029
replace SiteName ="Muda Babba Maternity" if SiteID==	519110030
replace SiteName ="T/wada Maternity" if SiteID==	519110031
replace SiteName ="Gidam Mada Dispensary" if SiteID==	519110032
replace SiteName ="T/Wada Dispensary" if SiteID==	519110033
replace SiteName ="Yayari Dispensary" if SiteID==	519110034
replace SiteName ="Ganji Maternity" if SiteID==	519110035
replace SiteName ="Haya" if SiteID==	519110036
replace SiteName ="Wando Dispensary" if SiteID==	519110037
replace SiteName ="Disa Dispensary" if SiteID==	519110038
replace SiteName ="Ingila Maternity" if SiteID==	519110039
replace SiteName ="Zurgwai Maternity" if SiteID==	519110040
replace SiteName ="Bakwi Dispensary" if SiteID==	519110041
replace SiteName ="Alangawari  disp" if SiteID==	520110001
replace SiteName ="Amarmari disp" if SiteID==	520110002
replace SiteName ="Jajeri  disp" if SiteID==	520110003
replace SiteName ="Kameme  disp" if SiteID==	520110004
replace SiteName ="Ariri" if SiteID==	520110005
replace SiteName ="Alganari" if SiteID==	520110006
replace SiteName ="Ariri" if SiteID==	520110007
replace SiteName ="Bursali  maternity" if SiteID==	520110008
replace SiteName ="Bursali disp" if SiteID==	520110009
replace SiteName ="Jindu disp" if SiteID==	520110010
replace SiteName ="Tikirje disp" if SiteID==	520110011
replace SiteName ="Masaje disp" if SiteID==	520110012
replace SiteName ="Chibiyayi" if SiteID==	520110013
replace SiteName ="Chibiyayi" if SiteID==	520110014
replace SiteName ="Sandigalau" if SiteID==	520110015
replace SiteName ="M/ gumai" if SiteID==	520110016
replace SiteName ="Bakari" if SiteID==	520110017
replace SiteName ="Gadai maternity" if SiteID==	520110018
replace SiteName ="Gadai  disp" if SiteID==	520110019
replace SiteName ="Maikore disp" if SiteID==	520110020
replace SiteName ="Kirchibuwa" if SiteID==	520110021
replace SiteName ="Futti disp" if SiteID==	520110022
replace SiteName ="Gumai mat" if SiteID==	520110023
replace SiteName ="Gumai disp" if SiteID==	520110024
replace SiteName ="Sabon sara disp " if SiteID==	520110025
replace SiteName ="Galdimari disp" if SiteID==	520110026
replace SiteName ="Birkicha disp" if SiteID==	520110027
replace SiteName ="Aishi disp" if SiteID==	520110028
replace SiteName ="K/larabawa" if SiteID==	520110029
replace SiteName ="K/larabawa" if SiteID==	520110030
replace SiteName ="General Hospital Katagum" if SiteID==	520210031
replace SiteName ="Katagum" if SiteID==	520110032
replace SiteName ="Lodiya" if SiteID==	520110033
replace SiteName ="Lodiya" if SiteID==	520110034
replace SiteName ="Ladari" if SiteID==	520110035
replace SiteName ="Bagam" if SiteID==	520110036
replace SiteName ="Madufa" if SiteID==	520110037
replace SiteName ="Madufa" if SiteID==	520110038
replace SiteName ="Chacharam" if SiteID==	520110039
replace SiteName ="Gauya" if SiteID==	520110040
replace SiteName ="Mainako" if SiteID==	520110041
replace SiteName ="Sabakuwa" if SiteID==	520110042
replace SiteName ="Gurka" if SiteID==	520110043
replace SiteName ="Maiwa" if SiteID==	520110044
replace SiteName ="Gurka" if SiteID==	520110045
replace SiteName ="S/ gari" if SiteID==	520110046
replace SiteName ="Kaskiidim" if SiteID==	520110047
replace SiteName ="Makawa" if SiteID==	520110048
replace SiteName ="Makawa" if SiteID==	520110049
replace SiteName ="Gara" if SiteID==	520110050
replace SiteName ="Manawaski" if SiteID==	520110051
replace SiteName ="Barwari" if SiteID==	520110052
replace SiteName ="Murmur" if SiteID==	520110053
replace SiteName ="Sakwa" if SiteID==	520110054
replace SiteName ="Sakwa" if SiteID==	520110055
replace SiteName ="Tarduwa" if SiteID==	520110056
replace SiteName ="Kujjin" if SiteID==	520110057
replace SiteName ="Tashena" if SiteID==	520110058
replace SiteName ="G/gami" if SiteID==	520110059
replace SiteName ="Akko Health clinic" if SiteID==	1601110001
replace SiteName ="Bula Dispensary" if SiteID==	1601110002
replace SiteName ="Bula Maternity Clinic" if SiteID==	1601110003
replace SiteName ="Gamadadi Dispensary" if SiteID==	1601110004
replace SiteName ="Lawanti Dispensary" if SiteID==	1601110005
replace SiteName ="Wurodole Dispensary" if SiteID==	1601110006
replace SiteName ="Zongomari Dispensary" if SiteID==	1601110007
replace SiteName ="Arfa Medical Centre" if SiteID==	1601220008
replace SiteName ="Bogo Maternity Clinic" if SiteID==	1601110009
replace SiteName ="Garko Dispensary" if SiteID==	1601110010
replace SiteName ="Kudulum Dispensary" if SiteID==	1601110011
replace SiteName ="Gaskiya Medical Clinic" if SiteID==	1601120012
replace SiteName ="Ponon Medical Clinic" if SiteID==	1601120013
replace SiteName ="Dikko Clinic" if SiteID==	1601120014
replace SiteName ="Tabra Maternity Clinic" if SiteID==	1601110015
replace SiteName ="Tumpure Dispensary" if SiteID==	1601110016
replace SiteName ="Chilo Dispensary" if SiteID==	1601110017
replace SiteName ="Chilo Maternity Clinic" if SiteID==	1601110018
replace SiteName ="Gujuba Dispensary" if SiteID==	1601110019
replace SiteName ="Kalshingi Dispensary" if SiteID==	1601110020
replace SiteName ="Kalshingi (PHC)" if SiteID==	1601110021
replace SiteName ="Dongol Dispensary" if SiteID==	1601110022
replace SiteName ="Kaltanga Dispensary" if SiteID==	1601110023
replace SiteName ="Kashere Maternity Clinic" if SiteID==	1601110024
replace SiteName ="Kashere Health Centre" if SiteID==	1601110025
replace SiteName ="Kashere General Hospital" if SiteID==	1601210026
replace SiteName ="Mispha Mat Home" if SiteID==	1601120027
replace SiteName ="Kembu Dispensary" if SiteID==	1601110028
replace SiteName ="Kidda Dispensary" if SiteID==	1601110029
replace SiteName ="Kembu Dispensary" if SiteID==	1601110030
replace SiteName ="Panda Maternity Clinic" if SiteID==	1601110031
replace SiteName ="Pandaya Dispensary" if SiteID==	1601110032
replace SiteName ="Tambie/Yolo Disp." if SiteID==	1601110033
replace SiteName ="Amina Mat Home" if SiteID==	1601120034
replace SiteName ="Kumo Health Clinic" if SiteID==	1601120035
replace SiteName ="Salama Health Clinic" if SiteID==	1601120036
replace SiteName ="Kumo Maternity Clinic " if SiteID==	1601110037
replace SiteName ="Kumo Gen. Hospital" if SiteID==	1601210038
replace SiteName ="Kumo Health Clinic" if SiteID==	1601110039
replace SiteName ="Barambu Health Clinic" if SiteID==	1601110040
replace SiteName ="Gwaram Maternity Clinic" if SiteID==	1601110041
replace SiteName ="Kilawa Dispensary" if SiteID==	1601110042
replace SiteName ="Lembi Maternity Clinic" if SiteID==	1601110043
replace SiteName ="Lembi Dispensary" if SiteID==	1601110044
replace SiteName ="Gadawo Dispensary" if SiteID==	1601110045
replace SiteName ="Kobuwa Dispensary" if SiteID==	1601110046
replace SiteName ="Kobuwa Maternity Clinic" if SiteID==	1601110047
replace SiteName ="Garin Rigiya Dispensary" if SiteID==	1601110048
replace SiteName ="Pindiga Health Clinic" if SiteID==	1601110049
replace SiteName ="Lambo Daji Dispensary" if SiteID==	1601110050
replace SiteName ="Pindiga General Hospital" if SiteID==	1601210051
replace SiteName ="Tukulma maternity Clinic" if SiteID==	1601110052
replace SiteName ="Shabbal Dispensary" if SiteID==	1601110053
replace SiteName ="Gokaru Dispensary" if SiteID==	1601110054
replace SiteName ="Badara Dispensary" if SiteID==	1601110055
replace SiteName ="Lariye Dispensary" if SiteID==	1601110056
replace SiteName ="Jauro Tukur Dispensary" if SiteID==	1601110057
replace SiteName ="Badawaire Dispensary" if SiteID==	1601110058
replace SiteName ="Bappah Ibrahim Dispensary" if SiteID==	1601110059
replace SiteName ="Jabba Dispensary" if SiteID==	1601110060
replace SiteName ="Piyau Dispensary" if SiteID==	1601110061
replace SiteName ="Yelwa Dispensary" if SiteID==	1601110062
replace SiteName ="Samkong Health Clinic" if SiteID==	1601120063
replace SiteName ="Sambo Daji Disp." if SiteID==	1601110064
replace SiteName ="Tumu Maternity" if SiteID==	1601110065
replace SiteName ="Zabinkami Dispensary" if SiteID==	1601110066
replace SiteName ="Tumu General Hospital" if SiteID==	1601210067
replace SiteName ="Cham Mat. Clinic" if SiteID==	1602110001
replace SiteName ="Cham Dispensary" if SiteID==	1602110002
replace SiteName ="ECWA DISpensary Cham" if SiteID==	1602120003
replace SiteName ="Salama Mat Clinic" if SiteID==	1602120004
replace SiteName ="Bambam PHC" if SiteID==	1602110005
replace SiteName ="Dr Fosa Med. Clinic" if SiteID==	1602120006
replace SiteName ="Bambam General Hospital" if SiteID==	1602210007
replace SiteName ="Kowa Health Clinic Bambam" if SiteID==	1602120008
replace SiteName ="Degri Dispensary" if SiteID==	1602110009
replace SiteName ="Kore Mat. Clinic" if SiteID==	1602110010
replace SiteName ="Kulani Mat. Clinic" if SiteID==	1602110011
replace SiteName ="Degri Mat. Clinic" if SiteID==	1602110012
replace SiteName ="Putoki Dispensary" if SiteID==	1602110013
replace SiteName ="Sikkam Mat. Clinic" if SiteID==	1602110014
replace SiteName ="Potuki General Hospital" if SiteID==	1602210015
replace SiteName ="ECWA Health Clinic Bambam" if SiteID==	1602120016
replace SiteName ="Dadiya Mat. Clinic" if SiteID==	1602110017
replace SiteName ="Maitunku Mat. Clinic" if SiteID==	1602110018
replace SiteName ="Yelwa Dispensary" if SiteID==	1602110019
replace SiteName ="Bangu Dispensary" if SiteID==	1602110020
replace SiteName ="Bakassi Dispensary" if SiteID==	1602110021
replace SiteName ="Balanga Dispensary" if SiteID==	1602110022
replace SiteName ="Dala waja Dispensary" if SiteID==	1602110023
replace SiteName ="Gelengu Maternity Clinic" if SiteID==	1602110024
replace SiteName ="Gelengu ECWA Mat. Clinic" if SiteID==	1602120025
replace SiteName ="Yolde Mat. Clinic" if SiteID==	1602110026
replace SiteName ="Lakun Mat. Clinic" if SiteID==	1602110027
replace SiteName ="Mona Mat. Clinic" if SiteID==	1602110028
replace SiteName ="Dong Mat. Clinic" if SiteID==	1602110029
replace SiteName ="Talasse Dispensary" if SiteID==	1602110030
replace SiteName ="Talasse PHC" if SiteID==	1602110031
replace SiteName ="Reme Mat. Clinic" if SiteID==	1602110032
replace SiteName ="Talasse General Hospital" if SiteID==	1602210033
replace SiteName ="Gwenti Dispensary" if SiteID==	1602110034
replace SiteName ="Lotani Dispensary" if SiteID==	1602110035
replace SiteName ="Lugwi Dispensary" if SiteID==	1602110036
replace SiteName ="Jessu Dispensary" if SiteID==	1602110037
replace SiteName ="Nyuwar PHC" if SiteID==	1602110038
replace SiteName ="Nyuwar Dispensary" if SiteID==	1602110039
replace SiteName ="Wala Lunguda Disp." if SiteID==	1602110040
replace SiteName ="Kolako Dispensary" if SiteID==	1602110041
replace SiteName ="Rafele Dispensary" if SiteID==	1602110042
replace SiteName ="Wadachi Dispensary" if SiteID==	1602110043
replace SiteName ="Banganje PHC" if SiteID==	1603110001
replace SiteName ="Layafi Health Clinic" if SiteID==	1603110002
replace SiteName ="Lamugu Health Clinic" if SiteID==	1603110003
replace SiteName ="Lawurkardo H/Clinic" if SiteID==	1603110004
replace SiteName ="Lakarai Health Clinic" if SiteID==	1603110005
replace SiteName ="Lawiltiu Health Clinic" if SiteID==	1603110006
replace SiteName ="Pokulji Health Clinic" if SiteID==	1603110007
replace SiteName ="Sabon-layi H/Clinic" if SiteID==	1603110008
replace SiteName ="Kwibah Health Clinic" if SiteID==	1603110009
replace SiteName ="Kekkel Mat. Clinic" if SiteID==	1603110010
replace SiteName ="Pokwagli Health Clinic" if SiteID==	1603110011
replace SiteName ="Lashiga Health Clinic" if SiteID==	1603110012
replace SiteName ="Lapandi-shadde H/Clinic" if SiteID==	1603110013
replace SiteName ="Nita Mat.Clinic" if SiteID==	1603120014
replace SiteName ="Waya Mat. Clinic" if SiteID==	1603120015
replace SiteName ="Sansani Health Clinic" if SiteID==	1603110016
replace SiteName ="Awai Health Clinic" if SiteID==	1603110017
replace SiteName ="Billiri General Hospital" if SiteID==	1603210018
replace SiteName ="ECWA Health Clinic Awai" if SiteID==	1603120019
replace SiteName ="Fakla Health Clinic" if SiteID==	1603110020
replace SiteName ="Kufai Health Clinic" if SiteID==	1603110021
replace SiteName ="Kufai Dispensary" if SiteID==	1603120022
replace SiteName ="ECWA Mat. Clinic Kufai" if SiteID==	1603120023
replace SiteName ="Komta Health Clinic" if SiteID==	1603110024
replace SiteName ="Latuggad Health Clinic" if SiteID==	1603110025
replace SiteName ="Poshiya Health Clinic" if SiteID==	1603110026
replace SiteName ="Ladikwiwa Medical Clinic" if SiteID==	1603120027
replace SiteName ="Yamban Dok Med. Clinic" if SiteID==	1603120028
replace SiteName ="Kalkulum Health Clinic" if SiteID==	1603110029
replace SiteName ="Sikirit Health Clinic" if SiteID==	1603110030
replace SiteName ="Kalindi Health Clinic" if SiteID==	1603110031
replace SiteName ="Lawushi Daji Health Clinic" if SiteID==	1603110032
replace SiteName ="Lasale Health Clinic" if SiteID==	1603110033
replace SiteName ="Ketengereng Health Clinic" if SiteID==	1603110034
replace SiteName ="Amuta Health Clinic" if SiteID==	1603110035
replace SiteName ="Amtawalam Health Clinic" if SiteID==	1603110036
replace SiteName ="Lakelembu H.Clinic" if SiteID==	1603110037
replace SiteName ="Lakukdu Health Clinic" if SiteID==	1603110038
replace SiteName ="Pobawure   H. Clinic" if SiteID==	1603110039
replace SiteName ="Kalmai Health Clinic" if SiteID==	1603110040
replace SiteName ="Catholic Mat. Center Kalmai" if SiteID==	1603120041
replace SiteName ="Ayaba Mat. Clinic" if SiteID==	1603110042
replace SiteName ="Kolokkwannin H. Clinic" if SiteID==	1603110043
replace SiteName ="Kurum Health Clinic" if SiteID==	1603110044
replace SiteName ="Kwiwulang H. Clinic" if SiteID==	1603110045
replace SiteName ="Lasani Health Clinic" if SiteID==	1603110046
replace SiteName ="Patinkude H.Clinic" if SiteID==	1603110047
replace SiteName ="Pandi-kungu H. Clinic" if SiteID==	1603110048
replace SiteName ="Tal Health Clinic" if SiteID==	1603110049
replace SiteName ="Tal Mat. Clinic" if SiteID==	1603110050
replace SiteName ="Ayaba Alheri Mat. Centre" if SiteID==	1603120051
replace SiteName ="ECWA Health Clinic Tal" if SiteID==	1603120052
replace SiteName ="Bassa Health Clinic" if SiteID==	1603110053
replace SiteName ="Kulgul Mat. Clinic" if SiteID==	1603110054
replace SiteName ="Lakalkal Health Clinic" if SiteID==	1603110055
replace SiteName ="Powushi Health Clinic" if SiteID==	1603110056
replace SiteName ="Poyali Health Clinic" if SiteID==	1603110057
replace SiteName ="Tanglang Health Clinic" if SiteID==	1603110058
replace SiteName ="T /kwaya Mat. Clinic" if SiteID==	1603110059
replace SiteName ="Panguru Health Clinic" if SiteID==	1603110060
replace SiteName ="T /Kwaya Health Clinic" if SiteID==	1603120061
replace SiteName ="Todi P H C" if SiteID==	1603110062
replace SiteName ="Shela Health Clinic" if SiteID==	1603110063
replace SiteName ="Popandi Health Clinic" if SiteID==	1603110064
replace SiteName ="Layer    /Lakule Health Clinic" if SiteID==	1603110065
replace SiteName ="ECWA H. Clinic Shela" if SiteID==	1603120066
replace SiteName ="Bawa Maternity Clinic" if SiteID==	1604110001
replace SiteName ="Bawa Dispensary" if SiteID==	1604110002
replace SiteName ="Gare Dispensary" if SiteID==	1604110003
replace SiteName ="Lule/Zero Dispensary" if SiteID==	1604110004
replace SiteName ="Yole Dispensary" if SiteID==	1604110005
replace SiteName ="Gombe-Abba Maternity" if SiteID==	1604110052
replace SiteName ="Hashidu Health Clinic" if SiteID==	1604110006
replace SiteName ="Dokoro Dispensary" if SiteID==	1604110007
replace SiteName ="Dokoro Maternity Clinic" if SiteID==	1604110008
replace SiteName ="Gadum Dispensary" if SiteID==	1604110009
replace SiteName ="Jamari Dispensary" if SiteID==	1604110010
replace SiteName ="Jamari Maternity Clinic" if SiteID==	1604110011
replace SiteName ="Kamba Maternity Clinic" if SiteID==	1604110012
replace SiteName ="Kamba Dispensary" if SiteID==	1604110013
replace SiteName ="Kukudi Dispensary" if SiteID==	1604110014
replace SiteName ="Maru Dispensary" if SiteID==	1604110015
replace SiteName ="Wuro  Bulama Dispensary" if SiteID==	1604110016
replace SiteName ="Wuro Bulama Maternity Clinic" if SiteID==	1604110017
replace SiteName ="Daminya Dispensary" if SiteID==	1604110018
replace SiteName ="Kunde Health Clinic" if SiteID==	1604110019
replace SiteName ="Lafiya Maternity Clinic" if SiteID==	1604110020
replace SiteName ="Lafiya Talle Dispensary" if SiteID==	1604110021
replace SiteName ="Burari Dispensary " if SiteID==	1604110022
replace SiteName ="Duggiri Dispensary" if SiteID==	1604110023
replace SiteName ="Kowagol Dispensary" if SiteID==	1604110024
replace SiteName ="Malala Dispensary" if SiteID==	1604110025
replace SiteName ="Malala N YSC Clinic" if SiteID==	1604110026
replace SiteName ="Mayo Lamido Dispensary" if SiteID==	1604110027
replace SiteName ="Mayo Lamido Materniy" if SiteID==	1604110028
replace SiteName ="Dukku Dispensary" if SiteID==	1604110029
replace SiteName ="Dukku Town Maternity Clinic" if SiteID==	1604110030
replace SiteName ="Garlingo Dispensary" if SiteID==	1604110031
replace SiteName ="Gode Dispensary" if SiteID==	1604110032
replace SiteName ="Jarlum Dispensary" if SiteID==	1604110033
replace SiteName ="Malalayel Dispensary" if SiteID==	1604110034
replace SiteName ="Comprehensive Health Centre" if SiteID==	1604110053
replace SiteName ="Dashi Dispensary" if SiteID==	1604110035
replace SiteName ="Dukku General Hospital" if SiteID==	1604210036
replace SiteName ="Kalam Dispensary" if SiteID==	1604110037
replace SiteName ="Tale Dispensary" if SiteID==	1604110038
replace SiteName ="Wuro Tale Dispensary" if SiteID==	1604110039
replace SiteName ="Wuro Tale Maternity Clinic" if SiteID==	1604110040
replace SiteName ="Bokkiro Dispensary" if SiteID==	1604110041
replace SiteName ="Jombo Dispensary" if SiteID==	1604110042
replace SiteName ="Kumi Dispensary" if SiteID==	1604110043
replace SiteName ="Zagala Dispensary" if SiteID==	1604110044
replace SiteName ="Zange Maternity Clinic" if SiteID==	1604110045
replace SiteName ="Zange Dispensary" if SiteID==	1604110046
replace SiteName ="Wuro Kudu Dispensary" if SiteID==	1604110047
replace SiteName ="Dukkuyel Dispensary" if SiteID==	1604110048
replace SiteName ="Garin Atiku Dispensary" if SiteID==	1604110049
replace SiteName ="Zaune Dispensary" if SiteID==	1604110050
replace SiteName ="Zaune Maternity Clinic" if SiteID==	1604110051
replace SiteName ="Ashaka Maternity Clinic" if SiteID==	1605110001
replace SiteName ="Ashaka Albarka N. Home" if SiteID==	1605120002
replace SiteName ="Ashaka Dispensary" if SiteID==	1605110003
replace SiteName ="Jalingo Maternity Clinic" if SiteID==	1605110004
replace SiteName ="Jalingo Dispensary" if SiteID==	1605110005
replace SiteName ="Magaba Dispensary" if SiteID==	1605110006
replace SiteName ="Mannari Maternity Clinic" if SiteID==	1605110007
replace SiteName ="Abuja Dispensary" if SiteID==	1605110008
replace SiteName ="Bage Maternity Clinic" if SiteID==	1605110009
replace SiteName ="Bage Dispensary" if SiteID==	1605110010
replace SiteName ="Ballabdi Dispensary" if SiteID==	1605110011
replace SiteName ="Bungum Dispensary" if SiteID==	1605110012
replace SiteName ="Kafiwal Dispensary" if SiteID==	1605110013
replace SiteName ="Jungol-Barkano Dispensary" if SiteID==	1605110014
replace SiteName ="Bajoga General Hospital" if SiteID==	1605210015
replace SiteName ="Bajoga Medical Clinic" if SiteID==	1605120016
replace SiteName ="Bajoga Maternity Clinic" if SiteID==	1605110017
replace SiteName ="Bajoga Dispensary" if SiteID==	1605110018
replace SiteName ="Ecwa Clinic Bajoga" if SiteID==	1605120019
replace SiteName ="Sangaru Maternity Clinic" if SiteID==	1605110020
replace SiteName ="Julahi Maternity Clinic" if SiteID==	1605110021
replace SiteName ="Julahi Dispensary" if SiteID==	1605110022
replace SiteName ="Kuka Bakwai Maternity Clinic" if SiteID==	1605110023
replace SiteName ="Kupto Maternity Clinic" if SiteID==	1605110024
replace SiteName ="Kupto Dispensary" if SiteID==	1605110025
replace SiteName ="Jangade Dispensary" if SiteID==	1605110026
replace SiteName ="Bodor Dispensary" if SiteID==	1605110027
replace SiteName ="Tilde Maternity Clinic" if SiteID==	1605110028
replace SiteName ="Tilde Dispensary" if SiteID==	1605110029
replace SiteName ="Tongo Health Clinic" if SiteID==	1605110030
replace SiteName ="Tongo N. Home Clinic" if SiteID==	1605120031
replace SiteName ="Guiwa Maternity Clinic" if SiteID==	1605110032
replace SiteName ="Ngarai Dispensary" if SiteID==	1605110033
replace SiteName ="Ribadu Maternity Clinic" if SiteID==	1605110034
replace SiteName ="Ribadu Dispensary" if SiteID==	1605110035
replace SiteName ="Komi Maternity Clinic" if SiteID==	1605110036
replace SiteName ="Wawa Maternity Clinic" if SiteID==	1605110037
replace SiteName ="Wawa Dispensary" if SiteID==	1605110038
replace SiteName ="Wakkaltu Dispensary" if SiteID==	1605110039
replace SiteName ="Nig. Prison Services Clinic" if SiteID==	1606110001
replace SiteName ="Bimma Medical Clinic" if SiteID==	1606120002
replace SiteName ="Fed.Medical Centre" if SiteID==	1606310003
replace SiteName ="F C E (Tech) Clinic" if SiteID==	1606110004
replace SiteName ="Urban Maternity Clinic" if SiteID==	1606110005
replace SiteName ="Idi Dispensary" if SiteID==	1606110006
replace SiteName ="Royal Eye & Dental Clinic" if SiteID==	1606120007
replace SiteName ="Savannah Clinic" if SiteID==	1606220008
replace SiteName ="Police Clinic" if SiteID==	1606110009
replace SiteName ="N N P C Gombe Depot Clinic" if SiteID==	1606110010
replace SiteName ="Army Barrack Clinic" if SiteID==	1606110011
replace SiteName ="Family Support Prog. Maternity Clinic" if SiteID==	1606110012
replace SiteName ="Bolari Maternity Clinic" if SiteID==	1606110013
replace SiteName ="Govt House Clinic" if SiteID==	1606110014
replace SiteName ="St. Rose Maternity Clinic" if SiteID==	1606120015
replace SiteName ="Arewa Medical Clinic" if SiteID==	1606120016
replace SiteName ="El-Norf Medical Clinic" if SiteID==	1606120017
replace SiteName ="H/Gana Health Clinic" if SiteID==	1606110018
replace SiteName ="Sunnah Hospital Gombe" if SiteID==	1606220019
replace SiteName ="Specialist Hospital Gombe" if SiteID==	1606210020
replace SiteName ="Divine Specialist Eye Clinic" if SiteID==	1606120021
replace SiteName ="Yarma Memorial Hospital" if SiteID==	1606120022
replace SiteName ="Gombe Town Mat Clinic" if SiteID==	1606110023
replace SiteName ="Tuberculosis/Leprosy Clinic" if SiteID==	1606110024
replace SiteName ="Doma Medical Hospital" if SiteID==	1606220025
replace SiteName ="Kumbia - Kumbia Mat. Clinic" if SiteID==	1606110026
replace SiteName ="Nassarawo Maternity Clinic" if SiteID==	1606110027
replace SiteName ="Pantami Health Clinic" if SiteID==	1606110028
replace SiteName ="Pantami Medical Clinic" if SiteID==	1606120029
replace SiteName ="Hamdala Specialist Clinic" if SiteID==	1606120030
replace SiteName ="Salem Medical Clinic" if SiteID==	1606120031
replace SiteName ="Mal. Inna Dispensary" if SiteID==	1606110032
replace SiteName ="Tudun Wada Health Clinic" if SiteID==	1606110033
replace SiteName ="Miyetti Medical Clinic" if SiteID==	1606120034
replace SiteName ="Musaba Medical Clinic" if SiteID==	1606120035
replace SiteName ="Tasma Medical Hospital" if SiteID==	1606120036
replace SiteName ="Metro Consultant Clinic" if SiteID==	1606120037
replace SiteName ="Dogon Ruwa Mat. Clinic" if SiteID==	1607110001
replace SiteName ="Bwara Health Clinic" if SiteID==	1607110002
replace SiteName ="Garin Bako Mat. Clinic" if SiteID==	1607110003
replace SiteName ="Samkong Maternity Clinic" if SiteID==	1607120004
replace SiteName ="S/Layi Maternity Clinic" if SiteID==	1607110005
replace SiteName ="Kije Health Clinic" if SiteID==	1607110006
replace SiteName ="Jalingo Maternity Clinic" if SiteID==	1607110007
replace SiteName ="Lungere Health Clinic" if SiteID==	1607110008
replace SiteName ="Baule Gari Maternity Clinic" if SiteID==	1607110009
replace SiteName ="Bule Health Clinic" if SiteID==	1607110010
replace SiteName ="Kaltin Maternity Clinic" if SiteID==	1607110011
replace SiteName ="Kwang Maternity Clinic" if SiteID==	1607110012
replace SiteName ="Lafiya Baule Mat. Clinic" if SiteID==	1607110013
replace SiteName ="General Hospital Kaltungo" if SiteID==	1607210014
replace SiteName ="Bandara Health Clinic" if SiteID==	1607110015
replace SiteName ="Kale Health Clinic" if SiteID==	1607110016
replace SiteName ="Kaluwa Health Clinic" if SiteID==	1607110017
replace SiteName ="Layiro Papandi Mat. Clinic" if SiteID==	1607110018
replace SiteName ="Layiro Posheren Health Clinic" if SiteID==	1607110019
replace SiteName ="Lakweme Maternity Clinic" if SiteID==	1607110020
replace SiteName ="Poshereng Maternity Clinic" if SiteID==	1607110021
replace SiteName ="Popandi Maternity Clinic" if SiteID==	1607110022
replace SiteName ="Purmai Health Clinic" if SiteID==	1607110023
replace SiteName ="Kaltungo Med. Centre" if SiteID==	1607120024
replace SiteName ="Molding Health Clinic" if SiteID==	1607110025
replace SiteName ="Kaltungo Town Maternity Clinic" if SiteID==	1607110026
replace SiteName ="Kalargo Health Clinic" if SiteID==	1607110027
replace SiteName ="Tantan Nursing Home" if SiteID==	1607120028
replace SiteName ="ECWA Health Clinic" if SiteID==	1607120029
replace SiteName ="Gujuba Maternity Clinic" if SiteID==	1607110030
replace SiteName ="Latarin Health Clinic" if SiteID==	1607110031
replace SiteName ="Lafiya Health Clinic Gujuba" if SiteID==	1607110032
replace SiteName ="Mozo Health Clinic" if SiteID==	1607110033
replace SiteName ="Pattuwana Maternity Clinic" if SiteID==	1607110034
replace SiteName ="Shenge Shenge Health Clinic" if SiteID==	1607110035
replace SiteName ="Bed Bede Health Clinic" if SiteID==	1607110036
replace SiteName ="ECWA Health Clinic Pokwangli" if SiteID==	1607110037
replace SiteName ="Pokwangli Health Clinic" if SiteID==	1607110038
replace SiteName ="Lakidir Health Centre" if SiteID==	1607110039
replace SiteName ="Wili Health Clinic" if SiteID==	1607110040
replace SiteName ="Mai Ture Maternity Clinic" if SiteID==	1607110041
replace SiteName ="Ture Balam Maternity Clinic" if SiteID==	1607110042
replace SiteName ="Ture Okra Health Clinic" if SiteID==	1607120043
replace SiteName ="Ture Okra Clinic" if SiteID==	1607120044
replace SiteName ="Kwen Health Clinic" if SiteID==	1607120045
replace SiteName ="ECWA,H/Clinic Galadima" if SiteID==	1607120046
replace SiteName ="Jauro Audi Health Clinic" if SiteID==	1607110047
replace SiteName ="Bwele Maternity Clinic" if SiteID==	1607110048
replace SiteName ="Bekuntin Health Clinic" if SiteID==	1607110049
replace SiteName ="Kaye Health Clinic" if SiteID==	1607110050
replace SiteName ="Yiri Maternity Clinic" if SiteID==	1607110051
replace SiteName ="Wange Maternity Clinic" if SiteID==	1607110052
replace SiteName ="Yoriyo Health Clinic" if SiteID==	1607110053
replace SiteName ="Chin Chin Health Clinic" if SiteID==	1607110054
replace SiteName ="ECWA Clinic Wange" if SiteID==	1607120055
replace SiteName ="Cottage Hospital, Tula " if SiteID==	1607110056
replace SiteName ="Bojude Maternity Clinic" if SiteID==	1608110001
replace SiteName ="Bojude Dispensary" if SiteID==	1608110002
replace SiteName ="General Hospital Bojude" if SiteID==	1608210003
replace SiteName ="Dukkul Maternity Clinic" if SiteID==	1608110004
replace SiteName ="Dukkul Dispensary" if SiteID==	1608110005
replace SiteName ="Gafara Dispensary" if SiteID==	1608110006
replace SiteName ="Doho Maternity Clinic" if SiteID==	1608110007
replace SiteName ="Doho Dispensary" if SiteID==	1608110008
replace SiteName ="Hamma Dukkuyo Dispensary" if SiteID==	1608110009
replace SiteName ="Jambula Dispensary" if SiteID==	1608110010
replace SiteName ="Hamma Dukkuyo Maternity" if SiteID==	1608110011
replace SiteName ="Wuro Dole Dispensary" if SiteID==	1608110012
replace SiteName ="D/Fulani Maternity Clinic" if SiteID==	1608110013
replace SiteName ="D/Fulani Dispensary" if SiteID==	1608110014
replace SiteName ="Wuro Jabe Dispensary" if SiteID==	1608110015
replace SiteName ="Gadam Maternity Clinic" if SiteID==	1608110016
replace SiteName ="Gadam Dispensary" if SiteID==	1608110017
replace SiteName ="Gwaram Dispensary" if SiteID==	1608110018
replace SiteName ="Mettako Dispensary" if SiteID==	1608110019
replace SiteName ="Tappi Dispensary" if SiteID==	1608110020
replace SiteName ="Allugel Dispensary" if SiteID==	1608110021
replace SiteName ="Jurara Maternity Clinic" if SiteID==	1608110022
replace SiteName ="Jurara Dispensary" if SiteID==	1608110023
replace SiteName ="Abuja Maternity Clinic" if SiteID==	1608110024
replace SiteName ="Bomala Dispensary" if SiteID==	1608110025
replace SiteName ="Komfulata Dispensary" if SiteID==	1608110026
replace SiteName ="Janji Dispensary" if SiteID==	1608110027
replace SiteName ="Shongo Maternity Clinic" if SiteID==	1608110028
replace SiteName ="Jauro Isa Dispensary" if SiteID==	1608110029
replace SiteName ="Gerkwami Maternity Clinic" if SiteID==	1608110030
replace SiteName ="Gerkwami Dispensary" if SiteID==	1608110031
replace SiteName ="Kwami Model Health Centre" if SiteID==	1608110032
replace SiteName ="Kwami Maternity Clinic" if SiteID==	1608110033
replace SiteName ="Kwami Dispensary" if SiteID==	1608110034
replace SiteName ="Titi Dispensary" if SiteID==	1608110035
replace SiteName ="Malleri Maternity Clinic" if SiteID==	1608110036
replace SiteName ="Malleri Dispensary" if SiteID==	1608110037
replace SiteName ="Tinda Dispensary" if SiteID==	1608110038
replace SiteName ="M/Sidi Maternity Clinic" if SiteID==	1608110039
replace SiteName ="Kyari Maternity Clinic" if SiteID==	1608110040
replace SiteName ="M/Sidi Dispensary" if SiteID==	1608110041
replace SiteName ="General Hospital M/Sidi" if SiteID==	1608210042
replace SiteName ="Cottage Hospital Biri" if SiteID==	1609110001
replace SiteName ="B/Bolewa Dispensary" if SiteID==	1609110002
replace SiteName ="B/Bolawa Maternity Clinic" if SiteID==	1609110003
replace SiteName ="B/Bolawa P H C" if SiteID==	1609110004
replace SiteName ="B/Bolawa Health Clinic" if SiteID==	1609110005
replace SiteName ="Sundingo Health Clinic" if SiteID==	1609110006
replace SiteName ="B/Fulani Maternity Clinic" if SiteID==	1609110007
replace SiteName ="B/Fulani Health Clinic" if SiteID==	1609110008
replace SiteName ="B/Fulani Dispensary" if SiteID==	1609110009
replace SiteName ="Kiyayo Dispensary" if SiteID==	1609110010
replace SiteName ="Birin - Fulani PHC" if SiteID==	1609110011
replace SiteName ="Madaki Lamu Dispensary" if SiteID==	1609110012
replace SiteName ="B/Nasarawo Maternity Clinic" if SiteID==	1609110013
replace SiteName ="B/Nasarawo Dispensary" if SiteID==	1609110014
replace SiteName ="Shanganawa Maternity Clinic" if SiteID==	1609110015
replace SiteName ="Wakkaltu Dispensary" if SiteID==	1609110016
replace SiteName ="B/Winde Maternity Clinic" if SiteID==	1609110017
replace SiteName ="B/Winde Dispensary" if SiteID==	1609110018
replace SiteName ="Duba Dispensary" if SiteID==	1609110019
replace SiteName ="Guduku Dispensary" if SiteID==	1609110020
replace SiteName ="Jigawa Maternity Clinic" if SiteID==	1609110021
replace SiteName ="Jigawa Dispensary" if SiteID==	1609110022
replace SiteName ="Dendele Dispensary" if SiteID==	1609110023
replace SiteName ="Jolle Dispensary" if SiteID==	1609210024
replace SiteName ="Nafada General Hospital" if SiteID==	1609110025
replace SiteName ="Nafada PHC" if SiteID==	1609110026
replace SiteName ="Nafada Maternity Clinic" if SiteID==	1609110027
replace SiteName ="Nafada Maternity Clinic" if SiteID==	1609110028
replace SiteName ="Shole Health Clinic" if SiteID==	1609110029
replace SiteName ="Nyalkam Dispensary" if SiteID==	1609110030
replace SiteName ="Nafada Dispensary" if SiteID==	1609110031
replace SiteName ="Munde Dispensary" if SiteID==	1610110001
replace SiteName ="Bagunji Maternity Clinic" if SiteID==	1610110002
replace SiteName ="Galadimari Maternity Clinic" if SiteID==	1610110003
replace SiteName ="Karel Maternity Clinic" if SiteID==	1610110004
replace SiteName ="Labeke Health Clinic" if SiteID==	1610110005
replace SiteName ="Lawishi Health Clinic" if SiteID==	1610110006
replace SiteName ="Boh Model P H C" if SiteID==	1610110007
replace SiteName ="Pokata Health Clinic" if SiteID==	1610110008
replace SiteName ="Burak Maternity Clinic" if SiteID==	1610110009
replace SiteName ="Nyalimi Health Clinic" if SiteID==	1610110010
replace SiteName ="Filiya P H C" if SiteID==	1610110011
replace SiteName ="Pero Maternity Clinic" if SiteID==	1610120012
replace SiteName ="Iliya Nursing Home Filiya" if SiteID==	1610110013
replace SiteName ="Gundale Maternity Clinic" if SiteID==	1610110014
replace SiteName ="Daja Maternity Clinic" if SiteID==	1610110015
replace SiteName ="Labanya Maternity Clinic" if SiteID==	1610110016
replace SiteName ="Lapan Health Clinic" if SiteID==	1610120017
replace SiteName ="Lasanjang Health Clinic" if SiteID==	1610110018
replace SiteName ="Lalaipido Maternity Clinic" if SiteID==	1610110019
replace SiteName ="Latatar Maternity Clinic" if SiteID==	1610110020
replace SiteName ="Amkolan Health Clinic" if SiteID==	1610110021
replace SiteName ="Nawarke Health Clinic Lakanturum" if SiteID==	1610110022
replace SiteName ="Majidadi Health Clinic" if SiteID==	1610110023
replace SiteName ="Keffi HealthClinic" if SiteID==	1610110024
replace SiteName ="Tora Health Clinic" if SiteID==	1610120025
replace SiteName ="Rev.Bitrus H.Memorial Health Clinic" if SiteID==	1610120026
replace SiteName ="Alheri Health Clinic Gwandum" if SiteID==	1610120027
replace SiteName ="UMCH Clinic Gwandum" if SiteID==	1610120028
replace SiteName ="UMCN Rural Health Clinic Filiya" if SiteID==	1610110029
replace SiteName ="Kulishin Maternity Clinic" if SiteID==	1610110030
replace SiteName ="Lashi Koltok Maternity Clinic" if SiteID==	1610110031
replace SiteName ="Kushi Maternity Clinic" if SiteID==	1610110032
replace SiteName ="Kushi Health Clinic" if SiteID==	1610110033
replace SiteName ="LapadintaiMaternity Clinic" if SiteID==	1610110034
replace SiteName ="Deba General Hospital" if SiteID==	1611210001
replace SiteName ="DebaMaternity Clinic" if SiteID==	1611110002
replace SiteName ="Deba Health Clinic" if SiteID==	1611110003
replace SiteName ="Saruje Dispensary" if SiteID==	1611110004
replace SiteName ="Deba Medical Clinic" if SiteID==	1611120005
replace SiteName ="Gwani MaternityClinic" if SiteID==	1611110006
replace SiteName ="Gwani/East Dispensary" if SiteID==	1611110007
replace SiteName ="Gwani West Dispensary" if SiteID==	1611110008
replace SiteName ="Shinga PHC" if SiteID==	1611110009
replace SiteName ="Wade Maternity Clinic" if SiteID==	1611110010
replace SiteName ="Wade Dispensary" if SiteID==	1611110011
replace SiteName ="Colony HealthClinic" if SiteID==	1611110012
replace SiteName ="Dadinkowa Maternity Clinic" if SiteID==	1611110013
replace SiteName ="D/Kowa Convalescent Clinic" if SiteID==	1611120014
replace SiteName ="D/Kowa Health Clinic" if SiteID==	1611110015
replace SiteName ="Garin Bukar Dispensary" if SiteID==	1611110016
replace SiteName ="General Hospital Hina" if SiteID==	1611210017
replace SiteName ="Hina Maternity Clinic" if SiteID==	1611110018
replace SiteName ="Jangargari Dispensary" if SiteID==	1611110019
replace SiteName ="Dasa Maternity Clinic" if SiteID==	1611110020
replace SiteName ="Dasa Dispensary" if SiteID==	1611110021
replace SiteName ="Dando Dispensary" if SiteID==	1611110022
replace SiteName ="Maikafo Maternity Clinic" if SiteID==	1611110023
replace SiteName ="Jigawan Iro Health Clinic" if SiteID==	1611110024
replace SiteName ="Jauro Gotel Dispensary" if SiteID==	1611110025
replace SiteName ="Tsando Dispensary" if SiteID==	1611110026
replace SiteName ="Kurjale Dispensary" if SiteID==	1611110027
replace SiteName ="Kurjale Maternity Clinic" if SiteID==	1611110028
replace SiteName ="Pata Dispensary" if SiteID==	1611110029
replace SiteName ="Dagar Maternity Clinic" if SiteID==	1611110030
replace SiteName ="Dagar Dispensary" if SiteID==	1611110031
replace SiteName ="Jannawo Dispensary" if SiteID==	1611110032
replace SiteName ="Kachallari Dispensary" if SiteID==	1611110033
replace SiteName ="Kachallari Maternity Clinic" if SiteID==	1611110034
replace SiteName ="WajariDispensary" if SiteID==	1611110035
replace SiteName ="Sele Health Clinic" if SiteID==	1611110036
replace SiteName ="Zamfarawa Health Clinic" if SiteID==	1611110037
replace SiteName ="Kuri Maternity Clinic" if SiteID==	1611110038
replace SiteName ="Kuri Cottage Hospital" if SiteID==	1611110039
replace SiteName ="Lano Maternity Clinic" if SiteID==	1611110040
replace SiteName ="Lambam Maternity Clinic" if SiteID==	1611110041
replace SiteName ="Lambam Dispensary" if SiteID==	1611110042
replace SiteName ="Kwadon Maternity clinic" if SiteID==	1611110043
replace SiteName ="Kurba Maternity Clinic" if SiteID==	1611110044
replace SiteName ="Kurba Dispensary " if SiteID==	1611110045
replace SiteName ="Kwadon Dispensary" if SiteID==	1611110046
replace SiteName ="Liji Maternity Clinic" if SiteID==	1611110047
replace SiteName ="Liji Dispensary" if SiteID==	1611110048
replace SiteName ="Nassarawo Dispensary" if SiteID==	1611110049
replace SiteName ="Difa Maternity Clinic" if SiteID==	1611110050
replace SiteName ="Difa Dispensary" if SiteID==	1611110051
replace SiteName ="Lubo Dispensary" if SiteID==	1611110052
replace SiteName ="Lubo Maternity Clinic" if SiteID==	1611110053
replace SiteName ="Kinafa Dispensary" if SiteID==	1611110054
replace SiteName ="Boltongo Dispensary" if SiteID==	1611110055
replace SiteName ="Garin Baraya Maternity Clinic" if SiteID==	1611110056
replace SiteName ="Garin Baraya Dispensary" if SiteID==	1611110057
replace SiteName ="KunnuwalMaternity Clinic" if SiteID==	1611110058
replace SiteName ="Lano Maternity Clinic" if SiteID==	1611110059
replace SiteName ="Nono Dispensary" if SiteID==	1611110060
replace SiteName ="Kwali Dispensary" if SiteID==	1611110061
replace SiteName ="Zambuk General Hospital" if SiteID==	1611210062
replace SiteName ="Zambuk Maternity Clinic" if SiteID==	1611110063
replace SiteName ="Zambuk Dispensary" if SiteID==	1611110064
replace SiteName ="Zambuk Tropical Health Clinic" if SiteID==	1611110065
replace SiteName ="Babura General Hospital" if SiteID==	1702210001
replace SiteName ="Jarmai Health Post" if SiteID==	1702110002
replace SiteName ="Batali Dispensary" if SiteID==	1702110003
replace SiteName ="Dorawa Health Post" if SiteID==	1702110004
replace SiteName ="Dazau Dispensary" if SiteID==	1702110005
replace SiteName ="Garu Primary Health Centre" if SiteID==	1702110006
replace SiteName ="Kyambo Health Post" if SiteID==	1702110007
replace SiteName ="Lamuntani Basic Health Clinic" if SiteID==	1702110008
replace SiteName ="Gasakoli Health Post" if SiteID==	1702110009
replace SiteName ="Tashar D/Kyambo Baisc Health Clinic" if SiteID==	1702110010
replace SiteName ="Insharuwa Health Post" if SiteID==	1702110011
replace SiteName ="Gurjiya Basic Health Clinic" if SiteID==	1702110012
replace SiteName ="Jigawa Babura Primary Health Centre" if SiteID==	1702110013
replace SiteName ="Kanya Health Clinic (Babura)" if SiteID==	1702110014
replace SiteName ="Kuzunzumi Health Post" if SiteID==	1702110015
replace SiteName ="Manga Health Post" if SiteID==	1702110016
replace SiteName ="Masko Dispensary" if SiteID==	1702110017
replace SiteName ="Takwasa Basic Health Clinic" if SiteID==	1702110018
replace SiteName ="Birnin Kudu General Hospital" if SiteID==	1703210001
replace SiteName ="Kudu Clinic" if SiteID==	1703220002
replace SiteName ="Magajin Gari Health Post" if SiteID==	1703110003
replace SiteName ="Birnin Kudu Federal Medical Centre" if SiteID==	1703310004
replace SiteName ="Kantoga Health Post" if SiteID==	1703110005
replace SiteName ="Dumus Health Post" if SiteID==	1703110006
replace SiteName ="Kangire Health Post" if SiteID==	1703110007
replace SiteName ="Kafin Gana Health Post" if SiteID==	1703110008
replace SiteName ="Babaldu Clinic" if SiteID==	1703110009
replace SiteName ="Babaldu Health Post" if SiteID==	1703110010
replace SiteName ="Kiyako Health Post" if SiteID==	1703110011
replace SiteName ="Bamaina Health Clinic" if SiteID==	1703110012
replace SiteName ="Kadangare Basic Health Clinic" if SiteID==	1703110013
replace SiteName ="Lafia Health Post" if SiteID==	1703110014
replace SiteName ="Tukuda Dispensary" if SiteID==	1703110015
replace SiteName ="Dukana Health Post" if SiteID==	1703110016
replace SiteName ="Kwari Dispensary" if SiteID==	1703110017
replace SiteName ="Nafara Health Post" if SiteID==	1703110018
replace SiteName ="Sundimina Health Clinic" if SiteID==	1703110019
replace SiteName ="Kwatai Health Post" if SiteID==	1703110020
replace SiteName ="Kumbura Health Post" if SiteID==	1703110021
replace SiteName ="Badingu Health Post" if SiteID==	1703110022
replace SiteName ="Jiboga Basic Health Clinic" if SiteID==	1703110023
replace SiteName ="Kawo Health Post" if SiteID==	1703110024
replace SiteName ="Unguwar Ya Health Clinic" if SiteID==	1703110025
replace SiteName ="Yarma Health Post" if SiteID==	1703110026
replace SiteName ="Giwa Health Post" if SiteID==	1703110027
replace SiteName ="Guna'an Damau Health Post" if SiteID==	1703110028
replace SiteName ="Jangargari Health Post" if SiteID==	1703110029
replace SiteName ="Samamiya Dispensary" if SiteID==	1703110030
replace SiteName ="Shungurin Health Post" if SiteID==	1703110031
replace SiteName ="Wurno Health Clinic" if SiteID==	1703110032
replace SiteName ="Arobade Health Post" if SiteID==	1703110033
replace SiteName ="Dokoki Health Post" if SiteID==	1703110034
								
replace SiteName ="Iggi Dispensary" if SiteID==	1703110035
replace SiteName ="Yalwan Damai Dispensary" if SiteID==	1703110036
replace SiteName ="Bkd Dangoli Health post" if SiteID==	1703110037
replace SiteName ="Kuka-Inkiwa Health Clinic" if SiteID==	1704110001
replace SiteName ="Birniwa Cottage Hospital" if SiteID==	1704210002
replace SiteName ="Birniwa Tashia Health Post" if SiteID==	1704110003
replace SiteName ="Dangolori Health Post" if SiteID==	1704110004
replace SiteName ="Kubuna Dispensary" if SiteID==	1704110005
replace SiteName ="Munkawo Health Post" if SiteID==	1704110006
replace SiteName ="Diginsa Health Clinic" if SiteID==	1704110007
replace SiteName ="Tsinkaina Health Post" if SiteID==	1704110008
replace SiteName ="Kirilla Health Post" if SiteID==	1704110009
replace SiteName ="Kachallari Dispensary" if SiteID==	1704110010
replace SiteName ="Kanya Health Clinic (Birniwa)" if SiteID==	1704110011
replace SiteName ="Karanga Basic Health Clinic" if SiteID==	1704110012
replace SiteName ="Kundi Health Post" if SiteID==	1704110013
replace SiteName ="Dolen Kwana Health Post" if SiteID==	1704110014
replace SiteName ="Kazura Primary Health Centre" if SiteID==	1704110015
replace SiteName ="Kubsa Primary Health Centre" if SiteID==	1704110016
replace SiteName ="Marya Health Post" if SiteID==	1704110017
replace SiteName ="Goruba Health Post" if SiteID==	1704110018
replace SiteName ="Nguwa Dispensary" if SiteID==	1704110019
replace SiteName ="Yusufari Health Post" if SiteID==	1704110020
replace SiteName ="Matara Uku Dispensary" if SiteID==	1704110021
replace SiteName ="Gaduwa Health Clinic" if SiteID==	1710110001
replace SiteName ="Abunabo Primary Health Centre" if SiteID==	1710110002
replace SiteName ="Adiyani Basic Health Clinic" if SiteID==	1710110003
replace SiteName ="Gagiya Dispensary" if SiteID==	1710110004
replace SiteName ="Dawa Health Post" if SiteID==	1710110005
replace SiteName ="Garbagal Health Post" if SiteID==	1710110006
replace SiteName ="Guri Primary Health Centre" if SiteID==	1710110007
replace SiteName ="Kadira Basic Health Clinic" if SiteID==	1710110008
replace SiteName ="Lafiya Health Clinic" if SiteID==	1710110009
replace SiteName ="Margadu Dispensary" if SiteID==	1710110010
replace SiteName ="Musari Basic Health Clinic" if SiteID==	1710110011
replace SiteName ="Una Dispensary" if SiteID==	1710110012
replace SiteName ="Dole Dispensary" if SiteID==	1710110013
replace SiteName ="Buntusu Dispensary" if SiteID==	1712110001
replace SiteName ="Jigawar Habe Health Post" if SiteID==	1712110002
replace SiteName ="Dabi Basic Health Clinic" if SiteID==	1712110003
replace SiteName ="Gimi Health Post" if SiteID==	1712110004
replace SiteName ="Tsubut Health Post" if SiteID==	1712110005
replace SiteName ="Maraganta Dispensary" if SiteID==	1712110006
replace SiteName ="Ung/Gamji Health Post" if SiteID==	1712110007
replace SiteName ="Firjin Yamma Health Post" if SiteID==	1712110008
replace SiteName ="Guntai Health Post" if SiteID==	1712110009
replace SiteName ="Gwiwa Primary Health Center" if SiteID==	1712110010
replace SiteName ="Korayel Primary Health Centre" if SiteID==	1712110011
replace SiteName ="Rorau Health Post" if SiteID==	1712110012
replace SiteName ="Daurawa Health Post" if SiteID==	1712110013
replace SiteName ="Shafe Health Post" if SiteID==	1712110014
replace SiteName ="Yola Health Post" if SiteID==	1712110015
replace SiteName ="Fara Health Post" if SiteID==	1712110016
replace SiteName ="Zauma Health Post" if SiteID==	1712110017
replace SiteName ="Aujara Primary Health Centre" if SiteID==	1714110001
replace SiteName ="Damutawa Health Post" if SiteID==	1714110002
replace SiteName ="Gabari Health Post" if SiteID==	1714110003
replace SiteName ="Garan Health Clinic" if SiteID==	1714110004
replace SiteName ="Abarakeu Health Post" if SiteID==	1714110005
replace SiteName ="Farfada Health Post" if SiteID==	1714110006
replace SiteName ="Gangawa Health Clinic" if SiteID==	1714110007
replace SiteName ="Kadowawa Health Clinic" if SiteID==	1714110008
replace SiteName ="Gauza Health post" if SiteID==	1714110009
replace SiteName ="Kafin Baka Health Clinic" if SiteID==	1714110010
replace SiteName ="Tazara Health Post" if SiteID==	1714110011
replace SiteName ="Dare/Doro Health Clinic" if SiteID==	1714110012
replace SiteName ="Gidan Gona Basic Health Clinic" if SiteID==	1714110013
replace SiteName ="Gunka Health Clinic" if SiteID==	1714110014
replace SiteName ="Yalleman Health post" if SiteID==	1714110015
replace SiteName ="Idanduna Health Clinic" if SiteID==	1714110016
replace SiteName ="Rinde Health post" if SiteID==	1714110017
replace SiteName ="Jabarna Health Post" if SiteID==	1714110018
replace SiteName ="Kulluru Health post" if SiteID==	1714110019
replace SiteName ="Magama Dispensary" if SiteID==	1714110020
replace SiteName ="Jahun General Hospital" if SiteID==	1714210021
replace SiteName ="Jahun Urban Maternity Clinic" if SiteID==	1714110022
replace SiteName ="Lafiya Clinic and Maternity" if SiteID==	1714110023
replace SiteName ="Burabura Health Post" if SiteID==	1714110024
replace SiteName ="Gidan Dango Health Post" if SiteID==	1714110025
replace SiteName ="Kale Dispensary" if SiteID==	1714110026
replace SiteName ="Faranshi Health Post" if SiteID==	1714110027
replace SiteName ="Kanwa Basic Health Clinic" if SiteID==	1714110028
replace SiteName ="Tunubo Health post" if SiteID==	1714110029
replace SiteName ="Atuman Health Clinic" if SiteID==	1714110030
replace SiteName ="Taraya Health Post" if SiteID==	1714110031
replace SiteName ="Zangon Kura Health Post" if SiteID==	1714110032
replace SiteName ="Harbo Health Clinic" if SiteID==	1714110033
replace SiteName ="Garado Health Post" if SiteID==	1714110034
replace SiteName ="Dodorin Malam Abdu Health Post" if SiteID==	1716110001
replace SiteName ="Kantamari Health Post" if SiteID==	1716110002
replace SiteName ="Adimin Gasau Health Post" if SiteID==	1716110003
replace SiteName ="Ubba Health Post" if SiteID==	1716110004
replace SiteName ="Dabuwaran Health Post" if SiteID==	1716110005
replace SiteName ="Garin Bagudu Health Post" if SiteID==	1716110006
replace SiteName ="Nuhu Alpha Primary Health Centre" if SiteID==	1716110007
replace SiteName ="Bultuwa Health Clinic" if SiteID==	1716110008
replace SiteName ="Girbobo Basic Health Clinic" if SiteID==	1716110009
replace SiteName ="Hadin Health Post" if SiteID==	1716110010
replace SiteName ="Je'a Health Post" if SiteID==	1716110011
replace SiteName ="Maina Bindi Health Post" if SiteID==	1716110012
replace SiteName ="Turmi Dispensary" if SiteID==	1716110013
replace SiteName ="Kaugama Primary Health Centre" if SiteID==	1716110014
replace SiteName ="Marke Health Clinic" if SiteID==	1716110015
replace SiteName ="Unguwar Jibrin Basic Health Clinic" if SiteID==	1716110016
replace SiteName ="Yalo Dispensary" if SiteID==	1716110017
replace SiteName ="Dandi Basic Health Clinic" if SiteID==	1717110001
replace SiteName ="Gurumfa Health post" if SiteID==	1717110002
replace SiteName ="Ung/Yarima Health Post" if SiteID==	1717110003
replace SiteName ="Dunguyawa Basic Health Clinic" if SiteID==	1717110004
replace SiteName ="Farun Daba Basic Health Clinic" if SiteID==	1717110005
replace SiteName ="Kazaure Kofar Arewa Clinic" if SiteID==	1717110006
replace SiteName ="Kurfi Health Post" if SiteID==	1717110007
replace SiteName ="Gada Dispensary" if SiteID==	1717110008
replace SiteName ="Katoge Health Post" if SiteID==	1717110009
replace SiteName ="Kazaure General Hospital" if SiteID==	1717110010
replace SiteName ="Kazaure Psychiatric Hospital" if SiteID==	1717110011
replace SiteName ="Zainab Mem Hospital" if SiteID==	1717110012
replace SiteName ="Karaftayi Dispensary" if SiteID==	1717110013
replace SiteName ="Mahuchi Health Post" if SiteID==	1717110014
replace SiteName ="Sabaru Dispensary" if SiteID==	1717110015
replace SiteName ="Bandutse Health Post" if SiteID==	1717110016
replace SiteName ="Unguwar Gabas Model Primary Health Centre" if SiteID==	1717110017
replace SiteName ="K/Chiroma Basic Health Clinic " if SiteID==	1717110018
replace SiteName ="Baauzini Health Post" if SiteID==	1717110019
replace SiteName ="Andaza Basic Health Clinic" if SiteID==	1719110001
replace SiteName ="Duhuwa Kiyawa Health Post" if SiteID==	1719110002
replace SiteName ="Balago Basic Health Clinic" if SiteID==	1719110003
replace SiteName ="Fiya Health Post" if SiteID==	1719110004
replace SiteName ="Markiba Health Post" if SiteID==	1719110005
replace SiteName ="Dangoli Health Post" if SiteID==	1719110006
replace SiteName ="Fake Dispensary" if SiteID==	1719110007
replace SiteName ="Gwadabe Health Post" if SiteID==	1719110008
replace SiteName ="Gidan Adede Health Post" if SiteID==	1719110009
replace SiteName ="Garko Dispensary" if SiteID==	1719110010
replace SiteName ="Mazazzaga Health Post" if SiteID==	1719110011
replace SiteName ="Garun Bayan Gari Health Post" if SiteID==	1719110012
replace SiteName ="Gurduba Health Post" if SiteID==	1719110013
replace SiteName ="Shuwarin Maternity Clinic" if SiteID==	1719110014
replace SiteName ="Katanga Primary Health Centre" if SiteID==	1719110015
replace SiteName ="Karfawa Health Post" if SiteID==	1719110016
replace SiteName ="Katuka Basic Health Clinic" if SiteID==	1719110017
replace SiteName ="Jamaar Isah Health Post" if SiteID==	1719110018
replace SiteName ="Gidan Malu Health Post" if SiteID==	1719110019
replace SiteName ="Kiyawa Primary Health Centre" if SiteID==	1719110020
replace SiteName ="Kiyawa Federal Government College School Clinic" if SiteID==	1719110021
replace SiteName ="Danfusan Dispensary" if SiteID==	1719110022
replace SiteName ="Kwanda Basic Health Clinic" if SiteID==	1719110023
replace SiteName ="Maje Kiyawa Dispensary" if SiteID==	1719110024
replace SiteName ="Miyawa Health Post" if SiteID==	1719110025
replace SiteName ="Sabon Gari Kiyawa Basic Health Clinic" if SiteID==	1719110026
replace SiteName ="Tsirma Health Clinic" if SiteID==	1719110027
replace SiteName ="Gorumo Health Post" if SiteID==	1719110028
replace SiteName ="Botsuwa Health Clinic" if SiteID==	1720110001
replace SiteName ="Dankumbo Health Post" if SiteID==	1720110002
replace SiteName ="Galadi Dispensary" if SiteID==	1720110003
replace SiteName ="Jajeri Basic Health Clinic" if SiteID==	1720110004
replace SiteName ="Dansambo Health Post" if SiteID==	1720110005
replace SiteName ="Katika Health Post" if SiteID==	1720110006
replace SiteName ="Kukayasku Basic Health Clinic" if SiteID==	1720110007
replace SiteName ="Madana Dispensary" if SiteID==	1720110008
replace SiteName ="Jobi Health Post" if SiteID==	1720110009
replace SiteName ="Maigatari Primary Health Centre" if SiteID==	1720110010
replace SiteName ="Wanzamai Health Post" if SiteID==	1720110011
replace SiteName ="S/Maja Health Clinic" if SiteID==	1720110012
replace SiteName ="Fulata Health Post" if SiteID==	1720110013
replace SiteName ="Shabarawa Health Post" if SiteID==	1720110014
replace SiteName ="Daguma Health Post" if SiteID==	1720110015
replace SiteName ="Kamainketa Health Post" if SiteID==	1720110016
replace SiteName ="Turbus Health Post" if SiteID==	1720110017
replace SiteName ="Amaryawa Health Clinic" if SiteID==	1724110001
replace SiteName ="Baragumi Dispensary" if SiteID==	1724110002
replace SiteName ="Nanumawa Health Post" if SiteID==	1724110003
replace SiteName ="Dansure Dispensary" if SiteID==	1724110004
replace SiteName ="Gora Dispensary" if SiteID==	1724110005
replace SiteName ="Roni Dispensary" if SiteID==	1724110006
replace SiteName ="Roni ECWA Health Clinic" if SiteID==	1724110007
replace SiteName ="Roni Primary Health Centre" if SiteID==	1724110008
replace SiteName ="Unguwarmani Health Post" if SiteID==	1724110009
replace SiteName ="Takwardawa Dispensary" if SiteID==	1724110010
replace SiteName ="Unguwar Mani Tunas Dispensary" if SiteID==	1724110011
replace SiteName ="Yassara Health Clinic" if SiteID==	1724110012
replace SiteName ="Zugai Basic Health Clinic" if SiteID==	1724110013
replace SiteName ="Bashe Dispensary" if SiteID==	1724110014
													
replace SiteName ="Fara Barinje Dispensary" if SiteID==	1724110015
replace SiteName ="Sankau Health Post" if SiteID==	1724110016
replace SiteName ="Baushe Dispensary" if SiteID==	1724110017
replace SiteName ="Achilafiya Health Clinic" if SiteID==	1727110001
replace SiteName ="Sada Dispensary" if SiteID==	1727110002
replace SiteName ="Murde Dispensary" if SiteID==	1727110003
replace SiteName ="Sabuwa Dispensary" if SiteID==	1727110004
replace SiteName ="Gurjiya (Yankwashi) Basic Health Clinic" if SiteID==	1727110005
replace SiteName ="Gwarta Dispensary" if SiteID==	1727110006
replace SiteName ="Karkarna Health Clinic" if SiteID==	1727110007
replace SiteName ="Kuda Basic Health Clinic" if SiteID==	1727110008
replace SiteName ="Dumbu Health Post" if SiteID==	1727110009
replace SiteName ="Ringin Dispensary" if SiteID==	1727110010
replace SiteName ="Yankwashi Health Post" if SiteID==	1727110011
replace SiteName ="Zoto Health Post" if SiteID==	1727110012
replace SiteName ="Firji Dispensary" if SiteID==	1727110013
replace SiteName ="Rauda BHC" if SiteID== 			1727110014

replace SiteName ="Hadejia General Hospital" if SiteID==	1713210005
replace SiteName ="Dutse General Hospital" if SiteID==	1706210019
replace SiteName ="Gumel General Hospital" if SiteID==	1709210009

*YOBE
replace SiteName ="Azam Kura Dispensary"	if SiteID==	3501110001
replace SiteName ="Azbak Health Clinic"	if SiteID==	3501110002
replace SiteName ="Babuje Dispensary"	if SiteID==	3501110003
replace SiteName ="Bade Clinic"	if SiteID==	3501110004
replace SiteName ="Bizi Health Centre"	if SiteID==	3501110005
replace SiteName ="Central Dispensary"	if SiteID==	3501110006
replace SiteName ="Dagona Health Clinic"	if SiteID==	3501110007
replace SiteName ="Dalah Health Centre"	if SiteID==	3501110008
replace SiteName ="Dawayo Dispensary"	if SiteID==	3501110009
replace SiteName ="Gabarwa Dispensary"	if SiteID==	3501110010
replace SiteName ="Gashu'a Maternity and Child Health Clinic"	if SiteID==	3501110011
replace SiteName ="Gashua Sabon Gari General Hospital"	if SiteID==	3501210012
replace SiteName ="Gwio Kura Dispensary"	if SiteID==	3501110013
replace SiteName ="Jigawa Health Centre"	if SiteID==	3501110014
replace SiteName ="Nasara Clinic"	if SiteID==	3501220015
replace SiteName ="Ngelbowa Health Centre"	if SiteID==	3501110016
replace SiteName ="Ngeljabe Dispensary"	if SiteID==	3501110017
replace SiteName ="Sabon Gari Child Welfare Clinic"	if SiteID==	3501110018
replace SiteName ="Sugum Comprehensive Health Centre"	if SiteID==	3501110019
replace SiteName ="Sugum Dispensary"	if SiteID==	3501110020
replace SiteName ="Tagali Dispensary"	if SiteID==	3501110021
replace SiteName ="Tagama Dispensary"	if SiteID==	3501110022
replace SiteName ="Zango Dispensary"	if SiteID==	3501110023
replace SiteName ="Abbari Dispensary"	if SiteID==	3502110001
replace SiteName ="Ajiri Dispensary"	if SiteID==	3502110002
replace SiteName ="Bade Gana Dispensary"	if SiteID==	3502110003
replace SiteName ="Bayamari Maternity and Child Health Clinic"	if SiteID==	3502110004
replace SiteName ="Bayamari Primary Health Centre"	if SiteID==	3502110005
replace SiteName ="Bururu Dispensary"	if SiteID==	3502110006
replace SiteName ="Dadigar Dispensary"	if SiteID==	3502110007
replace SiteName ="Dalari Health Clinic"	if SiteID==	3502110008
replace SiteName ="Damaya Dispensary"	if SiteID==	3502110009
replace SiteName ="Danani Dispensary"	if SiteID==	3502110010
replace SiteName ="Dapchi General Hospital"	if SiteID==	3502210011
replace SiteName ="Dapchi Maternity and Child Health Clinic"	if SiteID==	3502110012
replace SiteName ="Dapso Dispensary"	if SiteID==	3502110013
replace SiteName ="Dumburi Dispensary"	if SiteID==	3502110014
replace SiteName ="Gadine Dispensary"	if SiteID==	3502110015
replace SiteName ="Gangawa Dispensary"	if SiteID==	3502110016
replace SiteName ="Garin Alkali Dispensary"	if SiteID==	3502110017
replace SiteName ="Garin Kabaju Dispensary"	if SiteID==	3502110018
replace SiteName ="Garun Dole Dispensary"	if SiteID==	3502110019
replace SiteName ="Gilbasu Dispensary"	if SiteID==	3502110020
replace SiteName ="Girim Dispensary"	if SiteID==	3502110021
replace SiteName ="Guba Dispensary"	if SiteID==	3502110022
replace SiteName ="Ilela Dispensary"	if SiteID==	3502110023
replace SiteName ="Jaba Dispensary"	if SiteID==	3502110024
replace SiteName ="Juluri Dispensary"	if SiteID==	3502110025
replace SiteName ="Kakanderi Dispensary"	if SiteID==	3502110026
replace SiteName ="Kaliyari Dispensary"	if SiteID==	3502110027
replace SiteName ="Kankare Dispensary"	if SiteID==	3502110028
replace SiteName ="Koromari Dispensary"	if SiteID==	3502110029
replace SiteName ="Kujikujiri Dispensary"	if SiteID==	3502110030
replace SiteName ="Kurnawa Mother and Child Health Centre"	if SiteID==	3502110031
replace SiteName ="Lawanti Dispensary"	if SiteID==	3502110032
replace SiteName ="Marari Dispensary"	if SiteID==	3502110033
replace SiteName ="Masaba Health Clinic"	if SiteID==	3502110034
replace SiteName ="Metalari Dispensary"	if SiteID==	3502110035
replace SiteName ="Renukunu Dispensary"	if SiteID==	3502110036
replace SiteName ="Sunowa Dispensary"	if SiteID==	3502110037
replace SiteName ="Tarbutu Dispensary"	if SiteID==	3502110038
replace SiteName ="Turbangida Dispensary"	if SiteID==	3502110039
replace SiteName ="Warodi Dispensary"	if SiteID==	3502110040
replace SiteName ="Ajari Dispensary"	if SiteID==	3503110001
replace SiteName ="Ajiko Medical Centre"	if SiteID==	3503220002
replace SiteName ="Borno Medical Clinic"	if SiteID==	3503220003
replace SiteName ="Damakasu Dispensary"	if SiteID==	3503110004
replace SiteName ="Damanturu Federal Poly Clinic"	if SiteID==	3503110005
replace SiteName ="Damanturu Model Primary Health Centre"	if SiteID==	3503110006
replace SiteName ="Damaturu FSP Maternal and Child Health Clinic"	if SiteID==	3503110007
replace SiteName ="Damaturu Government House Clinic"	if SiteID==	3503110008
replace SiteName ="Damaturu Nigerian Police Force Clinic"	if SiteID==	3503110009
replace SiteName ="Dikumari Dispensary"	if SiteID==	3503110010
replace SiteName ="Federal Secretariat Staff Clinic"	if SiteID==	3503110011
replace SiteName ="Gabai Dispensary"	if SiteID==	3503110012
replace SiteName ="Gambir Dispensary"	if SiteID==	3503110013
replace SiteName ="Gwange Maternity and Child Health Clinic"	if SiteID==	3503110014
replace SiteName ="Kabaru Dispensary"	if SiteID==	3503110015
replace SiteName ="Kalallawa Dispensary"	if SiteID==	3503110016
replace SiteName ="Kukareta Maternity and Child Health Clinic"	if SiteID==	3503110017
replace SiteName ="Maisandari Clinic"	if SiteID==	3503110018
replace SiteName ="Murfa Kalam Dispensary"	if SiteID==	3503110019
replace SiteName ="Nayinawa Dispensary"	if SiteID==	3503110020
replace SiteName ="Sasawa Dispensary"	if SiteID==	3503110021
replace SiteName ="State Specialist Hospital"	if SiteID==	3503210022
replace SiteName ="Very Important Persons Clinic"	if SiteID==	3503220023
replace SiteName ="Yobe Medical and Maternity Clinic"	if SiteID==	3503220024
replace SiteName ="Yobe State Secretariat Clinic"	if SiteID==	3503110025
replace SiteName ="Anze Dispensary"	if SiteID==	3504110001
replace SiteName ="Boza Dispensary"	if SiteID==	3504110002
replace SiteName ="Bulaburin Health Clinic"	if SiteID==	3504110003
replace SiteName ="Chana Dispensary"	if SiteID==	3504110004
replace SiteName ="Damaze Health Clinic"	if SiteID==	3504110005
replace SiteName ="Daya Health Clinic"	if SiteID==	3504110006
replace SiteName ="Dogo Abare Health Clinic"	if SiteID==	3504110007
replace SiteName ="Dole Health Post"	if SiteID==	3504110008
replace SiteName ="Doto Fara Health Clinic"	if SiteID==	3504110009
replace SiteName ="Duffuyel Health Clinic"	if SiteID==	3504110010
replace SiteName ="Dumbulwa Dispensary"	if SiteID==	3504110011
replace SiteName ="Fakali Health Clinic"	if SiteID==	3504110012
replace SiteName ="Ferol Health Clinic"	if SiteID==	3504110013
replace SiteName ="Fika General Hospital"	if SiteID==	3504210014
replace SiteName ="Fika Maternity and Child Health Clinic"	if SiteID==	3504110015
replace SiteName ="Gadaka Health Clinic"	if SiteID==	3504110016
replace SiteName ="Gadaka Model Primary Health Centre"	if SiteID==	3504110017
replace SiteName ="Gamari Health Clinic"	if SiteID==	3504110018
replace SiteName ="Garin Abba Health Clinic"	if SiteID==	3504110019
replace SiteName ="Garin Alaramma Health Post"	if SiteID==	3504110020
replace SiteName ="Garin Ari Health Clinic"	if SiteID==	3504110021
replace SiteName ="Garin Chindo Health Post"	if SiteID==	3504110022
replace SiteName ="Garin Dauya Health Clinic"	if SiteID==	3504110023
replace SiteName ="Garin Gamji Health Clinic"	if SiteID==	3504110024
replace SiteName ="Garin Goge Dispensary"	if SiteID==	3504110025
replace SiteName ="Garin Tongo Health Post"	if SiteID==	3504110026
replace SiteName ="Garin Wayo Health Clinic"	if SiteID==	3504110027
replace SiteName ="Garin Yarima Health Post"	if SiteID==	3504110028
replace SiteName ="Garkuwa Health Clinic"	if SiteID==	3504110029
replace SiteName ="Gashaka Health Clinic"	if SiteID==	3504110030
replace SiteName ="Gashinge Health Post"	if SiteID==	3504110031
replace SiteName ="Godowoli Dispensary"	if SiteID==	3504110032
replace SiteName ="Gurjaje Health Post"	if SiteID==	3504110033
replace SiteName ="Janga Dole Health Clinic"	if SiteID==	3504110034
replace SiteName ="Janga Siri Health Post"	if SiteID==	3504110035
replace SiteName ="Kabano Health Clinic"	if SiteID==	3504110036
replace SiteName ="Kerem Health Clinic"	if SiteID==	3504110037
replace SiteName ="Koyaya Health Clinic"	if SiteID==	3504110038
replace SiteName ="Kukar Gadu Health Clinic"	if SiteID==	3504110039
replace SiteName ="Kurmi Dispensary"	if SiteID==	3504110040
replace SiteName ="Lewe Health Clinic"	if SiteID==	3504110041
replace SiteName ="Maluri Dispensary"	if SiteID==	3504110042
replace SiteName ="Manawachi Health Clinic"	if SiteID==	3504110043
replace SiteName ="Mazuwan Health Clinic"	if SiteID==	3504110044
replace SiteName ="Mubi/Fusami Dispensary"	if SiteID==	3504110045
replace SiteName ="Munchika Health Clinic"	if SiteID==	3504110046
replace SiteName ="Ngalda Dispensary"	if SiteID==	3504110047
replace SiteName ="Siminti Health Clinic"	if SiteID==	3504110048
replace SiteName ="Siminti Model Primary Health Clinic"	if SiteID==	3504110049
replace SiteName ="Turmi Health Clinic"	if SiteID==	3504110050
replace SiteName ="Yelwa Dispensary"	if SiteID==	3504110051
replace SiteName ="Zadawa Health Clinic"	if SiteID==	3504110052
replace SiteName ="Zamba Health Post"	if SiteID==	3504110053
replace SiteName ="Zangaya Dispensary"	if SiteID==	3504110054
replace SiteName ="Abakire Dispensary"	if SiteID==	3505110001
replace SiteName ="Aigala Dispensary"	if SiteID==	3505110002
replace SiteName ="Alagarno Health Clinic"	if SiteID==	3505110003
replace SiteName ="Balarabe Maternal and Child Health Clinic"	if SiteID==	3505220004
replace SiteName ="Banalewa Health Post"	if SiteID==	3505110005
replace SiteName ="Baushe Model Primary Health Centre"	if SiteID==	3505110006
replace SiteName ="Bebande Health Post"	if SiteID==	3505110007
replace SiteName ="Bindigi Health Clinic"	if SiteID==	3505110008
replace SiteName ="Borno Kiji Maternal and Child Health Clinic"	if SiteID==	3505110009
replace SiteName ="Bulanyiwa Health Clinic"	if SiteID==	3505110010
replace SiteName ="Damagum General Hospital"	if SiteID==	3505210011
replace SiteName ="Damagum Maternity and Child Health Clinic"	if SiteID==	3505110012
replace SiteName ="Daura Maternity and Child Health Clinic"	if SiteID==	3505110013
replace SiteName ="Dogon-Kuka B Maternal and Child Health Clinic"	if SiteID==	3505110014
replace SiteName ="Dogon-Kuka Maternity and Child Health Clinic"	if SiteID==	3505110015
replace SiteName ="Dubbol Model Primary Health Centre"	if SiteID==	3505110016
replace SiteName ="Duhuna Health Clinic"	if SiteID==	3505110017
replace SiteName ="Dumawal Health Post"	if SiteID==	3505110018
replace SiteName ="Dumbulwa (Fune) Dispensary"	if SiteID==	3505110019
replace SiteName ="Gaba Tasha Dispensary"	if SiteID==	3505110020
replace SiteName ="Ganji Dispensary"	if SiteID==	3505110021
replace SiteName ="Gazarakuma Health Post"	if SiteID==	3505110022
replace SiteName ="Gishiwari Dispensary"	if SiteID==	3505110023
replace SiteName ="Gubana Dispensary"	if SiteID==	3505110024
replace SiteName ="Gudugurka Dispensary"	if SiteID==	3505110025
replace SiteName ="Gurungu Health Post"	if SiteID==	3505110026
replace SiteName ="Jajere Dispensary"	if SiteID==	3505110027
replace SiteName ="Jajere Maternity and Child Health Clinic"	if SiteID==	3505110028
replace SiteName ="Jaji Burawa Dispensary"	if SiteID==	3505110029
replace SiteName ="Kafaje Dispensary"	if SiteID==	3505110030
replace SiteName ="Kayeri Dispensary"	if SiteID==	3505110031
replace SiteName ="Kayeri Maternity and Child Health Clinic"	if SiteID==	3505110032
replace SiteName ="Koibula Dispensary"	if SiteID==	3505110033
replace SiteName ="Kollere Health Clinic"	if SiteID==	3505110034
replace SiteName ="Koyaya Health Post"	if SiteID==	3505110035
replace SiteName ="Kwara-Wango Health Post"	if SiteID==	3505110036
replace SiteName ="Marmari Dispensary"	if SiteID==	3505110037
replace SiteName ="Mashio Health Clinic"	if SiteID==	3505110038
replace SiteName ="Murba Health Post"	if SiteID==	3505110039
replace SiteName ="Ngelshengele Dispensary"	if SiteID==	3505110040
replace SiteName ="Ngelzerma Maternity and Child Health Clinic"	if SiteID==	3505110041
replace SiteName ="Ningi Dispensary"	if SiteID==	3505110042
replace SiteName ="Sabongari Idi-Barde Dispensary"	if SiteID==	3505110043
replace SiteName ="Shamka Dispensary"	if SiteID==	3505110044
replace SiteName ="Shanga Dispensary"	if SiteID==	3505110045
replace SiteName ="Siminti (Fune) Dispensary"	if SiteID==	3505110046
replace SiteName ="Sudande Health Post"	if SiteID==	3505110047
replace SiteName ="Taiyu Health Post"	if SiteID==	3505110048
replace SiteName ="Tello Dispensary"	if SiteID==	3505110049
replace SiteName ="Alhajiri Dispensary"	if SiteID==	3506110001
replace SiteName ="Ashekri Town Dispensary"	if SiteID==	3506110002
replace SiteName ="Balle Maternal and Child Health Clinic"	if SiteID==	3506110003
replace SiteName ="Borko Dispensary"	if SiteID==	3506110004
replace SiteName ="Dagambi Dispensary"	if SiteID==	3506110005
replace SiteName ="Dajina Dispensary"	if SiteID==	3506110006
replace SiteName ="Damakarwa Dispensary"	if SiteID==	3506110007
replace SiteName ="Darro Dispensary"	if SiteID==	3506110008
replace SiteName ="Dilawa Dispensary"	if SiteID==	3506110009
replace SiteName ="Fukurti Dispensary"	if SiteID==	3506110010
replace SiteName ="Futchimiram Health Clinic"	if SiteID==	3506110011
replace SiteName ="Geidam General Hospital"	if SiteID==	3506210012
replace SiteName ="Geidam Maternity and Child Health Clinic"	if SiteID==	3506110013
replace SiteName ="Gumsa Model Primary Health Centre"	if SiteID==	3506110014
replace SiteName ="Hausari Dispensary"	if SiteID==	3506110015
replace SiteName ="Kelluri Mother and Child Health Centre"	if SiteID==	3506110016
replace SiteName ="Kindila Dispensary"	if SiteID==	3506110017
replace SiteName ="Kukawa Dispensary"	if SiteID==	3506110018
replace SiteName ="Kusur Dispensary"	if SiteID==	3506110019
replace SiteName ="Lawan Bukarti Dispensary"	if SiteID==	3506110020
replace SiteName ="Ma'anna Dispensary"	if SiteID==	3506110021
replace SiteName ="Malari Dispensary"	if SiteID==	3506110022
replace SiteName ="Matakuskum Health Clinic"	if SiteID==	3506110023
replace SiteName ="Adetona Medical Centre"	if SiteID==	3507220001
* Errors in official docs for Guijba LGA Yobe
replace SiteName ="Ambiya Dispensary"			if SiteID==	3507110002
replace SiteName ="Azare Dispensary"			if SiteID==	3507110003
replace SiteName ="Bukkil Dispensary"			if SiteID==	3507110004
replace SiteName ="Bulturam Dispensary"			if SiteID==	3507110005
replace SiteName ="Buni Gari Dispesanry"		if SiteID==	3507110006
replace SiteName ="Buni Yadi General Hospital"	if SiteID==	3507210007
replace SiteName ="Buniyadi Maternity and Child Health Clinic"	if SiteID==	3507110008
replace SiteName ="Dadewel Dispensary"			if SiteID==	3507110009
replace SiteName ="Dadingel Dispensary"			if SiteID==	3507110010
replace SiteName ="Goniri Comprehensive Health Centre"	if SiteID==	3507110011
replace SiteName ="Goniri Dispensary"			if SiteID==	3507110012
replace SiteName ="Gotumba Dispensary"			if SiteID==	3507110013
replace SiteName ="Gujba Dispensary"			if SiteID==	3507110014
replace SiteName ="Kasachiya Dispensary"		if SiteID==	3507110015
replace SiteName ="Katarko Dispensary"			if SiteID==	3507110016
replace SiteName ="Kukuwa Dispensary"			if SiteID==	3507110017
replace SiteName ="Malum-Dunari Dispensary"		if SiteID==	3507110018
replace SiteName ="Mutai Dispensary"			if SiteID==	3507110019
replace SiteName ="Ngurbuwa Maternity and Child Health Clinic"	if SiteID==	3507110020
replace SiteName ="Nyakire Dispensary"			if SiteID==	3507110021
replace SiteName ="Wagir Model Primary Health Centre"	if SiteID==	3507110022
replace SiteName ="Wulle Dispensary"			if SiteID==	3507110023
replace SiteName ="Alagarno Health Post"	if SiteID==	3508110001
replace SiteName ="Ayada Health Post"	if SiteID==	3508110002
replace SiteName ="Badugo-Badugoro Health Post"	if SiteID==	3508110003
replace SiteName ="Bara Comprensive Health Centre"	if SiteID==	3508110004
replace SiteName ="Bara Dispensary"	if SiteID==	3508110005
replace SiteName ="Birni-Gadam Health Post"	if SiteID==	3508110006
replace SiteName ="Borno Kiji Health Post"	if SiteID==	3508110007
replace SiteName ="Bularafa Health Centre"	if SiteID==	3508110008
replace SiteName ="Bumsa Dispensary"	if SiteID==	3508110009
replace SiteName ="Bursari Health Post"	if SiteID==	3508110010
replace SiteName ="Chandam Health Post"	if SiteID==	3508110011
replace SiteName ="Choka Health Post"	if SiteID==	3508110012
replace SiteName ="Dokshi Health Centre"	if SiteID==	3508110013
replace SiteName ="Dutchi Health Post"	if SiteID==	3508110014
replace SiteName ="Gabai Dispensary (Gulani)"	if SiteID==	3508110015
replace SiteName ="Gagure Dispensary"	if SiteID==	3508110016
replace SiteName ="Gargari Health Post"	if SiteID==	3508110017
replace SiteName ="Garin Maikomo Health Post"	if SiteID==	3508110018
replace SiteName ="Garin-Abdullahi Health Post"	if SiteID==	3508110019
replace SiteName ="Garintuwo Dispensary"	if SiteID==	3508110020
replace SiteName ="Gulani Health Centre"	if SiteID==	3508110021
replace SiteName ="Jana Health Post"	if SiteID==	3508110022
replace SiteName ="Kukuwa Health Post"	if SiteID==	3508110023
replace SiteName ="Kupto-Gana Health Post"	if SiteID==	3508110024
replace SiteName ="Kushimaga Dispensary"	if SiteID==	3508110025
replace SiteName ="Mabani Health Post"	if SiteID==	3508110026
replace SiteName ="Ngurum Health Post"	if SiteID==	3508110027
replace SiteName ="Nguzuwa Health Post"	if SiteID==	3508110028
replace SiteName ="Njibulwa Model Primary Health Centre"	if SiteID==	3508110029
replace SiteName ="Njibulwa Private Clinic"	if SiteID==	3508220030
replace SiteName ="Ruhu Dispensary"	if SiteID==	3508110031
replace SiteName ="Ruwan Kuka Health Post"	if SiteID==	3508110032
replace SiteName ="Shishi Waji Health Post"	if SiteID==	3508110033
replace SiteName ="Teteba Dispensary"	if SiteID==	3508110034
replace SiteName ="Yelwa Health Post (Gulani)"	if SiteID==	3508110035
replace SiteName ="Zongo Health Centre"	if SiteID==	3508110036
replace SiteName ="Adiya Dispensary"	if SiteID==	3509110001
replace SiteName ="Agana Health Centre"	if SiteID==	3509110002
replace SiteName ="Amshi Maternity and Child Health Clinic"	if SiteID==	3509110003
replace SiteName ="Ariri Health Centre"	if SiteID==	3509110004
replace SiteName ="Arvani Health Centre"	if SiteID==	3509110005
replace SiteName ="Bayam Dispensary"	if SiteID==	3509110006
replace SiteName ="Bubuno Health Centre"	if SiteID==	3509110007
replace SiteName ="Buduwa Health Centre"	if SiteID==	3509110008
replace SiteName ="Dachia Health Centre"	if SiteID==	3509110009
replace SiteName ="Damasa Health Centre"	if SiteID==	3509110010
replace SiteName ="Dan Takuni Health Centre"	if SiteID==	3509110011
replace SiteName ="Doro Health Centre"	if SiteID==	3509110012
replace SiteName ="Dumbari Dispensary"	if SiteID==	3509110013
replace SiteName ="Gamajam Health Centre"	if SiteID==	3509110014
replace SiteName ="Garin Biri Health Centre"	if SiteID==	3509110015
replace SiteName ="Garin Gano Health Centre"	if SiteID==	3509110016
replace SiteName ="Garin Tsalha Health Centre"	if SiteID==	3509110017
replace SiteName ="Gasamu Dispensary"	if SiteID==	3509110018
replace SiteName ="Gasi Health Centre"	if SiteID==	3509110019
replace SiteName ="Gauya Dispensary"	if SiteID==	3509110020
replace SiteName ="Girgir Dispensary"	if SiteID==	3509110021
replace SiteName ="Gogaram Federal Model Primary Health Centre"	if SiteID==	3509110022
replace SiteName ="Gumulawa Health Centre"	if SiteID==	3509110023
replace SiteName ="Gurbana Health Centre"	if SiteID==	3509110024
replace SiteName ="Guzambana Health Centre"	if SiteID==	3509110025
replace SiteName ="Gwayo Dispensary"	if SiteID==	3509110026
replace SiteName ="Iyim Dispensary"	if SiteID==	3509110027
replace SiteName ="Jaba Health Centre"	if SiteID==	3509110028
replace SiteName ="Jadam Health Centre"	if SiteID==	3509110029
replace SiteName ="Jakusko Dispensary"	if SiteID==	3509110030
replace SiteName ="Jakusko General Hospital"	if SiteID==	3509210031
replace SiteName ="Jakusko Maternity and Child Health Clinic"	if SiteID==	3509110032
replace SiteName ="Jamil Health Centre"	if SiteID==	3509110033
replace SiteName ="Kagammu Health Centre"	if SiteID==	3509110034
replace SiteName ="Karage Maternity and Child Health Clinic"	if SiteID==	3509110035
replace SiteName ="Katamma Health Centre"	if SiteID==	3509110036
replace SiteName ="Katangana Health Centre"	if SiteID==	3509110037
replace SiteName ="Kazir Dispensary"	if SiteID==	3509110038
replace SiteName ="Kukamaiwa Health Centre"	if SiteID==	3509110039
replace SiteName ="Kurkushe Dispensary"	if SiteID==	3509110040
replace SiteName ="Lafiyaloiloi Dispensary"	if SiteID==	3509110041
replace SiteName ="Lafiyan Gwa Health Centre"	if SiteID==	3509110042
replace SiteName ="Lamarbago Dispensary"	if SiteID==	3509110043
replace SiteName ="Muguram Health Centre"	if SiteID==	3509110044
replace SiteName ="Tajuwa Dispensary"	if SiteID==	3509110045
replace SiteName ="Tarja Health Centre"	if SiteID==	3509110046
replace SiteName =" Tudiniya Health Centre"	if SiteID==	3509110047
replace SiteName ="Bukarti Health Clinic"	if SiteID==	3510110001
replace SiteName ="Bukku Health Post"	if SiteID==	3510110002
replace SiteName ="Bularifi Dispensary"	if SiteID==	3510110003
replace SiteName ="Faji Ganari Dispensary"	if SiteID==	3510110004
replace SiteName ="Garin Gawo Dispensary"	if SiteID==	3510110005
replace SiteName ="Gasma Dispensary"	if SiteID==	3510110006
replace SiteName ="Jajeri Dispensary"	if SiteID==	3510110007
replace SiteName ="Jajimaji Comprehensive Health Centre"	if SiteID==	3510110008
replace SiteName ="Jajimaji Maternal and Child Health Clinic"	if SiteID==	3510110009
replace SiteName ="Kafetuwa Health Post"	if SiteID==	3510110010
replace SiteName ="Karasuwa Galu Dispensary"	if SiteID==	3510110011
replace SiteName ="Karasuwa Health Clinic"	if SiteID==	3510110012
replace SiteName ="Karasuwa Model Primary Health Centre"	if SiteID==	3510110013
replace SiteName ="Kilbuwa Health Post"	if SiteID==	3510110014
replace SiteName ="Lamido Sule Health Post"	if SiteID==	3510110015
replace SiteName ="Mallam Grema Health Post"	if SiteID==	3510110016
replace SiteName ="Mallam Musari Health Post"	if SiteID==	3510110017
replace SiteName ="Wachakal Dispensary"	if SiteID==	3510110018
replace SiteName ="Waro Dispensary"	if SiteID==	3510110019
replace SiteName ="Bogo Dispensary"	if SiteID==	3511110001
replace SiteName ="Burdumaram Dispensary"	if SiteID==	3511110002
replace SiteName ="Damai Dispensary"	if SiteID==	3511110003
replace SiteName ="Damdari Dispensary"	if SiteID==	3511110004
replace SiteName ="Dole Machina Health Clinic"	if SiteID==	3511110005
replace SiteName ="Falimaram Dispensary"	if SiteID==	3511110006
replace SiteName ="Garanda Dispensary"	if SiteID==	3511110007
replace SiteName ="Goki Dispensary"	if SiteID==	3511110008
replace SiteName ="Kagumsuwa Dispensary"	if SiteID==	3511110009
replace SiteName ="Kalgidi Dispensary"	if SiteID==	3511110010
replace SiteName ="Kangarwa Dispensary"	if SiteID==	3511110011
replace SiteName ="Karmashe Dispensary"	if SiteID==	3511110012
replace SiteName ="Kukayasku Dispensary"	if SiteID==	3511110013
replace SiteName ="Lamisu Dispensary"	if SiteID==	3511110014
replace SiteName ="Machina Central Dispensary"	if SiteID==	3511110015
replace SiteName ="Machina Comprehensive Health Centre"	if SiteID==	3511110016
replace SiteName ="Machina Maternity Child Health Clinic"	if SiteID==	3511110017
replace SiteName ="Maskandare Dispensary"	if SiteID==	3511110018
replace SiteName ="Taganama Dispensary"	if SiteID==	3511110019
replace SiteName ="Yalauwa Dispensary"	if SiteID==	3511110020
replace SiteName ="Baraniya Health Clinic"	if SiteID==	3512110001
replace SiteName ="Biriri Dispensary"	if SiteID==	3512110002
replace SiteName ="Chalinno Dispensary"	if SiteID==	3512110003
replace SiteName ="Chukuriwa Primary Health Centre"	if SiteID==	3512110004
replace SiteName ="Dadiso Health Post"	if SiteID==	3512110005
replace SiteName ="Dagare Dispensary"	if SiteID==	3512110006
replace SiteName ="Dagazirwa Health Clinic"	if SiteID==	3512110007
replace SiteName ="Darin Health Post"	if SiteID==	3512110008
replace SiteName ="Dawasa Dispensary"	if SiteID==	3512110009
replace SiteName ="Dawasa Maternity and Child (State) Health Clinic"	if SiteID==	3512110010
replace SiteName ="Dazigau Maternity and Child Health Clinic"	if SiteID==	3512110011
replace SiteName ="Degubi Model Primary Health Centre"	if SiteID==	3512110012
replace SiteName ="Dorawa Dadi Health Post"	if SiteID==	3512110013
replace SiteName ="Duddaye Dispensary"	if SiteID==	3512110014
replace SiteName ="Gabur Dispensary"	if SiteID==	3512110015
replace SiteName ="Garin Baba Dispensary"	if SiteID==	3512110016
replace SiteName ="Garin Gambo Dispensary"	if SiteID==	3512110017
replace SiteName ="Garin Jata Dispensary"	if SiteID==	3512110018
replace SiteName ="Garin Kadai Dispensary"	if SiteID==	3512110019
replace SiteName ="Garin Keri Dispensary"	if SiteID==	3512110020
replace SiteName ="Garin Muzam Health Clinic"	if SiteID==	3512110021
replace SiteName ="Garin Shera Dispensary"	if SiteID==	3512110022
replace SiteName ="Gudi Dispensary"	if SiteID==	3512110023
replace SiteName ="Haram Dispensary"	if SiteID==	3512110024
replace SiteName ="Kael Dispensary"	if SiteID==	3512110025
replace SiteName ="Katsira Health Centre"	if SiteID==	3512110026
replace SiteName ="Kukuri (State) Maternity and Child Health Clinic"	if SiteID==	3512110027
replace SiteName ="Kukuri Primary Health Centre"	if SiteID==	3512110028
replace SiteName ="Nangere General Hospital"	if SiteID==	3512210029
replace SiteName ="Old Nangere Health Clinic"	if SiteID==	3512110030
replace SiteName ="Sabongari Maternity and Child Health Clinic"	if SiteID==	3512110031
replace SiteName ="Tarajim Health post"	if SiteID==	3512110032
replace SiteName ="Tikau Health Centre"	if SiteID==	3512110033
replace SiteName ="Tudun Wada Health Clinic"	if SiteID==	3512110034
replace SiteName ="Watinane Maternity and Child Health Clinic"	if SiteID==	3512110035
replace SiteName ="Yaru Health Post"	if SiteID==	3512110036
replace SiteName ="Zinzano Dispensary"	if SiteID==	3512110037
replace SiteName ="Afunori Clinic"	if SiteID==	3513110001
replace SiteName ="Army Barrack Clinic (Nguru)"	if SiteID==	3513110002
replace SiteName ="Balanguwa Clinic"	if SiteID==	3513110003
replace SiteName ="Bombori Clinic"	if SiteID==	3513110004
replace SiteName ="Bubari Health Clinic"	if SiteID==	3513110005
replace SiteName ="Bulabulin Central Dispensary"	if SiteID==	3513110006
replace SiteName ="Dagirari Clinic"	if SiteID==	3513110007
replace SiteName ="Dumsai Dispensary"	if SiteID==	3513110008
replace SiteName ="Garbi Health Clinic"	if SiteID==	3513110009
replace SiteName ="Maja-Kura Clinic"	if SiteID==	3513110010
replace SiteName ="Ngilewa Health Clinic"	if SiteID==	3513110011
replace SiteName ="Nguru Federal Medical Centre"	if SiteID==	3513310012
replace SiteName ="Nguru Federal Model Primary Health Centre"	if SiteID==	3513110013
replace SiteName ="Nguru Maternal and Child Health Clinic"	if SiteID==	3513110014
replace SiteName ="Salisu Memorial Clinic"	if SiteID==	3513220015
replace SiteName ="Badejo Clinic"	if SiteID==	3514110001
replace SiteName ="Beta Clinic"	if SiteID==	3514220002
replace SiteName ="Bilam Fusam Clinic"	if SiteID==	3514110003
replace SiteName ="Bubaram Health Clinic"	if SiteID==	3514110004
replace SiteName ="Bula Clinic"	if SiteID==	3514110005
replace SiteName ="Bulabulin Clinic"	if SiteID==	3514110006
replace SiteName ="Catholic Maternity and Child Health Clinic"	if SiteID==	3514220007
replace SiteName ="Dakasku Clinic"	if SiteID==	3514110008
replace SiteName ="Danchuwa Clinic"	if SiteID==	3514110009
replace SiteName ="Dogon-Zare Clinic"	if SiteID==	3514110010
replace SiteName ="Eva Clinic"	if SiteID==	3514220011
replace SiteName ="Garin Abba Clinic"	if SiteID==	3514110012
replace SiteName ="Garin Dala Clinic"	if SiteID==	3514110013
replace SiteName ="Garin Kachalla Health Clinic"	if SiteID==	3514110014
replace SiteName ="Garin Makwai Maternal and Child Health Clinic"	if SiteID==	3514110015
replace SiteName ="Garin Mele Clinic"	if SiteID==	3514110016
replace SiteName ="Potiskum General Hospital"	if SiteID==	3514110017
replace SiteName ="Jama'a 2 Clinic"	if SiteID==	3514220018
replace SiteName ="Jamma'a Clinic"	if SiteID==	3514220019
replace SiteName ="Juma'a Clinic"	if SiteID==	3514110020
replace SiteName ="Leprosy Clinic"	if SiteID==	3514110021
replace SiteName ="Maje Clinic"	if SiteID==	3514110022
replace SiteName ="Mamudo Maternity and Child Health Clinic"	if SiteID==	3514110023
replace SiteName ="Mazaganai Maternity and Child Health Clinic"	if SiteID==	3514110024
replace SiteName ="Nahuta Clinic"	if SiteID==	3514110025
replace SiteName ="Potiskum Maternity and Child Health Clinic"	if SiteID==	3514110026
replace SiteName ="Potiskum Medical Clinic"	if SiteID==	3514220027
replace SiteName ="Potiskum Town Central Clinic"	if SiteID==	3514220028
replace SiteName ="Royal Clinic"	if SiteID==	3514220029
replace SiteName ="Taif Maternity Clinic"	if SiteID==	3514220030
replace SiteName ="Tudun Wada Maternity and Child Health Clinic"	if SiteID==	3514110031
replace SiteName ="Yerimaram Maternal and Child Health Clinic"	if SiteID==	3514110032
replace SiteName ="Yindiski Maternity and Child Health Clinic"	if SiteID==	3514110033
replace SiteName ="Zanwa Clinic"	if SiteID==	3514110034
replace SiteName ="Farafara MCH"	if SiteID==	3514110035
replace SiteName ="Babbangida Comprehensive Health Centre"	if SiteID==	3515110001
replace SiteName ="Babbangida Health Clinic"	if SiteID==	3515110002
replace SiteName ="Barkami Dispensary"	if SiteID==	3515110003
replace SiteName ="Biriri Dispensary (Tarmuwa)"	if SiteID==	3515110004
replace SiteName ="Chirokusko Dispensary"	if SiteID==	3515110005
replace SiteName ="Garga Dispensary"	if SiteID==	3515110006
replace SiteName ="Goduram Dispensary"	if SiteID==	3515110007
replace SiteName ="Jumbam Maternity and Child Health Clinic"	if SiteID==	3515110008
replace SiteName ="Kaliyari Dispensary (Tarmuwa)"	if SiteID==	3515110009
replace SiteName ="Koka MDG Clinic"	if SiteID==	3515110010
replace SiteName ="Koriyel Health Centre"	if SiteID==	3515110011
replace SiteName ="Lantaiwa Dispensary"	if SiteID==	3515110012
replace SiteName ="Mafa Maternity and Child Health Clinic"	if SiteID==	3515110013
replace SiteName ="Mandadawa Dispensary"	if SiteID==	3515110014
replace SiteName ="Matari Dispensary"	if SiteID==	3515110015
replace SiteName ="Shekau Dispensary"	if SiteID==	3515110016
replace SiteName ="Sungul Dispensary"	if SiteID==	3515110017
replace SiteName ="Buhari Dispensary"	if SiteID==	3516110001
replace SiteName ="Bukarti Dispensary"	if SiteID==	3516110002
replace SiteName ="Bulabulin Dispensary"	if SiteID==	3516110003
replace SiteName ="Bultuwa Maternity and Child Health Clinic"	if SiteID==	3516110004
replace SiteName ="Dalari Dispensary"	if SiteID==	3516110005
replace SiteName ="Degeltura Primary Health Centre"	if SiteID==	3516110006
replace SiteName ="Dekwa Dispensary"	if SiteID==	3516110007
replace SiteName ="Dilala Dispensary"	if SiteID==	3516110008
replace SiteName ="Dumbal Dispensary"	if SiteID==	3516110009
replace SiteName ="Garin Gada Dispensary"	if SiteID==	3516110010
replace SiteName ="Garin Gawo Dispensary (Yanusari)"	if SiteID==	3516110011
replace SiteName ="Gremari Dispensary"	if SiteID==	3516110012
replace SiteName ="Gursulu Dispensary"	if SiteID==	3516110013
replace SiteName ="Jigage Dispensary"	if SiteID==	3516110014
replace SiteName ="Kafiya Primary Health Centre"	if SiteID==	3516110015
replace SiteName ="Kakanderi Dispensary (Yanusari)"	if SiteID==	3516110016
replace SiteName ="Kalgi Dispensary"	if SiteID==	3516110017
replace SiteName ="Kanamma General Hospital"	if SiteID==	3516210018
replace SiteName ="Kujari Primary Health Centre"	if SiteID==	3516110019
replace SiteName ="Mairari Dispensary"	if SiteID==	3516110020
replace SiteName ="Manawaji Health Post"	if SiteID==	3516110021
replace SiteName ="Masta Fari Health Post"	if SiteID==	3516110022
replace SiteName ="Mozogum Dispensary"	if SiteID==	3516110023
replace SiteName ="Nganzai Dispensary"	if SiteID==	3516110024
replace SiteName ="Toshia Dispensary"	if SiteID==	3516110025
replace SiteName ="Wa'anga Health Post"	if SiteID==	3516110026
replace SiteName ="Yunusari Comprehensive Health Centre"	if SiteID==	3516110027
replace SiteName ="Yunusari Health Clinic"	if SiteID==	3516110028
replace SiteName ="Zai Dispensary"	if SiteID==	3516110029
replace SiteName ="Zajibiriri Dispensary"	if SiteID==	3516110030
replace SiteName ="Zigindimi Health Post"	if SiteID==	3516110031
replace SiteName ="Abbatura Dispensary"	if SiteID==	3517110001
replace SiteName ="Bula Jaji Dispensary"	if SiteID==	3517110002
replace SiteName ="Bula Madu Dispensary"	if SiteID==	3517110003
replace SiteName ="Bulatura Dispensary"	if SiteID==	3517110004
replace SiteName ="Gumshi Dispensary"	if SiteID==	3517110005
replace SiteName ="Guya Dispensary"	if SiteID==	3517110006
replace SiteName ="Guyamari Dispensary"	if SiteID==	3517110007
replace SiteName ="Jebuwa Dispensary"	if SiteID==	3517110008
replace SiteName ="Kachallari Dispensary (Yusufari)"	if SiteID==	3517110009
replace SiteName ="Kaluwa Dispensary"	if SiteID==	3517110010
replace SiteName ="Kaska Dispensary"	if SiteID==	3517110011
replace SiteName ="Kerewa Dispensary"	if SiteID==	3517110012
replace SiteName ="Kuka Tatawa Dispensary"	if SiteID==	3517110013
replace SiteName ="Kumagannam Dispensary"	if SiteID==	3517110014
replace SiteName ="Kumagannam General Hospital"	if SiteID==	3517210015
replace SiteName ="Maimalari Dispensary"	if SiteID==	3517110016
replace SiteName ="Masassara Dispensary"	if SiteID==	3517110017
replace SiteName ="Mayori Dispensary"	if SiteID==	3517110018
replace SiteName ="Sumbar Dispensary"	if SiteID==	3517110019
replace SiteName ="Tulo-Tulo Dispensary"	if SiteID==	3517110020
replace SiteName ="Yusufari Comprehensive Health Centre"	if SiteID==	3517110021
replace SiteName ="Yusufari Maternity and Child Health Clinic"	if SiteID==	3517110022
replace SiteName ="Yusufari Model Primary Health Centre"	if SiteID==	3517110023
replace SiteName ="Zumugu Dispensary"	if SiteID==	3517110024

replace SiteName = lga + " LGA" if Level=="Second"
replace SiteName = state + " State" if Level=="First"
tab SiteName, m


* User Name
replace Name = proper(Name)

* Email
cap gen Mail = ""
replace Mail = MailValueIMAMRegister if Mail==""
replace Mail = "no" if MailCategoryIMAMRegister=="no"

* Table of personnel working in LGA working in State.   

* Enumerate the number of persons registered and number of telephones
bysort state lga Name: egen num_tel = seq()
* Ordinal number of phones that one person has registered with 
tab num_tel, m
* The total number of persons registered is first row in table - num_tel=1. 
* what does it mean here to have up to 43 tel nums? 

sort state lga_code Level Name
* To remove any personnel with more than one phone add 'if num_tel ==1'
list state lga Name Level Post Type if num_tel ==1

* Check all needed variables are present for SITE

tab state, m
tab lga, m
tab SiteID, m 
tab Level , m 
tab Type , m 

* Save database with all registered personnel included
save "C:\TEMP\Working\REG_delete", replace

do "IMAM Weekly Analysis2"



