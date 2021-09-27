 clear
 set more off 

 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close
 
 
use "$WorkData/2covid_long.dta", clear //All sample from the last wave of UKHLS are in  
  
*-----------Basic summary--------------*  
  sum age 
  ta covidwave if age>19&age<66
  
  order pidp covidwave age nchild timechcare
  count if timechcare>0&timechcare~=.&nchild==0
  *replace timechcare=. if timechcare>0&timechcare~=.&nchild==0

  *table covidwave, c(min age max age)  
  ta x_preletter,m
  /*
preserve
  keep if covx_incovid==1
  xtset pidp covidwave
  xtdes
restore
*/

  
  append using "E:\Academia\Data\UKHLS\WorkData\main2021/ukhls3_pooled.dta"
  //full UKHLS waves appended, duplicates among those who are in sampling frame but not respond to covid survey
	

  *Now we have those who are not in COVID but in other UKHLS waves
  sort pidp wave covidwave

  bysort pidp: egen wavemax=max(wave)
  gen waveall=wave if wave~=.
  replace waveall=28+covidwave+1 if waveall==.
  order pidp waveall covidwave wave wavemax
  sort pidp waveall
  ta waveall,m 
  
  
 *=============Pool in Personal Fixed Info if not IN===================*
    gen proxy = [sf12pcs_dv ==-7] //Physical component 
    la var proxy "Proxy interviews"
    replace sf12pcs_dv  =. if sf12pcs_dv<0
    replace sf12mcs_dv =. if sf12mcs_dv<0
	
	ta sex sex_dv,m
	replace sex=0 if sex_dv==1&sex==.
	replace sex=1 if sex_dv==2&sex==.
	drop sex_dv
    
    replace chronic=x_hcond if chronic==.
    replace x_birthy=birthy if birthy>0&birthy~=.
	replace x_strata=strata if x_strata==.
	replace x_psu=psu if x_psu==.
    drop birthy strata psu
    
    sort pidp waveall
    order pidp waveall
    
    recode x_ukborn -9=. 1/4=1 5=0
    replace x_ukborn=1 if bornuk==1
    replace x_ukborn=0 if bornuk==2
    la def bornuk 0 "not born in uk" 1 "born in uk"
    la val x_ukborn bornuk
    drop bornuk	
	
   sort pidp waveall
   capture drop x_race
   ta xracel,m //lots missing
   order pidp waveall xracel x_racel_dv
   replace xracel=x_racel_dv if xracel==.  
   replace xracel=. if xracel<0
   ta xracel,m //3% missing
   drop x_racel_dv
	
   recode xracel -9/-1=. 1/4=0 9/13=1 14/16=2 17/97=3 5/8=3,gen(x_race)   
   la def race 0 "White" 1 "Asian" 2 "Black" 3 "Others"
   la val x_race race
   ta xracel x_race,m	
   drop xracel
    
    
    foreach var in edu3c x_race x_ukborn x_birthy sex religion_dum chronic x_preletter x_strata x_psu hh_tenure_dv gor_dv /*sf12pcs_dv sf12mcs_dv */ {
    replace `var'=. if `var'<0
 	bysort pidp: replace `var'=`var'[_n-1] ///
        if `var'==.|`var'<0
    }
    
   foreach var in chagemin {
 	bysort pidp: replace `var'=`var'[_n-1]+1 ///
        if `var'==.|`var'<0
    replace chagemin=. if chagemin>15
    }
        
    gsort pidp -waveall
   foreach var in edu3c x_race x_ukborn x_birthy sex religion_dum chronic x_preletter x_strata x_psu hh_tenure_dv gor_dv /*sf12pcs_dv sf12mcs_dv */ {
 	bysort pidp: replace `var'=`var'[_n-1] ///
        if `var'==.|`var'<0
    }
    
   sort pidp waveall
    
   
   *===================================
  *whether key dependnet variables in last wave, e.g., w28
   order pidp x_preletter waveall wavemax covidwave ///
   howlng timechcare hours workhrall  scghq1 scghq1_dv ///
   netpay15_month fimnlabnet_dv15 fimnnet_dv15 hhearn15_month hh_fihhmnnet1_dv15
  //howlng is asked in wave28
  
  keep if covidwave==.&wave==wavemax|covidwave==.&wave==.|covidwave~=.
	
  //2 records for those not in covid wave: one from covid xdata(waveall==.), another from 3_pooled
  //make this one record, pool some info into 3_pooled
  foreach v in x_preletter xoutcome1 xoutcome2 xoutcome3 xoutcome4 xoutcome5 xoutcome6 x_incovid ///
	xi_ioutcome xj_ioutcome  xk_ioutcome {
  bysort pidp: replace `v'=`v'[_n-1] if `v'==.
  bysort pidp: replace `v'=`v'[_n+1] if `v'==.
	}
  drop if waveall==.
  //1 record for those who ever in UKHLS but lost during main survey, not invited for COVID survey
  //1 record for those asked to participate covid survey, from 3_pooled, but did not respond
  //2 or more records for those in covid wave, one from covid wave data, another from 3_pooled
    
  bysort pidp: gen nrecord=_N  
  sort pidp waveall
  order pidp waveall nrecord
   
   order pidp waveall wave covidwave nrecord doiy doim
   la var waveall "Wave number combined with covid wave number"
   ta waveall,m //very few have their latest wave before wave 28 in 2019
   
 *pool key dependent info from wave28 to wave29 or covidwave0 for covid sample:
 *1. subjective wellbeing; 2. housework time; 3. couple and parenthood condition; 4. earnings
	
	    
	bysort pidp: replace scghq1=scghq1_dv[_n-1] if covidwave==0
	bysort pidp: replace howlng=howlng[_n-1] if covidwave==0
	
*Age used for predicting howlng and scghq1
	capture drop age
	gen age=doiy-x_birthy
	sum age
	gen howlngage=.
	replace howlngage=age if wavemax==wave
	order pidp age howlngage
	bysort pidp: replace howlngage=howlngage[_n-1] if howlngage==.
	la var howlngage "Age used to predict housework and subjective wellbeing"
	
	*codebook spinhh
	replace x_couple=1 if new_mastat>0&new_mastat<3
    replace x_couple=0 if new_mastat==0|new_mastat==3|new_mastat==4
	capture drop x_couple_pre
	gen x_couple_pre=.
	la val x_couple_pre couple
	la var x_couple_pre "Whether couple from last main survey"
	bysort pidp: replace x_couple_pre=x_couple[_n-1] if covidwave==0	
	la var nchild "All wave: # of children<=15"
    la var x_nchild "COVID fixed nchild"
	drop nchildc
  
	gen x_nchild_pre=.
	la var x_nchild_pre "Number of children from last main survey"
	bysort pidp: replace x_nchild_pre=nchild[_n-1] if covidwave==0
	*order pidp waveall covidwave x_nchild x_nchild_pre nchild x_couple new_mastat x_couple_pre spinhh
	
	replace working=employed if working==.
	drop employed 
	gen working_pre=.
	la val working_pre working
	bysort pidp: replace working_pre=working[_n-1] if covidwave==0
	
	gen netpay15_month_pre=.
	bysort pidp: replace netpay15_month_pre=fimnlabnet_dv15[_n-1] if covidwave==0
	la var netpay15_month_pre "fimnlabnet_dv15"
	
	*order pidp waveall covidwave working working_pre netpay15_month netpay15_month_pre
	
  *Drop earlier wave for those covid sample

    drop if wave~=.&covidwave==.&nrecord>1
	drop x_parent
	
  order pidp-x_preletter working hours scghq1 howlng timechcare netpay15_month ///
	sex x_race edu3c x_nchild nchild  x_couple new_mastat  
	
  foreach v in parent couple {
  bysort pidp: replace `v'=`v'[_n+1] if covidwave==0
  }
  **
  
 save "$WorkData/3covid_long_mergedwith3pooled.dta",replace
 
	ta waveall x_race, row nof
	ta covidwave x_race, row nof
	ta covidwave x_race if age>19&age<66, row nof
  
 ****************************************** 
erase "$WorkData/1covid_long.dta"

  forval i=0/7{
erase "$WorkData/1covid_w`i'.dta"
}  
  
  
  