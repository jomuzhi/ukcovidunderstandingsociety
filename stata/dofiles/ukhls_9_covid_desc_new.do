 clear
 set more off
 global local "D:\Academia\Data"
 global onedrive ///
 "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do" 
 
 do "$onedrive/Stata_2020\Do/ukhls_00dir" 
 set scheme s2color
 
 *-----------------Macro setup------------------*
    global x "genderparent1 genderparent2 genderparent3 genderparent4 couple raceminor"
    global x1 "edu1 edu2 edu3" 
    global p "furloughc1 furloughc2 furloughc3 keyworkerc1 keyworkerc2 keyworkerc3" 
    global occup "wah_pre jbisco88_pre jbnssec5_pre jbseg_dv_pre jbrgsc_dv_pre"
    global xheck "genderparent2 genderparent3 genderparent4 couple raceminor ukbornd edu2 edu3 lnfihhmnpre cage cagesq tenure2 tenure3 tenure4 region2 region3 region4 region5 region6 region7 timegap"
        
    /*notonbenefits*/  
    //too many missing values
    
    global c "age"
    
    global ypre "dp_fimnlab d_workhrall d_howlng d_swb wah"
    global ypost "dp_fimnlab d_workhrall d_howlng d_timeccare d_swb wah"
    global y29mean "fimnlab workhrall howlng swb"
    global y30mean "fimnlab workhrall howlng swb timeccare"
*    
*====================================================*

*Full UKHLS sample from old UKHLS

*====================================================*
forval i=29/31{
use "$onedrive/Stata_covid/ukhls_7_covid`i'",clear 
 replace dp_fimnlab=. if working_pre==0
    sum dp_fimnlab
    count if dp_fimnlab>2&dp_fimnlab~=.
}

forval i=29/31{
use "$onedrive/Stata_covid/ukhls_7_covid`i'",clear
ta wave covid

**out of the same number of ukhls sample
    
*Labour income: only available for those who did work in previous wave
    la var dp_fimnlab "Change in monthly labour earnings"
    order pidp wave working working_pre fimnlab dp_fimnlab parent
    replace dp_fimnlab=. if working_pre==0
    replace fimnlab=. if working_pre==0 
    replace pre_fimnlab=. if working_pre==0
    
  *Labour income change capped:  
    count if dp_fimnlab~=.
    sum dp_fimnlab
    count if dp_fimnlab>2&dp_fimnlab~=. //less than 1% of the sample
    replace  dp_fimnlab=2 if dp_fimnlab>2&dp_fimnlab~=. 
   /* 
*Working hours: ONly available for those who did work in previous waves
    replace d_workhrall=. if working_pre==0
    replace workhrall=. if working_pre==0 
    replace pre_workhrall=. if working_pre==0
   */ 
    la var wah "Working from home"
    ta wah,m
    ta wave wah
    tabulate wah, gen(wahd)
    la var wahd1 "Never"
    la var wahd2 "Sometimes vs Never"
    la var wahd3 "Often/always vs Never"
    la var wahd4 "Not working vs Never"
    
    la def wavecovid 29 "Pre-lockdown vs April" 30 "April vs May 2020" 31 "May vs June 2020"
    la val wave wavecovid
    
    order pidp wave dp_* d_*
 save "$onedrive/Stata_covid/ukhls_9_covid`i'", replace
  
}
**

*---------------T-test outcome acoss X--------------------*
*1. Labour earnings:
forval i=29/31{
use "$onedrive/Stata_covid/ukhls_9_covid`i'",clear 
/*
    sort pidp wave
    ta wave
    ta wave working_pre
    ta wave parent
*/
    sum dp_fimnlab
    count if dp_fimnlab>2&dp_fimnlab~=.
}


use "$onedrive/Stata_covid/ukhls_9_covid31",clear 
    //all UKHLS individuals in, no duplicated individual
    sum age 
    keep if wave>27
    ta wave
    count //
    foreach v in $x $x1 $c $xheck{
    	drop if `v'==.
         drop if xweight==0
    } //drop sample with missing predictors
    
    count    
             
  *Full sample, and full sample with no missing dependent variable - d_workhrall d_howlng d_swb
    count if d_workhrall~=.
    count if d_howlng~=.
    count if d_swb~=.
    
    
  *Parent sample, and parent sample with no missing in d_timeccare
    count if parent==1
    count if parent==1&d_timeccare~=.
    
  *Worker sample, and worker sample with nonmissing dependent variable - labour income change
    order pidp wave working working_pre pre_fimnlab fimnlab
    ta working_pre    
    count if dp_fimnlab~=.&working_pre==1
 
    
  *Labour income change capped:     
    table working_pre, c(min dp_fimnlab max dp_fimnlab min fimnlab max fimnlab)
    sum dp_fimnlab //8.6% drop
    sum dp_fimnlab [aw=xweight] //9.7% drop
    
    foreach x in $x $x1 {        
        table `x', c(mean pre_fimnlab mean fimnlab mean d_fimnlab) format(%9.1f)   
        table `x', c(sd pre_fimnlab sd fimnlab sd d_fimnlab) format(%9.1f)
        table `x', c(mean dp_fimnlab sd dp_fimnlab) format(%9.3f)  
        ttest dp_fimnlab, by(`x')
    }    

*2. Others:
    ta wave
    ta covidnewmissing //4.25%,10.41%,8.98% missing for workhrall howlng swb
    keep if covidnewmissing==0 
    foreach y in $ypost {
    foreach x in $x $x1 {
    	table `x', c(mean pre_`y' mean `y' mean d_`y') format(%9.1f) 
        table `x', c(sd pre_`y' sd `y' sd d_`y') format(%9.1f) 
        ttest d_`y', by(`x')
    }    
    }
    **  
}

    
 *---------------------Descriptive:Simple outcome and Predictor------------------------------------*   
 forval i=29/29{
    use "$onedrive/Stata_covid/ukhls_9_covid`i'", clear
    la var swb "Subjective wellbeing (GHQ)"
    la var fimnlab "Monthly labour income of workers"
    la var timeccare "Weekly childcare time of parents"
    keep if wave>27
    foreach v in $x $x1 $c $xheck{
    	drop if `v'==.
        drop if xweight==0
        *drop if d_swb==.
    } //drop sample with missing predictors
    
    ta wave  //9440    
    eststo clear
  #delimit ; 
    qui   eststo des_predictors: 
    estpost tabstat pre_fimnlab pre_workhrall pre_howlng pre_timeccare pre_swb 
    dp_fimnlab fimnlab  $y30mean $x $x1 $c $p $xheck [aw=xweight], statistics 
    (mean sd N min max) columns(statistics);
    esttab using
    "$onedrive/Stata_covid/coefplot/TabA1_desc.csv", 
    cells("mean(fmt(2)) sd(par fmt(2)) count(fmt(0)) min(fmt(0)) max(fmt(0)) ") 
    mtitles ("Wave `i'") label compress
    nostar unstack nonote nonumber noobs 
    noomitted replace;
   #delimit cr 	
	**
 }
 **
 
  forval i=30/31{
    use "$onedrive/Stata_covid/ukhls_9_covid`i'", clear
    la var swb "Subjective wellbeing (GHQ)"
    la var fimnlab "Monthly labour income of workers"
    la var timeccare "Weekly childcare time of parents"
    keep if wave>27
    
    foreach v in $x $x1 $c{
    	drop if `v'==.
        drop if xweight==0
        *drop if d_swb==.
    } //drop sample with missing predictors
    
    
    ta wave  //9440    
    eststo clear
  #delimit ; 
    qui   eststo des_predictors: 
    estpost tabstat fimnlab dp_fimnlab $y30mean $x $x1 $p $c [aw=xweight], statistics 
    (mean sd N min max) columns(statistics);
    esttab using
    "$onedrive/Stata_covid/coefplot/TabA1_desc.csv", 
    cells("mean(fmt(2)) sd(par fmt(2)) count(fmt(0)) min(fmt(0)) max(fmt(0)) ") 
    mtitles ("Wave `i'") label compress
    nostar unstack nonote nonumber noobs 
    noomitted append;
   #delimit cr 	
	**
 }

   
    
    
    