*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*The treatment is exogenous
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 clear
 set more off
 global local "D:\Academia\Data"
 global onedrive ///
 "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do" 
 
 do "$onedrive/Stata_2020\Do/ukhls_00dir" 
 
 capture log close
 
   global xheck "genderparent2 genderparent3 genderparent4 couple raceminor ukbornd age edu2 edu3 lnfihhmnpre tenure2 tenure3 tenure4 region2 region3 region4 region5 region6 region7"
    
 *xheck:
   //tenure2 tenure3 tenure4
  //physical and mental component summary
  //lnfimnlab 
  //also selection into working checked?
  /*nchild3c2 nchild3c3 nchild3c4 */
  //sfhealth2 sfhealth3 sfhealth4
  //
 
*-------------------------------------
 *Heckman selection into sample:
 
 *------------------------------------

 use "$RawData/ukhls_wx/xwavedat",clear

 merge 1:n pidp using "$WorkData/covid_combined_long"
 //using adult sample
 ta wave
 order pidp wave covid age _merge
 order hh_hidp pidp wave age  birthy 
 
 replace age=doiy-birthy if age==.
 replace age=2020-birthy if age==.
 ta xwdat_dv covid,m
 //none sample from BHPS only is now in covid
 ta xwdat_dv
 drop if xwdat_dv==2 //dropped bc no invitation sent to them for covid study
 
 order pidp-_merge sampst lwenum_dv lwintvd_dv
 sort pidp wave
 //many in master only, but are adults
 ta lwenum_dv covid
 sum age if wave==.
 drop if wave==.&covid==0
 //not in individual interview and not in covid, only in xwave
 
 *Selection into covid survey:
    ta wave covid,m
    sort pidp wave
    bysort pidp: replace covid=1 if covid[_n-1]==1&covid==0|covid[_n-1]==1&covid==.
    gsort pidp -wave
    bysort pidp: replace covid=1 if covid[_n-1]==1&covid==0|covid[_n-1]==1&covid==.
    sort pidp wave
    
 ta lwintvd_dv if wave==.
 //inapplicable last wave interviewed are children
 
 ta lvag16 if wave==.
 ta racel_dv if wave==. //many missing xinfo
 sum age if wave==.
 
 drop if racel_dv<0
 //covid sample with missing info in xwave dropped
 sort wave pidp
 
 ta lwintvd_dv covid, col nof 
 //95% are active in wave9
 //so sent invitation out of waves 8 and 9 as last interview has covered almost all the invitation pool
 ta wave netusenew,m row
 //since w24, new sample added 
 
 ta dcsedfl_dv dcsedw_dv
 table dcsedfl_dv , c(min age max age mean age)
 *hist age if dcsedfl_dv ==1&age<120
 
 drop if dcsedfl_dv==1 //deceased...
 
 
 //this is the pool where invitation was sent
 //also close to uk general population?
 
 *sex, age, couple, parenthood, nchild, chageminc, working, working hours, race ethnicity, house tenure, internet access, household income, carownership, whether live with parents at age 16, parental education.
 
     order pidp wave age
     sort pidp wave
     ta wave
     
     bysort pidp: replace age=age[_n-1] if age~=age[_n-1]&wave>27&age~=.&wave~=.&age[_n-1]~=.
  
 *Pool in work time and housework time, wellbeing, and gender attitude (already pooled) if not asked in this wave
    gen proxy = [sf12pcs_dv ==-7]
    replace sf12pcs_dv  =. if sf12pcs_dv<0
    replace sf12mcs_dv =. if sf12mcs_dv<0
    sort pidp wave
    foreach var in sf12pcs_dv sf12mcs_dv x_race sex notonbenefits chronic {
 	bysort pidp: replace `var'=`var'[_n-1] ///
        if `var'==.|`var'<0
    }
    
   foreach var in chagemin {
 	bysort pidp: replace `var'=`var'[_n-1]+1 ///
        if `var'==.|`var'<0
    }
        
    gsort pidp -wave
   foreach var in sf12pcs_dv sf12mcs_dv x_race sex {
 	bysort pidp: replace `var'=`var'[_n-1] ///
        if `var'==.|`var'<0
    }
    
   sort pidp wave
   
*------------------------WORK FROM HOME AND OCCUPATION----------------------
    order pidp wave wah working jbsemp jbisco88 jbnssec5 
    
    gen working_pre=.
    bysort pidp: replace working_pre=working[_n-1] if working_pre==.|working_pre<0
    
    gen wah_pre=.
    bysort pidp: replace wah_pre=wah[_n-1] if wah_pre==.|wah_pre<0
    
    codebook jbsemp j1semp sempderived
    replace jbsemp=j1semp if jbsemp==.|jbsemp<0
    replace jbsemp=sempderived  if jbsemp==.|jbsemp<0
    ta jbsemp,m
    replace jbsemp=. if jbsemp<0|jbsemp==4
    replace jbsemp=2 if jbsemp==3 //if both, chance of wah is higher/
    ta jbsemp if working==1,m
    
    bysort pidp: replace jbsemp=jbsemp[_n-1] if jbsemp==.&working==1|jbsemp[_n-1]<0&working==1
    
    global occupation "jbisco88 jbnssec5 jbseg_dv jbrgsc_dv"
    
    foreach y in $occupation {
        capture drop `y'_pre
    gen `y'_pre=.
    bysort pidp: replace  `y'_pre=`y'[_n-1] if `y'_pre==.&working==1|`y'_pre<0&working==1
    bysort pidp: replace  `y'_pre=`y'_pre[_n-1] if `y'_pre==.&working==1|`y'_pre<0&working==1
    replace  `y'_pre=. if `y'_pre<0
    }
    order pidp wave working working_pre wah wah_pre jbisco88_pre jbisco88
    
    codebook $occupation 
    la val jbisco88_pre a_jbisco88
    la val jbnssec5_pre a_jbnssec5_dv
    la val jbseg_dv_pre ba_jbseg_dv
    la val jbrgsc_dv_pre ba_jbrgsc_dv 
    
*--------------------------Difference score:---------------------------------

*1. Change in labour income among workers [wave28 vs wave29] and [wave29 vs wave30]
*1.1 selection of people in the labour market; 1.2 selection of people in the survey       
    capture drop d_fimnlab 
    capture drop dp_fimnlab
    order pidp wave working fimnlab jbisco88 
    ta working
    count if fimnlab<0
    count if working==1&fimnlab<0
    replace fimnlab=. if fimnlab<0
    sum fimnlab
    count if working==1&fimnlab==. //3894 caes only
    
    sum fimnlab if working==0
    sum fimnlab if working==0&wave>27
    replace working=1 if fimnlab>10&working==0&fimnlab~=.
    replace fimnlab=0 if working==0
    replace fimnlab=. if working==1&fimnlab<1
    
    bysort pidp: gen pre_fimnlab=fimnlab[_n-1]
    bysort pidp: gen d_fimnlab=fimnlab-pre_fimnlab
    la var d_fimnlab "Change in labour income"
    order pidp wave working fimnlab pre_fimnlab d_fimnlab
    
    //censored, unobserved if previously or currently not working
    bysort pidp: gen dp_fimnlab=d_fimnlab/pre_fimnlab
    la var dp_fimnlab "NAif previously no value and now has value: change in %labour income"
    bysort pidp: replace dp_fimnlab=. if pre_fimnlab==0&fimnlab~=.
    bysort pidp: replace dp_fimnlab=0 if pre_fimnlab==fimnlab&fimnlab~=.
    
    replace d_fimnlab=. if wave<29
    replace dp_fimnlab=. if wave<29
    order pidp wave working workhrall pre_fimnlab fimnlab d_fimnlab dp_fimnlab 
    sort pidp wave
    
    list pidp dp_fimnlab if dp_fimnlab >10&dp_fimnlab ~=.
    sum dp_fimnlab
    *hist dp_fimnlab
    count if d_fimnlab==.&wave>28
    count if wave>28
    di 3853/31247 //12% missing this info - abs values
        
*2. Change in working hours among both workers and nonworkers [wave28 vs wave29] and [wave29 vs wave30]
    sort pidp wave
    capture drop d_workhrall
    capture drop dp_workhrall
    replace workhrall=0 if working==0&workhrall==.
    bysort pidp: gen pre_workhrall=workhrall[_n-1]
    bysort pidp: gen d_workhrall=workhrall-pre_workhrall
    order pidp wave working working_pre pre_workhrall workhrall d_workhrall   
     
*3. Change in childcare time among parents - covid survey ONLY [wave30 vs wave 29]:
     sort pidp wave    
     capture drop d_timeccare
     bysort pidp: gen pre_timeccare=timeccare[_n-1]
     bysort pidp: gen d_timeccare=timeccare-pre_timeccare
     order pidp wave parent nchild pre_timeccare timeccare d_timeccare
     ta wave if  d_timeccare~=. //ONLY in wave 30
     sum d_timeccare 

*4. Change in housework time - COVID survey ONLY [imputed wave28 vs wave29, wave30 vs wave29]:
   *sum howlng if wave==28
     sort pidp wave
     gen pre_howlng=.
     
     forval i=1/4{
       bysort pidp: replace pre_howlng=howlng[_n-`i'] if pre_howlng==.
       bysort pidp: replace howlng =howlng[_n-`i'] if howlng==.&wave==28 
       //only fill in wave28 nc never asked baseline housework
     }
     count if howlng==.&wave==28
   
     sort pidp wave
     capture drop d_howlng
     bysort pidp: gen d_howlng=howlng-pre_howlng
     order pidp wave parent nchild pre_howlng howlng d_howlng
     ta wave if  d_howlng~=. //Select wave 30
     
*5. Change in subjective wellbeing - [Wave29 vs Wave27] + [wave30 vs wave29]
    *Using wave 27 working hour change
    foreach v in workhrall fimnlab {
      gen `v'swb=`v'
      sort pidp wave
      bysort pidp: gen pre_`v'swb=`v'[_n-1] if wave==28
      bysort pidp: replace `v'swb=`v'[_n-1] if wave==28
      //fill wave27 working hours into wave28-baseline covid
      capture drop d_`v'swb
      bysort pidp: gen d_`v'swb=`v'swb-`v'swb[_n-1] if wave==29
    }
    
     sort pidp wave
     
     bysort pidp: replace swb=swb[_n-1] if wave==28 
     bysort pidp: replace swb=swb[_n-2] if wave==28 &swb==.
     //only fill in w28 bc never asked baseline swb
     gen pre_swb=.
     bysort pidp: replace pre_swb=swb[_n-1] if pre_swb==.
     bysort pidp: replace pre_swb=swb[_n-2] if pre_swb==.
      //fill wave27 swb into wave28-baseline covid      
     capture drop d_swb
     bysort pidp: gen d_swb=swb-pre_swb
     order pidp wave swb d_swb
     ta wave if  d_swb~=. 
     table sex, c(mean d_fimnlab mean d_workhrall mean d_swb)

     order pidp wave working workhrall workhrallswb d_workhrallswb swb d_swb
     drop _merge
    
    
*6. Variables used in Selection Equation:
     do "$onedrive\Stata_covid/do/ukhls_7_covid1_varprep"
     
     sort pidp wave
     order pidp wave hh_hidp
     gsort pidp -wave
     bysort pidp: replace hh_hidp=hh_hidp[_n-1] if hh_hidp==.
     sort pidp wave
   
    gsort pidp -wave
    foreach v in $xheck {
    bysort pidp: replace `v'=`v'[_n-1] if `v'==.
    }
    **
    sort pidp wave
    foreach v in $xheck {
    bysort pidp: replace `v'=`v'[_n-1] if `v'==.
    }
    **
    
    drop if wave==.    
    drop if hh_hidp==. 
    drop if sex_dv==0   
    drop if age<0
     
save "$onedrive/Stata_covid/ukhls_6_covidmodel", replace

**
*-----------------Covid sample from Each Covid wave-----------*
    forval i=29/31{
use "$onedrive/Stata_covid/ukhls_6_covidmodel", clear
 *1. Filled info for each Covid Wave   
	keep if wave==`i'
    order pidp wave dp_fimnlab  d_*
    sum age
    
    *------Age Sample of Covid sample------*
    keep if age>19&age<66
save "$onedrive/Stata_covid/ukhls_6_covidmodel_w`i'", replace
}
**

*---------------------------------------------------------

*2. Full UKHLS sample

*---------------------------------------------------------
use "$onedrive/Stata_covid/ukhls_6_covidmodel",clear
    ta wave covid //wave 28 include everyone ever in Covid survey   
    sort pidp wave    
    drop if wave>27
    
     foreach y in doiy doim {
        gen `y'_pre=.
        bysort pidp: replace `y'_pre=`y'[_n-1] if `y'_pre==.
    }
    **
    gen timegap=(2020-doiy)*12+4-doim
    replace timegap=. if wave>27
    bysort pidp: replace timegap=timegap[_n-1] if wave>27
    la var timegap "month# till Covid study"
    
    order pidp wave timegap doiy_pre doiy doim_pre doim           
    sort pidp wave  
    xtset pidp wave
    /*
    xtdes //77338 individuals
    */
    capture drop wavelast
    bysort pidp: egen wavelast=max(wave)
    order pidp wave wavelast
    ta wave
    
    keep if wave== wavelast
    count
    ta wave //wave 28 would be missing because they all last in later waves
    sort pidp wave    
    
    gen age2020=2020-doiy+age
    la var age2020 "Age in the year 2020"
    order pidp wave age age2020 doiy timegap
   
    count //77356
    
    /*
  foreach var in $xheck {   
  	drop if `var'==.
  }  
    count 
    di 76136/77356
    */
    
 save "$onedrive/Stata_covid/ukhls_7_covidmodel",replace 
 //full UKHLS sample,waves before wave28
    
    
forval i=29/31{
 use "$onedrive/Stata_covid/ukhls_7_covidmodel", clear //77337 individuals
 gen ukhlsampe=1
 
 *--------------Age Sample of UKHLS full sample--------------*
 
 keep if age2020>19&age2020<66 
 count //56696
 append using "$onedrive/Stata_covid/ukhls_6_covidmodel_w`i'"
   sort pidp wave
   bysort pidp: replace timegap=timegap[_n-1] if timegap==.
   
 ta wave covid,m
 sort pidp wave
 *Not in full sample but in covid wave only, to drop these
 bysort pidp: gen covidn=_n
 bysort pidp: egen covidmax=max(covidn)
 order pidp wave covid covidn covidmax ukhlsampe
 ta covidmax if covid==1 //should always be 2 - in both 
 drop if covid==1&covidmax==2&ukhlsampe==1
 drop if ukhlsampe==.&covidmax==1
 count
 xtset pidp wave 
 count
 
 order pidp wave age age2020
 replace age2020=age if age2020==.
 drop age
 rename age2020 age
  sum age, meanonly
  gen cage = age-r(mean)  
  gen cagesq=cage*cage/100
  la var cage "Age centered"
  la var cagesq "Age centred squared"
  
 *Selection into covid sample for each wave
  gen covidnew=1 if wave==`i'
  sort pidp wave
  bysort pidp: replace covidnew=1 if covid[_n-1]==1&covidnew==.
  gsort pidp -wave
  bysort pidp: replace covidnew=1 if covid[_n-1]==1&covidnew==. 
  sort pidp wave
  replace covidnew=0 if covidnew==.
 save "$onedrive/Stata_covid/ukhls_7_covid`i'", replace
 *erase "$onedrive/Stata_covid/ukhls_6_covidmodel_w`i'.dta"
}
**


forval i=29/31{
 use "$onedrive/Stata_covid/ukhls_7_covid`i'", clear 
 ta wave
  foreach var in $xheck {   
  	count if `var'==.
  } 
}
use "$onedrive/Stata_covid/ukhls_7_covid29", clear 
    /*
    use "$onedrive/Stata_covid/ukhls_6_covidmodel_w31",clear
    hist dp_fimnlab
    hist dp_fimnlab if dp_fimnlab<3
    hist d_swb
    hist d_workhrall
    hist d_howlng
    hist d_timeccare
    */

   
  