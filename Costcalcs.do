*** Cost Calculations
*** 23 April 2015

cd  /afs/umich.edu/group/m/mmcmps/projects/increasing_college_opportunities/um_data/

use um_merged_srsd_2013, clear
*************************************
*Inspect all relevant cost variables*
*************************************

**EFCs
*Max EFC
sum x if freered==1, d

*FAFSA EFC 
sum FedProratedEFC if freered==1, d

*CSS EFC
sum ProfileEFC if freered==1, d

*EFC Differences
count if FedProratedEFC==0 & ProfileEFC!=0 & freered==1
sum ProfileEFC if FedProratedEFC==0 & ProfileEFC!=0 & freered==1, d 
sum diffefc if FedProratedEFC==0 & ProfileEFC!=0 & freered==1, d 

**Aid Offered
*Subsidized Stafford Loan
sum SubStaffLoanOffered if freered==1
sum SubStaffLoanDisbursed if freered==1

sum PerkinsOffered if freered==1
sum PerkinsDisbursed if freered==1

sum OtherLoanOffered if freered==1
sum OtherLoanDisbursed if freered==1

sum WorkStudyOffered if freered==1
sum WorkStudyEarned if freered==1

sum UMGiftOffered if freered==1
sum UMGiftDisbursed if freered==1

sum TotalGrantOffered if freered==1
sum TotalGrantDisbursed if freered==1

sum MCSOffered if freered==1
sum MCSDisbursed if freered==1

sum TotalScholOffered if freered==1
sum TotalScholDisbursed if freered==1

*******Do Calculations******
gen COA = 26984
label variable COA "Cost of Attendance" 

gen GAM = 21900
label variable GAM "Gift Aid Max" 

gen wselcurr = 2500
label variable wselcurr "Amount Eligible for Federal Work Study - Current Program" 

gen currprom=. 
label variable currprom "Grant Aid under current promise" 
replace currprom=COA-wselcurr if x==0
replace currprom=COA-wselcurr-x if x>0 & x<601
replace currprom=GAM-x if x=>601

gen newprom = COA-wselcurr
label variable newprom "Grant Aid under new promise" 

gen wselnew = COA-newprom-FedProratedEFC
label variable wsel "Amount Eligible for Federal Work Study - New Program" 

*Code check
sum wselnew, d

replace wselnew = 0 if wselnew<0
*Code check
sum wselnew, d

**Replicating Excel Spreadsheet Directly
*Today's Scenario: 
gen grantaidtoday=.
label variable grantaidtoday "Grant Aid Calc under Today's Package"
recode grantaidtoday=COA-

****Different Scenarios

*Not cost to family 

*

*Eliminate CSS profile: 
