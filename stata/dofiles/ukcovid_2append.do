 clear
 set more off
 global onedrive "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do"
 
 global pc "C:\Users\Muzhi\OneDrive - Nexus365"
 
 global local "D:\Academia\Data"
 do "$onedrive/Stata_covid\do/ukcovid_00dir"
 capture log close 

 use  "$WorkData/covid_indresp_widea",clear
 append using "$WorkData/covid_indresp_wideb"
 append using "$WorkData/covid_indresp_widec"
 order pidp doiy doim age sex swb1 working0 workhrall0 working1 couple1
 sort pidp doiy doim 
 ta sex,m
 bysort pidp: replace sex=sex[_n-1] if sex==3|sex==.|sex<0
 ta sex,m
 foreach v in age hh_hidp hh_hhsize1 working0 workhrall0 notonbenefits0 chronic0 new_jbft0 wah0 fimnlab0 fihhmn0 couple1 parent1 furlough1 keyworker1 keyworksector nchild1 nchildc1 childscha childschb {
 bysort pidp: replace `v'=`v'[_n-1] if `v'==.|`v'<0
 }
 **
 gsort pidp -doim
  foreach v in sex age hh_hidp hh_hhsize1 working0 workhrall0 notonbenefits0 chronic0 new_jbft0 wah0 fimnlab0 fihhmn0 couple1 parent1 furlough1 keyworker1 keyworksector nchild1 nchildc1 childscha childschb {
 bysort pidp: replace `v'=`v'[_n-1] if `v'==.|`v'<0
 }
 **
 sort pidp doim 
 ta sex,m
 drop if sex==.
 drop if hh_hidp ==.
 save "$WorkData/covid_indresp_wideall",replace
 
 *Modify data:
 use "$WorkData/covid_indresp_wideall", clear
  order pidp doiy doim age sex *0
  keep pidp doiy doim age sex *0 ///
  hh_hhsize1 parent1 couple1 nchild1 nchildc1 chageminc1 chageminsch ///
  keyworker1 keyworksector furlough1 xweightcovid
  
  drop if working0==. //not ask baseline working info again, dropped
  
  ta doim //7% ppl joined through may survey
  rename *0 *
  rename *1 *
  replace doim =1  
  sort pidp
 duplicates report pidp
 * duplicates list pidp //68704491,70432373
  bysort pidp: gen ncase=_n
  order pidp ncase
  sort pidp ncase  
  keep if ncase==1
  drop ncase
  count if fimnlab==.
  count if fihhmn==.
  save "$WorkData/covid_indresp_baseline", replace 
  //Baseline info in Jan/Feb 2020 retrospectively collected, 18,614 individuals
  
  use "$WorkData/covid_indresp_wideall", clear
  drop *0
 *Drop child's info if not analyzing this
  drop  child1 child2 childdob*_y childage* atschool_child* schoolwork_child*  lessonsoff_child* marking_child* compreq_child* chcomputer_child* hstime_child* hshelp_child* tutoring*_child* freemeals_child*  lessonson_child* meals_child*
 
  drop  nchildage* natschool_child* nschoolwork_child*  nmarking_child* ncompreq_child* nchcomputer_child* nhstime_child* nhshelp_child*  
 
  drop lastmodule
  
  rename *1 *
  append using "$WorkData/covid_indresp_baseline"
  
  sort pidp doiy doim
  bysort doim: ta keyworker working,m
  replace working=1 if keyworker==1&doim>1
  replace working=0 if keyworker==0&doim>1&working==.
  sort pidp doiy doim
  rename xweightcovid xweight
  replace fimnlab=0.5 if working==0&fimnlab==.
  count if fimnlab==.
  ta doim if fimnlab==. //real missing labour income among those who work
  ta doim
  count if fihhmn==.&doim>1
  save "$WorkData/covid_indresp_long", replace
  
  *erase "$WorkData/covid_indresp_baseline.dta"
 
  erase "$WorkData/covid_indresp_wideall.dta"
  
  
  
*-----------Basic summary--------------*  
  sum age //16 to 96
  capture drop agegr
  egen agegr = cut(age), at(16,25,35,45,55,65,75,100)
  table agegr, c(min age max age)
  ta agegr
  table agegr, c(mean swb)
  
  
  table sex, c(mean swb) //women score worse
  
  table doim, c(mean age mean swb mean workhrall mean howlng)