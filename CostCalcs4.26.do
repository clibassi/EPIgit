*** Increasing College Opportunities Cost Calculations
*** 26 April 2015

cd /afs/umich.edu/group/m/mmcmps/projects/increasing_college_opportunities/um_data/
use um_merged_srsd_2013, clear

set more off 

*log using costcalclog4.26.log, replace

*Create some important variables
gen COAexcel = 26984
label variable COAexcel "Cost of Attendance" 

gen GAM = 21900
label variable GAM "Gift Aid Max" 

**Generate Need Variables = COA-Federal EFC
gen needexcel=COAexcel-FedProratedEFC 
replace needexcel = 0 if FedProratedEFC>COAexcel  
gen needstata=COA-FedProratedEFC

gen maxEFCexcel = maxEFC if maxEFC<=COAexcel
replace maxEFCexcel = COAexcel if maxEFC>COAexcel

********************************************************************************





*************************************
*   Original Calculation (Flat COA) *
*          "No cost to you"         *
*  Paid with grant aid + work study *
*************************************

****** Current Program - Case 1 **********

**************
*  Grants 1  *
************** 

** Amount of Grant Aid According To Excel Spreadsheet:
gen grant1=. 
label variable grant1 "Current grant using Flat COA of 26984" 

/*With Zero EFC - cost to university is Cost of Attendence
less work study (2500)*/
replace grant1=COAexcel-2500 if maxefc==0

/*With EFC between 0 and 600,  cost to university is Cost of Attendence 
less work study (2500) less the maximum EFC value */
replace grant1=COAexcel-2500-maxefc if maxefc>0 & maxefc<601

*With greater than 600 EFC, cost to university of Gift Aid Max minus max EFC
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
********* Because current grant can go negative *******************
replace grant1=GAM-maxefc if maxefc>=601 & !missing(maxefc)

**************
*Work Study 1*
************** 

** Amount of Federal Work Study According to Excel Spreadsheet
*Flat $2500
gen ws1 = 2500

**************
*   Loan 1   *
************** 

** Amount of Federal Loan According to Excel Spreadsheet
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
************* Because loan can go negative** ******************

*Loan is zero for the 'promise' group - those with 600 or under EFC
gen loan1 = 0 if maxefc<601

*Otherwise, loan is COA minus grants, work study and family contribution
replace loan1 = COAexcel-grant1-ws1-maxefc if maxefc>=601 & !missing(maxefc)


******** Quality Check 1**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval1 = grant1+ws1+loan1 

*Check to see this is equal to COA 
count if COA!=tuitval1 & !missing(tuitval1) 
list COAexcel tuitval1 grant1 ws1 loan1 maxefc FedProratedEFC ProfileEFC if COAexcel!=tuitval1 & !missing(tuitval1) & _n<30


******** New Program - Case 2 *****************

** Cost of New Program According To Excel Spreadsheet:

**************
*  Grants 2  *
************** 

*New Grant equals Cost of Attendance less work study (2500)
gen grant2 = COAexcel-2500
label variable grant2 "New grant Flat COA of 26984"

**************
*Work Study 2*
**************

/*New Work Study Amount Equals Cost of Attendance less Grant 
Aid and FAFSA EFC */
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
***** Because total tuition value can be less than COA ************
gen ws2 = COAexcel-grant2-FedProratedEFC
label variable ws2 "Amount of Federal Work Study - New Program" 
replace ws2 = 0 if ws2<0

**************
*   Loan 2   *
**************
gen loan2 = 0 

**************
* Cost Calcs *
**************

*Calculate Per Student Cost Difference
gen costdif12 = grant2-grant1

*Sum up per student cost difference to get total cost, by FRPL group 
egen totcost129 = total(costdif12) if freered9==1 & freered10==1 & freered11==1
egen totcost1210 = total(costdif12) if freered10==1 & freered11==1
egen totcost1211 = total(costdif12) if freered11==1

******** Quality Check 2**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval2 = grant2+ws2+loan2 

*Check to see this is equal to COA 
count if COA!=tuitval2 & !missing(tuitval2) 
list COAexcel tuitval2 grant2 ws2 loan2 maxefc FedProratedEFC ProfileEFC if COAexcel!=tuitval2 & !missing(tuitval2) & _n<30







********************************************************************************







*************************************
*   Fixed Calculation (Flat COA)    *
*     "No cost to you....maybe"     *
*  Paid with grant aid + work study *
*  (and adjusted EFC of out pocket  *
*     for student in some cases)    *
*************************************

****** Current Program - Case 3 **********

**************
*Work Study 3*
**************

/**Fix the work study calculation so that work study is 2500
   if need is greater than 2500, otherwise work study is equal
   to need:
*/
gen ws3 = 2500 if needexcel>2500 & !missing(needexcel)
replace ws3 = needexcel if needexcel<2500

**************
*  Grants 3  *
************** 

***Fix the Grant Aid Calculation
gen grant3=.

/*With Zero EFC - cost to university is Cost of Attendence 
less work study (2500)*/
replace grant3=COAexcel-ws3 if maxEFCexcel==0

/*With EFC between 0 and 600,  cost to university is Cost of Attendence 
less work study (2500) less the maximum EFC value */
replace grant3=COAexcel-ws3-maxEFCexcel if maxEFCexcel>0 & maxEFCexcel<601

/*With greater than 600 EFC, cost to university of Gift Aid Max minus 
max EFC, as long GAM is greater than max EFC */
replace grant3=GAM-maxEFCexcel if maxEFCexcel>=601 & GAM>maxEFCexcel & !missing(maxEFCexcel)

*If GAM is less than max EFC, grant is 0
replace grant3=0 if maxEFCexcel>=601 & GAM<maxEFCexcel & !missing(maxEFCexcel)

**************
*   Loan 3   *
**************
*Loan is zero for the 'promise' group - those with 600 or under EFC
gen loan3 = 0 if maxEFCexcel<601

/*Loan is zero if EFC is greater than 600 and COA minus 
grant, work study and max EFC is less than zero */
replace loan3 = 0 if (COAexcel-grant3-ws3-maxEFCexcel)<0 & maxEFCexcel>=601

*Otherwise, loan is COA minus grants, work study and family contribution
replace loan3 = COAexcel-grant3-ws3-maxEFCexcel if maxEFCexcel>=601 & !missing(maxEFCexcel)


******** Quality Check 3**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval3 = grant3+ws3+loan3+maxEFCexcel

*Check to see this is equal to COA 
count if abs(COAexcel-tuitval3)>1 & !missing(tuitval3) 
list COAexcel tuitval3 grant3 ws3 loan3 needexcel maxEFCexcel maxefc FedProratedEFC ProfileEFC if abs(COAexcel-tuitval3)>1 & !missing(tuitval3) 

******** New Program - Case 4 *****************


/*Create an Adjusted EFC measure, which makes the EFC equal to
  minus $2,500. This is the cost to the student out of pocket. 
*/
gen studentcost4=FedProratedEFC-2500
replace studentcost4 = FedProratedEFC if FedProratedEFC==COAexcel
replace studentcost4=0 if FedProratedEFC<2500

**************
*Work Study 4*
**************

/**Create work study calculation so that work study is 2500
   if need is greater than 0, otherwise work study is equal
   to 0:
*/
gen ws4 = 2500 if needexcel>0 & !missing(needexcel) 
replace ws4 = needexcel if needexcel==0

**************
*  Grants 4  *
************** 
/**Create grant calculation so that students with high EFCs
   don't get full tuition grants. That is if FAFSA EFC is less 
   than $2500, grant equals Cost of Attendance minus work study. 
   Otherwise, grant equals Cost of Attendance minus work study
   and adjusted EFC. 
*/
gen grant4=.
replace grant4 = COAexcel-ws4 if FedProratedEFC<=2500
replace grant4 = COAexcel-studentcost4-ws4 if FedProratedEFC>2500 & !missing(FedProratedEFC)

**************
*   Loan 4   *
**************
gen loan4 = 0 

**************
* Cost Calcs *
**************

*Calculate Per Student Cost Difference
gen costdif34 = grant4-grant3

*Sum up per student cost difference to get total cost, by FRPL group 
egen totcost349 = total(costdif34) if freered9==1 & freered10==1 & freered11==1
egen totcost3410 = total(costdif34) if freered10==1 & freered11==1
egen totcost3411 = total(costdif34) if freered11==1


*Calculate Per Student Difference in Work Study 
gen wsdif34 = ws4-ws3
sum wsdif34, d

egen totwsdif349 = total(wsdif34) if freered9==1 & freered10==1 & freered11==1
egen totwsdif3410 = total(wsdif34) if freered10==1 & freered11==1
egen totwsdif3411 = total(wsdif34) if freered11==1


******** Quality Check 4**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval4 = grant4+ws4+loan4+studentcost4

*Check to see this is equal to COA 
count if abs(COAexcel-tuitval4)>1 & !missing(tuitval4) 
list COAexcel tuitval4 grant4 ws4 loan4 needexcel maxefc studentcost4 FedProratedEFC ProfileEFC if abs(COAexcel-tuitval4)>1 & !missing(tuitval4) 



********************************************************************************





*************************************
*   Original Calculation (MCER COA) *
*          "No cost to you"         *
*  Paid with grant aid + work study *
*************************************

****** Current Program - Case 5 **********

**************
*  Grants 5  *
************** 

** Amount of Grant Aid According To Excel Spreadsheet:
gen grant5=. 
label variable grant5 "Current grant using MCER COA" 

/*With Zero EFC - cost to university is Cost of Attendence
less work study (2500)*/
replace grant5=COA-2500 if maxefc==0

/*With EFC between 0 and 600,  cost to university is Cost of Attendence 
less work study (2500) less the maximum EFC value */
replace grant5=COA-2500-maxefc if maxefc>0 & maxefc<601

*With greater than 600 EFC, cost to university of Gift Aid Max minus max EFC
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
********* Because current grant can go negative *******************
replace grant5=GAM-maxefc if maxefc>=601 & !missing(maxefc)

**************
*Work Study 5*
************** 

** Amount of Federal Work Study According to Excel Spreadsheet
*Flat $2500
gen ws5 = 2500

**************
*   Loan 5   *
************** 

** Amount of Federal Loan According to Excel Spreadsheet
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
************* Because loan can go negative** ******************

*Loan is zero for the 'promise' group - those with 600 or under EFC
gen loan5 = 0 if maxefc<601

*Otherwise, loan is COA minus grants, work study and family contribution
replace loan5 = COA-grant5-ws5-maxefc if maxefc>=601 & !missing(maxefc)


******** Quality Check 5**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval5 = grant5+ws5+loan5 

*Check to see this is equal to COA 
count if COA!=tuitval5 & !missing(tuitval5) 
list COA tuitval5 grant5 ws5 loan5 maxefc FedProratedEFC ProfileEFC if COA!=tuitval5 & !missing(tuitval5) & _n<30


******** New Program - Case 6 *****************

** Cost of New Program According To Excel Spreadsheet:

**************
*  Grants 6  *
************** 

*New Grant equals Cost of Attendance less work study (2500)
gen grant6 = COA-2500
label variable grant6 "New grant using MCER COA"

**************
*Work Study 6*
**************

/*New Work Study Amount Equals Cost of Attendance less Grant 
Aid and FAFSA EFC */
*********** THIS IS ONE PLACE WE SEE AN ERROR *********************
***** Because total tuition value can be less than COA ************
gen ws6 = COA-grant6-FedProratedEFC
label variable ws6 "Amount of Federal Work Study - New Program" 
replace ws6 = 0 if ws6<0


**************
*   Loan 6   *
**************
gen loan6 = 0 


**************
* Cost Calcs *
**************

*Calculate Per Student Cost Difference
gen costdif56 = grant6-grant5

*Sum up per student cost difference to get total cost, by FRPL group 
egen totcost569 = total(costdif56) if freered9==1 & freered10==1 & freered11==1
egen totcost5610 = total(costdif56) if freered10==1 & freered11==1
egen totcost5611 = total(costdif56) if freered11==1


******** Quality Check 6**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval6 = grant6+ws6+loan6 

*Check to see this is equal to COA 
count if COA!=tuitval6 & !missing(tuitval6) 
list COA tuitval6 grant6 ws6 loan6 maxefc FedProratedEFC ProfileEFC if COA!=tuitval6 & !missing(tuitval6) & _n<30






********************************************************************************







*************************************
*    Fixed Calculation (MCER COA)   *
*          "No cost to you"         *
*  Paid with grant aid + work study *
*************************************

****** Current Program - Case 7 **********

**************
*Work Study 7*
**************

/**Fix the work study calculation so that work study is 2500
   if need is greater than 2500, otherwise work study is equal
   to need:
*/
gen ws7 = 2500 if needstata>2500 & !missing(needstata)
replace ws7 = needstata if needstata<2500

**************
*  Grants 7  *
************** 

***Fix the Grant Aid Calculation
gen grant7=.

/*With Zero EFC - cost to university is Cost of Attendence 
less work study (2500)*/
replace grant7=COA-ws7 if maxefc==0

/*With EFC between 0 and 600,  cost to university is Cost of Attendence 
less work study (2500) less the maximum EFC value */
replace grant7=COA-ws7-maxefc if maxefc>0 & maxefc<601

/*With greater than 600 EFC, cost to university of Gift Aid Max minus 
max EFC, as long GAM is greater than max EFC */
replace grant7=GAM-maxefc if maxefc>=601 & GAM>maxefc & !missing(maxefc)

*If GAM is less than max EFC, grant is 0
replace grant7=0 if maxefc>=601 & GAM<maxefc & !missing(maxefc)

**************
*   Loan 7   *
**************
*Loan is zero for the 'promise' group - those with 600 or under EFC
gen loan7 = 0 if maxefc<601

/*Loan is zero if EFC is greater than 600 and COA minus 
grant, work study and max EFC is less than zero */
replace loan7 = 0 if (COA-grant7-ws7-maxefc)<0 & maxefc>=601

*Otherwise, loan is COA minus grants, work study and family contribution
replace loan7 = COA-grant7-ws7-maxefc if maxefc>=601 & !missing(maxefc)


******** Quality Check 7**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval7 = grant7+ws7+loan7+maxEFC

*Check to see this is equal to COA 
count if abs(COA-tuitval7)>1 & !missing(tuitval7) 
list COA tuitval7 grant7 ws7 loan7 needstata maxefc FedProratedEFC ProfileEFC if abs(COA-tuitval7)>1 & !missing(tuitval7) 

******** New Program - Case 8 *****************


/*Create an Adjusted EFC measure, which makes the EFC equal to
  minus $2,500. This is the cost to the student out of pocket. 
*/
gen studentcost8=FedProratedEFC-2500
replace studentcost8 = FedProratedEFC if FedProratedEFC==COA
replace studentcost8=0 if FedProratedEFC<2500

**************
*Work Study 8*
**************

/**Create work study calculation so that work study is 2500
   if need is greater than 0, otherwise work study is equal
   to 0:
*/
gen ws8 = 2500 if needstata>0 & !missing(needstata) 
replace ws8 = needstata if needstata==0

**************
*  Grants 8  *
************** 
/**Create grant calculation so that students with high EFCs
   don't get full tuition grants. That is if FAFSA EFC is less 
   than $2500, grant equals Cost of Attendance minus work study. 
   Otherwise, grant equals Cost of Attendance minus work study
   and adjusted EFC. 
*/
gen grant8=.
replace grant8 = COA-ws8 if FedProratedEFC<=2500
replace grant8 = COA-studentcost8-ws8 if FedProratedEFC>2500 & !missing(FedProratedEFC)

**************
*   Loan 8   *
**************
gen loan8 = 0 

**************
* Cost Calcs *
**************

*Calculate Per Student Cost Difference
gen costdif78 = grant8-grant7

*Sum up per student cost difference to get total cost, by FRPL group 
egen totcost789 = total(costdif78) if freered9==1 & freered10==1 & freered11==1
egen totcost7810 = total(costdif78) if freered10==1 & freered11==1
egen totcost7811 = total(costdif78) if freered11==1


*Calculate Per Student Difference in Work Study 
gen wsdif78 = ws8-ws7
sum wsdif78, d

egen totwsdif789 = total(wsdif78) if freered9==1 & freered10==1 & freered11==1
egen totwsdif7810 = total(wsdif78) if freered10==1 & freered11==1
egen totwsdif7811 = total(wsdif78) if freered11==1


******** Quality Check 8**************

/*Create a variable that gives value of 
resources available to students to put toward COA. 
Equals Grant Aid + FWS + Federal Loans + Family 
Contibution */
gen tuitval8 = grant8+ws8+loan8+studentcost8

*Check to see this is equal to COA 
count if abs(COA-tuitval8)>1 & !missing(tuitval8) 
list COA tuitval8 grant8 ws8 loan8 needstata maxefc studentcost8 FedProratedEFC ProfileEFC if abs(COA-tuitval8)>1 & !missing(tuitval8) 



********************************************************************************
*Summarize Costs 

sum totcost* 

sum totws*


********************************************************************************
*FEBP Cleaning 
cd /afs/umich.edu/group/m/mmcmps/projects/increasing_college_opportunities/um_data/Git/EPIgit
import delimited higher_ed-data-17.csv, clear

forvalues i = 2007(1)2013{

label variable workdisburse_`i' "Federal Work-Study Grant Disbursements" 
label variable workrecip_`i' "Federal Work-Study Grant Recipients" 

replace workdisburse_`i'="." if workdisburse_`i'=="N/A" 
replace workrecip_`i'="." if workrecip_`i'=="N/A" 

destring workdisburse_`i', replace
destring workrecip_`i', replace 


}


*

sum work* if school=="University Of Michigan - Ann Arbor"


*/



