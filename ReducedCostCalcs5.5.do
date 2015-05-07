*** Increasing College Opportunities 
*** Final Cost Calculations
*** 5 May 2015

cd /afs/umich.edu/group/m/mmcmps/projects/increasing_college_opportunities/um_data/
use um_merged_srsd_2013, clear
capture log close 
set more off 

log using costcalclog5.5.log, replace

*Create some important variables
gen COAexcel = 26984
label variable COAexcel "Cost of Attendance" 

gen GAM = 21900
label variable GAM "Gift Aid Max" 

*Drop Students with missing MaxEFC
drop if missing(maxEFC)

**Generate Need Variables = COA-Federal EFC
gen needexcel=COAexcel-FedProratedEFC 
replace needexcel = 0 if FedProratedEFC>COAexcel  
gen needstata=COA-FedProratedEFC

gen maxEFCexcel = maxEFC if maxEFC<=COAexcel
replace maxEFCexcel = COAexcel if maxEFC>COAexcel



********************************************************************************



*************************************
*   Fixed Calculation (MCER COA)    *
*   "No cost to you....definitely"  *
*  Paid with grant aid + work study *
*  							        *
*         Fairness Concerns         *
*************************************

****** Current Program - Case 9 **********

**************
*Work Study 9*
**************

/**Fix the work study calculation so that work study is 2500
   if need is greater than 2500, otherwise work study is equal
   to need:
*/
gen ws9 = 2500 if needstata>2500 & !missing(needstata)
replace ws9 = needstata if needstata<2500

**************
*  Grants 9  *
************** 

***Fix the Grant Aid Calculation
gen grant9=.

/*With Zero EFC - cost to university is Cost of Attendence 
less work study (2500)*/
replace grant9=COA-ws9 if maxefc==0

/*With EFC between 0 and 600,  cost to university is Cost of Attendence 
less work study (2500) less the maximum EFC value */
replace grant9=COA-ws9-maxefc if maxefc>0 & maxefc<601

/*With greater than 600 EFC, cost to university of Gift Aid Max minus 
max EFC, as long GAM is greater than max EFC */
replace grant9=GAM-maxefc if maxefc>=601 & GAM>maxefc & !missing(maxefc)

*If GAM is less than max EFC, grant is 0
replace grant9=0 if maxefc>=601 & GAM<maxefc & !missing(maxefc)

**************
*   Loan 9   *
**************
*Loan is zero for the 'promise' group - those with 600 or under EFC
gen loan9 = 0 if maxefc<601

/*Loan is zero if EFC is greater than 600 and COA minus 
grant, work study and max EFC is less than zero */
replace loan9 = 0 if (COA-grant9-ws9-maxefc)<0 & maxefc>=601

*Otherwise, loan is COA minus grants, work study and family contribution
replace loan9 = COA-grant9-ws9-maxefc if maxefc>=601 & !missing(maxefc)


******** Quality Check 9**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval9 = grant9+ws9+loan9+maxEFC

*Check to see this is equal to COA 
count if abs(COA-tuitval9)>1 & !missing(tuitval9) 
list COA tuitval9 grant9 ws9 loan9 needstata maxefc FedProratedEFC ProfileEFC ///
if abs(COA-tuitval9)>1 & !missing(tuitval9) 

******** New Program - Case 10 *****************


**************
*  Grants 10 *
************** 
/**Create grant calculation that is simply equal to COA
   minus work study amount. This is where the fairness
   concern factors in - our work study calculation gives
   students with a Federal EFC greater than 2500 no work 
   study eligibility because we need to be able to grant
   them to the full COA, which we cannot do if we give 
   them work study, because then grant cannot exceed
   need. 
*/
gen grant10=COA-2500

***************
*Work Study 10*
***************

/**Create work study calculation so that work study is 2500
   if need is greater than 0, otherwise work study is equal
   to 0:
*/
gen ws10 = COA-grant10-FedProratedEFC
label variable ws10 "Amount of Federal Work Study - New Program" 
replace ws10 = 0 if ws10<0

**************
*   Loan 10  *
**************
gen loan10 = 0 

**************
*Student Cost*
**************

gen studentcost10 = COA-(grant10+ws10+loan10)

**************
* Cost Calcs *
**************

*Calculate Per Student Cost Difference
gen costdif910 = grant10-grant9

*Sum up per student cost difference to get total cost, by FRPL group 
egen totcost9109 = total(costdif910) if freered9==1 & freered10==1 & freered11==1
egen totcost91010 = total(costdif910) if freered10==1 & freered11==1
egen totcost91011 = total(costdif910) if freered11==1


**Sum up per student cost difference to get total cost, by FRPL group + some constraints

*Fam Inc less than 100k
egen totcost9109fi100 = total(costdif910) if freered9==1 & freered10==1 & freered11==1 & faminc<100000
egen totcost91010fi100 = total(costdif910) if freered10==1 & freered11==1 & faminc<100000
egen totcost91011fi100 = total(costdif910) if freered11==1 & faminc<100000

*Fam Inc in the bottom quartile
egen totcost9109fibq = total(costdif910) if freered9==1 & freered10==1 & freered11==1 & faminc<66225
egen totcost91010fibq= total(costdif910) if freered10==1 & freered11==1 & faminc<66225
egen totcost91011fibq = total(costdif910) if freered11==1 & faminc<66225

*Family Investment (any at all)
egen totcost9109inwany = total(costdif910) if freered9==1 & freered10==1 & freered11==1 & ParentInvNetWorth>0 & !missing(ParentInvNetWorth)
egen totcost91010inwany= total(costdif910) if freered10==1 & freered11==1 & ParentInvNetWorth>0 & !missing(ParentInvNetWorth)
egen totcost91011inwany = total(costdif910) if freered11==1 & ParentInvNetWorth>0 & !missing(ParentInvNetWorth)

*Family Investment (in top quartile) 
egen totcost9109inwtq = total(costdif910) if freered9==1 & freered10==1 & freered11==1 & ParentInvNetWorth>96000 & !missing(ParentInvNetWorth)
*egen totcost91010inwtq total(costdif910) if freered10==1 & freered11==1 & ParentInvNetWorth>96000 & !missing(ParentInvNetWorth)
egen totcost91011inwtq = total(costdif910) if freered11==1 & ParentInvNetWorth>96000 & !missing(ParentInvNetWorth)


*Calculate Per Student Difference in Work Study 
gen wsdif910 = ws10-ws9
sum wsdif910, d

egen totwsdif9109 = total(wsdif910) if freered9==1 & freered10==1 & freered11==1
egen totwsdif91010 = total(wsdif910) if freered10==1 & freered11==1
egen totwsdif91011 = total(wsdif910) if freered11==1



******** Quality Check 10**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval10 = grant10+ws10+loan10
replace tuitval10 = grant10+ws10+loan10+studentcost10

*Check to see this is equal to COA 
count if abs(COA-tuitval10)>1 & !missing(tuitval10) 
list COA tuitval10 grant10 ws10 loan10 needstata maxefc FedProratedEFC ProfileEFC if abs(COA-tuitval10)>1 & !missing(tuitval10) & _n<50
list COA tuitval10 grant10 ws10 loan10 studentcost10 needstata maxefc FedProratedEFC ProfileEFC if studentcost>2500 & !missing(studentcost)



********************************************************************************
*Summarize Costs 

sum totcost* 

sum totws*

