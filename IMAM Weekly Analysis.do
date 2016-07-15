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
capture gen SiteID = Site_inputValue
* Level 
capture gen Level = Site_inputCategory
* Type 
capture gen Type = TypeCategory
replace Type ="" if Type=="Other"
* if Type (OTP or SC) is recorded for 1st or 2nd level not implementation level, then delete
replace Type ="" if Level =="First" | Level == "Second"
* Post
capture gen Post = Post_impCategory
replace Post = Post_supCategory if Level !="Site"
replace Post ="" if Post=="Other"

* State code
gen state_code = substr(Site_inputValue,1, 2)
gen state = state_code
tostring state_code, replace

* Add names for state and LGA codes
replace state=	"Sokoto" if state==	"33"

* Add names for state and LGA codes
gen lga_code = substr(Site_inputValue,3, 2)
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

* SiteName
destring SiteID, replace force
gen SiteName = ""

replace SiteName = 	"Binji Up-Graded Dispensary"	if SiteID==	3301110001
replace SiteName = 	"General Hospital Binji"		if SiteID==	3301210002
replace SiteName = 	"Birni wari Dispensary"			if SiteID==	3301110003
replace SiteName = 	"Kalgo Dispensary"				if SiteID==	3301110004
replace SiteName = 	"Karani Dispensary"				if SiteID==	3301110005
replace SiteName = 	"Kura Up-Graded Dispensary"		if SiteID==	3301110006
replace SiteName = 	"Dalijam Dispensary"			if SiteID==	3301110007
replace SiteName = 	"Jamali Dispensary"				if SiteID==	3301110008
replace SiteName = 	"Jamali Tsohuwa Dispensary"		if SiteID==	3301110009
replace SiteName = 	"Danmali Dispensary"			if SiteID==	3301110010
replace SiteName = 	"Model PHC Bunkari"				if SiteID==	3301110011
replace SiteName = 	"Fako Dispensary"				if SiteID==	3301110012
replace SiteName = 	"Kandiza Dispensary"			if SiteID==	3301110013
replace SiteName = 	"Gwahitto Dispensary"			if SiteID==	3301110014
replace SiteName = 	"Soro Dispensary"			if SiteID==	3301110015
replace SiteName = 	"Tumuni Dispensary"			if SiteID==	3301110016
replace SiteName = 	"Gawazai Dispensary"		if SiteID==	3301110017
replace SiteName = 	"Matabare Dispensary"		if SiteID==	3301110018
replace SiteName = 	"Yardewu Dispensary"		if SiteID==	3301110019
replace SiteName = 	"Ginjo Dispensary"			if SiteID==	3301110020
replace SiteName = 	"Inname Dispensary"			if SiteID==	3301110021
replace SiteName = 	"Kunkurwa Dispensary"		if SiteID==	3301110022
replace SiteName = 	"Maikulki Up-Graded Dispensary"		if SiteID==	3301110023
replace SiteName = 	"Margai Dispensary"			if SiteID==	3301110024
replace SiteName = 	"Samama Dispensary"			if SiteID==	3301110025
replace SiteName = 	"Tudun Kose Dispensary"		if SiteID==	3301110026
replace SiteName = 	"Gidan Maidebe Dispensary"		if SiteID==	3301110027
replace SiteName = 	"Twaidi Dikko Dispensary	"	if SiteID==	3301110028
replace SiteName = 	"Twaidi Zaidi Dispensary	"	if SiteID==	3301110029
replace SiteName = 	"Abdulsalami Dispensary	"	if SiteID==	3302110001
replace SiteName = 	"Lukuyaw Dispensary	"		if SiteID==	3302110002
replace SiteName = 	"Sifawa Dispensary	"		if SiteID==	3302110003
replace SiteName = 	"Badau Dispensary	"		if SiteID==	3302110004
replace SiteName = 	"Darhela Up-Graded Dispensary	"	if SiteID==	3302110005
replace SiteName = 	"Badawa Dispensary	"		if SiteID==	3302110006
replace SiteName = 	"Bagarawa Dispensary	"	if SiteID==	3302110007
replace SiteName = 	"PHC Bagarawa	"			if SiteID==	3302110008
replace SiteName = 	"Zangalawa Dispensary	"	if SiteID==	3302110009
replace SiteName = 	"Bangi Dispensary	"	if SiteID==	3302110010
replace SiteName = 	"Dabaga Dsipensary	"	if SiteID==	3302110011
replace SiteName = 	"Tulluwa Dispensary	"	if SiteID==	3302110012
replace SiteName = 	"Wumumu Dispensary	"	if SiteID==	3302110013
replace SiteName = 	"Dan Ajwa Dispensary	"	if SiteID==	3302110014
replace SiteName = 	"K/Wwasau"					if SiteID==	3302110015
replace SiteName = 	"Dingyadi Up-Graded Dispensary"	if SiteID==	3302110016
replace SiteName = 	"PHC Dingyadi"	if SiteID==	3302110017
replace SiteName = 	"Gidan Kijo Dispensary	"	if SiteID==	3302110018
replace SiteName = 	"General Hospital Bodinga	"	if SiteID==	3302210019
replace SiteName = 	"Town Dispensary Bodinga	"	if SiteID==	3302110020
replace SiteName = 	"Gidan Tsara Dispensary	"	if SiteID==	3302110021
replace SiteName = 	"Kaura Buba Dispensary	"	if SiteID==	3302110022
replace SiteName = 	"Jabe Dispensary	"	if SiteID==	3302110023
replace SiteName = 	"Jirga Dsipensary	"	if SiteID==	3302110024
replace SiteName = 	"Kaurarmangala Dispensary	"	if SiteID==	3302110025
replace SiteName = 	"Mazangari Dispensary	"	if SiteID==	3302110026
replace SiteName = 	"Modorawa Dispensary	"	if SiteID==	3302110027
replace SiteName = 	"Takatuku Dispensary	"	if SiteID==	3302110028
replace SiteName = 	"PHC Danchadi	"	if SiteID==	3302110029
replace SiteName = 	"Town Dispensary Danchadi	"	if SiteID==	3302110030
replace SiteName = 	"1 Battalion Military Hospital	"	if SiteID==	3303210001
replace SiteName = 	"Shuni Dispensary	"	if SiteID==	3303110002
replace SiteName = 	"Amanawa Lep/General Hosp	"	if SiteID==	3303210003
replace SiteName = 	"Rudu Dispensary	"	if SiteID==	3303110004
replace SiteName = 	"Basic Health Centre Amanawa	"	if SiteID==	3303110005
replace SiteName = 	"Bodai Kaura Dispensary	"	if SiteID==	3303110006
replace SiteName = 	"Bodai Sajo Dispensary	"	if SiteID==	3303110007
replace SiteName = 	"Danbuwa Dispensary	"	if SiteID==	3303110008
replace SiteName = 	"Tsefe Dispensary	"	if SiteID==	3303110009
replace SiteName = 	"Tuntube Dispensary	"	if SiteID==	3303110010
replace SiteName = 	"Kwanawa Dispensary	"	if SiteID==	3303110011
replace SiteName = 	"Dange Up-Graded Dispensary	"	if SiteID==	3303110012
replace SiteName = 	"Model PHC Dange	"	if SiteID==	3303110013
replace SiteName = 	"Marina Dispensary	"	if SiteID==	3303110014
replace SiteName = 	"Fajaldu Dispensary	"	if SiteID==	3303110015
replace SiteName = 	"Dabagin Ardo Up-Graded Disp	"	if SiteID==	3303110016
replace SiteName = 	"Gajara Dispensary	"	if SiteID==	3303110017
replace SiteName = 	"Ge-Ere Dispensary	"	if SiteID==	3303110018
replace SiteName = 	"Wababe Dispensary	"	if SiteID==	3303110019
replace SiteName = 	"Rikina Dispensary	"	if SiteID==	3303110020
replace SiteName = 	"Ruggar Dudu Dispensary	"	if SiteID==	3303110021
replace SiteName = 	"Laffi Dispensary	"	if SiteID==	3303110022
replace SiteName = 	"Staff clinic Rima	"	if SiteID==	3303110023
replace SiteName = 	"Tsafanade Dispensary	"	if SiteID==	3303110024
replace SiteName = 	"Alibawa Community Disp	"	if SiteID==	3304110001
replace SiteName = 	"Gidan Gyado Com Dispensary	"	if SiteID==	3304110002
replace SiteName = 	"PHC Kaffe	"	if SiteID==	3304110003
replace SiteName = 	"General Hospital Gada	"	if SiteID==	3304210004
replace SiteName = 	"Baredi Community Dispensary	"	if SiteID==	3304110005
replace SiteName = 	"Gidan Madugu Comm Disp	"	if SiteID==	3304110006
replace SiteName = 	"Town Dispensary Gada	"	if SiteID==	3304110007
replace SiteName = 	"Dagindi Dispensary	"	if SiteID==	3304110008
replace SiteName = 	"Kaddi Up-Graded Dispensary	"	if SiteID==	3304110009
replace SiteName = 	"PHC Kadadi	"	if SiteID==	3304110010
replace SiteName = 	"Inga boro Dispensary	"	if SiteID==	3304110011
replace SiteName = 	"Kadadi Dispensary	"	if SiteID==	3304110012
replace SiteName = 	"Sagera Dispensary	"	if SiteID==	3304110013
replace SiteName = 	"Gadabo Dispensary	"	if SiteID==	3304110014
replace SiteName = 	"Gidan Hashimu Dispensary	"	if SiteID==	3304110015
replace SiteName = 	"Tsitse Dispensary	"	if SiteID==	3304110016
replace SiteName = 	"Gidan Albakari Dispensary	"	if SiteID==	3304110017
replace SiteName = 	"Illah Dispensary	"	if SiteID==	3304110018
replace SiteName = 	"PHC Dukamaje	"	if SiteID==	3304110019
replace SiteName = 	"Rabamawa Dispensary	"	if SiteID==	3304110020
replace SiteName = 	"Tsagal gale Dispensary	"	if SiteID==	3304110021
replace SiteName = 	"Gidan Amamata Dispensary	"	if SiteID==	3304110022
replace SiteName = 	"Holai Dispensary	"	if SiteID==	3304110023
replace SiteName = 	"Kyadawa Dispensary	"	if SiteID==	3304110024
replace SiteName = 	"PHC Wauru	"	if SiteID==	3304110025
replace SiteName = 	"Safiyal Dispensary	"	if SiteID==	3304110026
replace SiteName = 	"Gidan Dabo Dispensary	"	if SiteID==	3304110027
replace SiteName = 	"Kiri Dispensary	"	if SiteID==	3304110028
replace SiteName = 	"Gilbadi Dispensary	"	if SiteID==	3304110029
replace SiteName = 	"Tsaro Dispensary	"	if SiteID==	3304110030
replace SiteName = 	"Kadassaka Dispensary	"	if SiteID==	3304110031
replace SiteName = 	"Tudun Bulus Dispensary	"	if SiteID==	3304110032
replace SiteName = 	"Kwarma Dispensary	"	if SiteID==	3304110033
replace SiteName = 	"Rafin Duma Dispensary	"	if SiteID==	3304110034
replace SiteName = 	"Tufai Baba Dispensary	"	if SiteID==	3304110035
replace SiteName = 	"Takalmawa Community Disp	"	if SiteID==	3304110036
replace SiteName = 	"Sabon Gida Dispensary	"	if SiteID==	3304110037
replace SiteName = 	"Bare Dispensary	"	if SiteID==	3305110001
replace SiteName = 	"Darbabiya Dispensary	"	if SiteID==	3305110002
replace SiteName = 	"Kojiyo Dispensary	"	if SiteID==	3305110003
replace SiteName = 	"Birjingo Dispensary	"	if SiteID==	3305110004
replace SiteName = 	"Gidan Mata Dispensary	"	if SiteID==	3305110005
replace SiteName = 	"Ganza Dispensary	"	if SiteID==	3305110006
replace SiteName = 	"Boyekai Dispensary	"	if SiteID==	3305110007
replace SiteName = 	"Gamiha Kawara Dispensary	"	if SiteID==	3305110008
replace SiteName = 	"Dantasakko Dsipensary	"	if SiteID==	3305110009
replace SiteName = 	"Danwaru Dispensary	"	if SiteID==	3305110010
replace SiteName = 	"Kamitau Dispensary	"	if SiteID==	3305110011
replace SiteName = 	"Sabon  Gari Dole Dispensary	"	if SiteID==	3305110012
replace SiteName = 	"Kubutta Dispensary	"	if SiteID==	3305110013
replace SiteName = 	"T/G Dole Dispensary	"	if SiteID==	3305110014
replace SiteName = 	"Facilaya Dsipensary	"	if SiteID==	3305110015
replace SiteName = 	"Kaikazzaka Dsipensary	"	if SiteID==	3305110016
replace SiteName = 	"Rimawa Dispensary	"	if SiteID==	3305110017
replace SiteName = 	"Fadarawa Dispensary	"	if SiteID==	3305110018
replace SiteName = 	"Gidan Barau Dispensary	"	if SiteID==	3305110019
replace SiteName = 	"Kwakwazo Dispensary	"	if SiteID==	3305110020
replace SiteName = 	"Miyal Yako Dispensary	"	if SiteID==	3305110021
replace SiteName = 	"Giyawa Dispensary	"	if SiteID==	3305110022
replace SiteName = 	"Gorau Dispensary	"	if SiteID==	3305110023
replace SiteName = 	"Takakume Dispensary	"	if SiteID==	3305110024
replace SiteName = 	"Kagara Dispensary	"	if SiteID==	3305110025
replace SiteName = 	"Illela Dawagari Dispensary	"	if SiteID==	3305110026
replace SiteName = 	"PHC Goronyo	"	if SiteID==	3305110027
replace SiteName = 	"Taloka Dispensary	"	if SiteID==	3305110028
replace SiteName = 	"Illela Huda Dispensary	"	if SiteID==	3305110029
replace SiteName = 	"PHC Shinaka	"	if SiteID==	3305110030
replace SiteName = 	"Tuluske Dispensary	"	if SiteID==	3305110031
replace SiteName = 	"Zamace Dsipensary	"	if SiteID==	3305110032
replace SiteName = 	"Zamace Dsipensary	"	if SiteID==	3305110033
replace SiteName = 	"Bachaka Dispensary	"	if SiteID==	3306110001
replace SiteName = 	"Salewa Dispensary	"	if SiteID==	3306110002
replace SiteName = 	"Boto Dispensary	"	if SiteID==	3306110003
replace SiteName = 	"Yaka Dispensary	"	if SiteID==	3306110004
replace SiteName = 	"Chilas Dispensary	"	if SiteID==	3306110005
replace SiteName = 	"Dangadabro Dispensary	"	if SiteID==	3306110006
replace SiteName = 	"Makuya Dispenary	"	if SiteID==	3306110007
replace SiteName = 	"Bungel Dispensary	"	if SiteID==	3306110008
replace SiteName = 	"Karfen Chana Dispensary	"	if SiteID==	3306110009
replace SiteName = 	"Katsura Dispensary	"	if SiteID==	3306110010
replace SiteName = 	"PHC Kurdula	"	if SiteID==	3306110011
replace SiteName = 	"Darusa Gawo Dispensary	"	if SiteID==	3306110012
replace SiteName = 	"Bare-bari dispensary	"	if SiteID==	3306110013
replace SiteName = 	"Kukoki Dispensary	"	if SiteID==	3306110014
replace SiteName = 	"Jima-Jimi Dispensary	"	if SiteID==	3306110015
replace SiteName = 	"Marake Dispensary	"	if SiteID==	3306110016
replace SiteName = 	"PHC Balle	"	if SiteID==	3306110017
replace SiteName = 	"Rafin kubu Dispensary	"	if SiteID==	3306110018
replace SiteName = 	"PHC Karfen Sarki	"	if SiteID==	3306110019
replace SiteName = 	"Filasko Dispensary	"	if SiteID==	3306110020
replace SiteName = 	"Tullun-Doya Dispensary	"	if SiteID==	3306110021
replace SiteName = 	"Illela Dispensary	"	if SiteID==	3306110022
replace SiteName = 	"Asara Dispensary	"	if SiteID==	3307110001
replace SiteName = 	"Rumbuje Dispensary	"	if SiteID==	3307110002
replace SiteName = 	"Tungar Tudu Biga Dispensary	"	if SiteID==	3307110003
replace SiteName = 	"Attakwanyo Dispensary	"	if SiteID==	3307110004
replace SiteName = 	"Burdi Dispensary	"	if SiteID==	3307110005
replace SiteName = 	"Kangiye Dispensary	"	if SiteID==	3307110006
replace SiteName = 	"Katalla Dispensary	"	if SiteID==	3307110007
replace SiteName = 	"Chimmola Dispensary	"	if SiteID==	3307110008
replace SiteName = 	"Kwankwanbilo Dispensary	"	if SiteID==	3307110009
replace SiteName = 	"Kiliya Dispensary	"	if SiteID==	3307110010
replace SiteName = 	"Dan Abba Dispensary	"	if SiteID==	3307110011
replace SiteName = 	"Salame Dispensary	"	if SiteID==	3307110012
replace SiteName = 	"Galadanchi Dispensary	"	if SiteID==	3307110013
replace SiteName = 	"Gidan Dogaza Dipsensary	"	if SiteID==	3307110014
replace SiteName = 	"Gidan kaya Dispensary	"	if SiteID==	3307110015
replace SiteName = 	"Gwara Dispensary	"	if SiteID==	3307110016
replace SiteName = 	"Kililawa Dispensary	"	if SiteID==	3307110017
replace SiteName = 	"Yar Gada Dispensary	"	if SiteID==	3307110018
replace SiteName = 	"Gigane Up-Graded Dispensary	"	if SiteID==	3307110019
replace SiteName = 	"Meli Dispensary	"	if SiteID==	3307110020
replace SiteName = 	"Sakamaru Dispensary	"	if SiteID==	3307110021
replace SiteName = 	"Tunkura Dispensary	"	if SiteID==	3307110022
replace SiteName = 	"Huchi Dispensary	"	if SiteID==	3307110023
replace SiteName = 	"Fadan Kai Dsipensary	"	if SiteID==	3307110024
replace SiteName = 	"Makina Dispensary	"	if SiteID==	3307110025
replace SiteName = 	"Mamman Suka Dispensary	"	if SiteID==	3307110026
replace SiteName = 	"Chancha Disppensary 	"	if SiteID==	3307110027
replace SiteName = 	"Ranganda Dispensary	"	if SiteID==	3307110028
replace SiteName = 	"RHC Gwadabawa	"	if SiteID==	3307110029
replace SiteName = 	"Tudun Doki Dispensary	"	if SiteID==	3307110030
replace SiteName = 	"Tambagarka Dispensary	"	if SiteID==	3307110031
replace SiteName = 	"Kalaba Dsiepnsary	"	if SiteID==	3307110032
replace SiteName = 	"Wadai Dispensary	"	if SiteID==	3307110033
replace SiteName = 	"Bamana Dispensary	"	if SiteID==	3307110034
replace SiteName = 	"Mammande Dispensary	"	if SiteID==	3307110035
replace SiteName = 	"Zugana Dispensary	"	if SiteID==	3307110036
replace SiteName = 	"Amarawa Dispensary	"	if SiteID==	3308110001
replace SiteName = 	"Aminchi Nursing Home	"	if SiteID==	3308110002
replace SiteName = 	"Daboe Clinic & Maternity	"	if SiteID==	3308110003
replace SiteName = 	"General Hospital Illela	"	if SiteID==	3308210004
replace SiteName = 	"Nasiha Clinic	"	if SiteID==	3308210005
replace SiteName = 	"Sonane Dispensary	"	if SiteID==	3308110006
replace SiteName = 	"Staff clinic 	"	if SiteID==	3308110007
replace SiteName = 	"Town Dsipensary	"	if SiteID==	3308110008
replace SiteName = 	"Tudun Gudale Dispensary	"	if SiteID==	3308110009
replace SiteName = 	"Araba Up-Graded Dispensary	"	if SiteID==	3308110010
replace SiteName = 	"Bakin Dutsi Dispensary	"	if SiteID==	3308110011
replace SiteName = 	"Dan Boka Dispensary	"	if SiteID==	3308110012
replace SiteName = 	"Dango Dispensary	"	if SiteID==	3308110013
replace SiteName = 	"Basanta Dispensary	"	if SiteID==	3308110014
replace SiteName = 	"Gaidau Dispensary	"	if SiteID==	3308110015
replace SiteName = 	"Gidan katta Up-Graded Dispensary	"	if SiteID==	3308110016
replace SiteName = 	"Buwade Dispensary	"	if SiteID==	3308110017
replace SiteName = 	"Damba Up-Graded Dispensary	"	if SiteID==	3308110018
replace SiteName = 	"Gudun Gudun Dispensary	"	if SiteID==	3308110019
replace SiteName = 	"Tarke Dispensary	"	if SiteID==	3308110020
replace SiteName = 	"Tsauna Dispensary	"	if SiteID==	3308110021
replace SiteName = 	"Tumbulumkum Dispensary	"	if SiteID==	3308110022
replace SiteName = 	"Darna Kiliya Dispensary	"	if SiteID==	3308110023
replace SiteName = 	"Darna Sabon Gari Dispensary	"	if SiteID==	3308110024
replace SiteName = 	"Gidan Tudu Dispensary	"	if SiteID==	3308110025
replace SiteName = 	"Mullela Dispensary	"	if SiteID==	3308110026
replace SiteName = 	"Dabagin Tankari Dispensary	"	if SiteID==	3308110027
replace SiteName = 	"Darna Tsolawa Dispensary	"	if SiteID==	3308110028
replace SiteName = 	"Garu Up-Graded Dispensary	"	if SiteID==	3308110029
replace SiteName = 	"Tsangalandam Dispensary	"	if SiteID==	3308110030
replace SiteName = 	"Gidan bango Dispensary	"	if SiteID==	3308110031
replace SiteName = 	"Tozai Dispensary	"	if SiteID==	3308110032
replace SiteName = 	"Ambarura Up-Graded Dispensary	"	if SiteID==	3308110033
replace SiteName = 	"Gidan Hamma Dispensary	"	if SiteID==	3308110034
replace SiteName = 	"Here Dispensary	"	if SiteID==	3308110035
replace SiteName = 	"Jagai Dispensary	"	if SiteID==	3308110036
replace SiteName = 	"Jema Dispensary	"	if SiteID==	3308110037
replace SiteName = 	"Kalmalo Dispensary	"	if SiteID==	3308110038
replace SiteName = 	"Runji Dispensary	"	if SiteID==	3308110039
replace SiteName = 	"Lafani Dispensary	"	if SiteID==	3308110040
replace SiteName = 	"Gidan Chiwake Dispensary	"	if SiteID==	3308110041
replace SiteName = 	"Rungumawar  Gatti  Dispensary	"	if SiteID==	3308110042
replace SiteName = 	"Rungumawar  Jao Dispensary	"	if SiteID==	3308110043
replace SiteName = 	"Harigawa Dispensary	"	if SiteID==	3308110044
replace SiteName = 	"Adarawa Dispensary	"	if SiteID==	3309110001
replace SiteName = 	"Chohi Dispensary	"	if SiteID==	3309110002
replace SiteName = 	"Gamaroji Community Dispensary	"	if SiteID==	3309110003
replace SiteName = 	"KaiKairu Dispensary	"	if SiteID==	3309110004
replace SiteName = 	"Tidibali Dispensary	"	if SiteID==	3309110005
replace SiteName = 	"Katanga Dispensary	"	if SiteID==	3309110006
replace SiteName = 	"Dan Adamma Community Dispensary	"	if SiteID==	3309110007
replace SiteName = 	"Satiru Up-graded Dispensary	"	if SiteID==	3309110008
replace SiteName = 	"Tozai Dispensary	"	if SiteID==	3309110009
replace SiteName = 	"Bargaja  Dispensary	"	if SiteID==	3309110010
replace SiteName = 	"Danzanke Up-graded Dispensary	"	if SiteID==	3309110011
replace SiteName = 	"Gazau Dispensary	"	if SiteID==	3309110012
replace SiteName = 	"Kalage Community Dispensary	"	if SiteID==	3309110013
replace SiteName = 	"Modachi Dispensary	"	if SiteID==	3309110014
replace SiteName = 	"Dan Yada Dispensary	"	if SiteID==	3309110015
replace SiteName = 	"Gari Ubandawaki Comm. Disp	"	if SiteID==	3309110016
replace SiteName = 	"Tafkin Fili Up-graded Dispensary	"	if SiteID==	3309110017
replace SiteName = 	"Yanfako Dispensary	"	if SiteID==	3309110018
replace SiteName = 	"Gebe Upgraded Dispensary	"	if SiteID==	3309110019
replace SiteName = 	"Manawa Dispensary	"	if SiteID==	3309110020
replace SiteName = 	"Sabon Gari Dangwandi Community Dispensary	"	if SiteID==	3309110021
replace SiteName = 	"Sabon Gari Kamarawa Dispensary	"	if SiteID==	3309110022
replace SiteName = 	"PHC Bafarawa	"	if SiteID==	3309110023
replace SiteName = 	"Suruddubu Dispensary	"	if SiteID==	3309110024
replace SiteName = 	"General  Hospital  Isa	"	if SiteID==	3309210025
replace SiteName = 	"MCH  Isa	"	if SiteID==	3309210026
replace SiteName = 	"Gidan Dikko Dispensary	"	if SiteID==	3309110027
replace SiteName = 	"Girnashe Dispensary	"	if SiteID==	3309110028
replace SiteName = 	"Tsabre Dispensary	"	if SiteID==	3309110029
replace SiteName = 	"Gumal Up-graded Dispensary	"	if SiteID==	3309110030
replace SiteName = 	"Shallah Dispensary	"	if SiteID==	3309110031
replace SiteName = 	"Turba Dispensary	"	if SiteID==	3309110032
replace SiteName = 	"Kaurar Mota Up-graded Dispensary	"	if SiteID==	3309110033
replace SiteName = 	"Kwanar Isa  community Dispensary	"	if SiteID==	3309110034
replace SiteName = 	"Tudunwada Up-graded Dispensary	"	if SiteID==	3309110035
replace SiteName = 	"Fakku Up-Graded Dispensary	"	if SiteID==	3310110001
replace SiteName = 	"Rara Dispensary	"	if SiteID==	3310110002
replace SiteName = 	"Girkau Up-Graded Dispensary	"	if SiteID==	3310110003
replace SiteName = 	"Jabga Dispensary	"	if SiteID==	3310110004
replace SiteName = 	"Zugu Dispensary	"	if SiteID==	3310110005
replace SiteName = 	"Jigawa dispensary	"	if SiteID==	3310110006
replace SiteName = 	"Sabon Birni Dispensary	"	if SiteID==	3310110007
replace SiteName = 	"Sangi Dispensary	"	if SiteID==	3310110008
replace SiteName = 	"Jigiri Dispensary	"	if SiteID==	3310110009
replace SiteName = 	"Karma Dispensary	"	if SiteID==	3310110010
replace SiteName = 	"Gadacce Dispensary	"	if SiteID==	3310110011
replace SiteName = 	"Margai Dispensary	"	if SiteID==	3310110012
replace SiteName = 	"General Hospital Kebbe	"	if SiteID==	3310210013
replace SiteName = 	"Kebbe Up-Graded Dispensary	"	if SiteID==	3310110014
replace SiteName = 	"Umbutu Dispensary	"	if SiteID==	3310110015
replace SiteName = 	"Kuchi Up-Graded Dispensary	"	if SiteID==	3310110016
replace SiteName = 	"PHC Kuchi	"	if SiteID==	3310110017
replace SiteName = 	"Ungushi Dispensary	"	if SiteID==	3310110018
replace SiteName = 	"Nasagudu Dispensary	"	if SiteID==	3310110019
replace SiteName = 	"Kunduttu Dispensary	"	if SiteID==	3310110020
replace SiteName = 	"Maikurfuna Dispensary 	"	if SiteID==	3310110021
replace SiteName = 	"Dukura Dispensary	"	if SiteID==	3310110022
replace SiteName = 	"Sha Alwashi Dispensary	"	if SiteID==	3310110023
replace SiteName = 	"Basansan community Dispensary	"	if SiteID==	3311110001
replace SiteName = 	"Lemi Dispensary	"	if SiteID==	3311110002
replace SiteName = 	"Comprehensive Health Center Kware	"	if SiteID==	3311110003
replace SiteName = 	"Kalalawa Dispensary 	"	if SiteID==	3311110004
replace SiteName = 	"Kasgada Dispensary	"	if SiteID==	3311110005
replace SiteName = 	"Durbawa Up-Graded Dispensary	"	if SiteID==	3311110006
replace SiteName = 	"Federal Psychiatric Hospital	"	if SiteID==	3311310007
replace SiteName = 	"PHC Kware	"	if SiteID==	3311110008
replace SiteName = 	"Ruggar Liman Dispensary	"	if SiteID==	3311110009
replace SiteName = 	"Runji Dispensary	"	if SiteID==	3311110010
replace SiteName = 	"Federal Science School Clinic 	"	if SiteID==	3311110011
replace SiteName = 	"Gundunga  Dispensary	"	if SiteID==	3311110012
replace SiteName = 	"Ihi Dispensary	"	if SiteID==	3311110013
replace SiteName = 	"Model PHC Balkore	"	if SiteID==	3311110014
replace SiteName = 	"T/Galadima Dispensary	"	if SiteID==	3311110015
replace SiteName = 	"Gidan Maikara Dispensary	"	if SiteID==	3311110016
replace SiteName = 	"Hamma Ali Up-Graded Dispensary	"	if SiteID==	3311110017
replace SiteName = 	"Hausawa Dispensary	"	if SiteID==	3311110018
replace SiteName = 	"Karandai Dispensary	"	if SiteID==	3311110019
replace SiteName = 	"Marbawa Upgraded Dispensary	"	if SiteID==	3311110020
replace SiteName = 	"Kabanga Dispensary	"	if SiteID==	3311110021
replace SiteName = 	"Malamawa Adada  Dispensary	"	if SiteID==	3311110022
replace SiteName = 	"Mallamawa Yari Dispensary	"	if SiteID==	3311110023
replace SiteName = 	"Tunga Dispensary	"	if SiteID==	3311110024
replace SiteName = 	"Siri Jalo Dispensary	"	if SiteID==	3311110025
replace SiteName = 	"Tsaki Community Dispensary	"	if SiteID==	3311110026
replace SiteName = 	"Lambo Community Dispensary	"	if SiteID==	3311110027
replace SiteName = 	"Wallakae Dispensary	"	if SiteID==	3311110028
replace SiteName = 	"Zammau Dispensary	"	if SiteID==	3311110029
replace SiteName = 	"PHC Gandi	"	if SiteID==	3312110001
replace SiteName = 	"Alikiru Dispensary	"	if SiteID==	3312110002
replace SiteName = 	"Dankarmawa Dispensary	"	if SiteID==	3312110003
replace SiteName = 	"Angamba Dispensary	"	if SiteID==	3312110004
replace SiteName = 	"Gidan Buwai Dispensary	"	if SiteID==	3312110005
replace SiteName = 	"Gododdi Dispensary	"	if SiteID==	3312110006
replace SiteName = 	"Kurya Dispensary	"	if SiteID==	3312110007
replace SiteName = 	"Maikujera Dispensary	"	if SiteID==	3312110008
replace SiteName = 	"Riji Dispensary	"	if SiteID==	3312110009
replace SiteName = 	"Gidan Doka Dispensary	"	if SiteID==	3312110010
replace SiteName = 	"Burmawa Dispensary	"	if SiteID==	3312110011
replace SiteName = 	"Gawakuke Dispensary	"	if SiteID==	3312110012
replace SiteName = 	"Tofa Dispensary	"	if SiteID==	3312110013
replace SiteName = 	"General Hospital Rabah	"	if SiteID==	3312210014
replace SiteName = 	"Town Dispensary Rabah	"	if SiteID==	3312110015
replace SiteName = 	"PHC Rara	"	if SiteID==	3312110016
replace SiteName = 	"Sabaru Dispensary	"	if SiteID==	3312110017
replace SiteName = 	"Tursa Dispensary	"	if SiteID==	3312110018
replace SiteName = 	"Tsamiya Dispensary	"	if SiteID==	3312110019
replace SiteName = 	"Yartsakuwa Dispensary	"	if SiteID==	3312110020
replace SiteName = 	"Badama Dispensary	"	if SiteID==	3312110021
replace SiteName = 	"Dudu-Barade Dispensary	"	if SiteID==	3312110022
replace SiteName = 	"Gidan Almajir Dispensary	"	if SiteID==	3312110023
replace SiteName = 	"Gidan Dan'Ayya Dispensary	"	if SiteID==	3312110024
replace SiteName = 	"Rawkwamni Dispensary	"	if SiteID==	3312110025
replace SiteName = 	"Sabon Gari	"	if SiteID==	3312110026
replace SiteName = 	"Tabanni Dispensary	"	if SiteID==	3312110027
replace SiteName = 	"Warwanna Dispensary	"	if SiteID==	3312110028
replace SiteName = 	"Bachaka Dispensary	"	if SiteID==	3313110001
replace SiteName = 	"D/Kware Dispensary	"	if SiteID==	3313110002
replace SiteName = 	"Gidan Umaru Dispensary	"	if SiteID==	3313110003
replace SiteName = 	"Kalage Dispensary	"	if SiteID==	3313110004
replace SiteName = 	"Kyara Dispensary 	"	if SiteID==	3313110005
replace SiteName = 	"T/Tsaba Dispensary	"	if SiteID==	3313110006
replace SiteName = 	"Tara Dispensary	"	if SiteID==	3313110007
replace SiteName = 	"Bambadawa Dispensary	"	if SiteID==	3313110008
replace SiteName = 	"Burkusuma Dispensary	"	if SiteID==	3313110009
replace SiteName = 	"Gangara Dispensary	"	if SiteID==	3313110010
replace SiteName = 	"Dama Dispensary	"	if SiteID==	3313110011
replace SiteName = 	"Dan Kura Dispensary	"	if SiteID==	3313110012
replace SiteName = 	"Dabugi Dispensary	"	if SiteID==	3313110013
replace SiteName = 	"Dakwaro Dispensary	"	if SiteID==	3313110014
replace SiteName = 	"Kurawa Dispensary	"	if SiteID==	3313110015
replace SiteName = 	"Dan Maliki Dispensary	"	if SiteID==	3313110016
replace SiteName = 	"Kalgo Dispensary	"	if SiteID==	3313110017
replace SiteName = 	"Teke Dispensary	"	if SiteID==	3313110018
replace SiteName = 	"Dantudu Dispensary	"	if SiteID==	3313110019
replace SiteName = 	"Lanjego Dispensary	"	if SiteID==	3313110020
replace SiteName = 	"Lanjinge Dispensary	"	if SiteID==	3313110021
replace SiteName = 	"Garin Gado Dispensary	"	if SiteID==	3313110022
replace SiteName = 	"Gayya Dakwari Dispensary	"	if SiteID==	3313110023
replace SiteName = 	"Kiratawa Dispensary	"	if SiteID==	3313110024
replace SiteName = 	"Magarau Dispensary	"	if SiteID==	3313110025
replace SiteName = 	"Mallamawa Dispensary	"	if SiteID==	3313110026
replace SiteName = 	"Sangarawa Dispensary	"	if SiteID==	3313110027
replace SiteName = 	"Ungwar Lalle Dispensary	"	if SiteID==	3313110028
replace SiteName = 	"Yar Bulutu Dispensary	"	if SiteID==	3313110029
replace SiteName = 	"Garin Idi dispensary	"	if SiteID==	3313110030
replace SiteName = 	"Kwatsal Dispensary	"	if SiteID==	3313110031
replace SiteName = 	"Nasara Clinic Sabon Birni	"	if SiteID==	3313110032
replace SiteName = 	"PHC Sabon Birni	"	if SiteID==	3313110033
replace SiteName = 	"Son Allah Clinic	"	if SiteID==	3313110034
replace SiteName = 	"Garin Abara Dispensary	"	if SiteID==	3313110035
replace SiteName = 	"Gawo Dispensary	"	if SiteID==	3313110036
replace SiteName = 	"Tsamaye Dispensary	"	if SiteID==	3313110037
replace SiteName = 	"Labau Dispensary	"	if SiteID==	3313110038
replace SiteName = 	"Magira Dispensary	"	if SiteID==	3313110039
replace SiteName = 	"Model PHC Gatawa	"	if SiteID==	3313110040
replace SiteName = 	"Makuwana Dispensary	"	if SiteID==	3313110041
replace SiteName = 	"Aggur Dispensary	"	if SiteID==	3314110001
replace SiteName = 	"Kajiji Up-Graded Dispensary	"	if SiteID==	3314110002
replace SiteName = 	"Kesoje Dispensary	"	if SiteID==	3314110003
replace SiteName = 	"Ruggar Dispensary	"	if SiteID==	3314110004
replace SiteName = 	"Dan Baro Dispensary Horo	"	if SiteID==	3314110005
replace SiteName = 	"Ginga Dispensary	"	if SiteID==	3314110006
replace SiteName = 	"Model PHC Horo	"	if SiteID==	3314110007
replace SiteName = 	"Dandin Mahe Up-Graded Dispensary	"	if SiteID==	3314110008
replace SiteName = 	"Mabera Dispensary	"	if SiteID==	3314110009
replace SiteName = 	"Ruggar Mallam Dispensary	"	if SiteID==	3314110010
replace SiteName = 	"Darin Guru Dispensary	"	if SiteID==	3314110011
replace SiteName = 	"Gidan Tudu Dispensary	"	if SiteID==	3314110012
replace SiteName = 	"Tungar Barki Dispensary	"	if SiteID==	3314110013
replace SiteName = 	"Gam-Gam Dispensary	"	if SiteID==	3314110014
replace SiteName = 	"Doruwa Dispensary	"	if SiteID==	3314110015
replace SiteName = 	"Jandutsi Dispensary	"	if SiteID==	3314110016
replace SiteName = 	"Lambara Dsipensary	"	if SiteID==	3314110017
replace SiteName = 	"Mandera Dispensary	"	if SiteID==	3314110018
replace SiteName = 	"Jaredi Dispensary	"	if SiteID==	3314110019
replace SiteName = 	"Bullan Yaki Dispensary	"	if SiteID==	3314110020
replace SiteName = 	"Kalangu Dispensary	"	if SiteID==	3314110021
replace SiteName = 	"PHC Sanyinnawal Dispensary	"	if SiteID==	3314110022
replace SiteName = 	"Runji Kaka Dispensary	"	if SiteID==	3314110023
replace SiteName = 	"Sullubawa Dispensary	"	if SiteID==	3314110024
replace SiteName = 	"Kambama Up-Graded Dispensary	"	if SiteID==	3314110025
replace SiteName = 	"PHC Shagari	"	if SiteID==	3314110026
replace SiteName = 	"Wanke Dispensary	"	if SiteID==	3314110027
replace SiteName = 	"Chofal Dispensary	"	if SiteID==	3315110001
replace SiteName = 	"Gaukai Dispensary	"	if SiteID==	3315110002
replace SiteName = 	"Dankala Dsipensary	"	if SiteID==	3315110003
replace SiteName = 	"Kaya Dispensary	"	if SiteID==	3315110004
replace SiteName = 	"Zarengo Dispensary	"	if SiteID==	3315110005
replace SiteName = 	"PHC Gande	"	if SiteID==	3315110006
replace SiteName = 	"G.Magaji Dispensary	"	if SiteID==	3315110007
replace SiteName = 	"Male Dispensary	"	if SiteID==	3315110008
replace SiteName = 	"Galadi Dispensary	"	if SiteID==	3315110009
replace SiteName = 	"Kwagyal Dispensary	"	if SiteID==	3315110010
replace SiteName = 	"Rundi Dispensary	"	if SiteID==	3315110011
replace SiteName = 	"Betare Dispensary	"	if SiteID==	3315110012
replace SiteName = 	"Katami Up-Graded Dispensary	"	if SiteID==	3315110013
replace SiteName = 	"Gandanbe Dispensary	"	if SiteID==	3315110014
replace SiteName = 	"Tanera Dispensary	"	if SiteID==	3315110015
replace SiteName = 	"Tungar Isah Dispensary	"	if SiteID==	3315110016
replace SiteName = 	"Ruggar Fulani Dispensary	"	if SiteID==	3315110017
replace SiteName = 	"Gujiya Dispensary	"	if SiteID==	3315110018
replace SiteName = 	"Gunki Dispensary	"	if SiteID==	3315110019
replace SiteName = 	"Marafa Dispensary	"	if SiteID==	3315110020
replace SiteName = 	"Gungu Dispensary	"	if SiteID==	3315110021
replace SiteName = 	"Danjawa Dispensary	"	if SiteID==	3315110022
replace SiteName = 	"Jekanadu Dispensary	"	if SiteID==	3315110023
replace SiteName = 	"Kubodu Dispensary	"	if SiteID==	3315110024
replace SiteName = 	"Shabra Dispensary	"	if SiteID==	3315110025
replace SiteName = 	"Kubodu B	"	if SiteID==	3315110026
replace SiteName = 	"Labani Dispensary	"	if SiteID==	3315110027
replace SiteName = 	"Maje Dispensary	"	if SiteID==	3315110028
replace SiteName = 	"Tungar Abdu Dispensary	"	if SiteID==	3315110029
replace SiteName = 	"PHC Silame	"	if SiteID==	3315110030
replace SiteName = 	"Tozo Dispensary	"	if SiteID==	3315110031
replace SiteName = 	"Gabbuwa Dispensary	"	if SiteID==	3315110032
replace SiteName = 	"Alkamawa Basic Health Clinic	"	if SiteID==	3316110001
replace SiteName = 	"Helele  Basic Health Clinic	"	if SiteID==	3316110002
replace SiteName = 	"Assada Dispensary	"	if SiteID==	3316110003
replace SiteName = 	"Central Market Clinic	"	if SiteID==	3316110004
replace SiteName = 	"Kofar kade Basic Health Clinic	"	if SiteID==	3316110005
replace SiteName = 	"Sokoto Clinic	"	if SiteID==	3316220006
replace SiteName = 	"Rumbunkawa Basic Health Clinic	"	if SiteID==	3316110007
replace SiteName = 	"Kofar Rini Basic Health Clinic	"	if SiteID==	3316110008
replace SiteName = 	"Runji Sambo Basaic Health Clinic	"	if SiteID==	3316110009
replace SiteName = 	"Noma Hospital	"	if SiteID==	3316210010
replace SiteName = 	"Sultan Palace Clinic	"	if SiteID==	3316110011
replace SiteName = 	"Women and Children Welfare Clinic	"	if SiteID==	3316210012
replace SiteName = 	"Rini Tawaye Clinic	"	if SiteID==	3316110013
replace SiteName = 	"Holy Family Clinic	"	if SiteID==	3316210014
replace SiteName = 	"Alfijir  Specialist hospital	"	if SiteID==	3317220001
replace SiteName = 	"Marina Clinic	"	if SiteID==	3317220002
replace SiteName = 	"Tudunwada Clinic	"	if SiteID==	3317110003
replace SiteName = 	"Anas Private Hospital	"	if SiteID==	3317220004
replace SiteName = 	"Standard Hospital	"	if SiteID==	3317220005
replace SiteName = 	"Gidan Masau Dispensary	"	if SiteID==	3317110006
replace SiteName = 	"Gagi Basic health Clinic	"	if SiteID==	3317110007
replace SiteName = 	"Devine Health Clinic	"	if SiteID==	3317220008
replace SiteName = 	"Mabera Mujaya Dispensary	"	if SiteID==	3317110009
replace SiteName = 	"Freehand Specialist Hospital	"	if SiteID==	3317220010
replace SiteName = 	"Gidan Dahala Dispensary	"	if SiteID==	3317110011
replace SiteName = 	"Mabera Basic Health Clinic	"	if SiteID==	3317110012
replace SiteName = 	"Police Clinic	"	if SiteID==	3317110013
replace SiteName = 	"Saraki Specialist Hospital	"	if SiteID==	3317220014
replace SiteName = 	"Sheperd Clinic	"	if SiteID==	3317220015
replace SiteName = 	"Wali Bako Clinic	"	if SiteID==	3317220016
replace SiteName = 	"Maryam Abacha Women & Children Hospital	"	if SiteID==	3317210017
replace SiteName = 	"Godiya Clinic	"	if SiteID==	3317220018
replace SiteName = 	"Sahel Specialist Hospital	"	if SiteID==	3317220019
replace SiteName = 	"Aliyu Jodi Clinic	"	if SiteID==	3317220020
replace SiteName = 	"Hussein Medical Center	"	if SiteID==	3317220021
replace SiteName = 	"Hamdala Clinic	"	if SiteID==	3317220022
replace SiteName = 	"Yar Akija basic Health Clinic	"	if SiteID==	3317110023
replace SiteName = 	"Zafari Hospital	"	if SiteID==	3317220024
replace SiteName = 	"Karaye Clinic	"	if SiteID==	3317220025
replace SiteName = 	"PPFN Clinic	"	if SiteID==	3317110026
replace SiteName = 	"Rijiya Clinic	"	if SiteID==	3317220027
replace SiteName = 	"Specialist Hospital, Sokoto	"	if SiteID==	3317210028
replace SiteName = 	"Toraro Clinic	"	if SiteID==	3317220029
replace SiteName = 	"Bagida Dispensary	"	if SiteID==	3318110001
replace SiteName = 	"Danmadi Dispensary	"	if SiteID==	3318110002
replace SiteName = 	"Dogon Marke Dispensary	"	if SiteID==	3318110003
replace SiteName = 	"Ganuwa Dispensary	"	if SiteID==	3318110004
replace SiteName = 	"Bancho Dispensary	"	if SiteID==	3318110005
replace SiteName = 	"General Hospital  Dogon Daji	"	if SiteID==	3318210006
replace SiteName = 	"Kalgo Magaji Dispensary	"	if SiteID==	3318110007
replace SiteName = 	"Maikada Dispensary	"	if SiteID==	3318110008
replace SiteName = 	"MaiKade Dispensary	"	if SiteID==	3318110009
replace SiteName = 	"Salah Dispensary	"	if SiteID==	3318110010
replace SiteName = 	"Town Dispensary Dogon Daji	"	if SiteID==	3318110011
replace SiteName = 	"Nabaguda Community Dispensary	"	if SiteID==	3318110012
replace SiteName = 	"Sabawa Dispensary	"	if SiteID==	3318110013
replace SiteName = 	"Kaura Dispensary	"	if SiteID==	3318110014
replace SiteName = 	"Faga Dispensary	"	if SiteID==	3318110015
replace SiteName = 	"Model PHC Faga	"	if SiteID==	3318110016
replace SiteName = 	"Bashire Up-Graded Dispensary	"	if SiteID==	3318110017
replace SiteName = 	"Masu dispensary	"	if SiteID==	3318110018
replace SiteName = 	"Modo Dispensary	"	if SiteID==	3318110019
replace SiteName = 	"PHC Jabo	"	if SiteID==	3318110020
replace SiteName = 	"Charai Dispensary	"	if SiteID==	3318110021
replace SiteName = 	"Hiliya Dispensary	"	if SiteID==	3318110022
replace SiteName = 	"G/salodi Dispensary	"	if SiteID==	3318110023
replace SiteName = 	"H/Guraye Dispensary	"	if SiteID==	3318110024
replace SiteName = 	"Kagara Dispensary 	"	if SiteID==	3318110025
replace SiteName = 	"Bangala Dispensary	"	if SiteID==	3318110026
replace SiteName = 	"Gambuwa Dispensary	"	if SiteID==	3318110027
replace SiteName = 	"Garan Dispensary	"	if SiteID==	3318110028
replace SiteName = 	"Goshe Dispensary	"	if SiteID==	3318110029
replace SiteName = 	"Gudun Dispensary	"	if SiteID==	3318110030
replace SiteName = 	"General Hospital Tambuwal	"	if SiteID==	3318210031
replace SiteName = 	"PHC Tambuwal	"	if SiteID==	3318110032
replace SiteName = 	"Shinfiri Dispensary	"	if SiteID==	3318110033
replace SiteName = 	"Romo Dispensary	"	if SiteID==	3318110034
replace SiteName = 	"Romon Liman Dispensary	"	if SiteID==	3318110035
replace SiteName = 	"Illoje Dispensary	"	if SiteID==	3318110036
replace SiteName = 	"Bakaya Dispensary	"	if SiteID==	3318110037
replace SiteName = 	"Madacci  Community Dispensary	"	if SiteID==	3318110038
replace SiteName = 	"Kaya Dispensary	"	if SiteID==	3318110039
replace SiteName = 	"Barga Dispensary	"	if SiteID==	3318110040
replace SiteName = 	"PHC Sayinna	"	if SiteID==	3318110041
replace SiteName = 	"Saida Dispensary	"	if SiteID==	3318110042
replace SiteName = 	"Tandamare Dispensary	"	if SiteID==	3318110043
replace SiteName = 	"Buwade Dispensary	"	if SiteID==	3318110044
replace SiteName = 	"Tsiwa dispensary	"	if SiteID==	3318110045
replace SiteName = 	"Ungwar D/Kande Dispensary	"	if SiteID==	3318110046
replace SiteName = 	"Gozama dispensary	"	if SiteID==	3318110047
replace SiteName = 	"Tunga Community dispensary	"	if SiteID==	3318110048
replace SiteName = 	"Gambu dispensary	"	if SiteID==	3318110049
replace SiteName = 	"Alela Dispensary	"	if SiteID==	3319110001
replace SiteName = 	"Bararahe Up-graded Dispensary	"	if SiteID==	3319110002
replace SiteName = 	"Kwaraka Dispensary	"	if SiteID==	3319110003
replace SiteName = 	"Rini Dispensary	"	if SiteID==	3319110004
replace SiteName = 	"Sakkwai Up-graded Dispensary	"	if SiteID==	3319110005
replace SiteName = 	"Alkasum Dispensary	"	if SiteID==	3319110006
replace SiteName = 	"Kandam Dispensary	"	if SiteID==	3319110007
replace SiteName = 	"Mano Dispensary	"	if SiteID==	3319110008
replace SiteName = 	"Wasaniya Dispensary	"	if SiteID==	3319110009
replace SiteName = 	"Baidi Dispensary	"	if SiteID==	3319110010
replace SiteName = 	"General Hospital Tangaza	"	if SiteID==	3319210011
replace SiteName = 	"Gurdam Up-graded Dispensary	"	if SiteID==	3319110012
replace SiteName = 	"Labsani Dispensary	"	if SiteID==	3319110013
replace SiteName = 	"Town Dispensary Tangaza	"	if SiteID==	3319110014
replace SiteName = 	"Gidan Dadi Up-graded Dispensary	"	if SiteID==	3319110015
replace SiteName = 	"PHC Gidan madi	"	if SiteID==	3319110016
replace SiteName = 	"Gidima Dispensary	"	if SiteID==	3319110017
replace SiteName = 	"Kalanjeni Dispensary	"	if SiteID==	3319110018
replace SiteName = 	"Kaura Dispensary	"	if SiteID==	3319110019
replace SiteName = 	"Araba Dispensary	"	if SiteID==	3319110020
replace SiteName = 	"Kwacce Huro Dispensary	"	if SiteID==	3319110021
replace SiteName = 	"Kwanawa Up-graded Dispensary	"	if SiteID==	3319110022
replace SiteName = 	"Ginjo Dispensary	"	if SiteID==	3319110023
replace SiteName = 	"Masallachi  Dispensary	"	if SiteID==	3319110024
replace SiteName = 	"Mogonho Up-graded Dispensary	"	if SiteID==	3319110025
replace SiteName = 	"Sanyinna Dispensary	"	if SiteID==	3319110026
replace SiteName = 	"Takkau Dispensary	"	if SiteID==	3319110027
replace SiteName = 	"Gandaba Dispensary	"	if SiteID==	3319110028
replace SiteName = 	"Raka Up-graded Dispensary	"	if SiteID==	3319110029
replace SiteName = 	"Manja Up-graded Dispensary	"	if SiteID==	3319110030
replace SiteName = 	"PHC Ruwa Wuri	"	if SiteID==	3319110031
replace SiteName = 	"Sarma  A Dispensary	"	if SiteID==	3319110032
replace SiteName = 	"Sarma  B Dispensary	"	if SiteID==	3319110033
replace SiteName = 	"Tunigara Dispensary	"	if SiteID==	3319110034
replace SiteName = 	"Salewa Dispensary	"	if SiteID==	3319110035
replace SiteName = 	"Bauni Up-graded Dispensary	"	if SiteID==	3319110036
replace SiteName = 	"Zurmuku Dispensary	"	if SiteID==	3319110037
replace SiteName = 	"Bimasa Dispensary	"	if SiteID==	332011001
replace SiteName = 	"Dorawa Dispensary	"	if SiteID==	332011002
replace SiteName = 	"Gidan kare Dispensary	"	if SiteID==	332011003
replace SiteName = 	"Dangulbi Dispensary	"	if SiteID==	332011004
replace SiteName = 	"Duma Dispensary	"	if SiteID==	332011005
replace SiteName = 	"Fura Girke Dispensary	"	if SiteID==	332011006
replace SiteName = 	"Garbe Kanni Dispensary	"	if SiteID==	332011007
replace SiteName = 	"General Hospital Tureta	"	if SiteID==	332021008
replace SiteName = 	"Town Dispensary Tureta	"	if SiteID==	332011009
replace SiteName = 	"Rafin Bude Dispensary	"	if SiteID==	332011010
replace SiteName = 	"Tsamiya Up-Graded Dispensary	"	if SiteID==	332011011
replace SiteName = 	"Gidan Dangiwa Dispensary	"	if SiteID==	332011012
replace SiteName = 	"Gidan Garkuwa	"	if SiteID==	332011013
replace SiteName = 	"Lambar Tureta Up-Graded Dispensary	"	if SiteID==	332011014
replace SiteName = 	"Galadima Dispensary	"	if SiteID==	332011015
replace SiteName = 	"Kawara Dispensary	"	if SiteID==	332011016
replace SiteName = 	"Kuruwa Dispensary	"	if SiteID==	332011017
replace SiteName = 	"Kwarare Dispensary	"	if SiteID==	332011018
replace SiteName = 	"Lofa Dispensary	"	if SiteID==	332011019
replace SiteName = 	"Randa Dispensary	"	if SiteID==	332011020
replace SiteName = 	"Arkilla Basic Health Clinic	"	if SiteID==	3321110001
replace SiteName = 	"Government House Clinic	"	if SiteID==	3321110002
replace SiteName = 	"Guiwa Community Dispensary	"	if SiteID==	3321110003
replace SiteName = 	"Guiwa Primary Health Centre	"	if SiteID==	3321110004
replace SiteName = 	"Kontagora Bsaic Health Clinic	"	if SiteID==	3321110005
replace SiteName = 	"Jama’a Clinic	"	if SiteID==	3321220006
replace SiteName = 	"Usman DanFodio University Teaching Hosp	"	if SiteID==	3321310007
replace SiteName = 	"Asari Dipsensary	"	if SiteID==	3321110008
replace SiteName = 	"Badano Dispensary	"	if SiteID==	3321110009
replace SiteName = 	"Daraye Dispensary	"	if SiteID==	3321110010
replace SiteName = 	"Gedawa dsiepnsary	"	if SiteID==	3321110011
replace SiteName = 	"Liggyare Dispensary	"	if SiteID==	3321110012
replace SiteName = 	"Yarume Dispensary	"	if SiteID==	3321110013
replace SiteName = 	"Bado Dispensary	"	if SiteID==	3321110014
replace SiteName = 	"Bini Basic Health Clinic	"	if SiteID==	3321110015
replace SiteName = 	"Farfaru Basic Health Clinic	"	if SiteID==	3321110016
replace SiteName = 	"Bagaya Dispensary	"	if SiteID==	3321110017
replace SiteName = 	"Boyen Dutsi	"	if SiteID==	3321110018
replace SiteName = 	"Yaurawa Dispensary	"	if SiteID==	3321110019
replace SiteName = 	"Gidan  Habibu Dispensary	"	if SiteID==	3321110020
replace SiteName = 	"Bakin Kusu Dispensary	"	if SiteID==	3321110021
replace SiteName = 	"Danjawa Dispensary	"	if SiteID==	3321110022
replace SiteName = 	"Dundaye Up-Graded Dispensary	"	if SiteID==	3321110023
replace SiteName = 	"Yarlabe Dispensary	"	if SiteID==	3321110024
replace SiteName = 	"Tambaraga Dispensary	"	if SiteID==	3321110025
replace SiteName = 	"University Permanent Site Clinic	"	if SiteID==	3321110026
replace SiteName = 	"Dankyal Dispensary	"	if SiteID==	3321110027
replace SiteName = 	"Gwamatse Dispensary	"	if SiteID==	3321110028
replace SiteName = 	"Fanari Dispensary	"	if SiteID==	3321110029
replace SiteName = 	"Gatare Dispensary	"	if SiteID==	3321110030
replace SiteName = 	"Ruggar monde Dispensary	"	if SiteID==	3321110031
replace SiteName = 	"Gidan Sarki Dunki Dispensary	"	if SiteID==	3321110032
replace SiteName = 	"Gidan Bubu Dsiepnsary	"	if SiteID==	3321110033
replace SiteName = 	"Gidan Tudu Dispensary	"	if SiteID==	3321110034
replace SiteName = 	"Gidan Yaro Dispensary	"	if SiteID==	3321110035
replace SiteName = 	"Kasarawa  Community Dispensary	"	if SiteID==	3321110036
replace SiteName = 	"Maganawa Dispensary	"	if SiteID==	3321110037
replace SiteName = 	"Gumbi Dispensary	"	if SiteID==	3321110038
replace SiteName = 	"Wajake Dispensary	"	if SiteID==	3321110039
replace SiteName = 	"Yarabba Dispensary	"	if SiteID==	3321110040
replace SiteName = 	"Mankeri Dispensary	"	if SiteID==	3321110041
replace SiteName = 	"Wamakko Up-graded Dispensary 	"	if SiteID==	3321110042
replace SiteName = 	"Kaura Kimba Dsipensary 	"	if SiteID==	3321110043
replace SiteName = 	"Lafiya Clinic	"	if SiteID==	3321220044
replace SiteName = 	"Lagau Dispensary	"	if SiteID==	3321110045
replace SiteName = 	"Mobile Police  Clinic	"	if SiteID==	3321110046
replace SiteName = 	"Samalu Dispensary	"	if SiteID==	3321110047
replace SiteName = 	"Alkammu Dsipensary	"	if SiteID==	3322110001
replace SiteName = 	"Gyalgyal Dispensary	"	if SiteID==	3322110002
replace SiteName = 	"Barayar Zaki Up-graded Dispensary 	"	if SiteID==	3322110003
replace SiteName = 	"Kwargaba Dispensary	"	if SiteID==	3322110004
replace SiteName = 	"Lugu Up-graded Dispensary	"	if SiteID==	3322110005
replace SiteName = 	"Marnona Dispensary	"	if SiteID==	3322110006
replace SiteName = 	"Chacho Dispensary	"	if SiteID==	3322110007
replace SiteName = 	"Gawo Dispensary	"	if SiteID==	3322110008
replace SiteName = 	"Kadagiwa Dispensary	"	if SiteID==	3322110009
replace SiteName = 	"Munki Dispensary	"	if SiteID==	3322110010
replace SiteName = 	"Dimbisu Dispensary	"	if SiteID==	3322110011
replace SiteName = 	"Duhuwa Dispensary	"	if SiteID==	3322110012
replace SiteName = 	"Dinawa Up-graded Dispensary	"	if SiteID==	3322110013
replace SiteName = 	"General Hospital Wurno	"	if SiteID==	3322210014
replace SiteName = 	"Kwasare Dispensary	"	if SiteID==	3322110015
replace SiteName = 	"Sisawa Dispensary	"	if SiteID==	3322110016
replace SiteName = 	"Lahodu Up-graded Dispensary	"	if SiteID==	3322110017
replace SiteName = 	"Model PHC Achida	"	if SiteID==	3322110018
replace SiteName = 	"PHC Achida	"	if SiteID==	3322110019
replace SiteName = 	"Town Dispensary Wurno	"	if SiteID==	3322110020
replace SiteName = 	"Tunga Up-graded Dispensary	"	if SiteID==	3322110021
replace SiteName = 	"Gidan Bango Dispensary	"	if SiteID==	3322110022
replace SiteName = 	"Government Secondary School Clinic	"	if SiteID==	3322110023
replace SiteName = 	"Kandam Dispensary	"	if SiteID==	3322110024
replace SiteName = 	"Sabon Gari Liman	"	if SiteID==	3322110025
replace SiteName = 	"Sakketa Dispensary	"	if SiteID==	3322110026
replace SiteName = 	"Tambaraga Dispensary	"	if SiteID==	3322110027
replace SiteName = 	"Yantabau  Dispensary	"	if SiteID==	3322110028
replace SiteName = 	"Bengaje Dispensary	"	if SiteID==	3323110001
replace SiteName = 	"Dono Dispensary	"	if SiteID==	3323110002
replace SiteName = 	"Birni Ruwa Dispensary	"	if SiteID==	3323110003
replace SiteName = 	"Kamfatare Dsipensary	"	if SiteID==	3323110004
replace SiteName = 	"Fakka Dispensary	"	if SiteID==	3323110005
replace SiteName = 	"Gudurega Dispensary	"	if SiteID==	3323110006
replace SiteName = 	"Binji Muza Dispensary	"	if SiteID==	3323110007
replace SiteName = 	"Kibiyare Dispensary	"	if SiteID==	3323110008
replace SiteName = 	"PHC Binji Muza	"	if SiteID==	3323110009
replace SiteName = 	"PHC Kilgori	"	if SiteID==	3323110010
replace SiteName = 	"Dagawa Dispensary	"	if SiteID==	3323110011
replace SiteName = 	"Ruggar Kijo Dispensary	"	if SiteID==	3323110012
replace SiteName = 	"Toronkawa Dispensary 	"	if SiteID==	3323110013
replace SiteName = 	"General Hospital Yabo	"	if SiteID==	3323210014
replace SiteName = 	"Town Dispensary Yabo	"	if SiteID==	3323110015
replace SiteName = 	"Shabra Dispensary	"	if SiteID==	3323110016
replace SiteName = 	"Alkalije Dispensary	"	if SiteID==	3323110017
replace SiteName = 	"Bakale Dispensary	"	if SiteID==	3323110018
replace SiteName = 	"W.C.W.C Yabo	"	if SiteID==	3323110019

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

* Site Level Data
*Include only one SiteID for merge with programme data. 
bysort SiteID Type: egen SiteIDord = seq()
tab SiteIDord, m
drop if SiteIDord !=1

*Remove uninterpretable data.
drop if SiteID ==.

keep   SiteID SiteName Type state_code state lga_code lga 
order  SiteID SiteName Type state_code state lga_code lga 

save "C:\TEMP\Working\SITE_delete", replace
	
****************
* Programme Data	
****************
import excel "C:\TEMP\pro.xls", sheet("Runs") firstrow clear
* Do not use the tab "Contacts" as it is incomplete. 
* YOU MUST INCLUDE in the download. 
* - SiteID 
des SiteID

* Level (First, Second, or Implementation Site)
* Role (Supervision or Implementation)
gen Role = RoleCategory
gen Level = RoleValue
tab Role, m 
tab Level, m 

*gen length = strlen(SiteID)
*recode length (1 2 = 1 "First") (3 4 = 2 "Second") (9 10 = 3 "Implementation") (* =.), generate(Role)
*recode Role (1 2 = 1 Supervision)(3 = 2 Implementation)(* =.) , gen(Level)
* these tables are for all the runs, not the individual contacts. 


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
tab WeekNum, m

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
destring SiteID, replace
gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()

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
replace RUTF_used_sachetValue = mod(RUTF_used_sachetValue,150) if RUTF_used_sachetValue > 149
replace RUTF_bal_sachetValue = mod(RUTF_bal_sachetValue,150) if RUTF_bal_sachetValue > 149

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
drop if strlen(SiteID) <9 
* drop Assaye and Robert
drop if strmatch(SiteID, "101110001") 

drop if SiteID =="X"

* Look for duplicate data on with same WeekNum (all corrections will have more than one entry with same SiteID and WeekNum).
* First drop empty reports
gen STOnodata = RUTF_in==. & RUTF_out==. & RUTF_bal==. & F75_bal==. & F100_bal==. 
* Note 1 = no data 
drop if STOnodata ==1

* Remove duplicates
destring SiteID, replace
gsort SiteID WeekNum -LastSeen
by SiteID WeekNum: egen unique = seq()
drop if unique !=1

keep URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen 
order URN Name SiteID WeekNum Role Level Type RUTF_in RUTF_out RUTF_bal F75_bal F100_bal LastSeen FirstSeen 
sort SiteID Type WeekNum

save "C:\TEMP\Working\STO_delete", replace

****************
* Stocks data - LGA STATE
****************
import excel "C:\TEMP\lga.xls", sheet("Runs") firstrow clear
* MUST INCLUDE in the download. 
* SiteID 

* The State and LGA stocks are only for the reporter's SiteID. 
* Remove all entries with incorrect SiteIDs
drop if strlen(SiteID) >4 

drop if strmatch(Name,"Dominic Elue.")

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

* Issmail explained that date LastSeen is the date of the reported flow. 
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
gen Begstock= . 
replace Begstock = RUTF_bal[_n-1] if SiteID==SiteID[_n-1] & Type==Type[_n-1] & WeekNum==WeekNum[_n-1]+1

* REMOVED F100 and F75 from Excel Dashboard

keep id state lga SiteName SiteID Type Year WeekNum report_date URN AgeGroup Beg Amar Tin Dcur ///
     Dead Defu Dmed Tout End stockcode Begstock RUTF_in RUTF_out RUTF_bal  
order id state lga SiteName SiteID Type Year WeekNum report_date URN AgeGroup Beg Amar Tin Dcur ///
     Dead Defu Dmed Tout End stockcode Begstock RUTF_in RUTF_out RUTF_bal  

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

export excel using "C:\TEMP\CMAMDashboard.xls", firstrow(variables) replace


***********
* REMINDERS
***********
use "C:\TEMP\Working\CMAM_delete", clear

* Gentle cleaning - Remove there should be no first and second level supervisors with Type = OTP or SC
sort SiteID
drop if SiteID==3305 & Type=="OTP" 
drop if SiteID==3306 & Type=="OTP" 

* Create local variable of current WeekNum
sum CurrWeekNum, meanonly
local currentweeknum =  `r(mean)' 
local end = `r(mean)' - 1
* Change this to 8 or 7 (weeks in past of complete reporting) for next training
local start = `end' - 5

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

gen Message = "Dear @contact from @contact.SiteName. Thank you for reporting. This is a REMINDER to send missing PROGRAMME reports for week numbers @contact.promiss and STOCK reports for week numbers @contact.stomiss Thank you!"
replace Message =  "Dear @contact from @contact.SiteName. Thank you for reporting. This is a REMINDER to send missing STOCK reports for week numbers @contact.stomiss Thank you!" if SiteID<9999

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

keep Phone Name SiteName SiteID Type ProMiss StoMiss Message Level
order Phone Name SiteName SiteID Type ProMiss StoMiss Message Level 
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
