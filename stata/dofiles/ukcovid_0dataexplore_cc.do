*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*

*Data Exploration - Understandinbg Society Harmonized Covid

*Web and telephone survey, around 50% response rate

*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*
 clear
 set more off
 global onedrive "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do"
 
 global pc "C:\Users\Muzhi\OneDrive - Nexus365"
 
 global local "D:\Academia\Data"
 do "$onedrive/Stata_covid\do/ukcovid_00dir"
 capture log close 
 *log using "$Output\log_ukcovid0", replace //log file
 
 use "$RawCovid/cc_indresp_w",clear
 //_w: web result 2nd wave
 rename cc_* *
  gen doim=6
  gen year=2019 //used for merge income CPI, latest is 2019  
  gen doiy=2020
  rename betaindin_xw xweightcovid
  sum age
  
  ta couplewsh,m
  ta couple,m
  drop couplewsh
  
foreach i in a b c d e {
    ta hhcomp`i'
} //14,123
    count if blpay_amount<0
    count if blhhearn_amount<0
    count if hhearn_amount<0 //7985
*========================================================*
 *Household size:
    ta hhnum,m
    recode hhnum -9/-1=., gen(hh_hhsize)

   do "$docovid/ukcovid_1var_indi_c.do"
   table sex, c (mean swb1) //men 25.71 vs women 23.96
   //wave covid a - men 25.77 vs women 23.67
   
   replace i_hidp=k_hidp if i_hidp<0
   replace i_hidp=j_hidp if i_hidp<0
   count if i_hidp<0
    drop j_hidp k_hidp
   rename i_hidp hh_hidp
   
   keep *hidp pidp sex age couple* hhcomp* parent* couple* nchild* timeccare*  ///
   hadsymp hassymp tested testresult ///
   sempderived keyworksector ///
   gor_dv ///
   doim doiy hh_hhsize1-keyworker1 xweight 
   
   drop CPIH fimnlabgrs_dv0 fimnlabgrs_dv1 fihhmn_all0  fihhmn_all1

   
   save "$WorkData/covid_indresp_widec", replace




