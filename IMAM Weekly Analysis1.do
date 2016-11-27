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

import excel "C:\TEMP\reg.xlsx", sheet("Contacts") firstrow
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

* Set ACF persons to be technical assistance
replace Post_supValueIMAMRegister ="TA" if URN =="+2349023501879"
replace Post_supValueIMAMRegister ="TA" if URN =="+2347015878356"
replace Post_supCategoryIMAMRegist ="Technical Assistance" if URN =="+2349023501879"
replace Post_supCategoryIMAMRegist ="Technical Assistance" if URN =="+2347015878356"

* Proper cleaning of string SiteID ? 
destring Site_inputValueIMAM, gen(SiteTemp) force
tostring SiteTemp, gen(temp) force
replace SiteID = temp if SiteID=="" 
drop temp SiteTemp
destring SiteID, gen(SiteTemp) force
* replace SiteTemp = Site_inputValueIMAMReg if SiteTemp==.
sort SiteTemp
replace SiteID = "5" if SiteID=="05"
drop if SiteID=="1234567890"

* for some strange reason - decimal and zero added to SiteID, which causes problems to identify state and LGA. 
* Strip out ".0" from all SiteIDs
replace SiteID = subinstr(SiteID,".0","",1)

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



* Data cleaning
replace SiteID = subinstr(SiteID," OTP","",1)
* SiteID strips out numbers from data entry, but if garbage is included, like "OTP" that remains in the var. 
* Should have a test for any SiteID that is not a number. 

* State code ( can be 9 or 10 digits ) 
* Calculate length - take first one or two numbers
gen state_lgt = strlen(SiteID)
tab state_lgt, m


gen     state_code = substr(SiteID,1, 2) if state_lgt==10
replace state_code = substr(SiteID,1, 1) if state_lgt==9
replace state_code = substr(SiteID,1, 2) if state_lgt==4
replace state_code = substr(SiteID,1, 1) if state_lgt==3
replace state_code = SiteID if state_lgt< 3

gen state = state_code
tostring state_code, replace
tab state_code, m 

* Add names for state and LGA codes
replace state="Adamawa" if state=="2"
replace state="Bauchi" if state=="5"
replace state="Borno"  if state=="8"
replace state="Gombe"  if state=="16"
replace state="Jigawa" if state=="17"
replace state="Kaduna" if state=="18"
replace state="Kano"   if state=="19"
replace state="Katsina" if state=="20"
replace state="Kebbi"  if state=="21"
replace state="Sokoto" if state=="33"
replace state="Yobe"   if state=="35"
replace state="Zamfara" if state=="36"

tab state, m 
tab state Level, m 

* state and lga are not coded

* Add names for state and LGA codes
* NEED TO CHANGE THIS TO FIRST THREE OR FOUR DIGITS


gen lga_lgt = strlen(SiteID)
tab lga_lgt, m
list SiteID lga_lgt if lga_lgt==3

gen lga_code     = substr(SiteID,1, 4) if state_lgt==10
replace lga_code = substr(SiteID,1, 3) if state_lgt==9
replace lga_code = substr(SiteID,1, 4) if lga_lgt==4
replace lga_code = substr(SiteID,1, 3) if lga_lgt==3
gen lga = lga_code
tostring lga_code, replace
tab lga Level, m 

* Adamawa 
replace lga="DEMSA" if lga =="201"
replace lga="FUFORE" if lga =="202"
replace lga="GANYE" if lga =="203"
replace lga="GIREI" if lga =="204"
replace lga="GOMBI" if lga =="205"
replace lga="GUYUK" if lga =="206"
replace lga="HONG" if lga =="207"
replace lga="JADA" if lga =="208"
replace lga="LAMURDE" if lga =="209"
replace lga="MADAGALI" if lga =="210"
replace lga="MAIHA" if lga =="211"
replace lga="MAYO-BALEWA" if lga =="212"
replace lga="MICHIKA" if lga =="213"
replace lga="MUBI NORTH" if lga =="214"
replace lga="MUBI-SOUTH" if lga =="215"
replace lga="NUMAN" if lga =="216"
replace lga="SHELLENG" if lga =="217"
replace lga="SONG" if lga =="218"
replace lga="TOUNGO" if lga =="219"
replace lga="YOLA NORTH" if lga =="220"
replace lga="YOLA SOUTH" if lga =="221"

* Bauchi
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

* Borno
replace lga="ABADAM" if lga =="801"
replace lga="ASKIRA UBA" if lga =="802"
replace lga="BAMA" if lga =="803"
replace lga="BAYO" if lga =="804"
replace lga="BIU" if lga =="805"
replace lga="CHIBOK" if lga =="806"
replace lga="DAMBOA" if lga =="807"
replace lga="DIKWA" if lga =="808"
replace lga="GUBIO" if lga =="809"
replace lga="GUZAMALA" if lga =="810"
replace lga="GWOZA" if lga =="811"
replace lga="HAWUL" if lga =="812"
replace lga="JERE" if lga =="813"
replace lga="KAGA" if lga =="814"
replace lga="KALA BALGE" if lga =="815"
replace lga="KONDUGA" if lga =="816"
replace lga="KUKAWA" if lga =="817"
replace lga="KWAYA KWUSA" if lga =="818"
replace lga="MAFA" if lga =="819"
replace lga="MAGUMERI" if lga =="820"
replace lga="MAIDUGURI"  if lga =="821"
replace lga="MARTE" if lga =="822"
replace lga="MOBBAR" if lga =="823"
replace lga="MONGONU" if lga =="824"
replace lga="NGALA" if lga =="825"
replace lga="NGANZAI" if lga =="826"
replace lga="SHANI" if lga =="827"

* Gombe
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

* Jigawa
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

* Kano
replace lga="AJINGI" if lga =="1901"
replace lga="ALBASU" if lga =="1902"
replace lga="BAGWAI" if lga =="1903"
replace lga="BEBEJI" if lga =="1904"
replace lga="BICHI" if lga =="1905"
replace lga="BUNKURE" if lga =="1906"
replace lga="DALA" if lga =="1907"
replace lga="DAMBATTA" if lga =="1908"
replace lga="DAWAKIN KUDU" if lga =="1909"
replace lga="DAWAKIN TOFA" if lga =="1910"
replace lga="DOGUWA" if lga =="1911"
replace lga="FAGGE" if lga =="1912"
replace lga="GABASAWA" if lga =="1913"
replace lga="GARKO" if lga =="1914"
replace lga="GARUN MALLAM" if lga =="1915"
replace lga="GAYA" if lga =="1916"
replace lga="GEZAWA" if lga =="1918"
replace lga="GWALE" if lga =="1917"
replace lga="GWARZO" if lga =="1919"
replace lga="KABO" if lga =="1920"
replace lga="KANO MUNICIPAL" if lga =="1921"
replace lga="KARAYE" if lga =="1922"
replace lga="KIBIYA" if lga =="1923"
replace lga="KIRU" if lga =="1924"
replace lga="KUMBOTSO" if lga =="1925"
replace lga="KUNCHI" if lga =="1926"
replace lga="KURA" if lga =="1927"
replace lga="MADOBI" if lga =="1928"
replace lga="MAKODA" if lga =="1929"
replace lga="MINJIBIR" if lga =="1930"
replace lga="NASSARAWA" if lga =="1931"
replace lga="RANO" if lga =="1932"
replace lga="RIMIN GADO" if lga =="1934"
replace lga="ROGO" if lga =="1933"
replace lga="SHANONO" if lga =="1935"
replace lga="SUMAILA" if lga =="1936"
replace lga="TAKAI" if lga =="1937"
replace lga="TARAUNI" if lga =="1938"
replace lga="TOFA" if lga =="1939"
replace lga="TSANYAWA" if lga =="1940"
replace lga="TUDUN WADA" if lga =="1941"
replace lga="UNGOGO" if lga =="1942"
replace lga="WARAWA" if lga =="1943"
replace lga="WUDIL" if lga =="1944"

* Katsina
replace lga="BAKORI" if lga =="2001"
replace lga="BATAGARAWA" if lga =="2002"
replace lga="BATSARI" if lga =="2003"
replace lga="BAURE" if lga =="2004"
replace lga="BINDAWA" if lga =="2005"
replace lga="CHARANCHI" if lga =="2006"
replace lga="DANDUME" if lga =="2008"
replace lga="DANJA" if lga =="2009"
replace lga="DANMUSA" if lga =="2007"
replace lga="DAURA" if lga =="2010"
replace lga="DUTSI" if lga =="2011"
replace lga="DUTSIN-MA" if lga =="2012"
replace lga="FASKARI" if lga =="2013"
replace lga="FUNTUA" if lga =="2014"
replace lga="INGAWA" if lga =="2015"
replace lga="JIBIA" if lga =="2016"
replace lga="KAFUR" if lga =="2017"
replace lga="KAITA" if lga =="2018"
replace lga="KANKARA" if lga =="2019"
replace lga="KANKIA" if lga =="2020"
replace lga="KATSINA " if lga =="2021"
replace lga="KURFI" if lga =="2022"
replace lga="KUSADA" if lga =="2023"
replace lga="MAI'ADUA" if lga =="2024"
replace lga="MALUMFASHI" if lga =="2025"
replace lga="MANI" if lga =="2026"
replace lga="MASHI" if lga =="2027"
replace lga="MATAZU" if lga =="2028"
replace lga="MUSAWA" if lga =="2029"
replace lga="RIMI" if lga =="2030"
replace lga="SABUWA" if lga =="2031"
replace lga="SAFANA" if lga =="2032"
replace lga="SANDAMU" if lga =="2033"
replace lga="ZANGO" if lga =="2034"

* Kebbi
replace lga="ALIERO" if lga =="2101"
replace lga="AREWA" if lga =="2102"
replace lga="ARGUNGU" if lga =="2103"
replace lga="AUGIE" if lga =="2104"
replace lga="BAGUDO" if lga =="2105"
replace lga="BIRNIN KEBBI" if lga =="2106"
replace lga="BUNZA" if lga =="2107"
replace lga="DANDI" if lga =="2108"
replace lga="DANKO–WASAGU" if lga =="2109"
replace lga="FAKAI" if lga =="2110"
replace lga="GWANDU" if lga =="2111"
replace lga="JEGA" if lga =="2112"
replace lga="KALGO" if lga =="2113"
replace lga="KOKO–BESSE" if lga =="2114"
replace lga="MAIYAMA" if lga =="2115"
replace lga="NGASKI" if lga =="2116"
replace lga="SAKABA" if lga =="2117"
replace lga="SHANGA" if lga =="2118"
replace lga="SURU" if lga =="2119"
replace lga="YAURI" if lga =="2120"
replace lga="ZURU" if lga =="2121"


* Sokoto State
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
replace lga ="YUNUSARI" if lga=="3516"
replace lga ="YUSUFARI" if lga=="3517"
* Zamfara State
replace lga="ANKA" 			if lga=="3601"
replace lga="BAKURA" 		if lga=="3602"
replace lga="BIRNIN MAGAJI" if lga=="3603"
replace lga="BUKKUYUM" 		if lga=="3604"
replace lga="BUNGUDU" 		if lga=="3605"
replace lga="GUMMI" 		if lga=="3606"
replace lga="GUSAU" 		if lga=="3607"
replace lga="KAURA NAMODA" 	if lga=="3608"
replace lga="MARADUN" 		if lga=="3609"
replace lga="MARU" 			if lga=="3610"
replace lga="SHINKAFI" 		if lga=="3611"
replace lga="TALATA MAFARA" if lga=="3612"
replace lga="TSAFE" 		if lga=="3613"
replace lga="ZURMI" 		if lga=="3614"


replace lga = proper(lga)
tab lga, m 

* SiteName
destring SiteID, replace force
gen SiteName = ""


* Adamawa State
replace SiteName = "MAT CENT" if SiteID==	201110001
replace SiteName = "MURGARAN HC" if SiteID==	201110002
replace SiteName = "KODOMON HC" if SiteID==	201110003
replace SiteName = "DWAM MAT HC" if SiteID==	201110004
replace SiteName = "DOWAYA HC" if SiteID==	201110005
replace SiteName = "SABONGARI HC" if SiteID==	201110006
replace SiteName = "DONG HC" if SiteID==	201110007
replace SiteName = "JANUAWURI HC" if SiteID==	201110008
replace SiteName = "NEW DEMSA HC" if SiteID==	201110009
replace SiteName = "KEDEMURE HC" if SiteID==	201110010
replace SiteName = "LCCN HC" if SiteID==	201120011
replace SiteName = "LIFE LINE CLIN" if SiteID==	201120012
replace SiteName = "G.TRUST CLIN" if SiteID==	201120013
replace SiteName = "DILLI HC" if SiteID==	201110014
replace SiteName = "BILLACHI HC" if SiteID==	201110015
replace SiteName = "BORRONG HC" if SiteID==	201110016
replace SiteName = "TIKKA HC" if SiteID==	201110017
replace SiteName = "BORRONG COT. HOSP" if SiteID==	201210018
replace SiteName = "GWAMBA HC" if SiteID==	201110019
replace SiteName = "LASSALA H.Post" if SiteID==	201110020
replace SiteName = "KPASHAM MCH" if SiteID==	201110021
replace SiteName = "BALI HC" if SiteID==	201110022
replace SiteName = "KWAFARA H.Post" if SiteID==	201110023
replace SiteName = "TAGWAMBALI HC" if SiteID==	201110024
replace SiteName = "TASHAN GURU HTLHC" if SiteID==	201110025
replace SiteName = "BILLE MCH" if SiteID==	201110026
replace SiteName = "DAKSUNG HC" if SiteID==	201110027
replace SiteName = "GAJEMBO H.Post" if SiteID==	201110028
replace SiteName = "MBULA MAT HC" if SiteID==	201110029
replace SiteName = "KPAKMAYI HC" if SiteID==	201110030
replace SiteName = "NGUGWALING H.Post" if SiteID==	201110031
replace SiteName = "TAHAU MODEL H.CENT" if SiteID==	201110032
replace SiteName = "BETI HC" if SiteID==	202110001
replace SiteName = "CHIGARI HC" if SiteID==	202110002
replace SiteName = "GAWI HC" if SiteID==	202110003
replace SiteName = "WURO ARDO HC" if SiteID==	202110004
replace SiteName = "GARIN CHEKEL H.Post" if SiteID==	202110005
replace SiteName = "BA-USHE H.Post" if SiteID==	202110006
replace SiteName = "FARANG MAT CENT" if SiteID==	202110007
replace SiteName = "FARANG HC" if SiteID==	202110008
replace SiteName = "DAMARE HC" if SiteID==	202110009
replace SiteName = "MADDALI H.Post" if SiteID==	202110010
replace SiteName = "MUBAKO HC" if SiteID==	202110011
replace SiteName = "KURIYAJI H.Post" if SiteID==	202110012
replace SiteName = "RIBADU MALABU H.Post" if SiteID==	202110013
replace SiteName = "GOSHIDANG H.Post" if SiteID==	202110014
replace SiteName = "MBILLA MALABU H.Post" if SiteID==	202110015
replace SiteName = "LCCN H.Post" if SiteID==	202120016
replace SiteName = "COTTAGE HOSP FUFORE" if SiteID==	202210017
replace SiteName = "MODEL. HC" if SiteID==	202110018
replace SiteName = "FUFORE MAT CENT" if SiteID==	202110019
replace SiteName = "NJANGRE  H.Post" if SiteID==	202110020
replace SiteName = "GURIN MAT CENT" if SiteID==	202110021
replace SiteName = "GURIN HC" if SiteID==	202110022
replace SiteName = "CHIKITO HC" if SiteID==	202110023
replace SiteName = "MUNIGA MAT CENT" if SiteID==	202110024
replace SiteName = "MURINGA HC" if SiteID==	202110025
replace SiteName = "PARDA HC" if SiteID==	202110026
replace SiteName = "KARLAHI MAT CENT" if SiteID==	202110027
replace SiteName = "KARLAHI HC" if SiteID==	202110028
replace SiteName = "GURINGWA HC" if SiteID==	202110029
replace SiteName = "BOSIVANI HC" if SiteID==	202110030
replace SiteName = "NGURORE H.Post" if SiteID==	202110031
replace SiteName = "GOGORA H.Post" if SiteID==	202110032
replace SiteName = "BAGUARI H.Post" if SiteID==	202110033
replace SiteName = "WAMGO-GARGA H.Post" if SiteID==	202110034
replace SiteName = "MAYO-INNE MAT CENT" if SiteID==	202110035
replace SiteName = "MAYO-INNE HC" if SiteID==	202110036
replace SiteName = "KABILLO MAT CNTR" if SiteID==	202110037
replace SiteName = "KABILLO HC" if SiteID==	202110038
replace SiteName = "WURO-LAMIDO HC" if SiteID==	202110039
replace SiteName = "MAYO-SARKAN HC" if SiteID==	202110040
replace SiteName = "NDINGALA H.Post" if SiteID==	202110041
replace SiteName = "JILIMA SAM H.Post" if SiteID==	202110042
replace SiteName = "GATUGEL H.Post" if SiteID==	202110043
replace SiteName = "KIRI H.Post" if SiteID==	202110044
replace SiteName = "GATIRO HC" if SiteID==	202110045
replace SiteName = "PARIYA MAT CENT" if SiteID==	202110046
replace SiteName = "PARIYA HC" if SiteID==	202110047
replace SiteName = "BAGALE HC" if SiteID==	202110048
replace SiteName = "FURO PRI HC" if SiteID==	202110049
replace SiteName = "BENGO HC" if SiteID==	202110050
replace SiteName = "HOLMANO HC" if SiteID==	202110051
replace SiteName = "DAWARE HC" if SiteID==	202110052
replace SiteName = "DIGINO H.Post" if SiteID==	202110053
replace SiteName = "WURO-YOLDE H.Post" if SiteID==	202110054
replace SiteName = "KADARBU HC" if SiteID==	202110055
replace SiteName = "CHOLI HC" if SiteID==	202110056
replace SiteName = "GABSIN HC" if SiteID==	202110057
replace SiteName = "KOKSUAWA HC" if SiteID==	202110058
replace SiteName = "BAI H.Post" if SiteID==	202110059
replace SiteName = "TAWA H.Post" if SiteID==	202110060
replace SiteName = "JILLI H.Post" if SiteID==	202110061
replace SiteName = "GURANATI HC" if SiteID==	202120062
replace SiteName = "WURO-BOKKI MAT CENT" if SiteID==	202110063
replace SiteName = "WURO-BOKKO HC" if SiteID==	202110064
replace SiteName = "DENGESHI H.Post" if SiteID==	202110065
replace SiteName = "BILACHI HC" if SiteID==	202110066
replace SiteName = "DASIN ABBA KUMBO HC" if SiteID==	202110067
replace SiteName = "MALABU MAT CENT" if SiteID==	202110068
replace SiteName = "MALABU HC" if SiteID==	202120069
replace SiteName = "YADIM HC" if SiteID==	202110070
replace SiteName = "YADIM HC" if SiteID==	202110071
replace SiteName = "BENGNI HC" if SiteID==	202110072
replace SiteName = "NYIBANGO H.Post" if SiteID==	202110073
replace SiteName = "UGI H.Post" if SiteID==	202110074
replace SiteName = "BA-UMSE HC" if SiteID==	202110075
replace SiteName = "LCCN HC" if SiteID==	202120076
replace SiteName = "BAKARI GUSO HC" if SiteID==	203110001
replace SiteName = "DIRDIU HEALTH  POST" if SiteID==	203110002
replace SiteName = "GARGA H.Post" if SiteID==	203110003
replace SiteName = "BABIDI HC" if SiteID==	203110004
replace SiteName = "GANGTIMEN H.Post" if SiteID==	203110005
replace SiteName = "GAMU HC" if SiteID==	203110006
replace SiteName = "SANKOM H.Post" if SiteID==	203110007
replace SiteName = "DISSOL H.Post" if SiteID==	203110008
replace SiteName = "KURUM H.Post" if SiteID==	203110009
replace SiteName = "GANGSANEN H.Post" if SiteID==	203110010
replace SiteName = "SANGUM H.Post" if SiteID==	203110011
replace SiteName = "GURUM-PAWO HC" if SiteID==	203110012
replace SiteName = "DALAM H.Post" if SiteID==	203110013
replace SiteName = "SAMMERI HC" if SiteID==	203110014
replace SiteName = "GANGDIYI HC" if SiteID==	203110015
replace SiteName = "LINGBI H.Post" if SiteID==	203110016
replace SiteName = "DIMKUMA H.Post" if SiteID==	203110017
replace SiteName = "DATNUBU HC" if SiteID==	203110018
replace SiteName = "DIMGAM H.Post" if SiteID==	203110019
replace SiteName = "GUDING H.Post" if SiteID==	203110020
replace SiteName = "DAVAN H.Post" if SiteID==	203110021
replace SiteName = "NEW MARKET H.Post" if SiteID==	203110022
replace SiteName = "OLD MARKET H.Post" if SiteID==	203110023
replace SiteName = "NODINGA HC" if SiteID==	203120024
replace SiteName = "SUNSHINE HC" if SiteID==	203120025
replace SiteName = "BARHAMA HC" if SiteID==	203120026
replace SiteName = "Gen Hosp" if SiteID==	203210027
replace SiteName = "GOVT HEALTH OFFICE" if SiteID==	203110028
replace SiteName = "GANGWOKKI HC" if SiteID==	203110029
replace SiteName = "GANDONA HC" if SiteID==	203110030
replace SiteName = "GANGWOKI H.Post" if SiteID==	203110031
replace SiteName = "JAGGU HC" if SiteID==	203110032
replace SiteName = "BARI HC" if SiteID==	203110033
replace SiteName = "BANDA SARGA H.Post" if SiteID==	203110034
replace SiteName = "GARAMBA BALLAGRE H.H POST" if SiteID==	203110035
replace SiteName = "WADORE H.Post" if SiteID==	203110036
replace SiteName = "SANGASUMI HC" if SiteID==	203110037
replace SiteName = "SUGU HC" if SiteID==	203110038
replace SiteName = "GANGTUM HC" if SiteID==	203110039
replace SiteName = "SANKOM HC" if SiteID==	203110040
replace SiteName = "RANDO DEBBO H.Post" if SiteID==	203110041
replace SiteName = "NGURORE GANGTUM HLH POST" if SiteID==	203110042
replace SiteName = "YELWA MOD HC" if SiteID==	203110043
replace SiteName = "GANGJONEN H.Post" if SiteID==	203110044
replace SiteName = "SANSIR HC" if SiteID==	203110045
replace SiteName = "DABORA H.Post" if SiteID==	203110046
replace SiteName = "TIMDORE H.Post" if SiteID==	203110047
replace SiteName = "DAYIRI H.Post" if SiteID==	203110048
replace SiteName = "GURUM NONVAN H. POST" if SiteID==	203110049
replace SiteName = "DAKSAM H.Post" if SiteID==	203120050
replace SiteName = "JPRM HC" if SiteID==	203120051
replace SiteName = "YEBBI MOD. HC" if SiteID==	203110052
replace SiteName = "YEBBI HC" if SiteID==	203110053
replace SiteName = "KAIKA HC" if SiteID==	203110054
replace SiteName = "TIMKO HC" if SiteID==	203110055
replace SiteName = "GANGLARI H.Post" if SiteID==	203110056
replace SiteName = "NGURORE YEBBI H.Post" if SiteID==	203110057
replace SiteName = "JANGPUKI H.Post" if SiteID==	203110058
replace SiteName = "NEKSIRI H.Post" if SiteID==	203110059
replace SiteName = "GBANI H.Post" if SiteID==	203110060
replace SiteName = "ALAMISA H.Post" if SiteID==	203110061
replace SiteName = "GANJARI H.Post" if SiteID==	203110062
replace SiteName = "DAKRI PR. HC" if SiteID==	204110001
replace SiteName = "LABONDO MAT CENT" if SiteID==	204110002
replace SiteName = "FED. HOUSING MAT CENT" if SiteID==	204110003
replace SiteName = "MAL.JATAU MAT CENT" if SiteID==	204110004
replace SiteName = "BAJABURE  MAT CENT" if SiteID==	204110005
replace SiteName = "DAMARE MAT CENT" if SiteID==	204110006
replace SiteName = "DAGIYO H.Post" if SiteID==	204110007
replace SiteName = "GERENG MAT CENT" if SiteID==	204110008
replace SiteName = "KANGLING HC" if SiteID==	204110009
replace SiteName = "KOH  MAT CENT" if SiteID==	204110010
replace SiteName = "KPONGNO H.Post" if SiteID==	204110011
replace SiteName = "ABBA MURKE H.Post" if SiteID==	204110012
replace SiteName = "GIREI A PR HC" if SiteID==	204110013
replace SiteName = "GIREI B PR HC" if SiteID==	204110014
replace SiteName = "GIREI TOWN H.Post" if SiteID==	204110015
replace SiteName = "SANGERE MAT CENT" if SiteID==	204110016
replace SiteName = "FUTY HC" if SiteID==	204110017
replace SiteName = "FRSC HC" if SiteID==	204110018
replace SiteName = "GUDUSU MAT CENT" if SiteID==	204110019
replace SiteName = "NGAWA PR. HEALTH CCENT" if SiteID==	204110020
replace SiteName = "WURO BAMUMBO MAT.CNTR " if SiteID==	204110021
replace SiteName = "RUWO SANI H.Post" if SiteID==	204110022
replace SiteName = "RUWO AMSANI H.Post" if SiteID==	204110023
replace SiteName = "ABBA MURKE H.Post" if SiteID==	204110024
replace SiteName = "DANIYEL MAT CENT" if SiteID==	204110025
replace SiteName = "JERABIO MAT CENT" if SiteID==	204110026
replace SiteName = "MODIRE H.Post" if SiteID==	204110027
replace SiteName = "NJOBBORE HC" if SiteID==	204110028
replace SiteName = "VONOKLING MAT CENT" if SiteID==	204110029
replace SiteName = "BAKOPI HC" if SiteID==	204110030
replace SiteName = "JIMO HC" if SiteID==	204110031
replace SiteName = "LURU MAT CENT" if SiteID==	204110032
replace SiteName = "TAMBO H.Post" if SiteID==	204110033
replace SiteName = "JATAU H.Post" if SiteID==	204110034
replace SiteName = "JAMI-LAMBA HC" if SiteID==	204110035
replace SiteName = "MAL MADUGU MAT CENT" if SiteID==	204110036
replace SiteName = "WURO-DOLE MAT CENT" if SiteID==	204110037
replace SiteName = "GOMBI.A. HC" if SiteID==	205110001
replace SiteName = "COMP.HC GOMBI" if SiteID==	205110002
replace SiteName = "GOMBI.B. PHC" if SiteID==	205110003
replace SiteName = "GOMBI.C. PHC" if SiteID==	205110004
replace SiteName = "GUYAKU PHC" if SiteID==	205110005
replace SiteName = "DZANGOLA PHC" if SiteID==	205110006
replace SiteName = "JAU HC" if SiteID==	205110007
replace SiteName = "PRIKASA HC" if SiteID==	205110008
replace SiteName = "GIRGITHAN HC" if SiteID==	205110009
replace SiteName = "WUPUBA HC" if SiteID==	205110010
replace SiteName = "HUSSAIPA HC" if SiteID==	205110011
replace SiteName = "BALWONA PHC" if SiteID==	205110012
replace SiteName = "GARKIDA Gen Hosp" if SiteID==	205210013
replace SiteName = "GARKIDA LEPROSY HOSP" if SiteID==	205210014
replace SiteName = "WUYAKU PHC" if SiteID==	205110015
replace SiteName = "MBEWA HC" if SiteID==	205110016
replace SiteName = "ZANGRA HC" if SiteID==	205110017
replace SiteName = "DINGAI HEALTH  CLIN" if SiteID==	205110018
replace SiteName = "JEBRE HC" if SiteID==	205110019
replace SiteName = "BOGA HC" if SiteID==	205110020
replace SiteName = "SHIME HC" if SiteID==	205110021
replace SiteName = "SAMA HC" if SiteID==	205110022
replace SiteName = "FER’AMA H.Post" if SiteID==	205110023
replace SiteName = "KWARGOSHE H.Post" if SiteID==	205110024
replace SiteName = "FOTTA PHC" if SiteID==	205110025
replace SiteName = "DUWA HC" if SiteID==	205110026
replace SiteName = "JOROMBOI HC" if SiteID==	205110027
replace SiteName = "LEME HC" if SiteID==	205110028
replace SiteName = "RIJI H.Post" if SiteID==	205110029
replace SiteName = "GA’ANDA FED. MODEL HC" if SiteID==	205110030
replace SiteName = "DADWARI HC" if SiteID==	205110031
replace SiteName = "GANJARA HC" if SiteID==	205110032
replace SiteName = "GANGRANG HC" if SiteID==	205110033
replace SiteName = "JANJABA HC" if SiteID==	205110034
replace SiteName = "BAURE HC" if SiteID==	205110035
replace SiteName = "AMDUR HC" if SiteID==	205110036
replace SiteName = "PLARA H.Post" if SiteID==	205110037
replace SiteName = "BOKKI TAWA HC" if SiteID==	205110038
replace SiteName = "MUCHALLA HC" if SiteID==	205110039
replace SiteName = "BEBE HC" if SiteID==	205110040
replace SiteName = "GARFITE HC" if SiteID==	205110041
replace SiteName = "MIJIWANA HC" if SiteID==	205110042
replace SiteName = "MARABA BOKKI H.Post" if SiteID==	205110043
replace SiteName = "MAYO-ZAMBA H.Post" if SiteID==	205110044
replace SiteName = "GABUN HC" if SiteID==	205110045
replace SiteName = "NGALGA HC" if SiteID==	205110046
replace SiteName = "MBISHIM HC" if SiteID==	205110047
replace SiteName = "WAMMIRETA HC" if SiteID==	205110048
replace SiteName = "YANG HC" if SiteID==	205110049
replace SiteName = "SHENO HC" if SiteID==	205110050
replace SiteName = "NGAJING H.Post" if SiteID==	205110051
replace SiteName = "BANJIRAM MAT CENT" if SiteID==	206110001
replace SiteName = "KWADAIDAI HC" if SiteID==	206110002
replace SiteName = "GUGU HC" if SiteID==	206110003
replace SiteName = "BOBINI MODEL HC" if SiteID==	206110004
replace SiteName = "WAWI HC" if SiteID==	206110005
replace SiteName = "ARAHTECH HC" if SiteID==	206110006
replace SiteName = "GWALAM HC" if SiteID==	206110007
replace SiteName = "MADA MAT CENT" if SiteID==	206110008
replace SiteName = "DOMA HC" if SiteID==	206110009
replace SiteName = "GOROTORO HC" if SiteID==	206110010
replace SiteName = "CHIKILA MCH" if SiteID==	206110011
replace SiteName = "GWALANKA HC" if SiteID==	206110012
replace SiteName = "SILI  MAT CENT" if SiteID==	206110013
replace SiteName = "DANGIR MAT CENT" if SiteID==	206110014
replace SiteName = "JIU HC" if SiteID==	206110015
replace SiteName = "CHIKILA TUDU H.Post" if SiteID==	206110016
replace SiteName = "SILI TUDU H.Post" if SiteID==	206110017
replace SiteName = "DUKUL MAT CENT" if SiteID==	206110018
replace SiteName = "GUNDENYI H.Post" if SiteID==	206110019
replace SiteName = "FALU HC" if SiteID==	206110020
replace SiteName = "WALAN H.Post" if SiteID==	206110021
replace SiteName = "LAMZA MAT CENT" if SiteID==	206110022
replace SiteName = "DUMNA  ZERBU HC" if SiteID==	206110023
replace SiteName = "DUMNA DUTSE HC" if SiteID==	206110024
replace SiteName = "BANTHI HC" if SiteID==	206110025
replace SiteName = "ISALBO H.Post" if SiteID==	206110026
replace SiteName = "ZAKAWON HC" if SiteID==	206110027
replace SiteName = "BOSHIKIRI MAT CENT" if SiteID==	206110028
replace SiteName = "TUKUNA H.Post" if SiteID==	206110029
replace SiteName = "DUWO H.Post" if SiteID==	206110030
replace SiteName = "LAFIYA HC" if SiteID==	206110031
replace SiteName = "BOSHIKIRI HC" if SiteID==	206110032
replace SiteName = "GUYUK MCH" if SiteID==	206110033
replace SiteName = "GUYUK PHC" if SiteID==	206110034
replace SiteName = "PWALAMWOLIYE HC" if SiteID==	206110035
replace SiteName = "SISKIRA HC" if SiteID==	206110036
replace SiteName = "JAGIKA H.Post" if SiteID==	206110037
replace SiteName = "DASWANA H.Post" if SiteID==	206110038
replace SiteName = "LCCN HC" if SiteID==	206120039
replace SiteName = "GUYUGK COTTAGE HOSP" if SiteID==	206110040
replace SiteName = "KOLA HC" if SiteID==	206110041
replace SiteName = "KERAU HC" if SiteID==	206110042
replace SiteName = "PONDEWE H.Post" if SiteID==	206110043
replace SiteName = "THEBLE HEALT CLIN" if SiteID==	206110044
replace SiteName = "KWACGANKA HC" if SiteID==	206110045
replace SiteName = "LOKORO HC" if SiteID==	206110046
replace SiteName = "GUNDA HC" if SiteID==	206110047
replace SiteName = "SUKELYE HC" if SiteID==	206110048
replace SiteName = "PURAKAYO HC" if SiteID==	206110049
replace SiteName = "GOMBAWA H.Post" if SiteID==	206110050
replace SiteName = "BANGSHIKA HC" if SiteID==	207110001
replace SiteName = "MAKERA HC" if SiteID==	207110002
replace SiteName = "KALAA HC" if SiteID==	207110003
replace SiteName = "MBALWAHA HC" if SiteID==	207110004
replace SiteName = "KWAMBALA HC" if SiteID==	207110005
replace SiteName = "KWANANKUKA H.Post" if SiteID==	207110006
replace SiteName = "SHIWA H.Post" if SiteID==	207110007
replace SiteName = "KWATAU H.Post " if SiteID==	207110008
replace SiteName = "KUBUTAVA H.Post" if SiteID==	207110009
replace SiteName = "MBULAGYANG H.Post" if SiteID==	207110010
replace SiteName = "DOLMAVA H.Post" if SiteID==	207110011
replace SiteName = "ZHENDINYI HC" if SiteID==	207110012
replace SiteName = "MBOLINYI HC" if SiteID==	207110013
replace SiteName = "UDING HC" if SiteID==	207110014
replace SiteName = "DAKSIRI HC" if SiteID==	207110015
replace SiteName = "MOTHOL H.Post" if SiteID==	207110016
replace SiteName = "DILCHIDAMA H.Post" if SiteID==	207110017
replace SiteName = "TASH TIDING H.Post" if SiteID==	207110018
replace SiteName = "WURRO BOKKI H.Post" if SiteID==	207110019
replace SiteName = "DAKZA H.Post" if SiteID==	207110020
replace SiteName = "GARAHA MOJILI MAT CENT" if SiteID==	207110021
replace SiteName = "DABNA HC" if SiteID==	207110022
replace SiteName = "KINGKING HC" if SiteID==	207110023
replace SiteName = "KWAPARE HC" if SiteID==	207110024
replace SiteName = "ZAH H.Post" if SiteID==	207110025
replace SiteName = "LARH H.Post" if SiteID==	207110026
replace SiteName = "BANGA H.Post" if SiteID==	207110027
replace SiteName = "GARAHA DUTSE H.Post" if SiteID==	207110028
replace SiteName = "SHASHAU H.Post" if SiteID==	207110029
replace SiteName = "LCCN GARAHA HC" if SiteID==	207120030
replace SiteName = "JABA GAYA HC" if SiteID==	207110031
replace SiteName = "MAKI HC" if SiteID==	207110032
replace SiteName = "GASHALA MAMUDU HC" if SiteID==	207110033
replace SiteName = "GAYA SILKALMI HC" if SiteID==	207110034
replace SiteName = "GAYA FAA HC " if SiteID==	207110035
replace SiteName = "DOLMU HC" if SiteID==	207110036
replace SiteName = "MUSDA HC" if SiteID==	207110037
replace SiteName = "GASHALA DZUMBU H.POST" if SiteID==	207110038
replace SiteName = "FAA CHIBOK H.Post" if SiteID==	207110039
replace SiteName = "CHIKA H.Post" if SiteID==	207110040
replace SiteName = "MIJILI EYN HC" if SiteID==	207120041
replace SiteName = "HILDI PRIM HC" if SiteID==	207110042
replace SiteName = "PARAGALDA H.Post" if SiteID==	207110043
replace SiteName = "DAZKWA H.Post" if SiteID==	207110044
replace SiteName = "HONG A HC " if SiteID==	207110045
replace SiteName = "GUDUMIYA H.Post " if SiteID==	207110046
replace SiteName = "DULWACHIRA HC" if SiteID==	207110047
replace SiteName = "MOMBOL HC" if SiteID==	207110048
replace SiteName = "GARARI H.Post" if SiteID==	207110049
replace SiteName = "DZIGA YARIMA H.Post" if SiteID==	207110050
replace SiteName = "KWAKWAA EYN HC" if SiteID==	207120051
replace SiteName = "MOLLAH H.Post" if SiteID==	207110052
replace SiteName = "JABA HOSHERI H.Post" if SiteID==	207110053
replace SiteName = "BAKARI H.Post" if SiteID==	207110054
replace SiteName = "KWARHI PHC" if SiteID==	207110055
replace SiteName = "KWARHI EYN HC" if SiteID==	207120056
replace SiteName = "NAIWA H.Post" if SiteID==	207110057
replace SiteName = "GASHALA MIGZIL H.Post" if SiteID==	207110058
replace SiteName = "KURMI HC" if SiteID==	207110059
replace SiteName = "GASHALA KUFAN HC" if SiteID==	207110060
replace SiteName = "MIRINYI HC" if SiteID==	207110061
replace SiteName = "BAKINRIGYA H.Post" if SiteID==	207110062
replace SiteName = "HC B HONG" if SiteID==	207110064
replace SiteName = "MUNGA H.Post" if SiteID==	207110065
replace SiteName = "DAZAL H.Post" if SiteID==	207110066
replace SiteName = "MANDZA H.Post" if SiteID==	207110067
replace SiteName = "COTTAGE HOSP HONG" if SiteID==	207210068
replace SiteName = "FADAMA REKE EYN HC " if SiteID==	207120069
replace SiteName = "HC B HONG" if SiteID==	207110070
replace SiteName = "GASHAKA HC" if SiteID==	207110071
replace SiteName = "BUZZA HC" if SiteID==	207110072
replace SiteName = "MIDALA H.Post" if SiteID==	207110073
replace SiteName = "DZUMAH HC" if SiteID==	207110074
replace SiteName = "DULBUNI H.Post" if SiteID==	207110075
replace SiteName = "KOKO H.Post" if SiteID==	207110076
replace SiteName = "FACI HC" if SiteID==	207110077
replace SiteName = "NGALBI H.Post" if SiteID==	207110078
replace SiteName = "WOMEN IN HEALTH MAT.PELLA" if SiteID==	207110079
replace SiteName = "PELLA LCCN MAT" if SiteID==	207120080
replace SiteName = "PELLA LCCN HC" if SiteID==	207120081
replace SiteName = "PRIMARY HEALTH CARE UBA" if SiteID==	207110082
replace SiteName = "HC UBA" if SiteID==	207110083
replace SiteName = "HUSSARA HEALTH  POST" if SiteID==	207110084
replace SiteName = "WURO KARE H.Post" if SiteID==	207110085
replace SiteName = "JALINGO H.Post" if SiteID==	207110086
replace SiteName = "BARKA HC" if SiteID==	207120087
replace SiteName = "CLIN C Hong" if SiteID==	207110088
replace SiteName = "Kuva Gaya PHC" if SiteID==	207110089
replace SiteName = "DANABA MAT CENT" if SiteID==	208110001
replace SiteName = "NADEA H.Post" if SiteID==	208110002
replace SiteName = "SANKEUPO H.Post" if SiteID==	208110003
replace SiteName = "DIMKASUM HC" if SiteID==	208110004
replace SiteName = "KAMENYA H.Post" if SiteID==	208110005
replace SiteName = "JADA TOWN HC" if SiteID==	208110006
replace SiteName = "JADA PRIM. HEALTH  CENT" if SiteID==	208110007
replace SiteName = "COTTAGE HOSP. JADA" if SiteID==	208210008
replace SiteName = "SPECIAL EDU.HC" if SiteID==	208110009
replace SiteName = "NASSA. KONA MCH" if SiteID==	208110010
replace SiteName = "CHACHA HC" if SiteID==	208110011
replace SiteName = "KOMA 11 BETI HC" if SiteID==	208110012
replace SiteName = "WARI HC" if SiteID==	208110013
replace SiteName = "MAYO-HAKO HC" if SiteID==	208110014
replace SiteName = "DALAMI HC" if SiteID==	208110015
replace SiteName = "SOO MAT CENT" if SiteID==	208110016
replace SiteName = "GWAALGU HC" if SiteID==	208110017
replace SiteName = "WURO-ABBO HC" if SiteID==	208110018
replace SiteName = "GANGLE HC" if SiteID==	208110019
replace SiteName = "GANGKIRI H.Post" if SiteID==	208110020
replace SiteName = "MAPEO MAT CENT" if SiteID==	208110021
replace SiteName = "LENUGDO H.Post" if SiteID==	208110022
replace SiteName = "JALINGO H.Post" if SiteID==	208110023
replace SiteName = "MBULO PRIM. HC" if SiteID==	208110024
replace SiteName = "MBANGEN TIREN MAT CENT" if SiteID==	208110025
replace SiteName = "MBANGEA TIREN HC" if SiteID==	208110026
replace SiteName = "GANGSAJI  HC" if SiteID==	208110027
replace SiteName = "FARANG-VEN HC" if SiteID==	208110028
replace SiteName = "KOJOLI MAT CENT" if SiteID==	208110029
replace SiteName = "SAPEO HC" if SiteID==	208110030
replace SiteName = "GADJO H.Post" if SiteID==	208110031
replace SiteName = "MAYO-INNE H.Post" if SiteID==	208110032
replace SiteName = "Dashen PHC" if SiteID==	208110033
replace SiteName = "DUBWANGE HC" if SiteID==	209110001
replace SiteName = "MBEMUN HC" if SiteID==	209110002
replace SiteName = "BAFYAU H.Post" if SiteID==	209110003
replace SiteName = "GYWANA HC" if SiteID==	209110004
replace SiteName = "GYWANA MAT CENT" if SiteID==	209110005
replace SiteName = "SAVANNAH MAT CENT" if SiteID==	209120006
replace SiteName = "OVER SEER H.Post" if SiteID==	209110007
replace SiteName = "LAFIYA HC" if SiteID==	209110008
replace SiteName = "MAMSIRME MAT CENT" if SiteID==	209110009
replace SiteName = "FED.MOD. HC" if SiteID==	209110010
replace SiteName = "LAMURDE MAT CENT" if SiteID==	209110011
replace SiteName = "HADIYO HC" if SiteID==	209110012
replace SiteName = "RIGANGE HC" if SiteID==	209110013
replace SiteName = "BAJEN H.Post" if SiteID==	209110014
replace SiteName = "OPALO HC" if SiteID==	209110015
replace SiteName = "ZEKUN HC" if SiteID==	209110016
replace SiteName = "SABON LAYI HC" if SiteID==	209110017
replace SiteName = "TIPTO MAT CENT" if SiteID==	209110018
replace SiteName = "TINGNO DUTSE MAT CENT" if SiteID==	209110019
replace SiteName = "WADUKU MAT CENT" if SiteID==	209110020
replace SiteName = "KWAH HC" if SiteID==	209110021
replace SiteName = "NGBAKOWO HC" if SiteID==	209110022
replace SiteName = "KABAWA H.Post" if SiteID==	209110023
replace SiteName = "TINGNO KOGI HC" if SiteID==	209110024
replace SiteName = "SUWA HC" if SiteID==	209110025
replace SiteName = "GYAKAN  HC" if SiteID==	209110026
replace SiteName = "BALAIFI  HC" if SiteID==	209110027
replace SiteName = "LASSUN HC" if SiteID==	209110028
replace SiteName = "CHAKAWA PRIM.HC" if SiteID==	210110001
replace SiteName = "WAGGA HC" if SiteID==	210110002
replace SiteName = "NGORE H.Post" if SiteID==	210110003
replace SiteName = "TUR H.Post" if SiteID==	210110004
replace SiteName = "GULAK COTTAGE HOSP" if SiteID==	210210005
replace SiteName = "KUBU HC" if SiteID==	210110006
replace SiteName = "BAKIN DUTSE HC" if SiteID==	210110007
replace SiteName = "KAYA H.Post" if SiteID==	210110008
replace SiteName = "GHANTSA H.Post" if SiteID==	210110009
replace SiteName = "DAR H.Post" if SiteID==	210110010
replace SiteName = "WANUKI H.Post" if SiteID==	210110011
replace SiteName = "GULAK TOWN HC" if SiteID==	210110012
replace SiteName = "BEBEL HC" if SiteID==	210110013
replace SiteName = "DRIFF HC" if SiteID==	210110014
replace SiteName = "SUKUR SETTL. HC" if SiteID==	210110015
replace SiteName = "PALLAM MAT CENT" if SiteID==	210110016
replace SiteName = "TAKYA H.Post" if SiteID==	210110017
replace SiteName = "KOJITI H.Post" if SiteID==	210110018
replace SiteName = "WURO GAS H.Post" if SiteID==	210110019
replace SiteName = "NGUR JAKU H.Post" if SiteID==	210110020
replace SiteName = "GAJAMA H.Post" if SiteID==	210110021
replace SiteName = "NGUR HC" if SiteID==	210120022
replace SiteName = "TAHUM WAZIRI H.Post" if SiteID==	210110023
replace SiteName = "BITIKU PRIM. HC" if SiteID==	210110024
replace SiteName = "HYAMBULA 11 HC" if SiteID==	210110025
replace SiteName = "HYAMBULA 1 HC" if SiteID==	210110026
replace SiteName = "KIRCHINGA MAT CENT" if SiteID==	210110027
replace SiteName = "KOPA PRIMARY HC" if SiteID==	210110028
replace SiteName = "WURONGAYANDI HC" if SiteID==	210110029
replace SiteName = "KOPA KOE H.Post" if SiteID==	210110030
replace SiteName = "DAGALI HC" if SiteID==	210110031
replace SiteName = "GSS HC" if SiteID==	210110032
replace SiteName = "CBO. MCH" if SiteID==	210110033
replace SiteName = "MADAGALI HC" if SiteID==	210110034
replace SiteName = "VIZIK HC" if SiteID==	210110035
replace SiteName = "MADAGALI COM.HLTH" if SiteID==	210110036
replace SiteName = "PRISON HC" if SiteID==	210110037
replace SiteName = "MADAGALI GSS HC" if SiteID==	210110038
replace SiteName = "WULA MCH" if SiteID==	210110039
replace SiteName = "WULA KUSHIRI H.Post" if SiteID==	210110040
replace SiteName = "MUDUVU H.Post" if SiteID==	210110041
replace SiteName = "MILDO MODEL HC" if SiteID==	210110042
replace SiteName = "SUKUR SAMA H.Post" if SiteID==	210110043
replace SiteName = "DAMAI H.Post" if SiteID==	210110044
replace SiteName = "VAPURA H.Post" if SiteID==	210110045
replace SiteName = "KURANG H.Post" if SiteID==	210110046
replace SiteName = "BUGUDUM H.Post" if SiteID==	210110047
replace SiteName = "NDALMI H.Post" if SiteID==	210110048
replace SiteName = "MILDO MAT CENT" if SiteID==	210110049
replace SiteName = "PUBA H.Post" if SiteID==	210110050
replace SiteName = "LAMADU HC" if SiteID==	210110051
replace SiteName = "MAYOWANDU HC" if SiteID==	210110052
replace SiteName = "KWABULA HC" if SiteID==	210110053
replace SiteName = "DUHU H.Post" if SiteID==	210110054
replace SiteName = "NJAHILI H.Post" if SiteID==	210110055
replace SiteName = "COCCIN HC" if SiteID==	210120056
replace SiteName = "SHUWA CATH MCH" if SiteID==	210120057
replace SiteName = "SHAIDA HC" if SiteID==	210120058
replace SiteName = "BELEL MAT CENT" if SiteID==	211110001
replace SiteName = "BELEL LEPROSY CLIN" if SiteID==	211110002
replace SiteName = "BUNGEL H.Post" if SiteID==	211110003
replace SiteName = "JAMTARI HC" if SiteID==	211110004
replace SiteName = "HUMBUTUDI MAT CENT" if SiteID==	211110005
replace SiteName = "VOKUNA MAT CENT" if SiteID==	211110006
replace SiteName = "KAPULE HC" if SiteID==	211110007
replace SiteName = "MBALAGI HC" if SiteID==	211110008
replace SiteName = "KILANGE HC" if SiteID==	211110009
replace SiteName = "MAIHA GARI MAT CENT" if SiteID==	211110010
replace SiteName = "MAIHA GARI HC" if SiteID==	211110011
replace SiteName = "JABA-JABA MAT CENT" if SiteID==	211110012
replace SiteName = "LUGGA BABBA MAT CENT" if SiteID==	211110013
replace SiteName = "BOKEN HC" if SiteID==	211110014
replace SiteName = "KONKOL MAT CENT" if SiteID==	211110015
replace SiteName = "MARRABA KONKOL HC" if SiteID==	211110016
replace SiteName = "KONKOL HC" if SiteID==	211110017
replace SiteName = "WURO-BAMDI H.Post" if SiteID==	211110018
replace SiteName = "BOLOKO HC" if SiteID==	211110019
replace SiteName = "WURO-KURORI H.Post" if SiteID==	211110020
replace SiteName = "BOLOKO .FD.MOD. HC" if SiteID==	211110021
replace SiteName = "MANJEKIN MAT CENT" if SiteID==	211110022
replace SiteName = "SALMA KOLI H.Post" if SiteID==	211110023
replace SiteName = "HUBARE H.Post" if SiteID==	211110024
replace SiteName = "JALINGO BU H.Post" if SiteID==	211110025
replace SiteName = "KWAABOONAR H.Post" if SiteID==	211110026
replace SiteName = "DAFURA H.Post" if SiteID==	211110027
replace SiteName = "PALWAWOL MAT CENT" if SiteID==	211110028
replace SiteName = "MAYO-NGULI MAT CENT" if SiteID==	211110029
replace SiteName = "MAYO-NGULI HC" if SiteID==	211110030
replace SiteName = "DEDE MAT CENT" if SiteID==	211110031
replace SiteName = "BWADE MAT CENT" if SiteID==	211110032
replace SiteName = "HUDU HC" if SiteID==	211110033
replace SiteName = "LUDIRA HC" if SiteID==	211110034
replace SiteName = "TOUNGO H.Post" if SiteID==	211110035
replace SiteName = "HAMADALLA H.Post" if SiteID==	211110036
replace SiteName = "HOLE H.Post" if SiteID==	211110037
replace SiteName = "COTTAGE HOSP. MAIHA" if SiteID==	211210038
replace SiteName = "GSS H.Post" if SiteID==	211110039
replace SiteName = "PAKKA PRIM. HC" if SiteID==	211110040
replace SiteName = "MAANE HC" if SiteID==	211110041
replace SiteName = "PEGIN HC" if SiteID==	211110042
replace SiteName = "FURE MAANE H.Post" if SiteID==	211110043
replace SiteName = "GSS PAKKA H.Post" if SiteID==	211110044
replace SiteName = "LCCN HC" if SiteID==	211120045
replace SiteName = "KOWAGOL MAT CENT" if SiteID==	211110046
replace SiteName = "WURO-LADDE HC" if SiteID==	211110047
replace SiteName = "WURO-BOKKA MAT CENT" if SiteID==	211110048
replace SiteName = "WURO-GENDE HC" if SiteID==	211110049
replace SiteName = "KOLWA H.Post" if SiteID==	211110050
replace SiteName = "WURO-MALLUM H.Post" if SiteID==	211110051
replace SiteName = "WURO-LAWAN H.Post" if SiteID==	211110052
replace SiteName = "SORAU B MAT CENT" if SiteID==	211110053
replace SiteName = "SORAU B HC" if SiteID==	211110054
replace SiteName = "KONGOLI HC" if SiteID==	211110055
replace SiteName = "MAYO-VAMDE HC" if SiteID==	211110056
replace SiteName = "MBAFERE H.Post" if SiteID==	211110057
replace SiteName = "TAMJAM MAT CENT" if SiteID==	211110058
replace SiteName = "WURO-ALHAJI MAT CENT" if SiteID==	211110059
replace SiteName = "WURO-IYA MAT CENT" if SiteID==	211110060
replace SiteName = "MAGARA HC" if SiteID==	211110061
replace SiteName = "COTTAGE HOSP. MAYO-BALEWA" if SiteID==	212210001
replace SiteName = "MAYO-BALEWA MAT CENT" if SiteID==	212110002
replace SiteName = "ARDO HC" if SiteID==	212110003
replace SiteName = "MARKET HC" if SiteID==	212110004
replace SiteName = "SABONGARI TIKE HC" if SiteID==	212110005
replace SiteName = "M/SANGANARE HC" if SiteID==	212110006
replace SiteName = "KONA HC" if SiteID==	212120007
replace SiteName = "CIKASON ANGLICAN HTHC" if SiteID==	212120008
replace SiteName = "JAURO TAHIR BABA HC" if SiteID==	212120009
replace SiteName = "MAYO-FARANG MAT CENT" if SiteID==	212110010
replace SiteName = "GIJARO HC" if SiteID==	212110011
replace SiteName = "SEBORE HC" if SiteID==	212110012
replace SiteName = "MBALGARE HC" if SiteID==	212110013
replace SiteName = "RUMDEGIWA H.Post" if SiteID==	212110014
replace SiteName = "LIRINGO H.Post" if SiteID==	212110015
replace SiteName = "NDIKONG MAT CENT" if SiteID==	212110016
replace SiteName = "GARU HC" if SiteID==	212110017
replace SiteName = "DEO-LEGGAL HC" if SiteID==	212110018
replace SiteName = "POLL WAYA HC" if SiteID==	212110019
replace SiteName = "SINDIGANO HC" if SiteID==	212110020
replace SiteName = "KAURAME H.Post" if SiteID==	212110021
replace SiteName = "DALEHI H.Post" if SiteID==	212110022
replace SiteName = "JAMBINTU HC" if SiteID==	212110023
replace SiteName = "TOLA PRIMARY HC" if SiteID==	212110024
replace SiteName = "GANGNASO HC" if SiteID==	212110025
replace SiteName = "TOLA JABU HC" if SiteID==	212110026
replace SiteName = "KIGANG HC" if SiteID==	212110027
replace SiteName = "MUNCHI H.Post" if SiteID==	212110028
replace SiteName = "DEJJA H.Post" if SiteID==	212110029
replace SiteName = "BINYERE BASIC HC " if SiteID==	212110030
replace SiteName = "GANGTAGANI HC" if SiteID==	212110031
replace SiteName = "GAMPANA HC" if SiteID==	212110032
replace SiteName = "BAMFO H.Post" if SiteID==	212110033
replace SiteName = "YELWA HC" if SiteID==	212110034
replace SiteName = "WAKKA HC" if SiteID==	212110035
replace SiteName = "UBAKKA HC" if SiteID==	212110036
replace SiteName = "BAFUFUDUM HC" if SiteID==	212110037
replace SiteName = "SAKPANI H.Post" if SiteID==	212110038
replace SiteName = "WATEME H.Post" if SiteID==	212110039
replace SiteName = "TUMARI H.Post" if SiteID==	212110040
replace SiteName = "RIBADU HC" if SiteID==	212110041
replace SiteName = "YOLDE GUBUDO HC" if SiteID==	212110042
replace SiteName = "LABBARE HC" if SiteID==	212110043
replace SiteName = "CHUKKOL HC" if SiteID==	212110044
replace SiteName = "BINKOLA HC" if SiteID==	212110045
replace SiteName = "MBELA HC" if SiteID==	212110046
replace SiteName = "W/YOLDE H.Post" if SiteID==	212110047
replace SiteName = "NYAKAKUNA H.Post" if SiteID==	212110048
replace SiteName = "Njereng PHC" if SiteID==	212110049
replace SiteName = "MICHIKA TOWN HC" if SiteID==	213110001
replace SiteName = "MARKET H.Post" if SiteID==	213110002
replace SiteName = "MAHALSHALBAH MAT" if SiteID==	213110003
replace SiteName = "ABBASU HC" if SiteID==	213110004
replace SiteName = "MICHIKA Gen Hosp" if SiteID==	213210005
replace SiteName = "MICHIKA MAT CENT" if SiteID==	213110006
replace SiteName = "NUT CENT MICHIKA" if SiteID==	213110007
replace SiteName = "MODA HC" if SiteID==	213110008
replace SiteName = "DLAKA HC" if SiteID==	213110009
replace SiteName = "MAT CENT" if SiteID==	213110010
replace SiteName = "DLAKA HC" if SiteID==	213110011
replace SiteName = "MINKISI HC" if SiteID==	213110012
replace SiteName = "DIRGIWI H.Post" if SiteID==	213110013
replace SiteName = "LIDDLE HC" if SiteID==	213110014
replace SiteName = "HYLEMI MAT" if SiteID==	213110015
replace SiteName = "KAMALE HC" if SiteID==	213110016
replace SiteName = "KAMALE MAT" if SiteID==	213110017
replace SiteName = "SINA KWANDE HC" if SiteID==	213110018
replace SiteName = "SINA WHATE H.Post" if SiteID==	213110019
replace SiteName = "SINA BIZZIK H.Post" if SiteID==	213110020
replace SiteName = "SINA MALA H.Post" if SiteID==	213110021
replace SiteName = "MARABA HEALTH" if SiteID==	213110022
replace SiteName = "GARTA MAT CENT" if SiteID==	213110023
replace SiteName = "GARTA HC" if SiteID==	213110024
replace SiteName = "GHUMCHI H.Post" if SiteID==	213110025
replace SiteName = "NBORORO HC (EYN)" if SiteID==	213120026
replace SiteName = "FUTULESS HC" if SiteID==	213110027
replace SiteName = "FUTU DOU HC" if SiteID==	213110028
replace SiteName = "FUTU DOU H.Post" if SiteID==	213110029
replace SiteName = "HIMIKILESS HC" if SiteID==	213110030
replace SiteName = "NKAFAMIYA HC" if SiteID==	213110031
replace SiteName = "NKAFFA H.Post" if SiteID==	213110032
replace SiteName = "MUCCAVATTIA H.Post" if SiteID==	213110033
replace SiteName = "TILLI HC" if SiteID==	213110034
replace SiteName = "WAMBILIMI HC" if SiteID==	213110035
replace SiteName = "TILLI H.Post" if SiteID==	213110036
replace SiteName = "VIH HC" if SiteID==	213110037
replace SiteName = "BOKKO HC" if SiteID==	213110038
replace SiteName = "HURO MCH" if SiteID==	213110039
replace SiteName = "KUBURSHOSHO MOD H.LTH CENT" if SiteID==	213110040
replace SiteName = "BLASHAFA HC" if SiteID==	213110041
replace SiteName = "WATU H.Post" if SiteID==	213110042
replace SiteName = "JAGALAMBO HC" if SiteID==	213110043
replace SiteName = "SHAFA H.Post " if SiteID==	213110044
replace SiteName = "FWA H.Post" if SiteID==	213110045
replace SiteName = "MANJI MEMORI. HC" if SiteID==	213120046
replace SiteName = "KANKALE HC" if SiteID==	213110047
replace SiteName = "ST.MARIA CATHOLIC  MATY" if SiteID==	213120048
replace SiteName = "BAZZA HC" if SiteID==	213110049
replace SiteName = "BIARANG HC" if SiteID==	213110050
replace SiteName = "TSUKUMA MAT CENT" if SiteID==	213110051
replace SiteName = "WASILA MAT CENT" if SiteID==	213110052
replace SiteName = "SHAFFA H.Post" if SiteID==	213110053
replace SiteName = "KUDZUM HC" if SiteID==	213110054
replace SiteName = "KWAPABALE HC" if SiteID==	213110055
replace SiteName = "KWALIA H.Post" if SiteID==	213110056
replace SiteName = "KELLI H.Post" if SiteID==	213110057
replace SiteName = "DZOROK HC" if SiteID==	213110058
replace SiteName = "BUPPA MAT CENT" if SiteID==	213110059
replace SiteName = "KARAZAH HC" if SiteID==	213110060
replace SiteName = "KALU HC" if SiteID==	213110061
replace SiteName = "MAMPI H.Post" if SiteID==	213110062
replace SiteName = "BURHA VAMGO PRI. HC" if SiteID==	214110001
replace SiteName = "MADUGUVA PRY HC" if SiteID==	214110002
replace SiteName = "BAHULI HC" if SiteID==	214110003
replace SiteName = "BETSO PRIMARY HC" if SiteID==	214110004
replace SiteName = "BETSO MANGO H.Post" if SiteID==	214110005
replace SiteName = "BETSO HC" if SiteID==	214110006
replace SiteName = "WAMIZHLI H.Post" if SiteID==	214110007
replace SiteName = "SUZUWA HC" if SiteID==	214110008
replace SiteName = "KWA HC" if SiteID==	214110009
replace SiteName = "WUMU H.Post" if SiteID==	214110010
replace SiteName = "DIGIL MAT CENT" if SiteID==	214110011
replace SiteName = "DIGIL HC" if SiteID==	214110012
replace SiteName = "DIGIL PRIMARY HC" if SiteID==	214110013
replace SiteName = "WURO HARDE HC" if SiteID==	214110014
replace SiteName = "BUKKAJI H.Post" if SiteID==	214110015
replace SiteName = "HURIDA H.Post" if SiteID==	214110016
replace SiteName = "KOLERE H.Post" if SiteID==	214110017
replace SiteName = "LOKUWA PRIM. HEALTH  CLIN" if SiteID==	214110018
replace SiteName = "COLL.HEALTH TECH. HTHC" if SiteID==	214110019
replace SiteName = "SAMUNAKA HC" if SiteID==	214110020
replace SiteName = "FED.POLY HC" if SiteID==	214110021
replace SiteName = "STATE UNIVERSITY HC" if SiteID==	214110022
replace SiteName = "GSS MUBI HC" if SiteID==	214110023
replace SiteName = "GTSS HC" if SiteID==	214110024
replace SiteName = "NEW LIFE HOSP" if SiteID==	214220025
replace SiteName = "MUVA PRIMARY HEALTH  CLIN" if SiteID==	214110026
replace SiteName = "MAYO-BANI HC" if SiteID==	214110027
replace SiteName = "MUKTA HC" if SiteID==	214110028
replace SiteName = "MIZZA PRIMARY HEALTH CARE" if SiteID==	214110029
replace SiteName = "KIRYA HC" if SiteID==	214110030
replace SiteName = "GEMBULA H.Post " if SiteID==	214110031
replace SiteName = "MUCHHALLA .MOD. HC" if SiteID==	214110032
replace SiteName = "MUCHALLA PRI. HEALTH  CLIN" if SiteID==	214110033
replace SiteName = "BAGIRRA HC" if SiteID==	214110034
replace SiteName = "JILVU HC" if SiteID==	214110035
replace SiteName = "MUVUR H.Post" if SiteID==	214110036
replace SiteName = "GOVA H.Post" if SiteID==	214110037
replace SiteName = "SABON LAYI H.Post" if SiteID==	214110038
replace SiteName = "VIMTIM PRIMARY HEALTH CARE" if SiteID==	214110039
replace SiteName = "RIBAWO PRIMARY HEALTH CARE " if SiteID==	214110040
replace SiteName = "RIBAWO HC" if SiteID==	214110041
replace SiteName = "DUDA H.Post" if SiteID==	214110042
replace SiteName = "LIRA H.Post" if SiteID==	214110043
replace SiteName = "KWACHAFIYA HC" if SiteID==	214110044
replace SiteName = "NEW MARKET HC" if SiteID==	214110045
replace SiteName = "DAZALA H.Post" if SiteID==	214110046
replace SiteName = "YELWA H.Post" if SiteID==	214110047
replace SiteName = "GELLA MAT CENT" if SiteID==	215110001
replace SiteName = "MALUHA H.Post" if SiteID==	215110002
replace SiteName = "KWAJA MAT CENT" if SiteID==	215110003
replace SiteName = "KINGA H.Post" if SiteID==	215110004
replace SiteName = "KISSA H.Post" if SiteID==	215110005
replace SiteName = "DUVU MAT CENT" if SiteID==	215110006
replace SiteName = "DUVU H.Post" if SiteID==	215110007
replace SiteName = "GRA-GRA H.Post" if SiteID==	215110008
replace SiteName = "CHABA H.Post" if SiteID==	215110009
replace SiteName = "DIRBISHI PRY. HEALTH  CLIN" if SiteID==	215110010
replace SiteName = "GANDIRA MAT CENT" if SiteID==	215110011
replace SiteName = "SAHUDA HC" if SiteID==	215110012
replace SiteName = "MUJARA H.Post" if SiteID==	215110013
replace SiteName = "BAGUNA H.Post" if SiteID==	215110014
replace SiteName = "YELWA H.Post" if SiteID==	215110015
replace SiteName = "MADANYA H.Post" if SiteID==	215110016
replace SiteName = "MUJARA MAT CENT" if SiteID==	215110017
replace SiteName = "SEBORE H.Post" if SiteID==	215110018
replace SiteName = "WABULUDE H.Post" if SiteID==	215110019
replace SiteName = "NASSARAWA H.Post" if SiteID==	215110020
replace SiteName = "Gen Hosp MUBI" if SiteID==	215210021
replace SiteName = "CATHOLIC HC" if SiteID==	215120022
replace SiteName = "MALANGASHA H.Post" if SiteID==	215110023
replace SiteName = "LAMORDE H.Post" if SiteID==	215110024
replace SiteName = "ARHANKUNU H.Post" if SiteID==	215110025
replace SiteName = "GAYA H.Post" if SiteID==	215110026
replace SiteName = "J/LAMORDE H.Post" if SiteID==	215110027
replace SiteName = "ASAAL HC" if SiteID==	215120028
replace SiteName = "BEEKY HC" if SiteID==	215120029
replace SiteName = "UBES HC" if SiteID==	215110030
replace SiteName = "DEMBELE HC" if SiteID==	215120031
replace SiteName = "MUDA MAT CENT" if SiteID==	215110032
replace SiteName = "MUGULBU H.Post" if SiteID==	215110033
replace SiteName = "CHAKANJE H.Post" if SiteID==	215110034
replace SiteName = "DAJA H.Post" if SiteID==	215110035
replace SiteName = "BAJAULE H.Post" if SiteID==	215110036
replace SiteName = "VINDEJIRE H.Post" if SiteID==	215110037
replace SiteName = "MUCHAMI H.Post" if SiteID==	215110038
replace SiteName = "YADAFA H.Post" if SiteID==	215110039
replace SiteName = "MONDUVA MAT CENT" if SiteID==	215110040
replace SiteName = "MONDUVA H.Post" if SiteID==	215110041
replace SiteName = "MAWA H.Post" if SiteID==	215110042
replace SiteName = "GUDE H.Post" if SiteID==	215110043
replace SiteName = "WURO PATUJI H.Post" if SiteID==	215110044
replace SiteName = "NGASVAHI H.Post" if SiteID==	215110045
replace SiteName = "KAGII PHC" if SiteID==	215110046
replace SiteName = "BARE MAT CENT" if SiteID==	216110001
replace SiteName = "UBANDOMA H.Post" if SiteID==	216110002
replace SiteName = "SABON PEGI H.Post" if SiteID==	216110003
replace SiteName = "BOLKI HC" if SiteID==	216110004
replace SiteName = "NZUMOSU MAT CENT" if SiteID==	216110005
replace SiteName = "YANG HC" if SiteID==	216110006
replace SiteName = "GAMADIO HC" if SiteID==	216110007
replace SiteName = "TUNGA LADAN HC" if SiteID==	216110008
replace SiteName = "IMBURU HC" if SiteID==	216110009
replace SiteName = "NGABLANG HC" if SiteID==	216110010
replace SiteName = "ZANGUN HC" if SiteID==	216110011
replace SiteName = "KWAPUKAI H.Post" if SiteID==	216110012
replace SiteName = "KODOMTI HC" if SiteID==	216110013
replace SiteName = "KIKON HC" if SiteID==	216110014
replace SiteName = "SHAFORON HC" if SiteID==	216110015
replace SiteName = "NZORUWE H.Post" if SiteID==	216110016
replace SiteName = "PULLUM H.Post" if SiteID==	216110017
replace SiteName = "KWAUBA H.Post" if SiteID==	216110018
replace SiteName = "BAMATOTO HC" if SiteID==	216110019
replace SiteName = "GSS NUMAN HC" if SiteID==	216110020
replace SiteName = "TUDON WADA HC" if SiteID==	216110021
replace SiteName = "MOTHER OF MERCY HC" if SiteID==	216120022
replace SiteName = "WODI SAKATO HC" if SiteID==	216110023
replace SiteName = "PARE HC" if SiteID==	216110024
replace SiteName = "GSS PARE HC" if SiteID==	216110025
replace SiteName = "LCCN HC" if SiteID==	216120026
replace SiteName = "MAKERA HC" if SiteID==	216110027
replace SiteName = "JAURO BARKINDO HC" if SiteID==	216110028
replace SiteName = "SABON PEGI HC" if SiteID==	216110029
replace SiteName = "Gen Hosp" if SiteID==	216210030
replace SiteName = "DOWAYA H.Post" if SiteID==	216110031
replace SiteName = "GWEDA MALLAM HC" if SiteID==	216110032
replace SiteName = "GRACE LAND  HC" if SiteID==	216120033
replace SiteName = "BASHA HC" if SiteID==	216120034
replace SiteName = "VULPI HC" if SiteID==	216110035
replace SiteName = "SALTI HC" if SiteID==	216110036
replace SiteName = "GBALAPUN HC" if SiteID==	216110037
replace SiteName = "BAKTA HC" if SiteID==	217110001
replace SiteName = "JIMBO H.Post" if SiteID==	217110002
replace SiteName = "PUPAH H.Post" if SiteID==	217110003
replace SiteName = "BIKI H.Post" if SiteID==	217110004
replace SiteName = "BODWAI H.Post" if SiteID==	217110005
replace SiteName = "BODWAI MAT CENT" if SiteID==	217110006
replace SiteName = "BOLAMA H.Post" if SiteID==	217110007
replace SiteName = "DALWA HC" if SiteID==	217110008
replace SiteName = "GWARTA H.Post" if SiteID==	217110009
replace SiteName = "JALINGO H.Post" if SiteID==	217110010
replace SiteName = "RIWIRIM H.Post" if SiteID==	217110011
replace SiteName = "BOBERE HC" if SiteID==	217110012
replace SiteName = "DASON FULANI H.Post" if SiteID==	217110013
replace SiteName = "KEM HC" if SiteID==	217110014
replace SiteName = "LARABA H.Post" if SiteID==	217110015
replace SiteName = "GWAPOPOLOK HC" if SiteID==	217110016
replace SiteName = "KARLAJE HC" if SiteID==	217120017
replace SiteName = "KONGMA HC" if SiteID==	217110018
replace SiteName = "NAFADA H.Post" if SiteID==	217110019
replace SiteName = "BIRABIRA H.Post" if SiteID==	217110020
replace SiteName = "DONGE H.Post" if SiteID==	217110021
replace SiteName = "GOMBEYEL H.Post" if SiteID==	217110022
replace SiteName = "JAMALI H.Post" if SiteID==	217110023
replace SiteName = "KULA HC" if SiteID==	217110024
replace SiteName = "YORRONGE H.Post" if SiteID==	217110025
replace SiteName = "BARATA H.Post" if SiteID==	217110026
replace SiteName = "GONDONG HC" if SiteID==	217110027
replace SiteName = "KETEMBERE HC" if SiteID==	217110028
replace SiteName = "LABAU HC" if SiteID==	217110029
replace SiteName = "KIRI HC" if SiteID==	217110030
replace SiteName = "KIRI MAT CENT" if SiteID==	217110031
replace SiteName = "SAVANNAH CAM H.Post" if SiteID==	217120032
replace SiteName = "DUMBURI H.Post" if SiteID==	217110033
replace SiteName = "JABI H.Post" if SiteID==	217110034
replace SiteName = "KAMBILAM H.Post" if SiteID==	217110035
replace SiteName = "KATE HC" if SiteID==	217110036
replace SiteName = "WURONYANKA HC" if SiteID==	217110037
replace SiteName = "SHELLENG NYSC HC" if SiteID==	217110038
replace SiteName = "SHELLENG TOWN HC" if SiteID==	217110039
replace SiteName = "GWAGARAB HC" if SiteID==	217110040
replace SiteName = "KULA DUTSE H.Post" if SiteID==	217110041
replace SiteName = "TALUM H.Post" if SiteID==	217110042
replace SiteName = "WURO LADDE H.Post" if SiteID==	217110043
replace SiteName = "DIRMA MAT CENT" if SiteID==	218110001
replace SiteName = "SHURE H.Post" if SiteID==	218110002
replace SiteName = "BOTTA H.Post" if SiteID==	218110003
replace SiteName = "BATUM MAT CENT" if SiteID==	218110004
replace SiteName = "TINDE H.Post" if SiteID==	218110005
replace SiteName = "BWARE H.Post" if SiteID==	218110006
replace SiteName = "DOMBI H.Post" if SiteID==	218110007
replace SiteName = "BAPTA H.Post" if SiteID==	218110008
replace SiteName = "DUMNE MAT CENT" if SiteID==	218110009
replace SiteName = "DUMNE TOWN H.Post" if SiteID==	218110010
replace SiteName = "COTTAGE HOSP DUMNE" if SiteID==	218210011
replace SiteName = "DUMNE LCCN HC" if SiteID==	218120012
replace SiteName = "BAKKA H.Post" if SiteID==	218110013
replace SiteName = "SILON MAT CENT" if SiteID==	218110014
replace SiteName = "HOMBO HC" if SiteID==	218110015
replace SiteName = "SIMRA H.Post" if SiteID==	218110016
replace SiteName = "PULLEYANKA H.Post" if SiteID==	218110017
replace SiteName = "GUDU HC" if SiteID==	218110018
replace SiteName = "BREDEN H.Post" if SiteID==	218110019
replace SiteName = "GAKTA H.Post" if SiteID==	218110020
replace SiteName = "CHIBAWURO H.Post" if SiteID==	218110021
replace SiteName = "HANDU MAT CENT" if SiteID==	218110022
replace SiteName = "SIGIRE HC" if SiteID==	218110023
replace SiteName = "KESURE MAT CENT" if SiteID==	218110024
replace SiteName = "GOLONTOBAL MOD. H. CENT" if SiteID==	218110025
replace SiteName = "WURO MALLUM HC" if SiteID==	218110026
replace SiteName = "PAKIN MAT CENT" if SiteID==	218110027
replace SiteName = "WURODE HC" if SiteID==	218110028
replace SiteName = "GURIKI H.Post" if SiteID==	218110029
replace SiteName = "WURO DAUDA HC" if SiteID==	218110030
replace SiteName = "GHELLENG H.Post" if SiteID==	218110031
replace SiteName = "BOLOKO H.Post" if SiteID==	218110032
replace SiteName = "SALASA MAT CENT" if SiteID==	218110033
replace SiteName = "ROMA H.Post" if SiteID==	218110034
replace SiteName = "BALMA H.Post" if SiteID==	218110035
replace SiteName = "GBERWENE HC" if SiteID==	218110036
replace SiteName = "SUKTU SAKTE H.Post" if SiteID==	218110037
replace SiteName = "SUKTU SARKI H.Post" if SiteID==	218110038
replace SiteName = "KUMO MAT CENT" if SiteID==	218110039
replace SiteName = "PRAMBE MAT CENT" if SiteID==	218110040
replace SiteName = "PUPA H.Post" if SiteID==	218110041
replace SiteName = "WALTADI H.Post" if SiteID==	218110042
replace SiteName = "TSAUBIRI H.Post" if SiteID==	218110043
replace SiteName = "DIKIR H.Post" if SiteID==	218110044
replace SiteName = "KUTA MAT CENT" if SiteID==	218110045
replace SiteName = "HOLMA MODEL HC" if SiteID==	218110046
replace SiteName = "ZUMO PRIMARY HC" if SiteID==	218110047
replace SiteName = "LAMURDE H.Post" if SiteID==	218110048
replace SiteName = "COTTAGE HOSP SONG" if SiteID==	218210049
replace SiteName = "SONG MAT. HC" if SiteID==	218110050
replace SiteName = "SABON LOKO HC" if SiteID==	218110051
replace SiteName = "BOLKI MAT CENT" if SiteID==	218110052
replace SiteName = "NUTRITION REHABIL. CENT" if SiteID==	218110053
replace SiteName = "WALI H.Post" if SiteID==	218120054
replace SiteName = "MARKET H.Post" if SiteID==	218110055
replace SiteName = "AUWAL H.Post" if SiteID==	218120056
replace SiteName = "TOWN H.Post" if SiteID==	218110057
replace SiteName = "HAYINGADA HC" if SiteID==	218110058
replace SiteName = "MBILLA HC" if SiteID==	218110059
replace SiteName = "DADINKOWA HC" if SiteID==	218110060
replace SiteName = "GULUNGO H.Post" if SiteID==	218110061
replace SiteName = "GOMBO DEKEN H.Post" if SiteID==	218110062
replace SiteName = "MURKE HC" if SiteID==	218110063
replace SiteName = "GYAWAN HC" if SiteID==	218110064
replace SiteName = "MAIGGRO H.Post" if SiteID==	218110065
replace SiteName = "MULLENG H.Post" if SiteID==	218110066
replace SiteName = "GALAMBA  MAT CENT" if SiteID==	218110067
replace SiteName = "DADINGO H.Post" if SiteID==	218110068
replace SiteName = "MUDUGO H.Post" if SiteID==	218110069
replace SiteName = "LAIDE H.Post" if SiteID==	218110070
replace SiteName = "WAM H.Post" if SiteID==	218120071
replace SiteName = "GANSEINI HC" if SiteID==	219110001
replace SiteName = "DASU HC" if SiteID==	219110002
replace SiteName = "GUM HC" if SiteID==	219110003
replace SiteName = "KIRI HC" if SiteID==	219110004
replace SiteName = "NAYA HC" if SiteID==	219110005
replace SiteName = "MENTANI HC" if SiteID==	219110006
replace SiteName = "DALASUM HC" if SiteID==	219110007
replace SiteName = "DUGDU HC" if SiteID==	219110008
replace SiteName = "TIMBO HC" if SiteID==	219110009
replace SiteName = "TIMBUKUN HC" if SiteID==	219110010
replace SiteName = "KUDORI HC" if SiteID==	219110011
replace SiteName = "KOGIN BABA HC" if SiteID==	219110012
replace SiteName = "SONGOLI HC" if SiteID==	219110013
replace SiteName = "KILALAI HC" if SiteID==	219110014
replace SiteName = "COTTAGE HOSP TOUNGO" if SiteID==	219210015
replace SiteName = "TOUNGO TOWN H.Post" if SiteID==	219110016
replace SiteName = "TIPSAN H.Post" if SiteID==	219110017
replace SiteName = "LAINDE CHITTA H.Post" if SiteID==	219110018
replace SiteName = "GANGZAMANU HC" if SiteID==	219110019
replace SiteName = "YELISO MOD. HC" if SiteID==	219110020
replace SiteName = "NAMDU HC" if SiteID==	219110021
replace SiteName = "TAKSI GONI HC" if SiteID==	219110022
replace SiteName = "NEW AJIYA HC" if SiteID==	220110001
replace SiteName = "OLD AJIYA HC" if SiteID==	220110002
replace SiteName = "DAWAU HC" if SiteID==	220110003
replace SiteName = "ALAKALAWA  HC" if SiteID==	220110004
replace SiteName = "GALBOSE HOSP" if SiteID==	220220005
replace SiteName = "MAJOR AMINU HC" if SiteID==	220110006
replace SiteName = "BAMAIYI HOSP" if SiteID==	220220007
replace SiteName = "GWADABAWA HC" if SiteID==	220110008
replace SiteName = "GOVT HOUSE CLIN" if SiteID==	220110009
replace SiteName = "FCE CLIN" if SiteID==	220110010
replace SiteName = "GGSS HC" if SiteID==	220110011
replace SiteName = "JAMBUTU MAT CENT" if SiteID==	220110012
replace SiteName = "DAMILEU HC" if SiteID==	220110013
replace SiteName = "HASKE NURSING HOME" if SiteID==	220120014
replace SiteName = "GERIO NURSNG HOME" if SiteID==	220120015
replace SiteName = "IBRAHIM ALFA HOSP" if SiteID==	220220016
replace SiteName = "MERCY LAND CLIN" if SiteID==	220120017
replace SiteName = "POLICE HC" if SiteID==	220110018
replace SiteName = "AIRFORCE CLIN" if SiteID==	220210019
replace SiteName = "23RD ARMOURED MED.  CENT" if SiteID==	220210020
replace SiteName = "BEKAJI HC" if SiteID==	220110021
replace SiteName = "LEGSETIVE HC" if SiteID==	220110022
replace SiteName = "BACHURE H.Post" if SiteID==	220110023
replace SiteName = "MALAMARE HC" if SiteID==	220110024
replace SiteName = "STATE POLYTECHNIC CLIN" if SiteID==	220110025
replace SiteName = "BOSHONG HC" if SiteID==	220120026
replace SiteName = "MATCO HOSP" if SiteID==	220220027
replace SiteName = "GIZO CLIN" if SiteID==	220120028
replace SiteName = "NAKOWA CLIN" if SiteID==	220120029
replace SiteName = "VALADA CLIN" if SiteID==	220120030
replace SiteName = "VALLI CLIN" if SiteID==	220120031
replace SiteName = "LIMAWA HC" if SiteID==	220110032
replace SiteName = "HALAL CLIN" if SiteID==	220120033
replace SiteName = "LUGGERE HC CBBI)" if SiteID==	220110034
replace SiteName = "TRIUMPHC" if SiteID==	220120035
replace SiteName = "PEACE HOSP" if SiteID==	220220036
replace SiteName = "FREEDOM POLY HOSP" if SiteID==	220220037
replace SiteName = "JEMITA MCH" if SiteID==	220220038
replace SiteName = "YOLA SPECIALIST HOSP" if SiteID==	220210039
replace SiteName = "DEMSAWO HC " if SiteID==	220110040
replace SiteName = "EMICARE CLIN" if SiteID==	220120041
replace SiteName = "STAR CLIN" if SiteID==	220120042
replace SiteName = "RUMDE HC" if SiteID==	220110043
replace SiteName = "YELWA HC" if SiteID==	220110044
replace SiteName = "NASSARAWO PHC" if SiteID==	220110045
replace SiteName = "WURO-HAUSA HC" if SiteID==	221110001
replace SiteName = "WURO-HAUSA H.Post" if SiteID==	221110002
replace SiteName = "BAKO H.Post" if SiteID==	221110003
replace SiteName = "SHAGARI H.Post" if SiteID==	221110004
replace SiteName = "BOLE HC" if SiteID==	221110005
replace SiteName = "BOLE H.Post" if SiteID==	221110006
replace SiteName = "YOLDE PATE HC" if SiteID==	221110007
replace SiteName = "FEDERAL Med CENT" if SiteID==	221310008
replace SiteName = "NANA MAT CENT" if SiteID==	221110009
replace SiteName = "YOLA CENT. HC" if SiteID==	221110010
replace SiteName = "DAMARE HC" if SiteID==	221110011
replace SiteName = "LAMIDO HC" if SiteID==	221110012
replace SiteName = "MBAMBA HC" if SiteID==	221110013
replace SiteName = "MBAMBA POLICE CLIN" if SiteID==	221110014
replace SiteName = "UPPER BENUE HC" if SiteID==	221110015
replace SiteName = "NJOBOLI HC" if SiteID==	221110016
replace SiteName = "RUGANGE HC" if SiteID==	221110017
replace SiteName = "SEBORE HC" if SiteID==	221110018
replace SiteName = "MBAMOI HC" if SiteID==	221110019
replace SiteName = "PALACE HC" if SiteID==	221110020
replace SiteName = "ADAMAWA HOSP" if SiteID==	221220021
replace SiteName = "NAMTARI HC" if SiteID==	221110022
replace SiteName = "WAURUJABBE HC" if SiteID==	221110023
replace SiteName = "CHANGALA H.Post" if SiteID==	221110024
replace SiteName = "NAMTARI GUREL HELTH POST" if SiteID==	221110025
replace SiteName = "GONGOSHI H.Post" if SiteID==	221110026
replace SiteName = "NGURORE P HC " if SiteID==	221110027
replace SiteName = "WURON-YANKA HC" if SiteID==	221110028
replace SiteName = "KULANGU H.Post" if SiteID==	221110029
replace SiteName = "TOUNGO HC" if SiteID==	221110030
replace SiteName = "YOLDE KOHI H.Post" if SiteID==	221110031
replace SiteName = "HOSERE BEMBE HC" if SiteID==	221110032
replace SiteName = "GODUWO H.Post" if SiteID==	221110033
replace SiteName = "GONGOSHI HC" if SiteID==	221110034

* Bauchi

replace SiteName ="Alkaleri GH" if SiteID ==501210001
replace SiteName ="Alkaleri Town MAT" if SiteID==	501110002
replace SiteName ="Alkaleri Town Disp" if SiteID==	501110003
replace SiteName ="Bajama Com. Hlth. CENT" if SiteID==	501110004
replace SiteName ="Gigyara HC" if SiteID==	501110005
replace SiteName ="Yankari HC" if SiteID==	501110006
replace SiteName ="Badaram Dutsi" if SiteID==	501110007
replace SiteName ="Jamda Disp" if SiteID==	501110008
replace SiteName ="Yalwan Duguri MPHC" if SiteID==	501110009
replace SiteName ="Dan H.Post" if SiteID==	501110010
replace SiteName ="Futuk HC" if SiteID==	501110011
replace SiteName ="Garin Hamza Disp" if SiteID==	501110012
replace SiteName ="Gar MAT" if SiteID==	501110013
replace SiteName ="Gangar Disp" if SiteID==	501110014
replace SiteName ="Guruntun Disp" if SiteID==	501110015
replace SiteName ="Gwana MAT" if SiteID==	501110016
replace SiteName ="Gobirawa HC" if SiteID==	501110017
replace SiteName ="Gwaram MAT" if SiteID==	501110018
replace SiteName ="Gwaram Disp" if SiteID==	501110019
replace SiteName ="Gokaru HC" if SiteID==	501110020
replace SiteName ="Kaciciya Disp" if SiteID==	501110021
replace SiteName ="Shira MAT" if SiteID==	501110022
replace SiteName ="Galen Duguri HC" if SiteID==	501110023
replace SiteName ="Mainamaji Disp" if SiteID==	501110024
replace SiteName ="Kumbala HC" if SiteID==	501110025
replace SiteName ="Mundamiyo HC" if SiteID==	501110026
replace SiteName ="Kundak Disp" if SiteID==	501110027
replace SiteName ="Maimadi HC" if SiteID==	501110028
replace SiteName ="Mari-Ari HC" if SiteID==	501110029
replace SiteName ="Kwaimawa H.Post" if SiteID==	501110030
replace SiteName ="Jada Disp" if SiteID==	501110031
replace SiteName ="Mansur HC" if SiteID==	501110032
replace SiteName ="Galen Mansur HC" if SiteID==	501110033
replace SiteName ="Pali HC" if SiteID==	501110034
replace SiteName ="Bakin Kogi MPHC" if SiteID==	501110035
replace SiteName ="Yalo HC" if SiteID==	501110036
replace SiteName ="Digare Disp" if SiteID==	501110037
replace SiteName ="Duguri HC" if SiteID==	501110038
replace SiteName ="Bojos Disp" if SiteID==	501110039
replace SiteName ="Duguri Disp" if SiteID==	501110040
replace SiteName ="Gaji Disp" if SiteID==	501110041
replace SiteName ="Moscow HC" if SiteID==	501120042
replace SiteName ="Gen Hosp Bayara" if SiteID==	502210001
replace SiteName ="Yolan HC" if SiteID==	502110002
replace SiteName ="Buarnawa Disp" if SiteID==	502110003
replace SiteName ="Kadage" if SiteID==	502110004
replace SiteName ="Lusgi Disp" if SiteID==	502110005
replace SiteName ="Doya PHC" if SiteID==	502110006
replace SiteName ="Town MAT" if SiteID==	502110007
replace SiteName ="Kofar Dumi Mat&Child HC" if SiteID==	502110008
replace SiteName ="Ung. Mahaukata HC" if SiteID==	502110009
replace SiteName ="Afor CLIN & MAT" if SiteID==	502120010
replace SiteName ="Albishir CLIN" if SiteID==	502120011
replace SiteName ="Alheri Med CLIN" if SiteID==	502120012
replace SiteName ="Alhissan MCHC" if SiteID==	502120013
replace SiteName ="Almanzoor Diag. Center" if SiteID==	502120014
replace SiteName ="Alwadata Consult. CLIN" if SiteID==	502120015
replace SiteName ="Aminchi CLIN" if SiteID==	502120016
replace SiteName ="Amsad CLIN" if SiteID==	502120017
replace SiteName ="City Spec" if SiteID==	502120018
replace SiteName ="Dambam Nursing Home" if SiteID==	502120019
replace SiteName ="Darussalam HC" if SiteID==	502120020
replace SiteName ="Kainuwa CLIN" if SiteID==	502120021
replace SiteName ="Keffi CLIN" if SiteID==	502120022
replace SiteName ="Maijama’a CLIN" if SiteID==	502120023
replace SiteName ="Makkah Eye CLIN" if SiteID==	502120024
replace SiteName ="Nagarta CLIN" if SiteID==	502120025
replace SiteName ="Nasara HC" if SiteID==	502120026
replace SiteName ="Ni'ima Consult CLIN" if SiteID==	502120027
replace SiteName ="Peoples CLIN" if SiteID==	502120028
replace SiteName ="Phalicon CLIN" if SiteID==	502120029
replace SiteName ="Reemee Med. Care" if SiteID==	502120030
replace SiteName ="Royel CLIN" if SiteID==	502120031
replace SiteName ="Sabo CLIN" if SiteID==	502120032
replace SiteName ="Sauki CLIN" if SiteID==	502120033
replace SiteName ="Taimako HC" if SiteID==	502120034
replace SiteName ="Ubani Dental CLIN" if SiteID==	502120035
replace SiteName ="Yelwa CLIN & MAT" if SiteID==	502120036
replace SiteName ="Gudun PHC" if SiteID==	502110037
replace SiteName ="Dandango MAT" if SiteID==	502110038
replace SiteName ="Kir MAT" if SiteID==	502110039
replace SiteName ="Abubakar Tafawa Balewa Teach HOSP" if SiteID==	502310040
replace SiteName ="St Low Cost Mat&Child HC" if SiteID==	502110041
replace SiteName ="Federal Low Cost HC" if SiteID==	502110042
replace SiteName ="Police CLIN" if SiteID==	502110043
replace SiteName ="School of Armour CLIN" if SiteID==	502110044
replace SiteName ="33 Army Brigade CLIN " if SiteID==	502110045
replace SiteName ="Tashan Babiye PHC" if SiteID==	502110046
replace SiteName ="Azare Urban MAT" if SiteID==	502110047
replace SiteName ="Dawaki Disp" if SiteID==	502110048
replace SiteName ="Badakoshi Mat&Child HC" if SiteID==	502110049
replace SiteName ="Tudun Gambo HC" if SiteID==	502110050
replace SiteName ="Dindima Disp" if SiteID==	502110051
replace SiteName ="Galambi Disp" if SiteID==	502110052
replace SiteName ="Kurwala Disp" if SiteID==	502110053
replace SiteName ="Jalingo Disp" if SiteID==	502110054
replace SiteName ="Kwagal Disp" if SiteID==	502110055
replace SiteName ="Gwaskawaram HC" if SiteID==	502110056
replace SiteName ="Jitar HC" if SiteID==	502110057
replace SiteName ="U/Dashi Disp" if SiteID==	502110058
replace SiteName ="Kobi Disp" if SiteID==	502110059
replace SiteName ="Durum PHC" if SiteID==	502110060
replace SiteName ="Yalwan Kunlun HC" if SiteID==	502110061
replace SiteName ="Kundum Disp" if SiteID==	502110062
replace SiteName ="Dumin Zungur Disp" if SiteID==	502110063
replace SiteName ="Gubi Disp" if SiteID==	502110064
replace SiteName ="Balanshi PHC" if SiteID==	502110065
replace SiteName ="Benu HC" if SiteID==	502110066
replace SiteName ="Kagere MAT" if SiteID==	502110067
replace SiteName ="Bamanu MAT" if SiteID==	502110068
replace SiteName ="Kagere Disp" if SiteID==	502110069
replace SiteName ="Bishi Disp" if SiteID==	502110070
replace SiteName ="Mararraban /L Katagum HC" if SiteID==	502110071
replace SiteName ="L/Katagum CHC" if SiteID==	502110072
replace SiteName ="Jamda" if SiteID==	502110073
replace SiteName ="Gangu" if SiteID==	502110074
replace SiteName ="L/Kitagum" if SiteID==	502110075
replace SiteName ="Under 5 CLIN" if SiteID==	502110076
replace SiteName ="Family Planning CLIN" if SiteID==	502110077
replace SiteName ="Rimin Jalum Disp" if SiteID==	502110078
replace SiteName ="Miri PHC" if SiteID==	502110079
replace SiteName ="W/ Dada Mat&Child HC" if SiteID==	502110080
replace SiteName ="Buzaye Disp" if SiteID==	502110081
replace SiteName ="Dungal Disp" if SiteID==	502110082
replace SiteName ="Rijiyan Disp" if SiteID==	502110083
replace SiteName ="Juwara MAT" if SiteID==	502110084
replace SiteName ="Munsal MAT" if SiteID==	502110085
replace SiteName ="Mun Disp" if SiteID==	502110086
replace SiteName ="Gamawa Disp" if SiteID==	502110087
replace SiteName ="Gwambe Disp" if SiteID==	502110088
replace SiteName ="Yola Doka Disp" if SiteID==	502110089
replace SiteName ="Tirwun Mat&Child HC" if SiteID==	502110090
replace SiteName ="Ibrahim Bako HC" if SiteID==	502110091
replace SiteName ="Habli Disp" if SiteID==	502110092
replace SiteName ="Luda MAT" if SiteID==	502110093
replace SiteName ="Luda Disp" if SiteID==	502110094
replace SiteName ="Lekka Disp" if SiteID==	502110095
replace SiteName ="Palla Disp" if SiteID==	502110096
replace SiteName ="Hammadad Disp" if SiteID==	502110097
replace SiteName ="Zungur PHC" if SiteID==	502110098
replace SiteName ="Kusada Disp" if SiteID==	502110099
replace SiteName ="Sabon Garin Garkuwa Disp" if SiteID==	502110100
replace SiteName ="Giraka Disp" if SiteID==	502110101
replace SiteName ="Gungu Disp" if SiteID==	502110102
replace SiteName ="Datsang HC" if SiteID==	503110001
replace SiteName ="Bar HC" if SiteID==	503110002
replace SiteName ="Gen: HOSP " if SiteID==	503210003
replace SiteName ="Bogoro Mat&Child HC " if SiteID==	503110004
replace SiteName ="Ginzum HC" if SiteID==	503110005
replace SiteName ="PHC BOI" if SiteID==	503110006
replace SiteName ="Danshem Yelwa" if SiteID==	503110007
replace SiteName ="COCIN CLIN BOI" if SiteID==	503120008
replace SiteName ="Tongrate HC" if SiteID==	503120009
replace SiteName ="Bazanshi HC" if SiteID==	503110010
replace SiteName ="Dutsen Lawan HC" if SiteID==	503110011
replace SiteName ="Ungwan Rimi HC" if SiteID==	503110012
replace SiteName ="Gambar HC" if SiteID==	503110013
replace SiteName ="Dambar HC" if SiteID==	503110014
replace SiteName ="Ungwan Gyada HC" if SiteID==	503110015
replace SiteName ="Gobbiya MPCH" if SiteID==	503110016
replace SiteName ="Gyara HC" if SiteID==	503110017
replace SiteName ="Lusa MCH" if SiteID==	503110018
replace SiteName ="Dunga HC" if SiteID==	503110019
replace SiteName ="Bonga HC" if SiteID==	503110020
replace SiteName ="Mwari MCH" if SiteID==	503110021
replace SiteName ="Lafiyan-Sara  Mat&Child HC" if SiteID==	503110022
replace SiteName ="Dalanga HC" if SiteID==	503110023
replace SiteName ="Mwari PMSS CLIN" if SiteID==	503120024
replace SiteName ="Tadnum Mat&Child HC" if SiteID==	503110025
replace SiteName ="Banram HC" if SiteID==	503110026
replace SiteName ="Dagauda PHC" if SiteID==	504110001
replace SiteName ="Dambam MAT" if SiteID==	504110002
replace SiteName ="Dambam Disp" if SiteID==	504110003
replace SiteName ="GEN HOSPDambam" if SiteID==	504210004
replace SiteName ="Birniwa Disp" if SiteID==	504110005
replace SiteName ="Fagam Disp" if SiteID==	504110006
replace SiteName ="Fagarau Disp" if SiteID==	504110007
replace SiteName ="Gaina Disp" if SiteID==	504110008
replace SiteName ="Luchambi Disp" if SiteID==	504110009
replace SiteName ="Chadi Disp" if SiteID==	504110010
replace SiteName ="Wahu Disp" if SiteID==	504110011
replace SiteName ="Garuza Disp" if SiteID==	504110012
replace SiteName ="Gurbana Disp" if SiteID==	504110013
replace SiteName ="Jalam PHC" if SiteID==	504110014
replace SiteName ="Dorawa Disp" if SiteID==	504110015
replace SiteName ="G/Jarma" if SiteID==	504110016
replace SiteName ="K/Shinge" if SiteID==	504110017
replace SiteName ="Badakoshi Disp" if SiteID==	504110018
replace SiteName ="G/Sura Disp" if SiteID==	504110019
replace SiteName ="Janda Disp" if SiteID==	504110020
replace SiteName ="Tale Disp" if SiteID==	504110021
replace SiteName ="Minchika Disp" if SiteID==	504110022
replace SiteName ="Madawa Disp" if SiteID==	504110023
replace SiteName ="Durwari Disp" if SiteID==	504110024
replace SiteName ="Muzuwa Disp" if SiteID==	504110025
replace SiteName ="Yayari Disp" if SiteID==	504110026
replace SiteName ="Gwaramawa Disp" if SiteID==	504110027
replace SiteName ="Yame Disp" if SiteID==	504110028
replace SiteName ="Malatin Disp" if SiteID==	504110029
replace SiteName ="Yanda Disp" if SiteID==	504110030
replace SiteName ="Lailai Disp" if SiteID==	504110031
replace SiteName ="G/Jalo Disp" if SiteID==	504110032
replace SiteName ="Lubai Disp" if SiteID==	504110033
replace SiteName ="Yayari Disp" if SiteID==	504110034
replace SiteName ="Ngaima Disp" if SiteID==	504110035
replace SiteName ="Biniyu Disp" if SiteID==	504110036
replace SiteName ="Taiyu Disp" if SiteID==	504110037
replace SiteName ="Gen Hosp Darazo" if SiteID==	505210001
replace SiteName ="Under five CLIN" if SiteID==	505110002
replace SiteName ="Sabu MAT" if SiteID==	505110003
replace SiteName ="Zobo MAT" if SiteID==	505110004
replace SiteName ="Lemari MAT" if SiteID==	505110005
replace SiteName ="Tauya MAT HC" if SiteID==	505110006
replace SiteName ="Darazo HC" if SiteID==	505110007
replace SiteName ="S/G/Papa HC" if SiteID==	505110008
replace SiteName ="Sade HC" if SiteID==	505110009
replace SiteName ="Duwo HC" if SiteID==	505110010
replace SiteName ="Yalwal HC" if SiteID==	505110011
replace SiteName ="Yautare HC" if SiteID==	505110012
replace SiteName ="Tsamiya MCH" if SiteID==	505110013
replace SiteName ="Darazo Med. CLIN" if SiteID==	505120014
replace SiteName ="Nasiha Med. Center" if SiteID==	505120015
replace SiteName ="Kanya Disp" if SiteID==	505110016
replace SiteName ="Gabarin HC" if SiteID==	505110017
replace SiteName ="Kili Disp" if SiteID==	505110018
replace SiteName ="Jimin Disp" if SiteID==	505110019
replace SiteName ="Gangulawai Disp" if SiteID==	505110020
replace SiteName ="Bula Disp" if SiteID==	505110021
replace SiteName ="Gabchiyari HC" if SiteID==	505110022
replace SiteName ="Konkiyal HC" if SiteID==	505110023
replace SiteName ="Lago HC" if SiteID==	505110024
replace SiteName ="Kari HC" if SiteID==	505110025
replace SiteName ="Diggiri Disp" if SiteID==	505110026
replace SiteName ="Lanzai HC" if SiteID==	505110027
replace SiteName ="Lamba Disp" if SiteID==	505110028
replace SiteName ="Kaugama Disp" if SiteID==	505110029
replace SiteName ="S/G/Lanzai" if SiteID==	505110030
replace SiteName ="Papa MPHC" if SiteID==	505110031
replace SiteName ="Garin Abare HC" if SiteID==	505110032
replace SiteName ="Wahu HC" if SiteID==	505110033
replace SiteName ="Lagon Wahu Disp" if SiteID==	505110034
replace SiteName ="Indabu Disp" if SiteID==	505110035
replace SiteName ="Kawuri Disp" if SiteID==	505110036
replace SiteName ="Gakulan Audi Disp" if SiteID==	505110037
replace SiteName ="Wuro Dole Disp" if SiteID==	505110038
replace SiteName ="Makafiya Disp" if SiteID==	505110039
replace SiteName ="Aliya Disp" if SiteID==	505110040
replace SiteName ="Nahutan Sade Disp" if SiteID==	505110041
replace SiteName ="Zandam Disp" if SiteID==	505110042
replace SiteName ="Yunbunga Disp" if SiteID==	505110043
replace SiteName ="Dalagobe Disp" if SiteID==	505110044
replace SiteName ="Zoro Disp" if SiteID==	505110045
replace SiteName ="Nahuta Darazo" if SiteID==	505110046
replace SiteName ="Shadarki Disp" if SiteID==	505110047
replace SiteName ="Dayi Disp" if SiteID==	505110048
replace SiteName ="Kuka Biyu Disp" if SiteID==	505110049
replace SiteName ="Jiro Disp" if SiteID==	505110050
replace SiteName ="Gerin Lesa Disp" if SiteID==	505110051
replace SiteName ="S/G/Yautare Disp" if SiteID==	505110052
replace SiteName ="Dambiji Disp" if SiteID==	505110053
replace SiteName ="Bagel Disp" if SiteID==	506110001
replace SiteName ="Bajar HC" if SiteID==	506110002
replace SiteName ="Lirr MAT" if SiteID==	506110003
replace SiteName ="Baraza PHC" if SiteID==	506110004
replace SiteName ="Gala HC" if SiteID==	506110005
replace SiteName ="Bandas Disp" if SiteID==	506110006
replace SiteName ="Gamki Disp" if SiteID==	506110007
replace SiteName ="Dass Gen Hosp" if SiteID==	506210008
replace SiteName ="Dabardak MAT" if SiteID==	506110009
replace SiteName ="ECWA HC" if SiteID==	506120010
replace SiteName ="Town MAT" if SiteID==	506110011
replace SiteName ="Dass Town Disp" if SiteID==	506110012
replace SiteName ="Shalgwantar Disp" if SiteID==	506110013
replace SiteName ="Bashi Mat/CLIN" if SiteID==	506110014
replace SiteName ="Bangin MAT" if SiteID==	506110015
replace SiteName ="Nahuta Disp" if SiteID==	506110016
replace SiteName ="Garam Disp" if SiteID==	506110017
replace SiteName ="Gajiwal Disp" if SiteID==	506110018
replace SiteName ="Pegin Doka Disp" if SiteID==	506110019
replace SiteName ="Butur Disp" if SiteID==	506110020
replace SiteName ="Yelwan Bashi Disp" if SiteID==	506110021
replace SiteName ="Badel MAT" if SiteID==	506110022
replace SiteName ="Dott MAT" if SiteID==	506110023
replace SiteName ="Durr Mat/PHC" if SiteID==	506110024
replace SiteName ="Lukshi MAT" if SiteID==	506110025
replace SiteName ="Bazali PHC" if SiteID==	506110026
replace SiteName ="Jalbang Disp" if SiteID==	506110027
replace SiteName ="Dumba Disp" if SiteID==	506110028
replace SiteName ="G/Dutse Disp" if SiteID==	506110029
replace SiteName ="Wandi MAT" if SiteID==	506110030
replace SiteName ="Gwaltukurwa Disp" if SiteID==	506110031
replace SiteName ="Zumbul MAT" if SiteID==	506110032
replace SiteName ="S/G/Zumbul Disp" if SiteID==	506110033
replace SiteName ="Zunbul Danri" if SiteID==	506110034
replace SiteName ="Alagarno MAT" if SiteID==	507110001
replace SiteName ="Alagarno Disp" if SiteID==	507110002
replace SiteName ="Sabon garin Disp" if SiteID==	507110003
replace SiteName ="Gadiya modern HC" if SiteID==	507110004
replace SiteName ="Gadiya Disp" if SiteID==	507110005
replace SiteName ="Gen Hosp  Gamawa" if SiteID==	507210006
replace SiteName ="Gamawa MCH" if SiteID==	507110007
replace SiteName ="Gamawa MAT" if SiteID==	507110008
replace SiteName ="Gololo modl HC" if SiteID==	507110009
replace SiteName ="Gololo Disp" if SiteID==	507110010
replace SiteName ="Garin J Saleh Disp" if SiteID==	507110011
replace SiteName ="Karba Disp" if SiteID==	507110012
replace SiteName ="Bundujara Disp" if SiteID==	507110013
replace SiteName ="Gatattara Disp" if SiteID==	507110014
replace SiteName ="Kaisawa Disp" if SiteID==	507110015
replace SiteName ="Kafiromi MAT" if SiteID==	507110016
replace SiteName ="Kafiromi Disp" if SiteID==	507110017
replace SiteName ="Supa Disp" if SiteID==	507110018
replace SiteName ="Kore Disp" if SiteID==	507110019
replace SiteName ="Adabda Disp" if SiteID==	507110020
replace SiteName ="Gangawa Disp" if SiteID==	507110021
replace SiteName ="Kubdiya MAT" if SiteID==	507110022
replace SiteName ="Kubdiya Disp" if SiteID==	507110023
replace SiteName ="Marana Disp" if SiteID==	507110024
replace SiteName ="G/mallam Disp" if SiteID==	507110025
replace SiteName ="Raga MAT" if SiteID==	507110026
replace SiteName ="Raga Disp" if SiteID==	507110027
replace SiteName ="Bakori Disp" if SiteID==	507110028
replace SiteName ="Gayawa Disp" if SiteID==	507110029
replace SiteName ="Aido Disp" if SiteID==	507110030
replace SiteName ="Buraburi Disp" if SiteID==	507110031
replace SiteName ="Taranka Disp" if SiteID==	507110032
replace SiteName ="Buraburi Disp" if SiteID==	507110033
replace SiteName ="Tarsawa MAT" if SiteID==	507110034
replace SiteName ="Tarsawa Disp" if SiteID==	507110035
replace SiteName ="Tumbi Disp CLIN" if SiteID==	507110036
replace SiteName ="Bullana Disp CLIN" if SiteID==	507110037
replace SiteName ="Kidikadi Disp CLIN" if SiteID==	507110038
replace SiteName ="Tumbi Disp CLIN" if SiteID==	507110039
replace SiteName ="Bullana Disp CLIN" if SiteID==	507110040
replace SiteName ="Kadikadi Disp CLIN" if SiteID==	507110041
replace SiteName ="Wabu MCH" if SiteID==	507110042
replace SiteName ="Wabu Disp CLIN" if SiteID==	507110043
replace SiteName ="Yada Disp CLIN" if SiteID==	507110044
replace SiteName ="Kesa Disp CLIN" if SiteID==	507110045
replace SiteName ="Duwaru Disp CLIN" if SiteID==	507110046
replace SiteName ="Udubo MCH" if SiteID==	507110047
replace SiteName ="Ubudo MCH" if SiteID==	507110048
replace SiteName ="Ubudo Disp CLIN" if SiteID==	507110049
replace SiteName ="Gwarbatu Disp CLIN" if SiteID==	507110050
replace SiteName ="Udubo Disp CLIN" if SiteID==	507110051
replace SiteName ="Zindiwa MAT" if SiteID==	507110052
replace SiteName ="Zindiwa Disp" if SiteID==	507110053
replace SiteName ="Garin Kure Disp" if SiteID==	507110054
replace SiteName ="Nabayi MAT" if SiteID==	508110001
replace SiteName ="Baya H.Post" if SiteID==	508110002
replace SiteName ="Manga Disp" if SiteID==	508110003
replace SiteName ="Nabayi Disp" if SiteID==	508110004
replace SiteName ="Marbin Disp" if SiteID==	508110005
replace SiteName ="Yanda Disp" if SiteID==	508110006
replace SiteName ="Soro PHC" if SiteID==	508110007
replace SiteName ="Hameed HC" if SiteID==	508120008
replace SiteName ="Soro Nursing Home" if SiteID==	508120009
replace SiteName ="Gangura MAT" if SiteID==	508110010
replace SiteName ="Gangura Disp" if SiteID==	508110011
replace SiteName ="Buri-buri Disp" if SiteID==	508110012
replace SiteName ="Gabi Disp" if SiteID==	508110013
replace SiteName ="Kediya Disp" if SiteID==	508110014
replace SiteName ="Danduwo MAT" if SiteID==	508110015
replace SiteName ="Danduwo Disp" if SiteID==	508110016
replace SiteName ="UNG YAMMA HC" if SiteID==	508110017
replace SiteName ="L/liman Disp" if SiteID==	508110018
replace SiteName ="Tafazuwa Disp" if SiteID==	508110019
replace SiteName ="Ringim Disp" if SiteID==	508110020
replace SiteName ="Gen Hosp Kafin Madaiki" if SiteID==	508210021
replace SiteName ="S/kariya MAT" if SiteID==	508110022
replace SiteName ="H/tafi MAT " if SiteID==	508110023
replace SiteName ="Wushi H Post" if SiteID==	508110024
replace SiteName ="Mararraba H.Post" if SiteID==	508110025
replace SiteName ="Kariya Disp" if SiteID==	508110026
replace SiteName ="S/kariya Disp" if SiteID==	508110027
replace SiteName ="Y/gada Disp" if SiteID==	508110028
replace SiteName ="Zida Disp" if SiteID==	508110029
replace SiteName ="H/tafi Disp" if SiteID==	508110030
replace SiteName ="G/kawari MAT" if SiteID==	508110031
replace SiteName ="Maizuma Disp" if SiteID==	508110032
replace SiteName ="T/tabo Disp" if SiteID==	508110033
replace SiteName ="Bunga Disp" if SiteID==	508110034
replace SiteName ="Kubi MAT" if SiteID==	508110035
replace SiteName ="Kubi Disp" if SiteID==	508110036
replace SiteName ="Shila Disp" if SiteID==	508110037
replace SiteName ="Damaguza Disp" if SiteID==	508110038
replace SiteName ="Duma Disp" if SiteID==	508110039
replace SiteName ="Zalanga MAT" if SiteID==	508110040
replace SiteName ="Zalanga Disp" if SiteID==	508110041
replace SiteName ="Dirya Disp" if SiteID==	508110042
replace SiteName ="Wailo Disp" if SiteID==	508110043
replace SiteName ="Yaga Disp" if SiteID==	508110044
replace SiteName ="Miya HC" if SiteID==	508110045
replace SiteName ="Hameed HC" if SiteID==	508120046
replace SiteName ="Miya MPHC" if SiteID==	508110047
replace SiteName ="Zara MAT" if SiteID==	508110048
replace SiteName ="Burku MAT" if SiteID==	508110049
replace SiteName ="Zara Disp" if SiteID==	508110050
replace SiteName ="Tsagu Disp" if SiteID==	508110051
replace SiteName ="K/wudufa Disp" if SiteID==	508110052
replace SiteName ="Lulai Disp" if SiteID==	508110053
replace SiteName ="Gameru Disp" if SiteID==	508110054
replace SiteName ="Dabe MAT" if SiteID==	508110055
replace SiteName ="Gidan waya MAT" if SiteID==	508110056
replace SiteName ="Dabe Disp" if SiteID==	508110057
replace SiteName ="Gidan waya Disp" if SiteID==	508110058
replace SiteName ="Nassarawa MAT" if SiteID==	508110059
replace SiteName ="Siyi Disp" if SiteID==	508110060
replace SiteName ="Loyi Disp" if SiteID==	508110061
replace SiteName ="Buzim Disp" if SiteID==	508110062
replace SiteName ="Lafiyari Disp" if SiteID==	508110063
replace SiteName ="Yali MAT" if SiteID==	508110064
replace SiteName ="Firo MAT" if SiteID==	508110065
replace SiteName ="Sakarumbu H.Post" if SiteID==	508110066
replace SiteName ="Digawan Maigari H.Post" if SiteID==	508110067
replace SiteName ="Dumun Disp" if SiteID==	508110068
replace SiteName ="Yuli Disp" if SiteID==	508110069
replace SiteName ="Badaromo Disp" if SiteID==	508110070
replace SiteName ="Abunari MAT" if SiteID==	509110001
replace SiteName ="Abunari Disp" if SiteID==	509110002
replace SiteName ="Mailamalari Disp" if SiteID==	509110003
replace SiteName ="Chinkani Disp" if SiteID==	509110004
replace SiteName ="Jarmawo Disp" if SiteID==	509110005
replace SiteName ="Dogiwa Disp" if SiteID==	509110006
replace SiteName ="Takwaye Disp" if SiteID==	509110007
replace SiteName ="Gulbun Disp" if SiteID==	509110008
replace SiteName ="Faguji MAT" if SiteID==	509110009
replace SiteName ="Faguji Disp" if SiteID==	509110010
replace SiteName ="Giade Gen Hosp" if SiteID==	509210011
replace SiteName ="Giade MAT" if SiteID==	509110012
replace SiteName ="Giade Disp" if SiteID==	509110013
replace SiteName ="Namu CLIN & MAT" if SiteID==	509120014
replace SiteName ="Yandore MAT" if SiteID==	509110015
replace SiteName ="Zindiri Disp" if SiteID==	509110016
replace SiteName ="Yandore Disp" if SiteID==	509110017
replace SiteName ="Kafin Hardo Disp" if SiteID==	509110018
replace SiteName ="Isawa PHC" if SiteID==	509110019
replace SiteName ="Ganduha Disp" if SiteID==	509110020
replace SiteName ="Jawo Disp" if SiteID==	509110021
replace SiteName ="Yarimari Disp" if SiteID==	509110022
replace SiteName ="Jugugu Disp" if SiteID==	509110023
replace SiteName ="Kurba MAT" if SiteID==	509110024
replace SiteName ="Kurba Disp" if SiteID==	509110025
replace SiteName ="Kayakaya Disp" if SiteID==	509110026
replace SiteName ="Sabon Sara Disp" if SiteID==	509110027
replace SiteName ="Bombiyo Disp" if SiteID==	509110028
replace SiteName ="Uzum Disp" if SiteID==	509110029
replace SiteName ="Jahuri Disp" if SiteID==	509110030
replace SiteName ="Korawa Disp" if SiteID==	509110031
replace SiteName ="Zabi Model PHC" if SiteID==	509110032
replace SiteName ="Kimari Disp" if SiteID==	509110033
replace SiteName ="Rumbuna Disp" if SiteID==	509110034
replace SiteName ="Zirami Disp" if SiteID==	509110035
replace SiteName ="Magarya Disp" if SiteID==	509110036
replace SiteName ="Laila Disp" if SiteID==	509110037
replace SiteName ="Jarmawa Disp" if SiteID==	509110038
replace SiteName ="G/Kwari H.Post" if SiteID==	510110001
replace SiteName ="Abdallawa Disp" if SiteID==	510110002
replace SiteName ="Garin Dole H.Post" if SiteID==	510110003
replace SiteName ="Duhuwa " if SiteID==	510110004
replace SiteName ="Bambal Disp" if SiteID==	510110005
replace SiteName ="G/Ganji MAT" if SiteID==	510110006
replace SiteName ="Yarayi H.Post" if SiteID==	510110007
replace SiteName ="Buzawa H.Post" if SiteID==	510110008
replace SiteName ="G/Ganji Disp" if SiteID==	510110009
replace SiteName ="Babuguchi Disp" if SiteID==	510110010
replace SiteName ="Gadau MAT" if SiteID==	510110011
replace SiteName ="Walai Disp" if SiteID==	510110012
replace SiteName ="Gululu H.Post" if SiteID==	510110013
replace SiteName ="Gamsha Disp" if SiteID==	510110014
replace SiteName ="Gayara Disp" if SiteID==	510110015
replace SiteName ="Kofata H.Post" if SiteID==	510110016
replace SiteName ="Fango H.Post" if SiteID==	510110017
replace SiteName ="Gwarai Disp" if SiteID==	510110018
replace SiteName ="Gen Hosp" if SiteID==	510210019
replace SiteName ="Itas Town MAT" if SiteID==	510110020
replace SiteName ="Itas Town Disp" if SiteID==	510110021
replace SiteName ="Surfe H.Post" if SiteID==	510110022
replace SiteName ="Kana Deri H.Post" if SiteID==	510110023
replace SiteName ="Kashuri Disp" if SiteID==	510110024
replace SiteName ="Lizai Dipensary" if SiteID==	510110025
replace SiteName ="Magarya P.H.C" if SiteID==	510110026
replace SiteName ="Majiya H.Post" if SiteID==	510110027
replace SiteName ="Mashema MAT" if SiteID==	510110028
replace SiteName ="Momari H.Post" if SiteID==	510110029
replace SiteName ="Melamdige Dispenary" if SiteID==	510110030
replace SiteName ="Atafowa MAT" if SiteID==	510110031
replace SiteName ="Zubuki H.Post" if SiteID==	510110032
replace SiteName ="Gulmo H.Post" if SiteID==	510110033
replace SiteName ="Sharifari H.Post" if SiteID==	510110034
replace SiteName ="Atafowa Disp" if SiteID==	510110035
replace SiteName ="Dogon Jeji HC" if SiteID==	511110001
replace SiteName ="Mabai MAT" if SiteID==	511110002
replace SiteName ="Sabon Kafi Disp" if SiteID==	511110003
replace SiteName ="Marmaniji Disp" if SiteID==	511110004
replace SiteName ="Arawa Disp" if SiteID==	511110005
replace SiteName ="Gongo Disp" if SiteID==	511110006
replace SiteName ="Gilar Disp" if SiteID==	511110007
replace SiteName ="Galdimari HC" if SiteID==	511110008
replace SiteName ="Baburti Disp" if SiteID==	511110009
replace SiteName ="Beddorgel Disp" if SiteID==	511110010
replace SiteName ="Sharaba Disp" if SiteID==	511110011
replace SiteName ="Hanafari MPHC" if SiteID==	511110012
replace SiteName ="Gudu Disp" if SiteID==	511110013
replace SiteName ="Kunjeri Disp" if SiteID==	511110014
replace SiteName ="Town MAT" if SiteID==	511110015
replace SiteName ="Yahaya CLIN & Mat." if SiteID==	511120016
replace SiteName ="Jama’are HC" if SiteID==	511120017
replace SiteName ="Government Health Office" if SiteID==	511210018
replace SiteName ="Jurara MAT" if SiteID==	511110019
replace SiteName ="Jurara Disp" if SiteID==	511110020
replace SiteName ="Garin Babani Disp" if SiteID==	511110021
replace SiteName ="Fetere Disp" if SiteID==	511110022
replace SiteName ="Lariye Disp" if SiteID==	511110023
replace SiteName ="Kamaku Disp" if SiteID==	511110024
replace SiteName ="Yan'gamai Disp" if SiteID==	511110025
replace SiteName ="Yola Disp" if SiteID==	511110026
replace SiteName ="Jobbori Disp" if SiteID==	511110027
replace SiteName ="Bidir MAT" if SiteID==	512110001
replace SiteName ="Bidir Disp" if SiteID==	512110002
replace SiteName ="Bulkachuwa Mat/PHC" if SiteID==	512110003
replace SiteName ="Busuri Disp" if SiteID==	512110004
replace SiteName ="Buskuri MAT" if SiteID==	512110005
replace SiteName ="Buskuri Disp" if SiteID==	512110006
replace SiteName ="Gambaki Disp" if SiteID==	512110007
replace SiteName ="Adamoyel Disp" if SiteID==	512110008
replace SiteName ="Chinade PHC" if SiteID==	512110009
replace SiteName ="Chinade MAT" if SiteID==	512110010
replace SiteName ="Badderi" if SiteID==	512110011
replace SiteName ="Dagaro" if SiteID==	512110012
replace SiteName ="Maderi" if SiteID==	512110013
replace SiteName ="Gangai MAT" if SiteID==	512110014
replace SiteName ="Gangai Disp" if SiteID==	512110015
replace SiteName ="Zindi Disp" if SiteID==	512110016
replace SiteName ="Dagayari Disp" if SiteID==	512110017
replace SiteName ="Gen Hosp Azare" if SiteID==	512210018
replace SiteName ="Makarahuta MAT" if SiteID==	512110019
replace SiteName ="Urban MAT" if SiteID==	512110020
replace SiteName ="Katsalle Disp" if SiteID==	512110021
replace SiteName ="Madachi Disp" if SiteID==	512110022
replace SiteName ="Masaku Disp" if SiteID==	512110023
replace SiteName ="Madangala Disp" if SiteID==	512110024
replace SiteName ="Kazunu Disp" if SiteID==	512110025
replace SiteName ="Chara Chara Disp" if SiteID==	512110026
replace SiteName ="Madara HC" if SiteID==	512110027
replace SiteName ="Madara MAT" if SiteID==	512110028
replace SiteName ="Madara Disp" if SiteID==	512110029
replace SiteName ="Lariski Disp" if SiteID==	512110030
replace SiteName ="Jumberi Disp" if SiteID==	512110031
replace SiteName ="Garin Kauli Disp" if SiteID==	512110032
replace SiteName ="Matsango MAT" if SiteID==	512110033
replace SiteName ="Fed. Med CENT Azare" if SiteID==	512310034
replace SiteName ="Jidy Surgical Center" if SiteID==	512120035
replace SiteName ="Jama’are CLIN Azare" if SiteID==	512120036
replace SiteName ="Shifa’a Med. CLIN" if SiteID==	512120037
replace SiteName ="Amana Med. CLIN" if SiteID==	512120038
replace SiteName ="Maini’ima Consult. CLIN" if SiteID==	512120039
replace SiteName ="Gwasamai MPHC" if SiteID==	512110040
replace SiteName ="Ragwam MAT" if SiteID==	512110041
replace SiteName ="Ragwam Disp" if SiteID==	512110042
replace SiteName ="Town MAT" if SiteID==	512110043
replace SiteName ="Yayu MPHC" if SiteID==	512110044
replace SiteName ="Kafin Margai MAT" if SiteID==	513110001
replace SiteName ="Dembori MAT" if SiteID==	513110002
replace SiteName ="Badara HC" if SiteID==	513110003
replace SiteName ="Kalajanga matermity" if SiteID==	513110004
replace SiteName ="Balankanawa MAT" if SiteID==	513110005
replace SiteName ="Ribangarmu MAT" if SiteID==	513110006
replace SiteName ="Guyaba HC" if SiteID==	513110007
replace SiteName ="Kafin-iya HC" if SiteID==	513110008
replace SiteName ="Kwagal MAT" if SiteID==	513110009
replace SiteName ="Kaloma MAT" if SiteID==	513110010
replace SiteName ="Sharfuri MAT" if SiteID==	513110011
replace SiteName ="Lomi  MAT" if SiteID==	513110012
replace SiteName ="Shongo MAT" if SiteID==	513110013
replace SiteName ="Tubule HC" if SiteID==	513110014
replace SiteName ="Tashan Turmi MAT" if SiteID==	513110015
replace SiteName ="Bani MAT" if SiteID==	513110016
replace SiteName ="Bara HC" if SiteID==	513110017
replace SiteName ="Beni HC" if SiteID==	513110018
replace SiteName ="Garin Sale Maimaciji HC" if SiteID==	513110019
replace SiteName ="Boli MAT" if SiteID==	513110020
replace SiteName ="Dewu HC" if SiteID==	513110021
replace SiteName ="Golo MAT" if SiteID==	513110022
replace SiteName ="Kirfi Gen Hosp" if SiteID==	513210023
replace SiteName ="School CLIN GESKA" if SiteID==	513110024
replace SiteName ="Lariski HC" if SiteID==	513110025
replace SiteName ="Shongo HC" if SiteID==	513110026
replace SiteName ="Kafin Sarkin Yaki HC" if SiteID==	513110027
replace SiteName ="Wanka HC" if SiteID==	513110028
replace SiteName ="Baba Disp" if SiteID==	513110029
replace SiteName ="Kumbi Disp" if SiteID==	513110030
replace SiteName ="Balankanawa Disp" if SiteID==	513110031
replace SiteName ="Sharaba Disp" if SiteID==	513110032
replace SiteName ="Rugar-jalo Disp" if SiteID==	513110033
replace SiteName ="Gula Disp" if SiteID==	513110034
replace SiteName ="Kirfi-sama Disp" if SiteID==	513110035
replace SiteName ="Garin muazu Disp" if SiteID==	513110036
replace SiteName ="Kadolli Disp" if SiteID==	513110037
replace SiteName ="Bure Disp" if SiteID==	513110038
replace SiteName ="Taure Disp" if SiteID==	513110039
replace SiteName ="Zongoma Disp" if SiteID==	513110040
replace SiteName ="Feltum Disp" if SiteID==	513110041
replace SiteName ="Kirfi Town MAT" if SiteID==	513110042
replace SiteName ="Mainari PHC" if SiteID==	514110001
replace SiteName ="Ajili Disp" if SiteID==	514110002
replace SiteName ="Zindi Disp" if SiteID==	514110003
replace SiteName ="Dunkin Kasuwa Disp" if SiteID==	514110004
replace SiteName ="Tumfure Disp" if SiteID==	514110005
replace SiteName ="Zindi MAT" if SiteID==	514110006
replace SiteName ="Akuyam MAT" if SiteID==	514110007
replace SiteName ="Akuyam Disp" if SiteID==	514110008
replace SiteName ="Madakiri MAT" if SiteID==	514110009
replace SiteName ="Shalon MAT" if SiteID==	514110010
replace SiteName ="Beti Disp" if SiteID==	514110011
replace SiteName ="Koftara Disp" if SiteID==	514110012
replace SiteName ="Nylebajam Disp" if SiteID==	514110013
replace SiteName ="Jarmari Disp" if SiteID==	514110014
replace SiteName ="Shelon Disp" if SiteID==	514110015
replace SiteName ="Madakiri Disp" if SiteID==	514110016
replace SiteName ="Dunkurami Disp" if SiteID==	514110017
replace SiteName ="Gainan Hausa MAT" if SiteID==	514110018
replace SiteName ="Gugulin Disp" if SiteID==	514110019
replace SiteName ="Balen Hausa Disp" if SiteID==	514110020
replace SiteName ="Gainan Fulani Disp" if SiteID==	514110021
replace SiteName ="Diggeri Disp" if SiteID==	514110022
replace SiteName ="Gwaram PHC" if SiteID==	514110023
replace SiteName ="Barmo Disp" if SiteID==	514110024
replace SiteName ="Farin Ruwa Disp" if SiteID==	514110025
replace SiteName ="Kafin Bubari Disp" if SiteID==	514110026
replace SiteName ="Gwaram Disp" if SiteID==	514110027
replace SiteName ="Hardawa MAT" if SiteID==	514110028
replace SiteName ="Hardawa Disp" if SiteID==	514110029
replace SiteName ="Jarkasa Disp" if SiteID==	514110030
replace SiteName ="Jabdo Disp" if SiteID==	514110031
replace SiteName ="Hausari Disp" if SiteID==	514110032
replace SiteName ="Kafin Suleh Disp" if SiteID==	514110033
replace SiteName ="Gen Hosp Misau" if SiteID==	514210034
replace SiteName ="North Disp" if SiteID==	514110035
replace SiteName ="Misau Town MAT" if SiteID==	514110036
replace SiteName ="Bangarati Disp" if SiteID==	514110037
replace SiteName ="Dabsi Disp" if SiteID==	514110038
replace SiteName ="Chabai Disp" if SiteID==	514110039
replace SiteName ="Central Disp" if SiteID==	514110040
replace SiteName ="Sarma Disp" if SiteID==	514110041
replace SiteName ="Kafin Zaka Disp" if SiteID==	514110042
replace SiteName ="Yelwa Sarman Disp" if SiteID==	514110043
replace SiteName ="Sirko Disp" if SiteID==	514110044
replace SiteName ="Ngoyinga Disp" if SiteID==	514110045
replace SiteName ="Waliya Disp" if SiteID==	514110046
replace SiteName ="Dabji Disp" if SiteID==	514110047
replace SiteName ="Dallari Disp" if SiteID==	514110048
replace SiteName ="Jabalya Disp" if SiteID==	514110049
replace SiteName ="Zadawa MAT" if SiteID==	514110050
replace SiteName ="Zadawa Disp" if SiteID==	514110051
replace SiteName ="Nammare Disp" if SiteID==	514110052
replace SiteName ="Gen Hosp Burra" if SiteID==	515210001
replace SiteName ="Tsangaya Muel Health HC" if SiteID==	515110002
replace SiteName ="Ari HC" if SiteID==	515110003
replace SiteName ="Masussuka HC" if SiteID==	515110004
replace SiteName ="Kafin Lemo Disp" if SiteID==	515110005
replace SiteName ="Shuwaki Disp" if SiteID==	515110006
replace SiteName ="Aguwar Maji Disp" if SiteID==	515110007
replace SiteName ="T/Jarkoya Disp" if SiteID==	515110008
replace SiteName ="Deru Disp" if SiteID==	515110009
replace SiteName ="Balma MAT" if SiteID==	515110010
replace SiteName ="Nasaru Model P.H.C. CENT" if SiteID==	515110011
replace SiteName ="Iyayi Disp" if SiteID==	515110012
replace SiteName ="Kauyen Kayel Disp" if SiteID==	515110013
replace SiteName ="Ruwan Kanki Disp" if SiteID==	515110014
replace SiteName ="Nasaru Disp" if SiteID==	515110015
replace SiteName ="Zazika Disp" if SiteID==	515110016
replace SiteName ="Gidan Baki Disp" if SiteID==	515110017
replace SiteName ="Balma Disp" if SiteID==	515110018
replace SiteName ="Gadarmaiwa HC" if SiteID==	515120019
replace SiteName ="Nasaru HC" if SiteID==	515120020
replace SiteName ="Ningi Gen Hosp Ningi" if SiteID==	515210021
replace SiteName ="Ningi Town MAT" if SiteID==	515110022
replace SiteName ="Magami Disp" if SiteID==	515110023
replace SiteName ="Kajala Disp" if SiteID==	515110024
replace SiteName ="Ningi Town Disp" if SiteID==	515110025
replace SiteName ="Burra Disp" if SiteID==	515110026
replace SiteName ="Ningi CLIN & Mat" if SiteID==	515120027
replace SiteName ="Danbaba CLIN & Mat" if SiteID==	515120028
replace SiteName ="Yadagungume Model  HC" if SiteID==	515110029
replace SiteName ="Bashe MAT" if SiteID==	515110030
replace SiteName ="Ung. Madaki Disp" if SiteID==	515110031
replace SiteName ="Dabarbaga Disp" if SiteID==	515110032
replace SiteName ="Diwa Disp" if SiteID==	515110033
replace SiteName ="Ringya Disp" if SiteID==	515110034
replace SiteName ="Yadagungume Disp" if SiteID==	515110035
replace SiteName ="Kwangi Disp" if SiteID==	515110036
replace SiteName ="Bashe Disp" if SiteID==	515110037
replace SiteName ="Gadar Maiwa MAT" if SiteID==	515110038
replace SiteName ="Kwalangwadi MAT" if SiteID==	515110039
replace SiteName ="Katsinawa HC" if SiteID==	515110040
replace SiteName ="Gwam HC" if SiteID==	515110041
replace SiteName ="Rumbu Disp" if SiteID==	515110042
replace SiteName ="Tuwashi Disp" if SiteID==	515110043
replace SiteName ="Tashar Majee Disp" if SiteID==	515110044
replace SiteName ="Gadar Maiwa Disp" if SiteID==	515110045
replace SiteName ="Zakara Disp" if SiteID==	515110046
replace SiteName ="Kafin Zaki Disp" if SiteID==	515110047
replace SiteName ="Dingis Disp" if SiteID==	515110048
replace SiteName ="Jimi MAT" if SiteID==	515110049
replace SiteName ="Kurmi MAT" if SiteID==	515110050
replace SiteName ="Batu HC" if SiteID==	515110051
replace SiteName ="Tabula Disp" if SiteID==	515110052
replace SiteName ="Rafin Ciyawa Disp" if SiteID==	515110053
replace SiteName ="Dogon Ruwa Disp" if SiteID==	515110054
replace SiteName ="Kurim Disp" if SiteID==	515110055
replace SiteName ="Dana Disp" if SiteID==	515110056
replace SiteName ="Ganji Disp" if SiteID==	515110057
replace SiteName ="Jimi Disp" if SiteID==	515110058
replace SiteName ="Andubun MAT" if SiteID==	516110001
replace SiteName ="Andubun Disp" if SiteID==	516110002
replace SiteName ="Isore Disp" if SiteID==	516110003
replace SiteName ="Bangire Disp" if SiteID==	516110004
replace SiteName ="Dago Disp" if SiteID==	516110005
replace SiteName ="Jahn Disp" if SiteID==	516110006
replace SiteName ="Beli MAT" if SiteID==	516110007
replace SiteName ="Beli Disp" if SiteID==	516110008
replace SiteName ="Bukul Disp" if SiteID==	516110009
replace SiteName ="Baliam Disp" if SiteID==	516110010
replace SiteName ="Dango Disp" if SiteID==	516110011
replace SiteName ="Rimi Disp" if SiteID==	516110012
replace SiteName ="Disina PHC" if SiteID==	516110013
replace SiteName ="Disina Disp" if SiteID==	516110014
replace SiteName ="Gurmaw Disp" if SiteID==	516110015
replace SiteName ="Adamani Disp" if SiteID==	516110016
replace SiteName ="Sawi Disp" if SiteID==	516110017
replace SiteName ="Foggo mat/PHC" if SiteID==	516110018
replace SiteName ="Nahuce MAT" if SiteID==	516110019
replace SiteName ="Zigan Disp" if SiteID==	516110020
replace SiteName ="Gargidiba Disp" if SiteID==	516110021
replace SiteName ="Ganuwa Disp" if SiteID==	516110022
replace SiteName ="Bono Disp" if SiteID==	516110023
replace SiteName ="Kilbori Disp" if SiteID==	516110024
replace SiteName ="Kargo Disp" if SiteID==	516110025
replace SiteName ="Jama'a Disp" if SiteID==	516110026
replace SiteName ="Sambumal Disp" if SiteID==	516110027
replace SiteName ="Katabuwa Disp" if SiteID==	516110028
replace SiteName ="Kafin gara Disp" if SiteID==	516110029
replace SiteName ="Shira Disp" if SiteID==	516110030
replace SiteName ="Eldewo Disp" if SiteID==	516110031
replace SiteName ="Tsafi MAT" if SiteID==	516110032
replace SiteName ="Tsafi Disp" if SiteID==	516110033
replace SiteName ="Ligada Disp" if SiteID==	516110034
replace SiteName ="Zawabari Disp" if SiteID==	516110035
replace SiteName ="Sorodo MAT" if SiteID==	516110036
replace SiteName ="Tumfafi Disp" if SiteID==	516110037
replace SiteName ="Gazan tumfafi Disp" if SiteID==	516110038
replace SiteName ="Yana Gen Hosp" if SiteID==	516210039
replace SiteName ="Yana MAT" if SiteID==	516110040
replace SiteName ="Yana HC" if SiteID==	516110041
replace SiteName ="Zubo Disp" if SiteID==	516110042
replace SiteName ="Darajiya Disp" if SiteID==	516110043
replace SiteName ="Kwanjin Disp" if SiteID==	516110044
replace SiteName ="Darajiwo Disp" if SiteID==	516110045
replace SiteName ="Bulan Gawo MAT" if SiteID==	517110001
replace SiteName ="Bulan Gawo Disp" if SiteID==	517110002
replace SiteName ="Jambil Disp" if SiteID==	517110003
replace SiteName ="Gital MAT" if SiteID==	517110004
replace SiteName ="Shall Disp" if SiteID==	517110005
replace SiteName ="Gital Disp" if SiteID==	517110006
replace SiteName ="Bununu PHC" if SiteID==	517110007
replace SiteName ="Bununu MAT" if SiteID==	517110008
replace SiteName ="Bar MAT" if SiteID==	517110009
replace SiteName ="Bar Disp" if SiteID==	517110010
replace SiteName ="Lim Disp" if SiteID==	517110011
replace SiteName ="Bamja Dipensary" if SiteID==	517110012
replace SiteName ="Dajin MAT" if SiteID==	517110013
replace SiteName ="Katsinawa MAT" if SiteID==	517110014
replace SiteName ="Dajin Disp" if SiteID==	517110015
replace SiteName ="Katsinawa Disp" if SiteID==	517110016
replace SiteName ="Dull PHC" if SiteID==	517110017
replace SiteName ="Burga MAT" if SiteID==	517110018
replace SiteName ="Wurno HC" if SiteID==	517110019
replace SiteName ="Kardam MAT" if SiteID==	517110020
replace SiteName ="Kundum MAT" if SiteID==	517110021
replace SiteName ="Kardam Disp" if SiteID==	517110022
replace SiteName ="Kundum Disp" if SiteID==	517110023
replace SiteName ="Boto Gen Hosp" if SiteID==	517210024
replace SiteName ="Boto Disp" if SiteID==	517110025
replace SiteName ="Maijuju Disp" if SiteID==	517110026
replace SiteName ="Zari Disp" if SiteID==	517110027
replace SiteName ="Darahji Disp" if SiteID==	517110028
replace SiteName ="Lere PHC" if SiteID==	517110029
replace SiteName ="Sigdin Shehu Disp" if SiteID==	517110030
replace SiteName ="Ngebiji Disp" if SiteID==	517110031
replace SiteName ="Sara Disp" if SiteID==	517110032
replace SiteName ="Martin Daji Disp" if SiteID==	517110033
replace SiteName ="Mball MAT" if SiteID==	517110034
replace SiteName ="S/Gida HC" if SiteID==	517110035
replace SiteName ="Wurogeje Disp" if SiteID==	517110036
replace SiteName ="Mball Disp" if SiteID==	517110037
replace SiteName ="Yola Nora Disp" if SiteID==	517110038
replace SiteName ="Burwat Disp" if SiteID==	517110039
replace SiteName ="Yola Nora MAT" if SiteID==	517110040
replace SiteName ="Tapshin MPHC" if SiteID==	517110041
replace SiteName ="Duklin Bauchi MAT" if SiteID==	517110042
replace SiteName ="Gambar HC" if SiteID==	517110043
replace SiteName ="Zwall MAT" if SiteID==	517110044
replace SiteName ="Gori MAT" if SiteID==	517110045
replace SiteName ="Gwashe Disp" if SiteID==	517110046
replace SiteName ="Zwall Disp" if SiteID==	517110047
replace SiteName ="Gori Disp" if SiteID==	517110048
replace SiteName ="Tafawa-Balewa Gen Hosp" if SiteID==	517210049
replace SiteName ="T/Balewa MAT" if SiteID==	517110050
replace SiteName ="Tafore HC" if SiteID==	517110051
replace SiteName ="GGSS HC" if SiteID==	517110052
replace SiteName ="Jama'a MAT" if SiteID==	518110001
replace SiteName ="Tashin dirimi MAT" if SiteID==	518110002
replace SiteName ="Jama'a Disp" if SiteID==	518110003
replace SiteName ="Wom Disp" if SiteID==	518110004
replace SiteName ="Tashan dirimi Disp" if SiteID==	518110005
replace SiteName ="Mainasara Nursing Home" if SiteID==	518120006
replace SiteName ="Kowa HC" if SiteID==	518120007
replace SiteName ="Amarks HC" if SiteID==	518120008
replace SiteName ="Rinji HC" if SiteID==	518120009
replace SiteName ="Lame MAT" if SiteID==	518110010
replace SiteName ="Jonge MAT" if SiteID==	518110011
replace SiteName ="Saminakan gwa MAT" if SiteID==	518110012
replace SiteName ="Lame Disp" if SiteID==	518110013
replace SiteName ="Gukka Disp" if SiteID==	518110014
replace SiteName ="Shau Disp" if SiteID==	518110015
replace SiteName ="Jonge Disp" if SiteID==	518110016
replace SiteName ="Fatira Disp" if SiteID==	518110017
replace SiteName ="Rimin zayam MAT" if SiteID==	518110018
replace SiteName ="Rimin zdyan Disp" if SiteID==	518110019
replace SiteName ="Taka bunde Disp" if SiteID==	518110020
replace SiteName ="Sutumi Disp" if SiteID==	518110021
replace SiteName ="Rinjin gingin Disp" if SiteID==	518110022
replace SiteName ="Mara Disp" if SiteID==	518110023
replace SiteName ="Zakshi MAT" if SiteID==	518110024
replace SiteName ="Gandi MAT" if SiteID==	518110025
replace SiteName ="Kufai MAT" if SiteID==	518110026
replace SiteName ="Zakshi Disp" if SiteID==	518110027
replace SiteName ="Sabon garin zakshi Disp" if SiteID==	518110028
replace SiteName ="Zari maku Disp" if SiteID==	518110029
replace SiteName ="Kufai Disp" if SiteID==	518110030
replace SiteName ="Palama Disp" if SiteID==	518110031
replace SiteName ="Nasarawa samanja" if SiteID==	518110032
replace SiteName ="Matawai" if SiteID==	518110033
replace SiteName ="Rahama" if SiteID==	518110034
replace SiteName ="Makana Disp" if SiteID==	518110035
replace SiteName ="Gana" if SiteID==	518110036
replace SiteName ="Wurno" if SiteID==	518110037
replace SiteName ="Samanja" if SiteID==	518110038
replace SiteName ="Rauta MAT" if SiteID==	518110039
replace SiteName ="Nahuta MAT" if SiteID==	518110040
replace SiteName ="Felun abba MAT" if SiteID==	518110041
replace SiteName ="Gasuro MAT" if SiteID==	518110042
replace SiteName ="Rauta Disp" if SiteID==	518110043
replace SiteName ="Nahuta Disp" if SiteID==	518110044
replace SiteName ="Runtu Disp" if SiteID==	518110045
replace SiteName ="Felun abba Disp" if SiteID==	518110046
replace SiteName ="Geji Disp" if SiteID==	518110047
replace SiteName ="Natsira Disp" if SiteID==	518110048
replace SiteName ="Bakin ruwa Disp" if SiteID==	518110049
replace SiteName ="Biciti Disp" if SiteID==	518110050
replace SiteName ="Rinji MAT" if SiteID==	518110051
replace SiteName ="Rinji Disp" if SiteID==	518110052
replace SiteName ="Danmaigoro HOSP" if SiteID==	518120053
replace SiteName ="Khadija M. HC" if SiteID==	518120054
replace SiteName ="Salarma Disp" if SiteID==	518110055
replace SiteName ="Ganye MAT" if SiteID==	518110056
replace SiteName ="Gwalfada MAT" if SiteID==	518110057
replace SiteName ="Tudun wada ribina Disp" if SiteID==	518110058
replace SiteName ="Ganye Disp" if SiteID==	518110059
replace SiteName ="Rishi PHC" if SiteID==	518110060
replace SiteName ="Wundi MAT" if SiteID==	518110061
replace SiteName ="Dababe Disp" if SiteID==	518110062
replace SiteName ="Zukku Disp" if SiteID==	518110063
replace SiteName ="Tulu MAT" if SiteID==	518110064
replace SiteName ="Guraka Disp" if SiteID==	518110065
replace SiteName ="Tulu Disp" if SiteID==	518110066
replace SiteName ="Sabongari Disp" if SiteID==	518110067
replace SiteName ="Dinga Disp" if SiteID==	518110068
replace SiteName ="Burku Disp" if SiteID==	518110069
replace SiteName ="Makana Disp" if SiteID==	518110070
replace SiteName ="Tilde MAT" if SiteID==	518110071
replace SiteName ="Tilde Disp" if SiteID==	518110072
replace SiteName ="Sabon garin Disp" if SiteID==	518110073
replace SiteName ="Tumu Disp" if SiteID==	518110074
replace SiteName ="Bujiyel Disp" if SiteID==	518110075
replace SiteName ="Lafiya Nursing Home" if SiteID==	518120076
replace SiteName ="Taimako Nursing Home" if SiteID==	518120077
replace SiteName ="Rahusa CLIN & Mat." if SiteID==	518120078
replace SiteName ="Kowa HC & Mat." if SiteID==	518120079
replace SiteName ="Nasabi CLIN & Mat" if SiteID==	518120080
replace SiteName ="Toro Gen Hosp" if SiteID==	518210081
replace SiteName ="Toro MAT" if SiteID==	518110082
replace SiteName ="Magama MAT" if SiteID==	518110083
replace SiteName ="Polchi MAT" if SiteID==	518110084
replace SiteName ="Toro Disp" if SiteID==	518110085
replace SiteName ="Loro Disp" if SiteID==	518110086
replace SiteName ="Kere Disp" if SiteID==	518110087
replace SiteName ="Buka tulai MAT" if SiteID==	518110088
replace SiteName ="Buka tulai Disp" if SiteID==	518110089
replace SiteName ="Balorabe Disp" if SiteID==	518110090
replace SiteName ="Polchi Disp" if SiteID==	518110091
replace SiteName ="Tashan mai allo" if SiteID==	518110092
replace SiteName ="Magamu cari Disp" if SiteID==	518110093
replace SiteName ="Tashan maitolare Disp" if SiteID==	518110094
replace SiteName ="Kochey Disp el" if SiteID==	518110095
replace SiteName ="Yakanaji Disp" if SiteID==	518110096
replace SiteName ="Rinjin murur Disp" if SiteID==	518110097
replace SiteName ="Gumau MAT" if SiteID==	518110098
replace SiteName ="Gumau Disp" if SiteID==	518110099
replace SiteName ="Pingel Disp" if SiteID==	518110100
replace SiteName ="Ririwan dalma Disp" if SiteID==	518110101
replace SiteName ="Didin Disp" if SiteID==	518110102
replace SiteName ="Gel joule MAT" if SiteID==	518110103
replace SiteName ="Badikko Disp" if SiteID==	518110104
replace SiteName ="Bakin Kogi Disp" if SiteID==	518110105
replace SiteName ="PHC" if SiteID==	518110106
replace SiteName ="Moho MAT" if SiteID==	518110107
replace SiteName ="Chidiya Disp" if SiteID==	518110108
replace SiteName ="Rinjin Disp" if SiteID==	518110109
replace SiteName ="Moho Disp" if SiteID==	518110110
replace SiteName ="Zaranda MAT" if SiteID==	518110111
replace SiteName ="Makera MAT" if SiteID==	518110112
replace SiteName ="Nabordo MAT" if SiteID==	518110113
replace SiteName ="Yuga MAT" if SiteID==	518110114
replace SiteName ="Sabon gari HC" if SiteID==	518110115
replace SiteName ="Zaranda Disp" if SiteID==	518110116
replace SiteName ="Kwambo Disp" if SiteID==	518110117
replace SiteName ="Makera Disp" if SiteID==	518110118
replace SiteName ="Galda Disp" if SiteID==	518110119
replace SiteName ="Nabordo Disp" if SiteID==	518110120
replace SiteName ="Mundu Disp" if SiteID==	518110121
replace SiteName ="Yuga Disp" if SiteID==	518110122
replace SiteName ="Kafin dilimi Disp" if SiteID==	518110123
replace SiteName ="Takandan Giwa Disp" if SiteID==	518110124
replace SiteName ="Baima MAT" if SiteID==	519110001
replace SiteName ="K/Bubuna MAT" if SiteID==	519110002
replace SiteName ="Baima Disp" if SiteID==	519110003
replace SiteName ="Lan-Lan Disp" if SiteID==	519110004
replace SiteName ="Gawa" if SiteID==	519110005
replace SiteName ="Dagu MAT" if SiteID==	519110006
replace SiteName ="Badi-Yeso MAT" if SiteID==	519110007
replace SiteName ="Bunga MAT" if SiteID==	519110008
replace SiteName ="Dagu Disp" if SiteID==	519110009
replace SiteName ="Badi-Yeso Disp" if SiteID==	519110010
replace SiteName ="Bunga Disp" if SiteID==	519110011
replace SiteName ="K/Mada" if SiteID==	519110012
replace SiteName ="Dallaji Disp" if SiteID==	519110013
replace SiteName ="Marasuwa Disp" if SiteID==	519110014
replace SiteName ="Wuha Disp" if SiteID==	519110015
replace SiteName ="K/Kanawa MAT" if SiteID==	519110016
replace SiteName ="K/Kanawa Disp" if SiteID==	519110017
replace SiteName ="Gabanga MAT" if SiteID==	519110018
replace SiteName ="Gabnga H.Post" if SiteID==	519110019
replace SiteName ="Bura Disp" if SiteID==	519110020
replace SiteName ="Town Disp" if SiteID==	519110021
replace SiteName ="Warji Gen Hosp" if SiteID==	519210022
replace SiteName ="Danina Disp" if SiteID==	519110023
replace SiteName ="Jawa MAT" if SiteID==	519110024
replace SiteName ="Tuya Disp" if SiteID==	519110025
replace SiteName ="ECWA CLIN" if SiteID==	519120026
replace SiteName ="Kankare MAT" if SiteID==	519110027
replace SiteName ="Aru Disp" if SiteID==	519110028
replace SiteName ="Rumba Model Primary Health Care Center" if SiteID==	519110029
replace SiteName ="Muda Babba MAT" if SiteID==	519110030
replace SiteName ="T/wada MAT" if SiteID==	519110031
replace SiteName ="Gidam Mada Disp" if SiteID==	519110032
replace SiteName ="T/Wada Disp" if SiteID==	519110033
replace SiteName ="Yayari Disp" if SiteID==	519110034
replace SiteName ="Ganji MAT" if SiteID==	519110035
replace SiteName ="Haya" if SiteID==	519110036
replace SiteName ="Wando Disp" if SiteID==	519110037
replace SiteName ="Disa Disp" if SiteID==	519110038
replace SiteName ="Ingila MAT" if SiteID==	519110039
replace SiteName ="Zurgwai MAT" if SiteID==	519110040
replace SiteName ="Bakwi Disp" if SiteID==	519110041
replace SiteName ="Alangawari  disp" if SiteID==	520110001
replace SiteName ="Amarmari disp" if SiteID==	520110002
replace SiteName ="Jajeri  disp" if SiteID==	520110003
replace SiteName ="Kameme  disp" if SiteID==	520110004
replace SiteName ="Ariri" if SiteID==	520110005
replace SiteName ="Alganari" if SiteID==	520110006
replace SiteName ="Ariri" if SiteID==	520110007
replace SiteName ="Bursali  MAT" if SiteID==	520110008
replace SiteName ="Bursali disp" if SiteID==	520110009
replace SiteName ="Jindu disp" if SiteID==	520110010
replace SiteName ="Tikirje disp" if SiteID==	520110011
replace SiteName ="Masaje disp" if SiteID==	520110012
replace SiteName ="Chibiyayi" if SiteID==	520110013
replace SiteName ="Chibiyayi" if SiteID==	520110014
replace SiteName ="Sandigalau" if SiteID==	520110015
replace SiteName ="M/ gumai" if SiteID==	520110016
replace SiteName ="Bakari" if SiteID==	520110017
replace SiteName ="Gadai MAT" if SiteID==	520110018
replace SiteName ="Gadai Disp" if SiteID==	520110019
replace SiteName ="Maikore Disp" if SiteID==	520110020
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
replace SiteName ="Gen Hosp Katagum" if SiteID==	520210031
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





* Borno State
replace SiteName = "ABADAM GH" if SiteID==	801210001
replace SiteName = "ABADAM H/C" if SiteID==	801110002
replace SiteName = "AREGE H/C" if SiteID==	801110003
replace SiteName = "METELE H/C" if SiteID==	801110004
replace SiteName = "TIGINI HC" if SiteID==	801110005
replace SiteName = "COCIN RHP" if SiteID==	801120006
replace SiteName = "JABULAM H/C" if SiteID==	801110007
replace SiteName = "NGAM H/C" if SiteID==	801110008
replace SiteName = "PHC M/F" if SiteID==	801110009
replace SiteName = "YAU H/C" if SiteID==	801110010
replace SiteName = "Y/ WANGO  C." if SiteID==	801110011
replace SiteName = "Gen Hosp ASKIRA" if SiteID==	802210001
replace SiteName = "FSC ASK/UBA" if SiteID==	802110002
replace SiteName = "YIMIRALI H/C" if SiteID==	802110003
replace SiteName = "NGOHI DISP" if SiteID==	802110004
replace SiteName = "KILARGAL DISP" if SiteID==	802110005
replace SiteName = " LEHO DISP" if SiteID==	802110006
replace SiteName = "NGULDE DISP" if SiteID==	802110007
replace SiteName = " GARAMBAL DISP" if SiteID==	802110008
replace SiteName = "RUMUIRGO MCH" if SiteID==	802110009
replace SiteName = "CHUL H/C" if SiteID==	802110010
replace SiteName = " WAMDEO DISP" if SiteID==	802110011
replace SiteName = "GIWI DISP" if SiteID==	802110012
replace SiteName = "UDA DISP" if SiteID==	802110013
replace SiteName = "UVU DISP" if SiteID==	802110014
replace SiteName = "UBA DISP" if SiteID==	802110015
replace SiteName = "UBA GH" if SiteID==	802210016
replace SiteName = "HUSSARA H/C" if SiteID==	802110017
replace SiteName = " LASSA GH" if SiteID==	802210018
replace SiteName = "KOPA DISP" if SiteID==	802110019
replace SiteName = " NGURTHLARU" if SiteID==	802110020
replace SiteName = "MUSA PHC" if SiteID==	802110021
replace SiteName = "DILLE DISP" if SiteID==	802110022
replace SiteName = " HUYIM DISP" if SiteID==	802110023
replace SiteName = "M/ MAJJARI" if SiteID==	803110001
replace SiteName = "BULA GALADA" if SiteID==	803110002
replace SiteName = "M / KIMERI" if SiteID==	803110003
replace SiteName = "ARMY BARRACKS" if SiteID==	803210004
replace SiteName = " AMCHAKA" if SiteID==	803110005
replace SiteName = "WALASA" if SiteID==	803110006
replace SiteName = "BAKARI" if SiteID==	803110007
replace SiteName = " ANDARA" if SiteID==	803110008
replace SiteName = " BANKI DISP" if SiteID==	803110009
replace SiteName = "UMTH BANKI" if SiteID==	803210010
replace SiteName = "TAMUWA" if SiteID==	803110011
replace SiteName = " BOGOMARI" if SiteID==	803110012
replace SiteName = " JABBARI" if SiteID==	803110013
replace SiteName = "BOJINO" if SiteID==	803110014
replace SiteName = "DIPCHARI" if SiteID==	803110015
replace SiteName = "DARA JARAL" if SiteID==	803110016
replace SiteName = "JERE" if SiteID==	803110017
replace SiteName = "GONIRI" if SiteID==	803110018
replace SiteName = "GORI KURMI" if SiteID==	803110019
replace SiteName = " JEBRA" if SiteID==	803110020
replace SiteName = "GULUMBA" if SiteID==	803110021
replace SiteName = "KASHIMERI" if SiteID==	803110022
replace SiteName = "FSP TANDARI" if SiteID==	803110023
replace SiteName = "KUMSHE" if SiteID==	803110024
replace SiteName = "BULA UMARBE" if SiteID==	803110025
replace SiteName = "GEN HOSP" if SiteID==	803210026
replace SiteName = "MCH BAMA" if SiteID==	803110027
replace SiteName = "SOYE FSP" if SiteID==	803110028
replace SiteName = "CHONGOLO" if SiteID==	803110029
replace SiteName = "MBAGA" if SiteID==	803110030
replace SiteName = "KOTE" if SiteID==	803110031
replace SiteName = "ABUJA" if SiteID==	803110032
replace SiteName = "ZANGERI" if SiteID==	803110033
replace SiteName = "BALBAYA MHC" if SiteID==	804110001
replace SiteName = "GEN. HOP BRIYEL" if SiteID==	804210002
replace SiteName = "BRIYELFSP" if SiteID==	804110003
replace SiteName = "CHEKELE DISP" if SiteID==	804110004
replace SiteName = "FIKAYEL DISP 1 " if SiteID==	804110005
replace SiteName = "FIKAYEL DISP 2" if SiteID==	804110006
replace SiteName = "G/DADI H/C" if SiteID==	804110007
replace SiteName = "M/BABA  DISP " if SiteID==	804110008
replace SiteName = "J/DALI H/C " if SiteID==	804110009
replace SiteName = "ZANGA DISP " if SiteID==	804110010
replace SiteName = "J/GOL HC" if SiteID==	804110011
replace SiteName = "KORKO DISP" if SiteID==	804110012
replace SiteName = "EYN J/ GOL" if SiteID==	804120013
replace SiteName = "G/GADO DISP  " if SiteID==	804110014
replace SiteName = "TELI H/C" if SiteID==	804110015
replace SiteName = "WUYO H/C" if SiteID==	804110016
replace SiteName = " DAMBITAM DISP" if SiteID==	804110017
replace SiteName = " GAIDAM DISP" if SiteID==	804110018
replace SiteName = " LARO DISP" if SiteID==	804110019
replace SiteName = " GUBURDE DISP" if SiteID==	804110020
replace SiteName = " CHIBRA DISP" if SiteID==	804110021
replace SiteName = "DAWAL DISP" if SiteID==	804110022
replace SiteName = " LIMANTI DISP" if SiteID==	804110023
replace SiteName = "KUKURAL DISP" if SiteID==	804110024
replace SiteName = "ZARA DISP" if SiteID==	804110025
replace SiteName = "BIU GEN HOSP" if SiteID==	805210001
replace SiteName = "ABBORT CLIN" if SiteID==	805120002
replace SiteName = "M/ HARI CLIN" if SiteID==	805120003
replace SiteName = "ARMY BARACK" if SiteID==	805110004
replace SiteName = "YAWI DISP" if SiteID==	805110005
replace SiteName = "FSP UNIT" if SiteID==	805110006
replace SiteName = "TUM DISP" if SiteID==	805110007
replace SiteName = "B.C .G DISP" if SiteID==	805110008
replace SiteName = "HIZHI DISP" if SiteID==	805110009
replace SiteName = "M/ GARAU " if SiteID==	805110010
replace SiteName = "KIMBA DISP" if SiteID==	805110011
replace SiteName = "GUR" if SiteID==	805110012
replace SiteName = "MIRINGA DISP" if SiteID==	805110013
replace SiteName = "BURAITAI DISP" if SiteID==	805110014
replace SiteName = "MADLAU DISP" if SiteID==	805110015
replace SiteName = "BETERA DISP" if SiteID==	805110016
replace SiteName = "ZUWA DISP" if SiteID==	805110017
replace SiteName = "CHARANGI DISP" if SiteID==	805110018
replace SiteName = "GUNDA DISP" if SiteID==	805110019
replace SiteName = "KORONGULUM" if SiteID==	806110001
replace SiteName = "MCH" if SiteID==	806110002
replace SiteName = "MBOAKURA DISP" if SiteID==	806110003
replace SiteName = "MBALA DISP" if SiteID==	806110004
replace SiteName = "EYN MBALALA" if SiteID==	806120005
replace SiteName = "EYN NJOMA" if SiteID==	806120006
replace SiteName = "EYN KORONGULIA" if SiteID==	806120007
replace SiteName = "NGILANG DISP" if SiteID==	806110008
replace SiteName = "BAMZIR DISP" if SiteID==	806110009
replace SiteName = "PEMI DISP" if SiteID==	806110010
replace SiteName = "EYN KAUTIKARI" if SiteID==	806220011
replace SiteName = "KAUTIKARI DISP" if SiteID==	806110012
replace SiteName = "EYN KUBURMULA" if SiteID==	806120013
replace SiteName = "KAUMUTAHYAHI" if SiteID==	806110014
replace SiteName = "KUBURMBULA" if SiteID==	806110015
replace SiteName = " MBULABAM H/F" if SiteID==	806110016
replace SiteName = "SHIKARKIR DISP" if SiteID==	806110017
replace SiteName = "GATAMARWA DISP" if SiteID==	806110018
replace SiteName = "AJIGIN HC" if SiteID==	807110001
replace SiteName = "KAYA DISP" if SiteID==	807110002
replace SiteName = "GUMSURI" if SiteID==	807110003
replace SiteName = "WAWA" if SiteID==	807110004
replace SiteName = "KORED" if SiteID==	807110005
replace SiteName = "MCH" if SiteID==	807110006
replace SiteName = "GEN HOSP" if SiteID==	807210007
replace SiteName = "KAUJI DISP" if SiteID==	807110008
replace SiteName = "S/GARI " if SiteID==	807110009
replace SiteName = "MULTE" if SiteID==	807110010
replace SiteName = "AZIR" if SiteID==	807110011
replace SiteName = "NJABA DISP" if SiteID==	807110012
replace SiteName = "KAFA DISP" if SiteID==	807110013
replace SiteName = "MULGO DISP" if SiteID==	807110014
replace SiteName = "BA'ALE DISP" if SiteID==	807110015
replace SiteName = "MULAHARAM" if SiteID==	807110016
replace SiteName = "Hausari IDP" if SiteID==	807910016
replace SiteName = "GEN HOSP  DK" if SiteID==	808210001
replace SiteName = "MCH DIKWA" if SiteID==	808110002
replace SiteName = "MCH GAJIBO" if SiteID==	808110003
replace SiteName = "GAMAYA DISP" if SiteID==	808110004
replace SiteName = "SOGOMA DISP" if SiteID==	808110005
replace SiteName = "B/MAIBE  DISP" if SiteID==	808110006
replace SiteName = "MCH BOBOSHE" if SiteID==	808110007
replace SiteName = "JEJEME  DISP" if SiteID==	808110008
replace SiteName = "PHC MAJA" if SiteID==	808110009
replace SiteName = "ANTUL DISP" if SiteID==	808110010
replace SiteName = "B/ FADEBE  DISP" if SiteID==	808110011
replace SiteName = "PHC  MASA" if SiteID==	808110012
replace SiteName = "MCHC" if SiteID==	809110001
replace SiteName = "GEN HOSP" if SiteID==	809210002
replace SiteName = "BAZAM DISP" if SiteID==	809110003
replace SiteName = "DUNGA DISP" if SiteID==	809110004
replace SiteName = "GAZABURE DISP" if SiteID==	809110005
replace SiteName = "MCH  ZOWO" if SiteID==	809110006
replace SiteName = "NGETRA PHC" if SiteID==	809110007
replace SiteName = "Goni Abatchari CLIN" if SiteID==	809110008
replace SiteName = "GUDUMBALI" if SiteID==	810110001
replace SiteName = "ADUWA" if SiteID==	810110002
replace SiteName = "KINGARWA" if SiteID==	810110003
replace SiteName = "GUZAMALA" if SiteID==	810110004
replace SiteName = "GARANDA" if SiteID==	810110005
replace SiteName = "GONI ADAMTI" if SiteID==	810110006
replace SiteName = "BULTURAM" if SiteID==	810110007
replace SiteName = "LINGIR" if SiteID==	810110008
replace SiteName = "MAIRARI" if SiteID==	810110009
replace SiteName = "MODURI" if SiteID==	810110010
replace SiteName = "BUWA" if SiteID==	810110011
replace SiteName = "ALI GAMBORI" if SiteID==	810110012
replace SiteName = "WAMIRI" if SiteID==	810110013
replace SiteName = "BITA H/C" if SiteID==	811110001
replace SiteName = "IZGE PHC" if SiteID==	811110002
replace SiteName = "MADUBE DISP" if SiteID==	811110003
replace SiteName = "GEN HOSP NGOSHE" if SiteID==	811210004
replace SiteName = "KOGHUM H/C" if SiteID==	811110005
replace SiteName = "NGOSHE SAMA DISP " if SiteID==	811110006
replace SiteName = "HUDIMCHA DISP" if SiteID==	811110007
replace SiteName = "AGAPALAWA DISP" if SiteID==	811110008
replace SiteName = "GAVA DISP" if SiteID==	811110009
replace SiteName = "TAKWALA DISP" if SiteID==	811110010
replace SiteName = "GEN HOSP KIRAWA" if SiteID==	811210011
replace SiteName = "NDABA H/C" if SiteID==	811110012
replace SiteName = "KIRAWA DISP" if SiteID==	811110013
replace SiteName = "NDABA KURA HC" if SiteID==	811110014
replace SiteName = "VALENGADE DISP" if SiteID==	811110015
replace SiteName = "LIMKARA H/C" if SiteID==	811110016
replace SiteName = "YAMTAKE DISP" if SiteID==	811110017
replace SiteName = "JAJE DISP" if SiteID==	811110018
replace SiteName = "BOKKO DISP" if SiteID==	811110019
replace SiteName = "PULKA COCIN" if SiteID==	811110020
replace SiteName = "PULKA MCH" if SiteID==	811110021
replace SiteName = "FADEGWE DISP" if SiteID==	811110022
replace SiteName = "KIMBE DISP" if SiteID==	811110023
replace SiteName = "ASHIGASHIYA DISP" if SiteID==	811110024
replace SiteName = "BARAWA EYN DISP" if SiteID==	811110025
replace SiteName = "HADAKAYA DISP" if SiteID==	811110026
replace SiteName = "ARBOKO H/C" if SiteID==	811110027
replace SiteName = "GEN HOSP GWOZA" if SiteID==	811210028
replace SiteName = "MCH GWOZA" if SiteID==	811110029
replace SiteName = "DURE DISP" if SiteID==	811110030
replace SiteName = "WALA MCH" if SiteID==	811110031
replace SiteName = "TAKWALA DISP" if SiteID==	811110032
replace SiteName = "PHC SHSFFA" if SiteID==	812110001
replace SiteName = "GULA DISP" if SiteID==	812110002
replace SiteName = "EYN DISP" if SiteID==	812110003
replace SiteName = "YIMIRSHIKA H/C" if SiteID==	812110004
replace SiteName = "KIDA PHC" if SiteID==	812110005
replace SiteName = "KUKURUPU DISP" if SiteID==	812110006
replace SiteName = "GWALAM DISP" if SiteID==	812110007
replace SiteName = "HYERA DISP" if SiteID==	812110008
replace SiteName = "CHATA AP" if SiteID==	812120009
replace SiteName = "SHITIKAM HP" if SiteID==	812110010
replace SiteName = "GANGSHAFFA DISP" if SiteID==	812110011
replace SiteName = "KWAJAFA DISP" if SiteID==	812110012
replace SiteName = "HARANG DISP" if SiteID==	812110013
replace SiteName = "T/ ALADE DISP" if SiteID==	812110014
replace SiteName = "VINADAM DISP" if SiteID==	812110015
replace SiteName = "GUMA DISP" if SiteID==	812110016
replace SiteName = "WHITAUBAYA DISP" if SiteID==	812110017
replace SiteName = "AZARE GEN. HOSP" if SiteID==	812210018
replace SiteName = "HEMA HP" if SiteID==	812110019
replace SiteName = "GH MARAMA" if SiteID==	812210020
replace SiteName = "NGOMARI" if SiteID==	813110001
replace SiteName = "UMARU SHEHU HOSP" if SiteID==	813210002
replace SiteName = "DALARAM" if SiteID==	813110003
replace SiteName = "U.M.T.H" if SiteID==	813310004
replace SiteName = "UNIMAID" if SiteID==	813210005
replace SiteName = "MAIRI" if SiteID==	813110006
replace SiteName = "MASHAMARI" if SiteID==	813110007
replace SiteName = "GALTAMARI" if SiteID==	813110008
replace SiteName = "MAIMUSARI" if SiteID==	813110009
replace SiteName = "TAIMAKON J" if SiteID==	813120010
replace SiteName = "CHAD BASIN" if SiteID==	813110011
replace SiteName = "DUSUMAN" if SiteID==	813110012
replace SiteName = "POLICE" if SiteID==	813210013
replace SiteName = "GIWA BARACKS" if SiteID==	813210014
replace SiteName = "MAIMALARI BK" if SiteID==	813210015
replace SiteName = "GONGULONG" if SiteID==	813110016
replace SiteName = "DALA" if SiteID==	813110017
replace SiteName = "ZABAMARI" if SiteID==	813110018
replace SiteName = "TUBA" if SiteID==	813110019
replace SiteName = "FORI DISP" if SiteID==	813110020
replace SiteName = "ALAU DISP" if SiteID==	813110021
replace SiteName = "MUNA OTP" if SiteID==	813110022
replace SiteName = "Jiddari CLIN" if SiteID==	813110022
replace SiteName = "Dalori IDP Camp" if SiteID==	813910004
replace SiteName = "Muna Camp CLIN B" if SiteID==	813920022
replace SiteName = "Muna Camp CLIN A" if SiteID==	813930022
replace SiteName = "Rehabilitation CENT" if SiteID==	813940002
replace SiteName = "Goni Kachallari IDP" if SiteID==	813950022
replace SiteName = "Farm CENT IDP" if SiteID==	813960011
replace SiteName = "MARGUBA DISP" if SiteID==	814110001
replace SiteName = "BENISHIRK MCH" if SiteID==	814110002
replace SiteName = "GEN HOSP. B/S" if SiteID==	814210003
replace SiteName = "NGAMDU MCH" if SiteID==	814110004
replace SiteName = "MAINOK MCH" if SiteID==	814110005
replace SiteName = "K/WA DISP " if SiteID==	814110006
replace SiteName = "DANGO DISP " if SiteID==	814110007
replace SiteName = "WASARAMDO MCH " if SiteID==	814110008
replace SiteName = "TOBOL HC " if SiteID==	814110009
replace SiteName = "SHETIMARI HC " if SiteID==	814110010
replace SiteName = "GUWO DISP " if SiteID==	814110011
replace SiteName = "M/ KURI" if SiteID==	814110012
replace SiteName = "FAI DISP " if SiteID==	814110013
replace SiteName = "GALAJI DISP " if SiteID==	814110014
replace SiteName = "BUGUMA DISP " if SiteID==	814110015
replace SiteName = "DAIMA" if SiteID==	815110001
replace SiteName = "JARAWA" if SiteID==	815110002
replace SiteName = "JILBE" if SiteID==	815110003
replace SiteName = "KALA" if SiteID==	815110004
replace SiteName = "K/KUMAGA" if SiteID==	815110005
replace SiteName = "K/KAUDI" if SiteID==	815110006
replace SiteName = "MISHARDE" if SiteID==	815110007
replace SiteName = "RANN" if SiteID==	815110008
replace SiteName = "TILAM" if SiteID==	815110009
replace SiteName = "GEN. HOSP RANN" if SiteID==	815210010
replace SiteName = "WUMBI" if SiteID==	815110011
replace SiteName = "SIGAL" if SiteID==	815110012
replace SiteName = "KIMERI" if SiteID==	816110001
replace SiteName = "KAYAMLA" if SiteID==	816110002
replace SiteName = "NJIMTILO" if SiteID==	816110003
replace SiteName = "POMPOMARI" if SiteID==	816110004
replace SiteName = "CHABBOL" if SiteID==	816110005
replace SiteName = "TUNGUSHE" if SiteID==	816110006
replace SiteName = "AUNO" if SiteID==	816110007
replace SiteName = "DALORI" if SiteID==	816110008
replace SiteName = "DENGELTI" if SiteID==	816110009
replace SiteName = "DAWAL" if SiteID==	816110010
replace SiteName = "M. ABBARI" if SiteID==	816110011
replace SiteName = "M. FANNAMARI" if SiteID==	816110012
replace SiteName = "JAKANA" if SiteID==	816110013
replace SiteName = "YAJIWA" if SiteID==	816110014
replace SiteName = "BULABULIN" if SiteID==	816110015
replace SiteName = "NYALERI" if SiteID==	816110016
replace SiteName = "SANDIA" if SiteID==	816110017
replace SiteName = "YALE" if SiteID==	816110018
replace SiteName = "NGALIAMARI" if SiteID==	816110019
replace SiteName = "KAWURI" if SiteID==	816110020
replace SiteName = "AULARI" if SiteID==	816110021
replace SiteName = "MCH K." if SiteID==	816110022
replace SiteName = "GEN HOSP K" if SiteID==	816210023
replace SiteName = "MALARI" if SiteID==	816110024
replace SiteName = "LAWANTI" if SiteID==	816110025
replace SiteName = "MAIRAMRI" if SiteID==	816110026
replace SiteName = "BIDINGERI" if SiteID==	816110027
replace SiteName = "1000 Estates OTP" if SiteID==	816110028
replace SiteName = "777 Estates OTP" if SiteID==	816110029
replace SiteName = "Gubio IDP Camp" if SiteID==	816910005
replace SiteName = "Kofa IDP Camp" if SiteID==	816920008
replace SiteName = "Konduga IDP Camp" if SiteID==	816930024
replace SiteName = "Zaramari Outreach" if SiteID==	816950005
replace SiteName = "HF 1 G/H KWA" if SiteID==	817210001
replace SiteName = "HF 2 MCH KUKAWA" if SiteID==	817110002
replace SiteName = "HF 3 D/ MASARA" if SiteID==	817110003
replace SiteName = "HF 1 CROSS FSP" if SiteID==	817110004
replace SiteName = "HF 1 ALAGARO" if SiteID==	817110005
replace SiteName = "HF 1 COCIN" if SiteID==	817120006
replace SiteName = "HF 2 MCH BAGA" if SiteID==	817110007
replace SiteName = "HF 1 DORO HC" if SiteID==	817110008
replace SiteName = "HF 1 YOYO HC" if SiteID==	817110009
replace SiteName = "HF 1 BUNDUR" if SiteID==	817110010
replace SiteName = "HF 1 BARWATI" if SiteID==	817110011
replace SiteName = "HF 1 DOGOSHI" if SiteID==	817110012
replace SiteName = "HF 1 MILE 90" if SiteID==	817110013
replace SiteName = "HF 1 DUGUM HC" if SiteID==	817110014
replace SiteName = "HF 1 KANGARAM" if SiteID==	817110015
replace SiteName = "HF 1 MCH" if SiteID==	818110001
replace SiteName = "HF 2 GEN.HOSP KWAYA" if SiteID==	818210002
replace SiteName = "HF 2 GADAM HC" if SiteID==	818110003
replace SiteName = "HF 3  GUBA DISP" if SiteID==	818110004
replace SiteName = "HF 1 B/GUSI" if SiteID==	818110005
replace SiteName = "HF 1 KURBA GAYI" if SiteID==	818110006
replace SiteName = "HF 1 PETA DISP" if SiteID==	818110007
replace SiteName = "HF 1 YIRMIRLALANG" if SiteID==	818110008
replace SiteName = "HF 1 FESINGO" if SiteID==	818110009
replace SiteName = "HF 2 KOGU DISP" if SiteID==	818110010
replace SiteName = "HF 1 WANDALI" if SiteID==	818120011
replace SiteName = "HF 1 WAWA" if SiteID==	818110012
replace SiteName = "HF 1 DAYAR" if SiteID==	818110013
replace SiteName = "HF 1 GUWAL" if SiteID==	818110014
replace SiteName = "HF 1 AJIRI HC" if SiteID==	819110001
replace SiteName = "HF 1 DOGUMBA" if SiteID==	819110002
replace SiteName = "HF 1 KOSHEBE " if SiteID==	819110003
replace SiteName = "HF 1 GEN HOP" if SiteID==	819210004
replace SiteName = "HF 2 MCH MAFA" if SiteID==	819110005
replace SiteName = "HF 1 GWOZARI" if SiteID==	819110006
replace SiteName = "HF 2 MALAKYARIR" if SiteID==	819110007
replace SiteName = "HF 1 LOSKURI" if SiteID==	819110008
replace SiteName = "HF 2 NGWOM" if SiteID==	819110009
replace SiteName = "HF 1 MUJIGINE" if SiteID==	819110010
replace SiteName = "HF 1 MASKA" if SiteID==	819110011
replace SiteName = "Mafa IDP Camp" if SiteID==	819910004
replace SiteName = "HF 1 ARDORAM" if SiteID==	820110001
replace SiteName = "HF 1 B/YESU HC" if SiteID==	820110002
replace SiteName = "HF 1 FURRAM" if SiteID==	820110003
replace SiteName = "GM PHC" if SiteID==	820110004
replace SiteName = "HF 1 GEN HOSP" if SiteID==	820210005
replace SiteName = "HF 2 MCH" if SiteID==	820110006
replace SiteName = "HF 1 HOYO DISP" if SiteID==	820110007
replace SiteName = "HF 1 KARERAM DISP" if SiteID==	820110008
replace SiteName = "HF 1 TITIWA" if SiteID==	820110009
replace SiteName = "Magumeri Town OTP" if SiteID==	820110010
replace SiteName = "Bolori 1 Mallahkachalla OTP" if SiteID==	821110001
replace SiteName = "HF2 BORNO MED. CLIN" if SiteID==	821220002
replace SiteName = "HF3 KWATAM CLIN" if SiteID==	821220003
replace SiteName = "HF 4 AYAMSU CLIN" if SiteID==	821220004
replace SiteName = "HF 5 NEU. PSYCH. HOSP" if SiteID==	821210005
replace SiteName = "HF 1 ZAGERI CLINC" if SiteID==	821110006
replace SiteName = "HF 2 B/ NGORAM CHC" if SiteID==	821110007
replace SiteName = "HF 1 BULABULIN DISP" if SiteID==	821110008
replace SiteName = "HF 1 GAMBORI HC" if SiteID==	821110009
replace SiteName = "HF 2 IDH" if SiteID==	821210010
replace SiteName = "HF 3 STATE PSYCH. HOSP" if SiteID==	821210011
replace SiteName = "HF 1 GWANGE HC" if SiteID==	821110012
replace SiteName = "HF 1 GWANGE DISP" if SiteID==	821110013
replace SiteName = "HF 1 FATIMA A, SHERIF" if SiteID==	821110014
replace SiteName = "HF 2 POLICE CLIN" if SiteID==	821110015
replace SiteName = "HF 3 N/ HOME" if SiteID==	821210016
replace SiteName = "HF 4 STATE SPECIALIST HOSP" if SiteID==	821210017
replace SiteName = "HF 4 DENTAL HOSP" if SiteID==	821210018
replace SiteName = "HF 5 EYE HOSP" if SiteID==	821210019
replace SiteName = "HF 1 SUNNI HOSP" if SiteID==	821220020
replace SiteName = "HF 2 NAKOWA CLIN" if SiteID==	821220021
replace SiteName = "HF 2 KANEM HOSP" if SiteID==	821220022
replace SiteName = "HF 4 FOUNDATION HOSP" if SiteID==	821220023
replace SiteName = "HF 5 CITY HOSP" if SiteID==	821220024
replace SiteName = "HF 1 YERWA MCH" if SiteID==	821110025
replace SiteName = "HF 2 ZAMAN CLIN" if SiteID==	821220026
replace SiteName = "HF 1 ABBAGANARAM" if SiteID==	821110027
replace SiteName = "Gomboru Male Disp" if SiteID==	821110028
replace SiteName = "Nursing Village Maisandari" if SiteID==	821910009
replace SiteName = "Lamisula IDP" if SiteID==	821920017
replace SiteName = "Teachers Village IDP Camp" if SiteID==	821930001
replace SiteName = "CBN IDP Camp" if SiteID==	821940017
replace SiteName = "NYSC IDP Camp" if SiteID==	821950017
replace SiteName = "Mafoni IDP Camp " if SiteID==	821960017
replace SiteName = "Bakasi 2 IDP CLIN" if SiteID==	821970017
replace SiteName = "Bakasi 1 IDP CLIN" if SiteID==	821980017
replace SiteName = "HF 1 ALA HC" if SiteID==	822110001
replace SiteName = "HF 2 KAJE HC" if SiteID==	822110002
replace SiteName = "HF 1 ALA LAWANTI HC" if SiteID==	822110003
replace SiteName = "HF 1 KABULAWA" if SiteID==	822110004
replace SiteName = "HF 1 KIRENOWA" if SiteID==	822110005
replace SiteName = "HF 1 KULLI" if SiteID==	822110006
replace SiteName = "HF 1 MARTE MCH" if SiteID==	822110007
replace SiteName = "HF 3 GEN. HOSP" if SiteID==	822210008
replace SiteName = "HF 4 JILLAM" if SiteID==	822110009
replace SiteName = "HF 1 MUSNE" if SiteID==	822110010
replace SiteName = "HF 1 MUWALLI" if SiteID==	822110011
replace SiteName = "HF 1 NJINE" if SiteID==	822110012
replace SiteName = "HF 2 NEW MARTE" if SiteID==	822110013
replace SiteName = "HF 1 JIBIRLARAM" if SiteID==	822110014
replace SiteName = "HF 2 NGLEWA" if SiteID==	822110015
replace SiteName = "HF 3 KOLORAM" if SiteID==	822110016
replace SiteName = "HF 4 BADARI" if SiteID==	822110017
replace SiteName = "HF 1 G/H  DAMASRK" if SiteID==	823210001
replace SiteName = "HF 1 MCH" if SiteID==	823110002
replace SiteName = "HF 1 ASAGA" if SiteID==	823110003
replace SiteName = "HF 2 GUWA" if SiteID==	823110004
replace SiteName = "HF 1 GASHIGA" if SiteID==	823110005
replace SiteName = "HF 1 DUJI CHC" if SiteID==	823110006
replace SiteName = "HF 2 MELERI" if SiteID==	823110007
replace SiteName = "HF 1 KARETO" if SiteID==	823110008
replace SiteName = "HF 1 LAYI" if SiteID==	823110009
replace SiteName = "HF 1 ZARI" if SiteID==	823110010
replace SiteName = "HF 2 FSP CLIN" if SiteID==	824110001
replace SiteName = "HF 3 MCH" if SiteID==	824110002
replace SiteName = "HF 4 GEN HOSP" if SiteID==	824210003
replace SiteName = "HF 1 NGURNO HC" if SiteID==	824110004
replace SiteName = "HF 1 GUMNARI" if SiteID==	824110005
replace SiteName = "HF 1 WULO" if SiteID==	824110006
replace SiteName = "HF 1 NGOLLAM" if SiteID==	824110007
replace SiteName = "HF 2 MINTAR" if SiteID==	824110008
replace SiteName = "HF 3 DEBELE" if SiteID==	824110009
replace SiteName = "HF 4 DIFINOWA" if SiteID==	824110010
replace SiteName = "HF 5 ALINGOLLOA" if SiteID==	824110011
replace SiteName = "HF 6 NAIRAWA" if SiteID==	824110012
replace SiteName = "HF 1 YELE" if SiteID==	824110013
replace SiteName = "HF 1 MANDALA" if SiteID==	824110014
replace SiteName = "HF 1 ZULUM KAMAGA" if SiteID==	824110015
replace SiteName = "HF 1 MOFIO" if SiteID==	824110016
replace SiteName = "HF 1 DAMAKULI" if SiteID==	824110017
replace SiteName = "HF 1 BIDA" if SiteID==	824110018
replace SiteName = "HF 1 KUMALIA" if SiteID==	824110019
replace SiteName = "NRC Camp" if SiteID==	824910001
replace SiteName = "MCH Monguno Alima" if SiteID==	824920004
replace SiteName = "Govt Girls Sec School Monguno IDP" if SiteID==	824930004
replace SiteName = "Kuya Primary School Site" if SiteID==	824940002
replace SiteName = "Govt Snr Sci Sec School Monguno IDP" if SiteID==	824950004
replace SiteName = "Govt Day SS IDP" if SiteID==	824960002
replace SiteName = "Waterboard IDP" if SiteID==	824970004
replace SiteName = "Local Govt Sec IDP " if SiteID==	824980004
replace SiteName = "HF 1 FUYE" if SiteID==	825110001
replace SiteName = "HF 1 GAMBORI A" if SiteID==	825110002
replace SiteName = "HF 1 BADIYA HP" if SiteID==	825110003
replace SiteName = "HF 2 MISSION HC" if SiteID==	825110004
replace SiteName = "HF 1 MCH GAMB" if SiteID==	825110005
replace SiteName = "HF 1 CAPRO HC" if SiteID==	825110006
replace SiteName = "HF 1 LOGUMANE MCH" if SiteID==	825110007
replace SiteName = "HF 1 MAINE HP" if SiteID==	825110008
replace SiteName = "HF 1 NDUFU MCH" if SiteID==	825110009
replace SiteName = "HF 1 NGALA DISP" if SiteID==	825110010
replace SiteName = "HF 1 GEN HOSP NGALA" if SiteID==	825210011
replace SiteName = "HF 1 SHEHURI DISP." if SiteID==	825110012
replace SiteName = "HF 1 MANAWAJI " if SiteID==	825110013
replace SiteName = "HF 1 WARSHELE HC" if SiteID==	825110014
replace SiteName = "HF 1 TONGULEY" if SiteID==	825110015
replace SiteName = "HF 1 WULGO MCH" if SiteID==	825110016
replace SiteName = "HF 1 HAUSARI HP" if SiteID==	825110017
replace SiteName = "HF 1 SIIGIR DISP" if SiteID==	825110018
replace SiteName = "HF 1 KIRTA HC" if SiteID==	825110019
replace SiteName = "HF 1 DANBOURE" if SiteID==	825110020
replace SiteName = "HF 1 WURGE HP" if SiteID==	825110021
replace SiteName = "Ngala ISS IDP Camp" if SiteID==	825910010
replace SiteName = "TOROWA HC" if SiteID==	826110001
replace SiteName = "BADU CLIN" if SiteID==	826110002
replace SiteName = "GADAI HC" if SiteID==	826110003
replace SiteName = "KUDA HC" if SiteID==	826110004
replace SiteName = "DAMARAM HC" if SiteID==	826110005
replace SiteName = "MAIWA HC" if SiteID==	826110006
replace SiteName = "GABERWA HC" if SiteID==	826110007
replace SiteName = "MIYE HC" if SiteID==	826110008
replace SiteName = "KESSA NGALA DISP" if SiteID==	826110009
replace SiteName = "FSP CLIN" if SiteID==	826110010
replace SiteName = "GEN HOSP" if SiteID==	826210011
replace SiteName = "MCHC" if SiteID==	826110012
replace SiteName = "SABSABUWA" if SiteID==	826110013
replace SiteName = "HF 1 SHANI HC" if SiteID==	827110001
replace SiteName = "HF 2 GEN. HOSP SHANI" if SiteID==	827210002
replace SiteName = "HF 2 BAKAINA" if SiteID==	827110003
replace SiteName = "HF 1 GWASKARA" if SiteID==	827110004
replace SiteName = "HF 1 BUMA" if SiteID==	827110005
replace SiteName = "HF 1 GWALASHO" if SiteID==	827110006
replace SiteName = "HF 1 KOMBO" if SiteID==	827110007
replace SiteName = "HF 1 LAKUNDUM" if SiteID==	827110008
replace SiteName = "HF 1 WALAMA" if SiteID==	827110009
replace SiteName = "HF 1 GASI" if SiteID==	827110010
replace SiteName = "HF 1 WALAMA" if SiteID==	827110011
replace SiteName = "HF 1 BARGU HC" if SiteID==	827110012
replace SiteName = "HF 1 GORA" if SiteID==	827110013
replace SiteName = "HF 2 WUJE" if SiteID==	827110014
* Additions from the Southern Borno training - 24 Nov
replace SiteName = "Tampul Disp" if SiteID==	802110024
replace SiteName = "Tawiwi Disp" if SiteID==	812210021
replace SiteName = "Kwaya Bura MCH" if SiteID==	812210022

* Additions from the Southern Borno training - 25 Nov
*Borno	Shani 	Kubo	Kubo CHC 	827110015
*Borno	Biu	Garubula 	Sabo Clinic	805110020
*Borno	Biu	Zarawuyaku	MCH Biu 	805110021



* Gombe - 16

replace SiteName ="Akko HC" if SiteID==	1601110001
replace SiteName ="Bula Disp" if SiteID==	1601110002
replace SiteName ="Bula MCH" if SiteID==	1601110003
replace SiteName ="Gamadadi Disp" if SiteID==	1601110004
replace SiteName ="Lawanti Disp" if SiteID==	1601110005
replace SiteName ="Wurodole Disp" if SiteID==	1601110006
replace SiteName ="Zongomari Disp" if SiteID==	1601110007
replace SiteName ="Arfa Med CENT" if SiteID==	1601220008
replace SiteName ="Bogo MCH" if SiteID==	1601110009
replace SiteName ="Garko Disp" if SiteID==	1601110010
replace SiteName ="Kudulum Disp" if SiteID==	1601110011
replace SiteName ="Gaskiya Med CLIN" if SiteID==	1601120012
replace SiteName ="Ponon Med CLIN" if SiteID==	1601120013
replace SiteName ="Dikko CLIN" if SiteID==	1601120014
replace SiteName ="Tabra MCH" if SiteID==	1601110015
replace SiteName ="Tumpure Disp" if SiteID==	1601110016
replace SiteName ="Chilo Disp" if SiteID==	1601110017
replace SiteName ="Chilo MCH" if SiteID==	1601110018
replace SiteName ="Gujuba Disp" if SiteID==	1601110019
replace SiteName ="Kalshingi Disp" if SiteID==	1601110020
replace SiteName ="Kalshingi (PHC)" if SiteID==	1601110021
replace SiteName ="Dongol Disp" if SiteID==	1601110022
replace SiteName ="Kaltanga Disp" if SiteID==	1601110023
replace SiteName ="Kashere MCH" if SiteID==	1601110024
replace SiteName ="Kashere HC" if SiteID==	1601110025
replace SiteName ="Kashere Gen Hosp" if SiteID==	1601210026
replace SiteName ="Mispha Mat Home" if SiteID==	1601120027
replace SiteName ="Kembu Disp" if SiteID==	1601110028
replace SiteName ="Kidda Disp" if SiteID==	1601110029
replace SiteName ="Kembu Disp" if SiteID==	1601110030
replace SiteName ="Panda MCH" if SiteID==	1601110031
replace SiteName ="Pandaya Disp" if SiteID==	1601110032
replace SiteName ="Tambie/Yolo Disp." if SiteID==	1601110033
replace SiteName ="Amina Mat Home" if SiteID==	1601120034
replace SiteName ="Kumo HC" if SiteID==	1601120035
replace SiteName ="Salama HC" if SiteID==	1601120036
replace SiteName ="Kumo MCH " if SiteID==	1601110037
replace SiteName ="Kumo Gen. HOSP" if SiteID==	1601210038
replace SiteName ="Kumo HC" if SiteID==	1601110039
replace SiteName ="Barambu HC" if SiteID==	1601110040
replace SiteName ="Gwaram MCH" if SiteID==	1601110041
replace SiteName ="Kilawa Disp" if SiteID==	1601110042
replace SiteName ="Lembi MCH" if SiteID==	1601110043
replace SiteName ="Lembi Disp" if SiteID==	1601110044
replace SiteName ="Gadawo Disp" if SiteID==	1601110045
replace SiteName ="Kobuwa Disp" if SiteID==	1601110046
replace SiteName ="Kobuwa MCH" if SiteID==	1601110047
replace SiteName ="Garin Rigiya Disp" if SiteID==	1601110048
replace SiteName ="Pindiga HC" if SiteID==	1601110049
replace SiteName ="Lambo Daji Disp" if SiteID==	1601110050
replace SiteName ="Pindiga Gen Hosp" if SiteID==	1601210051
replace SiteName ="Tukulma MCH" if SiteID==	1601110052
replace SiteName ="Shabbal Disp" if SiteID==	1601110053
replace SiteName ="Gokaru Disp" if SiteID==	1601110054
replace SiteName ="Badara Disp" if SiteID==	1601110055
replace SiteName ="Lariye Disp" if SiteID==	1601110056
replace SiteName ="Jauro Tukur Disp" if SiteID==	1601110057
replace SiteName ="Badawaire Disp" if SiteID==	1601110058
replace SiteName ="Bappah Ibrahim Disp" if SiteID==	1601110059
replace SiteName ="Jabba Disp" if SiteID==	1601110060
replace SiteName ="Piyau Disp" if SiteID==	1601110061
replace SiteName ="Yelwa Disp" if SiteID==	1601110062
replace SiteName ="Samkong HC" if SiteID==	1601120063
replace SiteName ="Sambo Daji Disp." if SiteID==	1601110064
replace SiteName ="Tumu MAT" if SiteID==	1601110065
replace SiteName ="Zabinkami Disp" if SiteID==	1601110066
replace SiteName ="Tumu Gen Hosp" if SiteID==	1601210067
replace SiteName ="Cham MCH" if SiteID==	1602110001
replace SiteName ="Cham Disp" if SiteID==	1602110002
replace SiteName ="ECWA Disp Cham" if SiteID==	1602120003
replace SiteName ="Salama MCH" if SiteID==	1602120004
replace SiteName ="Bambam PHC" if SiteID==	1602110005
replace SiteName ="Dr Fosa Med. CLIN" if SiteID==	1602120006
replace SiteName ="Bambam Gen Hosp" if SiteID==	1602210007
replace SiteName ="Kowa HC Bambam" if SiteID==	1602120008
replace SiteName ="Degri Disp" if SiteID==	1602110009
replace SiteName ="Kore MCH" if SiteID==	1602110010
replace SiteName ="Kulani MCH" if SiteID==	1602110011
replace SiteName ="Degri MCH" if SiteID==	1602110012
replace SiteName ="Putoki Disp" if SiteID==	1602110013
replace SiteName ="Sikkam MCH" if SiteID==	1602110014
replace SiteName ="Potuki Gen Hosp" if SiteID==	1602210015
replace SiteName ="ECWA HC Bambam" if SiteID==	1602120016
replace SiteName ="Dadiya MCH" if SiteID==	1602110017
replace SiteName ="Maitunku MCH" if SiteID==	1602110018
replace SiteName ="Yelwa Disp" if SiteID==	1602110019
replace SiteName ="Bangu Disp" if SiteID==	1602110020
replace SiteName ="Bakassi Disp" if SiteID==	1602110021
replace SiteName ="Balanga Disp" if SiteID==	1602110022
replace SiteName ="Dala waja Disp" if SiteID==	1602110023
replace SiteName ="Gelengu MCH" if SiteID==	1602110024
replace SiteName ="Gelengu ECWA MCH" if SiteID==	1602120025
replace SiteName ="Yolde MCH" if SiteID==	1602110026
replace SiteName ="Lakun MCH" if SiteID==	1602110027
replace SiteName ="Mona MCH" if SiteID==	1602110028
replace SiteName ="Dong MCH" if SiteID==	1602110029
replace SiteName ="Talasse Disp" if SiteID==	1602110030
replace SiteName ="Talasse PHC" if SiteID==	1602110031
replace SiteName ="Reme MCH" if SiteID==	1602110032
replace SiteName ="Talasse Gen Hosp" if SiteID==	1602210033
replace SiteName ="Gwenti Disp" if SiteID==	1602110034
replace SiteName ="Lotani Disp" if SiteID==	1602110035
replace SiteName ="Lugwi Disp" if SiteID==	1602110036
replace SiteName ="Jessu Disp" if SiteID==	1602110037
replace SiteName ="Nyuwar PHC" if SiteID==	1602110038
replace SiteName ="Nyuwar Disp" if SiteID==	1602110039
replace SiteName ="Wala Lunguda Disp." if SiteID==	1602110040
replace SiteName ="Kolako Disp" if SiteID==	1602110041
replace SiteName ="Rafele Disp" if SiteID==	1602110042
replace SiteName ="Wadachi Disp" if SiteID==	1602110043
replace SiteName ="Banganje PHC" if SiteID==	1603110001
replace SiteName ="Layafi HC" if SiteID==	1603110002
replace SiteName ="Lamugu HC" if SiteID==	1603110003
replace SiteName ="Lawurkardo HC" if SiteID==	1603110004
replace SiteName ="Lakarai HC" if SiteID==	1603110005
replace SiteName ="Lawiltiu HC" if SiteID==	1603110006
replace SiteName ="Pokulji HC" if SiteID==	1603110007
replace SiteName ="Sabon-layi HC" if SiteID==	1603110008
replace SiteName ="Kwibah HC" if SiteID==	1603110009
replace SiteName ="Kekkel MCH" if SiteID==	1603110010
replace SiteName ="Pokwagli HC" if SiteID==	1603110011
replace SiteName ="Lashiga HC" if SiteID==	1603110012
replace SiteName ="Lapandi-shadde HC" if SiteID==	1603110013
replace SiteName ="Nita Mat.CLIN" if SiteID==	1603120014
replace SiteName ="Waya MCH" if SiteID==	1603120015
replace SiteName ="Sansani HC" if SiteID==	1603110016
replace SiteName ="Awai HC" if SiteID==	1603110017
replace SiteName ="Billiri Gen Hosp" if SiteID==	1603210018
replace SiteName ="ECWA HC Awai" if SiteID==	1603120019
replace SiteName ="Fakla HC" if SiteID==	1603110020
replace SiteName ="Kufai HC" if SiteID==	1603110021
replace SiteName ="Kufai Disp" if SiteID==	1603120022
replace SiteName ="ECWA MCH Kufai" if SiteID==	1603120023
replace SiteName ="Komta HC" if SiteID==	1603110024
replace SiteName ="Latuggad HC" if SiteID==	1603110025
replace SiteName ="Poshiya HC" if SiteID==	1603110026
replace SiteName ="Ladikwiwa Med CLIN" if SiteID==	1603120027
replace SiteName ="Yamban Dok Med. CLIN" if SiteID==	1603120028
replace SiteName ="Kalkulum HC" if SiteID==	1603110029
replace SiteName ="Sikirit HC" if SiteID==	1603110030
replace SiteName ="Kalindi HC" if SiteID==	1603110031
replace SiteName ="Lawushi Daji HC" if SiteID==	1603110032
replace SiteName ="Lasale HC" if SiteID==	1603110033
replace SiteName ="Ketengereng HC" if SiteID==	1603110034
replace SiteName ="Amuta HC" if SiteID==	1603110035
replace SiteName ="Amtawalam HC" if SiteID==	1603110036
replace SiteName ="Lakelembu HC" if SiteID==	1603110037
replace SiteName ="Lakukdu HC" if SiteID==	1603110038
replace SiteName ="Pobawure HC" if SiteID==	1603110039
replace SiteName ="Kalmai HC" if SiteID==	1603110040
replace SiteName ="Catholic MCH Kalmai" if SiteID==	1603120041
replace SiteName ="Ayaba MCH" if SiteID==	1603110042
replace SiteName ="Kolokkwannin HC" if SiteID==	1603110043
replace SiteName ="Kurum HC" if SiteID==	1603110044
replace SiteName ="Kwiwulang HC" if SiteID==	1603110045
replace SiteName ="Lasani HC" if SiteID==	1603110046
replace SiteName ="Patinkude HC" if SiteID==	1603110047
replace SiteName ="Pandi-kungu HC" if SiteID==	1603110048
replace SiteName ="Tal HC" if SiteID==	1603110049
replace SiteName ="Tal MCH" if SiteID==	1603110050
replace SiteName ="Ayaba Alheri MAT CENT" if SiteID==	1603120051
replace SiteName ="ECWA HC Tal" if SiteID==	1603120052
replace SiteName ="Bassa HC" if SiteID==	1603110053
replace SiteName ="Kulgul MCH" if SiteID==	1603110054
replace SiteName ="Lakalkal HC" if SiteID==	1603110055
replace SiteName ="Powushi HC" if SiteID==	1603110056
replace SiteName ="Poyali HC" if SiteID==	1603110057
replace SiteName ="Tanglang HC" if SiteID==	1603110058
replace SiteName ="T /kwaya MCH" if SiteID==	1603110059
replace SiteName ="Panguru HC" if SiteID==	1603110060
replace SiteName ="T /Kwaya HC" if SiteID==	1603120061
replace SiteName ="Todi P H C" if SiteID==	1603110062
replace SiteName ="Shela HC" if SiteID==	1603110063
replace SiteName ="Popandi HC" if SiteID==	1603110064
replace SiteName ="Layer    /Lakule HC" if SiteID==	1603110065
replace SiteName ="ECWA HC Shela" if SiteID==	1603120066
replace SiteName ="Bawa MCH" if SiteID==	1604110001
replace SiteName ="Bawa Disp" if SiteID==	1604110002
replace SiteName ="Gare Disp" if SiteID==	1604110003
replace SiteName ="Lule/Zero Disp" if SiteID==	1604110004
replace SiteName ="Yole Disp" if SiteID==	1604110005
replace SiteName ="Gombe-Abba MAT" if SiteID==	1604110052
replace SiteName ="Hashidu HC" if SiteID==	1604110006
replace SiteName ="Dokoro Disp" if SiteID==	1604110007
replace SiteName ="Dokoro MCH" if SiteID==	1604110008
replace SiteName ="Gadum Disp" if SiteID==	1604110009
replace SiteName ="Jamari Disp" if SiteID==	1604110010
replace SiteName ="Jamari MCH" if SiteID==	1604110011
replace SiteName ="Kamba MCH" if SiteID==	1604110012
replace SiteName ="Kamba Disp" if SiteID==	1604110013
replace SiteName ="Kukudi Disp" if SiteID==	1604110014
replace SiteName ="Maru Disp" if SiteID==	1604110015
replace SiteName ="Wuro  Bulama Disp" if SiteID==	1604110016
replace SiteName ="Wuro Bulama MCH" if SiteID==	1604110017
replace SiteName ="Daminya Disp" if SiteID==	1604110018
replace SiteName ="Kunde HC" if SiteID==	1604110019
replace SiteName ="Lafiya MCH" if SiteID==	1604110020
replace SiteName ="Lafiya Talle Disp" if SiteID==	1604110021
replace SiteName ="Burari Disp " if SiteID==	1604110022
replace SiteName ="Duggiri Disp" if SiteID==	1604110023
replace SiteName ="Kowagol Disp" if SiteID==	1604110024
replace SiteName ="Malala Disp" if SiteID==	1604110025
replace SiteName ="Malala N YSC CLIN" if SiteID==	1604110026
replace SiteName ="Mayo Lamido Disp" if SiteID==	1604110027
replace SiteName ="Mayo Lamido Materniy" if SiteID==	1604110028
replace SiteName ="Dukku Disp" if SiteID==	1604110029
replace SiteName ="Dukku Town MCH" if SiteID==	1604110030
replace SiteName ="Garlingo Disp" if SiteID==	1604110031
replace SiteName ="Gode Disp" if SiteID==	1604110032
replace SiteName ="Jarlum Disp" if SiteID==	1604110033
replace SiteName ="Malalayel Disp" if SiteID==	1604110034
replace SiteName ="Comp HC" if SiteID==	1604110053
replace SiteName ="Dashi Disp" if SiteID==	1604110035
replace SiteName ="Dukku Gen Hosp" if SiteID==	1604210036
replace SiteName ="Kalam Disp" if SiteID==	1604110037
replace SiteName ="Tale Disp" if SiteID==	1604110038
replace SiteName ="Wuro Tale Disp" if SiteID==	1604110039
replace SiteName ="Wuro Tale MCH" if SiteID==	1604110040
replace SiteName ="Bokkiro Disp" if SiteID==	1604110041
replace SiteName ="Jombo Disp" if SiteID==	1604110042
replace SiteName ="Kumi Disp" if SiteID==	1604110043
replace SiteName ="Zagala Disp" if SiteID==	1604110044
replace SiteName ="Zange MCH" if SiteID==	1604110045
replace SiteName ="Zange Disp" if SiteID==	1604110046
replace SiteName ="Wuro Kudu Disp" if SiteID==	1604110047
replace SiteName ="Dukkuyel Disp" if SiteID==	1604110048
replace SiteName ="Garin Atiku Disp" if SiteID==	1604110049
replace SiteName ="Zaune Disp" if SiteID==	1604110050
replace SiteName ="Zaune MCH" if SiteID==	1604110051
replace SiteName ="Ashaka MCH" if SiteID==	1605110001
replace SiteName ="Ashaka Albarka N. Home" if SiteID==	1605120002
replace SiteName ="Ashaka Disp" if SiteID==	1605110003
replace SiteName ="Jalingo MCH" if SiteID==	1605110004
replace SiteName ="Jalingo Disp" if SiteID==	1605110005
replace SiteName ="Magaba Disp" if SiteID==	1605110006
replace SiteName ="Mannari MCH" if SiteID==	1605110007
replace SiteName ="Abuja Disp" if SiteID==	1605110008
replace SiteName ="Bage MCH" if SiteID==	1605110009
replace SiteName ="Bage Disp" if SiteID==	1605110010
replace SiteName ="Ballabdi Disp" if SiteID==	1605110011
replace SiteName ="Bungum Disp" if SiteID==	1605110012
replace SiteName ="Kafiwal Disp" if SiteID==	1605110013
replace SiteName ="Jungol-Barkano Disp" if SiteID==	1605110014
replace SiteName ="Bajoga Gen Hosp" if SiteID==	1605210015
replace SiteName ="Bajoga Med CLIN" if SiteID==	1605120016
replace SiteName ="Bajoga MCH" if SiteID==	1605110017
replace SiteName ="Bajoga Disp" if SiteID==	1605110018
replace SiteName ="Ecwa CLIN Bajoga" if SiteID==	1605120019
replace SiteName ="Sangaru MCH" if SiteID==	1605110020
replace SiteName ="Julahi MCH" if SiteID==	1605110021
replace SiteName ="Julahi Disp" if SiteID==	1605110022
replace SiteName ="Kuka Bakwai MCH" if SiteID==	1605110023
replace SiteName ="Kupto MCH" if SiteID==	1605110024
replace SiteName ="Kupto Disp" if SiteID==	1605110025
replace SiteName ="Jangade Disp" if SiteID==	1605110026
replace SiteName ="Bodor Disp" if SiteID==	1605110027
replace SiteName ="Tilde MCH" if SiteID==	1605110028
replace SiteName ="Tilde Disp" if SiteID==	1605110029
replace SiteName ="Tongo HC" if SiteID==	1605110030
replace SiteName ="Tongo N. Home CLIN" if SiteID==	1605120031
replace SiteName ="Guiwa MCH" if SiteID==	1605110032
replace SiteName ="Ngarai Disp" if SiteID==	1605110033
replace SiteName ="Ribadu MCH" if SiteID==	1605110034
replace SiteName ="Ribadu Disp" if SiteID==	1605110035
replace SiteName ="Komi MCH" if SiteID==	1605110036
replace SiteName ="Wawa MCH" if SiteID==	1605110037
replace SiteName ="Wawa Disp" if SiteID==	1605110038
replace SiteName ="Wakkaltu Disp" if SiteID==	1605110039
replace SiteName ="Nig. Prison Services CLIN" if SiteID==	1606110001
replace SiteName ="Bimma Med CLIN" if SiteID==	1606120002
replace SiteName ="Fed.Med CENT" if SiteID==	1606310003
replace SiteName ="F C E (Tech) CLIN" if SiteID==	1606110004
replace SiteName ="Urban MCH" if SiteID==	1606110005
replace SiteName ="Idi Disp" if SiteID==	1606110006
replace SiteName ="Royal Eye & Dental CLIN" if SiteID==	1606120007
replace SiteName ="SavannaHC" if SiteID==	1606220008
replace SiteName ="Police CLIN" if SiteID==	1606110009
replace SiteName ="N N P C Gombe Depot CLIN" if SiteID==	1606110010
replace SiteName ="Army Barrack CLIN" if SiteID==	1606110011
replace SiteName ="Family Support Prog. MCH" if SiteID==	1606110012
replace SiteName ="Bolari MCH" if SiteID==	1606110013
replace SiteName ="Govt House CLIN" if SiteID==	1606110014
replace SiteName ="St. Rose MCH" if SiteID==	1606120015
replace SiteName ="Arewa Med CLIN" if SiteID==	1606120016
replace SiteName ="El-Norf Med CLIN" if SiteID==	1606120017
replace SiteName ="H/Gana HC" if SiteID==	1606110018
replace SiteName ="Sunnah HOSP Gombe" if SiteID==	1606220019
replace SiteName ="Specialist HOSP Gombe" if SiteID==	1606210020
replace SiteName ="Divine Specialist Eye CLIN" if SiteID==	1606120021
replace SiteName ="Yarma Memorial HOSP" if SiteID==	1606120022
replace SiteName ="Gombe Town MCH" if SiteID==	1606110023
replace SiteName ="Tuberculosis/Leprosy CLIN" if SiteID==	1606110024
replace SiteName ="Doma Med HOSP" if SiteID==	1606220025
replace SiteName ="Kumbia - Kumbia MCH" if SiteID==	1606110026
replace SiteName ="Nassarawo MCH" if SiteID==	1606110027
replace SiteName ="Pantami HC" if SiteID==	1606110028
replace SiteName ="Pantami Med CLIN" if SiteID==	1606120029
replace SiteName ="Hamdala Specialist CLIN" if SiteID==	1606120030
replace SiteName ="Salem Med CLIN" if SiteID==	1606120031
replace SiteName ="Mal. Inna Disp" if SiteID==	1606110032
replace SiteName ="Tudun Wada HC" if SiteID==	1606110033
replace SiteName ="Miyetti Med CLIN" if SiteID==	1606120034
replace SiteName ="Musaba Med CLIN" if SiteID==	1606120035
replace SiteName ="Tasma Med HOSP" if SiteID==	1606120036
replace SiteName ="Metro Consultant CLIN" if SiteID==	1606120037
replace SiteName ="Dogon Ruwa MCH" if SiteID==	1607110001
replace SiteName ="Bwara HC" if SiteID==	1607110002
replace SiteName ="Garin Bako MCH" if SiteID==	1607110003
replace SiteName ="Samkong MCH" if SiteID==	1607120004
replace SiteName ="S/Layi MCH" if SiteID==	1607110005
replace SiteName ="Kije HC" if SiteID==	1607110006
replace SiteName ="Jalingo MCH" if SiteID==	1607110007
replace SiteName ="Lungere HC" if SiteID==	1607110008
replace SiteName ="Baule Gari MCH" if SiteID==	1607110009
replace SiteName ="Bule HC" if SiteID==	1607110010
replace SiteName ="Kaltin MCH" if SiteID==	1607110011
replace SiteName ="Kwang MCH" if SiteID==	1607110012
replace SiteName ="Lafiya Baule MCH" if SiteID==	1607110013
replace SiteName ="Gen Hosp Kaltungo" if SiteID==	1607210014
replace SiteName ="Bandara HC" if SiteID==	1607110015
replace SiteName ="Kale HC" if SiteID==	1607110016
replace SiteName ="Kaluwa HC" if SiteID==	1607110017
replace SiteName ="Layiro Papandi MCH" if SiteID==	1607110018
replace SiteName ="Layiro Posheren HC" if SiteID==	1607110019
replace SiteName ="Lakweme MCH" if SiteID==	1607110020
replace SiteName ="Poshereng MCH" if SiteID==	1607110021
replace SiteName ="Popandi MCH" if SiteID==	1607110022
replace SiteName ="Purmai HC" if SiteID==	1607110023
replace SiteName ="Kaltungo Med. CENT" if SiteID==	1607120024
replace SiteName ="Molding HC" if SiteID==	1607110025
replace SiteName ="Kaltungo Town MCH" if SiteID==	1607110026
replace SiteName ="Kalargo HC" if SiteID==	1607110027
replace SiteName ="Tantan Nursing Home" if SiteID==	1607120028
replace SiteName ="ECWA HC" if SiteID==	1607120029
replace SiteName ="Gujuba MCH" if SiteID==	1607110030
replace SiteName ="Latarin HC" if SiteID==	1607110031
replace SiteName ="Lafiya HC Gujuba" if SiteID==	1607110032
replace SiteName ="Mozo HC" if SiteID==	1607110033
replace SiteName ="Pattuwana MCH" if SiteID==	1607110034
replace SiteName ="Shenge Shenge HC" if SiteID==	1607110035
replace SiteName ="Bed Bede HC" if SiteID==	1607110036
replace SiteName ="ECWA HC Pokwangli" if SiteID==	1607110037
replace SiteName ="Pokwangli HC" if SiteID==	1607110038
replace SiteName ="Lakidir HC" if SiteID==	1607110039
replace SiteName ="Wili HC" if SiteID==	1607110040
replace SiteName ="Mai Ture MCH" if SiteID==	1607110041
replace SiteName ="Ture Balam MCH" if SiteID==	1607110042
replace SiteName ="Ture Okra HC" if SiteID==	1607120043
replace SiteName ="Ture Okra CLIN" if SiteID==	1607120044
replace SiteName ="Kwen HC" if SiteID==	1607120045
replace SiteName ="ECWA,HC Galadima" if SiteID==	1607120046
replace SiteName ="Jauro Audi HC" if SiteID==	1607110047
replace SiteName ="Bwele MCH" if SiteID==	1607110048
replace SiteName ="Bekuntin HC" if SiteID==	1607110049
replace SiteName ="Kaye HC" if SiteID==	1607110050
replace SiteName ="Yiri MCH" if SiteID==	1607110051
replace SiteName ="Wange MCH" if SiteID==	1607110052
replace SiteName ="Yoriyo HC" if SiteID==	1607110053
replace SiteName ="Chin Chin HC" if SiteID==	1607110054
replace SiteName ="ECWA CLIN Wange" if SiteID==	1607120055
replace SiteName ="Cottage HOSP, Tula " if SiteID==	1607110056
replace SiteName ="Bojude MCH" if SiteID==	1608110001
replace SiteName ="Bojude Disp" if SiteID==	1608110002
replace SiteName ="Gen Hosp Bojude" if SiteID==	1608210003
replace SiteName ="Dukkul MCH" if SiteID==	1608110004
replace SiteName ="Dukkul Disp" if SiteID==	1608110005
replace SiteName ="Gafara Disp" if SiteID==	1608110006
replace SiteName ="Doho MCH" if SiteID==	1608110007
replace SiteName ="Doho Disp" if SiteID==	1608110008
replace SiteName ="Hamma Dukkuyo Disp" if SiteID==	1608110009
replace SiteName ="Jambula Disp" if SiteID==	1608110010
replace SiteName ="Hamma Dukkuyo MAT" if SiteID==	1608110011
replace SiteName ="Wuro Dole Disp" if SiteID==	1608110012
replace SiteName ="D/Fulani MCH" if SiteID==	1608110013
replace SiteName ="D/Fulani Disp" if SiteID==	1608110014
replace SiteName ="Wuro Jabe Disp" if SiteID==	1608110015
replace SiteName ="Gadam MCH" if SiteID==	1608110016
replace SiteName ="Gadam Disp" if SiteID==	1608110017
replace SiteName ="Gwaram Disp" if SiteID==	1608110018
replace SiteName ="Mettako Disp" if SiteID==	1608110019
replace SiteName ="Tappi Disp" if SiteID==	1608110020
replace SiteName ="Allugel Disp" if SiteID==	1608110021
replace SiteName ="Jurara MCH" if SiteID==	1608110022
replace SiteName ="Jurara Disp" if SiteID==	1608110023
replace SiteName ="Abuja MCH" if SiteID==	1608110024
replace SiteName ="Bomala Disp" if SiteID==	1608110025
replace SiteName ="Komfulata Disp" if SiteID==	1608110026
replace SiteName ="Janji Disp" if SiteID==	1608110027
replace SiteName ="Shongo MCH" if SiteID==	1608110028
replace SiteName ="Jauro Isa Disp" if SiteID==	1608110029
replace SiteName ="Gerkwami MCH" if SiteID==	1608110030
replace SiteName ="Gerkwami Disp" if SiteID==	1608110031
replace SiteName ="Kwami Model HC" if SiteID==	1608110032
replace SiteName ="Kwami MCH" if SiteID==	1608110033
replace SiteName ="Kwami Disp" if SiteID==	1608110034
replace SiteName ="Titi Disp" if SiteID==	1608110035
replace SiteName ="Malleri MCH" if SiteID==	1608110036
replace SiteName ="Malleri Disp" if SiteID==	1608110037
replace SiteName ="Tinda Disp" if SiteID==	1608110038
replace SiteName ="M/Sidi MCH" if SiteID==	1608110039
replace SiteName ="Kyari MCH" if SiteID==	1608110040
replace SiteName ="M/Sidi Disp" if SiteID==	1608110041
replace SiteName ="Gen Hosp M/Sidi" if SiteID==	1608210042
replace SiteName ="Cottage HOSP Biri" if SiteID==	1609110001
replace SiteName ="B/Bolewa Disp" if SiteID==	1609110002
replace SiteName ="B/Bolawa MCH" if SiteID==	1609110003
replace SiteName ="B/Bolawa P H C" if SiteID==	1609110004
replace SiteName ="B/Bolawa HC" if SiteID==	1609110005
replace SiteName ="Sundingo HC" if SiteID==	1609110006
replace SiteName ="B/Fulani MCH" if SiteID==	1609110007
replace SiteName ="B/Fulani HC" if SiteID==	1609110008
replace SiteName ="B/Fulani Disp" if SiteID==	1609110009
replace SiteName ="Kiyayo Disp" if SiteID==	1609110010
replace SiteName ="Birin - Fulani PHC" if SiteID==	1609110011
replace SiteName ="Madaki Lamu Disp" if SiteID==	1609110012
replace SiteName ="B/Nasarawo MCH" if SiteID==	1609110013
replace SiteName ="B/Nasarawo Disp" if SiteID==	1609110014
replace SiteName ="Shanganawa MCH" if SiteID==	1609110015
replace SiteName ="Wakkaltu Disp" if SiteID==	1609110016
replace SiteName ="B/Winde MCH" if SiteID==	1609110017
replace SiteName ="B/Winde Disp" if SiteID==	1609110018
replace SiteName ="Duba Disp" if SiteID==	1609110019
replace SiteName ="Guduku Disp" if SiteID==	1609110020
replace SiteName ="Jigawa MCH" if SiteID==	1609110021
replace SiteName ="Jigawa Disp" if SiteID==	1609110022
replace SiteName ="Dendele Disp" if SiteID==	1609110023
replace SiteName ="Jolle Disp" if SiteID==	1609210024
replace SiteName ="Nafada Gen Hosp" if SiteID==	1609110025
replace SiteName ="Nafada PHC" if SiteID==	1609110026
replace SiteName ="Nafada MCH" if SiteID==	1609110027
replace SiteName ="Nafada MCH" if SiteID==	1609110028
replace SiteName ="Shole HC" if SiteID==	1609110029
replace SiteName ="Nyalkam Disp" if SiteID==	1609110030
replace SiteName ="Nafada Disp" if SiteID==	1609110031
replace SiteName ="Munde Disp" if SiteID==	1610110001
replace SiteName ="Bagunji MCH" if SiteID==	1610110002
replace SiteName ="Galadimari MCH" if SiteID==	1610110003
replace SiteName ="Karel MCH" if SiteID==	1610110004
replace SiteName ="Labeke HC" if SiteID==	1610110005
replace SiteName ="Lawishi HC" if SiteID==	1610110006
replace SiteName ="Boh Model P H C" if SiteID==	1610110007
replace SiteName ="Pokata HC" if SiteID==	1610110008
replace SiteName ="Burak MCH" if SiteID==	1610110009
replace SiteName ="Nyalimi HC" if SiteID==	1610110010
replace SiteName ="Filiya P H C" if SiteID==	1610110011
replace SiteName ="Pero MCH" if SiteID==	1610120012
replace SiteName ="Iliya Nursing Home Filiya" if SiteID==	1610110013
replace SiteName ="Gundale MCH" if SiteID==	1610110014
replace SiteName ="Daja MCH" if SiteID==	1610110015
replace SiteName ="Labanya MCH" if SiteID==	1610110016
replace SiteName ="Lapan HC" if SiteID==	1610120017
replace SiteName ="Lasanjang HC" if SiteID==	1610110018
replace SiteName ="Lalaipido MCH" if SiteID==	1610110019
replace SiteName ="Latatar MCH" if SiteID==	1610110020
replace SiteName ="Amkolan HC" if SiteID==	1610110021
replace SiteName ="Nawarke HC Lakanturum" if SiteID==	1610110022
replace SiteName ="Majidadi HC" if SiteID==	1610110023
replace SiteName ="Keffi HCLIN" if SiteID==	1610110024
replace SiteName ="Tora HC" if SiteID==	1610120025
replace SiteName ="Rev.Bitrus H.Memorial HC" if SiteID==	1610120026
replace SiteName ="Alheri HC Gwandum" if SiteID==	1610120027
replace SiteName ="UMCHC Gwandum" if SiteID==	1610120028
replace SiteName ="UMCN Rural HC Filiya" if SiteID==	1610110029
replace SiteName ="Kulishin MCH" if SiteID==	1610110030
replace SiteName ="Lashi Koltok MCH" if SiteID==	1610110031
replace SiteName ="Kushi MCH" if SiteID==	1610110032
replace SiteName ="Kushi HC" if SiteID==	1610110033
replace SiteName ="LapadintaiMCH" if SiteID==	1610110034
replace SiteName ="Deba Gen Hosp" if SiteID==	1611210001
replace SiteName ="DebaMCH" if SiteID==	1611110002
replace SiteName ="Deba HC" if SiteID==	1611110003
replace SiteName ="Saruje Disp" if SiteID==	1611110004
replace SiteName ="Deba Med CLIN" if SiteID==	1611120005
replace SiteName ="Gwani MATCLIN" if SiteID==	1611110006
replace SiteName ="Gwani/East Disp" if SiteID==	1611110007
replace SiteName ="Gwani West Disp" if SiteID==	1611110008
replace SiteName ="Shinga PHC" if SiteID==	1611110009
replace SiteName ="Wade MCH" if SiteID==	1611110010
replace SiteName ="Wade Disp" if SiteID==	1611110011
replace SiteName ="Colony HCLIN" if SiteID==	1611110012
replace SiteName ="Dadinkowa MCH" if SiteID==	1611110013
replace SiteName ="D/Kowa Convalescent CLIN" if SiteID==	1611120014
replace SiteName ="D/Kowa HC" if SiteID==	1611110015
replace SiteName ="Garin Bukar Disp" if SiteID==	1611110016
replace SiteName ="Gen Hosp Hina" if SiteID==	1611210017
replace SiteName ="Hina MCH" if SiteID==	1611110018
replace SiteName ="Jangargari Disp" if SiteID==	1611110019
replace SiteName ="Dasa MCH" if SiteID==	1611110020
replace SiteName ="Dasa Disp" if SiteID==	1611110021
replace SiteName ="Dando Disp" if SiteID==	1611110022
replace SiteName ="Maikafo MCH" if SiteID==	1611110023
replace SiteName ="Jigawan Iro HC" if SiteID==	1611110024
replace SiteName ="Jauro Gotel Disp" if SiteID==	1611110025
replace SiteName ="Tsando Disp" if SiteID==	1611110026
replace SiteName ="Kurjale Disp" if SiteID==	1611110027
replace SiteName ="Kurjale MCH" if SiteID==	1611110028
replace SiteName ="Pata Disp" if SiteID==	1611110029
replace SiteName ="Dagar MCH" if SiteID==	1611110030
replace SiteName ="Dagar Disp" if SiteID==	1611110031
replace SiteName ="Jannawo Disp" if SiteID==	1611110032
replace SiteName ="Kachallari Disp" if SiteID==	1611110033
replace SiteName ="Kachallari MCH" if SiteID==	1611110034
replace SiteName ="WajariDisp" if SiteID==	1611110035
replace SiteName ="Sele HC" if SiteID==	1611110036
replace SiteName ="Zamfarawa HC" if SiteID==	1611110037
replace SiteName ="Kuri MCH" if SiteID==	1611110038
replace SiteName ="Kuri Cottage HOSP" if SiteID==	1611110039
replace SiteName ="Lano MCH" if SiteID==	1611110040
replace SiteName ="Lambam MCH" if SiteID==	1611110041
replace SiteName ="Lambam Disp" if SiteID==	1611110042
replace SiteName ="Kwadon MCH" if SiteID==	1611110043
replace SiteName ="Kurba MCH" if SiteID==	1611110044
replace SiteName ="Kurba Disp " if SiteID==	1611110045
replace SiteName ="Kwadon Disp" if SiteID==	1611110046
replace SiteName ="Liji MCH" if SiteID==	1611110047
replace SiteName ="Liji Disp" if SiteID==	1611110048
replace SiteName ="Nassarawo Disp" if SiteID==	1611110049
replace SiteName ="Difa MCH" if SiteID==	1611110050
replace SiteName ="Difa Disp" if SiteID==	1611110051
replace SiteName ="Lubo Disp" if SiteID==	1611110052
replace SiteName ="Lubo MCH" if SiteID==	1611110053
replace SiteName ="Kinafa Disp" if SiteID==	1611110054
replace SiteName ="Boltongo Disp" if SiteID==	1611110055
replace SiteName ="Garin Baraya MCH" if SiteID==	1611110056
replace SiteName ="Garin Baraya Disp" if SiteID==	1611110057
replace SiteName ="KunnuwalMCH" if SiteID==	1611110058
replace SiteName ="Lano MCH" if SiteID==	1611110059
replace SiteName ="Nono Disp" if SiteID==	1611110060
replace SiteName ="Kwali Disp" if SiteID==	1611110061
replace SiteName ="Zambuk Gen Hosp" if SiteID==	1611210062
replace SiteName ="Zambuk MCH" if SiteID==	1611110063
replace SiteName ="Zambuk Disp" if SiteID==	1611110064
replace SiteName ="Zambuk Tropical HC" if SiteID==	1611110065

* Jigawa - 17
replace SiteName ="Babura Gen Hosp" if SiteID==	1702210001
replace SiteName ="Jarmai H.Post" if SiteID==	1702110002
replace SiteName ="Batali Disp" if SiteID==	1702110003
replace SiteName ="Dorawa H.Post" if SiteID==	1702110004
replace SiteName ="Dazau Disp" if SiteID==	1702110005
replace SiteName ="Garu PHC" if SiteID==	1702110006
replace SiteName ="Kyambo H.Post" if SiteID==	1702110007
replace SiteName ="Lamuntani Basic HC" if SiteID==	1702110008
replace SiteName ="Gasakoli H.Post" if SiteID==	1702110009
replace SiteName ="Tashar D/Kyambo Baisc HC" if SiteID==	1702110010
replace SiteName ="Insharuwa H.Post" if SiteID==	1702110011
replace SiteName ="Gurjiya Basic HC" if SiteID==	1702110012
replace SiteName ="Jigawa Babura PHC" if SiteID==	1702110013
replace SiteName ="Kanya HC (Babura)" if SiteID==	1702110014
replace SiteName ="Kuzunzumi H.Post" if SiteID==	1702110015
replace SiteName ="Manga H.Post" if SiteID==	1702110016
replace SiteName ="Masko Disp" if SiteID==	1702110017
replace SiteName ="Takwasa Basic HC" if SiteID==	1702110018
replace SiteName ="Birnin Kudu Gen Hosp" if SiteID==	1703210001
replace SiteName ="Kudu CLIN" if SiteID==	1703220002
replace SiteName ="Magajin Gari H.Post" if SiteID==	1703110003
replace SiteName ="Birnin Kudu Federal Med CENT" if SiteID==	1703310004
replace SiteName ="Kantoga H.Post" if SiteID==	1703110005
replace SiteName ="Dumus H.Post" if SiteID==	1703110006
replace SiteName ="Kangire H.Post" if SiteID==	1703110007
replace SiteName ="Kafin Gana H.Post" if SiteID==	1703110008
replace SiteName ="Babaldu CLIN" if SiteID==	1703110009
replace SiteName ="Babaldu H.Post" if SiteID==	1703110010
replace SiteName ="Kiyako H.Post" if SiteID==	1703110011
replace SiteName ="Bamaina HC" if SiteID==	1703110012
replace SiteName ="Kadangare Basic HC" if SiteID==	1703110013
replace SiteName ="Lafia H.Post" if SiteID==	1703110014
replace SiteName ="Tukuda Disp" if SiteID==	1703110015
replace SiteName ="Dukana H.Post" if SiteID==	1703110016
replace SiteName ="Kwari Disp" if SiteID==	1703110017
replace SiteName ="Nafara H.Post" if SiteID==	1703110018
replace SiteName ="Sundimina HC" if SiteID==	1703110019
replace SiteName ="Kwatai H.Post" if SiteID==	1703110020
replace SiteName ="Kumbura H.Post" if SiteID==	1703110021
replace SiteName ="Badingu H.Post" if SiteID==	1703110022
replace SiteName ="Jiboga Basic HC" if SiteID==	1703110023
replace SiteName ="Kawo H.Post" if SiteID==	1703110024
replace SiteName ="Unguwar Ya HC" if SiteID==	1703110025
replace SiteName ="Yarma H.Post" if SiteID==	1703110026
replace SiteName ="Giwa H.Post" if SiteID==	1703110027
replace SiteName ="Guna'an Damau H.Post" if SiteID==	1703110028
replace SiteName ="Jangargari H.Post" if SiteID==	1703110029
replace SiteName ="Samamiya Disp" if SiteID==	1703110030
replace SiteName ="Shungurin H.Post" if SiteID==	1703110031
replace SiteName ="Wurno HC" if SiteID==	1703110032
replace SiteName ="Arobade H.Post" if SiteID==	1703110033
replace SiteName ="Dokoki H.Post" if SiteID==	1703110034
								
replace SiteName ="Iggi Disp" if SiteID==	1703110035
replace SiteName ="Yalwan Damai Disp" if SiteID==	1703110036
replace SiteName ="Bkd Dangoli H.Post" if SiteID==	1703110037
replace SiteName ="Kuka-Inkiwa HC" if SiteID==	1704110001
replace SiteName ="Birniwa Cottage HOSP" if SiteID==	1704210002
replace SiteName ="Birniwa Tashia H.Post" if SiteID==	1704110003
replace SiteName ="Dangolori H.Post" if SiteID==	1704110004
replace SiteName ="Kubuna Disp" if SiteID==	1704110005
replace SiteName ="Munkawo H.Post" if SiteID==	1704110006
replace SiteName ="Diginsa HC" if SiteID==	1704110007
replace SiteName ="Tsinkaina H.Post" if SiteID==	1704110008
replace SiteName ="Kirilla H.Post" if SiteID==	1704110009
replace SiteName ="Kachallari Disp" if SiteID==	1704110010
replace SiteName ="Kanya HC (Birniwa)" if SiteID==	1704110011
replace SiteName ="Karanga Basic HC" if SiteID==	1704110012
replace SiteName ="Kundi H.Post" if SiteID==	1704110013
replace SiteName ="Dolen Kwana H.Post" if SiteID==	1704110014
replace SiteName ="Kazura PHC" if SiteID==	1704110015
replace SiteName ="Kubsa PHC" if SiteID==	1704110016
replace SiteName ="Marya H.Post" if SiteID==	1704110017
replace SiteName ="Goruba H.Post" if SiteID==	1704110018
replace SiteName ="Nguwa Disp" if SiteID==	1704110019
replace SiteName ="Yusufari H.Post" if SiteID==	1704110020
replace SiteName ="Matara Uku Disp" if SiteID==	1704110021
replace SiteName ="Gaduwa HC" if SiteID==	1710110001
replace SiteName ="Abunabo PHC" if SiteID==	1710110002
replace SiteName ="Adiyani Basic HC" if SiteID==	1710110003
replace SiteName ="Gagiya Disp" if SiteID==	1710110004
replace SiteName ="Dawa H.Post" if SiteID==	1710110005
replace SiteName ="Garbagal H.Post" if SiteID==	1710110006
replace SiteName ="Guri PHC" if SiteID==	1710110007
replace SiteName ="Kadira Basic HC" if SiteID==	1710110008
replace SiteName ="Lafiya HC" if SiteID==	1710110009
replace SiteName ="Margadu Disp" if SiteID==	1710110010
replace SiteName ="Musari Basic HC" if SiteID==	1710110011
replace SiteName ="Una Disp" if SiteID==	1710110012
replace SiteName ="Dole Disp" if SiteID==	1710110013
replace SiteName ="Buntusu Disp" if SiteID==	1712110001
replace SiteName ="Jigawar Habe H.Post" if SiteID==	1712110002
replace SiteName ="Dabi Basic HC" if SiteID==	1712110003
replace SiteName ="Gimi H.Post" if SiteID==	1712110004
replace SiteName ="Tsubut H.Post" if SiteID==	1712110005
replace SiteName ="Maraganta Disp" if SiteID==	1712110006
replace SiteName ="Ung/Gamji H.Post" if SiteID==	1712110007
replace SiteName ="Firjin Yamma H.Post" if SiteID==	1712110008
replace SiteName ="Guntai H.Post" if SiteID==	1712110009
replace SiteName ="Gwiwa Primary HC" if SiteID==	1712110010
replace SiteName ="Korayel PHC" if SiteID==	1712110011
replace SiteName ="Rorau H.Post" if SiteID==	1712110012
replace SiteName ="Daurawa H.Post" if SiteID==	1712110013
replace SiteName ="Shafe H.Post" if SiteID==	1712110014
replace SiteName ="Yola H.Post" if SiteID==	1712110015
replace SiteName ="Fara H.Post" if SiteID==	1712110016
replace SiteName ="Zauma H.Post" if SiteID==	1712110017
replace SiteName ="Aujara PHC" if SiteID==	1714110001
replace SiteName ="Damutawa H.Post" if SiteID==	1714110002
replace SiteName ="Gabari H.Post" if SiteID==	1714110003
replace SiteName ="Garan HC" if SiteID==	1714110004
replace SiteName ="Abarakeu H.Post" if SiteID==	1714110005
replace SiteName ="Farfada H.Post" if SiteID==	1714110006
replace SiteName ="Gangawa HC" if SiteID==	1714110007
replace SiteName ="Kadowawa HC" if SiteID==	1714110008
replace SiteName ="Gauza H.Post" if SiteID==	1714110009
replace SiteName ="Kafin Baka HC" if SiteID==	1714110010
replace SiteName ="Tazara H.Post" if SiteID==	1714110011
replace SiteName ="Dare/Doro HC" if SiteID==	1714110012
replace SiteName ="Gidan Gona Basic HC" if SiteID==	1714110013
replace SiteName ="Gunka HC" if SiteID==	1714110014
replace SiteName ="Yalleman H.Post" if SiteID==	1714110015
replace SiteName ="Idanduna HC" if SiteID==	1714110016
replace SiteName ="Rinde H.Post" if SiteID==	1714110017
replace SiteName ="Jabarna H.Post" if SiteID==	1714110018
replace SiteName ="Kulluru H.Post" if SiteID==	1714110019
replace SiteName ="Magama Disp" if SiteID==	1714110020
replace SiteName ="Jahun Gen Hosp" if SiteID==	1714210021
replace SiteName ="Jahun Urban MCH" if SiteID==	1714110022
replace SiteName ="Lafiya CLIN and MAT" if SiteID==	1714110023
replace SiteName ="Burabura H.Post" if SiteID==	1714110024
replace SiteName ="Gidan Dango H.Post" if SiteID==	1714110025
replace SiteName ="Kale Disp" if SiteID==	1714110026
replace SiteName ="Faranshi H.Post" if SiteID==	1714110027
replace SiteName ="Kanwa Basic HC" if SiteID==	1714110028
replace SiteName ="Tunubo H.Post" if SiteID==	1714110029
replace SiteName ="Atuman HC" if SiteID==	1714110030
replace SiteName ="Taraya H.Post" if SiteID==	1714110031
replace SiteName ="Zangon Kura H.Post" if SiteID==	1714110032
replace SiteName ="Harbo HC" if SiteID==	1714110033
replace SiteName ="Garado H.Post" if SiteID==	1714110034
replace SiteName ="Dodorin Malam Abdu H.Post" if SiteID==	1716110001
replace SiteName ="Kantamari H.Post" if SiteID==	1716110002
replace SiteName ="Adimin Gasau H.Post" if SiteID==	1716110003
replace SiteName ="Ubba H.Post" if SiteID==	1716110004
replace SiteName ="Dabuwaran H.Post" if SiteID==	1716110005
replace SiteName ="Garin Bagudu H.Post" if SiteID==	1716110006
replace SiteName ="Nuhu Alpha PHC" if SiteID==	1716110007
replace SiteName ="Bultuwa HC" if SiteID==	1716110008
replace SiteName ="Girbobo Basic HC" if SiteID==	1716110009
replace SiteName ="Hadin H.Post" if SiteID==	1716110010
replace SiteName ="Je'a H.Post" if SiteID==	1716110011
replace SiteName ="Maina Bindi H.Post" if SiteID==	1716110012
replace SiteName ="Turmi Disp" if SiteID==	1716110013
replace SiteName ="Kaugama PHC" if SiteID==	1716110014
replace SiteName ="Marke HC" if SiteID==	1716110015
replace SiteName ="Unguwar Jibrin Basic HC" if SiteID==	1716110016
replace SiteName ="Yalo Disp" if SiteID==	1716110017
replace SiteName ="Dandi Basic HC" if SiteID==	1717110001
replace SiteName ="Gurumfa H.Post" if SiteID==	1717110002
replace SiteName ="Ung/Yarima H.Post" if SiteID==	1717110003
replace SiteName ="Dunguyawa Basic HC" if SiteID==	1717110004
replace SiteName ="Farun Daba Basic HC" if SiteID==	1717110005
replace SiteName ="Kazaure Kofar Arewa CLIN" if SiteID==	1717110006
replace SiteName ="Kurfi H.Post" if SiteID==	1717110007
replace SiteName ="Gada Disp" if SiteID==	1717110008
replace SiteName ="Katoge H.Post" if SiteID==	1717110009
replace SiteName ="Kazaure Gen Hosp" if SiteID==	1717110010
replace SiteName ="Kazaure Psychiatric HOSP" if SiteID==	1717110011
replace SiteName ="Zainab Mem HOSP" if SiteID==	1717110012
replace SiteName ="Karaftayi Disp" if SiteID==	1717110013
replace SiteName ="Mahuchi H.Post" if SiteID==	1717110014
replace SiteName ="Sabaru Disp" if SiteID==	1717110015
replace SiteName ="Bandutse H.Post" if SiteID==	1717110016
replace SiteName ="Unguwar Gabas Model PHC" if SiteID==	1717110017
replace SiteName ="K/Chiroma Basic HC " if SiteID==	1717110018
replace SiteName ="Baauzini H.Post" if SiteID==	1717110019
replace SiteName ="Andaza Basic HC" if SiteID==	1719110001
replace SiteName ="Duhuwa Kiyawa H.Post" if SiteID==	1719110002
replace SiteName ="Balago Basic HC" if SiteID==	1719110003
replace SiteName ="Fiya H.Post" if SiteID==	1719110004
replace SiteName ="Markiba H.Post" if SiteID==	1719110005
replace SiteName ="Dangoli H.Post" if SiteID==	1719110006
replace SiteName ="Fake Disp" if SiteID==	1719110007
replace SiteName ="Gwadabe H.Post" if SiteID==	1719110008
replace SiteName ="Gidan Adede H.Post" if SiteID==	1719110009
replace SiteName ="Garko Disp" if SiteID==	1719110010
replace SiteName ="Mazazzaga H.Post" if SiteID==	1719110011
replace SiteName ="Garun Bayan Gari H.Post" if SiteID==	1719110012
replace SiteName ="Gurduba H.Post" if SiteID==	1719110013
replace SiteName ="Shuwarin MCH" if SiteID==	1719110014
replace SiteName ="Katanga PHC" if SiteID==	1719110015
replace SiteName ="Karfawa H.Post" if SiteID==	1719110016
replace SiteName ="Katuka Basic HC" if SiteID==	1719110017
replace SiteName ="Jamaar Isah H.Post" if SiteID==	1719110018
replace SiteName ="Gidan Malu H.Post" if SiteID==	1719110019
replace SiteName ="Kiyawa PHC" if SiteID==	1719110020
replace SiteName ="Kiyawa Fed Govt Coll ScHC" if SiteID==	1719110021
replace SiteName ="Danfusan Disp" if SiteID==	1719110022
replace SiteName ="Kwanda Basic HC" if SiteID==	1719110023
replace SiteName ="Maje Kiyawa Disp" if SiteID==	1719110024
replace SiteName ="Miyawa H.Post" if SiteID==	1719110025
replace SiteName ="Sabon Gari Kiyawa BHC" if SiteID==	1719110026
replace SiteName ="Tsirma HC" if SiteID==	1719110027
replace SiteName ="Gorumo H.Post" if SiteID==	1719110028
replace SiteName ="Botsuwa HC" if SiteID==	1720110001
replace SiteName ="Dankumbo H.Post" if SiteID==	1720110002
replace SiteName ="Galadi Disp" if SiteID==	1720110003
replace SiteName ="Jajeri Basic HC" if SiteID==	1720110004
replace SiteName ="Dansambo H.Post" if SiteID==	1720110005
replace SiteName ="Katika H.Post" if SiteID==	1720110006
replace SiteName ="Kukayasku Basic HC" if SiteID==	1720110007
replace SiteName ="Madana Disp" if SiteID==	1720110008
replace SiteName ="Jobi H.Post" if SiteID==	1720110009
replace SiteName ="Maigatari PHC" if SiteID==	1720110010
replace SiteName ="Wanzamai H.Post" if SiteID==	1720110011
replace SiteName ="S/Maja HC" if SiteID==	1720110012
replace SiteName ="Fulata H.Post" if SiteID==	1720110013
replace SiteName ="Shabarawa H.Post" if SiteID==	1720110014
replace SiteName ="Daguma H.Post" if SiteID==	1720110015
replace SiteName ="Kamainketa H.Post" if SiteID==	1720110016
replace SiteName ="Turbus H.Post" if SiteID==	1720110017
replace SiteName ="Amaryawa HC" if SiteID==	1724110001
replace SiteName ="Baragumi Disp" if SiteID==	1724110002
replace SiteName ="Nanumawa H.Post" if SiteID==	1724110003
replace SiteName ="Dansure Disp" if SiteID==	1724110004
replace SiteName ="Gora Disp" if SiteID==	1724110005
replace SiteName ="Roni Disp" if SiteID==	1724110006
replace SiteName ="Roni ECWA HC" if SiteID==	1724110007
replace SiteName ="Roni PHC" if SiteID==	1724110008
replace SiteName ="Unguwarmani H.Post" if SiteID==	1724110009
replace SiteName ="Takwardawa Disp" if SiteID==	1724110010
replace SiteName ="Unguwar Mani Tunas Disp" if SiteID==	1724110011
replace SiteName ="Yassara HC" if SiteID==	1724110012
replace SiteName ="Zugai Basic HC" if SiteID==	1724110013
replace SiteName ="Bashe Disp" if SiteID==	1724110014
													
replace SiteName ="Fara Barinje Disp" if SiteID==	1724110015
replace SiteName ="Sankau H.Post" if SiteID==	1724110016
replace SiteName ="Baushe Disp" if SiteID==	1724110017
replace SiteName ="Achilafiya HC" if SiteID==	1727110001
replace SiteName ="Sada Disp" if SiteID==	1727110002
replace SiteName ="Murde Disp" if SiteID==	1727110003
replace SiteName ="Sabuwa Disp" if SiteID==	1727110004
replace SiteName ="Gurjiya (Yankwashi) Basic HC" if SiteID==	1727110005
replace SiteName ="Gwarta Disp" if SiteID==	1727110006
replace SiteName ="Karkarna HC" if SiteID==	1727110007
replace SiteName ="Kuda Basic HC" if SiteID==	1727110008
replace SiteName ="Dumbu H.Post" if SiteID==	1727110009
replace SiteName ="Ringin Disp" if SiteID==	1727110010
replace SiteName ="Yankwashi H.Post" if SiteID==	1727110011
replace SiteName ="Zoto H.Post" if SiteID==	1727110012
replace SiteName ="Firji Disp" if SiteID==	1727110013
replace SiteName ="Rauda BHC" if SiteID== 			1727110014

replace SiteName ="Hadejia Gen Hosp" if SiteID==	1713210005
replace SiteName ="Dutse Gen Hosp" if SiteID==	1706210019
replace SiteName ="Gumel Gen Hosp" if SiteID==	1709210009




*KANO
replace SiteName = "Ajingi PHC" if SiteID==	1901110001
replace SiteName = "Balare HC" if SiteID==	1901110002
replace SiteName = "Tsebarawa HP" if SiteID==	1901110003
replace SiteName = "Chula Disp" if SiteID==	1901110004
replace SiteName = "Dabi HP" if SiteID==	1901110005
replace SiteName = "Fagawa HP" if SiteID==	1901110006
replace SiteName = "Fulatan HP" if SiteID==	1901110007
replace SiteName = "Marita HP" if SiteID==	1901110008
replace SiteName = "Dundun HP" if SiteID==	1901110009
replace SiteName = "Maigana HP" if SiteID==	1901110010
replace SiteName = "Jiyayya HP" if SiteID==	1901110011
replace SiteName = "Gurduba Disp" if SiteID==	1901110012
replace SiteName = "Kawari Keri HP" if SiteID==	1901110013
replace SiteName = "Kullumi HP" if SiteID==	1901110014
replace SiteName = "Zangon Gulya HP" if SiteID==	1901110015
replace SiteName = "Kara Makama Disp" if SiteID==	1901110016
replace SiteName = "Kiroro HP" if SiteID==	1901110017
replace SiteName = "Kunkurawa HP" if SiteID==	1901110018
replace SiteName = "Biyamusu HP" if SiteID==	1901110019
replace SiteName = "Kara-Dagaji HC" if SiteID==	1901110020
replace SiteName = "Kawoni HP" if SiteID==	1901110021
replace SiteName = "Toranke HC" if SiteID==	1901110022
replace SiteName = "Gagarawa HP" if SiteID==	1901110023
replace SiteName = "Kadiri Disp" if SiteID==	1901110024
replace SiteName = "Dan Malam HP" if SiteID==	1901110025
replace SiteName = "Gafasa HP" if SiteID==	1901110026
replace SiteName = "Makarya MPHC" if SiteID==	1901110027
replace SiteName = "Sakalawa HP" if SiteID==	1901110028
replace SiteName = "Unguwar Bai Disp" if SiteID==	1901110029
replace SiteName = "Albasu PHC" if SiteID==	1902110001
replace SiteName = "GGASS Albasu Clin" if SiteID==	1902110002
replace SiteName = "Jigar HP" if SiteID==	1902110003
replace SiteName = "Baleke HP" if SiteID==	1902110004
replace SiteName = "Bataiya PHC" if SiteID==	1902110005
replace SiteName = "Mangari HP" if SiteID==	1902110006
replace SiteName = "Chamarana HP" if SiteID==	1902110007
replace SiteName = "Duja HP" if SiteID==	1902110008
replace SiteName = "Daho Disp" if SiteID==	1902110009
replace SiteName = "Farantama HP" if SiteID==	1902110010
replace SiteName = "Zuwan Hawa HP" if SiteID==	1902110011
replace SiteName = "Faragai Disp" if SiteID==	1902110012
replace SiteName = "Gwangwarandan HP" if SiteID==	1902110013
replace SiteName = "S/G Naira HP" if SiteID==	1902110014
replace SiteName = "Gagarame HP" if SiteID==	1902110015
replace SiteName = "Jirago HP" if SiteID==	1902110016
replace SiteName = "Hungu Health Center" if SiteID==	1902110017
replace SiteName = "Sittika HP" if SiteID==	1902110018
replace SiteName = "Hamdullahi Disp" if SiteID==	1902110019
replace SiteName = "Panda Disp" if SiteID==	1902110020
replace SiteName = "Umbara HP" if SiteID==	1902110021
replace SiteName = "Bur-Burwa HP" if SiteID==	1902110022
replace SiteName = "Kalahaddi HP" if SiteID==	1902110023
replace SiteName = "Saya Saya Disp (Alb)" if SiteID==	1902110024
replace SiteName = "Tsangaya PHC" if SiteID==	1902110025
replace SiteName = "Yawurma HP" if SiteID==	1902110026
replace SiteName = "Yawra HP" if SiteID==	1902110027
replace SiteName = "Rubun HP" if SiteID==	1902110028
replace SiteName = "Gwagi HP" if SiteID==	1902110029
replace SiteName = "Rinji HP" if SiteID==	1902110030
replace SiteName = "Hargagi HP" if SiteID==	1902110031
replace SiteName = "Duwa HP" if SiteID==	1902110032
replace SiteName = "Jiragon Makera HP" if SiteID==	1902110033
replace SiteName = "Zananne HP" if SiteID==	1902110034
replace SiteName = "Biskin HP" if SiteID==	1902110035
replace SiteName = "Abbas PHC" if SiteID==	1903110001
replace SiteName = "Jauben Yamma H/P" if SiteID==	1903110002
replace SiteName = "Daddauda H/P" if SiteID==	1903110003
replace SiteName = "Dangada MPHC" if SiteID==	1903110004
replace SiteName = "Kafin Maiko H/P" if SiteID==	1903110005
replace SiteName = "Gadanya BHC" if SiteID==	1903110006
replace SiteName = "Tudara H/P" if SiteID==	1903110007
replace SiteName = "Gogori PHC" if SiteID==	1903110008
replace SiteName = "Gajal H/P" if SiteID==	1903110009
replace SiteName = "Kiyawa BHC" if SiteID==	1903110010
replace SiteName = "K/Adam H/P" if SiteID==	1903110011
replace SiteName = "R/Dako HP" if SiteID==	1903110012
replace SiteName = "Badodo H/P" if SiteID==	1903110013
replace SiteName = "Romo PHC" if SiteID==	1903110014
replace SiteName = "Jarumawa H/P" if SiteID==	1903110015
replace SiteName = "Yartofa H/P" if SiteID==	1903110016
replace SiteName = "Sare-Sare H/P" if SiteID==	1903110017
replace SiteName = "Alajawa Dispen" if SiteID==	1903110018
replace SiteName = "Wura Bagga H/P" if SiteID==	1903110019
replace SiteName = "Badau Dispen" if SiteID==	1903110020
replace SiteName = "Kwajale Disp" if SiteID==	1903110021
replace SiteName = "Tuga H/P" if SiteID==	1903110022
replace SiteName = "Rimin Bai H/P" if SiteID==	1903110023
replace SiteName = "Galawa HP" if SiteID==	1903110024
replace SiteName = "Baure HP" if SiteID==	1903110025
replace SiteName = "Kariya M/Kambu HP" if SiteID==	1903110026
replace SiteName = "Surfan HP" if SiteID==	1903110027
replace SiteName = "Tiga Gen. Hosp" if SiteID==	1904210001
replace SiteName = "Bebeji PHC" if SiteID==	1904110002
replace SiteName = "Tariwa Disp" if SiteID==	1904110003
replace SiteName = "Bagauda HP" if SiteID==	1904110004
replace SiteName = "Anadariya HP" if SiteID==	1904110005
replace SiteName = "Jibga H/P" if SiteID==	1904110006
replace SiteName = "Kuki Disp" if SiteID==	1904110007
replace SiteName = "Damau HP" if SiteID==	1904110008
replace SiteName = "Danbubu HP" if SiteID==	1904110009
replace SiteName = "Durmawa HP" if SiteID==	1904110010
replace SiteName = "Wak BHC" if SiteID==	1904110011
replace SiteName = "Hayin Gwarmai HP" if SiteID==	1904110012
replace SiteName = "Gargai HP" if SiteID==	1904110013
replace SiteName = "Gwarmai PHC" if SiteID==	1904110014
replace SiteName = "Kofa Disp" if SiteID==	1904110015
replace SiteName = "Rahama BHC" if SiteID==	1904110016
replace SiteName = "Nasarawar kuki HP" if SiteID==	1904110017
replace SiteName = "Ranka HP" if SiteID==	1904110018
replace SiteName = "Rantan HP" if SiteID==	1904110019
replace SiteName = "Cutar Biki HP" if SiteID==	1904110020
replace SiteName = "Taimako Nursing Home" if SiteID==	1904120021
replace SiteName = "Bichi Gen. Hosp" if SiteID==	1905210001
replace SiteName = "Danzabuwa MPHC" if SiteID==	1905110002
replace SiteName = "Badume HC" if SiteID==	1905110003
replace SiteName = "Kawaji HP" if SiteID==	1905110004
replace SiteName = "Kyauta HP" if SiteID==	1905110005
replace SiteName = "Sabo HP" if SiteID==	1905110006
replace SiteName = "Sanakur HP" if SiteID==	1905110007
replace SiteName = "Tsaure HP" if SiteID==	1905110008
replace SiteName = "Gulbi HP" if SiteID==	1905110009
replace SiteName = "Yola H/P" if SiteID==	1905110010
replace SiteName = "Damisa HP" if SiteID==	1905110011
replace SiteName = "Karari HP" if SiteID==	1905110012
replace SiteName = "Dutsen Karya H/P" if SiteID==	1905110013
replace SiteName = "Malikawa Sarari HP" if SiteID==	1905110014
replace SiteName = "Malikawa Garu HP" if SiteID==	1905110015
replace SiteName = "Fagwalo HP" if SiteID==	1905110016
replace SiteName = "Gyauro HP" if SiteID==	1905110017
replace SiteName = "Yatsi HP" if SiteID==	1905110018
replace SiteName = "Kungu H/P" if SiteID==	1905110019
replace SiteName = "Tukuibi HP" if SiteID==	1905110020
replace SiteName = "Yan Dutse HP" if SiteID==	1905110021
replace SiteName = "Rimayen Rake H/P" if SiteID==	1905110022
replace SiteName = "Kwamarawa HP" if SiteID==	1905110023
replace SiteName = "Hagawa HP" if SiteID==	1905110024
replace SiteName = "Tinki HP" if SiteID==	1905110025
replace SiteName = "Chiromawa HC" if SiteID==	1905110026
replace SiteName = "Lamba HP" if SiteID==	1905110027
replace SiteName = "Yangwarzo H/P" if SiteID==	1905110028
replace SiteName = "Iyawa HP" if SiteID==	1905110029
replace SiteName = "Sani A-Awa HP" if SiteID==	1905110030
replace SiteName = "Muntsira H/P" if SiteID==	1905110031
replace SiteName = "Tsaraka  H/P" if SiteID==	1905110032
replace SiteName = "Bankaura HP" if SiteID==	1905110033
replace SiteName = "Bum Bum HP" if SiteID==	1905110034
replace SiteName = "Saye MPHC" if SiteID==	1905110035
replace SiteName = "Yanbundu HP" if SiteID==	1905110036
replace SiteName = "Jinjimawa HP" if SiteID==	1905110037
replace SiteName = "Waire HP" if SiteID==	1905110038
replace SiteName = "Tsidau H/P" if SiteID==	1905110039
replace SiteName = "Belli HP" if SiteID==	1905110040
replace SiteName = "Daddo HP" if SiteID==	1905110041
replace SiteName = "Damargu PHC" if SiteID==	1905110042
replace SiteName = "Marga HP" if SiteID==	1905110043
replace SiteName = "Yanlami H/ P" if SiteID==	1905110044
replace SiteName = "Galaji HP" if SiteID==	1905110045
replace SiteName = "Margar Dari HP" if SiteID==	1905110046
replace SiteName = "Dutsen Dorawa Disp" if SiteID==	1905110047
replace SiteName = "Garun Bature HP" if SiteID==	1905110048
replace SiteName = "Gulbi HP" if SiteID==	1905110049
replace SiteName = "Yakasai HP" if SiteID==	1905110050
replace SiteName = "Bunkure BHC" if SiteID==	1906110001
replace SiteName = "Barkum Disp" if SiteID==	1906110002
replace SiteName = "Bono HP" if SiteID==	1906110003
replace SiteName = "Dandagana HP" if SiteID==	1906110004
replace SiteName = "Barnawa HP" if SiteID==	1906110005
replace SiteName = "Chirin Disp" if SiteID==	1906110006
replace SiteName = "Gafan HP" if SiteID==	1906110007
replace SiteName = "Shiye HP" if SiteID==	1906110008
replace SiteName = "Gwamma HP" if SiteID==	1906110009
replace SiteName = "Gwaneri Disp." if SiteID==	1906110010
replace SiteName = "Tsanbaki HP" if SiteID==	1906110011
replace SiteName = "Gurjiya H/P" if SiteID==	1906110012
replace SiteName = "Jalabi HP" if SiteID==	1906110013
replace SiteName = "Kulluwa HP" if SiteID==	1906110014
replace SiteName = "Dususu HP" if SiteID==	1906110015
replace SiteName = "Kumurya PHC" if SiteID==	1906110016
replace SiteName = "Dundu HP" if SiteID==	1906110017
replace SiteName = "Jarnawa HP" if SiteID==	1906110018
replace SiteName = "Sanda HP" if SiteID==	1906110019
replace SiteName = "Sabon Ruwa (mashaura) HP" if SiteID==	1906110020
replace SiteName = "Makunturi Hp" if SiteID==	1906110021
replace SiteName = "Jaroji HP" if SiteID==	1906110022
replace SiteName = "National Orth. Hos" if SiteID==	1907310001
replace SiteName = "Adakawa HP" if SiteID==	1907110002
replace SiteName = "Gobirawa HP" if SiteID==	1907110003
replace SiteName = "Hajia U-Zaria Clin" if SiteID==	1907110004
replace SiteName = "F/Arewa HC" if SiteID==	1907110005
replace SiteName = "Kofar Mazugal HP" if SiteID==	1907110006
replace SiteName = "Kofar Ruwa HP" if SiteID==	1907110007
replace SiteName = "Kurna HC" if SiteID==	1907110008
replace SiteName = "Madakin Gini H/C" if SiteID==	1907110009
replace SiteName = "Dala MCH Clin" if SiteID==	1907110010
replace SiteName = "Gwammaja MCH" if SiteID==	1907110011
replace SiteName = "K/Tudu  HC" if SiteID==	1907110012
replace SiteName = "Sheik Abubakar M/Yawa Bakin Ruwa" if SiteID==	1907110013
replace SiteName = "Mai Unguwa Garba HC" if SiteID==	1907110014
replace SiteName = "Danbatta Gen Hosp" if SiteID==	1908210001
replace SiteName = "FagwalawaCott Hosp" if SiteID==	1908210002
replace SiteName = "Fagwalo HP" if SiteID==	1908110003
replace SiteName = "GGASS & GSS Danbatta Clins" if SiteID==	1908110004
replace SiteName = "Mahuta HC" if SiteID==	1908110005
replace SiteName = "Ajumawa HP" if SiteID==	1908110006
replace SiteName = "Marken Danya HP" if SiteID==	1908110007
replace SiteName = "Yammawa HP" if SiteID==	1908110008
replace SiteName = "Tona HP" if SiteID==	1908110009
replace SiteName = "Goron Maje BHC" if SiteID==	1908110010
replace SiteName = "Diggol HP" if SiteID==	1908110011
replace SiteName = "Dukawa HP" if SiteID==	1908110012
replace SiteName = "Gwanda HP" if SiteID==	1908110013
replace SiteName = "Baushe HP" if SiteID==	1908110014
replace SiteName = "Shiddar HP" if SiteID==	1908110015
replace SiteName = "Gwarabjawa H/P" if SiteID==	1908110016
replace SiteName = "Gwalaida H/P" if SiteID==	1908110017
replace SiteName = "Dumma HP" if SiteID==	1908110018
replace SiteName = "Kore Disp" if SiteID==	1908110019
replace SiteName = "Ruwantsa HP" if SiteID==	1908110020
replace SiteName = "LarabarTakuya HP" if SiteID==	1908110021
replace SiteName = "Koya HP " if SiteID==	1908110022
replace SiteName = "Marken Mahuta HP" if SiteID==	1908110023
replace SiteName = "Saidawa HP" if SiteID==	1908110024
replace SiteName = "Kwasauri HP" if SiteID==	1908110025
replace SiteName = "Sansan HP (DBT)" if SiteID==	1908110026
replace SiteName = "Tsaraka Disp" if SiteID==	1908110027
replace SiteName = "Maiganji HP" if SiteID==	1908110028
replace SiteName = "Yammawa Wanzami HP" if SiteID==	1908110029
replace SiteName = "Chasko HP" if SiteID==	1908110030
replace SiteName = "Takau HP" if SiteID==	1908110031
replace SiteName = "Masallachi HP" if SiteID==	1908110032
replace SiteName = "Zago HP" if SiteID==	1908110033
replace SiteName = "Katsarduwa HP" if SiteID==	1908110034
replace SiteName = "Women Cente Clin" if SiteID==	1908110035
replace SiteName = "Mahuta HC" if SiteID==	1908110036
replace SiteName = "D/Kudu Gen Hosp" if SiteID==	1909210001
replace SiteName = "Daba  BHC" if SiteID==	1909110002
replace SiteName = "Dawakiji BHC" if SiteID==	1909110003
replace SiteName = "Dosan HP" if SiteID==	1909110004
replace SiteName = "Fanchin HP" if SiteID==	1909110005
replace SiteName = "KunKurawa HP" if SiteID==	1909110006
replace SiteName = "Gano BHC" if SiteID==	1909110007
replace SiteName = "Runa HP" if SiteID==	1909110008
replace SiteName = "Gurjiya HP " if SiteID==	1909110009
replace SiteName = "Jido Disp" if SiteID==	1909110010
replace SiteName = "Matage Disp" if SiteID==	1909110011
replace SiteName = "Tamburawa HP" if SiteID==	1909110012
replace SiteName = "Gada HP" if SiteID==	1909110013
replace SiteName = "Tsakuwa PHC" if SiteID==	1909110014
replace SiteName = "U/Duniya HP" if SiteID==	1909110015
replace SiteName = "Sarai HP" if SiteID==	1909110016
replace SiteName = "Yan Katsari Disp" if SiteID==	1909110017
replace SiteName = "Yar Gaya Disp" if SiteID==	1909110018
replace SiteName = "Zogarawa HP" if SiteID==	1909110019
replace SiteName = "Kamagata HP" if SiteID==	1909110020
replace SiteName = "Fanido HP" if SiteID==	1909110021
replace SiteName = "Dawakin Tofa Cot Hosp" if SiteID==	1910210001
replace SiteName = "Dawanau Psych hosp" if SiteID==	1910210002
replace SiteName = "Sarkakiya HP" if SiteID==	1910110003
replace SiteName = "GGSS D/Tofa Clin" if SiteID==	1910110004
replace SiteName = "Dan Guguwa Disp" if SiteID==	1910110005
replace SiteName = "Kadawa Disp " if SiteID==	1910110006
replace SiteName = "Bagadawa HP" if SiteID==	1910110007
replace SiteName = "Dawanau BHC" if SiteID==	1910110008
replace SiteName = "Nassarawa HP " if SiteID==	1910110009
replace SiteName = "Fagen Kawo H/P" if SiteID==	1910110010
replace SiteName = "Damfamin Tofa HP" if SiteID==	1910110011
replace SiteName = "Ganduje PHC" if SiteID==	1910110012
replace SiteName = "Jemomi HP" if SiteID==	1910110013
replace SiteName = "Roba HP" if SiteID==	1910110014
replace SiteName = "Gudau Disp" if SiteID==	1910110015
replace SiteName = "Gwamai HP" if SiteID==	1910110016
replace SiteName = "Dungurawa Disp" if SiteID==	1910110017
replace SiteName = "Jalli HP" if SiteID==	1910110018
replace SiteName = "Kuidawa HP" if SiteID==	1910110019
replace SiteName = "Madachi Disp" if SiteID==	1910110020
replace SiteName = "Buruntumau HP" if SiteID==	1910110021
replace SiteName = "Chedi Babbar Ruga HP" if SiteID==	1910110022
replace SiteName = "GGSS Kwa Clin" if SiteID==	1910110023
replace SiteName = "Kwa Disp" if SiteID==	1910110024
replace SiteName = "Kale Ku HP" if SiteID==	1910110025
replace SiteName = "Marke Disp" if SiteID==	1910110026
replace SiteName = "Yar Rutu HP" if SiteID==	1910110027
replace SiteName = "Joben Marke HP" if SiteID==	1910110028
replace SiteName = "Chedi Mai Dala (Ingawa) HP" if SiteID==	1910110029
replace SiteName = "Dandalama PHC" if SiteID==	1910110030
replace SiteName = "Dambazau HP" if SiteID==	1910110031
replace SiteName = "Kunnawa Hc" if SiteID==	1910110032
replace SiteName = "Fango HP" if SiteID==	1910110033
replace SiteName = "Romi HC" if SiteID==	1910110034
replace SiteName = "Tunfafi HP" if SiteID==	1910110035
replace SiteName = "Sarauniya HP" if SiteID==	1910110036
replace SiteName = "Gargari HP" if SiteID==	1910110037
replace SiteName = "Tattarawa PHC" if SiteID==	1910110038
replace SiteName = "Zangon Mata Disp" if SiteID==	1910110039
replace SiteName = "Gabari HP (DTF)" if SiteID==	1910110040
replace SiteName = "Zangon Dawanau PHC" if SiteID==	1910110041
replace SiteName = "Kirya HP" if SiteID==	1910110042
replace SiteName = "Makerawa HP" if SiteID==	1910110043
replace SiteName = "Yakasan Dandalama HP" if SiteID==	1910110044
replace SiteName = "Doguwa Gen Hosp" if SiteID==	1911210001
replace SiteName = "Riruwai BHC" if SiteID==	1911110002
replace SiteName = "Doguwa Dispen." if SiteID==	1911110003
replace SiteName = "Birji PHC" if SiteID==	1911110004
replace SiteName = "Dogon Kawo HP" if SiteID==	1911110005
replace SiteName = "Dariyar Shere HP" if SiteID==	1911110006
replace SiteName = "Falgore Disp" if SiteID==	1911110007
replace SiteName = "Fanyabo HP" if SiteID==	1911110008
replace SiteName = "Gada Biyu HP" if SiteID==	1911110009
replace SiteName = "Maraku Disp" if SiteID==	1911110010
replace SiteName = "Dadin-Kowa Disp" if SiteID==	1911110011
replace SiteName = "Rufai HP" if SiteID==	1911110012
replace SiteName = "Dokar Goma Disp " if SiteID==	1911110013
replace SiteName = "Tagwaye Dispensary" if SiteID==	1911110014
replace SiteName = "Asada Disp" if SiteID==	1911110015
replace SiteName = "U/Natsohuwa HP" if SiteID==	1911110016
replace SiteName = "Karasa HP" if SiteID==	1911110017
replace SiteName = "Zainabi Disp" if SiteID==	1911110018
replace SiteName = "Y/DanMusa HP" if SiteID==	1911110019
replace SiteName = "MaiKwandira HP" if SiteID==	1911110020
replace SiteName = "I.D Hosp" if SiteID==	1912210001
replace SiteName = "Sheik MJ Gen Hosp" if SiteID==	1912210002
replace SiteName = "Abubakar Imam Urology Centre" if SiteID==	1912110003
replace SiteName = "Nig Armed Forces Hosp" if SiteID==	1912210004
replace SiteName = "Galadima Fagge HC" if SiteID==	1912110005
replace SiteName = "Sabo Garba Mat" if SiteID==	1912120006
replace SiteName = "Dan Rimi HP" if SiteID==	1912110007
replace SiteName = "Kwaciri  BHC" if SiteID==	1912110008
replace SiteName = "Tudun Bojuwa (HAJARATU) HC" if SiteID==	1912110009
replace SiteName = "Yammata HP" if SiteID==	1912110010
replace SiteName = "Nig Airforce Clin " if SiteID==	1912110011
replace SiteName = "Jaba MPHC" if SiteID==	1912110012
replace SiteName = "S/G Middlle Rd MCH" if SiteID==	1912120013
replace SiteName = "Rijiyar Lemo MPHC" if SiteID==	1912110014
replace SiteName = "Rijiyar Lemo MCH " if SiteID==	1912110015
replace SiteName = "Arewa Surgey Hosp" if SiteID==	1912220016
replace SiteName = "Intl Clin" if SiteID==	1912120017
replace SiteName = "Khadijat Hosp (DAL)" if SiteID==	1912220018
replace SiteName = "Rahamaniyawa PHC" if SiteID==	1912120019
replace SiteName = "Sabo Clin" if SiteID==	1912120020
replace SiteName = "Light Clin" if SiteID==	1912120021
replace SiteName = "Tiga Clin" if SiteID==	1912120022
replace SiteName = "Al-Hassan Hosp" if SiteID==	1912220023
replace SiteName = "Amina Spec Hosp" if SiteID==	1912220024
replace SiteName = "Castle Clin & Mat Hosp" if SiteID==	1912120025
replace SiteName = "Catharina Hosp" if SiteID==	1912120026
replace SiteName = "Hali Clin" if SiteID==	1912120027
replace SiteName = "Hope Clin & Mat" if SiteID==	1912120028
replace SiteName = "Ideal Hosp" if SiteID==	1912120029
replace SiteName = "Lafiya Surgery Hosp" if SiteID==	1912220030
replace SiteName = "Model Clin" if SiteID==	1912120031
replace SiteName = "Modular Clin" if SiteID==	1912120032
replace SiteName = "Nakowa Clin" if SiteID==	1912120033
replace SiteName = "New Tyrones Clin" if SiteID==	1912120034
replace SiteName = "Salam Clin " if SiteID==	1912120035
replace SiteName = "Soomia Clin" if SiteID==	1912120036
replace SiteName = "Maycare Hosp" if SiteID==	1912120037
replace SiteName = "Universal Clin " if SiteID==	1912120038
replace SiteName = "Waliy Welfare Hosp" if SiteID==	1912120039
replace SiteName = "Ejeoma Clin" if SiteID==	1912120040
replace SiteName = "Assumpta Clin" if SiteID==	1912120041
replace SiteName = "Barewa Clin" if SiteID==	1912120042
replace SiteName = "Chisam Clin" if SiteID==	1912120043
replace SiteName = "Continental Clin" if SiteID==	1912120044
replace SiteName = "Crescent Clin" if SiteID==	1912120045
replace SiteName = "Crown Dental" if SiteID==	1912120046
replace SiteName = "Ebony Clin" if SiteID==	1912120047
replace SiteName = "Middle Road Maternity" if SiteID==	1912120048
replace SiteName = "Emotan Clin" if SiteID==	1912120049
replace SiteName = "Foundation Clin" if SiteID==	1912120050
replace SiteName = "Good Pasture Clin" if SiteID==	1912120051
replace SiteName = "Gresland Clin" if SiteID==	1912120052
replace SiteName = "Gabasawa MPHC" if SiteID==	1913110001
replace SiteName = "Zakirai CHC" if SiteID==	1913110002
replace SiteName = "Chikawa HP" if SiteID==	1913110003
replace SiteName = "Dadin Duniya HP" if SiteID==	1913110004
replace SiteName = "Kawo Disp" if SiteID==	1913110005
replace SiteName = "Doga HP" if SiteID==	1913110006
replace SiteName = "Fangam HP" if SiteID==	1913110007
replace SiteName = "Gambawa HP" if SiteID==	1913110008
replace SiteName = "Garun Danga MPHC" if SiteID==	1913110009
replace SiteName = "Joda Disp" if SiteID==	1913110010
replace SiteName = "Santsi Disp" if SiteID==	1913110011
replace SiteName = "Wasarde HP" if SiteID==	1913110012
replace SiteName = "Gumawa HP" if SiteID==	1913110013
replace SiteName = "Karmami MHC" if SiteID==	1913110014
replace SiteName = "Badawa HP" if SiteID==	1913110015
replace SiteName = "Kumbo HP" if SiteID==	1913110016
replace SiteName = "Mazan Gudu HP" if SiteID==	1913110017
replace SiteName = "Mekiya Disp" if SiteID==	1913110018
replace SiteName = "Shana HP" if SiteID==	1913110019
replace SiteName = "Dan Dake HP" if SiteID==	1913110020
replace SiteName = "Guruma HP" if SiteID==	1913110021
replace SiteName = "Yar Zabaina HP" if SiteID==	1913110022
replace SiteName = "Yaranchi Disp" if SiteID==	1913110023
replace SiteName = "Yamakanawa Disp" if SiteID==	1913110024
replace SiteName = "Yumbu Dispensary" if SiteID==	1913110025
replace SiteName = "Tankarau HP" if SiteID==	1913110026
replace SiteName = "Zugachi BHC" if SiteID==	1913110027
replace SiteName = "Tarauni HP" if SiteID==	1913110028
replace SiteName = "Yautar Kudu HP" if SiteID==	1913110029
replace SiteName = "Kwadage HP" if SiteID==	1913110030
replace SiteName = "Garko PHC" if SiteID==	1914110001
replace SiteName = "Garko MPHC" if SiteID==	1914110002
replace SiteName = "Dal MPHC" if SiteID==	1914110003
replace SiteName = "Garin-Ali PHC" if SiteID==	1914110004
replace SiteName = "Kafin Mallamai Disp" if SiteID==	1914110005
replace SiteName = "Lamire HP" if SiteID==	1914110006
replace SiteName = "Sanni Disp" if SiteID==	1914110007
replace SiteName = "Kwas HP" if SiteID==	1914110008
replace SiteName = "Tsakuwa Dal HP" if SiteID==	1914110009
replace SiteName = "Kawo HP (GAK)" if SiteID==	1914110010
replace SiteName = "Maida HP" if SiteID==	1914110011
replace SiteName = "Sarina MHC" if SiteID==	1914110012
replace SiteName = "Buda Disp" if SiteID==	1914110013
replace SiteName = "Garwaji HP" if SiteID==	1914110014
replace SiteName = "Kafinchiri BHC" if SiteID==	1914110015
replace SiteName = "Makadi HP" if SiteID==	1914110016
replace SiteName = "Zakarawa Disp" if SiteID==	1914110017
replace SiteName = "Gurjiya Disensary" if SiteID==	1914110018
replace SiteName = "AHIP" if SiteID==	1914220019
replace SiteName = "Garun Malam PHC" if SiteID==	1915110001
replace SiteName = "Kadawa quart HP" if SiteID==	1915110002
replace SiteName = "Chiromawa K HP" if SiteID==	1915110003
replace SiteName = "Mudawa HP" if SiteID==	1915110004
replace SiteName = "Unguwar Kudu HP" if SiteID==	1915110005
replace SiteName = "Dakasoye HP" if SiteID==	1915110006
replace SiteName = "Dorawar Sallau HP" if SiteID==	1915110007
replace SiteName = "Garun Babba Clin" if SiteID==	1915110008
replace SiteName = "Jobawa HP" if SiteID==	1915110009
replace SiteName = "Kadawa Ciki HP" if SiteID==	1915110010
replace SiteName = "Kadawa PHC" if SiteID==	1915110011
replace SiteName = "Makwaro HP" if SiteID==	1915110012
replace SiteName = "Agalawa HP" if SiteID==	1915110013
replace SiteName = "Dan-Mora HP" if SiteID==	1915110014
replace SiteName = "Kwiwa HP" if SiteID==	1915110015
replace SiteName = "Yadakwari BHC" if SiteID==	1915110016
replace SiteName = "Gaya Gen Hosp" if SiteID==	1916210001
replace SiteName = "Gaya South HC" if SiteID==	1916110002
replace SiteName = "Balan HP" if SiteID==	1916110003
replace SiteName = "Jibawa HP" if SiteID==	1916110004
replace SiteName = "Gamarya HC" if SiteID==	1916110005
replace SiteName = "Gamoji HP" if SiteID==	1916110006
replace SiteName = "Kawarin Bangashe HP" if SiteID==	1916110007
replace SiteName = "Agundawa HP" if SiteID==	1916110008
replace SiteName = "Kademi PHC" if SiteID==	1916110009
replace SiteName = "Kera HP" if SiteID==	1916110010
replace SiteName = "Kazurawa HP" if SiteID==	1916110011
replace SiteName = "Yan Kau Clin" if SiteID==	1916110012
replace SiteName = "Maimakawa Clin" if SiteID==	1916110013
replace SiteName = "Yan Audu HP" if SiteID==	1916110014
replace SiteName = "Jobe HP" if SiteID==	1916110015
replace SiteName = "Gungara HP" if SiteID==	1916110016
replace SiteName = "Gidan S/Noma MPHC" if SiteID==	1916110017
replace SiteName = "Yansoro HP" if SiteID==	1916110018
replace SiteName = "Kalahaddi HP" if SiteID==	1916110019
replace SiteName = "Amarawa HP" if SiteID==	1916110020
replace SiteName = "Hausawa HP" if SiteID==	1916110021
replace SiteName = "Fan ido HP" if SiteID==	1916110022
replace SiteName = "Dorayi Babba Clin" if SiteID==	1917110001
replace SiteName = "Dorayi Karama Clin" if SiteID==	1917110002
replace SiteName = "Ja'en HC" if SiteID==	1917110003
replace SiteName = "F/Yamma Clin" if SiteID==	1917110004
replace SiteName = "Gwale MCH" if SiteID==	1917110005
replace SiteName = "K/Naisa HP" if SiteID==	1917110006
replace SiteName = "Aisami Disp" if SiteID==	1917110007
replace SiteName = "Dukawuya HC" if SiteID==	1917110008
replace SiteName = "FCE Staff Clin" if SiteID==	1917110009
replace SiteName = "K/Kabuga PHC" if SiteID==	1917110010
replace SiteName = "Kofar Waika HP" if SiteID==	1917110011
replace SiteName = "Unguwar Dabai PHC" if SiteID==	1917110012
replace SiteName = "B.U.K Staff Clin" if SiteID==	1917110013
replace SiteName = "Sabon Sara HC" if SiteID==	1917110014
replace SiteName = "K/Janbulo BHC" if SiteID==	1917110015
replace SiteName = "Dalai Rinji HC" if SiteID==	1917110016
replace SiteName = "Kwamitin Makofta S/M HC" if SiteID==	1917110017
replace SiteName = "Dausayi HC" if SiteID==	1917110018
replace SiteName = "S/Madina HP" if SiteID==	1917110019
replace SiteName = "U/Jakada HC" if SiteID==	1917110020
replace SiteName = "Gezawa Gen Hosp" if SiteID==	1918210001
replace SiteName = "Gezawa Disp" if SiteID==	1918110002
replace SiteName = "Babawa MPHC" if SiteID==	1918110003
replace SiteName = "Gunduwawa HP" if SiteID==	1918110004
replace SiteName = "Musku HP" if SiteID==	1918110005
replace SiteName = "Tofa Dispensary" if SiteID==	1918110006
replace SiteName = "Jogana Disp" if SiteID==	1918110007
replace SiteName = "Yafata HP" if SiteID==	1918110008
replace SiteName = "Baita HP" if SiteID==	1918110009
replace SiteName = "Mesar Burmi HP" if SiteID==	1918110010
replace SiteName = "Mesar Tudu HP" if SiteID==	1918110011
replace SiteName = "Imamu Wali Dis" if SiteID==	1918120012
replace SiteName = "Larabar Abasawa HC" if SiteID==	1918110013
replace SiteName = "Tsamiya Babba Disp" if SiteID==	1918110014
replace SiteName = "Tumbau HP" if SiteID==	1918110015
replace SiteName = "Wangara Disp" if SiteID==	1918110016
replace SiteName = "Daraudau HP" if SiteID==	1918110017
replace SiteName = "Tsalle Disp" if SiteID==	1918110018
replace SiteName = "Zango Disp" if SiteID==	1918110019
replace SiteName = "Gofara PHC" if SiteID==	1918110020
replace SiteName = "Kwasangwami PHC" if SiteID==	1918110021
replace SiteName = "Gwarzo Gen Hosp" if SiteID==	1919210001
replace SiteName = "Getso MHC" if SiteID==	1919110002
replace SiteName = "Yar Kasuwa HP" if SiteID==	1919110003
replace SiteName = "Badari HP" if SiteID==	1919110004
replace SiteName = "Malamawa Disp" if SiteID==	1919110005
replace SiteName = "Kara Disp" if SiteID==	1919110006
replace SiteName = "Koya HP (GRZ)" if SiteID==	1919110007
replace SiteName = "Sabon Layi Kara HP" if SiteID==	1919110008
replace SiteName = "Kutama Disp" if SiteID==	1919110009
replace SiteName = "Dakwara HP" if SiteID==	1919110010
replace SiteName = "Lakwaya Disp" if SiteID==	1919110011
replace SiteName = "Rugoji HP" if SiteID==	1919110012
replace SiteName = "Madadi BHC" if SiteID==	1919110013
replace SiteName = "Marori HP" if SiteID==	1919110014
replace SiteName = "Dankyandi HP" if SiteID==	1919110015
replace SiteName = "Mainika HP" if SiteID==	1919110016
replace SiteName = "Makanwata HP" if SiteID==	1919110017
replace SiteName = "Sabon Birni Disp" if SiteID==	1919110018
replace SiteName = "Dorogo Ung HP" if SiteID==	1919110019
replace SiteName = "Dan nafada Disp" if SiteID==	1919110020
replace SiteName = "Jama'a PHC U/C" if SiteID==	1919110021
replace SiteName = "Tumfafi HP" if SiteID==	1919110022
replace SiteName = "Dalan Gashi HP" if SiteID==	1919110023
replace SiteName = "Mallam Gajere HP" if SiteID==	1920110001
replace SiteName = "Dugabau Disp" if SiteID==	1920110002
replace SiteName = "Unguwarturaki HP" if SiteID==	1920110003
replace SiteName = "Walawa HP" if SiteID==	1920110004
replace SiteName = "Durun MCH" if SiteID==	1920110005
replace SiteName = "Gabasawa HP" if SiteID==	1920110006
replace SiteName = "Gammo Disp" if SiteID==	1920110007
replace SiteName = "Fagore HP" if SiteID==	1920110008
replace SiteName = "Garo PHC" if SiteID==	1920110009
replace SiteName = "Kanye HP" if SiteID==	1920110010
replace SiteName = "Balan Disp" if SiteID==	1920110011
replace SiteName = "Godiya Disp" if SiteID==	1920110012
replace SiteName = "Wari HP" if SiteID==	1920110013
replace SiteName = "Gude Disp" if SiteID==	1920110014
replace SiteName = "Husure HP" if SiteID==	1920110015
replace SiteName = "H/Bango HP" if SiteID==	1920110016
replace SiteName = "Hayin Galadima HP" if SiteID==	1920110017
replace SiteName = "Baskore HP" if SiteID==	1920110018
replace SiteName = "Kanwa HP " if SiteID==	1920110019
replace SiteName = "Kazode HP" if SiteID==	1920110020
replace SiteName = "Masanawa Disp" if SiteID==	1920110021
replace SiteName = "Kabo Cottage Hosp" if SiteID==	1920210022
replace SiteName = "Shadau HP" if SiteID==	1920110023
replace SiteName = "Danmaliki HP" if SiteID==	1920110024
replace SiteName = "Sari Girin HP" if SiteID==	1920110025
replace SiteName = "Dan Amale HP" if SiteID==	1920110026
replace SiteName = "Sharifai HP" if SiteID==	1920110027
replace SiteName = "Kauyen Mahauta HP" if SiteID==	1920110028
replace SiteName = "S/Bakin Zuwo Mat" if SiteID==	1921210001
replace SiteName = "Hasiya Bayero Hosp" if SiteID==	1921210002
replace SiteName = "Murtala Mohammed Spec Hosp" if SiteID==	1921210003
replace SiteName = "Tukuntawa HC" if SiteID==	1921110004
replace SiteName = "Gandu Model PHC" if SiteID==	1921110005
replace SiteName = "Bamalli Nuhu Dom Mat Hosp" if SiteID==	1921210006
replace SiteName = "Kano Prison Clin" if SiteID==	1921110007
replace SiteName = "Kwalli Disp" if SiteID==	1921110008
replace SiteName = "New Hasiya Bayero Ped Hosp" if SiteID==	1921210009
replace SiteName = "Madatai HC" if SiteID==	1921110010
replace SiteName = "Sharada PHC" if SiteID==	1921110011
replace SiteName = "Marmara MCH" if SiteID==	1921110012
replace SiteName = "Emir's Palace HC" if SiteID==	1921110013
replace SiteName = "Yakasai Zumunta Clin" if SiteID==	1921110014
replace SiteName = "Mayanka PHC" if SiteID==	1921110015
replace SiteName = "YanAwaki Clin" if SiteID==	1921110016
replace SiteName = "Unguwar Gini PHC" if SiteID==	1921110017
replace SiteName = "Fuskar Gabas HC" if SiteID==	1921110018
replace SiteName = "Alfindiki Zumunta MED HC" if SiteID==	1921110019
replace SiteName = "Karaye CHC" if SiteID==	1922110001
replace SiteName = "Daura HP" if SiteID==	1922110002
replace SiteName = "Unguwar Tofa HP" if SiteID==	1922110003
replace SiteName = "Dambazau HP (KRY)" if SiteID==	1922110004
replace SiteName = "Zangon Majema HP" if SiteID==	1922110005
replace SiteName = "Kurugu HP" if SiteID==	1922110006
replace SiteName = "Kwanyawa MHC" if SiteID==	1922110007
replace SiteName = "Tudun Kaya Disp" if SiteID==	1922110008
replace SiteName = "Turawa Disp" if SiteID==	1922110009
replace SiteName = "Unguwar Mani HP" if SiteID==	1922110010
replace SiteName = "Kafin Dafga Disp" if SiteID==	1922110011
replace SiteName = "Sabon Fegi HP" if SiteID==	1922110012
replace SiteName = "Yammedi MPHC" if SiteID==	1922110013
replace SiteName = "Ma'a HP" if SiteID==	1922110014
replace SiteName = "Yola HP " if SiteID==	1922110015
replace SiteName = "Dederi Disp" if SiteID==	1922110016
replace SiteName = "Unity School Clin" if SiteID==	1922110017
replace SiteName = "D/Gayaki HP" if SiteID==	1922110018
replace SiteName = "D/Amare Hp" if SiteID==	1922110019
replace SiteName = "Husama HP" if SiteID==	1922110020
replace SiteName = "Kibiya PHC" if SiteID==	1923110001
replace SiteName = "Durba BHC" if SiteID==	1923110002
replace SiteName = "Sarari HP" if SiteID==	1923110003
replace SiteName = "Fammar HP" if SiteID==	1923110004
replace SiteName = "Kure BHC" if SiteID==	1923110005
replace SiteName = "Kalambuh HP" if SiteID==	1923110006
replace SiteName = "Saya Saya BHC " if SiteID==	1923110007
replace SiteName = "Kadigawa HP" if SiteID==	1923110008
replace SiteName = "Kuluki HP" if SiteID==	1923110009
replace SiteName = "Kahu HP" if SiteID==	1923110010
replace SiteName = "Shike HP" if SiteID==	1923110011
replace SiteName = "Gunda HP" if SiteID==	1923110012
replace SiteName = "Bacha HP" if SiteID==	1923110013
replace SiteName = "Chalbo HP" if SiteID==	1923110014
replace SiteName = "Nariya HP" if SiteID==	1923110015
replace SiteName = "Tarai BHC" if SiteID==	1923110016
replace SiteName = "D/Durba HP" if SiteID==	1923110017
replace SiteName = "U/Gai HP" if SiteID==	1923110018
replace SiteName = "Ung Liman HP " if SiteID==	1923110019
replace SiteName = "Faran HP" if SiteID==	1923110020
replace SiteName = "Fancha HP" if SiteID==	1923110021
replace SiteName = "Kiru CHC" if SiteID==	1924110001
replace SiteName = "Ba'awa BHC" if SiteID==	1924110002
replace SiteName = "Maska Disp" if SiteID==	1924110003
replace SiteName = "Sakarma HP" if SiteID==	1924110004
replace SiteName = "Badafi HP" if SiteID==	1924110005
replace SiteName = "Bargi HP" if SiteID==	1924110006
replace SiteName = "Yarganji HP" if SiteID==	1924110007
replace SiteName = "Acilafiya HP" if SiteID==	1924110008
replace SiteName = "Bargoni Disp" if SiteID==	1924110009
replace SiteName = "Kailani HP" if SiteID==	1924110010
replace SiteName = "Bauda Disp" if SiteID==	1924110011
replace SiteName = "Dangora Disp" if SiteID==	1924110012
replace SiteName = "Kyarana HP" if SiteID==	1924110013
replace SiteName = "0" if SiteID==	1924110014
replace SiteName = "Gabari HP (kku" if SiteID==	1924110015
replace SiteName = "Dashi HP" if SiteID==	1924110016
replace SiteName = "Galadimawa HP " if SiteID==	1924110017
replace SiteName = "Alhazawa HP" if SiteID==	1924110018
replace SiteName = "Daurawa HP" if SiteID==	1924110019
replace SiteName = "Kogo HP" if SiteID==	1924110020
replace SiteName = "Maraku HP" if SiteID==	1924110021
replace SiteName = "Tsaudawa HP" if SiteID==	1924110022
replace SiteName = "Yako BHC" if SiteID==	1924110023
replace SiteName = "Gajale HP (KKU)" if SiteID==	1924110024
replace SiteName = "Kafin Maiyaki BHC" if SiteID==	1924110025
replace SiteName = "Yalwa HP (KKU)" if SiteID==	1924110026
replace SiteName = "Zuwo HP" if SiteID==	1924110027
replace SiteName = "Dansoshiya Disp" if SiteID==	1924110028
replace SiteName = "Makatuwo HP" if SiteID==	1924110029
replace SiteName = "Gazan HP" if SiteID==	1924110030
replace SiteName = "Tahfizul Qur. Sch CL" if SiteID==	1924110031
replace SiteName = "M.A WASE CHC" if SiteID==	1925110001
replace SiteName = "Shekar Barde PHC" if SiteID==	1925110002
replace SiteName = "Shekar Madaki HP" if SiteID==	1925110003
replace SiteName = "Ja'oji HP" if SiteID==	1925110004
replace SiteName = "Rinkusawa HP" if SiteID==	1925110005
replace SiteName = "Challawa BHC" if SiteID==	1925110006
replace SiteName = "Chiranci HP" if SiteID==	1925110007
replace SiteName = "Dan Maliki Disp" if SiteID==	1925110008
replace SiteName = "Danbare HP" if SiteID==	1925110009
replace SiteName = "Gwazaye HP" if SiteID==	1925110010
replace SiteName = "Bechi HP" if SiteID==	1925110011
replace SiteName = "Guringawa Disp" if SiteID==	1925110012
replace SiteName = "Riga Fada HP" if SiteID==	1925110013
replace SiteName = "Mariri BHC" if SiteID==	1925110014
replace SiteName = "Zara HP" if SiteID==	1925110015
replace SiteName = "Dangwaro HP" if SiteID==	1925110016
replace SiteName = "Maikalwa Disp" if SiteID==	1925110017
replace SiteName = "Na'ibawa HP" if SiteID==	1925110018
replace SiteName = "Wailare HP" if SiteID==	1925110019
replace SiteName = "Panshekara BHC" if SiteID==	1925110020
replace SiteName = "Zawachiki HP" if SiteID==	1925110021
replace SiteName = "Limawa HP" if SiteID==	1925110022
replace SiteName = "Unguwar Rimi HP" if SiteID==	1925110023
replace SiteName = "Kunchi PHC" if SiteID==	1926110001
replace SiteName = "Bumai HP" if SiteID==	1926110002
replace SiteName = "Danjaka HP" if SiteID==	1926110003
replace SiteName = "Jangefe HP" if SiteID==	1926110004
replace SiteName = "U/gyartai HP" if SiteID==	1926110005
replace SiteName = "Rigana HP" if SiteID==	1926110006
replace SiteName = "Gwarmai BHC" if SiteID==	1926110007
replace SiteName = "Dan Kwai HP" if SiteID==	1926110008
replace SiteName = "Jodade HP" if SiteID==	1926110009
replace SiteName = "Kasuwar Kuka MPHC" if SiteID==	1926110010
replace SiteName = "Tabanni HP" if SiteID==	1926110011
replace SiteName = "Tofawa HP" if SiteID==	1926110012
replace SiteName = "Sodawa HP" if SiteID==	1926110013
replace SiteName = "Falle HP" if SiteID==	1926110014
replace SiteName = "Gadaba HP" if SiteID==	1926110015
replace SiteName = "Kaya HP" if SiteID==	1926110016
replace SiteName = "Matan Fada Disp" if SiteID==	1926110017
replace SiteName = "Ridawa HP" if SiteID==	1926110018
replace SiteName = "Baji Shama HP" if SiteID==	1926110019
replace SiteName = "Gwadama BHC" if SiteID==	1926110020
replace SiteName = "Shamakawa HP" if SiteID==	1926110021
replace SiteName = "Dunbule HP" if SiteID==	1926110022
replace SiteName = "Galadimawa HP " if SiteID==	1926110023
replace SiteName = "Hugungumai HP" if SiteID==	1926110024
replace SiteName = "Shuwaki MPHC" if SiteID==	1926110025
replace SiteName = "Karofawa HP" if SiteID==	1926110026
replace SiteName = "Magawata HP" if SiteID==	1926110027
replace SiteName = "Yan Dadi Disp" if SiteID==	1926110028
replace SiteName = "Yan Kifi HP" if SiteID==	1926110029
replace SiteName = "K/Kunchi HP" if SiteID==	1926110030
replace SiteName = "Kuku HP" if SiteID==	1926110031
replace SiteName = "Gidan Nasau HP" if SiteID==	1926110032
replace SiteName = "Kura Gen Hosp" if SiteID==	1927210001
replace SiteName = "Kura HC" if SiteID==	1927110002
replace SiteName = "Azore HC" if SiteID==	1927110003
replace SiteName = "Danhassan PHC" if SiteID==	1927110004
replace SiteName = "Gamadan HP" if SiteID==	1927110005
replace SiteName = "Dukawa Disp" if SiteID==	1927110006
replace SiteName = "Kunshama A. HC" if SiteID==	1927110007
replace SiteName = "Kunshama B. HC" if SiteID==	1927110008
replace SiteName = "Gainawa HP" if SiteID==	1927110009
replace SiteName = "Gundutse HC" if SiteID==	1927110010
replace SiteName = "Karfi Disp" if SiteID==	1927110011
replace SiteName = "Imawa HC" if SiteID==	1927110012
replace SiteName = "Kadani HC" if SiteID==	1927110013
replace SiteName = "Kirya HC" if SiteID==	1927110014
replace SiteName = "Godar Ali HP" if SiteID==	1927110015
replace SiteName = "R/Kwarya HC" if SiteID==	1927110016
replace SiteName = "Hadeja Jamaare HC" if SiteID==	1927110017
replace SiteName = "Guraza HC" if SiteID==	1927110018
replace SiteName = "Akilu Memorial CHC" if SiteID==	1928110001
replace SiteName = "Birji HC" if SiteID==	1928110002
replace SiteName = "Maraya HP" if SiteID==	1928110003
replace SiteName = "Chinkoso HP" if SiteID==	1928110004
replace SiteName = "Dan Marina HP" if SiteID==	1928110005
replace SiteName = "Gora Disp" if SiteID==	1928110006
replace SiteName = "Kafin-Agur BHC" if SiteID==	1928110007
replace SiteName = "Hausawa HP" if SiteID==	1928110008
replace SiteName = "Kanwa Disp" if SiteID==	1928110009
replace SiteName = "Kauran Mata BHC" if SiteID==	1928110010
replace SiteName = "Kubarachi BHC" if SiteID==	1928110011
replace SiteName = "Kundirin HP" if SiteID==	1928110012
replace SiteName = "Kwankwaso BHC" if SiteID==	1928110013
replace SiteName = "Ningawa HP" if SiteID==	1928110014
replace SiteName = "Gara HP" if SiteID==	1928110015
replace SiteName = "Jirgwai HP" if SiteID==	1928110016
replace SiteName = "Rikadawa HP" if SiteID==	1928110017
replace SiteName = "Yakun HP" if SiteID==	1928110018
replace SiteName = "Daburau HP" if SiteID==	1928110019
replace SiteName = "Galinja HP" if SiteID==	1928110020
replace SiteName = "Ganji HP" if SiteID==	1929110001
replace SiteName = "Makoda PHC" if SiteID==	1929110002
replace SiteName = "Shantake HP" if SiteID==	1929110003
replace SiteName = "Audu Bako School C" if SiteID==	1929110004
replace SiteName = "Tasharbasa HP" if SiteID==	1929110005
replace SiteName = "Bare Bari Disp" if SiteID==	1929110006
replace SiteName = "Jibga HP " if SiteID==	1929110007
replace SiteName = "Danmaidaki HP" if SiteID==	1929110008
replace SiteName = "Jama'ar Hazo HP" if SiteID==	1929110009
replace SiteName = "Kantudu HC" if SiteID==	1929110010
replace SiteName = "Kurna HP" if SiteID==	1929110011
replace SiteName = "Koguna PHC" if SiteID==	1929110012
replace SiteName = "Sabon Ruwa HP" if SiteID==	1929110013
replace SiteName = "Dunawa HP" if SiteID==	1929110014
replace SiteName = "Kore HP" if SiteID==	1929110015
replace SiteName = "Mai-Tsidau HC" if SiteID==	1929110016
replace SiteName = "Dawan Kaya HP" if SiteID==	1929110017
replace SiteName = "Jigawar Satame HP" if SiteID==	1929110018
replace SiteName = "Tangaji HP" if SiteID==	1929110019
replace SiteName = "Tangajiyo 2 HP" if SiteID==	1929110020
replace SiteName = "Wailare Disp" if SiteID==	1929110021
replace SiteName = "Bakalari HP" if SiteID==	1929110022
replace SiteName = "Walawa HP" if SiteID==	1929110023
replace SiteName = "Yallada HP" if SiteID==	1929110024
replace SiteName = "Minjibir Gen. Hosp" if SiteID==	1930210001
replace SiteName = "Garji HP" if SiteID==	1930110002
replace SiteName = "Koya BHC" if SiteID==	1930110003
replace SiteName = "Sanbauna BHC" if SiteID==	1930110004
replace SiteName = "Gandurwawa BHC" if SiteID==	1930110005
replace SiteName = "Gyeranya Disp" if SiteID==	1930110006
replace SiteName = "Kantama Babba HP" if SiteID==	1930110007
replace SiteName = "Danbawa HP" if SiteID==	1930110008
replace SiteName = "Kunya BHC" if SiteID==	1930110009
replace SiteName = "Geza HP" if SiteID==	1930110010
replace SiteName = "Jirgabawa HP" if SiteID==	1930110011
replace SiteName = "Kuru Disp" if SiteID==	1930110012
replace SiteName = "Zabainawa Dansudu HP" if SiteID==	1930110013
replace SiteName = "Gasgainu Disp" if SiteID==	1930110014
replace SiteName = "Kwarkiya HP" if SiteID==	1930110015
replace SiteName = "Sarbi HP" if SiteID==	1930110016
replace SiteName = "Tunkunawa HP" if SiteID==	1930110017
replace SiteName = "Zango HP" if SiteID==	1930110018
replace SiteName = "Tsakiya Disp" if SiteID==	1930110019
replace SiteName = "Kankarawa Disp" if SiteID==	1930110020
replace SiteName = "Abdakaya HP" if SiteID==	1930110021
replace SiteName = "Wasai HP" if SiteID==	1930110022
replace SiteName = "Gurjiya Disp" if SiteID==	1930110023
replace SiteName = "Garke HP" if SiteID==	1930110024
replace SiteName = "MA Wase Spec Hosp" if SiteID==	1931210001
replace SiteName = "Sir MS Gen Hosp" if SiteID==	1931210002
replace SiteName = "Gama Health Post" if SiteID==	1931110003
replace SiteName = "Badawa Disp" if SiteID==	1931110004
replace SiteName = "Kawo HP" if SiteID==	1931110005
replace SiteName = "Giginyu BHC" if SiteID==	1931110006
replace SiteName = "Hotoro South HP" if SiteID==	1931110007
replace SiteName = "Ladanai HP" if SiteID==	1931110008
replace SiteName = "Hotoro North HC" if SiteID==	1931110009
replace SiteName = "Kauran Goje HP" if SiteID==	1931110010
replace SiteName = "Kawaji Disp" if SiteID==	1931110011
replace SiteName = "Tokarawa PHC" if SiteID==	1931110012
replace SiteName = "D/Dakata Clin" if SiteID==	1931110013
replace SiteName = "Gwagwarwa PHC" if SiteID==	1931110014
replace SiteName = "Bompai Police Clin " if SiteID==	1931110015
replace SiteName = "SHT Clin" if SiteID==	1931110016
replace SiteName = "T/Murtala HP" if SiteID==	1931110017
replace SiteName = "Haye HP" if SiteID==	1931110018
replace SiteName = "Sauna Kawaji HP" if SiteID==	1931110019
replace SiteName = "Kaura Goje PHC" if SiteID==	1931110020
replace SiteName = "Gaskiya Textile Staff Clin" if SiteID==	1931120021
replace SiteName = "Luna Continental Staff Clin" if SiteID==	1931120022
replace SiteName = "Nig Spinners Dyer Clin" if SiteID==	1931120023
replace SiteName = "Bamaiyi Sai Allah Clin" if SiteID==	1931120024
replace SiteName = "Ikon Allah Maternity" if SiteID==	1931120025
replace SiteName = "Sani Bello Hosp" if SiteID==	1931120026
replace SiteName = "Tafa Clin" if SiteID==	1931120027
replace SiteName = "Ahmadiyya Hosp" if SiteID==	1931120028
replace SiteName = "Ahmadiyya Dental Clin" if SiteID==	1931120029
replace SiteName = "Accord Surg Hosp" if SiteID==	1931120030
replace SiteName = "Classic Clin" if SiteID==	1931120031
replace SiteName = "Empire Clin" if SiteID==	1931120032
replace SiteName = "Melicus Clin" if SiteID==	1931120033
replace SiteName = "Park House Clin" if SiteID==	1931120034
replace SiteName = "Gamji Hosp" if SiteID==	1931120035
replace SiteName = "Hallmark Clin" if SiteID==	1931120036
replace SiteName = "Arewa Surgery Hosp" if SiteID==	1931120037
replace SiteName = "Central Bank Staff" if SiteID==	1931120038
replace SiteName = "Abdulwahab Hosp" if SiteID==	1931120039
replace SiteName = "Cedar Poly Clin" if SiteID==	1931120040
replace SiteName = "Copper Stone Hosp" if SiteID==	1931120041
replace SiteName = "Doctors Clin " if SiteID==	1931120042
replace SiteName = "Kafal Optical Center" if SiteID==	1931120043
replace SiteName = "Warshu Hosp" if SiteID==	1931120044
replace SiteName = "Accord Surgery Hosp" if SiteID==	1931120045
replace SiteName = "Ahmadiya Hosp" if SiteID==	1931120046
replace SiteName = "Al-Amin Medical Cent " if SiteID==	1931120047
replace SiteName = "Alfa Clin " if SiteID==	1931120048
replace SiteName = "Alheri Medical Group" if SiteID==	1931120049
replace SiteName = "Al-Shifa Clin" if SiteID==	1931120050
replace SiteName = "Anda Clin " if SiteID==	1931120051
replace SiteName = "Annuri Hosp" if SiteID==	1931120052
replace SiteName = "Ave Cinna Hosp" if SiteID==	1931120053
replace SiteName = "Balla Clin" if SiteID==	1931120054
replace SiteName = "Castle Clin & Mat " if SiteID==	1931120055
replace SiteName = "Catherine Hosp" if SiteID==	1931120056
replace SiteName = "Continental Clin " if SiteID==	1931120057
replace SiteName = "Custom Staff Clin" if SiteID==	1931120058
replace SiteName = "Ebony Clin" if SiteID==	1931120059
replace SiteName = "El-Shadai Hosp" if SiteID==	1931120060
replace SiteName = "Good Pasture Clin" if SiteID==	1931120061
replace SiteName = "Ideal Hosp" if SiteID==	1931120062
replace SiteName = "Imperial Hosp" if SiteID==	1931120063
replace SiteName = "Jemodeen Clin" if SiteID==	1931120064
replace SiteName = "Joy Clin" if SiteID==	1931120065
replace SiteName = "Maimuna A/Raya Hosp" if SiteID==	1931120066
replace SiteName = "New Nigerian Clin " if SiteID==	1931120067
replace SiteName = "Nigerian Airforce Hosp" if SiteID==	1931120068
replace SiteName = "Oddumma Estate Hosp" if SiteID==	1931120069
replace SiteName = "Royal Clin " if SiteID==	1931120070
replace SiteName = "Sauki Clin " if SiteID==	1931120071
replace SiteName = "Somiya Clin" if SiteID==	1931120072
replace SiteName = "Unity Hosp" if SiteID==	1931120073
replace SiteName = "Victory Clin" if SiteID==	1931120074
replace SiteName = "Yamid Clin" if SiteID==	1931120075
replace SiteName = "ECWA Eye Hosp" if SiteID==	1931120076
replace SiteName = "Kano Medical Center" if SiteID==	1931120077
replace SiteName = "Terry Text Nig Ltd Staff Clin" if SiteID==	1931120078
replace SiteName = "WJ Bush Staff Clin" if SiteID==	1931120079
replace SiteName = "Rano Gen Hosp" if SiteID==	1932210001
replace SiteName = "Rano Dawaki HP" if SiteID==	1932110002
replace SiteName = "Madachi HP" if SiteID==	1932110003
replace SiteName = "Munture HC" if SiteID==	1932110004
replace SiteName = "Rurum HC" if SiteID==	1932110005
replace SiteName = "Saji Disp" if SiteID==	1932110006
replace SiteName = "Yama Disp " if SiteID==	1932110007
replace SiteName = "Bul HP" if SiteID==	1932110008
replace SiteName = "Yalwa Health Post" if SiteID==	1932110009
replace SiteName = "Kazaurawa HP" if SiteID==	1932110010
replace SiteName = "Tabobi HP" if SiteID==	1932110011
replace SiteName = "Lausu HP" if SiteID==	1932110012
replace SiteName = "Taitai HC" if SiteID==	1932110013
replace SiteName = "Sabuwar Kaura HP" if SiteID==	1932110014
replace SiteName = "School Clin" if SiteID==	1932110015
replace SiteName = "Rogo Cottage Hosp" if SiteID==	1933210001
replace SiteName = "Rogo Disp" if SiteID==	1933110002
replace SiteName = "Rogo Tsohuwa Disp" if SiteID==	1933110003
replace SiteName = "Beli BHC" if SiteID==	1933110004
replace SiteName = "Falgore Model PHC" if SiteID==	1933110005
replace SiteName = "Fulatan BHC" if SiteID==	1933110006
replace SiteName = "Bari PHC" if SiteID==	1933110007
replace SiteName = "Gwangwan BHC" if SiteID==	1933110008
replace SiteName = "Unguwar Mallam Disp" if SiteID==	1933110009
replace SiteName = "Ung Liman HP " if SiteID==	1933110010
replace SiteName = "Barbarji HP" if SiteID==	1933110011
replace SiteName = "Jajaye BHC" if SiteID==	1933110012
replace SiteName = "Kaleko BHC" if SiteID==	1933110013
replace SiteName = "Sagwandary HP" if SiteID==	1933110014
replace SiteName = "Yanoko Disp" if SiteID==	1933110015
replace SiteName = "Dayaso BHC" if SiteID==	1933110016
replace SiteName = "Karshi HP" if SiteID==	1933110017
replace SiteName = "Sundu Disp" if SiteID==	1933110018
replace SiteName = "Zarewa BHC" if SiteID==	1933110019
replace SiteName = "Tsara HP" if SiteID==	1933110020
replace SiteName = "R/Bago HP" if SiteID==	1933110021
replace SiteName = "Hago HP" if SiteID==	1933110022
replace SiteName = "Rimin Gado BHC" if SiteID==	1934110001
replace SiteName = "Butu Butu HP" if SiteID==	1934110002
replace SiteName = "Indabo HP" if SiteID==	1934110003
replace SiteName = "D/Gulu HP" if SiteID==	1934110004
replace SiteName = "Doka-Dawa Disp" if SiteID==	1934110005
replace SiteName = "Kazardawa HP" if SiteID==	1934110006
replace SiteName = "Dogurawa Disp" if SiteID==	1934110007
replace SiteName = "Gulu Disp" if SiteID==	1934110008
replace SiteName = "Jili HP" if SiteID==	1934110009
replace SiteName = "Juji HP" if SiteID==	1934110010
replace SiteName = "Danshayi HP" if SiteID==	1934110011
replace SiteName = "Krofin Yashi Disp" if SiteID==	1934110012
replace SiteName = "Sakaratsa Disp" if SiteID==	1934110013
replace SiteName = "Maigari  " if SiteID==	1934110014
replace SiteName = " Ingila HP" if SiteID==	1934110015
replace SiteName = "Tamawa Disp" if SiteID==	1934110016
replace SiteName = "Yalwa BHC" if SiteID==	1934110017
replace SiteName = "Yango HP" if SiteID==	1934110018
replace SiteName = "Zango 1 HP" if SiteID==	1934110019
replace SiteName = "Zango 2 HP" if SiteID==	1934110020
replace SiteName = "Maigari HP" if SiteID==	1934110021
replace SiteName = "Dan Isa HP" if SiteID==	1934110022
replace SiteName = "Shanono CHC" if SiteID==	1935110001
replace SiteName = "Alajawa Disp" if SiteID==	1935110002
replace SiteName = "Koya Disp" if SiteID==	1935110003
replace SiteName = "D/Bakoshi Disp" if SiteID==	1935110004
replace SiteName = "Dorogo HP" if SiteID==	1935110005
replace SiteName = "Faruruwa PHC" if SiteID==	1935110006
replace SiteName = "Yan Kwada HP" if SiteID==	1935110007
replace SiteName = "Bakaji HP" if SiteID==	1935110008
replace SiteName = "Goron Dutse HP " if SiteID==	1935110009
replace SiteName = "Kuraku HP" if SiteID==	1935110010
replace SiteName = "Kadamu MPHC" if SiteID==	1935110011
replace SiteName = "Kundila HP" if SiteID==	1935110012
replace SiteName = "Gudan Tuwo HP" if SiteID==	1935110013
replace SiteName = "Kokiya Disp" if SiteID==	1935110014
replace SiteName = "Bakwami HP" if SiteID==	1935110015
replace SiteName = "Leni HC" if SiteID==	1935110016
replace SiteName = "Godarawa HP" if SiteID==	1935110017
replace SiteName = "Shakogi HP" if SiteID==	1935110018
replace SiteName = "Janbirji HP" if SiteID==	1935110019
replace SiteName = "Tsaure HC" if SiteID==	1935110020
replace SiteName = "Yan Shadu HP" if SiteID==	1935110021
replace SiteName = "Sumaila Gen. Hosp" if SiteID==	1936210001
replace SiteName = "Karofi Sumaila Disp" if SiteID==	1936110002
replace SiteName = "Bingi HP" if SiteID==	1936110003
replace SiteName = "Gala Disp" if SiteID==	1936110004
replace SiteName = "Baji HP" if SiteID==	1936110005
replace SiteName = "Bagagare HP" if SiteID==	1936110006
replace SiteName = "Dagora Disp" if SiteID==	1936110007
replace SiteName = "Dambazau yamma Disp" if SiteID==	1936110008
replace SiteName = "Gani PHC" if SiteID==	1936110009
replace SiteName = "Alfindi HP" if SiteID==	1936110010
replace SiteName = "Garfa Disp " if SiteID==	1936110011
replace SiteName = "Dando Disp" if SiteID==	1936110012
replace SiteName = "Gediya BHC" if SiteID==	1936110013
replace SiteName = "B/Lahadi HP" if SiteID==	1936110014
replace SiteName = "Kula Disp" if SiteID==	1936110015
replace SiteName = "Bango Disp" if SiteID==	1936110016
replace SiteName = "Dingamu Disp" if SiteID==	1936110017
replace SiteName = "Kanawa Disp" if SiteID==	1936110018
replace SiteName = "Yan Bawa HP" if SiteID==	1936110019
replace SiteName = "Kwajale HP" if SiteID==	1936110020
replace SiteName = "Magami BHC" if SiteID==	1936110021
replace SiteName = "Sansani Disp" if SiteID==	1936110022
replace SiteName = "Beta HP" if SiteID==	1936110023
replace SiteName = "Gomo BHC" if SiteID==	1936110024
replace SiteName = "Mamiso HP" if SiteID==	1936110025
replace SiteName = "Massu BHC" if SiteID==	1936110026
replace SiteName = "Dakumbal Disp" if SiteID==	1936110027
replace SiteName = "Farin Dutse HP" if SiteID==	1936110028
replace SiteName = "Gisai HP" if SiteID==	1936110029
replace SiteName = "Rimi BHC" if SiteID==	1936110030
replace SiteName = "Yakuduna HP" if SiteID==	1936110031
replace SiteName = "Rumo Disp" if SiteID==	1936110032
replace SiteName = "Rayen Masaka HP" if SiteID==	1936110033
replace SiteName = "Sitti BHC" if SiteID==	1936110034
replace SiteName = "Yu HP" if SiteID==	1936110035
replace SiteName = "Kargo HP" if SiteID==	1936110036
replace SiteName = "Kawo HP" if SiteID==	1936110037
replace SiteName = "Gajiki HP" if SiteID==	1936110038
replace SiteName = "Gwanda HP" if SiteID==	1936110039
replace SiteName = "Tukuda HP" if SiteID==	1936110040
replace SiteName = "Matugwai Disp" if SiteID==	1936110041
replace SiteName = "Hayin Gada HP" if SiteID==	1936110042
replace SiteName = "Patricia MCH" if SiteID==	1936110043
replace SiteName = "Magana Clin" if SiteID==	1936120044
replace SiteName = "Takai NYSC PHC" if SiteID==	1937110001
replace SiteName = "Bagwaro Dispensary" if SiteID==	1937110002
replace SiteName = "Kayadda HP" if SiteID==	1937110003
replace SiteName = "Birnin Bako Disp" if SiteID==	1937110004
replace SiteName = "Kafinlafiya HP" if SiteID==	1937110005
replace SiteName = "Sakwaya HP" if SiteID==	1937110006
replace SiteName = "Durbunde PHC" if SiteID==	1937110007
replace SiteName = "Fajewa Disp" if SiteID==	1937110008
replace SiteName = "Hantsai HP" if SiteID==	1937110009
replace SiteName = "Salmande HP" if SiteID==	1937110010
replace SiteName = "Falali Disp" if SiteID==	1937110011
replace SiteName = "Kyansha HP" if SiteID==	1937110012
replace SiteName = "Dambazau HP " if SiteID==	1937110013
replace SiteName = "Farunruwa Disp" if SiteID==	1937110014
replace SiteName = "Jigawa HP " if SiteID==	1937110015
replace SiteName = "Yada HP" if SiteID==	1937110016
replace SiteName = "Awazara HP" if SiteID==	1937110017
replace SiteName = "Huguma Disp" if SiteID==	1937110018
replace SiteName = "Kwanar " if SiteID==	1937110019
replace SiteName = "Huguma HP" if SiteID==	1937110020
replace SiteName = "Langwami HP" if SiteID==	1937110021
replace SiteName = "Kachako PHC " if SiteID==	1937110022
replace SiteName = "Diribo Disp" if SiteID==	1937110023
replace SiteName = "Karfi HP" if SiteID==	1937110024
replace SiteName = "Shawu Disp" if SiteID==	1937110025
replace SiteName = "Gamawa HP" if SiteID==	1937110026
replace SiteName = "Kafinsidda HP" if SiteID==	1937110027
replace SiteName = "Kuka HP" if SiteID==	1937110028
replace SiteName = "Garandiya HP" if SiteID==	1937110029
replace SiteName = "Kan Iyaka HP" if SiteID==	1937110030
replace SiteName = "Kogo HP " if SiteID==	1937110031
replace SiteName = "Zuga Disp" if SiteID==	1937110032
replace SiteName = "Kurido HP" if SiteID==	1937110033
replace SiteName = "Bango HP" if SiteID==	1937110034
replace SiteName = "Kano Dental Hosp" if SiteID==	1938210001
replace SiteName = "AKT Hosp" if SiteID==	1938310002
replace SiteName = "Hausawa  HC" if SiteID==	1938110003
replace SiteName = "New H. B. Paediatric Hosp" if SiteID==	1938210004
replace SiteName = "B/Giji HP" if SiteID==	1938110005
replace SiteName = "Kundila PHC" if SiteID==	1938110006
replace SiteName = "Ja'oji PHC" if SiteID==	1938110007
replace SiteName = "Gyadi-Gyadi Kudu HP" if SiteID==	1938110008
replace SiteName = "Hotoro HP" if SiteID==	1938110009
replace SiteName = "Kawyen Alu HC" if SiteID==	1938110010
replace SiteName = "Tarauni PHC" if SiteID==	1938110011
replace SiteName = "Govt House Clin" if SiteID==	1938110012
replace SiteName = "Unguwa Uku PHC" if SiteID==	1938110013
replace SiteName = "Yar Akwa HP" if SiteID==	1938110014
replace SiteName = "Nasara Clin" if SiteID==	1938120015
replace SiteName = "Premier Clin" if SiteID==	1938120016
replace SiteName = "Chatti Dental Clin" if SiteID==	1938120017
replace SiteName = "Almu Memo Hosp" if SiteID==	1938120018
replace SiteName = "Tofa CHC" if SiteID==	1939110001
replace SiteName = "Dindire Dispensary" if SiteID==	1939110002
replace SiteName = "Doka Disp" if SiteID==	1939110003
replace SiteName = "Gajida Dispensary" if SiteID==	1939110004
replace SiteName = "Ginsawa HP" if SiteID==	1939110005
replace SiteName = "Janguza Disp" if SiteID==	1939110006
replace SiteName = "Joben Kudu Disp" if SiteID==	1939110007
replace SiteName = "Kwami HP" if SiteID==	1939110008
replace SiteName = "Dansudu Disp" if SiteID==	1939110009
replace SiteName = "Lambu MPHC" if SiteID==	1939110010
replace SiteName = "Langel HP" if SiteID==	1939110011
replace SiteName = "U/Rimi Disp" if SiteID==	1939110012
replace SiteName = "Wangara HP" if SiteID==	1939110013
replace SiteName = "Yalwa Karama HP" if SiteID==	1939110014
replace SiteName = "Yanoko HP" if SiteID==	1939110015
replace SiteName = "Yarimawa Health Post" if SiteID==	1939110016
replace SiteName = "Lambu BHC" if SiteID==	1939110017
replace SiteName = "Jagaja Disp" if SiteID==	1939110018
replace SiteName = "Tofa Missionary Clin" if SiteID==	1939120019
replace SiteName = "Jigilawa HP" if SiteID==	1940110001
replace SiteName = "Tsanyawa CHC" if SiteID==	1940110002
replace SiteName = "Daddarawa BHC" if SiteID==	1940110003
replace SiteName = "U/Barke HP" if SiteID==	1940110004
replace SiteName = "Yan mamman HP" if SiteID==	1940110005
replace SiteName = "Dumbulum BHC" if SiteID==	1940110006
replace SiteName = "Kokai HP" if SiteID==	1940110007
replace SiteName = "Tafashiya BHC" if SiteID==	1940110008
replace SiteName = "Gurun MPHC" if SiteID==	1940110009
replace SiteName = "Yan Awaki HP (TYW)" if SiteID==	1940110010
replace SiteName = "Nassarawa HP" if SiteID==	1940110011
replace SiteName = "Harbau BHC" if SiteID==	1940110012
replace SiteName = "Kabagiwa HP" if SiteID==	1940110013
replace SiteName = "Dorayi HP" if SiteID==	1940110014
replace SiteName = "Farsa HP" if SiteID==	1940110015
replace SiteName = "Tatsan HP" if SiteID==	1940110016
replace SiteName = "Yan'Amar HP" if SiteID==	1940110017
replace SiteName = "Gezawa (TYW)  HP" if SiteID==	1940110018
replace SiteName = "Yan Chibi HP" if SiteID==	1940110019
replace SiteName = "Yan Ganau HP" if SiteID==	1940110020
replace SiteName = "Yan Kamaye  TG HP" if SiteID==	1940110021
replace SiteName = "Zakawa HP" if SiteID==	1940110022
replace SiteName = "Yar Gwanda BHC" if SiteID==	1940110023
replace SiteName = "Yakanawa HP" if SiteID==	1940110024
replace SiteName = "Zarogi HP" if SiteID==	1940110025
replace SiteName = "Yankamaya SG BHC" if SiteID==	1940110026
replace SiteName = "Rafin Tsamiya HP" if SiteID==	1940110027
replace SiteName = "Tudun Wada Cottage" if SiteID==	1941210001
replace SiteName = "Jan Maje HP" if SiteID==	1941110002
replace SiteName = "T Wada PHC" if SiteID==	1941110003
replace SiteName = "Baburi HC" if SiteID==	1941110004
replace SiteName = "Dariya HC" if SiteID==	1941110005
replace SiteName = "Rufan Disp" if SiteID==	1941110006
replace SiteName = "Tukuda HC" if SiteID==	1941110007
replace SiteName = "Burum Burum HC" if SiteID==	1941110008
replace SiteName = "Gazobi HP" if SiteID==	1941110009
replace SiteName = "GGSS T/Wada" if SiteID==	1941110010
replace SiteName = "F/Ma'aji Disp" if SiteID==	1941110011
replace SiteName = "Jan Dutse HP" if SiteID==	1941110012
replace SiteName = "GS C T/Wada" if SiteID==	1941110013
replace SiteName = "Farin Ruwa Disp" if SiteID==	1941110014
replace SiteName = "Kurkujawa HP" if SiteID==	1941110015
replace SiteName = "Yar Fulani HP" if SiteID==	1941110016
replace SiteName = "Karafe HP" if SiteID==	1941110017
replace SiteName = "Na Ta'Ala BHC" if SiteID==	1941110018
replace SiteName = "Rugu Rugu HC" if SiteID==	1941110019
replace SiteName = "Yalwa Disp" if SiteID==	1941110020
replace SiteName = "F/Wambai HP" if SiteID==	1941110021
replace SiteName = "Jeli Disp" if SiteID==	1941110022
replace SiteName = "Sumana HP" if SiteID==	1941110023
replace SiteName = "Yar Maraya HC" if SiteID==	1941110024
replace SiteName = "Jita HP" if SiteID==	1941110025
replace SiteName = "Shawaki HP" if SiteID==	1941110026
replace SiteName = "Yaryasa HP" if SiteID==	1941110027
replace SiteName = "Dalawa HP" if SiteID==	1941110028
replace SiteName = "Ruwan Tabo HC" if SiteID==	1941110029
replace SiteName = "Wuna HC" if SiteID==	1941110030
replace SiteName = "Yadakunya Leprosy Hosp" if SiteID==	1942210001
replace SiteName = "Bachirawa Disp" if SiteID==	1942110002
replace SiteName = "Dausayi HP" if SiteID==	1942110003
replace SiteName = "Gadan HP" if SiteID==	1942110004
replace SiteName = "Rijiyar Zaki HC" if SiteID==	1942110005
replace SiteName = "Ungogo BHC" if SiteID==	1942110006
replace SiteName = "Fanisau HC" if SiteID==	1942110007
replace SiteName = "Gera HP" if SiteID==	1942110008
replace SiteName = "Dan Rimi Disp" if SiteID==	1942110009
replace SiteName = "Kadawa HC" if SiteID==	1942110010
replace SiteName = "Z/Barebari HP" if SiteID==	1942110011
replace SiteName = "Bagujan HP" if SiteID==	1942110012
replace SiteName = "Jajira HP" if SiteID==	1942110013
replace SiteName = "T/fulani HC" if SiteID==	1942110014
replace SiteName = "Doka HP" if SiteID==	1942110015
replace SiteName = "Sabon Garin Doka HP" if SiteID==	1942110016
replace SiteName = "Inusawa Disp" if SiteID==	1942110017
replace SiteName = "Rimin Kebe HC" if SiteID==	1942110018
replace SiteName = "Gayawa HC" if SiteID==	1942110019
replace SiteName = "Dausara HP" if SiteID==	1942110020
replace SiteName = "Katsinawa HP" if SiteID==	1942110021
replace SiteName = "Dalal HC" if SiteID==	1942110022
replace SiteName = "Yola HP" if SiteID==	1942110023
replace SiteName = "S/Rangaza HP" if SiteID==	1942110024
replace SiteName = "Dan Kunkuru HP" if SiteID==	1942110025
replace SiteName = "Tarda Disp" if SiteID==	1942110026
replace SiteName = "Waziri Shehu Gidado Gh" if SiteID==	1942210027
replace SiteName = "Warawa BHC" if SiteID==	1943110001
replace SiteName = "Danfari Disp" if SiteID==	1943110002
replace SiteName = "Danlasan BHC" if SiteID==	1943110003
replace SiteName = "Police Academy " if SiteID==	1943110004
replace SiteName = "Wamranto HP" if SiteID==	1943110005
replace SiteName = "Gogel BHC" if SiteID==	1943110006
replace SiteName = "Imawa Disp" if SiteID==	1943110007
replace SiteName = "Juma-Galadima Disp" if SiteID==	1943110008
replace SiteName = "Yar Tofa HP " if SiteID==	1943110009
replace SiteName = "Jemagu BHC" if SiteID==	1943110010
replace SiteName = "Jigawa Disp " if SiteID==	1943110011
replace SiteName = "Katarkawa Disp" if SiteID==	1943110012
replace SiteName = "Ganakakun Disp" if SiteID==	1943110013
replace SiteName = "T/Yandaudu HC" if SiteID==	1943110014
replace SiteName = "Tanagar Disp" if SiteID==	1943110015
replace SiteName = "Amarawa HP" if SiteID==	1943110016
replace SiteName = "Yan Dalla Disp" if SiteID==	1943110017
replace SiteName = "Alitini Disp" if SiteID==	1943110018
replace SiteName = "T/Gabas PHC" if SiteID==	1943110019
replace SiteName = "T/Yandadi Disp" if SiteID==	1943110020
replace SiteName = "Wudil GH" if SiteID==	1944210001
replace SiteName = "Wudil HP" if SiteID==	1944110002
replace SiteName = "Achika HC" if SiteID==	1944110003
replace SiteName = "Dagumana HC" if SiteID==	1944110004
replace SiteName = "Juma HC" if SiteID==	1944110005
replace SiteName = "Darki MPHC" if SiteID==	1944110006
replace SiteName = "Jigaware Hc" if SiteID==	1944110007
replace SiteName = "Indabo PHC" if SiteID==	1944110008
replace SiteName = "Gachi Kedi HP" if SiteID==	1944110009
replace SiteName = "Kausani HC" if SiteID==	1944110010
replace SiteName = "Tsibiri HP" if SiteID==	1944110011
replace SiteName = "Lajawa PHC" if SiteID==	1944110012
replace SiteName = "Makera HP" if SiteID==	1944110013
replace SiteName = "Utai HC" if SiteID==	1944110014
replace SiteName = "Tudun Gunsau HC" if SiteID==	1944110015
replace SiteName = "Makanwaci HC" if SiteID==	1944110016
replace SiteName = "Yan Lahadi HP" if SiteID==	1944110017
replace SiteName = "Katai  Faudan HC" if SiteID==	1944110018
replace SiteName = "Fadi Sonka HP" if SiteID==	1944110019
replace SiteName = "Al-Hilal Mat Hosp" if SiteID==	1944120020
replace SiteName = "Amana Hospital" if SiteID==	1944120021
replace SiteName = "Sauki Clin " if SiteID==	1944120022
replace SiteName = "G/Alhazai Mat Hosp" if SiteID==	1944120023




* KATSINA
replace SiteName = "MARARABAR DANJA HC" if SiteID==	2001110001
replace SiteName = "BAKORI HC" if SiteID==	2001110002
replace SiteName = "AFUWA HC" if SiteID==	2001110003
replace SiteName = "COM. HEALTH CENT" if SiteID==	2001110004
replace SiteName = "FSC HC" if SiteID==	2001110005
replace SiteName = "ADAKO HC " if SiteID==	2001110006
replace SiteName = "YAN LAMBU HC" if SiteID==	2001110007
replace SiteName = "BARDE HC" if SiteID==	2001110008
replace SiteName = "GIDAN BAKORI HC" if SiteID==	2001110009
replace SiteName = "KWANTAKWARI HC" if SiteID==	2001110010
replace SiteName = "KAWO HC" if SiteID==	2001110011
replace SiteName = "T/WADA HC" if SiteID==	2001110012
replace SiteName = "ZANGON MARKE HC" if SiteID==	2001110013
replace SiteName = "JALLATU HC" if SiteID==	2001110014
replace SiteName = "GIDAN MAIKATI HC" if SiteID==	2001120015
replace SiteName = "KIRINKI HC" if SiteID==	2001120016
replace SiteName = "TAMALIKE HC" if SiteID==	2001110017
replace SiteName = "KANADA HC" if SiteID==	2001110018
replace SiteName = "U.ALHERI HC" if SiteID==	2001110019
replace SiteName = "YARI BASO HC" if SiteID==	2001110020
replace SiteName = "K/BAUSHI HC" if SiteID==	2001110021
replace SiteName = "U/GABAS HC" if SiteID==	2001110022
replace SiteName = "K/DANBATTA HC" if SiteID==	2001110023
replace SiteName = "GUGA PHC" if SiteID==	2001110024
replace SiteName = "MAGOJE HC" if SiteID==	2001110025
replace SiteName = "YAN NEBU HC" if SiteID==	2001110026
replace SiteName = "LAMIDO HC" if SiteID==	2001110027
replace SiteName = "YAR TSAILURA HC" if SiteID==	2001110028
replace SiteName = "YAN SHUNI HC" if SiteID==	2001110029
replace SiteName = "JAR GABA PHC" if SiteID==	2001110030
replace SiteName = "SHUWAILI HC" if SiteID==	2001110031
replace SiteName = "UNG. DOGO HC" if SiteID==	2001110032
replace SiteName = "DANGANA HC" if SiteID==	2001110033
replace SiteName = "KABOMO HC" if SiteID==	2001110034
replace SiteName = "K/DOKA HC" if SiteID==	2001110035
replace SiteName = "H/LIMAN HC" if SiteID==	2001110036
replace SiteName = "GANJAR HC" if SiteID==	2001110037
replace SiteName = "H/ROSHE HC" if SiteID==	2001110038
replace SiteName = "LAYIN KURA HC" if SiteID==	2001110039
replace SiteName = "KAKUMI PHC" if SiteID==	2001110040
replace SiteName = "DOTSA HC" if SiteID==	2001110041
replace SiteName = "GARAN GOZAI HC" if SiteID==	2001110042
replace SiteName = "TINJIMMASA HC" if SiteID==	2001110043
replace SiteName = "DAN DAUDU HC" if SiteID==	2001110044
replace SiteName = "DAUDU HC" if SiteID==	2001110045
replace SiteName = "GANJAR HC" if SiteID==	2001110046
replace SiteName = "D/GUZA HC" if SiteID==	2001110047
replace SiteName = "MACIKAYA HC" if SiteID==	2001110048
replace SiteName = "KANDARAWA HC" if SiteID==	2001110049
replace SiteName = "R/KURI HC" if SiteID==	2001110050
replace SiteName = "MAIYADIYA HC" if SiteID==	2001110051
replace SiteName = "ALUBURA HC" if SiteID==	2001110052
replace SiteName = "SHANTALI H/POST" if SiteID==	2001110053
replace SiteName = "UNG. BANA H/POST" if SiteID==	2001110054
replace SiteName = "GIDAN KAWU H/POST" if SiteID==	2001110055
replace SiteName = "U/ARDO H/POST" if SiteID==	2001110056
replace SiteName = "DAN BAUSHE H/POST" if SiteID==	2001110057
replace SiteName = "KURAMI HC" if SiteID==	2001110058
replace SiteName = "NABUKKA HC" if SiteID==	2001110059
replace SiteName = "YAN KWANI HC" if SiteID==	2001110060
replace SiteName = "R/KANYA HC" if SiteID==	2001110061
replace SiteName = "S/BAILA HC" if SiteID==	2001110062
replace SiteName = "D/REME HC" if SiteID==	2001110063
replace SiteName = "L/RAMA HC" if SiteID==	2001110064
replace SiteName = "B/GADA HC" if SiteID==	2001110065
replace SiteName = "MAKERA HC" if SiteID==	2001110066
replace SiteName = "FUNTUA Clin" if SiteID==	2001120067
replace SiteName = "LAFIYA Clin" if SiteID==	2001120068
replace SiteName = "TSIGA HC" if SiteID==	2001110069
replace SiteName = "MAKURDI HC" if SiteID==	2001110070
replace SiteName = "B/KUFAI HC" if SiteID==	2001110071
replace SiteName = "Y/RUMFA HC" if SiteID==	2001110072
replace SiteName = "G/BAUSHE HC" if SiteID==	2001110073
replace SiteName = "AJIWA" if SiteID==	2002210001
replace SiteName = "M. AUSHI" if SiteID==	2002110002
replace SiteName = "SHAGUNBA" if SiteID==	2002110003
replace SiteName = "SHANTALI" if SiteID==	2002110004
replace SiteName = "BARHIM" if SiteID==	2002110005
replace SiteName = "KURTUBA" if SiteID==	2002110006
replace SiteName = "KITABI" if SiteID==	2002110007
replace SiteName = "BAKIYAWA" if SiteID==	2002110008
replace SiteName = "YANGEMU" if SiteID==	2002110009
replace SiteName = "S/GARI" if SiteID==	2002110010
replace SiteName = "DOLE" if SiteID==	2002110011
replace SiteName = "BARAWA" if SiteID==	2002110012
replace SiteName = "YAR GIGO" if SiteID==	2002110013
replace SiteName = "M. MUSA" if SiteID==	2002110014
replace SiteName = "GYARKE" if SiteID==	2002110015
replace SiteName = "SALIHAWA" if SiteID==	2002110016
replace SiteName = "SHEKAR GABI" if SiteID==	2002110017
replace SiteName = "BATAGARAWA" if SiteID==	2002110018
replace SiteName = "BABBAR GAWO" if SiteID==	2002110019
replace SiteName = "BAZANZAMAWA" if SiteID==	2002110020
replace SiteName = "BASAU" if SiteID==	2002110021
replace SiteName = "KAWO" if SiteID==	2002110022
replace SiteName = "FSC" if SiteID==	2002110023
replace SiteName = "DORAR" if SiteID==	2002110024
replace SiteName = "DABAIBAYAWA" if SiteID==	2002110025
replace SiteName = "MAKADA" if SiteID==	2002110026
replace SiteName = "BADO" if SiteID==	2002110027
replace SiteName = "JILAWA" if SiteID==	2002110028
replace SiteName = "KAMFATAU" if SiteID==	2002110029
replace SiteName = "GODAMMATAWA" if SiteID==	2002110030
replace SiteName = "D/DAGORO" if SiteID==	2002110031
replace SiteName = "TIGIRMIS" if SiteID==	2002110032
replace SiteName = "S/GIDA" if SiteID==	2002110033
replace SiteName = "KAUKAI" if SiteID==	2002110034
replace SiteName = "TSUNTSUWA" if SiteID==	2002110035
replace SiteName = "RIGAR DILA" if SiteID==	2002110036
replace SiteName = "YAN NERA" if SiteID==	2002110037
replace SiteName = "JINO" if SiteID==	2002110038
replace SiteName = "GEN HOSPB/RUGA" if SiteID==	2002210039
replace SiteName = "INWALA" if SiteID==	2002110040
replace SiteName = "BANBAMI" if SiteID==	2002110041
replace SiteName = "YAR SHANYA" if SiteID==	2002110042
replace SiteName = "KAYAUKI" if SiteID==	2002110043
replace SiteName = "D/IYAU" if SiteID==	2002110044
replace SiteName = "KURHUNDU" if SiteID==	2002110045
replace SiteName = "BADAR MURTALA" if SiteID==	2002110046
replace SiteName = "TSANNI" if SiteID==	2002110047
replace SiteName = "MAILLALE" if SiteID==	2002110048
replace SiteName = "YARBARZA" if SiteID==	2002110049
replace SiteName = "RAHAJE" if SiteID==	2002110050
replace SiteName = "YAR KIRAKWAI" if SiteID==	2002110051
replace SiteName = "YARGAMJI" if SiteID==	2002110052
replace SiteName = "JAMO" if SiteID==	2002110053
replace SiteName = "T/ALMU" if SiteID==	2002110054
replace SiteName = "YAN BUTU" if SiteID==	2002110055
replace SiteName = "ALAU JAMA'A" if SiteID==	2002110056
replace SiteName = "TADETA HC" if SiteID==	2003110001
replace SiteName = "ABADAU HC" if SiteID==	2003110002
replace SiteName = "AKATA HC" if SiteID==	2003110003
replace SiteName = "BARAN KADA HC" if SiteID==	2003110004
replace SiteName = "DADIN KOWA HC" if SiteID==	2003110005
replace SiteName = "SAWANAWA HC" if SiteID==	2003110006
replace SiteName = "SHIRGI HC" if SiteID==	2003110007
replace SiteName = "TSABAWA HC" if SiteID==	2003110008
replace SiteName = "ZAMFARAWA HC" if SiteID==	2003110009
replace SiteName = "ZANKO HC" if SiteID==	2003110010
replace SiteName = "FSP BATSARI" if SiteID==	2003110011
replace SiteName = "GEN.HOSP. BTR" if SiteID==	2003210012
replace SiteName = "SALIHAWA DAKAMNA HC" if SiteID==	2003110013
replace SiteName = "WATAN GADIYA HC" if SiteID==	2003110014
replace SiteName = "YASORE HC" if SiteID==	2003110015
replace SiteName = "UNG. MALAMAI HC" if SiteID==	2003110016
replace SiteName = "KATOGE HC" if SiteID==	2003110017
replace SiteName = "BIYA KI KWANA HC" if SiteID==	2003110018
replace SiteName = "GARIN LULAI HC" if SiteID==	2003110019
replace SiteName = "GARIN GOJE" if SiteID==	2003110020
replace SiteName = "GEHE" if SiteID==	2003110021
replace SiteName = "KUKAR TORO" if SiteID==	2003110022
replace SiteName = "KURMIYAL" if SiteID==	2003110023
replace SiteName = "MAIDORIYA" if SiteID==	2003110024
replace SiteName = "MAKADA DUMA" if SiteID==	2003110025
replace SiteName = "SAKI JIKI" if SiteID==	2003110026
replace SiteName = "SALIHAWAN ALHAJI" if SiteID==	2003110027
replace SiteName = "YANDAKA MCH" if SiteID==	2003110028
replace SiteName = "YANGAYYA" if SiteID==	2003110029
replace SiteName = "KANDAWA" if SiteID==	2003110030
replace SiteName = "DANKAR MCH" if SiteID==	2003110031
replace SiteName = "TSAUWA HC" if SiteID==	2003110032
replace SiteName = "KARARE" if SiteID==	2003110033
replace SiteName = "GAZARI HC" if SiteID==	2003110034
replace SiteName = "KOKIYA HC" if SiteID==	2003110035
replace SiteName = "KWATARNI HC" if SiteID==	2003110036
replace SiteName = "MADADABAI HC" if SiteID==	2003110037
replace SiteName = "MADOGARA HC" if SiteID==	2003110038
replace SiteName = "GARIN BUGAJE HC" if SiteID==	2003110039
replace SiteName = "GARIN ZAKI HC" if SiteID==	2003110040
replace SiteName = "NAHUTA HC" if SiteID==	2003110041
replace SiteName = "DUBA  HC" if SiteID==	2003110042
replace SiteName = "GARIN RINJI HC" if SiteID==	2003110043
replace SiteName = "TSUGUNNI HC" if SiteID==	2003110044
replace SiteName = "BATSARIN ALHAJI HC" if SiteID==	2003110045
replace SiteName = "DANGEZA HC" if SiteID==	2003110046
replace SiteName = "KOFA HC" if SiteID==	2003110047
replace SiteName = "MALLAMAWA HC" if SiteID==	2003110048
replace SiteName = "GARWA HC" if SiteID==	2003110049
replace SiteName = "INWALA HC" if SiteID==	2003110050
replace SiteName = "S/GANGARA HC" if SiteID==	2003110051
replace SiteName = "YARLUMU HC" if SiteID==	2003110052
replace SiteName = "YAU-YAU HC" if SiteID==	2003110053
replace SiteName = "RUMA PHC" if SiteID==	2003110054
replace SiteName = "GARIN LABO HC" if SiteID==	2003110055
replace SiteName = "KWANDAISO HC" if SiteID==	2003110056
replace SiteName = "LARBA HC" if SiteID==	2003110057
replace SiteName = "RAYI HC" if SiteID==	2003110058
replace SiteName = "S/DUMBURAWA HC" if SiteID==	2003110059
replace SiteName = "GARIN INU HC" if SiteID==	2003110060
replace SiteName = "KAREWA HC" if SiteID==	2003110061
replace SiteName = "MAGAJI ABU HC" if SiteID==	2003110062
replace SiteName = "SHEKEWA MCH" if SiteID==	2003110063
replace SiteName = "YARGAMJI HC" if SiteID==	2003110064
replace SiteName = "WAGINI PHC" if SiteID==	2003110065
replace SiteName = "DAN TUDU HC" if SiteID==	2003110066
replace SiteName = "DAURAWA HC" if SiteID==	2003110067
replace SiteName = "GARIN DODO HC" if SiteID==	2003110068
replace SiteName = "GARIN HAMBAMA HC" if SiteID==	2003110069
replace SiteName = "KASAI HC" if SiteID==	2003110070
replace SiteName = "GEN HOSPBAURE" if SiteID==	2004210001
replace SiteName = "BABBAN MUTUM CHC" if SiteID==	2004110002
replace SiteName = "SALAI  HC" if SiteID==	2004110003
replace SiteName = "DAJE HC" if SiteID==	2004110004
replace SiteName = "GURE HC" if SiteID==	2004110005
replace SiteName = "FASKI MCH" if SiteID==	2004110006
replace SiteName = "KAGARA HC" if SiteID==	2004110007
replace SiteName = "BURDUDU HC" if SiteID==	2004110008
replace SiteName = "MAIKILIYA MCH" if SiteID==	2004110009
replace SiteName = "YAN MAULU MCH" if SiteID==	2004110010
replace SiteName = "DOLE HC" if SiteID==	2004110011
replace SiteName = "KUMBI HC" if SiteID==	2004110012
replace SiteName = "MANTAU MCH" if SiteID==	2004110013
replace SiteName = "TARAMNAWA HC" if SiteID==	2004110014
replace SiteName = "BARE HC" if SiteID==	2004110015
replace SiteName = "UNG. ISAH MCH" if SiteID==	2004110016
replace SiteName = "GARKI PHC" if SiteID==	2004110017
replace SiteName = "KUNTARU HC" if SiteID==	2004110018
replace SiteName = "TUMFUSHI HC" if SiteID==	2004110019
replace SiteName = "MAIBARA MCH" if SiteID==	2004110020
replace SiteName = "KAWARI HC" if SiteID==	2004110021
replace SiteName = "ACHAKWALE HC" if SiteID==	2004110022
replace SiteName = "GWARANDAMA HC" if SiteID==	2004110023
replace SiteName = "YANDUNA MCH" if SiteID==	2004110024
replace SiteName = "DAWAYE HC" if SiteID==	2004110025
replace SiteName = "GAMAJI HC" if SiteID==	2004110026
replace SiteName = "HUI MCH" if SiteID==	2004110027
replace SiteName = "DAN TAGWARMA HC" if SiteID==	2004110028
replace SiteName = "HURTUMI HC" if SiteID==	2004110029
replace SiteName = "MAZARE HC" if SiteID==	2004110030
replace SiteName = "UNG. RAF HC" if SiteID==	2004110031
replace SiteName = "YANTSAI HC" if SiteID==	2004110032
replace SiteName = "K/SALLAU HC" if SiteID==	2004110033
replace SiteName = "AGALA HC" if SiteID==	2004110034
replace SiteName = "DANKUM HC" if SiteID==	2004110035
replace SiteName = "AYA HC" if SiteID==	2004110036
replace SiteName = "KINOMA HC" if SiteID==	2004110037
replace SiteName = "MACANMAWA HC" if SiteID==	2004110038
replace SiteName = "MAIMAKWAMI HC" if SiteID==	2004110039
replace SiteName = "MUDURI HC" if SiteID==	2004110040
replace SiteName = "UNG. GAMJI HC" if SiteID==	2004110041
replace SiteName = "JUMBURUN HC" if SiteID==	2004110042
replace SiteName = "Dangagi PHC" if SiteID==	2004110042
replace SiteName = "BINDAWA CHC" if SiteID==	2005110001
replace SiteName = "BINDAWA DISP" if SiteID==	2005110002
replace SiteName = "MAKERA DISP" if SiteID==	2005110003
replace SiteName = "ZANGO DISP" if SiteID==	2005110004
replace SiteName = "TAFASHIYA DISP" if SiteID==	2005110005
replace SiteName = "DALLAJE MCHC" if SiteID==	2005110006
replace SiteName = "RUGAR IDI PHC" if SiteID==	2005110007
replace SiteName = "FARU DISP" if SiteID==	2005110008
replace SiteName = "KYARMANYA DISP" if SiteID==	2005110009
replace SiteName = "YAN RABO DISP" if SiteID==	2005110010
replace SiteName = "KUBA DISP" if SiteID==	2005110011
replace SiteName = "RUGAR BADU DISP" if SiteID==	2005110012
replace SiteName = "SHA'ISKAWA MCH" if SiteID==	2005110013
replace SiteName = "JIBAWA DISP" if SiteID==	2005110014
replace SiteName = "GIMI DISP" if SiteID==	2005110015
replace SiteName = "ADARKAWA DISP" if SiteID==	2005110016
replace SiteName = "YAN-JALO DISP" if SiteID==	2005110017
replace SiteName = "YAR KUKI DISP" if SiteID==	2005110018
replace SiteName = "BAURE MCHC" if SiteID==	2005110019
replace SiteName = "BAURE DISP" if SiteID==	2005110020
replace SiteName = "MAZANYA DISP" if SiteID==	2005110021
replace SiteName = "DAKWALE DISP" if SiteID==	2005110022
replace SiteName = "KAMFANI DISP" if SiteID==	2005120023
replace SiteName = "DADIN KOWA DISP" if SiteID==	2005110024
replace SiteName = "DORO MPHC" if SiteID==	2005110025
replace SiteName = "DORO DISP" if SiteID==	2005110026
replace SiteName = "TUWARU DISP" if SiteID==	2005110027
replace SiteName = "KARKAHU DISP" if SiteID==	2005110028
replace SiteName = "FARU DISP" if SiteID==	2005110029
replace SiteName = "YAN GORA MPHC" if SiteID==	2005110030
replace SiteName = "YAN GORA DISP" if SiteID==	2005110031
replace SiteName = "K/GAWO DISP" if SiteID==	2005110032
replace SiteName = "K/JOGO DISP" if SiteID==	2005110033
replace SiteName = "MAGIWA DISP" if SiteID==	2005110034
replace SiteName = "DIGGA DISP" if SiteID==	2005110035
replace SiteName = "GIREMAWA" if SiteID==	2005110036
replace SiteName = "GOBIRAWA DISP" if SiteID==	2005110037
replace SiteName = "A/SAWA DISP" if SiteID==	2005110038
replace SiteName = "YAN NAGANI DISP" if SiteID==	2005110039
replace SiteName = "KANGI DISP" if SiteID==	2005110040
replace SiteName = "SANTAR BILA DISP" if SiteID==	2005110041
replace SiteName = "SHIBDAWA MCHC" if SiteID==	2005110042
replace SiteName = "KIRYA DISP" if SiteID==	2005110043
replace SiteName = "AGALAWA DISP" if SiteID==	2005110044
replace SiteName = "LARABAWA DISP" if SiteID==	2005110045
replace SiteName = "ZAKATA DISP" if SiteID==	2005110046
replace SiteName = "WARI DISP" if SiteID==	2005110047
replace SiteName = "TAMA MPHC" if SiteID==	2005110048
replace SiteName = "BA'AWA MCHC" if SiteID==	2005110049
replace SiteName = "GWANZA MCHC" if SiteID==	2005110050
replace SiteName = "DAN MARKE PHC" if SiteID==	2005110051
replace SiteName = "RINJIN BAUSHE DISP" if SiteID==	2005110052
replace SiteName = "DAYE DISP" if SiteID==	2005110053
replace SiteName = "TUTUNBE DISP" if SiteID==	2005110054
replace SiteName = "DAGEJI DISP" if SiteID==	2005110055
replace SiteName = "DOKAJI DISP" if SiteID==	2005110056
replace SiteName = "GAIWA DISP" if SiteID==	2005110057
replace SiteName = "MAKERA DISP" if SiteID==	2005110058
replace SiteName = "MAGAMU DISP" if SiteID==	2005110059
replace SiteName = "GAIWAR KURMI DISP" if SiteID==	2005110060
replace SiteName = "KAMRI MCHC" if SiteID==	2005110061
replace SiteName = "BARGAI DISP" if SiteID==	2005110062
replace SiteName = "YAR ALI DISP" if SiteID==	2005110063
replace SiteName = "YAR DAURA DISP" if SiteID==	2005110064
replace SiteName = "BANYE PHC" if SiteID==	2006110001
replace SiteName = "YANUKU HC" if SiteID==	2006110002
replace SiteName = "LAMUTANNI HC" if SiteID==	2006110003
replace SiteName = "BADAKE HC" if SiteID==	2006110004
replace SiteName = "KAGADAMA HC" if SiteID==	2006110005
replace SiteName = "SALGORIYO HC" if SiteID==	2006110006
replace SiteName = "CHARANCHI CHC" if SiteID==	2006110007
replace SiteName = "CHARANCHI MCHC" if SiteID==	2006110008
replace SiteName = "HANAYE HC" if SiteID==	2006110009
replace SiteName = "KERERIYA HC" if SiteID==	2006110010
replace SiteName = "TIKI HC" if SiteID==	2006110011
replace SiteName = "CHARANCI MEDICAL Clin AND MATERNITY" if SiteID==	2006120012
replace SiteName = "MAZAGA PHC" if SiteID==	2006110013
replace SiteName = "MDG DOKA PHC" if SiteID==	2006110014
replace SiteName = "DANGUNA HC" if SiteID==	2006110015
replace SiteName = "DANGUNA HC" if SiteID==	2006110016
replace SiteName = "JEWA HC" if SiteID==	2006110017
replace SiteName = "MARKE HC" if SiteID==	2006110018
replace SiteName = "KUNATAU HC" if SiteID==	2006110019
replace SiteName = "GANUWA HC" if SiteID==	2006110020
replace SiteName = "DOKAU GANUA HC" if SiteID==	2006110021
replace SiteName = "BURTU HC" if SiteID==	2006110022
replace SiteName = "DABGANYA HC" if SiteID==	2006110023
replace SiteName = "DANJAKKA HC" if SiteID==	2006110024
replace SiteName = "GAURAKI HC" if SiteID==	2006110025
replace SiteName = "KODA HC" if SiteID==	2006110026
replace SiteName = "FARIN RUWA HC" if SiteID==	2006110027
replace SiteName = "KODAR JALLI HC" if SiteID==	2006110028
replace SiteName = "DOKAU MAIRIMAYE HC" if SiteID==	2006110029
replace SiteName = "MAGANIN WAKE HC" if SiteID==	2006110030
replace SiteName = "KURAYE HC" if SiteID==	2006110031
replace SiteName = "BAGGA HC" if SiteID==	2006110032
replace SiteName = "MDG DAGORA HC" if SiteID==	2006110033
replace SiteName = "YAR'MALAMAI HC" if SiteID==	2006110034
replace SiteName = "RUGAR WAKE HC" if SiteID==	2006110035
replace SiteName = "MAJEN WAYYA HC" if SiteID==	2006110036
replace SiteName = "NASARAWA   HC" if SiteID==	2006110037
replace SiteName = "YAR - MUDI HC" if SiteID==	2006110038
replace SiteName = "KARTAKA HC" if SiteID==	2006110039
replace SiteName = "LAMBA HC" if SiteID==	2006110040
replace SiteName = "BARAN GIZO HC" if SiteID==	2006110041
replace SiteName = "SABARU HC" if SiteID==	2006110042
replace SiteName = "RADDA PHC" if SiteID==	2006110043
replace SiteName = "ZANA HC" if SiteID==	2006110044
replace SiteName = "KADANYA HC" if SiteID==	2006110045
replace SiteName = "BILLIZI HC" if SiteID==	2006110046
replace SiteName = "DAGALADI HC" if SiteID==	2006110047
replace SiteName = "FARFARU HC" if SiteID==	2006110048
replace SiteName = "SAFANA HC" if SiteID==	2006110049
replace SiteName = "KUKI HC" if SiteID==	2006110050
replace SiteName = "BAJINAWA HC" if SiteID==	2006110051
replace SiteName = "DAMAKWARO HC" if SiteID==	2006110052
replace SiteName = "YANDU HC" if SiteID==	2006110053
replace SiteName = "TSAKATSA HC" if SiteID==	2006110054
replace SiteName = "DAFARA HC" if SiteID==	2006110055
replace SiteName = "RUGA HC" if SiteID==	2006110056
replace SiteName = "AREA HC" if SiteID==	2006110057
replace SiteName = "MALAMAWA HC" if SiteID==	2006110058
replace SiteName = "GEN HOSPD/Musa" if SiteID==	2007210001
replace SiteName = "PHC DANMUSA DESP" if SiteID==	2007110002
replace SiteName = "GURZA KUKA DESP" if SiteID==	2007110003
replace SiteName = "MAIRABON TUWO DESP" if SiteID==	2007110004
replace SiteName = "Katsinawa HC" if SiteID==	2007110005
replace SiteName = "Zamfarawa HC" if SiteID==	2007110006
replace SiteName = "SAKWATAWA DESP" if SiteID==	2007110007
replace SiteName = "BICHI DESP" if SiteID==	2007110008
replace SiteName = "MARKE DESP" if SiteID==	2007110009
replace SiteName = "SHAWERE DESP" if SiteID==	2007110010
replace SiteName = "DUTSIN DADI DESP" if SiteID==	2007110011
replace SiteName = "NASARAWA DESP" if SiteID==	2007110012
replace SiteName = "BAREBARI DESP" if SiteID==	2007110013
replace SiteName = "DAN ALKIMA DESP" if SiteID==	2007110014
replace SiteName = "AINUN HASSAN DESP" if SiteID==	2007110015
replace SiteName = "DANTAKURI DESP" if SiteID==	2007110016
replace SiteName = "DAN-ALI DESP" if SiteID==	2007110017
replace SiteName = "TASHAR KADANYA DESP" if SiteID==	2007110018
replace SiteName = "AMARAWA DESP" if SiteID==	2007110019
replace SiteName = "DAN-DIRE DESP" if SiteID==	2007110020
replace SiteName = "HANKI BIRI DESP" if SiteID==	2007110021
replace SiteName = "KABUKE DESP" if SiteID==	2007110022
replace SiteName = "DANTUDU DESP" if SiteID==	2007110023
replace SiteName = "KAIGA MALAMAI DESP" if SiteID==	2007110024
replace SiteName = "MAIDABINO MCH" if SiteID==	2007110025
replace SiteName = "G/KUNDUMA DESP" if SiteID==	2007110026
replace SiteName = "SABON GARIN TABARAU DESP" if SiteID==	2007110027
replace SiteName = "KULERE DESP" if SiteID==	2007110028
replace SiteName = "RUNKA DESP" if SiteID==	2007110029
replace SiteName = "GIDAN KUNDUMA DESP" if SiteID==	2007110030
replace SiteName = "LELELU DESP" if SiteID==	2007110031
replace SiteName = "DUNYA HC" if SiteID==	2007110032
replace SiteName = "FALALE DESP" if SiteID==	2007110033
replace SiteName = "GOBIRAWA DESP" if SiteID==	2007110034
replace SiteName = "DANGEZA DESP" if SiteID==	2007110035
replace SiteName = "YANTARA DESP" if SiteID==	2007110036
replace SiteName = "T/ICCE DESP" if SiteID==	2007110037
replace SiteName = "YAR DANKO DESP" if SiteID==	2007110038
replace SiteName = "YASHE DESP" if SiteID==	2007110039
replace SiteName = "FAFAWA DESP" if SiteID==	2007110040
replace SiteName = "KWARARE DESP" if SiteID==	2007110041
replace SiteName = "YANTUMAKI PHC" if SiteID==	2007110042
replace SiteName = "T/AGEWA DESP" if SiteID==	2007110043
replace SiteName = "DANDUME CHC" if SiteID==	2008110001
replace SiteName = "DANDUME PHC" if SiteID==	2008110002
replace SiteName = "HAJARAKI HC" if SiteID==	2008120003
replace SiteName = "NASIHA MATERNITY" if SiteID==	2008120004
replace SiteName = "JIRUWA HC" if SiteID==	2008110005
replace SiteName = "UNG. RIMI HC" if SiteID==	2008110006
replace SiteName = "UNG. ZANGO HC" if SiteID==	2008110007
replace SiteName = "KWAKWARE HC" if SiteID==	2008110008
replace SiteName = "UNG. BANGO HC" if SiteID==	2008110009
replace SiteName = "DANSODA HC" if SiteID==	2008110010
replace SiteName = "DUGUN SAMBO HC" if SiteID==	2008110011
replace SiteName = "KABALAWA HC" if SiteID==	2008110012
replace SiteName = "UNG. HAJE HC" if SiteID==	2008110013
replace SiteName = "DANTANKARI HC" if SiteID==	2008120014
replace SiteName = "UNG. SORO HC" if SiteID==	2008110015
replace SiteName = "UNG. GAMBA HC" if SiteID==	2008110016
replace SiteName = "UNG. MUJIA HC" if SiteID==	2008110017
replace SiteName = "MAIKWAMA HC" if SiteID==	2008110018
replace SiteName = "NASARAWA HC" if SiteID==	2008110019
replace SiteName = "MADOBI HC" if SiteID==	2008110020
replace SiteName = "M/WANDO HC" if SiteID==	2008110021
replace SiteName = "TUBU HC" if SiteID==	2008110022
replace SiteName = "UNG. DORO HC" if SiteID==	2008110023
replace SiteName = "MAHUTA PHC" if SiteID==	2008110024
replace SiteName = "GYAZAMA HC" if SiteID==	2008110025
replace SiteName = "UNG. ALKASIM HC" if SiteID==	2008110026
replace SiteName = "GWAIGWAYE HC" if SiteID==	2008110027
replace SiteName = "SAKO HC" if SiteID==	2008110028
replace SiteName = "MAITSATSAKA HC" if SiteID==	2008110029
replace SiteName = "UNG. MAIGAYYA HC" if SiteID==	2008110030
replace SiteName = "MAHUTA MDG Clin" if SiteID==	2008110031
replace SiteName = "KAURAN PAWA HC" if SiteID==	2008110032
replace SiteName = "TUMBURKA PHC" if SiteID==	2008110033
replace SiteName = "UNG. WAZIRI HC" if SiteID==	2008110034
replace SiteName = "UNG. DUTSE HC" if SiteID==	2008110035
replace SiteName = "BADO HC" if SiteID==	2008110036
replace SiteName = "KWADIRAHA HC" if SiteID==	2008110037
replace SiteName = "L/KADAYA MDG CLININC" if SiteID==	2008110038
replace SiteName = "TAKALMAWA HC" if SiteID==	2008110039
replace SiteName = "JIDADI HC" if SiteID==	2008110040
replace SiteName = "KAURA ALASAN HC" if SiteID==	2008110041
replace SiteName = "UNG. ILU HC" if SiteID==	2008110042
replace SiteName = "PHC DANJA" if SiteID==	2009110001
replace SiteName = "PHC DABAI" if SiteID==	2009110002
replace SiteName = "TANDAMA HC" if SiteID==	2009110003
replace SiteName = " KAHUTU HC" if SiteID==	2009110004
replace SiteName = " JIBA HC" if SiteID==	2009110005
replace SiteName = "FSC DANJA" if SiteID==	2009110006
replace SiteName = "UNG GWARI  DESP" if SiteID==	2009110007
replace SiteName = "DANANANY DESP" if SiteID==	2009110008
replace SiteName = "BABBAN RAFI DESP" if SiteID==	2009110009
replace SiteName = "CHADIYA DESP" if SiteID==	2009110010
replace SiteName = "DAN MALAM GAUTA DESP" if SiteID==	2009110011
replace SiteName = "BAMO DESP" if SiteID==	2009110012
replace SiteName = "KOKAMI DESP" if SiteID==	2009120013
replace SiteName = "NAHUCE DESP" if SiteID==	2009110014
replace SiteName = "UNG SA'I DESP" if SiteID==	2009110015
replace SiteName = "BAZANGA DESP" if SiteID==	2009110016
replace SiteName = "UNR RIMI DESP" if SiteID==	2009110017
replace SiteName = "ABASAWA DESP" if SiteID==	2009110018
replace SiteName = "RAFIN GORA DESP" if SiteID==	2009110019
replace SiteName = "UNG SARKIN NOMA DESP" if SiteID==	2009110020
replace SiteName = "BUZAYE DESP" if SiteID==	2009110021
replace SiteName = "UNG BALARABE DESP" if SiteID==	2009110022
replace SiteName = "UNG DANTALLE DESP" if SiteID==	2009110023
replace SiteName = "LAYIN MAHAUTA DESP" if SiteID==	2009110024
replace SiteName = "MARABAR DABAI DESP" if SiteID==	2009110025
replace SiteName = "HURGU DESP" if SiteID==	2009110026
replace SiteName = "TAFARIN HABE DESP" if SiteID==	2009110027
replace SiteName = "DAURAN NUHU DESP" if SiteID==	2009110028
replace SiteName = "DAURAN INDA DESP" if SiteID==	2009110029
replace SiteName = "CHC DAURA" if SiteID==	2010110001
replace SiteName = "BAWO Clin AND MATERNITY" if SiteID==	2010220002
replace SiteName = "DAURA MEDICAL Clin AND MATERNITY" if SiteID==	2010120003
replace SiteName = "MADOBI HC" if SiteID==	2010110004
replace SiteName = "SHARAWA MCH" if SiteID==	2010110005
replace SiteName = "KURNEJI MCH" if SiteID==	2010110006
replace SiteName = "SUDUJI PHC" if SiteID==	2010110007
replace SiteName = "TAMBU HC" if SiteID==	2010110008
replace SiteName = "DANNAKOLA HC" if SiteID==	2010110009
replace SiteName = "DAURA URBAN HC" if SiteID==	2010110010
replace SiteName = "HINDATU MCH" if SiteID==	2010110011
replace SiteName = "KANTI MCH" if SiteID==	2010110012
replace SiteName = "KALGO MCH" if SiteID==	2010110013
replace SiteName = "GURJIYA MCH" if SiteID==	2010110014
replace SiteName = "BARAJI MCH" if SiteID==	2010110015
replace SiteName = "FSC DAURA" if SiteID==	2010110016
replace SiteName = "GEN HOSPDAURA" if SiteID==	2010210017
replace SiteName = "DAN AUNAI MCH" if SiteID==	2011110001
replace SiteName = "SOBASHI MCH" if SiteID==	2011110002
replace SiteName = "KOGON BURTU MCH" if SiteID==	2011110003
replace SiteName = "KAOGE HC" if SiteID==	2011110004
replace SiteName = "DUTSI CHC" if SiteID==	2011120005
replace SiteName = "DUTSI MCH" if SiteID==	2011120006
replace SiteName = "DUTSAWA HC" if SiteID==	2011120007
replace SiteName = "MACHINAWA HC" if SiteID==	2011120008
replace SiteName = "TALU HC" if SiteID==	2011120009
replace SiteName = "KAYAWA MCH" if SiteID==	2011120010
replace SiteName = "GIGINYA MCH" if SiteID==	2011120011
replace SiteName = "MAKANGARA HC" if SiteID==	2011120012
replace SiteName = "KANTUDU HC" if SiteID==	2011120013
replace SiteName = "BAEL HC" if SiteID==	2011120014
replace SiteName = "MUNAWA MCH" if SiteID==	2011120015
replace SiteName = "DAGUNEJI HC" if SiteID==	2011120016
replace SiteName = "MADAWA MCH" if SiteID==	2011120017
replace SiteName = "RABO HC" if SiteID==	2011110018
replace SiteName = "SHARGALLE MCH" if SiteID==	2011110019
replace SiteName = "KAUNU HC" if SiteID==	2011110020
replace SiteName = "KARAWA HC" if SiteID==	2011110021
replace SiteName = "RIJIYA HC" if SiteID==	2011110022
replace SiteName = "JAKASA HC" if SiteID==	2011110023
replace SiteName = "SIRIKA HC" if SiteID==	2011110024
replace SiteName = "YAMEL MCH" if SiteID==	2011110025
replace SiteName = "BAGGA HC" if SiteID==	2011110026
replace SiteName = "YALDE HC" if SiteID==	2011110027
replace SiteName = "SHARGALLE FSC" if SiteID==	2011110028
replace SiteName = "T/WALI HC" if SiteID==	2011110029
replace SiteName = "BOLORI HC" if SiteID==	2011110030
replace SiteName = "BAGAGADI PHC" if SiteID==	2012110001
replace SiteName = "BAJINAWA HC" if SiteID==	2012110002
replace SiteName = "DAGE LAWAL MPHC" if SiteID==	2012110003
replace SiteName = "KURA KATOGE HC" if SiteID==	2012110004
replace SiteName = "DABAWA HC" if SiteID==	2012110005
replace SiteName = "MAITSANI HC" if SiteID==	2012110006
replace SiteName = "KWANTAMAWA HC" if SiteID==	2012110007
replace SiteName = "WAKAJI PHC" if SiteID==	2012110008
replace SiteName = "CHC DUTSIN-MA CHC" if SiteID==	2012110009
replace SiteName = "FSC" if SiteID==	2012110010
replace SiteName = "GEN HOSPD/MA" if SiteID==	2012210011
replace SiteName = "D/MA MED. CENTRE" if SiteID==	2012220012
replace SiteName = "PHC DUTSIN-MA" if SiteID==	2012110013
replace SiteName = "KAGARA HC" if SiteID==	2012110014
replace SiteName = "S/GARIN SAFANA" if SiteID==	2012110015
replace SiteName = "RUWAN DOROWA" if SiteID==	2012110016
replace SiteName = "DOCTOR'S Clin" if SiteID==	2012220017
replace SiteName = "PHC KAROFI" if SiteID==	2012110018
replace SiteName = "RAYI HC" if SiteID==	2012110019
replace SiteName = "FAGUWA HC" if SiteID==	2012110020
replace SiteName = "JAKA HC" if SiteID==	2012110021
replace SiteName = "DAKA HC" if SiteID==	2012110022
replace SiteName = "DOGON ZU HC" if SiteID==	2012110023
replace SiteName = "WAKAZA HC" if SiteID==	2012110024
replace SiteName = "TAURA HC" if SiteID==	2012110025
replace SiteName = "PHC KUKI" if SiteID==	2012110026
replace SiteName = "GOBIRAWA HC" if SiteID==	2012110027
replace SiteName = "KILIYA HC" if SiteID==	2012110028
replace SiteName = "DANTAKIRI HC" if SiteID==	2012110029
replace SiteName = "TSAWA TSAWA HC" if SiteID==	2012110030
replace SiteName = "PHC Y/RUMA" if SiteID==	2012110031
replace SiteName = "BADOLE CHC" if SiteID==	2012110032
replace SiteName = "GARHI HC" if SiteID==	2012110033
replace SiteName = "TAKATSABA HC" if SiteID==	2012110034
replace SiteName = "TURARE PHC" if SiteID==	2012110035
replace SiteName = "D/RUWA MCHC" if SiteID==	2012110036
replace SiteName = "SANAWA PHC" if SiteID==	2012110037
replace SiteName = "GARANGAMAWA HC" if SiteID==	2012110038
replace SiteName = "YANSHANTUNA HC" if SiteID==	2012110039
replace SiteName = "MDG MAKERA MCHC" if SiteID==	2012110040
replace SiteName = "SHEMA MPHC" if SiteID==	2012110041
replace SiteName = "GIZAWAHC" if SiteID==	2012110042
replace SiteName = "MPHC" if SiteID==	2012110043
replace SiteName = "FASKARI CHC" if SiteID==	2013110001
replace SiteName = "BILBIS HC" if SiteID==	2013110002
replace SiteName = "UNG. DANMAIRO HC" if SiteID==	2013110003
replace SiteName = "UNG. GAGO HC" if SiteID==	2013110004
replace SiteName = "UNG. BIKA HC" if SiteID==	2013110005
replace SiteName = "DOGON AWO HC" if SiteID==	2013110006
replace SiteName = "FASKARI HC" if SiteID==	2013110007
replace SiteName = "BIRNIN KOGO HC" if SiteID==	2013110008
replace SiteName = "MAKERA HC" if SiteID==	2013110009
replace SiteName = "SABON LAYI HC" if SiteID==	2013110010
replace SiteName = "FANKAMA HC" if SiteID==	2013110011
replace SiteName = "UNG. DOKA HC" if SiteID==	2013110012
replace SiteName = "UNG. TSAMIYA HC" if SiteID==	2013110013
replace SiteName = "DOGON DAWA HC" if SiteID==	2013110014
replace SiteName = "GOBIRAWA HC" if SiteID==	2013110015
replace SiteName = "UNG. SAKKAI HC" if SiteID==	2013110016
replace SiteName = "KAGARA HC" if SiteID==	2013110017
replace SiteName = "YANKARA PHC" if SiteID==	2013110018
replace SiteName = "ZAGAMI HC" if SiteID==	2013110019
replace SiteName = "YANFA HC" if SiteID==	2013110020
replace SiteName = "HIMGO HC" if SiteID==	2013110021
replace SiteName = "MAIWA PHC" if SiteID==	2013110022
replace SiteName = "UNG. MAJE HC" if SiteID==	2013110023
replace SiteName = "BELE HC" if SiteID==	2013110024
replace SiteName = "UNG. M. MUSA HC" if SiteID==	2013110025
replace SiteName = "TAFOKI HC" if SiteID==	2013110026
replace SiteName = "UNG. MIKO HC" if SiteID==	2013110027
replace SiteName = "DOMA  HC" if SiteID==	2013110028
replace SiteName = "SHEME HC" if SiteID==	2013110029
replace SiteName = "UNG. SARKI HC" if SiteID==	2013110030
replace SiteName = "UNG. HAYAKI HC" if SiteID==	2013110031
replace SiteName = "NASARAWA HC" if SiteID==	2013110032
replace SiteName = "KAMFANI HC" if SiteID==	2013110033
replace SiteName = "YAR MALAMAI HC" if SiteID==	2013110034
replace SiteName = "DAN AJI HC" if SiteID==	2013110035
replace SiteName = "BAKAMYA HC" if SiteID==	2013110036
replace SiteName = "MUNONI HC" if SiteID==	2013110037
replace SiteName = "YAR MARAFA HC" if SiteID==	2013110038
replace SiteName = "MAL. SABO HC" if SiteID==	2013110039
replace SiteName = "ZAUREN ZAKI HC" if SiteID==	2013110040
replace SiteName = "DAUDAWA CHC" if SiteID==	2013110041
replace SiteName = "KAMFANIN DAUDAWA HC" if SiteID==	2013110042
replace SiteName = "KWANKIRO HC" if SiteID==	2013110043
replace SiteName = "KANA HAKI HC" if SiteID==	2013110044
replace SiteName = "UNG. NAMADI HC" if SiteID==	2013110045
replace SiteName = "UNG. SAMANJA HC" if SiteID==	2013110046
replace SiteName = "MAIGORA HC" if SiteID==	2013110047
replace SiteName = "UNG. GIGO HC" if SiteID==	2013110048
replace SiteName = "UNG. A BABBA HC" if SiteID==	2013110049
replace SiteName = "KADISAU HC" if SiteID==	2013110050
replace SiteName = "UNG. GIZO HC" if SiteID==	2013110051
replace SiteName = "KUKOKI HC" if SiteID==	2013110052
replace SiteName = "UNG. A . SANI HC" if SiteID==	2013110053
replace SiteName = "RUWAN GODIYA CHC" if SiteID==	2013110054
replace SiteName = "DAN BA'U HC" if SiteID==	2013110055
replace SiteName = "KWAI HC" if SiteID==	2013110056
replace SiteName = "SHAWA HC" if SiteID==	2013110057
replace SiteName = "KWAKWARE HC" if SiteID==	2013110058
replace SiteName = "POLICE Clin" if SiteID==	2014110001
replace SiteName = "WOMEN & CHILDREN Clin" if SiteID==	2014220002
replace SiteName = "CHI BAUNA HC" if SiteID==	2014110003
replace SiteName = "DUKKE PHC" if SiteID==	2014110004
replace SiteName = "K/MAITSAMIYA HC" if SiteID==	2014110005
replace SiteName = "RAFIN DINYA HC" if SiteID==	2014110006
replace SiteName = "UNG. BIRI HC" if SiteID==	2014110007
replace SiteName = "UNG. BISHI HC" if SiteID==	2014110008
replace SiteName = "UNG. DAUDU HC" if SiteID==	2014110009
replace SiteName = "UNG. TUJI HC" if SiteID==	2014110010
replace SiteName = "UNG. MAI TANKO HC" if SiteID==	2014110011
replace SiteName = "UNG. SALLAH HC" if SiteID==	2014110012
replace SiteName = "ZAMFARAWA HC" if SiteID==	2014110013
replace SiteName = "GWAIGWAYE HC" if SiteID==	2014110014
replace SiteName = "DAN LAYI HC" if SiteID==	2014110015
replace SiteName = "GOYA PHC" if SiteID==	2014110016
replace SiteName = "KWANAWAI HC" if SiteID==	2014110017
replace SiteName = "MAIKWALLA HC" if SiteID==	2014110018
replace SiteName = "UNG. MODA HC" if SiteID==	2014110019
replace SiteName = "DANKAWO HC" if SiteID==	2014110020
replace SiteName = "JABIRI HC" if SiteID==	2014110021
replace SiteName = "KWATAN GIRI HC" if SiteID==	2014110022
replace SiteName = "MAI GAMJI PHC" if SiteID==	2014110023
replace SiteName = "RINJI HC" if SiteID==	2014110024
replace SiteName = "UNG. YAWA HC" if SiteID==	2014110025
replace SiteName = "YAR TAFKI HC" if SiteID==	2014110026
replace SiteName = "NEW FUNTUA" if SiteID==	2014220027
replace SiteName = "HIMMA" if SiteID==	2014220028
replace SiteName = "BAGARI HC" if SiteID==	2014110029
replace SiteName = "COMPREHENSIVE" if SiteID==	2014110030
replace SiteName = "DAN FILI HC" if SiteID==	2014110031
replace SiteName = "GEN HOSPFTA" if SiteID==	2014210032
replace SiteName = "KALIYAWA HC" if SiteID==	2014110033
replace SiteName = "KWANA GUGA HC" if SiteID==	2014110034
replace SiteName = "UNG. DAHIRU HC" if SiteID==	2014110035
replace SiteName = "NAKOWA Clin" if SiteID==	2014210036
replace SiteName = "GWANGORI HC" if SiteID==	2014110037
replace SiteName = "MASKA PHC" if SiteID==	2014110038
replace SiteName = "NASARAWA PHC" if SiteID==	2014110039
replace SiteName = "UNG. TOFA HC" if SiteID==	2014110040
replace SiteName = "BCGA HC" if SiteID==	2014110041
replace SiteName = "TUDUN WADA HC" if SiteID==	2014110042
replace SiteName = "BISTIT" if SiteID==	2014220043
replace SiteName = "KHAMEK" if SiteID==	2014220044
replace SiteName = "FUNTUA MED Clin AND MATERNITY" if SiteID==	2014220045
replace SiteName = "NAKOWA Clin" if SiteID==	2014220046
replace SiteName = "JUST HOSPITAL" if SiteID==	2014120047
replace SiteName = "BAGIRE HC" if SiteID==	2014110048
replace SiteName = "BURMA HC" if SiteID==	2014110049
replace SiteName = "LASANAWA HC" if SiteID==	2014110050
replace SiteName = "TUDUN IYA HC" if SiteID==	2014110051
replace SiteName = "UNG. DANDADA HC" if SiteID==	2014110052
replace SiteName = "UNG. MAILAYA HC" if SiteID==	2014110053
replace SiteName = "NA JAMA'A HC" if SiteID==	2014110054
replace SiteName = "NASARAWA MCH" if SiteID==	2014110055
replace SiteName = "GEN HOSPINGAWA" if SiteID==	2015210001
replace SiteName = "FAMILY SUP. Clin" if SiteID==	2015110002
replace SiteName = "CENT. Clin" if SiteID==	2015110003
replace SiteName = "YANDOMA MPHC" if SiteID==	2015110004
replace SiteName = "YANDOMA MCH" if SiteID==	2015110005
replace SiteName = "KURFEJI MCH" if SiteID==	2015110006
replace SiteName = "YANKAURA HC" if SiteID==	2015110007
replace SiteName = "SANTAR YALLAWAL HC" if SiteID==	2015110008
replace SiteName = "DUNDU HC" if SiteID==	2015110009
replace SiteName = "SANTAR NA KYALLU HC" if SiteID==	2015110010
replace SiteName = "AMALAWA HC" if SiteID==	2015110011
replace SiteName = "DAMTSI HC" if SiteID==	2015110012
replace SiteName = "MANOMAWA MCH" if SiteID==	2015110013
replace SiteName = "KAFI HC" if SiteID==	2015110014
replace SiteName = "ADAMAWA HC" if SiteID==	2015110015
replace SiteName = "GANJUWA MCH" if SiteID==	2015110016
replace SiteName = "NASARAWA HC" if SiteID==	2015110017
replace SiteName = "JOBE HC" if SiteID==	2015110018
replace SiteName = "ZANGO HC" if SiteID==	2015110019
replace SiteName = "KANDAWA HC" if SiteID==	2015110020
replace SiteName = "DUKUMA HC" if SiteID==	2015110021
replace SiteName = "BADOLE HC" if SiteID==	2015110022
replace SiteName = "TSAMCINI HC" if SiteID==	2015110023
replace SiteName = "AGAYAWA MCH" if SiteID==	2015110024
replace SiteName = "YALLAMI HC" if SiteID==	2015110025
replace SiteName = "DAUNAKA" if SiteID==	2015110026
replace SiteName = "KANDARE HC" if SiteID==	2015110027
replace SiteName = "TUNAS PHC" if SiteID==	2015110028
replace SiteName = "BAKIN KWARI HC" if SiteID==	2015110029
replace SiteName = "KARKAKU HC" if SiteID==	2015110030
replace SiteName = "YAYA MCH" if SiteID==	2015110031
replace SiteName = "BIDORE HC" if SiteID==	2015110032
replace SiteName = "LADAN MCH" if SiteID==	2015110033
replace SiteName = "RURUMA MCH" if SiteID==	2015110034
replace SiteName = "BARERUWA HC" if SiteID==	2015110035
replace SiteName = "RURUMA HC" if SiteID==	2015110036
replace SiteName = "DANKAWA HC" if SiteID==	2015110037
replace SiteName = "DAN-ASHITAN HC" if SiteID==	2015110038
replace SiteName = "DARA PHC" if SiteID==	2015110039
replace SiteName = "SANDAWA HC" if SiteID==	2015110040
replace SiteName = "BUGAJE MCH" if SiteID==	2016110001
replace SiteName = "KAURA HC" if SiteID==	2016110002
replace SiteName = "GAKORDI HC" if SiteID==	2016110003
replace SiteName = "MURTUKU HC" if SiteID==	2016110004
replace SiteName = "TANTAGARYA HC" if SiteID==	2016110005
replace SiteName = "FARFARU HC" if SiteID==	2016110006
replace SiteName = "MAZANYA ABU HC" if SiteID==	2016110007
replace SiteName = "FARU HC" if SiteID==	2016110008
replace SiteName = "GURBIN MAGARYA PHC" if SiteID==	2016110009
replace SiteName = "JIBIA MAJE HC" if SiteID==	2016110010
replace SiteName = "MALLAMAWA HC" if SiteID==	2016110011
replace SiteName = "GANGARA PHC" if SiteID==	2016110012
replace SiteName = "TANKURI HC" if SiteID==	2016110013
replace SiteName = "KANWA HC" if SiteID==	2016110014
replace SiteName = "MAJE HC" if SiteID==	2016110015
replace SiteName = "FALELE HC" if SiteID==	2016110016
replace SiteName = "GURBI PHC" if SiteID==	2016110017
replace SiteName = "PPFN HC" if SiteID==	2016110018
replace SiteName = "TSANBEN 7 HC" if SiteID==	2016110019
replace SiteName = "FAFARA HC" if SiteID==	2016110020
replace SiteName = "TSANBEN RADI HC" if SiteID==	2016110021
replace SiteName = "JIBIA MEDICAL Clin AND MATERNITY" if SiteID==	2016120022
replace SiteName = "TUDUN WADA HC" if SiteID==	2016110023
replace SiteName = "PPFN HC" if SiteID==	2016110024
replace SiteName = "JIBIA BABBA HC" if SiteID==	2016110025
replace SiteName = "DADDARA PHC" if SiteID==	2016110026
replace SiteName = "S/GARIN RABE HC" if SiteID==	2016110027
replace SiteName = "RIMIN KUSA HC" if SiteID==	2016110028
replace SiteName = "KUSA MCH" if SiteID==	2016110029
replace SiteName = "NATSINTA HC" if SiteID==	2016110030
replace SiteName = "MAGAMA CHC" if SiteID==	2016110031
replace SiteName = "KWARARE HC" if SiteID==	2016110032
replace SiteName = "ZANDAM HC" if SiteID==	2016110033
replace SiteName = "MAZANYA "A" HC" if SiteID==	2016110034
replace SiteName = "GEN HOSPJIBIA" if SiteID==	2016210035
replace SiteName = "RIKO PHC" if SiteID==	2016110036
replace SiteName = "DAGA HC" if SiteID==	2016110037
replace SiteName = "DAN CAFA HC" if SiteID==	2016110038
replace SiteName = "AGANGARO HC" if SiteID==	2016110039
replace SiteName = "GINZO HC" if SiteID==	2016110040
replace SiteName = "YANGAYYA HC" if SiteID==	2016110041
replace SiteName = "K/BABBAN GIDA HC" if SiteID==	2016110042
replace SiteName = "JARKUKA HC" if SiteID==	2016110043
replace SiteName = "M. AMBULANCE HC" if SiteID==	2016110044
replace SiteName = "KAFUR PHC" if SiteID==	2017110001
replace SiteName = "U/DOGO HC" if SiteID==	2017110002
replace SiteName = "YARKADANYA HC" if SiteID==	2017110003
replace SiteName = "KAFUR OPD Clin" if SiteID==	2017120004
replace SiteName = "S/BIRNI HC" if SiteID==	2017110005
replace SiteName = "DANTUTURE HC" if SiteID==	2017110006
replace SiteName = "DANKANJIBA HC" if SiteID==	2017110007
replace SiteName = "DURMAI HC" if SiteID==	2017110008
replace SiteName = "JANGE HC" if SiteID==	2017110009
replace SiteName = "JARGABA HC" if SiteID==	2017110010
replace SiteName = "MAHUTA HC" if SiteID==	2017110011
replace SiteName = "KAGARA HC" if SiteID==	2017110012
replace SiteName = "NASARAWA HC" if SiteID==	2017110013
replace SiteName = "BARI HC" if SiteID==	2017110014
replace SiteName = "DANKWARO HC" if SiteID==	2017110015
replace SiteName = "S/LAYIN SIRAN HC" if SiteID==	2017110016
replace SiteName = "LAYIN HABU HC" if SiteID==	2017110017
replace SiteName = "GAMZAGO HC" if SiteID==	2017110018
replace SiteName = "MALLAMAWA HC" if SiteID==	2017110019
replace SiteName = "BAYALA HC" if SiteID==	2017110020
replace SiteName = "Y/TSAMIYA HC" if SiteID==	2017110021
replace SiteName = "BARAKAI HC" if SiteID==	2017110022
replace SiteName = "NASARAWA HC" if SiteID==	2017110023
replace SiteName = "DUTSEN KURA PHC" if SiteID==	2017110024
replace SiteName = "KANYA HC" if SiteID==	2017120025
replace SiteName = "M/KANYA HC" if SiteID==	2017110026
replace SiteName = "U/TSAMIYA HC" if SiteID==	2017110027
replace SiteName = "D/BORI HC" if SiteID==	2017110028
replace SiteName = "YARI BORI HC" if SiteID==	2017110029
replace SiteName = "LAYIN BORKONO HC" if SiteID==	2017110030
replace SiteName = "KUFAN TAMBO HC" if SiteID==	2017110031
replace SiteName = "KURUMGAFA HC" if SiteID==	2017110032
replace SiteName = "U/ALH. AMADU HC" if SiteID==	2017110033
replace SiteName = "MASARI MPHC" if SiteID==	2017110034
replace SiteName = "BAGUDU HC" if SiteID==	2017110035
replace SiteName = "LAYIN MAKERA HC" if SiteID==	2017110036
replace SiteName = "LAYIN ALH. AMADU HC" if SiteID==	2017110037
* there was a LGA code error here in NBS codes
replace SiteName = "LAYIN ALH. AMADU HC" if SiteID==	2017110037
replace SiteName = "U/SAMAE HC" if SiteID==	2017110038
replace SiteName = "U/SHUKAU HC" if SiteID==	2017110039
replace SiteName = "U/ILYA HC" if SiteID==	2017110040
replace SiteName = "S/KASA HC" if SiteID==	2017110041
replace SiteName = "S/LAYIN BASA HC" if SiteID==	2017110042
replace SiteName = "MAHANGI HC" if SiteID==	2017110043
replace SiteName = "SHEKKA HC" if SiteID==	2017110044
replace SiteName = "RUGOJI HC" if SiteID==	2017110045
replace SiteName = "YARTALATA HC" if SiteID==	2017110046
replace SiteName = "DUTSEN YANKE HC" if SiteID==	2017110047
replace SiteName = "U/DAWO HC" if SiteID==	2017110048
replace SiteName = "DAYAWA HC" if SiteID==	2017110049
replace SiteName = "KURMI HC" if SiteID==	2017110050
replace SiteName = "GOZAKI HC" if SiteID==	2017110051
replace SiteName = "TIBIS HC" if SiteID==	2017110052
replace SiteName = "HUGUMA HC" if SiteID==	2017110053
replace SiteName = "U/NUHU HC" if SiteID==	2017110054
replace SiteName = "SANI A HC" if SiteID==	2017110055
replace SiteName = "D/BORI HC" if SiteID==	2017110056
* End of NBS error corrections
replace SiteName = "ABDALLAWA MCH" if SiteID==	2018110001
replace SiteName = "DANBAZAU HC" if SiteID==	2018110002
replace SiteName = "NANJOGEL HC" if SiteID==	2018110003
replace SiteName = "NASARAWA HC" if SiteID==	2018110004
replace SiteName = "JIFATU HC" if SiteID==	2018110005
replace SiteName = "DANKUNAMA HC" if SiteID==	2018110006
replace SiteName = "BA'AWA HC" if SiteID==	2018110007
replace SiteName = "SABON BIRNI HC" if SiteID==	2018110008
replace SiteName = "DANKABA MCH" if SiteID==	2018110009
replace SiteName = "SAWARYA HC" if SiteID==	2018110010
replace SiteName = "DONO HC" if SiteID==	2018110011
replace SiteName = "FULFUREN UMME HC" if SiteID==	2018110012
replace SiteName = "DANKAMA PHC" if SiteID==	2018110013
replace SiteName = "DANKAMA DESP" if SiteID==	2018110014
replace SiteName = "DANTUDU HC" if SiteID==	2018110015
replace SiteName = "SHAGARAI HC" if SiteID==	2018110016
replace SiteName = "GAFIYA HC" if SiteID==	2018110017
replace SiteName = "NAHUTA HC" if SiteID==	2018110018
replace SiteName = "ZABAKAU HC" if SiteID==	2018110019
replace SiteName = "MADABA HC" if SiteID==	2018110020
replace SiteName = "BADO HC" if SiteID==	2018110021
replace SiteName = "GIRKA MDG" if SiteID==	2018110022
replace SiteName = "GARU HC" if SiteID==	2018110023
replace SiteName = "UNG. TSAMIYA HC" if SiteID==	2018110024
replace SiteName = "JAN KYARMA HC" if SiteID==	2018110025
replace SiteName = "DAN GAMJI HC" if SiteID==	2018110026
replace SiteName = "KAITA CHC" if SiteID==	2018110027
replace SiteName = "GANDE HC" if SiteID==	2018110028
replace SiteName = "GABA-GADI HC" if SiteID==	2018110029
replace SiteName = "DABA HC" if SiteID==	2018110030
replace SiteName = "MATSAI HC" if SiteID==	2018110031
replace SiteName = "RADI HC" if SiteID==	2018110032
replace SiteName = "KABOBI HC" if SiteID==	2018110033
replace SiteName = "KAGADAMA HC" if SiteID==	2018110034
replace SiteName = "WANGE-WANGE HC" if SiteID==	2018110035
replace SiteName = "YANDAKI MCH" if SiteID==	2018110036
replace SiteName = "DUTSEN SAFE MDG" if SiteID==	2018110037
replace SiteName = "LOKI HC" if SiteID==	2018110038
replace SiteName = "MAI TUKURI HC" if SiteID==	2018110039
replace SiteName = "YANHOHO HC" if SiteID==	2018110040
replace SiteName = "KAFIN MASHI HC" if SiteID==	2018110041
replace SiteName = "SABI HC" if SiteID==	2018110042
replace SiteName = "M/KADO HC" if SiteID==	2018110043
replace SiteName = "BURDUGAU HC" if SiteID==	2019110001
replace SiteName = "DAN-KALGO HC" if SiteID==	2019110002
replace SiteName = "SHARADDA HC" if SiteID==	2019110003
replace SiteName = "KURBA HC" if SiteID==	2019110004
replace SiteName = "DANMURABU HC" if SiteID==	2019110005
replace SiteName = "BAURE HC" if SiteID==	2019110006
replace SiteName = "UNG. TABO HC" if SiteID==	2019110007
replace SiteName = "GUNDAWA HC" if SiteID==	2019110008
replace SiteName = "INAWAR KAZA HC" if SiteID==	2019110009
replace SiteName = "TUDU HC" if SiteID==	2019110010
replace SiteName = "UNG. TSAMIYA HC" if SiteID==	2019110011
replace SiteName = "GURBI HC" if SiteID==	2019110012
replace SiteName = "GURBI OPD Clin" if SiteID==	2019120013
replace SiteName = "PAUWA HC" if SiteID==	2019110014
replace SiteName = "KATOGE HC" if SiteID==	2019110015
replace SiteName = "MASAKU HC" if SiteID==	2019110016
replace SiteName = "MAJIFA HC" if SiteID==	2019110017
replace SiteName = "DAN-GEME HC" if SiteID==	2019110018
replace SiteName = "DANBIRGIMA HC" if SiteID==	2019110019
replace SiteName = "KANKARA" if SiteID==	2019210020
replace SiteName = "KANKARA PHC" if SiteID==	2019110021
replace SiteName = "KANKARA MCH" if SiteID==	2019110022
replace SiteName = "NASARA HC" if SiteID==	2019120023
replace SiteName = "JANRUWA HC" if SiteID==	2019110024
replace SiteName = "KATARE PHC" if SiteID==	2019110025
replace SiteName = "GAIDAN ZAKI HC" if SiteID==	2019110026
replace SiteName = "BADA'U HC" if SiteID==	2019110027
replace SiteName = "HURYA HC" if SiteID==	2019110028
replace SiteName = "DANDASHIRE HC" if SiteID==	2019110029
replace SiteName = "KUKA SHEKA HC" if SiteID==	2019110030
replace SiteName = "SABON LAYI HC" if SiteID==	2019110031
replace SiteName = "MASHIGI HC" if SiteID==	2019110032
replace SiteName = "MABAI MCH" if SiteID==	2019110033
replace SiteName = "DAN-NAKINABO HC" if SiteID==	2019110034
replace SiteName = "DORAWA HC" if SiteID==	2019110035
replace SiteName = "YAR-GOJE MCH" if SiteID==	2019110036
replace SiteName = "DAN-MARKE Y PHC" if SiteID==	2019110037
replace SiteName = "KATSINAWA MCH" if SiteID==	2019110038
replace SiteName = "YAR TSAMIYA PHC" if SiteID==	2019110039
replace SiteName = "BATSIRARI HC" if SiteID==	2019110040
replace SiteName = "DARUSSALAM OPD Clin" if SiteID==	2019120041
replace SiteName = "AMARAWA HC" if SiteID==	2019110042
replace SiteName = "ZANGO PHC" if SiteID==	2019110043
replace SiteName = "DANSSABAU HC" if SiteID==	2019110044
replace SiteName = "YAR SANTA HC" if SiteID==	2019110045
replace SiteName = "JEKA AREDA HC" if SiteID==	2019110046
replace SiteName = "BAKKAL HC" if SiteID==	2019110047
replace SiteName = "KABUILE HC" if SiteID==	2019110048
replace SiteName = "DAN MARKE 2 PHC" if SiteID==	2019110049
replace SiteName = "GALADIMA PHC" if SiteID==	2020110001
replace SiteName = "K/DAWA HC" if SiteID==	2020110002
replace SiteName = "G.G.P.S.S KNK HC" if SiteID==	2020110003
replace SiteName = "MOBILE AMB. CLN" if SiteID==	2020110004
replace SiteName = "KAWARI PHC" if SiteID==	2020110005
replace SiteName = "KNK MCH" if SiteID==	2020120006
replace SiteName = "MD Clin" if SiteID==	2020110007
replace SiteName = "GYAZA PHC" if SiteID==	2020110008
replace SiteName = "GYAZA OPD Clin" if SiteID==	2020120009
replace SiteName = "JALIGA HC" if SiteID==	2020110010
replace SiteName = "YARKUTUNGU MCH" if SiteID==	2020110011
replace SiteName = "GOLGORO HC" if SiteID==	2020110012
replace SiteName = "KUNDURU HC" if SiteID==	2020110013
replace SiteName = "TOKARCHI HC" if SiteID==	2020110014
replace SiteName = "SUKUNTUNI PHC" if SiteID==	2020110015
replace SiteName = "T/WULU HC" if SiteID==	2020110016
replace SiteName = "GE. HOSP. KNK" if SiteID==	2020210017
replace SiteName = "DANDORO PHC" if SiteID==	2020110018
replace SiteName = "KAFIN SOLI MCH" if SiteID==	2020110019
replace SiteName = "R/GAYYA PHC" if SiteID==	2020110020
replace SiteName = "SAGAWA MCH" if SiteID==	2020110021
replace SiteName = "GADAR DANZARA HC" if SiteID==	2020110022
replace SiteName = "FAKUWA PHC" if SiteID==	2020110023
replace SiteName = "DANGI MCH" if SiteID==	2020110024
replace SiteName = "D/NAYAKI MCH" if SiteID==	2020110025
replace SiteName = "K/MAINA MCH" if SiteID==	2020110026
replace SiteName = "RIMAYE CHC" if SiteID==	2020110027
replace SiteName = "YARGAJEM HC" if SiteID==	2020110028
replace SiteName = "NASARAWA (R) HC" if SiteID==	2020110029
replace SiteName = "TAFASHIYA MCH" if SiteID==	2020110030
replace SiteName = "NASARAWA HC" if SiteID==	2020110031
replace SiteName = "TSA PHC" if SiteID==	2020110032
replace SiteName = "MAGAM PHC" if SiteID==	2020110033
replace SiteName = "MACHINJIM HC" if SiteID==	2020110034
replace SiteName = "MALLAMAWA HC" if SiteID==	2020110035
replace SiteName = "T/GAMJI HC" if SiteID==	2020110036
replace SiteName = "KOFAR SAURI MCHC" if SiteID==	2021110001
replace SiteName = "UMMUL KHAIRI MAT" if SiteID==	2021120002
replace SiteName = "IKWAN EYE Clin" if SiteID==	2021120003
replace SiteName = "KOFAR MARUSA MCHC" if SiteID==	2021110004
replace SiteName = "NURSING HOME HOSP." if SiteID==	2021120005
replace SiteName = "A.J.S.OUT PAT. Clin" if SiteID==	2021120006
replace SiteName = "ALLAH BAMU LAFIA Clin" if SiteID==	2021120007
replace SiteName = "SURA Clin" if SiteID==	2021120008
replace SiteName = "SAUKI Clin" if SiteID==	2021120009
replace SiteName = "LOW COST HC" if SiteID==	2021110010
replace SiteName = "GEN HOSPKTN" if SiteID==	2021210011
replace SiteName = "KUKAR GESA MCH" if SiteID==	2021110012
replace SiteName = "RAFIN DADI DESP. MCHC" if SiteID==	2021110013
replace SiteName = "RAFIN DADI DESP." if SiteID==	2021110014
replace SiteName = "KOFAR KAURA MCHC" if SiteID==	2021110015
replace SiteName = "TURAI YAR'ADUA MCH " if SiteID==	2021210016
replace SiteName = "GIDAN DAWA Clin" if SiteID==	2021110017
replace SiteName = "POLICE Clin" if SiteID==	2021120018
replace SiteName = "ALHERI Clin" if SiteID==	2021120019
replace SiteName = "HAMDALA SURGERY" if SiteID==	2021220020
replace SiteName = "ANFANI Clin" if SiteID==	2021120021
replace SiteName = "LABMINA MCH" if SiteID==	2021120022
replace SiteName = "ABBATIOR MCHC" if SiteID==	2021110023
replace SiteName = "S/UNGUWA Clin" if SiteID==	2021120024
replace SiteName = "INWALA HC" if SiteID==	2021110025
replace SiteName = "NEW MELLINIUM Clin" if SiteID==	2021120026
replace SiteName = "ASFA'U Clin" if SiteID==	2021120027
replace SiteName = "GODIYA Clin" if SiteID==	2021120028
replace SiteName = "NANA BILKISU MATERNITY" if SiteID==	2021120029
replace SiteName = "KATSINA SPECIALIST HOSP." if SiteID==	2021120030
replace SiteName = "OKMOS Clin" if SiteID==	2021120031
replace SiteName = "TUNDUN YAN'LIHIDDA MCH" if SiteID==	2021110032
replace SiteName = "KOFAR GUGA MCHC" if SiteID==	2021110033
replace SiteName = "FMC KTN" if SiteID==	2021310034
replace SiteName = "NASARAWA DAY Clin" if SiteID==	2021110035
replace SiteName = "WAKILIN AREWA HC" if SiteID==	2021110036
replace SiteName = "SHINKAFI MCH" if SiteID==	2021110037
replace SiteName = "DAN-NABASO MCH" if SiteID==	2021110038
replace SiteName = "KWADO MCH" if SiteID==	2021110039
replace SiteName = "BAKURU HC" if SiteID==	2021110040
replace SiteName = "MODOJI HC" if SiteID==	2021110041
replace SiteName = "AIRPORT Clin" if SiteID==	2021110042
replace SiteName = "ARMY BARRACK HC" if SiteID==	2021110043
replace SiteName = "BARKIYA PHC" if SiteID==	2022110001
replace SiteName = "YAR'LIYAU HC" if SiteID==	2022110002
replace SiteName = "YAR MARKE HC" if SiteID==	2022110003
replace SiteName = "YAR MALGA HC" if SiteID==	2022110004
replace SiteName = "BIRCHI HC" if SiteID==	2022110005
replace SiteName = "CHEDIYA HC" if SiteID==	2022110006
replace SiteName = "K/YAMM HC" if SiteID==	2022110007
replace SiteName = "KAGUWA HC" if SiteID==	2022110008
replace SiteName = "GEN HOSPKURFI" if SiteID==	2022210009
replace SiteName = "YARRANDA HC" if SiteID==	2022110010
replace SiteName = "MUJI HC" if SiteID==	2022110011
replace SiteName = "K/DAN-AMARYA HC" if SiteID==	2022110012
replace SiteName = "TAMAWA HC" if SiteID==	2022110013
replace SiteName = "SAUYAWA HC" if SiteID==	2022110014
replace SiteName = "FADUMAWA HC" if SiteID==	2022110015
replace SiteName = "RAWAYAU PHC" if SiteID==	2022110016
replace SiteName = "M/KARYA HC" if SiteID==	2022110017
replace SiteName = "DAN GAWO HC" if SiteID==	2022110018
replace SiteName = "S/GARI HC" if SiteID==	2022110019
replace SiteName = "YAR UNGUWA HC" if SiteID==	2022110020
replace SiteName = "TSAURI PHC" if SiteID==	2022110021
replace SiteName = "KATOGE HC" if SiteID==	2022110022
replace SiteName = "AGAMA LAFIYA HC" if SiteID==	2022110023
replace SiteName = "BAMBADAWA HC" if SiteID==	2022110024
replace SiteName = "KAWARE HC" if SiteID==	2022110025
replace SiteName = "GWANZO HC" if SiteID==	2022110026
replace SiteName = "DAN AGALI HC" if SiteID==	2022110027
replace SiteName = "WURMA" if SiteID==	2022110028
replace SiteName = "GATARAWA HC" if SiteID==	2022110029
replace SiteName = "KUDEWA HC" if SiteID==	2022110030
replace SiteName = "TAMU HC" if SiteID==	2022110031
replace SiteName = "F/DUTSI HC" if SiteID==	2022110032
replace SiteName = "FANDOGARI HC" if SiteID==	2022110033
replace SiteName = "BIRINYA HC" if SiteID==	2022110034
replace SiteName = "CHIKAWA HC" if SiteID==	2022110035
replace SiteName = "KUSADA CHC" if SiteID==	2023110001
replace SiteName = "YASHE PHC" if SiteID==	2023110002
replace SiteName = "KAWARIN YASHE HC" if SiteID==	2023110003
replace SiteName = "GIDAN MUTUM DAYA MCH" if SiteID==	2023110004
replace SiteName = "JORI HC" if SiteID==	2023110005
replace SiteName = "MAGAMA HC" if SiteID==	2023110006
replace SiteName = "DUDUNNI HC" if SiteID==	2023110007
replace SiteName = "JORAKAWA HC" if SiteID==	2023110008
replace SiteName = "ZANGO HC" if SiteID==	2023110009
replace SiteName = "KOFA MCH" if SiteID==	2023110010
replace SiteName = "SABON RAFI HC" if SiteID==	2023110011
replace SiteName = "SABARU HC" if SiteID==	2023110012
replace SiteName = "KATOGE HC" if SiteID==	2023110013
replace SiteName = "KAGADAMA HC" if SiteID==	2023110014
replace SiteName = "TUFANI HC" if SiteID==	2023110015
replace SiteName = "BAURANYA MCH" if SiteID==	2023110016
replace SiteName = "MAIRANA HC" if SiteID==	2023110017
replace SiteName = "KAFARDA HC" if SiteID==	2023110018
replace SiteName = "MAIGAMAWA HC" if SiteID==	2023110019
replace SiteName = "MAWASHI MCH" if SiteID==	2023110020
replace SiteName = "YARDOKA HC" if SiteID==	2023110021
replace SiteName = "AGANTA FULANI HC" if SiteID==	2023110022
replace SiteName = "SABON GARI MCH" if SiteID==	2023110023
replace SiteName = "BOKO SIRE HC" if SiteID==	2023110024
replace SiteName = "YAN ZARO HC" if SiteID==	2023110025
replace SiteName = "RINGI MCH" if SiteID==	2023110026
replace SiteName = "KAIKAI HC" if SiteID==	2023110027
replace SiteName = "AGANTA "B" MCH" if SiteID==	2023110028
replace SiteName = "GUNSAWA MCH" if SiteID==	2023110029
replace SiteName = "MAI'ADUA CHC" if SiteID==	2024110001
replace SiteName = "MAI'ADUA HC" if SiteID==	2024110002
replace SiteName = "K/YAMMA HC" if SiteID==	2024110003
replace SiteName = "MULUDU HC" if SiteID==	2024110004
replace SiteName = "MAITURMI HC" if SiteID==	2024110005
replace SiteName = "DANKINDI HC" if SiteID==	2024110006
replace SiteName = "KWAGAU MCH" if SiteID==	2024110007
replace SiteName = "SHIROKA HC" if SiteID==	2024110008
replace SiteName = "GALADIMAWA HC" if SiteID==	2024110009
replace SiteName = "DAGURA HC" if SiteID==	2024110010
replace SiteName = "UNG. LABE HC" if SiteID==	2024110011
replace SiteName = "DABA HC" if SiteID==	2024110012
replace SiteName = "KOZA PHC" if SiteID==	2024110013
replace SiteName = "JASSAI HC" if SiteID==	2024110014
replace SiteName = "JIRDEDE HC" if SiteID==	2024110015
replace SiteName = "BULA HC" if SiteID==	2024110016
replace SiteName = "MADADDAGA HC" if SiteID==	2024110017
replace SiteName = "TOFAKAI HC" if SiteID==	2024110018
replace SiteName = "GWAJOGWAJO HC" if SiteID==	2024110019
replace SiteName = "YARYAUDI HC" if SiteID==	2024110020
replace SiteName = "SHARTA HC" if SiteID==	2024110021
replace SiteName = "MAIKOMI HC" if SiteID==	2024110022
replace SiteName = "TADI HC" if SiteID==	2024110023
replace SiteName = "HAUKAR ZANA HC" if SiteID==	2024110024
replace SiteName = "YANKARA HC" if SiteID==	2024110025
replace SiteName = "MAIGARI HC" if SiteID==	2024110026
replace SiteName = "YAYAYE HC" if SiteID==	2024110027
replace SiteName = "DANYASHE HC" if SiteID==	2024110028
replace SiteName = "DOGON HALSA HC" if SiteID==	2024110029
replace SiteName = "MISIRA HC" if SiteID==	2024110030
replace SiteName = "TSABU HC" if SiteID==	2024110031
replace SiteName = "TSIGA HC" if SiteID==	2024110032
replace SiteName = "MAIDARIYA HC" if SiteID==	2024110033
replace SiteName = "KWADAGE HC" if SiteID==	2024110034
replace SiteName = "BUMBUM MCH" if SiteID==	2024110035
replace SiteName = "SHEKIYAL MDG" if SiteID==	2024110036
replace SiteName = "ZANGON BORIN DAWA HC" if SiteID==	2025110001
replace SiteName = "SABON GARIN BORIN DAWA HC" if SiteID==	2025110002
replace SiteName = "ALLAH MADOGARA HC" if SiteID==	2025110003
replace SiteName = "DAYI CHC" if SiteID==	2025110004
replace SiteName = "BABBAN DUHU HC" if SiteID==	2025110005
replace SiteName = "ALMAKIYAYI HC" if SiteID==	2025110006
replace SiteName = "DANSARAI HC" if SiteID==	2025110007
replace SiteName = "ALJIYAWA HC" if SiteID==	2025110008
replace SiteName = "TUNKUDA HC" if SiteID==	2025110009
replace SiteName = "KARFI PHC" if SiteID==	2025110010
replace SiteName = "LAYIN MINISTA HC" if SiteID==	2025110011
replace SiteName = "GANDUN KARIFI HC" if SiteID==	2025110012
replace SiteName = "YARJEBA HC" if SiteID==	2025110013
replace SiteName = "GORAR DANSAKA PHC" if SiteID==	2025110014
replace SiteName = "GANGARA HC" if SiteID==	2025110015
replace SiteName = "LAMUNTANI HC" if SiteID==	2025110016
replace SiteName = "MAKAURACHI PHC" if SiteID==	2025110017
replace SiteName = "BADAWA MCH" if SiteID==	2025110018
replace SiteName = "JAKWALLAWA HC" if SiteID==	2025110019
replace SiteName = "MALUMFASHI MCH" if SiteID==	2025210020
replace SiteName = "LABO MAHUTA MEMORIAL Clin" if SiteID==	2025120021
replace SiteName = "ALBARKA Clin" if SiteID==	2025120022
replace SiteName = "DEOCEASE Clin" if SiteID==	2025120023
replace SiteName = "ALMAKIYAYI HC" if SiteID==	2025110024
replace SiteName = "GEN HOSPMLF" if SiteID==	2025210025
replace SiteName = "MALUMFASHI Clin" if SiteID==	2025120026
replace SiteName = "M. BALA HOSPITAL" if SiteID==	2025120027
replace SiteName = "DOWN Clin" if SiteID==	2025120028
replace SiteName = "ECWA Clin" if SiteID==	2025120029
replace SiteName = "T/DUKUMI Clin" if SiteID==	2025120030
replace SiteName = "NA'ALMA PHC" if SiteID==	2025110031
replace SiteName = "KARO HC" if SiteID==	2025110032
replace SiteName = "GARAN GOZAI HC" if SiteID==	2025110033
replace SiteName = "KWANDAWA HC" if SiteID==	2025110034
replace SiteName = "RUWAN SANYI PHC" if SiteID==	2025110035
replace SiteName = "AYAGA HC" if SiteID==	2025110036
replace SiteName = "KATANGA HC" if SiteID==	2025110037
replace SiteName = "UNG. ARI HC" if SiteID==	2025110038
replace SiteName = "YABA HC" if SiteID==	2025110039
replace SiteName = "MARMARA HC" if SiteID==	2025110040
replace SiteName = "MARARRABAR KANKARA HC" if SiteID==	2025110041
replace SiteName = "UNG. GAMBO HC" if SiteID==	2025110042
replace SiteName = "BURDUGAR HC" if SiteID==	2025110043
replace SiteName = "MAI FARIN KAI HC" if SiteID==	2025110044
replace SiteName = "YAMMAMA HC" if SiteID==	2025110045
replace SiteName = "GORA HC" if SiteID==	2025110046
replace SiteName = "GWANAMAUDE HC" if SiteID==	2025110047
replace SiteName = "GIDAN BABA HC" if SiteID==	2025110048
replace SiteName = "GEN HOSPMANI" if SiteID==	2026210001
replace SiteName = "MANI HC" if SiteID==	2026110002
replace SiteName = "KADARABE HC" if SiteID==	2026110003
replace SiteName = "GGSS MANI HC" if SiteID==	2026110004
replace SiteName = "MACHIKA HC" if SiteID==	2026110005
replace SiteName = "GALLAWA HC" if SiteID==	2026110006
replace SiteName = "ANIYAWA HC" if SiteID==	2026110007
replace SiteName = "JIDA'A HC" if SiteID==	2026110008
replace SiteName = "BAGIWA HC" if SiteID==	2026110009
replace SiteName = "DURU HC" if SiteID==	2026110010
replace SiteName = "NASARAWA HC" if SiteID==	2026110011
replace SiteName = "KWATTA MCH" if SiteID==	2026110012
replace SiteName = "GAWON MALA HC" if SiteID==	2026110013
replace SiteName = "KWALKODAU HC" if SiteID==	2026110014
replace SiteName = "GHARAMBI HC" if SiteID==	2026110015
replace SiteName = "JANI CHC" if SiteID==	2026110016
replace SiteName = "JANI MCH" if SiteID==	2026110017
replace SiteName = "SAMBAWA HC" if SiteID==	2026110018
replace SiteName = "KURNA HC" if SiteID==	2026110019
replace SiteName = "YARCHAKARANDE HC" if SiteID==	2026110020
replace SiteName = "MUDURU PHC" if SiteID==	2026110021
replace SiteName = "FADI GURJE HC" if SiteID==	2026110022
replace SiteName = "DAMAWA HC" if SiteID==	2026110023
replace SiteName = "KUKOKI HC" if SiteID==	2026110024
replace SiteName = "TSAGEM HC" if SiteID==	2026110025
replace SiteName = "BARYAWA HC" if SiteID==	2026110026
replace SiteName = "SHEME HC" if SiteID==	2026110027
replace SiteName = "SHA'ISKAWA HC" if SiteID==	2026110028
replace SiteName = "TAKUSHEYE HC" if SiteID==	2026110029
replace SiteName = "MAGAMI MCH" if SiteID==	2026110030
replace SiteName = "WALAWA HC" if SiteID==	2026110031
replace SiteName = "KURUNKUS HC" if SiteID==	2026110032
replace SiteName = "BAKANKARA HC" if SiteID==	2026110033
replace SiteName = "HAMCHETA MCH" if SiteID==	2026110034
replace SiteName = "ALIYABA MCH" if SiteID==	2026110035
replace SiteName = "SAMFA HC" if SiteID==	2026110036
replace SiteName = "BINONI HC" if SiteID==	2026110037
replace SiteName = "DUWAN MCH" if SiteID==	2026110038
replace SiteName = "MAKAU HC" if SiteID==	2026110039
replace SiteName = "GAMDA HC" if SiteID==	2026110040
replace SiteName = "MARKE HC" if SiteID==	2026110041
replace SiteName = "GABBY HC" if SiteID==	2026110042
replace SiteName = "BUJAWA PHC" if SiteID==	2026110043
replace SiteName = "RANDAWA MCH" if SiteID==	2026110044
replace SiteName = "GEWAYAU HC" if SiteID==	2026110045
replace SiteName = "KAFASU HC" if SiteID==	2026110046
replace SiteName = "ISUFAWA HC" if SiteID==	2026110047
replace SiteName = "KWANGAMA HC" if SiteID==	2026110048
replace SiteName = "TUSKULE HC" if SiteID==	2026110049
replace SiteName = "YAUMAWA HC" if SiteID==	2026110050
replace SiteName = "TAKAI HC" if SiteID==	2026110051
replace SiteName = "MASHI CHC" if SiteID==	2027110001
replace SiteName = "MASHI DESP." if SiteID==	2027110002
replace SiteName = "TORANKE DESP." if SiteID==	2027110003
replace SiteName = "CHIDAWA DESP." if SiteID==	2027110004
replace SiteName = "DOKAWA HC" if SiteID==	2027110005
replace SiteName = "YANRIGA MCH" if SiteID==	2027110006
replace SiteName = "GARO HC" if SiteID==	2027110007
replace SiteName = "TULUWA DESP." if SiteID==	2027110008
replace SiteName = "BULA DESP." if SiteID==	2027110009
replace SiteName = "JANA DISP." if SiteID==	2027110010
replace SiteName = "FILIN MANDA DESP." if SiteID==	2027110011
replace SiteName = "DOKA HC" if SiteID==	2027110012
replace SiteName = "TAMILO MCH" if SiteID==	2027110013
replace SiteName = "MORAYE DESP" if SiteID==	2027110014
replace SiteName = "GUMA DESP" if SiteID==	2027110015
replace SiteName = "RANDA MPHC" if SiteID==	2027110016
replace SiteName = "MANAWA CHC" if SiteID==	2027110017
replace SiteName = "KILAGO DESP" if SiteID==	2027110018
replace SiteName = "JIGAWA DESP" if SiteID==	2027110019
replace SiteName = "TSAMIYA LALU DESP" if SiteID==	2027110020
replace SiteName = "TAGURA DESP" if SiteID==	2027110021
replace SiteName = "BIRNIN KUKA PHC" if SiteID==	2027110022
replace SiteName = "KASANKI MCH" if SiteID==	2027110023
replace SiteName = "DAN DANA DESP" if SiteID==	2027110024
replace SiteName = "HAMIS DESP" if SiteID==	2027110025
replace SiteName = "KAMARAWA DESP" if SiteID==	2027110026
replace SiteName = "DOGURU MCH" if SiteID==	2027110027
replace SiteName = "BAGAWA DESP" if SiteID==	2027110028
replace SiteName = "BADAURI DESP" if SiteID==	2027110029
replace SiteName = "ISHESHE DESP" if SiteID==	2027110030
replace SiteName = "MARKE DESP" if SiteID==	2027110031
replace SiteName = "DANLAKO DESP" if SiteID==	2027110032
replace SiteName = "KINDIGI DESP" if SiteID==	2027110033
replace SiteName = "MAJIGIRI MCH" if SiteID==	2027110034
replace SiteName = "SABUWA MCHC" if SiteID==	2027110035
replace SiteName = "MAKERAWA DESP" if SiteID==	2027110036
replace SiteName = "SONKAYA MCH" if SiteID==	2027110037
replace SiteName = "YAR RABO DESP" if SiteID==	2027110038
replace SiteName = "KOTAI DESP" if SiteID==	2027110039
replace SiteName = "GALLU MCHC" if SiteID==	2027110040
replace SiteName = "AGALA DESP" if SiteID==	2027110041
replace SiteName = "GYARTA DESP" if SiteID==	2027110042
replace SiteName = "DISSI HC" if SiteID==	2028110001
replace SiteName = "DANBANGA HC" if SiteID==	2028110002
replace SiteName = "GWARJO" if SiteID==	2028110003
replace SiteName = "ILAL HC" if SiteID==	2028110004
replace SiteName = "JINFIN NAWALA HC" if SiteID==	2028110005
replace SiteName = "YAR UNGUWA HC" if SiteID==	2028110006
replace SiteName = "KARADUA HC" if SiteID==	2028110007
replace SiteName = "NASARAWA HC" if SiteID==	2028110008
replace SiteName = "KAGADAMA HC" if SiteID==	2028110009
replace SiteName = "KOGARI HC" if SiteID==	2028110010
replace SiteName = "TSAKUWA HC" if SiteID==	2028110011
replace SiteName = "UNGUWAR SARKA HC" if SiteID==	2028110012
replace SiteName = "DAURAWA HC" if SiteID==	2028110013
replace SiteName = "TABOBI HC" if SiteID==	2028110014
replace SiteName = "GINCHAWA HC" if SiteID==	2028110015
replace SiteName = "MATAZU CYHC" if SiteID==	2028110016
replace SiteName = "KUDU HC" if SiteID==	2028110017
replace SiteName = "KOFEN RUGA HC" if SiteID==	2028110018
replace SiteName = "PAPO HC" if SiteID==	2028110019
replace SiteName = "DUGUL HC" if SiteID==	2028110020
replace SiteName = "YALWA HC" if SiteID==	2028110021
replace SiteName = "MAZOJI MPHC" if SiteID==	2028110022
replace SiteName = "RINJIN IDI HC" if SiteID==	2028110023
replace SiteName = "SABON GARI HC" if SiteID==	2028110024
replace SiteName = "SAYAYA MPHC" if SiteID==	2028110025
replace SiteName = "SAURA HC" if SiteID==	2028110026
replace SiteName = "RADDAWA HC" if SiteID==	2028110027
replace SiteName = "BAKANE HC" if SiteID==	2028110028
replace SiteName = "KOGON MAIDAWA HC" if SiteID==	2028110029
replace SiteName = "KAWARI HC" if SiteID==	2028110030
replace SiteName = "MOBILE AMBULANCE" if SiteID==	2028110031
replace SiteName = "DANGANI PHC" if SiteID==	2029110001
replace SiteName = "SAKO HC" if SiteID==	2029110002
replace SiteName = "KATOGE HC" if SiteID==	2029110003
replace SiteName = "TURAWA HC" if SiteID==	2029110004
replace SiteName = "GIDAN DODO HC" if SiteID==	2029110005
replace SiteName = "BAKAM HC" if SiteID==	2029110006
replace SiteName = "ALHAZAWA HC" if SiteID==	2029110007
replace SiteName = "GARU MODEL" if SiteID==	2029110008
replace SiteName = "KUNTURYA HC" if SiteID==	2029110009
replace SiteName = "GANGARA HC" if SiteID==	2029110010
replace SiteName = "HADABA HC" if SiteID==	2029110011
replace SiteName = "TSUNTSAYE HC" if SiteID==	2029110012
replace SiteName = "GARUN SANYINA HC" if SiteID==	2029110013
replace SiteName = "DANJANKU PHC" if SiteID==	2029110014
replace SiteName = "GIDAN LUMO HC" if SiteID==	2029110015
replace SiteName = "BADAWA HC" if SiteID==	2029110016
replace SiteName = "DANKADO HC" if SiteID==	2029110017
replace SiteName = "KARACHI HC" if SiteID==	2029110018
replace SiteName = "SABON LAYI HC" if SiteID==	2029110019
replace SiteName = "MUNTA TSAUNI HC" if SiteID==	2029110020
replace SiteName = "KIRA HC" if SiteID==	2029110021
replace SiteName = "YARKANYA HC" if SiteID==	2029110022
replace SiteName = "DAURAWA HC" if SiteID==	2029110023
replace SiteName = "GANUWA HC" if SiteID==	2029110024
replace SiteName = "BURKUMI HC" if SiteID==	2029110025
replace SiteName = "GINGIN HC" if SiteID==	2029110026
replace SiteName = "JANGAU HC" if SiteID==	2029110027
replace SiteName = "KATSIRO HC" if SiteID==	2029110028
replace SiteName = "YARKIRGI HC" if SiteID==	2029110029
replace SiteName = "FAMPO HC" if SiteID==	2029110030
replace SiteName = "YARSANTA HC" if SiteID==	2029110031
replace SiteName = "JIKAMSHI PHC" if SiteID==	2029110032
replace SiteName = "ADUWA HC" if SiteID==	2029110033
replace SiteName = "KURKUJAN PHC" if SiteID==	2029110034
replace SiteName = "RIGAR FARI HC" if SiteID==	2029110035
replace SiteName = "BACHIRAWA HC" if SiteID==	2029110036
replace SiteName = "KOKANA HC" if SiteID==	2029110037
replace SiteName = "M/MUSAWA HC" if SiteID==	2029110038
replace SiteName = "YAR DANYA HC" if SiteID==	2029110039
replace SiteName = "FULALAWA HC" if SiteID==	2029110040
replace SiteName = "KAUYEN BANGO HC" if SiteID==	2029110041
replace SiteName = "GEN HOSP. MSW" if SiteID==	2029210042
replace SiteName = "FSC MSW HC" if SiteID==	2029110043
replace SiteName = "K/DANDAGO HC" if SiteID==	2029110044
replace SiteName = "BAKIN KASUWA HC" if SiteID==	2029110045
replace SiteName = "TSARIKA HC" if SiteID==	2029110046
replace SiteName = "KURU HC" if SiteID==	2029110047
replace SiteName = "TABANNI PHC" if SiteID==	2029110048
replace SiteName = "G/GORA HC" if SiteID==	2029110049
replace SiteName = "YAR RADAU HC" if SiteID==	2029110050
replace SiteName = "SABON GIDA HC" if SiteID==	2029110051
replace SiteName = "G/DUKKU HC" if SiteID==	2029110052
replace SiteName = "S/RINJI HC" if SiteID==	2029110053
replace SiteName = "R/MAIDABINO HC" if SiteID==	2029110054
replace SiteName = "TUGE PHC" if SiteID==	2029110055
replace SiteName = "KARO HC" if SiteID==	2029110056
replace SiteName = "TSABE HC" if SiteID==	2029110057
replace SiteName = "SALIHAWA HC" if SiteID==	2029110058
replace SiteName = "WALKI HC" if SiteID==	2029110059
replace SiteName = "RIMI MCH" if SiteID==	2030110001
replace SiteName = "GEN HOSPRIMI" if SiteID==	2030210002
replace SiteName = "ABUKUR MCH" if SiteID==	2030110003
replace SiteName = "TAFIDARAWA HC" if SiteID==	2030110004
replace SiteName = "SABON GARI HC" if SiteID==	2030110005
replace SiteName = "DAGORA HC" if SiteID==	2030110006
replace SiteName = "RENAWA HC" if SiteID==	2030110007
replace SiteName = "ALLARAINI HC" if SiteID==	2030110008
replace SiteName = "KADANDANI HC" if SiteID==	2030110009
replace SiteName = "ARE HC" if SiteID==	2030110010
replace SiteName = "JIKAMSHIN KADANDANI HC" if SiteID==	2030110011
replace SiteName = "MAJEN GOBIR HC" if SiteID==	2030110012
replace SiteName = "YAR KADIR HC" if SiteID==	2030110013
replace SiteName = "KARARE I HC" if SiteID==	2030110014
replace SiteName = "TSAGERO PHC" if SiteID==	2030110015
replace SiteName = "KANYA HC" if SiteID==	2030110016
replace SiteName = "TURAJI HC" if SiteID==	2030110017
replace SiteName = "FARDAMI HC" if SiteID==	2030110018
replace SiteName = "MAKWALLA HC" if SiteID==	2030110019
replace SiteName = "IYATAWA HC" if SiteID==	2030110020
replace SiteName = "REMAWA HC" if SiteID==	2030110021
replace SiteName = "DANMUSA HC" if SiteID==	2030110022
replace SiteName = "YAR NABAYYE HC" if SiteID==	2030110023
replace SiteName = "YAR GWAMNA HC" if SiteID==	2030110024
replace SiteName = "MAKURDA MCH" if SiteID==	2030110025
replace SiteName = "DABGANYA HC" if SiteID==	2030110026
replace SiteName = "SABUWA CHC" if SiteID==	2031110001
replace SiteName = "AWALA HC" if SiteID==	2031110002
replace SiteName = "MAZARE HC" if SiteID==	2031110003
replace SiteName = "SAUKI Clin" if SiteID==	2031120004
replace SiteName = "GAZARI HC" if SiteID==	2031110005
replace SiteName = "INONO HC" if SiteID==	2031110006
replace SiteName = "YARKAKA HC" if SiteID==	2031110007
replace SiteName = "JIGO HC" if SiteID==	2031110008
replace SiteName = "GAMJI PHC" if SiteID==	2031110009
replace SiteName = "KANAWA HC" if SiteID==	2031110010
replace SiteName = "UNG. MAIGAYYA PHC" if SiteID==	2031110011
replace SiteName = "ALBASU HC" if SiteID==	2031110012
replace SiteName = "GOBIRAWA HC" if SiteID==	2031110013
replace SiteName = "DAMARI PHC" if SiteID==	2031110014
replace SiteName = "GULANGE HC" if SiteID==	2031110015
replace SiteName = "HAYIN TABO HC" if SiteID==	2031110016
replace SiteName = "HAYIN KASUWA HC" if SiteID==	2031110017
replace SiteName = "ISYAWARE HC" if SiteID==	2031110018
replace SiteName = "MACHIKA MPHC" if SiteID==	2031110019
replace SiteName = "BARKISHI HC" if SiteID==	2031110020
replace SiteName = "MAIGANGUMA HC" if SiteID==	2031110021
replace SiteName = "YARKINDA HC" if SiteID==	2031110022
replace SiteName = "UNGUWAR RIMI HC" if SiteID==	2031110023
replace SiteName = "MARABAR KINJI HC" if SiteID==	2031110024
replace SiteName = "DOGON MU'AZU PHC" if SiteID==	2031110025
replace SiteName = "DANKOLO HC" if SiteID==	2031110026
replace SiteName = "UNG. SARKI NOMA HC" if SiteID==	2031110027
replace SiteName = "SAYAU PHC" if SiteID==	2031110028
replace SiteName = "DANKURMI HC" if SiteID==	2031110029
replace SiteName = "TAURA HC" if SiteID==	2031110030
replace SiteName = "UNG. NAKABAHC" if SiteID==	2031110031
replace SiteName = "RAFIN-IWA HC" if SiteID==	2031110032
replace SiteName = "BANDAGA HC" if SiteID==	2031110033
replace SiteName = "LABI HC" if SiteID==	2031110034
replace SiteName = "MAICHARI HC" if SiteID==	2031110035
replace SiteName = "UNG. A. TUKUR HC" if SiteID==	2031110036
replace SiteName = "MAIBAKKO HC" if SiteID==	2031110037
replace SiteName = "UNG. BAKO HC" if SiteID==	2031110038
replace SiteName = "UNG. SANI HC" if SiteID==	2031110039
replace SiteName = "HAYIN ISAU HC" if SiteID==	2031110040
replace SiteName = "YAR LAGWADA HC" if SiteID==	2031110041
replace SiteName = "BABBAN DUHU MPHC" if SiteID==	2032110001
replace SiteName = "BAREBARI HC" if SiteID==	2032110002
replace SiteName = "KUKAR RABO HC" if SiteID==	2032110003
replace SiteName = "KUKAR SAMU PHC" if SiteID==	2032110004
replace SiteName = "KIRTAWA HC" if SiteID==	2032110005
replace SiteName = "MUNIYA HC" if SiteID==	2032110006
replace SiteName = "BAURE MPHC" if SiteID==	2032110007
replace SiteName = "SALIHAWAR KALGO HC" if SiteID==	2032110008
replace SiteName = "DANJIKKO HC" if SiteID==	2032110009
replace SiteName = "GARIN WAZIRI HC" if SiteID==	2032110010
replace SiteName = "MARINA HC" if SiteID==	2032110011
replace SiteName = "ILLELA HC" if SiteID==	2032110012
replace SiteName = "DAGWARWA HC" if SiteID==	2032110013
replace SiteName = "RUNKA MPHC" if SiteID==	2032110014
replace SiteName = "KUNKUNNA HC" if SiteID==	2032110015
replace SiteName = "GUZURAWA HC" if SiteID==	2032110016
replace SiteName = "YARLILO MPHC " if SiteID==	2032110017
replace SiteName = "GORA II PHC" if SiteID==	2032110018
replace SiteName = "GARIN MAGAJI HC" if SiteID==	2032110019
replace SiteName = "MAKANWACHI HC" if SiteID==	2032110020
replace SiteName = "MAIKADA HC" if SiteID==	2032110021
replace SiteName = "SAFANA CHC" if SiteID==	2032110022
replace SiteName = "KUNAMAWA HC" if SiteID==	2032110023
replace SiteName = "SAFANA PHC" if SiteID==	2032110024
replace SiteName = "SAFANA FSPC" if SiteID==	2032110025
replace SiteName = "TSASKIYA MPHC" if SiteID==	2032110026
replace SiteName = "DAGARAWA HC" if SiteID==	2032110027
replace SiteName = "MAMMANDO HC" if SiteID==	2032110028
replace SiteName = "TUDUN DOLE HC" if SiteID==	2032110029
replace SiteName = "ZAKKA PHC" if SiteID==	2032110030
replace SiteName = "UMMADAU HC" if SiteID==	2032110031
replace SiteName = "KWAYAWA HC" if SiteID==	2032110032
replace SiteName = "DAN ZAKI HC" if SiteID==	2032110033
replace SiteName = "DAN AWO HC" if SiteID==	2032110034
replace SiteName = "KAUYEN TSAMIYA HC" if SiteID==	2032110035
replace SiteName = "R/TSAMIYA MCHC" if SiteID==	2033110001
replace SiteName = "JARKUKA HC" if SiteID==	2033110002
replace SiteName = "BABATAWA HC" if SiteID==	2033110003
replace SiteName = "R/TSAMIYA NORTH" if SiteID==	2033110004
replace SiteName = "RUMA HC" if SiteID==	2033110005
replace SiteName = "MAJIYAWA HC" if SiteID==	2033110006
replace SiteName = "KACIKA HC" if SiteID==	2033110007
replace SiteName = "WALAWA HC" if SiteID==	2033110008
replace SiteName = "FAGO MCHC" if SiteID==	2033110009
replace SiteName = "YAKAWADA HC" if SiteID==	2033110010
replace SiteName = "FAGON FULANI HC" if SiteID==	2033110011
replace SiteName = "ZUGAI MCHC" if SiteID==	2033110012
replace SiteName = "GAZORI HC" if SiteID==	2033110013
replace SiteName = "S/GARIN SHAGAN HC" if SiteID==	2033110014
replace SiteName = "KAIBAKI HC" if SiteID==	2033110015
replace SiteName = "GUMZU HC" if SiteID==	2033110016
replace SiteName = "KAGARE GARI HC" if SiteID==	2033110017
replace SiteName = "KAGAREN FULANI HC" if SiteID==	2033110018
replace SiteName = "KAWARI HC" if SiteID==	2033110019
replace SiteName = "KARKARKU HC" if SiteID==	2033110020
replace SiteName = "MAYE HC" if SiteID==	2033110021
replace SiteName = "KATSAYAL MCHC" if SiteID==	2033110022
replace SiteName = "KATSAYAL NORTH HC" if SiteID==	2033110023
replace SiteName = "KWASARAWA MCHC" if SiteID==	2033110024
replace SiteName = "DANGAU HC" if SiteID==	2033110025
replace SiteName = "INGAWA HC" if SiteID==	2033110026
replace SiteName = "YANMANUWA HC" if SiteID==	2033110027
replace SiteName = "LEMO HC" if SiteID==	2033110028
replace SiteName = "RADE HC" if SiteID==	2033110029
replace SiteName = "KYARU HC" if SiteID==	2033110030
replace SiteName = "GUNDU HC" if SiteID==	2033110031
replace SiteName = "R/DUTSI HC" if SiteID==	2033110032
replace SiteName = "JIBA HC" if SiteID==	2033110033
replace SiteName = "S/GARIN BURTA HC" if SiteID==	2033110034
replace SiteName = "MAKAURACI HC" if SiteID==	2033110035
replace SiteName = "GARGARAWA HC" if SiteID==	2033110036
replace SiteName = "SANDAMU CHC" if SiteID==	2033110037
replace SiteName = "LUGGA HC" if SiteID==	2033110038
replace SiteName = "JAMBAGI HC" if SiteID==	2033110039
replace SiteName = "MOBILE HC" if SiteID==	2033110040
replace SiteName = "ZANGO CHC" if SiteID==	2034110001
replace SiteName = "ZANGO MPHC" if SiteID==	2034110002
replace SiteName = "K/KUDU HC" if SiteID==	2034110003
replace SiteName = "FANTEKA HC" if SiteID==	2034110004
replace SiteName = "DARGAGE MCHC " if SiteID==	2034110005
replace SiteName = "ISHIYAWA HC" if SiteID==	2034110006
replace SiteName = "ADUWAWA HC" if SiteID==	2034110007
replace SiteName = "BARAGE HC" if SiteID==	2034110008
replace SiteName = "FIWUNI HC" if SiteID==	2034110009
replace SiteName = "GARNI MCHC" if SiteID==	2034110010
replace SiteName = "MADAKA HC" if SiteID==	2034110011
replace SiteName = "MAKIYA HC" if SiteID==	2034110012
replace SiteName = "BADAKE HC" if SiteID==	2034110013
replace SiteName = "DAWAN MALAN HC" if SiteID==	2034110014
replace SiteName = "GWAMBA MCHC" if SiteID==	2034110015
replace SiteName = "UNG. DUMA MCHC" if SiteID==	2034110016
replace SiteName = "GARBA HC" if SiteID==	2034110017
replace SiteName = "ROGOGO HC" if SiteID==	2034110018
replace SiteName = "ROGOGO CHIDARI HC" if SiteID==	2034110019
replace SiteName = "UNG. GAJE HC" if SiteID==	2034110020
replace SiteName = "SARA MCHC" if SiteID==	2034110021
replace SiteName = "RAHAMAWA HC" if SiteID==	2034110022
replace SiteName = "K/KUDI MCHC" if SiteID==	2034110023
replace SiteName = "BUGAJE HC" if SiteID==	2034110024
replace SiteName = "KYAUKYAWA HC" if SiteID==	2034110025
replace SiteName = "K/MALAMAI HC" if SiteID==	2034110026
replace SiteName = "BIDAWA HC" if SiteID==	2034110027
replace SiteName = "BIDAWA FULANI HC" if SiteID==	2034110028
replace SiteName = "KANDA MCHC" if SiteID==	2034110029
replace SiteName = "KUTUTURE HC" if SiteID==	2034110030
replace SiteName = "YARDAJE MCHC" if SiteID==	2034110031
replace SiteName = "DISHE HC" if SiteID==	2034110032

* Kebbi State
replace SiteName = "Kofar D/Galadima" if SiteID==	2101110001
replace SiteName = "G/Dari " if SiteID==	2101110002
replace SiteName = "Sadam " if SiteID==	2101110003
replace SiteName = "G. Hosp. Aliero" if SiteID==	2101210004
replace SiteName = "Danwarai" if SiteID==	2101110005
replace SiteName = "Jiga Birni" if SiteID==	2101110006
replace SiteName = "Jiga Sala" if SiteID==	2101110007
replace SiteName = "Kizama" if SiteID==	2101110008
replace SiteName = "U/Galadima" if SiteID==	2101110009
replace SiteName = "Sabiyel" if SiteID==	2101110010
replace SiteName = "Dakala" if SiteID==	2101110011
replace SiteName = "University Clinic" if SiteID==	2101110012
replace SiteName = "Gumbulu" if SiteID==	2101110013
replace SiteName = "Dorawai" if SiteID==	2101110014
replace SiteName = "Bachaka" if SiteID==	2102110001
replace SiteName = "Jarkuka" if SiteID==	2102110002
replace SiteName = "Bui" if SiteID==	2102110003
replace SiteName = "Gigane " if SiteID==	2102110004
replace SiteName = "Marake" if SiteID==	2102110005
replace SiteName = "Kohobi" if SiteID==	2102110006
replace SiteName = "Falde" if SiteID==	2102110007
replace SiteName = "Gamza " if SiteID==	2102110008
replace SiteName = "Faske Tudu" if SiteID==	2102110009
replace SiteName = "Gorin Dikko" if SiteID==	2102110010
replace SiteName = "Sabaru" if SiteID==	2102110011
replace SiteName = "Gumundai" if SiteID==	2102110012
replace SiteName = "Rafin Tsaka" if SiteID==	2102110013
replace SiteName = "Town Disp." if SiteID==	2102110014
replace SiteName = "RHC Kangiwa" if SiteID==	2102110015
replace SiteName = "Leima" if SiteID==	2102110016
replace SiteName = "Karen Jantullu" if SiteID==	2102110017
replace SiteName = "Sarka" if SiteID==	2102110018
replace SiteName = "Gurun Labbo" if SiteID==	2102110019
replace SiteName = "Yeldu " if SiteID==	2102110020
replace SiteName = "Matunkari" if SiteID==	2102110021
replace SiteName = "Alwasa" if SiteID==	2103110001
replace SiteName = "Dabire" if SiteID==	2103110002
replace SiteName = "Argungu Town PHC" if SiteID==	2103110003
replace SiteName = "G.Hosp. Arg." if SiteID==	2103210004
replace SiteName = "Gulma" if SiteID==	2103110005
replace SiteName = "Gulma Town " if SiteID==	2103110006
replace SiteName = "F/Sarki" if SiteID==	2103110007
replace SiteName = "Gijiya" if SiteID==	2103110008
replace SiteName = "S/Kanta" if SiteID==	2103110009
replace SiteName = "MCH" if SiteID==	2103110010
replace SiteName = "NRC" if SiteID==	2103110011
replace SiteName = "K/Arewa" if SiteID==	2103110012
replace SiteName = "K/Zabarma" if SiteID==	2103110013
replace SiteName = "Gaskiya Clinic Arg." if SiteID==	2103110014
replace SiteName = "Sauwa" if SiteID==	2103110015
replace SiteName = "K/Sani" if SiteID==	2103110016
replace SiteName = "T/Zazzagawa" if SiteID==	2103110017
replace SiteName = "Rumbiki" if SiteID==	2103110018
replace SiteName = "Augie PHC" if SiteID==	2104110001
replace SiteName = "Bagaye HF" if SiteID==	2104110002
replace SiteName = "Mera HF" if SiteID==	2104110003
replace SiteName = "Bayawa HF" if SiteID==	2104110004
replace SiteName = "Dafashi HF" if SiteID==	2104110005
replace SiteName = "Jabaki HF" if SiteID==	2104110006
replace SiteName = "Sabla HF" if SiteID==	2104110007
replace SiteName = "B/Tudu HF" if SiteID==	2104110008
replace SiteName = "Gudale HF" if SiteID==	2104110009
replace SiteName = "Bubuche HF" if SiteID==	2104110010
replace SiteName = "Bangaram HF" if SiteID==	2104110011
replace SiteName = "Kwaido HF" if SiteID==	2104110012
replace SiteName = "Zagie HF" if SiteID==	2104110013
replace SiteName = "Tiggi HF" if SiteID==	2104110014
replace SiteName = "F/Dutse" if SiteID==	2104110015
replace SiteName = "Yola HF" if SiteID==	2104110016
replace SiteName = "Garic HF" if SiteID==	2104110017
replace SiteName = "MCH Bagudo" if SiteID==	2105110001
replace SiteName = "Tuga Disp." if SiteID==	2105110002
replace SiteName = "PHC Kaliel" if SiteID==	2105110003
replace SiteName = "Bahindi Disp." if SiteID==	2105110004
replace SiteName = "Bani Disp." if SiteID==	2105110005
replace SiteName = "Tsamiya Disp." if SiteID==	2105110006
replace SiteName = "Illo Town Disp." if SiteID==	2105110007
replace SiteName = "S/Gari Illo Disp." if SiteID==	2105110008
replace SiteName = "PHC Kaoje" if SiteID==	2105110009
replace SiteName = "Bakin Ruwa Disp" if SiteID==	2105110010
replace SiteName = "Kende Disp." if SiteID==	2105110011
replace SiteName = "Lani Disp." if SiteID==	2105110012
replace SiteName = "Shorabi Disp." if SiteID==	2105110013
replace SiteName = "Maidahini Disp." if SiteID==	2105110014
replace SiteName = "BHC Lolo" if SiteID==	2105110015
replace SiteName = "Kasati Disp." if SiteID==	2105110016
replace SiteName = "T-Lawal Disp." if SiteID==	2105110017
replace SiteName = "Lafagu Disp." if SiteID==	2105110018
replace SiteName = "Matsinkai Disp." if SiteID==	2105110019
replace SiteName = "Geza Disp." if SiteID==	2105110020
replace SiteName = "PHC Zagga" if SiteID==	2105110021
replace SiteName = "Mado Disp." if SiteID==	2105110022
replace SiteName = "Ambusa " if SiteID==	2106110001
replace SiteName = "Illelar-Yari" if SiteID==	2106110002
replace SiteName = "Gamagira" if SiteID==	2106110003
replace SiteName = "Gawasu" if SiteID==	2106110004
replace SiteName = "Damana" if SiteID==	2106110005
replace SiteName = "Gulumbe" if SiteID==	2106110006
replace SiteName = "Gwadangaji" if SiteID==	2106110007
replace SiteName = "Kawara" if SiteID==	2106110008
replace SiteName = "Kola" if SiteID==	2106110009
replace SiteName = "Tarasa" if SiteID==	2106110010
replace SiteName = "Kardi " if SiteID==	2106110011
replace SiteName = "Matankari" if SiteID==	2106110012
replace SiteName = "Lagga" if SiteID==	2106110013
replace SiteName = "Randali" if SiteID==	2106110014
replace SiteName = "Makera" if SiteID==	2106110015
replace SiteName = "Danyaku" if SiteID==	2106110016
replace SiteName = "Takalau" if SiteID==	2106110017
replace SiteName = "Mourida" if SiteID==	2106110018
replace SiteName = "Karyo" if SiteID==	2106110019
replace SiteName = "B/Tasha" if SiteID==	2106110020
replace SiteName = "Sir Yahaya Mem. Hospital " if SiteID==	2106210021
replace SiteName = "Godiya Hospital " if SiteID==	2106220022
replace SiteName = "Alpha Clinic" if SiteID==	2106220023
replace SiteName = "Major Foundation Clinic" if SiteID==	2106220024
replace SiteName = "Federal Medical Centre" if SiteID==	2106310025
replace SiteName = "Army Barracks Clinic" if SiteID==	2106110026
replace SiteName = "Ujariya" if SiteID==	2106110027
replace SiteName = "Junju" if SiteID==	2106110028
replace SiteName = "Zauro" if SiteID==	2106110029
replace SiteName = "G/Hosp. Zauro" if SiteID==	2106210030
replace SiteName = "Bunza G.Hosp." if SiteID==	2107210001
replace SiteName = "Waje" if SiteID==	2107110002
replace SiteName = "Bulu" if SiteID==	2107110003
replace SiteName = "S/GAri" if SiteID==	2107110004
replace SiteName = "Gwade" if SiteID==	2107110005
replace SiteName = "Bacha" if SiteID==	2107110006
replace SiteName = "Maidahini" if SiteID==	2107110007
replace SiteName = "Garadi" if SiteID==	2107110008
replace SiteName = "Raha" if SiteID==	2107110009
replace SiteName = "Matseri" if SiteID==	2107110010
replace SiteName = "Salwani" if SiteID==	2107110011
replace SiteName = "S/Birni Disp." if SiteID==	2107110012
replace SiteName = "Lolo Disp." if SiteID==	2107110013
replace SiteName = "Tunga Disp." if SiteID==	2107110014
replace SiteName = "Kahibile Disp." if SiteID==	2107110015
replace SiteName = "Hilema Disp." if SiteID==	2107110016
replace SiteName = "Tilli Ugo Disp." if SiteID==	2107110017
replace SiteName = "Zogirma Disp." if SiteID==	2107110018
replace SiteName = "Tsamiya Disp." if SiteID==	2107110019
replace SiteName = "Buma" if SiteID==	2108110001
replace SiteName = "Tunga Rafi" if SiteID==	2108110002
replace SiteName = "Bani Zumbu" if SiteID==	2108110003
replace SiteName = "Wasali " if SiteID==	2108110004
replace SiteName = "Dolekaina " if SiteID==	2108110005
replace SiteName = "Tunga Sule" if SiteID==	2108110006
replace SiteName = "Gezah " if SiteID==	2108110007
replace SiteName = "Belin Zunbai" if SiteID==	2108110008
replace SiteName = "Fana" if SiteID==	2108110009
replace SiteName = "Maidaji" if SiteID==	2108110010
replace SiteName = "Kyangakwai" if SiteID==	2108110011
replace SiteName = "Fingilla" if SiteID==	2108110012
replace SiteName = "Kwakwaba" if SiteID==	2108110013
replace SiteName = "Kamba MCH" if SiteID==	2108110014
replace SiteName = "Maigwaza" if SiteID==	2108110015
replace SiteName = "Shiko" if SiteID==	2108110016
replace SiteName = "Gorun Malam" if SiteID==	2108110017
replace SiteName = "Taimako Clinic" if SiteID==	2108220018
replace SiteName = "Yemko Clinic" if SiteID==	2108220019
replace SiteName = "Ayu" if SiteID==	2109110001
replace SiteName = "Sakawa" if SiteID==	2109110002
replace SiteName = "Bena" if SiteID==	2109110003
replace SiteName = "Malekaci" if SiteID==	2109110004
replace SiteName = "Nawake Clinic " if SiteID==	2109220005
replace SiteName = "Dan-Umaru" if SiteID==	2109110006
replace SiteName = "Mai Rairai" if SiteID==	2109110007
replace SiteName = "Danko" if SiteID==	2109110008
replace SiteName = "Maga" if SiteID==	2109110009
replace SiteName = "Kele" if SiteID==	2109110010
replace SiteName = "Kariya" if SiteID==	2109110011
replace SiteName = "Kango" if SiteID==	2109110012
replace SiteName = "Kuntomo" if SiteID==	2109110013
replace SiteName = "Caisome" if SiteID==	2109110014
replace SiteName = "Machika" if SiteID==	2109110015
replace SiteName = "MCH Ribah" if SiteID==	2109110016
replace SiteName = "Unashi" if SiteID==	2109110017
replace SiteName = "Yarkuka" if SiteID==	2109110018
replace SiteName = "Wasagu" if SiteID==	2109110019
replace SiteName = "G/Hospital" if SiteID==	2109210020
replace SiteName = "Kunjiri Med. Clinic" if SiteID==	2109220021
replace SiteName = "Koliko" if SiteID==	2109110022
replace SiteName = "Maga" if SiteID==	2109110023
replace SiteName = "Nasara Hosp." if SiteID==	2109220024
replace SiteName = "Bajida PHC" if SiteID==	2110110001
replace SiteName = "Kukum PHC" if SiteID==	2110110002
replace SiteName = "Bangu PHC" if SiteID==	2110110003
replace SiteName = "Garin Isah PHC" if SiteID==	2110110004
replace SiteName = "Matseri PHC" if SiteID==	2110110005
replace SiteName = "Uchiri PHC" if SiteID==	2110110006
replace SiteName = "Fakai Disp." if SiteID==	2110110007
replace SiteName = "Kuka PHC" if SiteID==	2110110008
replace SiteName = "Gulbin Kuka PHC" if SiteID==	2110110009
replace SiteName = "Maijahula PHC" if SiteID==	2110110010
replace SiteName = "Kangi PHC" if SiteID==	2110110011
replace SiteName = "Gobiraje PHC" if SiteID==	2110110012
replace SiteName = "Mahuta MPHC" if SiteID==	2110110013
replace SiteName = "GGSS Clinic" if SiteID==	2110110014
replace SiteName = "Garin Awal PHC" if SiteID==	2110110015
replace SiteName = "Bulu Shipkau " if SiteID==	2110110016
replace SiteName = "Marafa PHC" if SiteID==	2110110017
replace SiteName = "Dan Indo PHC" if SiteID==	2110110018
replace SiteName = "Yoko PHC" if SiteID==	2110110019
replace SiteName = "Farin Ruwa PHC" if SiteID==	2110110020
replace SiteName = "Cheberu HF" if SiteID==	2111110001
replace SiteName = "Waworin Magaji" if SiteID==	2111110002
replace SiteName = "Dalijan B/Sule HF" if SiteID==	2111110003
replace SiteName = "Dodoru T.Yole " if SiteID==	2111110004
replace SiteName = "Wanon Centre " if SiteID==	2111110005
replace SiteName = "Gulmare/Tari HF" if SiteID==	2111110006
replace SiteName = "Kambaza" if SiteID==	2111110007
replace SiteName = "Malisa/Gora/ Kwatted" if SiteID==	2111110008
replace SiteName = "N/Goma/Gumbai" if SiteID==	2111110009
replace SiteName = "Masama/ Kwasagara" if SiteID==	2111110010
replace SiteName = "RHC" if SiteID== 2111110011

replace SiteName = 	"Gwandu Gen Hosp"	if SiteID==	2111210012
replace SiteName = "MDG Wadako" 		if SiteID==	2109110025
replace SiteName = "PHC Kyaku" 			if SiteID==	2109110026
replace SiteName = "Gen Hosp Bena" 		if SiteID==	2109210027
replace SiteName = "Gen Hosp Ribah" 	if SiteID==	2109210028
replace SiteName = "Gen Hosp Kamba" 	if SiteID==	2108210020
replace SiteName = "Gen Hosp Bagudo" 	if SiteID==	2105210023
replace SiteName = "Lailaba PHC" 		if SiteID==	2103110019
replace SiteName = "Amagoro MDG" 		if SiteID==	2102110022
replace SiteName = "MCH Kangiwa" 		if SiteID==	2102110023
replace SiteName = "Makera Gandu" 		if SiteID==	2106110031
replace SiteName = "Jega Gen Hosp"		if SiteID==	2112210004

replace SiteName = "B/Yari" if SiteID==	2112110001
replace SiteName = "Binyari HF" if SiteID==	2112110002
replace SiteName = "T/Wada" if SiteID==	2112110003
replace SiteName = "Dangomaji " if SiteID==	2112110005
replace SiteName = "U/Madi" if SiteID==	2112110006
replace SiteName = "Katanga" if SiteID==	2112110007
replace SiteName = "Fagada" if SiteID==	2112110008
replace SiteName = "Dunbegu " if SiteID==	2112110009
replace SiteName = "Basaura " if SiteID==	2112110010
replace SiteName = "Ginidi" if SiteID==	2112110011
replace SiteName = "Kyarmi" if SiteID==	2112110012
replace SiteName = "Alelu" if SiteID==	2112110013
replace SiteName = "Gehiru" if SiteID==	2112110014
replace SiteName = "Kimba" if SiteID==	2112110015
replace SiteName = "Ingarje" if SiteID==	2112110016
replace SiteName = "Jandutsi" if SiteID==	2112110017
replace SiteName = "Agwada" if SiteID==	2112110018
replace SiteName = "Dangoma Disp." if SiteID==	2113110001
replace SiteName = "Gayi Disp." if SiteID==	2113110002
replace SiteName = "Diggi Disp." if SiteID==	2113110003
replace SiteName = "Keta Disp" if SiteID==	2113110004
replace SiteName = "Gangare" if SiteID==	2113110005
replace SiteName = "Magarza Disp." if SiteID==	2113110006
replace SiteName = "Biri" if SiteID==	2113110007
replace SiteName = "Kalgo MCH" if SiteID==	2113110008
replace SiteName = "Ung. Dikko Disp." if SiteID==	2113110009
replace SiteName = "Kukah Disp." if SiteID==	2113110010
replace SiteName = "Kukani Disp." if SiteID==	2113110011
replace SiteName = "Mutubari" if SiteID==	2113110012
replace SiteName = "Banganna" if SiteID==	2113110013
replace SiteName = "Sandare" if SiteID==	2113110014
replace SiteName = "Unguwar Rafi" if SiteID==	2113110015
replace SiteName = "Wurogauri" if SiteID==	2113110016
replace SiteName = "Zuguru" if SiteID==	2113110017
replace SiteName = "PHC Besse" if SiteID==	2114110001
replace SiteName = "T/Bude" if SiteID==	2114110002
replace SiteName = "Dutsin Mari" if SiteID==	2114110003
replace SiteName = "Dulmeru" if SiteID==	2114110004
replace SiteName = "Takware" if SiteID==	2114110005
replace SiteName = "T/Magaji" if SiteID==	2114110006
replace SiteName = "K/Damba" if SiteID==	2114110007
replace SiteName = "Maikwari" if SiteID==	2114110008
replace SiteName = "Hirini" if SiteID==	2114110009
replace SiteName = "Madacci" if SiteID==	2114110010
replace SiteName = "Koko Disp." if SiteID==	2114110011
replace SiteName = "G.Hosp." if SiteID==	2114210012
replace SiteName = "Lani Disp." if SiteID==	2114110013
replace SiteName = "M/Tafikain" if SiteID==	2114110014
replace SiteName = "Jadadi" if SiteID==	2114110015
replace SiteName = "D/Niki" if SiteID==	2114110016
replace SiteName = "Dada" if SiteID==	2114110017
replace SiteName = "Alelu" if SiteID==	2114110018
replace SiteName = "T/Dodo" if SiteID==	2114110019
replace SiteName = "Zaria" if SiteID==	2114110020
replace SiteName = "Koko Clinic, Koko" if SiteID==	2114220021
replace SiteName = "Andarai" if SiteID==	2115110001
replace SiteName = "Kikudu" if SiteID==	2115110002
replace SiteName = "Gidiga " if SiteID==	2115110003
replace SiteName = "Kuberi" if SiteID==	2115110004
replace SiteName = "Kawara" if SiteID==	2115110005
replace SiteName = "R/Fibi" if SiteID==	2115110006
replace SiteName = "Giwa Tazo" if SiteID==	2115110007
replace SiteName = "Zara" if SiteID==	2115110008
replace SiteName = "G/Kure" if SiteID==	2115110009
replace SiteName = "Gamjeji" if SiteID==	2115110010
replace SiteName = "Karaye" if SiteID==	2115110011
replace SiteName = "D/Daji" if SiteID==	2115110012
replace SiteName = "Liba" if SiteID==	2115110013
replace SiteName = "D/Kowa" if SiteID==	2115110014
replace SiteName = "Sambawa" if SiteID==	2115110015
replace SiteName = "Mayolo" if SiteID==	2115110016
replace SiteName = "Mungadi" if SiteID==	2115110017
replace SiteName = "Batoro" if SiteID==	2115110018
replace SiteName = "Maiyama MCH" if SiteID==	2115110019
replace SiteName = "G/Hospital " if SiteID==	2115210020
replace SiteName = "Sauki Clinic Maiyama" if SiteID==	2115220021
replace SiteName = "S/Dosa" if SiteID==	2115110022
replace SiteName = "Gubba" if SiteID==	2115110023
replace SiteName = "Wara MCH" if SiteID==	2116110001
replace SiteName = "G.Hosp. Wara" if SiteID==	2116210002
replace SiteName = "Hamdola Clinic " if SiteID==	2116220003
replace SiteName = "Libata " if SiteID==	2116110004
replace SiteName = "Lokon – Udoh " if SiteID==	2116110005
replace SiteName = "Chupamini" if SiteID==	2116110006
replace SiteName = "Gungun-Kwano" if SiteID==	2116110007
replace SiteName = "Gidan Kwano " if SiteID==	2116110008
replace SiteName = "Natade" if SiteID==	2116110009
replace SiteName = "Ngaski" if SiteID==	2116110010
replace SiteName = "Kinkya " if SiteID==	2116110011
replace SiteName = "Utono " if SiteID==	2116110012
replace SiteName = "Gungun Hoge" if SiteID==	2116110013
replace SiteName = "Uleira" if SiteID==	2116110014
replace SiteName = "Magubuti " if SiteID==	2116110015
replace SiteName = "Rikate" if SiteID==	2116110016
replace SiteName = "Makirin" if SiteID==	2116110017
replace SiteName = "B/Yauri" if SiteID==	2116110018
replace SiteName = "Maikaho" if SiteID==	2116210019
replace SiteName = "Kambawa" if SiteID==	2116110020
replace SiteName = "Dan-Maraya" if SiteID==	2116110021
replace SiteName = "Maganda" if SiteID==	2117110001
replace SiteName = "Pampam" if SiteID==	2117110002
replace SiteName = "Dankolo" if SiteID==	2117110003
replace SiteName = "Daura" if SiteID==	2117110004
replace SiteName = "H/Hausawa" if SiteID==	2117110005
replace SiteName = "T/Shibo" if SiteID==	2117110006
replace SiteName = "Dirin Daji" if SiteID==	2117110007
replace SiteName = "G.Hosp." if SiteID==	2117210008
replace SiteName = "Gelwasa " if SiteID==	2117110009
replace SiteName = "Jan Birni " if SiteID==	2117110010
replace SiteName = "Laraba" if SiteID==	2117110011
replace SiteName = "Makuku" if SiteID==	2117110012
replace SiteName = "D/Kambari" if SiteID==	2117110013
replace SiteName = "Maza Maza" if SiteID==	2117110014
replace SiteName = "Siloka" if SiteID==	2117110015
replace SiteName = "Sakaba " if SiteID==	2117110016
replace SiteName = "Mazurka" if SiteID==	2117110017
replace SiteName = "Rijau" if SiteID==	2117110018
replace SiteName = "Atuwo" if SiteID==	2118110001
replace SiteName = "Kyastu" if SiteID==	2118110002
replace SiteName = "D/Tsoho" if SiteID==	2118110003
replace SiteName = "D/Raha" if SiteID==	2118110004
replace SiteName = "Gebbe " if SiteID==	2118110005
replace SiteName = "Shabanda" if SiteID==	2118110006
replace SiteName = "Kawara" if SiteID==	2118110007
replace SiteName = "Sango " if SiteID==	2118110008
replace SiteName = "R/Kirya" if SiteID==	2118110009
replace SiteName = "T/Tara" if SiteID==	2118110010
replace SiteName = "Sakace" if SiteID==	2118110011
replace SiteName = "Hondeji" if SiteID==	2118110012
replace SiteName = "Sawashi" if SiteID==	2118110013
replace SiteName = "G/Masa" if SiteID==	2118110014
replace SiteName = "Shanga" if SiteID==	2118110015
replace SiteName = "Saminaka" if SiteID==	2118110016
replace SiteName = "Takware" if SiteID==	2118110017
replace SiteName = "T/Giwa" if SiteID==	2118110018
replace SiteName = "Yar Besse" if SiteID==	2118110019
replace SiteName = "Aljanare" if SiteID==	2119110001
replace SiteName = "Tunga Alhaji" if SiteID==	2119110002
replace SiteName = "Bakuwai PHC" if SiteID==	2119110003
replace SiteName = "Kwokware" if SiteID==	2119110004
replace SiteName = "Banda" if SiteID==	2119110005
replace SiteName = "Zakuwa " if SiteID==	2119110006
replace SiteName = "Barbarajo" if SiteID==	2119110007
replace SiteName = "T/Arawa" if SiteID==	2119110008
replace SiteName = "Dakin Gari PHC" if SiteID==	2119110009
replace SiteName = "Bendu" if SiteID==	2119110010
replace SiteName = "Maikuri" if SiteID==	2119110011
replace SiteName = "Hore" if SiteID==	2119110012
replace SiteName = "Sangelu " if SiteID==	2119110013
replace SiteName = "Giro PHC" if SiteID==	2119110014
replace SiteName = "Fala" if SiteID==	2119110015
replace SiteName = "Kwaifa " if SiteID==	2119110016
replace SiteName = "Dandawa " if SiteID==	2119110017
replace SiteName = "Shema" if SiteID==	2119110018
replace SiteName = "Daniya" if SiteID==	2119110019
replace SiteName = "Suru PHC" if SiteID==	2119110020
replace SiteName = "Kawara" if SiteID==	2119110021
replace SiteName = "Gumbi Disp." if SiteID==	2120110001
replace SiteName = "Hinanbiro" if SiteID==	2120110002
replace SiteName = "T/Maishagali" if SiteID==	2120110003
replace SiteName = "Jijima Disp." if SiteID==	2120110004
replace SiteName = "T/Illo Disp." if SiteID==	2120110005
replace SiteName = "T/Gada Disp." if SiteID==	2120110006
replace SiteName = "Town Disp." if SiteID==	2120110007
replace SiteName = "T/Bindiga" if SiteID==	2120110008
replace SiteName = "MCH" if SiteID==	2120110009
replace SiteName = "G. Hosp." if SiteID==	2120210010
replace SiteName = "Nakowa Clinic" if SiteID==	2120220011
replace SiteName = "Yelwa Hosp. Clini" if SiteID==	2120220012
replace SiteName = "Royal Hosp. Clinic" if SiteID==	2120220013
replace SiteName = "Illela Royal Clinic " if SiteID==	2120120014
replace SiteName = "Zamare" if SiteID==	2120120015
replace SiteName = "U/Damisa " if SiteID==	2120120016
replace SiteName = "Bedi" if SiteID==	2121110001
replace SiteName = "Domo ‘B’" if SiteID==	2121110002
replace SiteName = "Dabai" if SiteID==	2121110003
replace SiteName = "Kwendo " if SiteID==	2121110004
replace SiteName = "Usimoh " if SiteID==	2121110005
replace SiteName = "Isgogo" if SiteID==	2121110006
replace SiteName = "Dago " if SiteID==	2121110007
replace SiteName = "Amanawa" if SiteID==	2121110008
replace SiteName = "Alembalu" if SiteID==	2121110009
replace SiteName = "MCH" if SiteID==	2121110010
replace SiteName = "ANC" if SiteID==	2121110011
replace SiteName = "Gen. Hosp. Zuru" if SiteID==	2121210012
replace SiteName = "Hankuri Clinic" if SiteID==	2121120013
replace SiteName = "Godiya Clinics" if SiteID==	2121220014
replace SiteName = "Faith Clinic Zuru" if SiteID==	2121120015
replace SiteName = "Rikoto" if SiteID==	2121110016
replace SiteName = "Zuru Med. Clinics" if SiteID==	2121220017
replace SiteName = "Senchi G. Hosp." if SiteID==	2121210018
replace SiteName = "Bahago" if SiteID==	2121110019
replace SiteName = "Tadurga" if SiteID==	2121110020
replace SiteName = "Maikoho" if SiteID==	2121110021
replace SiteName = "Zodi " if SiteID==	2121110022
replace SiteName = "Rafin Hinta " if SiteID==	2121110023


* Sokoto - 33
replace SiteName = "Binji Up-Graded Disp"	if SiteID==	3301110001
replace SiteName = "Gen Hosp Binji"		if SiteID==	3301210002
replace SiteName = "Birni wari Disp"			if SiteID==	3301110003
replace SiteName = "Kalgo Disp"				if SiteID==	3301110004
replace SiteName = "Karani Disp"				if SiteID==	3301110005
replace SiteName = "Kura Up-Graded Disp"		if SiteID==	3301110006
replace SiteName = "Dalijam Disp"			if SiteID==	3301110007
replace SiteName = "Jamali Disp"				if SiteID==	3301110008
replace SiteName = "Jamali Tsohuwa Disp"		if SiteID==	3301110009
replace SiteName = "Danmali Disp"			if SiteID==	3301110010
replace SiteName = "Model PHC Bunkari"				if SiteID==	3301110011
replace SiteName = "Fako Disp"				if SiteID==	3301110012
replace SiteName = "Kandiza Disp"			if SiteID==	3301110013
replace SiteName = "Gwahitto Disp"			if SiteID==	3301110014
replace SiteName = "Soro Disp"			if SiteID==	3301110015
replace SiteName = "Tumuni Disp"			if SiteID==	3301110016
replace SiteName = "Gawazai Disp"		if SiteID==	3301110017
replace SiteName = "Matabare Disp"		if SiteID==	3301110018
replace SiteName = "Yardewu Disp"		if SiteID==	3301110019
replace SiteName = "Ginjo Disp"			if SiteID==	3301110020
replace SiteName = "Inname Disp"			if SiteID==	3301110021
replace SiteName = "Kunkurwa Disp"		if SiteID==	3301110022
replace SiteName = "Maikulki Up-Graded Disp"		if SiteID==	3301110023
replace SiteName = "Margai Disp"			if SiteID==	3301110024
replace SiteName = "Samama Disp"			if SiteID==	3301110025
replace SiteName = "Tudun Kose Disp"		if SiteID==	3301110026
replace SiteName = "Gidan Maidebe Disp"		if SiteID==	3301110027
replace SiteName = "Twaidi Dikko Disp"	if SiteID==	3301110028
replace SiteName = "Twaidi Zaidi Disp"	if SiteID==	3301110029
replace SiteName = "Abdulsalami Disp"	if SiteID==	3302110001
replace SiteName = "Lukuyaw Disp"		if SiteID==	3302110002
replace SiteName = "Sifawa Disp"		if SiteID==	3302110003
replace SiteName = "Badau Disp"		if SiteID==	3302110004
replace SiteName = "Darhela Up-Graded Disp"	if SiteID==	3302110005
replace SiteName = "Badawa Disp"		if SiteID==	3302110006
replace SiteName = "Bagarawa Disp"	if SiteID==	3302110007
replace SiteName = "PHC Bagarawa"			if SiteID==	3302110008
replace SiteName = "Zangalawa Disp"	if SiteID==	3302110009
replace SiteName = "Bangi Disp"	if SiteID==	3302110010
replace SiteName = "Dabaga Dsipensary"	if SiteID==	3302110011
replace SiteName = "Tulluwa Disp"	if SiteID==	3302110012
replace SiteName = "Wumumu Disp"	if SiteID==	3302110013
replace SiteName = "Dan Ajwa Disp"	if SiteID==	3302110014
replace SiteName = "K/Wwasau"					if SiteID==	3302110015
replace SiteName = "Dingyadi Up-Graded Disp"	if SiteID==	3302110016
replace SiteName = "PHC Dingyadi"	if SiteID==	3302110017
replace SiteName = "Gidan Kijo Disp"	if SiteID==	3302110018
replace SiteName = "Gen Hosp Bodinga"	if SiteID==	3302210019
replace SiteName = "Town Disp Bodinga"	if SiteID==	3302110020
replace SiteName = "Gidan Tsara Disp"	if SiteID==	3302110021
replace SiteName = "Kaura Buba Disp"	if SiteID==	3302110022
replace SiteName = "Jabe Disp"	if SiteID==	3302110023
replace SiteName = "Jirga Dsipensary"	if SiteID==	3302110024
replace SiteName = "Kaurarmangala Disp"	if SiteID==	3302110025
replace SiteName = "Mazangari Disp"	if SiteID==	3302110026
replace SiteName = "Modorawa Disp"	if SiteID==	3302110027
replace SiteName = "Takatuku Disp"	if SiteID==	3302110028
replace SiteName = "PHC Danchadi"	if SiteID==	3302110029
replace SiteName = "Town Disp Danchadi"	if SiteID==	3302110030
replace SiteName = "1 Battalion Military Hosp"	if SiteID==	3303210001
replace SiteName = "Shuni Disp"	if SiteID==	3303110002
replace SiteName = "Amanawa Lep/General Hosp"	if SiteID==	3303210003
replace SiteName = "Rudu Disp"	if SiteID==	3303110004
replace SiteName = "Basic HC Amanawa"	if SiteID==	3303110005
replace SiteName = "Bodai Kaura Disp"	if SiteID==	3303110006
replace SiteName = "Bodai Sajo Disp"	if SiteID==	3303110007
replace SiteName = "Danbuwa Disp"	if SiteID==	3303110008
replace SiteName = "Tsefe Disp"	if SiteID==	3303110009
replace SiteName = "Tuntube Disp"	if SiteID==	3303110010
replace SiteName = "Kwanawa Disp"	if SiteID==	3303110011
replace SiteName = "Dange Up-Graded Disp"	if SiteID==	3303110012
replace SiteName = "Model PHC Dange"	if SiteID==	3303110013
replace SiteName = "Marina Disp"	if SiteID==	3303110014
replace SiteName = "Fajaldu Disp"	if SiteID==	3303110015
replace SiteName = "Dabagin Ardo Up-Graded Disp"	if SiteID==	3303110016
replace SiteName = "Gajara Disp"	if SiteID==	3303110017
replace SiteName = "Ge-Ere Disp"	if SiteID==	3303110018
replace SiteName = "Wababe Disp"	if SiteID==	3303110019
replace SiteName = "Rikina Disp"	if SiteID==	3303110020
replace SiteName = "Ruggar Dudu Disp"	if SiteID==	3303110021
replace SiteName = "Laffi Disp"	if SiteID==	3303110022
replace SiteName = "Staff CLIN Rima"	if SiteID==	3303110023
replace SiteName = "Tsafanade Disp"	if SiteID==	3303110024
replace SiteName = "Alibawa Community Disp"	if SiteID==	3304110001
replace SiteName = "Gidan Gyado Com Disp"	if SiteID==	3304110002
replace SiteName = "PHC Kaffe"	if SiteID==	3304110003
replace SiteName = "Gen Hosp Gada"	if SiteID==	3304210004
replace SiteName = "Baredi Community Disp"	if SiteID==	3304110005
replace SiteName = "Gidan Madugu Comm Disp"	if SiteID==	3304110006
replace SiteName = "Town Disp Gada"	if SiteID==	3304110007
replace SiteName = "Dagindi Disp"	if SiteID==	3304110008
replace SiteName = "Kaddi Up-Graded Disp"	if SiteID==	3304110009
replace SiteName = "PHC Kadadi"	if SiteID==	3304110010
replace SiteName = "Inga boro Disp"	if SiteID==	3304110011
replace SiteName = "Kadadi Disp"	if SiteID==	3304110012
replace SiteName = "Sagera Disp"	if SiteID==	3304110013
replace SiteName = "Gadabo Disp"	if SiteID==	3304110014
replace SiteName = "Gidan Hashimu Disp"	if SiteID==	3304110015
replace SiteName = "Tsitse Disp"	if SiteID==	3304110016
replace SiteName = "Gidan Albakari Disp"	if SiteID==	3304110017
replace SiteName = "Illah Disp"	if SiteID==	3304110018
replace SiteName = "PHC Dukamaje"	if SiteID==	3304110019
replace SiteName = "Rabamawa Disp"	if SiteID==	3304110020
replace SiteName = "Tsagal gale Disp"	if SiteID==	3304110021
replace SiteName = "Gidan Amamata Disp"	if SiteID==	3304110022
replace SiteName = "Holai Disp"	if SiteID==	3304110023
replace SiteName = "Kyadawa Disp"	if SiteID==	3304110024
replace SiteName = "PHC Wauru"	if SiteID==	3304110025
replace SiteName = "Safiyal Disp"	if SiteID==	3304110026
replace SiteName = "Gidan Dabo Disp"	if SiteID==	3304110027
replace SiteName = "Kiri Disp"	if SiteID==	3304110028
replace SiteName = "Gilbadi Disp"	if SiteID==	3304110029
replace SiteName = "Tsaro Disp"	if SiteID==	3304110030
replace SiteName = "Kadassaka Disp"	if SiteID==	3304110031
replace SiteName = "Tudun Bulus Disp"	if SiteID==	3304110032
replace SiteName = "Kwarma Disp"	if SiteID==	3304110033
replace SiteName = "Rafin Duma Disp"	if SiteID==	3304110034
replace SiteName = "Tufai Baba Disp"	if SiteID==	3304110035
replace SiteName = "Takalmawa Community Disp"	if SiteID==	3304110036
replace SiteName = "Sabon Gida Disp"	if SiteID==	3304110037
replace SiteName = "Bare Disp"	if SiteID==	3305110001
replace SiteName = "Darbabiya Disp"	if SiteID==	3305110002
replace SiteName = "Kojiyo Disp"	if SiteID==	3305110003
replace SiteName = "Birjingo Disp"	if SiteID==	3305110004
replace SiteName = "Gidan Mata Disp"	if SiteID==	3305110005
replace SiteName = "Ganza Disp"	if SiteID==	3305110006
replace SiteName = "Boyekai Disp"	if SiteID==	3305110007
replace SiteName = "Gamiha Kawara Disp"	if SiteID==	3305110008
replace SiteName = "Dantasakko Dsipensary"	if SiteID==	3305110009
replace SiteName = "Danwaru Disp"	if SiteID==	3305110010
replace SiteName = "Kamitau Disp"	if SiteID==	3305110011
replace SiteName = "Sabon  Gari Dole Disp"	if SiteID==	3305110012
replace SiteName = "Kubutta Disp"	if SiteID==	3305110013
replace SiteName = "T/G Dole Disp"	if SiteID==	3305110014
replace SiteName = "Facilaya Dsipensary"	if SiteID==	3305110015
replace SiteName = "Kaikazzaka Dsipensary"	if SiteID==	3305110016
replace SiteName = "Rimawa Disp"	if SiteID==	3305110017
replace SiteName = "Fadarawa Disp"	if SiteID==	3305110018
replace SiteName = "Gidan Barau Disp"	if SiteID==	3305110019
replace SiteName = "Kwakwazo Disp"	if SiteID==	3305110020
replace SiteName = "Miyal Yako Disp"	if SiteID==	3305110021
replace SiteName = "Giyawa Disp"	if SiteID==	3305110022
replace SiteName = "Gorau Disp"	if SiteID==	3305110023
replace SiteName = "Takakume Disp"	if SiteID==	3305110024
replace SiteName = "Kagara Disp"	if SiteID==	3305110025
replace SiteName = "Illela Dawagari Disp"	if SiteID==	3305110026
replace SiteName = "PHC Goronyo"	if SiteID==	3305110027
replace SiteName = "Taloka Disp"	if SiteID==	3305110028
replace SiteName = "Illela Huda Disp"	if SiteID==	3305110029
replace SiteName = "PHC Shinaka"	if SiteID==	3305110030
replace SiteName = "Tuluske Disp"	if SiteID==	3305110031
replace SiteName = "Zamace Dsipensary"	if SiteID==	3305110032
replace SiteName = "Zamace Dsipensary"	if SiteID==	3305110033
replace SiteName = "Bachaka Disp"	if SiteID==	3306110001
replace SiteName = "Salewa Disp"	if SiteID==	3306110002
replace SiteName = "Boto Disp"	if SiteID==	3306110003
replace SiteName = "Yaka Disp"	if SiteID==	3306110004
replace SiteName = "Chilas Disp"	if SiteID==	3306110005
replace SiteName = "Dangadabro Disp"	if SiteID==	3306110006
replace SiteName = "Makuya Dispenary"	if SiteID==	3306110007
replace SiteName = "Bungel Disp"	if SiteID==	3306110008
replace SiteName = "Karfen Chana Disp"	if SiteID==	3306110009
replace SiteName = "Katsura Disp"	if SiteID==	3306110010
replace SiteName = "PHC Kurdula"	if SiteID==	3306110011
replace SiteName = "Darusa Gawo Disp"	if SiteID==	3306110012
replace SiteName = "Bare-bari Disp"	if SiteID==	3306110013
replace SiteName = "Kukoki Disp"	if SiteID==	3306110014
replace SiteName = "Jima-Jimi Disp"	if SiteID==	3306110015
replace SiteName = "Marake Disp"	if SiteID==	3306110016
replace SiteName = "PHC Balle"	if SiteID==	3306110017
replace SiteName = "Rafin kubu Disp"	if SiteID==	3306110018
replace SiteName = "PHC Karfen Sarki"	if SiteID==	3306110019
replace SiteName = "Filasko Disp"	if SiteID==	3306110020
replace SiteName = "Tullun-Doya Disp"	if SiteID==	3306110021
replace SiteName = "Illela Disp"	if SiteID==	3306110022
replace SiteName = "Asara Disp"	if SiteID==	3307110001
replace SiteName = "Rumbuje Disp"	if SiteID==	3307110002
replace SiteName = "Tungar Tudu Biga Disp"	if SiteID==	3307110003
replace SiteName = "Attakwanyo Disp"	if SiteID==	3307110004
replace SiteName = "Burdi Disp"	if SiteID==	3307110005
replace SiteName = "Kangiye Disp"	if SiteID==	3307110006
replace SiteName = "Katalla Disp"	if SiteID==	3307110007
replace SiteName = "Chimmola Disp"	if SiteID==	3307110008
replace SiteName = "Kwankwanbilo Disp"	if SiteID==	3307110009
replace SiteName = "Kiliya Disp"	if SiteID==	3307110010
replace SiteName = "Dan Abba Disp"	if SiteID==	3307110011
replace SiteName = "Salame Disp"	if SiteID==	3307110012
replace SiteName = "Galadanchi Disp"	if SiteID==	3307110013
replace SiteName = "Gidan Dogaza Dipsensary"	if SiteID==	3307110014
replace SiteName = "Gidan kaya Disp"	if SiteID==	3307110015
replace SiteName = "Gwara Disp"	if SiteID==	3307110016
replace SiteName = "Kililawa Disp"	if SiteID==	3307110017
replace SiteName = "Yar Gada Disp"	if SiteID==	3307110018
replace SiteName = "Gigane Up-Graded Disp"	if SiteID==	3307110019
replace SiteName = "Meli Disp"	if SiteID==	3307110020
replace SiteName = "Sakamaru Disp"	if SiteID==	3307110021
replace SiteName = "Tunkura Disp"	if SiteID==	3307110022
replace SiteName = "Huchi Disp"	if SiteID==	3307110023
replace SiteName = "Fadan Kai Dsipensary"	if SiteID==	3307110024
replace SiteName = "Makina Disp"	if SiteID==	3307110025
replace SiteName = "Mamman Suka Disp"	if SiteID==	3307110026
replace SiteName = "Chancha Disppensary "	if SiteID==	3307110027
replace SiteName = "Ranganda Disp"	if SiteID==	3307110028
replace SiteName = "RHC Gwadabawa"	if SiteID==	3307110029
replace SiteName = "Tudun Doki Disp"	if SiteID==	3307110030
replace SiteName = "Tambagarka Disp"	if SiteID==	3307110031
replace SiteName = "Kalaba Dsiepnsary"	if SiteID==	3307110032
replace SiteName = "Wadai Disp"	if SiteID==	3307110033
replace SiteName = "Bamana Disp"	if SiteID==	3307110034
replace SiteName = "Mammande Disp"	if SiteID==	3307110035
replace SiteName = "Zugana Disp"	if SiteID==	3307110036
replace SiteName = "Amarawa Disp"	if SiteID==	3308110001
replace SiteName = "Aminchi Nursing Home"	if SiteID==	3308110002
replace SiteName = "Daboe CLIN & MAT"	if SiteID==	3308110003
replace SiteName = "Gen Hosp Illela"	if SiteID==	3308210004
replace SiteName = "Nasiha CLIN"	if SiteID==	3308210005
replace SiteName = "Sonane Disp"	if SiteID==	3308110006
replace SiteName = "Staff CLIN"	if SiteID==	3308110007
replace SiteName = "Town Dsipensary"	if SiteID==	3308110008
replace SiteName = "Tudun Gudale Disp"	if SiteID==	3308110009
replace SiteName = "Araba Up-Graded Disp"	if SiteID==	3308110010
replace SiteName = "Bakin Dutsi Disp"	if SiteID==	3308110011
replace SiteName = "Dan Boka Disp"	if SiteID==	3308110012
replace SiteName = "Dango Disp"	if SiteID==	3308110013
replace SiteName = "Basanta Disp"	if SiteID==	3308110014
replace SiteName = "Gaidau Disp"	if SiteID==	3308110015
replace SiteName = "Gidan katta Up-Graded Disp"	if SiteID==	3308110016
replace SiteName = "Buwade Disp"	if SiteID==	3308110017
replace SiteName = "Damba Up-Graded Disp"	if SiteID==	3308110018
replace SiteName = "Gudun Gudun Disp"	if SiteID==	3308110019
replace SiteName = "Tarke Disp"	if SiteID==	3308110020
replace SiteName = "Tsauna Disp"	if SiteID==	3308110021
replace SiteName = "Tumbulumkum Disp"	if SiteID==	3308110022
replace SiteName = "Darna Kiliya Disp"	if SiteID==	3308110023
replace SiteName = "Darna Sabon Gari Disp"	if SiteID==	3308110024
replace SiteName = "Gidan Tudu Disp"	if SiteID==	3308110025
replace SiteName = "Mullela Disp"	if SiteID==	3308110026
replace SiteName = "Dabagin Tankari Disp"	if SiteID==	3308110027
replace SiteName = "Darna Tsolawa Disp"	if SiteID==	3308110028
replace SiteName = "Garu Up-Graded Disp"	if SiteID==	3308110029
replace SiteName = "Tsangalandam Disp"	if SiteID==	3308110030
replace SiteName = "Gidan bango Disp"	if SiteID==	3308110031
replace SiteName = "Tozai Disp"	if SiteID==	3308110032
replace SiteName = "Ambarura Up-Graded Disp"	if SiteID==	3308110033
replace SiteName = "Gidan Hamma Disp"	if SiteID==	3308110034
replace SiteName = "Here Disp"	if SiteID==	3308110035
replace SiteName = "Jagai Disp"	if SiteID==	3308110036
replace SiteName = "Jema Disp"	if SiteID==	3308110037
replace SiteName = "Kalmalo Disp"	if SiteID==	3308110038
replace SiteName = "Runji Disp"	if SiteID==	3308110039
replace SiteName = "Lafani Disp"	if SiteID==	3308110040
replace SiteName = "Gidan Chiwake Disp"	if SiteID==	3308110041
replace SiteName = "Rungumawar  Gatti  Disp"	if SiteID==	3308110042
replace SiteName = "Rungumawar  Jao Disp"	if SiteID==	3308110043
replace SiteName = "Harigawa Disp"	if SiteID==	3308110044
replace SiteName = "Adarawa Disp"	if SiteID==	3309110001
replace SiteName = "Chohi Disp"	if SiteID==	3309110002
replace SiteName = "Gamaroji Community Disp"	if SiteID==	3309110003
replace SiteName = "KaiKairu Disp"	if SiteID==	3309110004
replace SiteName = "Tidibali Disp"	if SiteID==	3309110005
replace SiteName = "Katanga Disp"	if SiteID==	3309110006
replace SiteName = "Dan Adamma Community Disp"	if SiteID==	3309110007
replace SiteName = "Satiru Up-graded Disp"	if SiteID==	3309110008
replace SiteName = "Tozai Disp"	if SiteID==	3309110009
replace SiteName = "Bargaja  Disp"	if SiteID==	3309110010
replace SiteName = "Danzanke Up-graded Disp"	if SiteID==	3309110011
replace SiteName = "Gazau Disp"	if SiteID==	3309110012
replace SiteName = "Kalage Community Disp"	if SiteID==	3309110013
replace SiteName = "Modachi Disp"	if SiteID==	3309110014
replace SiteName = "Dan Yada Disp"	if SiteID==	3309110015
replace SiteName = "Gari Ubandawaki Comm. Disp"	if SiteID==	3309110016
replace SiteName = "Tafkin Fili Up-graded Disp"	if SiteID==	3309110017
replace SiteName = "Yanfako Disp"	if SiteID==	3309110018
replace SiteName = "Gebe Upgraded Disp"	if SiteID==	3309110019
replace SiteName = "Manawa Disp"	if SiteID==	3309110020
replace SiteName = "Sabon Gari Dangwandi Community Disp"	if SiteID==	3309110021
replace SiteName = "Sabon Gari Kamarawa Disp"	if SiteID==	3309110022
replace SiteName = "PHC Bafarawa"	if SiteID==	3309110023
replace SiteName = "Suruddubu Disp"	if SiteID==	3309110024
replace SiteName = "General  HOSP Isa"	if SiteID==	3309210025
replace SiteName = "MCH  Isa"	if SiteID==	3309210026
replace SiteName = "Gidan Dikko Disp"	if SiteID==	3309110027
replace SiteName = "Girnashe Disp"	if SiteID==	3309110028
replace SiteName = "Tsabre Disp"	if SiteID==	3309110029
replace SiteName = "Gumal Up-graded Disp"	if SiteID==	3309110030
replace SiteName = "Shallah Disp"	if SiteID==	3309110031
replace SiteName = "Turba Disp"	if SiteID==	3309110032
replace SiteName = "Kaurar Mota Up-graded Disp"	if SiteID==	3309110033
replace SiteName = "Kwanar Isa  community Disp"	if SiteID==	3309110034
replace SiteName = "Tudunwada Up-graded Disp"	if SiteID==	3309110035
replace SiteName = "Fakku Up-Graded Disp"	if SiteID==	3310110001
replace SiteName = "Rara Disp"	if SiteID==	3310110002
replace SiteName = "Girkau Up-Graded Disp"	if SiteID==	3310110003
replace SiteName = "Jabga Disp"	if SiteID==	3310110004
replace SiteName = "Zugu Disp"	if SiteID==	3310110005
replace SiteName = "Jigawa Disp"	if SiteID==	3310110006
replace SiteName = "Sabon Birni Disp"	if SiteID==	3310110007
replace SiteName = "Sangi Disp"	if SiteID==	3310110008
replace SiteName = "Jigiri Disp"	if SiteID==	3310110009
replace SiteName = "Karma Disp"	if SiteID==	3310110010
replace SiteName = "Gadacce Disp"	if SiteID==	3310110011
replace SiteName = "Margai Disp"	if SiteID==	3310110012
replace SiteName = "Gen Hosp Kebbe"	if SiteID==	3310210013
replace SiteName = "Kebbe Up-Graded Disp"	if SiteID==	3310110014
replace SiteName = "Umbutu Disp"	if SiteID==	3310110015
replace SiteName = "Kuchi Up-Graded Disp"	if SiteID==	3310110016
replace SiteName = "PHC Kuchi"	if SiteID==	3310110017
replace SiteName = "Ungushi Disp"	if SiteID==	3310110018
replace SiteName = "Nasagudu Disp"	if SiteID==	3310110019
replace SiteName = "Kunduttu Disp"	if SiteID==	3310110020
replace SiteName = "Maikurfuna Disp "	if SiteID==	3310110021
replace SiteName = "Dukura Disp"	if SiteID==	3310110022
replace SiteName = "Sha Alwashi Disp"	if SiteID==	3310110023
replace SiteName = "Basansan community Disp"	if SiteID==	3311110001
replace SiteName = "Lemi Disp"	if SiteID==	3311110002
replace SiteName = "Comprehensive HC Kware"	if SiteID==	3311110003
replace SiteName = "Kalalawa Disp "	if SiteID==	3311110004
replace SiteName = "Kasgada Disp"	if SiteID==	3311110005
replace SiteName = "Durbawa Up-Graded Disp"	if SiteID==	3311110006
replace SiteName = "Federal Psychiatric HOSP"	if SiteID==	3311310007
replace SiteName = "PHC Kware"	if SiteID==	3311110008
replace SiteName = "Ruggar Liman Disp"	if SiteID==	3311110009
replace SiteName = "Runji Disp"	if SiteID==	3311110010
replace SiteName = "Federal Science School CLIN "	if SiteID==	3311110011
replace SiteName = "Gundunga  Disp"	if SiteID==	3311110012
replace SiteName = "Ihi Disp"	if SiteID==	3311110013
replace SiteName = "Model PHC Balkore"	if SiteID==	3311110014
replace SiteName = "T/Galadima Disp"	if SiteID==	3311110015
replace SiteName = "Gidan Maikara Disp"	if SiteID==	3311110016
replace SiteName = "Hamma Ali Up-Graded Disp"	if SiteID==	3311110017
replace SiteName = "Hausawa Disp"	if SiteID==	3311110018
replace SiteName = "Karandai Disp"	if SiteID==	3311110019
replace SiteName = "Marbawa Upgraded Disp"	if SiteID==	3311110020
replace SiteName = "Kabanga Disp"	if SiteID==	3311110021
replace SiteName = "Malamawa Adada Disp"	if SiteID==	3311110022
replace SiteName = "Mallamawa Yari Disp"	if SiteID==	3311110023
replace SiteName = "Tunga Disp"	if SiteID==	3311110024
replace SiteName = "Siri Jalo Disp"	if SiteID==	3311110025
replace SiteName = "Tsaki Community Disp"	if SiteID==	3311110026
replace SiteName = "Lambo Community Disp"	if SiteID==	3311110027
replace SiteName = "Wallakae Disp"	if SiteID==	3311110028
replace SiteName = "Zammau Disp"	if SiteID==	3311110029
replace SiteName = "PHC Gandi"	if SiteID==	3312110001
replace SiteName = "Alikiru Disp"	if SiteID==	3312110002
replace SiteName = "Dankarmawa Disp"	if SiteID==	3312110003
replace SiteName = "Angamba Disp"	if SiteID==	3312110004
replace SiteName = "Gidan Buwai Disp"	if SiteID==	3312110005
replace SiteName = "Gododdi Disp"	if SiteID==	3312110006
replace SiteName = "Kurya Disp"	if SiteID==	3312110007
replace SiteName = "Maikujera Disp"	if SiteID==	3312110008
replace SiteName = "Riji Disp"	if SiteID==	3312110009
replace SiteName = "Gidan Doka Disp"	if SiteID==	3312110010
replace SiteName = "Burmawa Disp"	if SiteID==	3312110011
replace SiteName = "Gawakuke Disp"	if SiteID==	3312110012
replace SiteName = "Tofa Disp"	if SiteID==	3312110013
replace SiteName = "Gen Hosp Rabah"	if SiteID==	3312210014
replace SiteName = "Town Disp Rabah"	if SiteID==	3312110015
replace SiteName = "PHC Rara"	if SiteID==	3312110016
replace SiteName = "Sabaru Disp"	if SiteID==	3312110017
replace SiteName = "Tursa Disp"	if SiteID==	3312110018
replace SiteName = "Tsamiya Disp"	if SiteID==	3312110019
replace SiteName = "Yartsakuwa Disp"	if SiteID==	3312110020
replace SiteName = "Badama Disp"	if SiteID==	3312110021
replace SiteName = "Dudu-Barade Disp"	if SiteID==	3312110022
replace SiteName = "Gidan Almajir Disp"	if SiteID==	3312110023
replace SiteName = "Gidan Dan'Ayya Disp"	if SiteID==	3312110024
replace SiteName = "Rawkwamni Disp"	if SiteID==	3312110025
replace SiteName = "Sabon Gari"	if SiteID==	3312110026
replace SiteName = "Tabanni Disp"	if SiteID==	3312110027
replace SiteName = "Warwanna Disp"	if SiteID==	3312110028
replace SiteName = "Bachaka Disp"	if SiteID==	3313110001
replace SiteName = "D/Kware Disp"	if SiteID==	3313110002
replace SiteName = "Gidan Umaru Disp"	if SiteID==	3313110003
replace SiteName = "Kalage Disp"	if SiteID==	3313110004
replace SiteName = "Kyara Disp "	if SiteID==	3313110005
replace SiteName = "T/Tsaba Disp"	if SiteID==	3313110006
replace SiteName = "Tara Disp"	if SiteID==	3313110007
replace SiteName = "Bambadawa Disp"	if SiteID==	3313110008
replace SiteName = "Burkusuma Disp"	if SiteID==	3313110009
replace SiteName = "Gangara Disp"	if SiteID==	3313110010
replace SiteName = "Dama Disp"	if SiteID==	3313110011
replace SiteName = "Dan Kura Disp"	if SiteID==	3313110012
replace SiteName = "Dabugi Disp"	if SiteID==	3313110013
replace SiteName = "Dakwaro Disp"	if SiteID==	3313110014
replace SiteName = "Kurawa Disp"	if SiteID==	3313110015
replace SiteName = "Dan Maliki Disp"	if SiteID==	3313110016
replace SiteName = "Kalgo Disp"	if SiteID==	3313110017
replace SiteName = "Teke Disp"	if SiteID==	3313110018
replace SiteName = "Dantudu Disp"	if SiteID==	3313110019
replace SiteName = "Lanjego Disp"	if SiteID==	3313110020
replace SiteName = "Lanjinge Disp"	if SiteID==	3313110021
replace SiteName = "Garin Gado Disp"	if SiteID==	3313110022
replace SiteName = "Gayya Dakwari Disp"	if SiteID==	3313110023
replace SiteName = "Kiratawa Disp"	if SiteID==	3313110024
replace SiteName = "Magarau Disp"	if SiteID==	3313110025
replace SiteName = "Mallamawa Disp"	if SiteID==	3313110026
replace SiteName = "Sangarawa Disp"	if SiteID==	3313110027
replace SiteName = "Ungwar Lalle Disp"	if SiteID==	3313110028
replace SiteName = "Yar Bulutu Disp"	if SiteID==	3313110029
replace SiteName = "Garin Idi Disp"	if SiteID==	3313110030
replace SiteName = "Kwatsal Disp"	if SiteID==	3313110031
replace SiteName = "Nasara CLIN Sabon Birni"	if SiteID==	3313110032
replace SiteName = "PHC Sabon Birni"	if SiteID==	3313110033
replace SiteName = "Son AllaHC"	if SiteID==	3313110034
replace SiteName = "Garin Abara Disp"	if SiteID==	3313110035
replace SiteName = "Gawo Disp"	if SiteID==	3313110036
replace SiteName = "Tsamaye Disp"	if SiteID==	3313110037
replace SiteName = "Labau Disp"	if SiteID==	3313110038
replace SiteName = "Magira Disp"	if SiteID==	3313110039
replace SiteName = "Model PHC Gatawa"	if SiteID==	3313110040
replace SiteName = "Makuwana Disp"	if SiteID==	3313110041
replace SiteName = "Aggur Disp"	if SiteID==	3314110001
replace SiteName = "Kajiji Up-Graded Disp"	if SiteID==	3314110002
replace SiteName = "Kesoje Disp"	if SiteID==	3314110003
replace SiteName = "Ruggar Disp"	if SiteID==	3314110004
replace SiteName = "Dan Baro Disp Horo"	if SiteID==	3314110005
replace SiteName = "Ginga Disp"	if SiteID==	3314110006
replace SiteName = "Model PHC Horo"	if SiteID==	3314110007
replace SiteName = "Dandin Mahe Up-Graded Disp"	if SiteID==	3314110008
replace SiteName = "Mabera Disp"	if SiteID==	3314110009
replace SiteName = "Ruggar Mallam Disp"	if SiteID==	3314110010
replace SiteName = "Darin Guru Disp"	if SiteID==	3314110011
replace SiteName = "Gidan Tudu Disp"	if SiteID==	3314110012
replace SiteName = "Tungar Barki Disp"	if SiteID==	3314110013
replace SiteName = "Gam-Gam Disp"	if SiteID==	3314110014
replace SiteName = "Doruwa Disp"	if SiteID==	3314110015
replace SiteName = "Jandutsi Disp"	if SiteID==	3314110016
replace SiteName = "Lambara Dsipensary"	if SiteID==	3314110017
replace SiteName = "Mandera Disp"	if SiteID==	3314110018
replace SiteName = "Jaredi Disp"	if SiteID==	3314110019
replace SiteName = "Bullan Yaki Disp"	if SiteID==	3314110020
replace SiteName = "Kalangu Disp"	if SiteID==	3314110021
replace SiteName = "PHC Sanyinnawal Disp"	if SiteID==	3314110022
replace SiteName = "Runji Kaka Disp"	if SiteID==	3314110023
replace SiteName = "Sullubawa Disp"	if SiteID==	3314110024
replace SiteName = "Kambama Up-Graded Disp"	if SiteID==	3314110025
replace SiteName = "PHC Shagari"	if SiteID==	3314110026
replace SiteName = "Wanke Disp"	if SiteID==	3314110027
replace SiteName = "Chofal Disp"	if SiteID==	3315110001
replace SiteName = "Gaukai Disp"	if SiteID==	3315110002
replace SiteName = "Dankala Dsipensary"	if SiteID==	3315110003
replace SiteName = "Kaya Disp"	if SiteID==	3315110004
replace SiteName = "Zarengo Disp"	if SiteID==	3315110005
replace SiteName = "PHC Gande"	if SiteID==	3315110006
replace SiteName = "G.Magaji Disp"	if SiteID==	3315110007
replace SiteName = "Male Disp"	if SiteID==	3315110008
replace SiteName = "Galadi Disp"	if SiteID==	3315110009
replace SiteName = "Kwagyal Disp"	if SiteID==	3315110010
replace SiteName = "Rundi Disp"	if SiteID==	3315110011
replace SiteName = "Betare Disp"	if SiteID==	3315110012
replace SiteName = "Katami Up-Graded Disp"	if SiteID==	3315110013
replace SiteName = "Gandanbe Disp"	if SiteID==	3315110014
replace SiteName = "Tanera Disp"	if SiteID==	3315110015
replace SiteName = "Tungar Isah Disp"	if SiteID==	3315110016
replace SiteName = "Ruggar Fulani Disp"	if SiteID==	3315110017
replace SiteName = "Gujiya Disp"	if SiteID==	3315110018
replace SiteName = "Gunki Disp"	if SiteID==	3315110019
replace SiteName = "Marafa Disp"	if SiteID==	3315110020
replace SiteName = "Gungu Disp"	if SiteID==	3315110021
replace SiteName = "Danjawa Disp"	if SiteID==	3315110022
replace SiteName = "Jekanadu Disp"	if SiteID==	3315110023
replace SiteName = "Kubodu Disp"	if SiteID==	3315110024
replace SiteName = "Shabra Disp"	if SiteID==	3315110025
replace SiteName = "Kubodu B"	if SiteID==	3315110026
replace SiteName = "Labani Disp"	if SiteID==	3315110027
replace SiteName = "Maje Disp"	if SiteID==	3315110028
replace SiteName = "Tungar Abdu Disp"	if SiteID==	3315110029
replace SiteName = "PHC Silame"	if SiteID==	3315110030
replace SiteName = "Tozo Disp"	if SiteID==	3315110031
replace SiteName = "Gabbuwa Disp"	if SiteID==	3315110032
replace SiteName = "Alkamawa Basic HC"	if SiteID==	3316110001
replace SiteName = "Helele  Basic HC"	if SiteID==	3316110002
replace SiteName = "Assada Disp"	if SiteID==	3316110003
replace SiteName = "Central Market CLIN"	if SiteID==	3316110004
replace SiteName = "Kofar kade Basic HC"	if SiteID==	3316110005
replace SiteName = "Sokoto CLIN"	if SiteID==	3316220006
replace SiteName = "Rumbunkawa Basic HC"	if SiteID==	3316110007
replace SiteName = "Kofar Rini Basic HC"	if SiteID==	3316110008
replace SiteName = "Runji Sambo Basaic HC"	if SiteID==	3316110009
replace SiteName = "Noma HOSP"	if SiteID==	3316210010
replace SiteName = "Sultan Palace CLIN"	if SiteID==	3316110011
replace SiteName = "Women and Children Welfare CLIN"	if SiteID==	3316210012
replace SiteName = "Rini Tawaye CLIN"	if SiteID==	3316110013
replace SiteName = "Holy Family CLIN"	if SiteID==	3316210014
replace SiteName = "Alfijir Specialist HOSP"	if SiteID==	3317220001
replace SiteName = "Marina CLIN"	if SiteID==	3317220002
replace SiteName = "Tudunwada CLIN"	if SiteID==	3317110003
replace SiteName = "Anas Private HOSP"	if SiteID==	3317220004
replace SiteName = "Standard HOSP"	if SiteID==	3317220005
replace SiteName = "Gidan Masau Disp"	if SiteID==	3317110006
replace SiteName = "Gagi Basic HC"	if SiteID==	3317110007
replace SiteName = "Devine HC"	if SiteID==	3317220008
replace SiteName = "Mabera Mujaya Disp"	if SiteID==	3317110009
replace SiteName = "Freehand Specialist HOSP"	if SiteID==	3317220010
replace SiteName = "Gidan Dahala Disp"	if SiteID==	3317110011
replace SiteName = "Mabera Basic HC"	if SiteID==	3317110012
replace SiteName = "Police CLIN"	if SiteID==	3317110013
replace SiteName = "Saraki Specialist HOSP"	if SiteID==	3317220014
replace SiteName = "Sheperd CLIN"	if SiteID==	3317220015
replace SiteName = "Wali Bako CLIN"	if SiteID==	3317220016
replace SiteName = "Maryam Abacha Women & Children HOSP"	if SiteID==	3317210017
replace SiteName = "Godiya CLIN"	if SiteID==	3317220018
replace SiteName = "Sahel Specialist HOSP"	if SiteID==	3317220019
replace SiteName = "Aliyu Jodi CLIN"	if SiteID==	3317220020
replace SiteName = "Hussein Med Center"	if SiteID==	3317220021
replace SiteName = "Hamdala CLIN"	if SiteID==	3317220022
replace SiteName = "Yar Akija basic HC"	if SiteID==	3317110023
replace SiteName = "Zafari HOSP"	if SiteID==	3317220024
replace SiteName = "Karaye CLIN"	if SiteID==	3317220025
replace SiteName = "PPFN CLIN"	if SiteID==	3317110026
replace SiteName = "Rijiya CLIN"	if SiteID==	3317220027
replace SiteName = "Specialist HOSP, Sokoto"	if SiteID==	3317210028
replace SiteName = "Toraro CLIN"	if SiteID==	3317220029
replace SiteName = "Bagida Disp"	if SiteID==	3318110001
replace SiteName = "Danmadi Disp"	if SiteID==	3318110002
replace SiteName = "Dogon Marke Disp"	if SiteID==	3318110003
replace SiteName = "Ganuwa Disp"	if SiteID==	3318110004
replace SiteName = "Bancho Disp"	if SiteID==	3318110005
replace SiteName = "Gen Hosp  Dogon Daji"	if SiteID==	3318210006
replace SiteName = "Kalgo Magaji Disp"	if SiteID==	3318110007
replace SiteName = "Maikada Disp"	if SiteID==	3318110008
replace SiteName = "MaiKade Disp"	if SiteID==	3318110009
replace SiteName = "Salah Disp"	if SiteID==	3318110010
replace SiteName = "Town Disp Dogon Daji"	if SiteID==	3318110011
replace SiteName = "Nabaguda Community Disp"	if SiteID==	3318110012
replace SiteName = "Sabawa Disp"	if SiteID==	3318110013
replace SiteName = "Kaura Disp"	if SiteID==	3318110014
replace SiteName = "Faga Disp"	if SiteID==	3318110015
replace SiteName = "Model PHC Faga"	if SiteID==	3318110016
replace SiteName = "Bashire Up-Graded Disp"	if SiteID==	3318110017
replace SiteName = "Masu Disp"	if SiteID==	3318110018
replace SiteName = "Modo Disp"	if SiteID==	3318110019
replace SiteName = "PHC Jabo"	if SiteID==	3318110020
replace SiteName = "Charai Disp"	if SiteID==	3318110021
replace SiteName = "Hiliya Disp"	if SiteID==	3318110022
replace SiteName = "G/salodi Disp"	if SiteID==	3318110023
replace SiteName = "H/Guraye Disp"	if SiteID==	3318110024
replace SiteName = "Kagara Disp "	if SiteID==	3318110025
replace SiteName = "Bangala Disp"	if SiteID==	3318110026
replace SiteName = "Gambuwa Disp"	if SiteID==	3318110027
replace SiteName = "Garan Disp"	if SiteID==	3318110028
replace SiteName = "Goshe Disp"	if SiteID==	3318110029
replace SiteName = "Gudun Disp"	if SiteID==	3318110030
replace SiteName = "Gen Hosp Tambuwal"	if SiteID==	3318210031
replace SiteName = "PHC Tambuwal"	if SiteID==	3318110032
replace SiteName = "Shinfiri Disp"	if SiteID==	3318110033
replace SiteName = "Romo Disp"	if SiteID==	3318110034
replace SiteName = "Romon Liman Disp"	if SiteID==	3318110035
replace SiteName = "Illoje Disp"	if SiteID==	3318110036
replace SiteName = "Bakaya Disp"	if SiteID==	3318110037
replace SiteName = "Madacci Community Disp"	if SiteID==	3318110038
replace SiteName = "Kaya Disp"	if SiteID==	3318110039
replace SiteName = "Barga Disp"	if SiteID==	3318110040
replace SiteName = "PHC Sayinna"	if SiteID==	3318110041
replace SiteName = "Saida Disp"	if SiteID==	3318110042
replace SiteName = "Tandamare Disp"	if SiteID==	3318110043
replace SiteName = "Buwade Disp"	if SiteID==	3318110044
replace SiteName = "Tsiwa Disp"	if SiteID==	3318110045
replace SiteName = "Ungwar D/Kande Disp"	if SiteID==	3318110046
replace SiteName = "Gozama Disp"	if SiteID==	3318110047
replace SiteName = "Tunga Community Disp"	if SiteID==	3318110048
replace SiteName = "Gambu Disp"	if SiteID==	3318110049
replace SiteName = "Alela Disp"	if SiteID==	3319110001
replace SiteName = "Bararahe Up-graded Disp"	if SiteID==	3319110002
replace SiteName = "Kwaraka Disp"	if SiteID==	3319110003
replace SiteName = "Rini Disp"	if SiteID==	3319110004
replace SiteName = "Sakkwai Up-graded Disp"	if SiteID==	3319110005
replace SiteName = "Alkasum Disp"	if SiteID==	3319110006
replace SiteName = "Kandam Disp"	if SiteID==	3319110007
replace SiteName = "Mano Disp"	if SiteID==	3319110008
replace SiteName = "Wasaniya Disp"	if SiteID==	3319110009
replace SiteName = "Baidi Disp"	if SiteID==	3319110010
replace SiteName = "Gen Hosp Tangaza"	if SiteID==	3319210011
replace SiteName = "Gurdam Up-graded Disp"	if SiteID==	3319110012
replace SiteName = "Labsani Disp"	if SiteID==	3319110013
replace SiteName = "Town Disp Tangaza"	if SiteID==	3319110014
replace SiteName = "Gidan Dadi Up-graded Disp"	if SiteID==	3319110015
replace SiteName = "PHC Gidan madi"	if SiteID==	3319110016
replace SiteName = "Gidima Disp"	if SiteID==	3319110017
replace SiteName = "Kalanjeni Disp"	if SiteID==	3319110018
replace SiteName = "Kaura Disp"	if SiteID==	3319110019
replace SiteName = "Araba Disp"	if SiteID==	3319110020
replace SiteName = "Kwacce Huro Disp"	if SiteID==	3319110021
replace SiteName = "Kwanawa Up-graded Disp"	if SiteID==	3319110022
replace SiteName = "Ginjo Disp"	if SiteID==	3319110023
replace SiteName = "Masallachi  Disp"	if SiteID==	3319110024
replace SiteName = "Mogonho Up-graded Disp"	if SiteID==	3319110025
replace SiteName = "Sanyinna Disp"	if SiteID==	3319110026
replace SiteName = "Takkau Disp"	if SiteID==	3319110027
replace SiteName = "Gandaba Disp"	if SiteID==	3319110028
replace SiteName = "Raka Up-graded Disp"	if SiteID==	3319110029
replace SiteName = "Manja Up-graded Disp"	if SiteID==	3319110030
replace SiteName = "PHC Ruwa Wuri"	if SiteID==	3319110031
replace SiteName = "Sarma A Disp"	if SiteID==	3319110032
replace SiteName = "Sarma B Disp"	if SiteID==	3319110033
replace SiteName = "Tunigara Disp"	if SiteID==	3319110034
replace SiteName = "Salewa Disp"	if SiteID==	3319110035
replace SiteName = "Bauni Up-graded Disp"	if SiteID==	3319110036
replace SiteName = "Zurmuku Disp"	if SiteID==	3319110037
replace SiteName = "Bimasa Disp"	if SiteID==	332011001
replace SiteName = "Dorawa Disp"	if SiteID==	332011002
replace SiteName = "Gidan kare Disp"	if SiteID==	332011003
replace SiteName = "Dangulbi Disp"	if SiteID==	332011004
replace SiteName = "Duma Disp"	if SiteID==	332011005
replace SiteName = "Fura Girke Disp"	if SiteID==	332011006
replace SiteName = "Garbe Kanni Disp"	if SiteID==	332011007
replace SiteName = "Gen Hosp Tureta"	if SiteID==	332021008
replace SiteName = "Town Disp Tureta"	if SiteID==	332011009
replace SiteName = "Rafin Bude Disp"	if SiteID==	332011010
replace SiteName = "Tsamiya Up-Graded Disp"	if SiteID==	332011011
replace SiteName = "Gidan Dangiwa Disp"	if SiteID==	332011012
replace SiteName = "Gidan Garkuwa"	if SiteID==	332011013
replace SiteName = "Lambar Tureta Up-Graded Disp"	if SiteID==	332011014
replace SiteName = "Galadima Disp"	if SiteID==	332011015
replace SiteName = "Kawara Disp"	if SiteID==	332011016
replace SiteName = "Kuruwa Disp"	if SiteID==	332011017
replace SiteName = "Kwarare Disp"	if SiteID==	332011018
replace SiteName = "Lofa Disp"	if SiteID==	332011019
replace SiteName = "Randa Disp"	if SiteID==	332011020
replace SiteName = "Arkilla Basic HC"	if SiteID==	3321110001
replace SiteName = "Government House CLIN"	if SiteID==	3321110002
replace SiteName = "Guiwa Community Disp"	if SiteID==	3321110003
replace SiteName = "Guiwa PHC"	if SiteID==	3321110004
replace SiteName = "Kontagora Bsaic HC"	if SiteID==	3321110005
replace SiteName = "Jama’a CLIN"	if SiteID==	3321220006
replace SiteName = "Usman DanFodio UTH"	if SiteID==	3321310007
replace SiteName = "Asari Dipsensary"	if SiteID==	3321110008
replace SiteName = "Badano Disp"	if SiteID==	3321110009
replace SiteName = "Daraye Disp"	if SiteID==	3321110010
replace SiteName = "Gedawa dsiepnsary"	if SiteID==	3321110011
replace SiteName = "Liggyare Disp"	if SiteID==	3321110012
replace SiteName = "Yarume Disp"	if SiteID==	3321110013
replace SiteName = "Bado Disp"	if SiteID==	3321110014
replace SiteName = "Bini Basic HC"	if SiteID==	3321110015
replace SiteName = "Farfaru Basic HC"	if SiteID==	3321110016
replace SiteName = "Bagaya Disp"	if SiteID==	3321110017
replace SiteName = "Boyen Dutsi"	if SiteID==	3321110018
replace SiteName = "Yaurawa Disp"	if SiteID==	3321110019
replace SiteName = "Gidan  Habibu Disp"	if SiteID==	3321110020
replace SiteName = "Bakin Kusu Disp"	if SiteID==	3321110021
replace SiteName = "Danjawa Disp"	if SiteID==	3321110022
replace SiteName = "Dundaye Up-Graded Disp"	if SiteID==	3321110023
replace SiteName = "Yarlabe Disp"	if SiteID==	3321110024
replace SiteName = "Tambaraga Disp"	if SiteID==	3321110025
replace SiteName = "University Permanent Site CLIN"	if SiteID==	3321110026
replace SiteName = "Dankyal Disp"	if SiteID==	3321110027
replace SiteName = "Gwamatse Disp"	if SiteID==	3321110028
replace SiteName = "Fanari Disp"	if SiteID==	3321110029
replace SiteName = "Gatare Disp"	if SiteID==	3321110030
replace SiteName = "Ruggar monde Disp"	if SiteID==	3321110031
replace SiteName = "Gidan Sarki Dunki Disp"	if SiteID==	3321110032
replace SiteName = "Gidan Bubu Dsiepnsary"	if SiteID==	3321110033
replace SiteName = "Gidan Tudu Disp"	if SiteID==	3321110034
replace SiteName = "Gidan Yaro Disp"	if SiteID==	3321110035
replace SiteName = "Kasarawa  Community Disp"	if SiteID==	3321110036
replace SiteName = "Maganawa Disp"	if SiteID==	3321110037
replace SiteName = "Gumbi Disp"	if SiteID==	3321110038
replace SiteName = "Wajake Disp"	if SiteID==	3321110039
replace SiteName = "Yarabba Disp"	if SiteID==	3321110040
replace SiteName = "Mankeri Disp"	if SiteID==	3321110041
replace SiteName = "Wamakko Up-graded Disp"	if SiteID==	3321110042
replace SiteName = "Kaura Kimba Dsipensary "	if SiteID==	3321110043
replace SiteName = "Lafiya CLIN"	if SiteID==	3321220044
replace SiteName = "Lagau Disp"	if SiteID==	3321110045
replace SiteName = "Mobile Police  CLIN"	if SiteID==	3321110046
replace SiteName = "Samalu Disp"	if SiteID==	3321110047
replace SiteName = "Alkammu Dsipensary"	if SiteID==	3322110001
replace SiteName = "Gyalgyal Disp"	if SiteID==	3322110002
replace SiteName = "Barayar Zaki Up-graded Disp"	if SiteID==	3322110003
replace SiteName = "Kwargaba Disp"	if SiteID==	3322110004
replace SiteName = "Lugu Up-graded Disp"	if SiteID==	3322110005
replace SiteName = "Marnona Disp"	if SiteID==	3322110006
replace SiteName = "Chacho Disp"	if SiteID==	3322110007
replace SiteName = "Gawo Disp"	if SiteID==	3322110008
replace SiteName = "Kadagiwa Disp"	if SiteID==	3322110009
replace SiteName = "Munki Disp"	if SiteID==	3322110010
replace SiteName = "Dimbisu Disp"	if SiteID==	3322110011
replace SiteName = "Duhuwa Disp"	if SiteID==	3322110012
replace SiteName = "Dinawa Up-graded Disp"	if SiteID==	3322110013
replace SiteName = "Gen Hosp Wurno"	if SiteID==	3322210014
replace SiteName = "Kwasare Disp"	if SiteID==	3322110015
replace SiteName = "Sisawa Disp"	if SiteID==	3322110016
replace SiteName = "Lahodu Up-graded Disp"	if SiteID==	3322110017
replace SiteName = "Model PHC Achida"	if SiteID==	3322110018
replace SiteName = "PHC Achida"	if SiteID==	3322110019
replace SiteName = "Town Disp Wurno"	if SiteID==	3322110020
replace SiteName = "Tunga Up-graded Disp"	if SiteID==	3322110021
replace SiteName = "Gidan Bango Disp"	if SiteID==	3322110022
replace SiteName = "Government Secondary School CLIN"	if SiteID==	3322110023
replace SiteName = "Kandam Disp"	if SiteID==	3322110024
replace SiteName = "Sabon Gari Liman"	if SiteID==	3322110025
replace SiteName = "Sakketa Disp"	if SiteID==	3322110026
replace SiteName = "Tambaraga Disp"	if SiteID==	3322110027
replace SiteName = "Yantabau  Disp"	if SiteID==	3322110028
replace SiteName = "Bengaje Disp"	if SiteID==	3323110001
replace SiteName = "Dono Disp"	if SiteID==	3323110002
replace SiteName = "Birni Ruwa Disp"	if SiteID==	3323110003
replace SiteName = "Kamfatare Dsipensary"	if SiteID==	3323110004
replace SiteName = "Fakka Disp"	if SiteID==	3323110005
replace SiteName = "Gudurega Disp"	if SiteID==	3323110006
replace SiteName = "Binji Muza Disp"	if SiteID==	3323110007
replace SiteName = "Kibiyare Disp"	if SiteID==	3323110008
replace SiteName = "PHC Binji Muza"	if SiteID==	3323110009
replace SiteName = "PHC Kilgori"	if SiteID==	3323110010
replace SiteName = "Dagawa Disp"	if SiteID==	3323110011
replace SiteName = "Ruggar Kijo Disp"	if SiteID==	3323110012
replace SiteName = "Toronkawa Disp "	if SiteID==	3323110013
replace SiteName = "Gen Hosp Yabo"	if SiteID==	3323210014
replace SiteName = "Town Disp Yabo"	if SiteID==	3323110015
replace SiteName = "Shabra Disp"	if SiteID==	3323110016
replace SiteName = "Alkalije Disp"	if SiteID==	3323110017
replace SiteName = "Bakale Disp"	if SiteID==	3323110018
replace SiteName = "W.C.W.C Yabo"	if SiteID==	3323110019




*YOBE
replace SiteName ="Azam Kura Disp"	if SiteID==	3501110001
replace SiteName ="Azbak HC"	if SiteID==	3501110002
replace SiteName ="Babuje Disp"	if SiteID==	3501110003
replace SiteName ="Bade CLIN"	if SiteID==	3501110004
replace SiteName ="Bizi HC"	if SiteID==	3501110005
replace SiteName ="Central Disp"	if SiteID==	3501110006
replace SiteName ="Dagona HC"	if SiteID==	3501110007
replace SiteName ="Dalah HC"	if SiteID==	3501110008
replace SiteName ="Dawayo Disp"	if SiteID==	3501110009
replace SiteName ="Gabarwa Disp"	if SiteID==	3501110010
replace SiteName ="Gashu'a MCH"	if SiteID==	3501110011
replace SiteName ="Gashua Sabon Gari Gen Hosp"	if SiteID==	3501210012
replace SiteName ="Gwio Kura Disp"	if SiteID==	3501110013
replace SiteName ="Jigawa HC"	if SiteID==	3501110014
replace SiteName ="Nasara CLIN"	if SiteID==	3501220015
replace SiteName ="Ngelbowa HC"	if SiteID==	3501110016
replace SiteName ="Ngeljabe Disp"	if SiteID==	3501110017
replace SiteName ="Sabon Gari Child Welfare CLIN"	if SiteID==	3501110018
replace SiteName ="Sugum Comp HC"	if SiteID==	3501110019
replace SiteName ="Sugum Disp"	if SiteID==	3501110020
replace SiteName ="Tagali Disp"	if SiteID==	3501110021
replace SiteName ="Tagama Disp"	if SiteID==	3501110022
replace SiteName ="Zango Disp"	if SiteID==	3501110023
replace SiteName ="Garin Lamido Health CENT" if SiteID==	3501110024


replace SiteName ="Abbari Disp"	if SiteID==	3502110001
replace SiteName ="Ajiri Disp"	if SiteID==	3502110002
replace SiteName ="Bade Gana Disp"	if SiteID==	3502110003
replace SiteName ="Bayamari MCH"	if SiteID==	3502110004
replace SiteName ="Bayamari PHC"	if SiteID==	3502110005
replace SiteName ="Bururu Disp"	if SiteID==	3502110006
replace SiteName ="Dadigar Disp"	if SiteID==	3502110007
replace SiteName ="Dalari HC"	if SiteID==	3502110008
replace SiteName ="Damaya Disp"	if SiteID==	3502110009
replace SiteName ="Danani Disp"	if SiteID==	3502110010
replace SiteName ="Dapchi Gen Hosp"	if SiteID==	3502210011
replace SiteName ="Dapchi MCH"	if SiteID==	3502110012
replace SiteName ="Dapso Disp"	if SiteID==	3502110013
replace SiteName ="Dumburi Disp"	if SiteID==	3502110014
replace SiteName ="Gadine Disp"	if SiteID==	3502110015
replace SiteName ="Gangawa Disp"	if SiteID==	3502110016
replace SiteName ="Garin Alkali Disp"	if SiteID==	3502110017
replace SiteName ="Garin Kabaju Disp"	if SiteID==	3502110018
replace SiteName ="Garun Dole Disp"	if SiteID==	3502110019
replace SiteName ="Gilbasu Disp"	if SiteID==	3502110020
replace SiteName ="Girim Disp"	if SiteID==	3502110021
replace SiteName ="Guba Disp"	if SiteID==	3502110022
replace SiteName ="Ilela Disp"	if SiteID==	3502110023
replace SiteName ="Jaba Disp"	if SiteID==	3502110024
replace SiteName ="Juluri Disp"	if SiteID==	3502110025
replace SiteName ="Kakanderi Disp"	if SiteID==	3502110026
replace SiteName ="Kaliyari Disp"	if SiteID==	3502110027
replace SiteName ="Kankare Disp"	if SiteID==	3502110028
replace SiteName ="Koromari Disp"	if SiteID==	3502110029
replace SiteName ="Kujikujiri Disp"	if SiteID==	3502110030
replace SiteName ="Kurnawa MCH"	if SiteID==	3502110031
replace SiteName ="Lawanti Disp"	if SiteID==	3502110032
replace SiteName ="Marari Disp"	if SiteID==	3502110033
replace SiteName ="Masaba HC"	if SiteID==	3502110034
replace SiteName ="Metalari Disp"	if SiteID==	3502110035
replace SiteName ="Renukunu Disp"	if SiteID==	3502110036
replace SiteName ="Sunowa Disp"	if SiteID==	3502110037
replace SiteName ="Tarbutu Disp"	if SiteID==	3502110038
replace SiteName ="Turbangida Disp"	if SiteID==	3502110039
replace SiteName ="Warodi Disp"	if SiteID==	3502110040
replace SiteName = "Jawa Comp HC" if SiteID==3502110041
replace SiteName ="Ajari Disp"	if SiteID==	3503110001
replace SiteName ="Ajiko Med CENT"	if SiteID==	3503220002
replace SiteName ="Borno Med CLIN"	if SiteID==	3503220003
replace SiteName ="Damakasu Disp"	if SiteID==	3503110004
replace SiteName ="Damanturu Federal Poly CLIN"	if SiteID==	3503110005
replace SiteName ="Damanturu Model PHC"	if SiteID==	3503110006
replace SiteName ="Damaturu FSP MCH"	if SiteID==	3503110007
replace SiteName ="Damaturu Government House CLIN"	if SiteID==	3503110008
replace SiteName ="Damaturu Nigerian Police Force CLIN"	if SiteID==	3503110009
replace SiteName ="Dikumari Disp"	if SiteID==	3503110010
replace SiteName ="Federal Secretariat Staff CLIN"	if SiteID==	3503110011
replace SiteName ="Gabai Disp"	if SiteID==	3503110012
replace SiteName ="Gambir Disp"	if SiteID==	3503110013
replace SiteName ="Gwange MCH"	if SiteID==	3503110014
replace SiteName ="Kabaru Disp"	if SiteID==	3503110015
replace SiteName ="Kalallawa Disp"	if SiteID==	3503110016
replace SiteName ="Kukareta MCH"	if SiteID==	3503110017
replace SiteName ="Maisandari CLIN"	if SiteID==	3503110018
replace SiteName ="Murfa Kalam Disp"	if SiteID==	3503110019
replace SiteName ="Nayinawa Disp"	if SiteID==	3503110020
replace SiteName ="Sasawa Disp"	if SiteID==	3503110021
replace SiteName ="State Specialist HOSP"	if SiteID==	3503210022
replace SiteName ="Very Important Persons CLIN"	if SiteID==	3503220023
replace SiteName ="Yobe Med and MCH"	if SiteID==	3503220024
replace SiteName ="Yobe State Secretariat CLIN"	if SiteID==	3503110025
replace SiteName ="Anze Disp"	if SiteID==	3504110001
replace SiteName ="Boza Disp"	if SiteID==	3504110002
replace SiteName ="Bulaburin HC"	if SiteID==	3504110003
replace SiteName ="Chana Disp"	if SiteID==	3504110004
replace SiteName ="Damaze HC"	if SiteID==	3504110005
replace SiteName ="Daya HC"	if SiteID==	3504110006
replace SiteName ="Dogo Abare HC"	if SiteID==	3504110007
replace SiteName ="Dole H.Post"	if SiteID==	3504110008
replace SiteName ="Doto Fara HC"	if SiteID==	3504110009
replace SiteName ="Duffuyel HC"	if SiteID==	3504110010
replace SiteName ="Dumbulwa Disp"	if SiteID==	3504110011
replace SiteName ="Fakali HC"	if SiteID==	3504110012
replace SiteName ="Ferol HC"	if SiteID==	3504110013
replace SiteName ="Fika Gen Hosp"	if SiteID==	3504210014
replace SiteName ="Fika MCH"	if SiteID==	3504110015
replace SiteName ="Gadaka HC"	if SiteID==	3504110016
replace SiteName ="Gadaka Model PHC"	if SiteID==	3504110017
replace SiteName ="Gamari HC"	if SiteID==	3504110018
replace SiteName ="Garin Abba HC"	if SiteID==	3504110019
replace SiteName ="Garin Alaramma H.Post"	if SiteID==	3504110020
replace SiteName ="Garin Ari HC"	if SiteID==	3504110021
replace SiteName ="Garin Chindo H.Post"	if SiteID==	3504110022
replace SiteName ="Garin Dauya HC"	if SiteID==	3504110023
replace SiteName ="Garin Gamji HC"	if SiteID==	3504110024
replace SiteName ="Garin Goge Disp"	if SiteID==	3504110025
replace SiteName ="Garin Tongo H.Post"	if SiteID==	3504110026
replace SiteName ="Garin Wayo HC"	if SiteID==	3504110027
replace SiteName ="Garin Yarima H.Post"	if SiteID==	3504110028
replace SiteName ="Garkuwa HC"	if SiteID==	3504110029
replace SiteName ="Gashaka HC"	if SiteID==	3504110030
replace SiteName ="Gashinge H.Post"	if SiteID==	3504110031
replace SiteName ="Godowoli Disp"	if SiteID==	3504110032
replace SiteName ="Gurjaje H.Post"	if SiteID==	3504110033
replace SiteName ="Janga Dole HC"	if SiteID==	3504110034
replace SiteName ="Janga Siri H.Post"	if SiteID==	3504110035
replace SiteName ="Kabano HC"	if SiteID==	3504110036
replace SiteName ="Kerem HC"	if SiteID==	3504110037
replace SiteName ="Koyaya HC"	if SiteID==	3504110038
replace SiteName ="Kukar Gadu HC"	if SiteID==	3504110039
replace SiteName ="Kurmi Disp"	if SiteID==	3504110040
replace SiteName ="Lewe HC"	if SiteID==	3504110041
replace SiteName ="Maluri Disp"	if SiteID==	3504110042
replace SiteName ="Manawachi HC"	if SiteID==	3504110043
replace SiteName ="Mazuwan HC"	if SiteID==	3504110044
replace SiteName ="Mubi/Fusami Disp"	if SiteID==	3504110045
replace SiteName ="Munchika HC"	if SiteID==	3504110046
replace SiteName ="Ngalda Disp"	if SiteID==	3504110047
replace SiteName ="Siminti HC"	if SiteID==	3504110048
replace SiteName ="Siminti Model Primary HC"	if SiteID==	3504110049
replace SiteName ="Turmi HC"	if SiteID==	3504110050
replace SiteName ="Yelwa Disp"	if SiteID==	3504110051
replace SiteName ="Zadawa HC"	if SiteID==	3504110052
replace SiteName ="Zamba H.Post"	if SiteID==	3504110053
replace SiteName ="Zangaya Disp"	if SiteID==	3504110054
replace SiteName ="Abakire Disp"	if SiteID==	3505110001
replace SiteName ="Aigala Disp"	if SiteID==	3505110002
replace SiteName ="Alagarno HC"	if SiteID==	3505110003
replace SiteName ="Balarabe MCH"	if SiteID==	3505220004
replace SiteName ="Banalewa H.Post"	if SiteID==	3505110005
replace SiteName ="Baushe Model PHC"	if SiteID==	3505110006
replace SiteName ="Bebande H.Post"	if SiteID==	3505110007
replace SiteName ="Bindigi HC"	if SiteID==	3505110008
replace SiteName ="Borno Kiji MCH"	if SiteID==	3505110009
replace SiteName ="Bulanyiwa HC"	if SiteID==	3505110010
replace SiteName ="Damagum Gen Hosp"	if SiteID==	3505210011
replace SiteName ="Damagum MCH"	if SiteID==	3505110012
replace SiteName ="Daura MCH"	if SiteID==	3505110013
replace SiteName ="Dogon-Kuka B MCH"	if SiteID==	3505110014
replace SiteName ="Dogon-Kuka MCH"	if SiteID==	3505110015
replace SiteName ="Dubbol Model PHC"	if SiteID==	3505110016
replace SiteName ="Duhuna HC"	if SiteID==	3505110017
replace SiteName ="Dumawal H.Post"	if SiteID==	3505110018
replace SiteName ="Dumbulwa (Fune) Disp"	if SiteID==	3505110019
replace SiteName ="Gaba Tasha Disp"	if SiteID==	3505110020
replace SiteName ="Ganji Disp"	if SiteID==	3505110021
replace SiteName ="Gazarakuma H.Post"	if SiteID==	3505110022
replace SiteName ="Gishiwari Disp"	if SiteID==	3505110023
replace SiteName ="Gubana Disp"	if SiteID==	3505110024
replace SiteName ="Gudugurka Disp"	if SiteID==	3505110025
replace SiteName ="Gurungu H.Post"	if SiteID==	3505110026
replace SiteName ="Jajere Disp"	if SiteID==	3505110027
replace SiteName ="Jajere MCH"	if SiteID==	3505110028
replace SiteName ="Jaji Burawa Disp"	if SiteID==	3505110029
replace SiteName ="Kafaje Disp"	if SiteID==	3505110030
replace SiteName ="Kayeri Disp"	if SiteID==	3505110031
replace SiteName ="Kayeri MCH"	if SiteID==	3505110032
replace SiteName ="Koibula Disp"	if SiteID==	3505110033
replace SiteName ="Kollere HC"	if SiteID==	3505110034
replace SiteName ="Koyaya H.Post"	if SiteID==	3505110035
replace SiteName ="Kwara-Wango H.Post"	if SiteID==	3505110036
replace SiteName ="Marmari Disp"	if SiteID==	3505110037
replace SiteName ="Mashio HC"	if SiteID==	3505110038
replace SiteName ="Murba H.Post"	if SiteID==	3505110039
replace SiteName ="Ngelshengele Disp"	if SiteID==	3505110040
replace SiteName ="Ngelzerma MCH"	if SiteID==	3505110041
replace SiteName ="Ningi Disp"	if SiteID==	3505110042
replace SiteName ="Sabongari Idi-Barde Disp"	if SiteID==	3505110043
replace SiteName ="Shamka Disp"	if SiteID==	3505110044
replace SiteName ="Shanga Disp"	if SiteID==	3505110045
replace SiteName ="Siminti (Fune) Disp"	if SiteID==	3505110046
replace SiteName ="Sudande H.Post"	if SiteID==	3505110047
replace SiteName ="Taiyu H.Post"	if SiteID==	3505110048
replace SiteName ="Tello Disp"	if SiteID==	3505110049
replace SiteName ="Alhajiri Disp"	if SiteID==	3506110001
replace SiteName ="Ashekri Town Disp"	if SiteID==	3506110002
replace SiteName ="Balle MCH"	if SiteID==	3506110003
replace SiteName ="Borko Disp"	if SiteID==	3506110004
replace SiteName ="Dagambi Disp"	if SiteID==	3506110005
replace SiteName ="Dajina Disp"	if SiteID==	3506110006
replace SiteName ="Damakarwa Disp"	if SiteID==	3506110007
replace SiteName ="Darro Disp"	if SiteID==	3506110008
replace SiteName ="Dilawa Disp"	if SiteID==	3506110009
replace SiteName ="Fukurti Disp"	if SiteID==	3506110010
replace SiteName ="Futchimiram HC"	if SiteID==	3506110011
replace SiteName ="Geidam Gen Hosp"	if SiteID==	3506210012
replace SiteName ="Geidam MCH"	if SiteID==	3506110013
replace SiteName ="Gumsa Model PHC"	if SiteID==	3506110014
replace SiteName ="Hausari Disp"	if SiteID==	3506110015
replace SiteName ="Kelluri MCH"	if SiteID==	3506110016
replace SiteName ="Kindila Disp"	if SiteID==	3506110017



replace SiteName ="Kukawa Disp"	if SiteID==	3506110018
replace SiteName ="Kusur Disp"	if SiteID==	3506110019
replace SiteName ="Lawan Bukarti Disp"	if SiteID==	3506110020
replace SiteName ="Ma'anna Disp"	if SiteID==	3506110021
replace SiteName ="Malari Disp"	if SiteID==	3506110022
replace SiteName ="Matakuskum HC"	if SiteID==	3506110023
replace SiteName ="Adetona Med CENT"	if SiteID==	3507220001
* Errors in official docs for Guijba LGA Yobe
replace SiteName ="Ambiya Disp"			if SiteID==	3507110002
replace SiteName ="Azare Disp"			if SiteID==	3507110003
replace SiteName ="Bukkil Disp"			if SiteID==	3507110004
replace SiteName ="Bulturam Disp"			if SiteID==	3507110005
replace SiteName ="Buni Gari Dispesanry"		if SiteID==	3507110006
replace SiteName ="Buni Yadi Gen Hosp"	if SiteID==	3507210007
replace SiteName ="Buniyadi MCH"	if SiteID==	3507110008
replace SiteName ="Dadewel Disp"			if SiteID==	3507110009
replace SiteName ="Dadingel Disp"			if SiteID==	3507110010
replace SiteName ="Goniri Comp HC"	if SiteID==	3507110011
replace SiteName ="Goniri Disp"			if SiteID==	3507110012
replace SiteName ="Gotumba Disp"			if SiteID==	3507110013
replace SiteName ="Gujba Disp"			if SiteID==	3507110014
replace SiteName ="Kasachiya Disp"		if SiteID==	3507110015
replace SiteName ="Katarko Disp"			if SiteID==	3507110016
replace SiteName ="Kukuwa Disp"			if SiteID==	3507110017
replace SiteName ="Malum-Dunari Disp"		if SiteID==	3507110018
replace SiteName ="Mutai Disp"			if SiteID==	3507110019
replace SiteName ="Ngurbuwa MCH"	if SiteID==	3507110020
replace SiteName ="Nyakire Disp"			if SiteID==	3507110021
replace SiteName ="Wagir Model PHC"	if SiteID==	3507110022
replace SiteName ="Wulle Disp"			if SiteID==	3507110023
replace SiteName ="Alagarno H.Post"	if SiteID==	3508110001
replace SiteName ="Ayada H.Post"	if SiteID==	3508110002
replace SiteName ="Badugo-Badugoro H.Post"	if SiteID==	3508110003
replace SiteName ="Bara Comprensive HC"	if SiteID==	3508110004
replace SiteName ="Bara Disp"	if SiteID==	3508110005
replace SiteName ="Birni-Gadam H.Post"	if SiteID==	3508110006
replace SiteName ="Borno Kiji H.Post"	if SiteID==	3508110007
replace SiteName ="Bularafa HC"	if SiteID==	3508110008
replace SiteName ="Bumsa Disp"	if SiteID==	3508110009
replace SiteName ="Bursari H.Post"	if SiteID==	3508110010
replace SiteName ="Chandam H.Post"	if SiteID==	3508110011
replace SiteName ="Choka H.Post"	if SiteID==	3508110012
replace SiteName ="Dokshi HC"	if SiteID==	3508110013
replace SiteName ="Dutchi H.Post"	if SiteID==	3508110014
replace SiteName ="Gabai Disp (Gulani)"	if SiteID==	3508110015
replace SiteName ="Gagure Disp"	if SiteID==	3508110016
replace SiteName ="Gargari H.Post"	if SiteID==	3508110017
replace SiteName ="Garin Maikomo H.Post"	if SiteID==	3508110018
replace SiteName ="Garin-Abdullahi H.Post"	if SiteID==	3508110019
replace SiteName ="Garintuwo Disp"	if SiteID==	3508110020
replace SiteName ="Gulani HC"	if SiteID==	3508110021
replace SiteName ="Jana H.Post"	if SiteID==	3508110022
replace SiteName ="Kukuwa H.Post"	if SiteID==	3508110023
replace SiteName ="Kupto-Gana H.Post"	if SiteID==	3508110024
replace SiteName ="Kushimaga Disp"	if SiteID==	3508110025
replace SiteName ="Mabani H.Post"	if SiteID==	3508110026
replace SiteName ="Ngurum H.Post"	if SiteID==	3508110027
replace SiteName ="Nguzuwa H.Post"	if SiteID==	3508110028
replace SiteName ="Njibulwa Model PHC"	if SiteID==	3508110029
replace SiteName ="Njibulwa Private CLIN"	if SiteID==	3508220030
replace SiteName ="Ruhu Disp"	if SiteID==	3508110031
replace SiteName ="Ruwan Kuka H.Post"	if SiteID==	3508110032
replace SiteName ="Shishi Waji H.Post"	if SiteID==	3508110033
replace SiteName ="Teteba Disp"	if SiteID==	3508110034
replace SiteName ="Yelwa H.Post (Gulani)"	if SiteID==	3508110035
replace SiteName ="Zongo HC"	if SiteID==	3508110036
replace SiteName ="Adiya Disp"	if SiteID==	3509110001
replace SiteName ="Agana HC"	if SiteID==	3509110002
replace SiteName ="Amshi MCH"	if SiteID==	3509110003
replace SiteName ="Ariri HC"	if SiteID==	3509110004
replace SiteName ="Arvani HC"	if SiteID==	3509110005
replace SiteName ="Bayam Disp"	if SiteID==	3509110006
replace SiteName ="Bubuno HC"	if SiteID==	3509110007
replace SiteName ="Buduwa HC"	if SiteID==	3509110008
replace SiteName ="Dachia HC"	if SiteID==	3509110009
replace SiteName ="Damasa HC"	if SiteID==	3509110010
replace SiteName ="Dan Takuni HC"	if SiteID==	3509110011
replace SiteName ="Doro HC"	if SiteID==	3509110012
replace SiteName ="Dumbari Disp"	if SiteID==	3509110013
replace SiteName ="Gamajam HC"	if SiteID==	3509110014
replace SiteName ="Garin Biri HC"	if SiteID==	3509110015
replace SiteName ="Garin Gano HC"	if SiteID==	3509110016
replace SiteName ="Garin Tsalha HC"	if SiteID==	3509110017
replace SiteName ="Gasamu Disp"	if SiteID==	3509110018
replace SiteName ="Gasi HC"	if SiteID==	3509110019
replace SiteName ="Gauya Disp"	if SiteID==	3509110020
replace SiteName ="Girgir Disp"	if SiteID==	3509110021
replace SiteName ="Gogaram Federal Model PHC"	if SiteID==	3509110022
replace SiteName ="Gumulawa HC"	if SiteID==	3509110023
replace SiteName ="Gurbana HC"	if SiteID==	3509110024
replace SiteName ="Guzambana HC"	if SiteID==	3509110025
replace SiteName ="Gwayo Disp"	if SiteID==	3509110026
replace SiteName ="Iyim Disp"	if SiteID==	3509110027
replace SiteName ="Jaba HC"	if SiteID==	3509110028
replace SiteName ="Jadam HC"	if SiteID==	3509110029
replace SiteName ="Jakusko Disp"	if SiteID==	3509110030
replace SiteName ="Jakusko Gen Hosp"	if SiteID==	3509210031
replace SiteName ="Jakusko MCH"	if SiteID==	3509110032
replace SiteName ="Jamil HC"	if SiteID==	3509110033
replace SiteName ="Kagammu HC"	if SiteID==	3509110034
replace SiteName ="Karage MCH"	if SiteID==	3509110035
replace SiteName ="Katamma HC"	if SiteID==	3509110036
replace SiteName ="Katangana HC"	if SiteID==	3509110037
replace SiteName ="Kazir Disp"	if SiteID==	3509110038
replace SiteName ="Kukamaiwa HC"	if SiteID==	3509110039
replace SiteName ="Kurkushe Disp"	if SiteID==	3509110040
replace SiteName ="Lafiyaloiloi Disp"	if SiteID==	3509110041
replace SiteName ="Lafiyan Gwa HC"	if SiteID==	3509110042
replace SiteName ="Lamarbago Disp"	if SiteID==	3509110043
replace SiteName ="Muguram HC"	if SiteID==	3509110044
replace SiteName ="Tajuwa Disp"	if SiteID==	3509110045
replace SiteName ="Tarja HC"	if SiteID==	3509110046
replace SiteName =" Tudiniya HC"	if SiteID==	3509110047
replace SiteName ="Bukarti HC"	if SiteID==	3510110001
replace SiteName ="Bukku H.Post"	if SiteID==	3510110002
replace SiteName ="Bularifi Disp"	if SiteID==	3510110003
replace SiteName ="Faji Ganari Disp"	if SiteID==	3510110004
replace SiteName ="Garin Gawo Disp"	if SiteID==	3510110005
replace SiteName ="Gasma Disp"	if SiteID==	3510110006
replace SiteName ="Jajeri Disp"	if SiteID==	3510110007
replace SiteName ="Jajimaji Comp HC"	if SiteID==	3510110008
replace SiteName ="Jajimaji MCH"	if SiteID==	3510110009
replace SiteName ="Kafetuwa H.Post"	if SiteID==	3510110010
replace SiteName ="Karasuwa Galu Disp"	if SiteID==	3510110011
replace SiteName ="Karasuwa HC"	if SiteID==	3510110012
replace SiteName ="Karasuwa Model PHC"	if SiteID==	3510110013
replace SiteName ="Kilbuwa H.Post"	if SiteID==	3510110014
replace SiteName ="Lamido Sule H.Post"	if SiteID==	3510110015
replace SiteName ="Mallam Grema H.Post"	if SiteID==	3510110016
replace SiteName ="Mallam Musari H.Post"	if SiteID==	3510110017
replace SiteName ="Wachakal Disp"	if SiteID==	3510110018
replace SiteName ="Waro Disp"	if SiteID==	3510110019
replace SiteName ="Bogo Disp"	if SiteID==	3511110001
replace SiteName ="Burdumaram Disp"	if SiteID==	3511110002
replace SiteName ="Damai Disp"	if SiteID==	3511110003
replace SiteName ="Damdari Disp"	if SiteID==	3511110004
replace SiteName ="Dole Machina HC"	if SiteID==	3511110005
replace SiteName ="Falimaram Disp"	if SiteID==	3511110006
replace SiteName ="Garanda Disp"	if SiteID==	3511110007
replace SiteName ="Goki Disp"	if SiteID==	3511110008
replace SiteName ="Kagumsuwa Disp"	if SiteID==	3511110009
replace SiteName ="Kalgidi Disp"	if SiteID==	3511110010
replace SiteName ="Kangarwa Disp"	if SiteID==	3511110011
replace SiteName ="Karmashe Disp"	if SiteID==	3511110012
replace SiteName ="Kukayasku Disp"	if SiteID==	3511110013
replace SiteName ="Lamisu Disp"	if SiteID==	3511110014
replace SiteName ="Machina Central Disp"	if SiteID==	3511110015
replace SiteName ="Machina Comp HC"	if SiteID==	3511110016
replace SiteName ="Machina MCH"	if SiteID==	3511110017
replace SiteName ="Maskandare Disp"	if SiteID==	3511110018
replace SiteName ="Taganama Disp"	if SiteID==	3511110019
replace SiteName ="Yalauwa Disp"	if SiteID==	3511110020
replace SiteName ="Baraniya HC"	if SiteID==	3512110001
replace SiteName ="Biriri Disp"	if SiteID==	3512110002
replace SiteName ="Chalinno Disp"	if SiteID==	3512110003
replace SiteName ="Chukuriwa PHC"	if SiteID==	3512110004
replace SiteName ="Dadiso H.Post"	if SiteID==	3512110005
replace SiteName ="Dagare Disp"	if SiteID==	3512110006
replace SiteName ="Dagazirwa HC"	if SiteID==	3512110007
replace SiteName ="Darin H.Post"	if SiteID==	3512110008
replace SiteName ="Dawasa Disp"	if SiteID==	3512110009
replace SiteName ="Dawasa MCH(State)"	if SiteID==	3512110010
replace SiteName ="Dazigau MCH"	if SiteID==	3512110011
replace SiteName ="Degubi Model PHC"	if SiteID==	3512110012
replace SiteName ="Dorawa Dadi H.Post"	if SiteID==	3512110013
replace SiteName ="Duddaye Disp"	if SiteID==	3512110014
replace SiteName ="Gabur Disp"	if SiteID==	3512110015
replace SiteName ="Garin Baba Disp"	if SiteID==	3512110016
replace SiteName ="Garin Gambo Disp"	if SiteID==	3512110017
replace SiteName ="Garin Jata Disp"	if SiteID==	3512110018
replace SiteName ="Garin Kadai Disp"	if SiteID==	3512110019
replace SiteName ="Garin Keri Disp"	if SiteID==	3512110020
replace SiteName ="Garin Muzam HC"	if SiteID==	3512110021
replace SiteName ="Garin Shera Disp"	if SiteID==	3512110022
replace SiteName ="Gudi Disp"	if SiteID==	3512110023
replace SiteName ="Haram Disp"	if SiteID==	3512110024
replace SiteName ="Kael Disp"	if SiteID==	3512110025
replace SiteName ="Katsira HC"	if SiteID==	3512110026
replace SiteName ="Kukuri (State) MCH"	if SiteID==	3512110027
replace SiteName ="Kukuri PHC"	if SiteID==	3512110028
replace SiteName ="Nangere Gen Hosp"	if SiteID==	3512210029
replace SiteName ="Old Nangere HC"	if SiteID==	3512110030
replace SiteName ="Sabongari MCH"	if SiteID==	3512110031
replace SiteName ="Tarajim H.Post"	if SiteID==	3512110032
replace SiteName ="Tikau HC"	if SiteID==	3512110033
replace SiteName ="Tudun Wada HC"	if SiteID==	3512110034
replace SiteName ="Watinane MCH"	if SiteID==	3512110035
replace SiteName ="Yaru H.Post"	if SiteID==	3512110036
replace SiteName ="Zinzano Disp"	if SiteID==	3512110037
replace SiteName ="Afunori CLIN"	if SiteID==	3513110001
replace SiteName ="Army Barrack CLIN (Nguru)"	if SiteID==	3513110002
replace SiteName ="Balanguwa CLIN"	if SiteID==	3513110003
replace SiteName ="Bombori CLIN"	if SiteID==	3513110004
replace SiteName ="Bubari HC"	if SiteID==	3513110005
replace SiteName ="Bulabulin Central Disp"	if SiteID==	3513110006
replace SiteName ="Dagirari CLIN"	if SiteID==	3513110007
replace SiteName ="Dumsai Disp"	if SiteID==	3513110008
replace SiteName ="Garbi HC"	if SiteID==	3513110009
replace SiteName ="Maja-Kura CLIN"	if SiteID==	3513110010
replace SiteName ="Ngilewa HC"	if SiteID==	3513110011
replace SiteName ="Nguru Federal Med CENT"	if SiteID==	3513310012
replace SiteName ="Nguru Federal Model PHC"	if SiteID==	3513110013
replace SiteName ="Nguru MCH"	if SiteID==	3513110014
replace SiteName ="Salisu Memorial CLIN"	if SiteID==	3513220015
replace SiteName = "Mirba HC" if SiteID==3513110016
replace SiteName = "Dabule HC" if SiteID==3513110017
replace SiteName ="Badejo CLIN"	if SiteID==	3514110001
replace SiteName ="Beta CLIN"	if SiteID==	3514220002
replace SiteName ="Bilam Fusam CLIN"	if SiteID==	3514110003
replace SiteName ="Bubaram HC"	if SiteID==	3514110004
replace SiteName ="Bula CLIN"	if SiteID==	3514110005
replace SiteName ="Bulabulin CLIN"	if SiteID==	3514110006
replace SiteName ="Catholic MCH"	if SiteID==	3514220007
replace SiteName ="Dakasku CLIN"	if SiteID==	3514110008
replace SiteName ="Danchuwa CLIN"	if SiteID==	3514110009
replace SiteName ="Dogon-Zare CLIN"	if SiteID==	3514110010
replace SiteName ="Eva CLIN"	if SiteID==	3514220011
replace SiteName ="Garin Abba CLIN"	if SiteID==	3514110012
replace SiteName ="Garin Dala CLIN"	if SiteID==	3514110013
replace SiteName ="Garin Kachalla HC"	if SiteID==	3514110014
replace SiteName ="Garin Makwai MCH"	if SiteID==	3514110015
replace SiteName ="Garin Mele CLIN"	if SiteID==	3514110016
replace SiteName ="Potiskum Gen Hosp"	if SiteID==	3514110017
replace SiteName ="Jama'a 2 CLIN"	if SiteID==	3514220018
replace SiteName ="Jamma'a CLIN"	if SiteID==	3514220019
replace SiteName ="Juma'a CLIN"	if SiteID==	3514110020
replace SiteName ="Leprosy CLIN"	if SiteID==	3514110021
replace SiteName ="Maje CLIN"	if SiteID==	3514110022
replace SiteName ="Mamudo MCH"	if SiteID==	3514110023
replace SiteName ="Mazaganai MCH"	if SiteID==	3514110024
replace SiteName ="Nahuta CLIN"	if SiteID==	3514110025
replace SiteName ="Potiskum MCH"	if SiteID==	3514110026
replace SiteName ="Potiskum Med CLIN"	if SiteID==	3514220027
replace SiteName ="Potiskum Town Central CLIN"	if SiteID==	3514220028
replace SiteName ="Royal CLIN"	if SiteID==	3514220029
replace SiteName ="Taif MCH"	if SiteID==	3514220030
replace SiteName ="Tudun Wada MCH"	if SiteID==	3514110031
replace SiteName ="Yerimaram MCH"	if SiteID==	3514110032
replace SiteName ="Yindiski MCH"	if SiteID==	3514110033
replace SiteName ="Zanwa CLIN"	if SiteID==	3514110034
replace SiteName ="Farafara MCH"	if SiteID==	3514110035
replace SiteName ="Babbangida Comp HC"	if SiteID==	3515110001
replace SiteName ="Babbangida HC"	if SiteID==	3515110002
replace SiteName ="Barkami Disp"	if SiteID==	3515110003
replace SiteName ="Biriri Disp (Tarmuwa)"	if SiteID==	3515110004
replace SiteName ="Chirokusko Disp"	if SiteID==	3515110005
replace SiteName ="Garga Disp"	if SiteID==	3515110006
replace SiteName ="Goduram Disp"	if SiteID==	3515110007
replace SiteName ="Jumbam MCH"	if SiteID==	3515110008
replace SiteName ="Kaliyari Disp(Tarmuwa)"	if SiteID==	3515110009
replace SiteName ="Koka MDG CLIN"	if SiteID==	3515110010
replace SiteName ="Koriyel HC"	if SiteID==	3515110011
replace SiteName ="Lantaiwa Disp"	if SiteID==	3515110012
replace SiteName ="Mafa MCH"	if SiteID==	3515110013
replace SiteName ="Mandadawa Disp"	if SiteID==	3515110014
replace SiteName ="Matari Disp"	if SiteID==	3515110015
replace SiteName ="Shekau Disp"	if SiteID==	3515110016
replace SiteName ="Sungul Disp"	if SiteID==	3515110017
replace SiteName ="Buhari Disp"	if SiteID==	3516110001
replace SiteName ="Bukarti Disp"	if SiteID==	3516110002
replace SiteName ="Bulabulin Disp"	if SiteID==	3516110003
replace SiteName ="Bultuwa MCH"	if SiteID==	3516110004
replace SiteName ="Dalari Disp"	if SiteID==	3516110005
replace SiteName ="Degeltura PHC"	if SiteID==	3516110006
replace SiteName ="Dekwa Disp"	if SiteID==	3516110007
replace SiteName ="Dilala Disp"	if SiteID==	3516110008
replace SiteName ="Dumbal Disp"	if SiteID==	3516110009
replace SiteName ="Garin Gada Disp"	if SiteID==	3516110010
replace SiteName ="Garin Gawo Disp (Yanusari)"	if SiteID==	3516110011
replace SiteName ="Gremari Disp"	if SiteID==	3516110012
replace SiteName ="Gursulu Disp"	if SiteID==	3516110013
replace SiteName ="Jigage Disp"	if SiteID==	3516110014
replace SiteName ="Kafiya PHC"	if SiteID==	3516110015
replace SiteName ="Kakanderi Disp (Yanusari)"	if SiteID==	3516110016
replace SiteName ="Kalgi Disp"	if SiteID==	3516110017
replace SiteName ="Kanamma Gen Hosp"	if SiteID==	3516210018
replace SiteName ="Kujari PHC"	if SiteID==	3516110019
replace SiteName ="Mairari Disp"	if SiteID==	3516110020
replace SiteName ="Manawaji H.Post"	if SiteID==	3516110021
replace SiteName ="Masta Fari H.Post"	if SiteID==	3516110022
replace SiteName ="Mozogum Disp"	if SiteID==	3516110023
replace SiteName ="Nganzai Disp"	if SiteID==	3516110024
replace SiteName ="Toshia Disp"	if SiteID==	3516110025
replace SiteName ="Wa'anga H.Post"	if SiteID==	3516110026
replace SiteName ="Yunusari Comp HC"	if SiteID==	3516110027
replace SiteName ="Yunusari HC"	if SiteID==	3516110028
replace SiteName ="Zai Disp"	if SiteID==	3516110029
replace SiteName ="Zajibiriri Disp"	if SiteID==	3516110030
replace SiteName ="Zigindimi H.Post"	if SiteID==	3516110031
replace SiteName ="Abbatura Disp"	if SiteID==	3517110001
replace SiteName ="Bula Jaji Disp"	if SiteID==	3517110002
replace SiteName ="Bula Madu Disp"	if SiteID==	3517110003
replace SiteName ="Bulatura Disp"	if SiteID==	3517110004
replace SiteName ="Gumshi Disp"	if SiteID==	3517110005
replace SiteName ="Guya Disp"	if SiteID==	3517110006
replace SiteName ="Guyamari Disp"	if SiteID==	3517110007
replace SiteName ="Jebuwa Disp"	if SiteID==	3517110008
replace SiteName ="Kachallari Disp (Yusufari)"	if SiteID==	3517110009
replace SiteName ="Kaluwa Disp"	if SiteID==	3517110010
replace SiteName ="Kaska Disp"	if SiteID==	3517110011
replace SiteName ="Kerewa Disp"	if SiteID==	3517110012
replace SiteName ="Kuka Tatawa Disp"	if SiteID==	3517110013
replace SiteName ="Kumagannam Disp"	if SiteID==	3517110014
replace SiteName ="Kumagannam Gen Hosp"	if SiteID==	3517210015
replace SiteName ="Maimalari Disp"	if SiteID==	3517110016
replace SiteName ="Masassara Disp"	if SiteID==	3517110017
replace SiteName ="Mayori Disp"	if SiteID==	3517110018
replace SiteName ="Sumbar Disp"	if SiteID==	3517110019
replace SiteName ="Tulo-Tulo Disp"	if SiteID==	3517110020
replace SiteName ="Yusufari Comp HC"	if SiteID==	3517110021
replace SiteName ="Yusufari MCH"	if SiteID==	3517110022
replace SiteName ="Yusufari Model PHC"	if SiteID==	3517110023
replace SiteName ="Zumugu Disp"	if SiteID==	3517110024

* Zamfara
replace SiteName = "Bagega PHC" if SiteID==	3601110001
replace SiteName = "Kasumka Comm Disp" if SiteID==	3601110002
replace SiteName = "Kawaye Disp" if SiteID==	3601110003
replace SiteName = "Makakari Disp" if SiteID==	3601110004
replace SiteName = "Tungar Daji Disp (Anka)" if SiteID==	3601110005
replace SiteName = "Tungar Kudaku " if SiteID==	3601110006
replace SiteName = "Barayar Zaki Primary HC" if SiteID==	3601110007
replace SiteName = "Bardi Disp" if SiteID==	3601110008
replace SiteName = "Dutsin Dan Ajiya Disp" if SiteID==	3601110009
replace SiteName = "Rafin Gero PHC" if SiteID==	3601110010
replace SiteName = "Anka WCW Clinic" if SiteID==	3601110011
replace SiteName = "Anka Psychiatric Hosp." if SiteID==	3601210012
replace SiteName = "Gargam Dispensary" if SiteID==	3601110013
replace SiteName = "Galadunci Desp." if SiteID==	3601110014
replace SiteName = "inwala Disp" if SiteID==	3601110015
replace SiteName = "Kadadabba Disp" if SiteID==	3601110016
replace SiteName = "Abare Disp" if SiteID==	3601110017
replace SiteName = "Anka GH" if SiteID==	3601210018
replace SiteName = "Anka orphans and less previlaged Clinic" if SiteID==	3601110019
replace SiteName = "Dareta Dispensary" if SiteID==	3601110020
replace SiteName = "Babban B/Maiduma Disp" if SiteID==	3601110021
replace SiteName = "Gima Disp" if SiteID==	3601110022
replace SiteName = "Girkau Disp" if SiteID==	3601110023
replace SiteName = "Kwanar Maje Disp" if SiteID==	3601110024
replace SiteName = "Manya Disp" if SiteID==	3601110025
replace SiteName = "Matseri Disp" if SiteID==	3601110026
replace SiteName = "Baudi Com Disp" if SiteID==	3601110027
replace SiteName = "Bawa Daji Disp" if SiteID==	3601110028
replace SiteName = "Duhuwa CHC" if SiteID==	3601110029
replace SiteName = "Gobirawa (Anka) Disp" if SiteID==	3601110030
replace SiteName = "Sabon birni p h c" if SiteID==	3601110031
replace SiteName = "Moda Disp" if SiteID==	3601110032
replace SiteName = "Shabli Desp." if SiteID==	3601110033
replace SiteName = "Wanu Disp" if SiteID==	3601110034
replace SiteName = "Waramu Clinic" if SiteID==	3601110035
replace SiteName = "Jarkuka Disp" if SiteID==	3601110036
replace SiteName = "Tan Garam Desp." if SiteID==	3601110037
replace SiteName = "Tsabta Disp" if SiteID==	3601110038
replace SiteName = "Wuya PHC" if SiteID==	3601110039
replace SiteName = "Yan Matankari Disp" if SiteID==	3601110040
replace SiteName = "yarsabaya Disp" if SiteID==	3601110041
replace SiteName = "Bakura General Hosp" if SiteID==	3602210001
replace SiteName = "Bakura OLP Clinic" if SiteID==	3602110002
replace SiteName = "Bakura Town Disp" if SiteID==	3602110003
replace SiteName = "Birnin Tudu Disp (Baku)" if SiteID==	3602110004
replace SiteName = "Dankaiwa Disp" if SiteID==	3602110005
replace SiteName = "Maitako Disp." if SiteID==	3602110006
replace SiteName = "Dakko Disp" if SiteID==	3602110007
replace SiteName = "Kaura Malam HC" if SiteID==	3602110008
replace SiteName = "Damri PHC" if SiteID==	3602110009
replace SiteName = "Sabon Gari Disp" if SiteID==	3602110010
replace SiteName = "Dambo Disp" if SiteID==	3602110011
replace SiteName = "Dankadu Disp" if SiteID==	3602110012
replace SiteName = "Madaci Disp" if SiteID==	3602110013
replace SiteName = "Danmanau Disp" if SiteID==	3602110014
replace SiteName = "Gamji Disp" if SiteID==	3602110015
replace SiteName = "Kwanar Kalgo Disp" if SiteID==	3602110016
replace SiteName = "Rukuma Disp" if SiteID==	3602110017
replace SiteName = "Nasarawa Disp (Nasa)" if SiteID==	3602110018
replace SiteName = "Tumba Disp" if SiteID==	3602110019
replace SiteName = "Rini Disp" if SiteID==	3602110020
replace SiteName = "Tungar Fadama Disp" if SiteID==	3602110021
replace SiteName = "Yargeda Disp" if SiteID==	3602110022
replace SiteName = "Kabawa Disp." if SiteID==	3602110023
replace SiteName = "Yarkofoji Disp" if SiteID==	3602110024
replace SiteName = "Birnin Magaji GH" if SiteID==	3603210001
replace SiteName = "Birnin Magaji WCW Clinic" if SiteID==	3603110002
replace SiteName = "Magare Disp." if SiteID==	3603110003
replace SiteName = "Orphans and Less Priv" if SiteID==	3603110004
replace SiteName = "Damfami Disp" if SiteID==	3603110005
replace SiteName = "Danwala Disp" if SiteID==	3603110006
replace SiteName = "Gidan Kasso Disp" if SiteID==	3603110007
replace SiteName = "Gidan Namaganga Disp" if SiteID==	3603110008
replace SiteName = "Sabon Birnin Disp" if SiteID==	3603110009
replace SiteName = "Shamusalle Dispensary" if SiteID==	3603110010
replace SiteName = "Gidan Bage Disp." if SiteID==	3603110011
replace SiteName = "Gora HC" if SiteID==	3603110012
replace SiteName = "Janbuzu Disp" if SiteID==	3603110013
replace SiteName = "Kannu Disp" if SiteID==	3603110014
replace SiteName = "Shagerawa Dispensary" if SiteID==	3603110015
replace SiteName = "Yauta Baki Disp" if SiteID==	3603110016
replace SiteName = "Gidan Maijanido Disp." if SiteID==	3603110017
replace SiteName = "Gusami Disp" if SiteID==	3603110018
replace SiteName = "Gidan Bajini Disp." if SiteID==	3603110019
replace SiteName = "Jela Disp" if SiteID==	3603110020
replace SiteName = "Kabuke Disp" if SiteID==	3603110021
replace SiteName = "Maikuru Disp" if SiteID==	3603110022
replace SiteName = "Murai Disp." if SiteID==	3603110023
replace SiteName = "Billashe Disp" if SiteID==	3603110024
replace SiteName = "Kirifada Galadima Disp" if SiteID==	3603110025
replace SiteName = "Tashar Shehu Disp." if SiteID==	3603110026
replace SiteName = "Challi Disp" if SiteID==	3603110027
replace SiteName = "Kirifada Gora Disp" if SiteID==	3603110028
replace SiteName = "Modomawa Clinic" if SiteID==	3603110029
replace SiteName = "Chigama Disp" if SiteID==	3603110030
replace SiteName = "Dan Dambo" if SiteID==	3603110031
replace SiteName = "Garin Kaka Disp" if SiteID==	3603110032
replace SiteName = "Kokiya Disp" if SiteID==	3603110033
replace SiteName = "Tsabre Disp" if SiteID==	3603110034
replace SiteName = "Gidan Danjuma Disp" if SiteID==	3603110035
replace SiteName = "Jar Dawa Disp." if SiteID==	3603110036
replace SiteName = "Nasarawa Godel MPHC" if SiteID==	3603110037
replace SiteName = "Dutsin Wake Disp." if SiteID==	3603110038
replace SiteName = "Karfa Disp. " if SiteID==	3603110039
replace SiteName = "Kiyawa Disp" if SiteID==	3603110040
replace SiteName = "Makera Disp (NAM)" if SiteID==	3603110041
replace SiteName = "Nasarawa Mailayi BHC" if SiteID==	3603110042
replace SiteName = "Usu Disp" if SiteID==	3603110043
replace SiteName = "Adabka PHC" if SiteID==	3604110001
replace SiteName = "Duhuwa Disp" if SiteID==	3604110002
replace SiteName = "Fasagora Disp" if SiteID==	3604110003
replace SiteName = "Birnin Waje Disp" if SiteID==	3604110004
replace SiteName = "Bukkuyum Gen Hosp" if SiteID==	3604110005
replace SiteName = "Bukkuyum OPC" if SiteID==	3604110006
replace SiteName = "Bukkuyum WCWC" if SiteID==	3604110007
replace SiteName = "Masu Disp" if SiteID==	3604110008
replace SiteName = "Akawo Disp" if SiteID==	3604110009
replace SiteName = "Gando Disp" if SiteID==	3604110010
replace SiteName = "Gwashi PHC" if SiteID==	3604110011
replace SiteName = "R/Baba Disp" if SiteID==	3604110012
replace SiteName = "G/Zaima Disp" if SiteID==	3604110013
replace SiteName = "Kairu Clinic" if SiteID==	3604110014
replace SiteName = "Kyaram PHC" if SiteID==	3604110015
replace SiteName = "Ruwan Kura Disp" if SiteID==	3604110016
replace SiteName = "Wawan Icce Disp" if SiteID==	3604110017
replace SiteName = "Zugu Disp" if SiteID==	3604110018
replace SiteName = "Masama Disp" if SiteID==	3604110019
replace SiteName = "Rukumawa Disp" if SiteID==	3604110020
replace SiteName = "S/Tunga Disp" if SiteID==	3604110021
replace SiteName = "Gana Disp" if SiteID==	3604110022
replace SiteName = "Gurusu Disp" if SiteID==	3604110023
replace SiteName = "Hillani Disp" if SiteID==	3604110024
replace SiteName = "Kamaru T/Rogo Disp" if SiteID==	3604110025
replace SiteName = "Nasarawa Private Clinic" if SiteID==	3604120026
replace SiteName = "Nasarawa PHC" if SiteID==	3604110027
replace SiteName = "Rafin Maiki Disp" if SiteID==	3604110028
replace SiteName = "Ruwan Jema PHC" if SiteID==	3604110029
replace SiteName = "Balala Disp." if SiteID==	3604110030
replace SiteName = "Ruwan Rana Disp" if SiteID==	3604110031
replace SiteName = "Yashi Disp" if SiteID==	3604110032
replace SiteName = "Dangurunfa HC" if SiteID==	3604110033
replace SiteName = "Dargaje Dip" if SiteID==	3604110034
replace SiteName = "Ranfashi Disp" if SiteID==	3604110035
replace SiteName = "Tashar Taya Disp" if SiteID==	3604110036
replace SiteName = "Yargalma Disp" if SiteID==	3604110037
replace SiteName = "Zarummai HC" if SiteID==	3604110038
replace SiteName = "Birnin Zauma HC" if SiteID==	3604110039
replace SiteName = "T/Maigunya Disp" if SiteID==	3604110040
replace SiteName = "Yandu Disp." if SiteID==	3604110041
replace SiteName = "Asako Disp" if SiteID==	3605110001
replace SiteName = "Bela HC" if SiteID==	3605110002
replace SiteName = "Kaida Disp" if SiteID==	3605110003
replace SiteName = "Lango Disp" if SiteID==	3605110004
replace SiteName = "Marke (Bungudu) Disp" if SiteID==	3605110005
replace SiteName = "Tashar Rawayya" if SiteID==	3605110006
replace SiteName = "Rawayya HC" if SiteID==	3605110007
replace SiteName = "Yarlabe Disp" if SiteID==	3605110008
replace SiteName = "Bingi HC" if SiteID==	3605110009
replace SiteName = "Gidan Saro PHC" if SiteID==	3605110010
replace SiteName = "Kangon Sabuwal Disp" if SiteID==	3605110011
replace SiteName = "Kekun Waje HC" if SiteID==	3605110012
replace SiteName = "Kuya Dispensary" if SiteID==	3605110013
replace SiteName = "Maje Disp" if SiteID==	3605110014
replace SiteName = "Mashema Disp" if SiteID==	3605110015
replace SiteName = "Yarkatsina Disp" if SiteID==	3605110016
replace SiteName = "Burai Disp" if SiteID==	3605110017
replace SiteName = "Kangon Marafa Disp" if SiteID==	3605110018
replace SiteName = "Kungurmi Disp" if SiteID==	3605110019
replace SiteName = "Kurar Mota Disp" if SiteID==	3605110020
replace SiteName = "Landai Disp" if SiteID==	3605110021
replace SiteName = "Makwa Disp" if SiteID==	3605110022
replace SiteName = "Tungar Dorowa Disp." if SiteID==	3605110023
replace SiteName = "Yarwutsiya Disp." if SiteID==	3605110024
replace SiteName = "Birnin Malam Disp" if SiteID==	3605110025
replace SiteName = "Bungudu Gen Hosp" if SiteID==	3605210026
replace SiteName = "Bungudu Wcwc" if SiteID==	3605110027
replace SiteName = "Bungudu Approved School Disp." if SiteID==	3605110028
replace SiteName = "Bungudu Orphans and Less Previlaged Clinic" if SiteID==	3605110029
replace SiteName = "Gidan Dangwari Disp" if SiteID==	3605110030
replace SiteName = "Saye Disp" if SiteID==	3605110031
replace SiteName = "UDSS Bungudu Disp." if SiteID==	3605110032
replace SiteName = "Yartukunya Disp" if SiteID==	3605110033
replace SiteName = "Auki Disp" if SiteID==	3605110034
replace SiteName = "Fantaru Disp" if SiteID==	3605110035
replace SiteName = "Furfuri HC" if SiteID==	3605110036
replace SiteName = "Gidan Dan inna Disp" if SiteID==	3605110037
replace SiteName = "Madidi Disp" if SiteID==	3605110038
replace SiteName = "Kukan Nini Disp." if SiteID==	3605110039
replace SiteName = "Runji Disp" if SiteID==	3605110040
replace SiteName = "Birnin Yanruwa Disp" if SiteID==	3605110041
replace SiteName = "Danmagori Disp" if SiteID==	3605110042
replace SiteName = "Danmarke PHC" if SiteID==	3605110043
replace SiteName = "Gada HC" if SiteID==	3605110044
replace SiteName = "Kananami Disp" if SiteID==	3605110045
replace SiteName = "Karakai HC" if SiteID==	3605110046
replace SiteName = "Kurhi Disp" if SiteID==	3605110047
replace SiteName = "Aisha Disp" if SiteID==	3605110048
replace SiteName = "Gulubba Disp" if SiteID==	3605110049
replace SiteName = "Kohi Disp" if SiteID==	3605110050
replace SiteName = "Kotorkoshi HC" if SiteID==	3605110051
replace SiteName = "Kotorkoshi OLP PHC" if SiteID==	3605110052
replace SiteName = "Tazame Disp" if SiteID==	3605110053
replace SiteName = "Danguro Disp" if SiteID==	3605110054
replace SiteName = "Dogondaji Disp" if SiteID==	3605110055
replace SiteName = "Nahuche PHC" if SiteID==	3605110056
replace SiteName = "Dashi Clinic" if SiteID==	3605110057
replace SiteName = "Samawa HC" if SiteID==	3605110058
replace SiteName = "GGUSS Disp" if SiteID==	3605110059
replace SiteName = "Ribe Disp." if SiteID==	3605110060
replace SiteName = "Sankalawa HC" if SiteID==	3605110061
replace SiteName = "Gamawa Disp" if SiteID==	3605110062
replace SiteName = "Tofa Clinic" if SiteID==	3605110063
replace SiteName = "Birnin Magaji Disp" if SiteID==	3606110001
replace SiteName = "Kwammaka Disp" if SiteID==	3606110002
replace SiteName = "Babban Rafi Disp" if SiteID==	3606110003
replace SiteName = "Bardoki Disp" if SiteID==	3606110004
replace SiteName = "Barikin Daji Disp" if SiteID==	3606110005
replace SiteName = "Gwalli Disp" if SiteID==	3606110006
replace SiteName = "Birnin Tudu Disp (Gummi)" if SiteID==	3606110007
replace SiteName = "Daki Takwas Disp" if SiteID==	3606110008
replace SiteName = "Leshi Disp" if SiteID==	3606110009
replace SiteName = "Nasarawa Disp (B Tudu)" if SiteID==	3606110010
replace SiteName = "T Wakaso Disp" if SiteID==	3606110011
replace SiteName = "Falale Disp" if SiteID==	3606110012
replace SiteName = "Iyaka Disp" if SiteID==	3606110013
replace SiteName = "Gamo Disp" if SiteID==	3606110014
replace SiteName = "Jabaka Disp (Gamo)" if SiteID==	3606110015
replace SiteName = "Adarawa Disp" if SiteID==	3606110016
replace SiteName = "Dakawa Disp" if SiteID==	3606110017
replace SiteName = "Gayari Up Graded Disp" if SiteID==	3606110018
replace SiteName = "Dangwai Disp" if SiteID==	3606110019
replace SiteName = "Gabtu Disp" if SiteID==	3606110020
replace SiteName = "Gyalange Disp" if SiteID==	3606110021
replace SiteName = "Falan Birni Disp" if SiteID==	3606110022
replace SiteName = "Gambanda Magiro disp" if SiteID==	3606110023
replace SiteName = "Kurfa Disp" if SiteID==	3606110024
replace SiteName = "Taka-Tsaba Disp" if SiteID==	3606110025
replace SiteName = "Amanawa Disp" if SiteID==	3606110026
replace SiteName = "Gummi G/H" if SiteID==	3606210027
replace SiteName = "Gummi Orphans And Less Previlaged" if SiteID==	3606110028
replace SiteName = "Gummi Town Disp" if SiteID==	3606110029
replace SiteName = "Gummi MCH HC" if SiteID==	3606110030
replace SiteName = "Lema Babba Disp" if SiteID==	3606110031
replace SiteName = "Dan Fako Disp" if SiteID==	3606110032
replace SiteName = "Gidan Kade Disp" if SiteID==	3606110033
replace SiteName = "100 Housing Clinic" if SiteID==	3607110001
replace SiteName = "Gusau Gen Hosp" if SiteID==	3607210002
replace SiteName = "Gusau FMC" if SiteID==	3607310003
replace SiteName = "Gusau Medical Clinic" if SiteID==	3607120004
replace SiteName = "Gusau Orphans an Less Previlaged" if SiteID==	3607210005
replace SiteName = "Government House Clinic" if SiteID==	3607110006
replace SiteName = "Hayin M/Ibrahim Clinic" if SiteID==	3607110007
replace SiteName = "Jakiri Community Desp." if SiteID==	3607110008
replace SiteName = "Jakiri Desp." if SiteID==	3607110009
replace SiteName = "Kwata WCWC" if SiteID==	3607110010
replace SiteName = "Science Secondary ScHC" if SiteID==	3607110011
replace SiteName = "Takama Janyau Clinic" if SiteID==	3607110012
replace SiteName = "Zacas Clinic" if SiteID==	3607110013
replace SiteName = "Chediya Ukku Desp." if SiteID==	3607110014
replace SiteName = "Kasharuwa Disp" if SiteID==	3607110015
replace SiteName = "Kofar Mani Clinic" if SiteID==	3607110016
replace SiteName = "Kolo Desp." if SiteID==	3607110017
replace SiteName = "Shagari Clinic" if SiteID==	3607110018
replace SiteName = "Unguwar  Mangwaro Desp." if SiteID==	3607110019
replace SiteName = "Fegin Mahe Disp" if SiteID==	3607110020
replace SiteName = "Kundumao Desp." if SiteID==	3607110021
replace SiteName = "Lafiya Clinic" if SiteID==	3607110022
replace SiteName = "Maijatau Desp." if SiteID==	3607120023
replace SiteName = "Ruwan Bore Disp (R Bore)" if SiteID==	3607110024
replace SiteName = "Takokai Clinic" if SiteID==	3607110025
replace SiteName = "Arewa Hospital" if SiteID==	3607120026
replace SiteName = "Bamaiyi Clinic" if SiteID==	3607120027
replace SiteName = "Fatima Private Clinic" if SiteID==	3607120028
replace SiteName = "Madan Karo Clinic" if SiteID==	3607110029
replace SiteName = "Mallaha C" if SiteID==	3607120030
replace SiteName = "Rama Hospital" if SiteID==	3607120031
replace SiteName = "Sabo Gari C" if SiteID==	3607120032
replace SiteName = "Agwai Desp." if SiteID==	3607110033
replace SiteName = "Dr Mustapha Private Clinic" if SiteID==	3607120034
replace SiteName = "Duddugel Clinic" if SiteID==	3607110035
replace SiteName = "Gonar Wake Desp." if SiteID==	3607110036
replace SiteName = "Mada Gen Hosp" if SiteID==	3607210037
replace SiteName = "Mada PHC" if SiteID==	3607110038
replace SiteName = "Shemori Disp" if SiteID==	3607110039
replace SiteName = "Tsuna Clinic" if SiteID==	3607110040
replace SiteName = "Tsuna Clinic" if SiteID==	3607110041
replace SiteName = "Abarma Clinic" if SiteID==	3607110042
replace SiteName = "Gada Biyu" if SiteID==	3607110043
replace SiteName = "Madidi Disp" if SiteID==	3607110044
replace SiteName = "Kango Disp" if SiteID==	3607110045
replace SiteName = "Madaba Disp" if SiteID==	3607110046
replace SiteName = "Magami PHC" if SiteID==	3607110047
replace SiteName = "KunKelai Desp." if SiteID==	3607110048
replace SiteName = "Ruwan Dawa Disp" if SiteID==	3607110049
replace SiteName = "Yargada Clinic" if SiteID==	3607110050
replace SiteName = "Agama Lafiya Disp" if SiteID==	3607110051
replace SiteName = "G/Fakai Clinic" if SiteID==	3607110052
replace SiteName = "za Rijiya Clinic" if SiteID==	3607110053
replace SiteName = "Cakal Desp." if SiteID==	3607110054
replace SiteName = "Damba Clinic" if SiteID==	3607110055
replace SiteName = "Daula Private Hosp" if SiteID==	3607220056
replace SiteName = "Gidan Maryam Clinic" if SiteID==	3607110057
replace SiteName = "Gusau FCET Clinic" if SiteID==	3607110058
replace SiteName = "Gusau Poly Clinic" if SiteID==	3607120059
replace SiteName = "Karazau Desp." if SiteID==	3607110060
replace SiteName = "Sauki Clinic" if SiteID==	3607120061
replace SiteName = "Tudun Wada MCHC" if SiteID==	3607110062
replace SiteName = "King Fahad WCWC" if SiteID==	3607210063
replace SiteName = "Gidan Ango Desp." if SiteID==	3607110064
replace SiteName = "Gidan Gabi Clinic" if SiteID==	3607110065
replace SiteName = "Jangeme Disp" if SiteID==	3607110066
replace SiteName = "Karal Disp" if SiteID==	3607110067
replace SiteName = "Madaro Disp" if SiteID==	3607110068
replace SiteName = "Wanke PHC" if SiteID==	3607110069
replace SiteName = "Akuzo Desp." if SiteID==	3607110070
replace SiteName = "Bawo Desp." if SiteID==	3607110071
replace SiteName = "Fagen Kanawa" if SiteID==	3607110072
replace SiteName = "Furagirke " if SiteID==	3607110073
replace SiteName = "Furagirke Desp." if SiteID==	3607110074
replace SiteName = "Furagirke Desp." if SiteID==	3607110075
replace SiteName = "Kamari Disp" if SiteID==	3607110076
replace SiteName = "Lilo Disp" if SiteID==	3607110077
replace SiteName = "Rafi Disp" if SiteID==	3607110078
replace SiteName = "Togai Comm Disp" if SiteID==	3607110079
replace SiteName = "Wonaka Disp" if SiteID==	3607110080
replace SiteName = "ASYBS Hosp" if SiteID==	3607210081
replace SiteName = "Banga PHC" if SiteID==	3608110001
replace SiteName = "Katsara Disp" if SiteID==	3608110002
replace SiteName = "Kawari Disp" if SiteID==	3608110003
replace SiteName = "Kogi Disp" if SiteID==	3608110004
replace SiteName = "Rahazawa Disp" if SiteID==	3608110005
replace SiteName = "Dan Isa Disp" if SiteID==	3608110006
replace SiteName = "Dogon Kade Disp" if SiteID==	3608110007
replace SiteName = "Mailallen Jarkasa Disp" if SiteID==	3608110008
replace SiteName = "Sodingo Disp" if SiteID==	3608110009
replace SiteName = "Agira Dispensary" if SiteID==	3608110010
replace SiteName = "Garbawa Disp" if SiteID==	3608110011
replace SiteName = "Magizawa Disp" if SiteID==	3608110012
replace SiteName = "Bungudawa Disp" if SiteID==	3608110013
replace SiteName = "Falau Disp" if SiteID==	3608110014
replace SiteName = "Mailallan Nagona C Disp" if SiteID==	3608110015
replace SiteName = "Rututu Disp" if SiteID==	3608110016
replace SiteName = "Tundu Wada Rahazawa Disp" if SiteID==	3608110017
replace SiteName = "Allahuwa Disp" if SiteID==	3608110018
replace SiteName = "Dabah CD" if SiteID==	3608110019
replace SiteName = "Dayau CD" if SiteID==	3608110020
replace SiteName = "Fagoji Disp" if SiteID==	3608110021
replace SiteName = "Kungurki Disp" if SiteID==	3608110022
replace SiteName = "Madira Community Disp" if SiteID==	3608110023
replace SiteName = "Niima Clinic (S Gari)" if SiteID==	3608120024
replace SiteName = "S/Gari (K_Namoda) Disp" if SiteID==	3608110025
replace SiteName = "Walo Disp" if SiteID==	3608110026
replace SiteName = "Kofa Dis" if SiteID==	3608110027
replace SiteName = "Kurya PHC" if SiteID==	3608110028
replace SiteName = "Sake Disp" if SiteID==	3608110029
replace SiteName = "T/Mudi Comm Disp (Kofa)" if SiteID==	3608110030
replace SiteName = "Tungar Haruna Disp" if SiteID==	3608110031
replace SiteName = "Bunaje Disp" if SiteID==	3608110032
replace SiteName = "Famfifi Disp" if SiteID==	3608110033
replace SiteName = "Kasuwar Daji PHC" if SiteID==	3608110034
replace SiteName = "Kyanbarawa Disp" if SiteID==	3608110035
replace SiteName = "Maguru Disp" if SiteID==	3608110036
replace SiteName = "Tukasu Disp" if SiteID==	3608110037
replace SiteName = "Abaniyawa Disp" if SiteID==	3608110038
replace SiteName = "Badako Disp" if SiteID==	3608110039
replace SiteName = "Dokau Community Disp" if SiteID==	3608110040
replace SiteName = "Sakajiki Disp" if SiteID==	3608110041
replace SiteName = "U Sakin Musulimi Clinic" if SiteID==	3608110042
replace SiteName = "Yamatsawa Community Disp" if SiteID==	3608110043
replace SiteName = "Bula Dispensary" if SiteID==	3608110044
replace SiteName = "Gidan Ajinna Disp" if SiteID==	3608110045
replace SiteName = "GRA Clinic" if SiteID==	3608110046
replace SiteName = "K Namoda WCW Clinic" if SiteID==	3608110047
replace SiteName = "K/Namoda Ganeral Hosp" if SiteID==	3608110048
replace SiteName = "K/Namoda OLP Clinic" if SiteID==	3608110049
replace SiteName = "Kaura Namoda Town Disp" if SiteID==	3608110050
replace SiteName = "K/Namoda Poly Clinic" if SiteID==	3608110051
replace SiteName = "Tankwaren Daji Disp" if SiteID==	3608110052
replace SiteName = "Tungar Dorowa Disp" if SiteID==	3608110053
replace SiteName = "Barkeji Disp" if SiteID==	3608110054
replace SiteName = "Yan Ruma Com Disp" if SiteID==	3608110055
replace SiteName = "Yankaba PHC" if SiteID==	3608110056
replace SiteName = "Yar Dole Comm Disp" if SiteID==	3608110057
replace SiteName = "Gabake Dan Maliki Disp" if SiteID==	3608110058
replace SiteName = "Gabake Mesa Disp" if SiteID==	3608110059
replace SiteName = "Getso Disp" if SiteID==	3608110060
replace SiteName = "Magami Community Disp" if SiteID==	3608110061
replace SiteName = "Damaga Disp" if SiteID==	3609110001
replace SiteName = "Gama Giwa Disp" if SiteID==	3609110002
replace SiteName = "Gwabro Disp" if SiteID==	3609110003
replace SiteName = "Zamangira Disp" if SiteID==	3609110004
replace SiteName = "Birnin Kaya Dispensary" if SiteID==	3609110005
replace SiteName = "Danbaza HC" if SiteID==	3609110006
replace SiteName = "Danbaza Desp." if SiteID==	3609110007
replace SiteName = "Dosara Disp" if SiteID==	3609110008
replace SiteName = "Fallau Disp" if SiteID==	3609110009
replace SiteName = "Gilliba Disp" if SiteID==	3609110010
replace SiteName = "Alfarm Clinic(faru/magami)" if SiteID==	3609110011
replace SiteName = "Danau Disp" if SiteID==	3609110012
replace SiteName = "Ellenkwashe Desp." if SiteID==	3609110013
replace SiteName = "Faru Upgraded PHC" if SiteID==	3609110014
replace SiteName = "Gidan Adamu Disp" if SiteID==	3609110015
replace SiteName = "Kuzi Disp" if SiteID==	3609110016
replace SiteName = "Magami Dispensary" if SiteID==	3609110017
replace SiteName = "Rudunu Disp" if SiteID==	3609110018
replace SiteName = "Ruwan Bado Disp" if SiteID==	3609110019
replace SiteName = "Sabon Sara Disp" if SiteID==	3609110020
replace SiteName = "Dan Rini Gidan Goga Disp" if SiteID==	3609110021
replace SiteName = "Gidan Goga PHC" if SiteID==	3609110022
replace SiteName = "Magara Dispensary" if SiteID==	3609110023
replace SiteName = "Malikawa Disp" if SiteID==	3609110024
replace SiteName = "Gidan Zama Disp" if SiteID==	3609110025
replace SiteName = "Gora PHC" if SiteID==	3609110026
replace SiteName = "Maijatau Disp" if SiteID==	3609110027
replace SiteName = "Manasa Disp" if SiteID==	3609110028
replace SiteName = "Illela Desp." if SiteID==	3609110029
replace SiteName = "Kadage Disp" if SiteID==	3609110030
replace SiteName = "Kakin Dawa Disp" if SiteID==	3609110031
replace SiteName = "Kaya PHC" if SiteID==	3609110032
replace SiteName = "Kingidahe Disp" if SiteID==	3609110033
replace SiteName = "Sububu Disp" if SiteID==	3609110034
replace SiteName = "Takalmawa PHC" if SiteID==	3609110035
replace SiteName = "Aljimma Disp" if SiteID==	3609110036
replace SiteName = "Gidan Dawa Disp" if SiteID==	3609110037
replace SiteName = "Kofar Kyarawa Desp." if SiteID==	3609110038
replace SiteName = "Shandame (Jihiya) Disp" if SiteID==	3609110039
replace SiteName = "Maradun General Hosp" if SiteID==	3609210040
replace SiteName = "Maradun Town Disp" if SiteID==	3609110041
replace SiteName = "Maradun WCWC" if SiteID==	3609110042
replace SiteName = "Maradun OLP" if SiteID==	3609110043
replace SiteName = "Tungar Magaji Disp" if SiteID==	3609110044
replace SiteName = "Sabon Gida Dispensary" if SiteID==	3609110045
replace SiteName = "Tsibiri Dispensary" if SiteID==	3609110046
replace SiteName = "Babera Disp" if SiteID==	3609110047
replace SiteName = "Badiyiwa Desp." if SiteID==	3609110048
replace SiteName = "Janbako Upgraded Dispensa" if SiteID==	3609110049
replace SiteName = "Sakkida Bayan Dutse Disp" if SiteID==	3609110050
replace SiteName = "Sakkida Fulani Disp" if SiteID==	3609110051
replace SiteName = "Bakin Dutsi Disp" if SiteID==	3610110001
replace SiteName = "Bakin Gulbi Desp." if SiteID==	3610110002
replace SiteName = "Bindin BHC" if SiteID==	3610110003
replace SiteName = "Gobirawa (Maru) Disp" if SiteID==	3610110004
replace SiteName = "Lingyado Disp" if SiteID==	3610110005
replace SiteName = "Bingi Disp" if SiteID==	3610110006
replace SiteName = "Bini Disp" if SiteID==	3610110007
replace SiteName = "Borwaye Disp" if SiteID==	3610110008
replace SiteName = "Bozaya Disp" if SiteID==	3610110009
replace SiteName = "Gabiya Comm Disp" if SiteID==	3610110010
replace SiteName = "Malamawa Comm Disp" if SiteID==	3610110011
replace SiteName = "Dan Maaji Disp" if SiteID==	3610110012
replace SiteName = "Dangulbi PHC" if SiteID==	3610110013
replace SiteName = "Kwana Desp." if SiteID==	3610110014
replace SiteName = "Tasha Disp" if SiteID==	3610110015
replace SiteName = "Tsuntsomawa Disp" if SiteID==	3610110016
replace SiteName = "Wabi Disp" if SiteID==	3610110017
replace SiteName = "Barebari Disp" if SiteID==	3610110018
replace SiteName = "Dankurmi Disp" if SiteID==	3610110019
replace SiteName = "Dogon Daji Disp" if SiteID==	3610110020
replace SiteName = "Farin Ruwan Disp" if SiteID==	3610110021
replace SiteName = "Gestso Disp" if SiteID==	3610110022
replace SiteName = "Maimarahu Disp" if SiteID==	3610110023
replace SiteName = "Zamfarawa Disp" if SiteID==	3610110024
replace SiteName = "Dandalla Disp" if SiteID==	3610110025
replace SiteName = "Dansadau Gen Hosp" if SiteID==	3610210026
replace SiteName = "Dansadau MCHC" if SiteID==	3610110027
replace SiteName = "Dansadau OLP" if SiteID==	3610110028
replace SiteName = "Kabaro Desp." if SiteID==	3610110029
replace SiteName = "Madaka Desp." if SiteID==	3610110030
replace SiteName = "Maganawa Desp." if SiteID==	3610110031
replace SiteName = "Mutunji Disp" if SiteID==	3610110032
replace SiteName = "Saulawa Desp." if SiteID==	3610110033
replace SiteName = "U Galadima Comm Disp" if SiteID==	3610110034
replace SiteName = "Yartasha Disp" if SiteID==	3610110035
replace SiteName = "Birni Disp" if SiteID==	3610110036
replace SiteName = "Dutsingari Disp" if SiteID==	3610110037
replace SiteName = "Kanoma PHC" if SiteID==	3610110038
replace SiteName = "Kwantaragi Comm Disp" if SiteID==	3610110039
replace SiteName = "Tsibiri Comm Disp" if SiteID==	3610110040
replace SiteName = "Zaman Gira Disp" if SiteID==	3610110041
replace SiteName = "Babba Doka Comm Disp" if SiteID==	3610110042
replace SiteName = "Chabi Comm Disp" if SiteID==	3610110043
replace SiteName = "Dangurgu Desp." if SiteID==	3610110044
replace SiteName = "Famaje Disp" if SiteID==	3610110045
replace SiteName = "Madada Comm Disp" if SiteID==	3610110046
replace SiteName = "Maigoge Comm Disp" if SiteID==	3610110047
replace SiteName = "Mailalle Comm Disp" if SiteID==	3610110048
replace SiteName = "Rawan Tofa" if SiteID==	3610110049
replace SiteName = "Sangeku Disp" if SiteID==	3610110050
replace SiteName = "Jabaka Disp (Maru)" if SiteID==	3610110051
replace SiteName = "Kadauri Disp" if SiteID==	3610110052
replace SiteName = "Lugga Comm Disp" if SiteID==	3610110053
replace SiteName = "Maru Gen Hosp" if SiteID==	3610210054
replace SiteName = "Maru OLP" if SiteID==	3610110055
replace SiteName = "Maru MCHC" if SiteID==	3610110056
replace SiteName = "Mayanchi BHC" if SiteID==	3610110057
replace SiteName = "Mayanchi Disp" if SiteID==	3610110058
replace SiteName = "Arafa Disp" if SiteID==	3610110059
replace SiteName = "Difgawa Clinic" if SiteID==	3610110060
replace SiteName = "Kadadaba Disp" if SiteID==	3610110061
replace SiteName = "Ruwan Doruwa PHC" if SiteID==	3610110062
replace SiteName = "Badarawa Disp" if SiteID==	3611110001
replace SiteName = "T/Kado Disp" if SiteID==	3611110002
replace SiteName = "Birnin Yaro Disp" if SiteID==	3611110003
replace SiteName = "Maiwa HC" if SiteID==	3611110004
replace SiteName = "Tubali Disp" if SiteID==	3611110005
replace SiteName = "Batauna Disp" if SiteID==	3611110006
replace SiteName = "Bula Disp" if SiteID==	3611110007
replace SiteName = "G/Rijiya Disp" if SiteID==	3611110008
replace SiteName = "Galadi PHC" if SiteID==	3611110009
replace SiteName = "T/Bore Disp" if SiteID==	3611110010
replace SiteName = "Baje Disp" if SiteID==	3611110011
replace SiteName = "Jangeru PHC (Shinkafi)" if SiteID==	3611110012
replace SiteName = "Kayaye (J 3) Disp" if SiteID==	3611110013
replace SiteName = "Amallamawa Disp" if SiteID==	3611110014
replace SiteName = "G/soja HC" if SiteID==	3611110015
replace SiteName = "Januhu Disp" if SiteID==	3611110016
replace SiteName = "Kafin Mazuga Disp" if SiteID==	3611110017
replace SiteName = "Katuru Disp" if SiteID==	3611110018
replace SiteName = "T/Kafau disp" if SiteID==	3611110019
replace SiteName = "Bagare Disp" if SiteID==	3611110020
replace SiteName = "Dakwarawa Disp" if SiteID==	3611110021
replace SiteName = "Fakai HC" if SiteID==	3611110022
replace SiteName = "Gangara Disp (Kurya)" if SiteID==	3611110023
replace SiteName = "Gidan bugaje com disp" if SiteID==	3611110024
replace SiteName = "Katsira HC" if SiteID==	3611110025
replace SiteName = "Kurya Disp" if SiteID==	3611110026
replace SiteName = "Asarara Disp" if SiteID==	3611110027
replace SiteName = "Atarawa Disp" if SiteID==	3611110028
replace SiteName = "Kukar Banda Disp" if SiteID==	3611110029
replace SiteName = "Kursasa Disp" if SiteID==	3611110030
replace SiteName = "Kware PHC" if SiteID==	3611110031
replace SiteName = "ajiyawa disp" if SiteID==	3611110032
replace SiteName = "Shanawa Disp" if SiteID==	3611110033
replace SiteName = "Shinkafi Gen Hosp" if SiteID==	3611210034
replace SiteName = "Shinkafi WCW Clinic" if SiteID==	3611110035
replace SiteName = "Mabaraya Disp" if SiteID==	3611110036
replace SiteName = "s/gari disp skf" if SiteID==	3611110037
replace SiteName = "Shinkafi OLPC" if SiteID==	3611110038
replace SiteName = "Colony Disp" if SiteID==	3612110001
replace SiteName = "GGSS H/C" if SiteID==	3612110002
replace SiteName = "Talata Mafara Gen Hosp" if SiteID==	3612210003
replace SiteName = "Tala Mafara OLPHC" if SiteID==	3612110004
replace SiteName = "Garbadu Disp" if SiteID==	3612110005
replace SiteName = "T/Bai Disp" if SiteID==	3612110006
replace SiteName = "Bobo Disp" if SiteID==	3612110007
replace SiteName = "Gidan Haki Disp" if SiteID==	3612110008
replace SiteName = "Gidankane Disp" if SiteID==	3612110009
replace SiteName = "Gwaram Disp" if SiteID==	3612110010
replace SiteName = "Jangebe PHC" if SiteID==	3612110011
replace SiteName = "Mashaya Desp." if SiteID==	3612110012
replace SiteName = "Maikwanugga Disp" if SiteID==	3612110013
replace SiteName = "Dankwato Disp" if SiteID==	3612110014
replace SiteName = "Kagara Gen Hosp" if SiteID==	3612110015
replace SiteName = "Bakin Zaji Disp" if SiteID==	3612110016
replace SiteName = "Duduma Disp" if SiteID==	3612110017
replace SiteName = "Matusgi Disp" if SiteID==	3612110018
replace SiteName = "Tunfafiya Disp" if SiteID==	3612110019
replace SiteName = "Tungar Miya Disp" if SiteID==	3612110020
replace SiteName = "Ware Damtse Disp" if SiteID==	3612110021
replace SiteName = "Gidan Rashi Disp" if SiteID==	3612110022
replace SiteName = "Hura Disp" if SiteID==	3612110023
replace SiteName = "Makera Disp (NAM)" if SiteID==	3612110024
replace SiteName = "Take Tsaba Disp (MTT)" if SiteID==	3612110025
replace SiteName = "Talata Mafara WCW Clinic" if SiteID==	3612110026
replace SiteName = "Tungar Waje Disp" if SiteID==	3612110027
replace SiteName = "Kuka Mairahu Disp" if SiteID==	3612110028
replace SiteName = "Garki Yahaya Desp." if SiteID==	3612110029
replace SiteName = "Morai PHC" if SiteID==	3612110030
replace SiteName = "Sado Disp" if SiteID==	3612110031
replace SiteName = "Morkidi Disp" if SiteID==	3612110032
replace SiteName = "Ruwan Bore Disp (MR Bore)" if SiteID==	3612110033
replace SiteName = "Barikin Daji Disp (RG)" if SiteID==	3612110034
replace SiteName = "Mirkidi Desp (RG)" if SiteID==	3612110035
replace SiteName = "Ruwan Gizo PHC" if SiteID==	3612110036
replace SiteName = "Zauren Gora Disp" if SiteID==	3612110037
replace SiteName = "Dan Kabale Desp." if SiteID==	3612110038
replace SiteName = "Dan Kalgo Desp." if SiteID==	3612110039
replace SiteName = "Duhun Karki Desp." if SiteID==	3612110040
replace SiteName = "Gora Daji Disp" if SiteID==	3612110041
replace SiteName = "Kwandawa Desp" if SiteID==	3612110042
replace SiteName = "Matuna Desp." if SiteID==	3612110043
replace SiteName = "Ruwan Gora Disp" if SiteID==	3612110044
replace SiteName = "Sakarawa Desp." if SiteID==	3612110045
replace SiteName = "Sauna Disp" if SiteID==	3612110046
replace SiteName = "Tungar Sadau Disp" if SiteID==	3612110047
replace SiteName = "Unguwar Shanu Disp" if SiteID==	3612110048
replace SiteName = "Bilbis PHC" if SiteID==	3613110001
replace SiteName = "Kucheri Disp" if SiteID==	3613110002
replace SiteName = "Magazu MPHC" if SiteID==	3613110003
replace SiteName = "Magazawa Desp." if SiteID==	3613110004
replace SiteName = "Ung Dan Halima Disp" if SiteID==	3613110005
replace SiteName = "Wanzamai Disp" if SiteID==	3613110006
replace SiteName = "Bakin Manya Disp" if SiteID==	3613110007
replace SiteName = "Chediya PHC" if SiteID==	3613110008
replace SiteName = "Doka Disp - Chediya" if SiteID==	3613110009
replace SiteName = "Danjibga Disp" if SiteID==	3613110010
replace SiteName = "Kizara Disp" if SiteID==	3613110011
replace SiteName = "Kunchin Kalgo Disp" if SiteID==	3613110012
replace SiteName = "Kwalfada Disp" if SiteID==	3613110013
replace SiteName = "Munhaye Desp." if SiteID==	3613110014
replace SiteName = "Sabon Garin Dutse Kura  Disp" if SiteID==	3613110015
replace SiteName = "Unguwar Gyauro Disp" if SiteID==	3613110016
replace SiteName = "Yarzaiga Desp." if SiteID==	3613110017
replace SiteName = "Bedi Disp" if SiteID==	3613110018
replace SiteName = "Dauki Disp" if SiteID==	3613110019
replace SiteName = "Bawa Ganga Disp" if SiteID==	3613110020
replace SiteName = "Dangulbi Desp." if SiteID==	3613110021
replace SiteName = "Kwaren Ganuwa Disp" if SiteID==	3613110022
replace SiteName = "Marbe Clinic" if SiteID==	3613110023
replace SiteName = "Musawa Disp" if SiteID==	3613110024
replace SiteName = "Keta PHC" if SiteID==	3613110025
replace SiteName = "Maitoshshi Disp" if SiteID==	3613110026
replace SiteName = "Babban Kauye Desp." if SiteID==	3613110027
replace SiteName = "Fagen Baza Desp." if SiteID==	3613110028
replace SiteName = "Gangara Desp." if SiteID==	3613110029
replace SiteName = "Kyauyen Kane Desp." if SiteID==	3613110030
replace SiteName = "Rahama Clinic" if SiteID==	3613110031
replace SiteName = "Rakyabu Disp" if SiteID==	3613110032
replace SiteName = "Sungawa Disp" if SiteID==	3613110033
replace SiteName = "Tsafe  OLPH" if SiteID==	3613110034
replace SiteName = "Tsafe General Hosp" if SiteID==	3613210035
replace SiteName = "Tsafe GSS Clinic" if SiteID==	3613110036
replace SiteName = "Tsafe WCWC" if SiteID==	3613110037
replace SiteName = "Bayan Banki Disp" if SiteID==	3613110038
replace SiteName = "Biyabiki Disp" if SiteID==	3613110039
replace SiteName = "Gidan Dawa Disp (Yand)" if SiteID==	3613110040
replace SiteName = "Langa Langa Disp" if SiteID==	3613110041
replace SiteName = "Marke Disp" if SiteID==	3613110042
replace SiteName = "U/ Dan Umma Desp." if SiteID==	3613110043
replace SiteName = "Yandoto Disp" if SiteID==	3613110044
replace SiteName = "Malamawa Disp" if SiteID==	3613110045
replace SiteName = "Mararaba Dispensary" if SiteID==	3613110046
replace SiteName = "Unguwar Dodo Disp" if SiteID==	3613110047
replace SiteName = "Yankuzo Disp" if SiteID==	3613110048
replace SiteName = "Buke Buke Disp" if SiteID==	3613110049
replace SiteName = "Gurbi Disp" if SiteID==	3613110050
replace SiteName = "Hayin Alhaji PHC" if SiteID==	3613110051
replace SiteName = "Wailare Disp" if SiteID==	3613110052
replace SiteName = "Dan amana Galadima Desp." if SiteID==	3613110053
replace SiteName = "Dogon Kawo desp." if SiteID==	3613110054
replace SiteName = "Gidan D/Kaka Desp." if SiteID==	3613110055
replace SiteName = "Hegin Dakai Disp" if SiteID==	3613110056
replace SiteName = "Marken Yamma Disp" if SiteID==	3613110057
replace SiteName = "Tabkin Kazai Disp" if SiteID==	3613110058
replace SiteName = "Yanware PHC" if SiteID==	3613110059
replace SiteName = "Boko HC" if SiteID==	3614110001
replace SiteName = "Dumama HC" if SiteID==	3614110002
replace SiteName = "Dumfawa HC" if SiteID==	3614110003
replace SiteName = "Jaya HC" if SiteID==	3614110004
replace SiteName = "Birnin Tsaba HC" if SiteID==	3614110005
replace SiteName = "Dauran Basic HC" if SiteID==	3614110006
replace SiteName = "Doroyi HC" if SiteID==	3614110007
replace SiteName = "Marrakkai HC" if SiteID==	3614110008
replace SiteName = "Dole Basic HC" if SiteID==	3614110009
replace SiteName = "Tudun Bugaje HC" if SiteID==	3614110010
replace SiteName = "Tudun Saariami Disp" if SiteID==	3614110011
replace SiteName = "Jabanda HC" if SiteID==	3614110012
replace SiteName = "Kanwa HC" if SiteID==	3614110013
replace SiteName = "Magariya HC" if SiteID==	3614110014
replace SiteName = "G Kada Disp" if SiteID==	3614110015
replace SiteName = "Gidan Jaja HC" if SiteID==	3614110016
replace SiteName = "Gidan Kaya HC" if SiteID==	3614110017
replace SiteName = "Gurbi Bore BHC" if SiteID==	3614110018
replace SiteName = "Kwashabawa HC" if SiteID==	3614110019
replace SiteName = "Kalage HC" if SiteID==	3614110020
replace SiteName = "Mashems HC" if SiteID==	3614110021
replace SiteName = "Tumfa HC" if SiteID==	3614110022
replace SiteName = "Tunga Fulani HC" if SiteID==	3614110023
replace SiteName = "Birane HC" if SiteID==	3614110024
replace SiteName = "Bugawa Disp" if SiteID==	3614110025
replace SiteName = "Koluwai Disp" if SiteID==	3614110026
replace SiteName = "Kuturu BHC" if SiteID==	3614110027
replace SiteName = "Makosa HC" if SiteID==	3614110028
replace SiteName = "Mayasa Model PHC" if SiteID==	3614110029
replace SiteName = "Kayawa HC" if SiteID==	3614110030
replace SiteName = "Kwangwami HC" if SiteID==	3614110031
replace SiteName = "Moriki CWC" if SiteID==	3614110032
replace SiteName = "Moriki Gen Hosp" if SiteID==	3614210033
replace SiteName = "Moriki GGSS HC" if SiteID==	3614110034
replace SiteName = "Moriki Town desp." if SiteID==	3614110035
replace SiteName = "Moriki Ophn Less Prev" if SiteID==	3614110036
replace SiteName = "Moriki PHC" if SiteID==	3614110037
replace SiteName = "Dumbrum Health Centre" if SiteID==	3614110038
replace SiteName = "Kakoki HC" if SiteID==	3614110039
replace SiteName = "Madobiya HC" if SiteID==	3614110040
replace SiteName = "Rukudawa HC" if SiteID==	3614110041
replace SiteName = "Tsanu HC" if SiteID==	3614110042
replace SiteName = "Dutsi Basic HC" if SiteID==	3614110043
replace SiteName = "Maduba HC" if SiteID==	3614110044
replace SiteName = "Yanbuki HC" if SiteID==	3614110045
replace SiteName = "Dada HC" if SiteID==	3614110046
replace SiteName = "GASS HC" if SiteID==	3614110047
replace SiteName = "Kadamotsa HC" if SiteID==	3614110048
replace SiteName = "Nasarawa FSC" if SiteID==	3614110049
replace SiteName = "Zurmi Gen Hosp" if SiteID==	3614210050
replace SiteName = "Zurmi OLPH" if SiteID==	3614110051
replace SiteName = "Zurmi PHC" if SiteID==	3614110052
replace SiteName = "Zurmi Town Disp" if SiteID==	3614110053


replace SiteName = lga + " LGA" if Level=="Second"
replace SiteName = state + " State" if Level=="First"
replace SiteName = "National" if Site_inputText=="N" | Site_inputText=="Nat"
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
* these are telephone numbers with persons who did not complete the registration

sort state lga_code Level Name
* To remove any personnel with more than one phone add 'if num_tel ==1'
list state lga SiteID Name Post Type if num_tel ==1, header

* Cannot force all onto one line
list state lga SiteName Name Type if num_tel ==1, compress header table abb(10)


* Check all needed variables are present for SITE

tab state, m
tab lga, m
tab SiteID, m 
tab Level , m 
tab Type , m 

* Save database with all registered personnel included
save "C:\TEMP\Working\REG_delete", replace

do "IMAM Weekly Analysis2"



