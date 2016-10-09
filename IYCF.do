* IYCF
* NIGERIA
* JULY 2016


clear
set more off
import excel "C:\TEMP\iycf.xls", sheet("Runs") firstrow

* add state, LGA and ward

* Monday - need to send reminders for July August data for IYCF. 

* Month
cap destring Response9ValueIYCF, gen(month) force

* name of support group
cap gen name_supp_group = Response12ValueIYCF 

* Number of supervisory visits
cap destring SupervisionVisitsValueIYCF, gen(super_visit) force
tab super_visit, m 

* Number of pregnant women attending
cap destring PregnantWomenValueIYCF, gen(pregwom) force
tab pregwom, m 

* Number of women with kid < 6 months
cap destring MothersLT6MonthsValueIYCF, gen(mothlt6) force
tab mothlt6, m 

* Number of women with kid 6 - 23 months
cap destring Mothers6to23MonthsValueIYCF, gen(moth6to23) force
tab moth6to23, m 

* Number of women of reproductive age
cap destring WomenRepAgeValueIYCF, gen(womrepage) force
tab womrepage, m 

* Number of grandmothers
cap destring GrandmothersValueIYCF, gen(grandma) force
tab grandma, m 

* Number of men
cap destring MenValueIYCF, gen(men) force
tab men, m 

* Number of new attendees
cap destring NewAttendeesValueIYCF, gen(newattend) force
tab newattend, m 

* Number of referrals
cap destring ReferalsValueIYCF, gen(referral) force
tab referral, m 
