 clear
 set more off
 global local "D:\Academia\Data"
 global onedrive ///
 "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do" 
 
 do "$onedrive/Stata_2020\Do/ukhls_00dir" 
 set scheme s2color
 
 *-----------------Macro setup------------------*
    global xheck "genderparent2 genderparent3 genderparent4 couple raceminor ukbornd edu2 edu3 lnfihhmnpre cage cagesq tenure2 tenure3 tenure4 region2 region3 region4 region5 region6 region7 timegap"
/*sfhealth2 sfhealth3 sfhealth4*/
    global xheckp "female chageminc2 couple raceminor ukbornd edu2 edu3 lnfihhmnpre cage cagesq tenure2 tenure3 tenure4 region2 region3 region4 region5 region6 region7 timegap"

    global x "raceminor" // race2 race3 race4 , ukbornd
    global demo "genderparent2 genderparent3 genderparent4 couple"
    global x1 "edu2 edu3"
    global p "chronic keyworkerc1 keyworkerc2 furloughc1 furloughc2" 
    /*furlough notonbenefits*/ 
    //too many missing values
    
    global c "cage cagesq"
    
    global ypre "dp_fimnlab d_workhrall d_howlng d_swb "
    global ylogit "wah"
    global coefv "genderparent2 genderparent3 genderparent4 raceminor edu2 edu3 chronic furlough keyworker _cons"  
    //coefplot furlough keyworker 
    global coefvlogit "*.jbnssec5_pre semp female raceminor edu2 edu3 _cons"
    //Occupation and who can work from home!
*  
  
*===============================================================*

*Models: Four dimensions of inequality: gender, race/ethnicity, education, and health

*===============================================================*
eststo clear
    
*------------Models test:Parents' work time, housework time, wellbeing----------
use "$onedrive/Stata_covid/ukhls_9_covid29",clear    
    foreach v in $demo $x $x1 $c $xheck {
    	drop if `v'==.
        drop if xweight==0
    } //drop sample with missing predictors
    
    count
    ta wave //11996
    count if d_workhrall ~=.
    count if xweight==.
    count if xweight~=0&d_workhrall ~=.
    
    reg d_workhrall  $demo $x $x1 $c [aw=xweight],  ///
    vce(cluster hh_hidp) 
    
    
    foreach y in d_workhrall  {
 	sum `y'     
    keep if working==1 //workers in covid
   *1. Basic OLS Model:
    reg `y' $demo $x $x1 $c /*keyworkerc2 furlough*/ [aw=xweight],  ///
    vce(cluster hh_hidp)    
    est store `y'_w`i'
    *predict `xvar'_femr`i'  
    }
  


    
*------------Models 1:Labour income, work time, housework time, wellbeing----------
forval i = 29/31 {
use "$onedrive/Stata_covid/ukhls_9_covid`i'",clear
    ta wave covid
    
    foreach v in $x $x1 $c $xheck {
    	drop if `v'==.
        drop if xweight==0
    } //drop sample with missing predictors
    
    
    foreach y in $ypre{
 	sum `y'     
    
   *1. Basic OLS Model:
    reg `y'  $demo $x $x1 $c [aw=xweight],  ///
    vce(cluster hh_hidp)    
    est store `y'_w`i'
    *predict `xvar'_femr`i'    
  
   *2. Heckman Model considering sample selection into covid study:
    #delimit ;
    heckman `y' $demo $x $x1 $c ,
    select (covid = $xheck) 
    vce(cluster hh_hidp)
    ;  
    #delimit cr
    est store `y'hk_w`i'   
    //vce(cluster geo) not go with twostep
    //twostep mills(invmills_femr`i')- NA for ML method
    }
   
}


*------------------Models 2:Childcare time among parents----------------
forval i = 30/31 {
use "$onedrive/Stata_covid/ukhls_9_covid`i'",clear
    drop if wave>`i'
    
     foreach v in $x $x1 $c $xheck{
    	drop if `v'==.
        drop if xweight==0
    } //drop sample with missing predictors
    
    keep if parent==1
    ta wave    
    *eststo clear
    foreach y in d_timeccare  {
 	sum `y'     
   *1. Basic OLS Model:
   reg `y' female chageminc2 couple $x $x1 $c [aw=xweight],  ///
    vce(cluster hh_hidp)    
    est store `y'_w`i'
    *predict `xvar'_femr`i'    
  
   *2. Heckman Model considering sample selection into covid study:
    #delimit ;
    heckman `y' female chageminc2 couple $x $x1 $c,
    select (covid = $xheckp) 
    vce(cluster hh_hidp)
    ;  
    #delimit cr
    est store `y'hk_w`i'   
    //vce(cluster geo) not go with twostep
    //twostep mills(invmills_femr`i')- NA for ML method
    }
}

**================================================

***                   Coef Plot* 

*==================================================

***Graphs from baseline wave, with y label, no aspectratio
forval i=29/29{
foreach y in $ypre {
   **------------Coef Plot*------------  
    local v: label (wave) `i'
    local j=`i'-28
	#delimit ; 
	coefplot 
	(`y'_w`i', 
    mlc(gs10) ms(o) mlw(.3) mc(gs10) 
    offset(.2) ciopts(lc(gs10) recast(rcap)) 
    lc(red)label("OLS")) 
	(`y'hk_w`i' , 
    mlc(gs0) ms(x) mlw(.3) mc(gs0)
    offset(-0.1) ciopts(lc(gs0) recast(rcap)) 
    lc(gs0)label("Heckman")) ,
    name(`y'_w`i', replace)
	keep($coefv)
    coeflabels(female = "Women" chronic="Chronic disease"
    genderparent2 = "Childless women vs Childless men" 
    genderparent3 = "Fathers vs Childless men" 
    genderparent4="Mothers vs Childless men"
    raceminor = "BAME vs White"
    edu2="Higher Second. vs GCSE" edu3="Degree vs GCSE"
    chageminc1="Child age<5" chageminc2="Child age 5-15 vs <5"
    chageminc3="No child vs child<5" _cons="Const.",
    wrap(12) ) 
    mlabel mlabp(11) mlabg(0.8)  mlabf(%5.2f)     
    xline(0,lc(black) lw(.1)) 
	graphregion(color(white) margin(left)) bgcolor(white) 
	title("`v'", size(medium)) 
    ;
     graph save `y'_w`i', replace;
	#delimit cr 
}
}

****


***Graphs from later waves, to combine, no y label and change aspectratio
forval i=30/31{
foreach y in $ypre {
   **------------Coef Plot*------------  
   local j=`i'-28
   local v: label (wave) `i'
	#delimit ; 
	coefplot 
	(`y'_w`i', 
    mlc(gs10) ms(o) mlw(.3) mc(gs10) 
    offset(.2) ciopts(lc(gs10) recast(rcap)) 
    lc(red)label("OLS")) 
	(`y'hk_w`i' , 
    mlc(gs0) ms(x) mlw(.3) mc(gs0)
    offset(-0.1) ciopts(lc(gs0) recast(rcap)) 
    lc(gs0)label("Heckman")) ,
    name(`y'_w`i', replace)
	keep($coefv) 
    mlabel mlabp(12) mlabg(0.8)  mlabf(%5.2f)     
    xline(0,lc(black) lw(.1)) 
    ylab(,nolab notick) 
	graphregion(color(white) margin(zero)) bgcolor(white)
    aspectratio(2.8)
	title("`v'", size(medium)) 
    ;
     graph save `y'_w`i', replace;
	#delimit cr 
}
}
****

***Childcare time Graphs from later waves, 1st wave wave 30 with y label
forval i=30/30{
foreach y in d_timeccare {
   **------------Coef Plot*------------  
    local v: label (wave) `i'
    local j=`i'-28
	#delimit ; 
	coefplot 
	(`y'_w`i', 
    mlc(gs10) ms(o) mlw(.3) mc(gs10) 
    offset(.2) ciopts(lc(gs10) recast(rcap)) 
    lc(red)label("OLS")) 
	(`y'hk_w`i' , 
    mlc(gs0) ms(x) mlw(.3) mc(gs0)
    offset(-0.1) ciopts(lc(gs0) recast(rcap)) 
    lc(gs0)label("Heckman")) ,
    name(`y'_w`i', replace)
	keep(female $coefv)
    coeflabels(female = "Mother vs Father" chronic="Chronic disease"
    genderparent2 = "Women vs Men (no child)" 
    genderparent3 = "Fathers" genderparent4="Mothers"
    raceminor = "BAME vs White"
    edu2="Higher Secondary vs GCSE" edu3="Degree vs GCSE"
    chageminc1="Child age<5" chageminc2="Child age 5-15 vs <5"
    chageminc3="No child vs child<5" _cons="Const.",
    wrap(9)) 
    mlabel mlabp(12) mlabg(0.8)  mlabf(%5.2f)     
    xline(0,lc(black) lw(.1)) 
	graphregion(color(white) margin(left)) bgcolor(white) 
	title("`v'", size(medium)) ;
     graph save `y'_w`i', replace;
	#delimit cr 
}
}
****


***Childcare time Graphs from later waves, to combine, no y label and change aspectratio
forval i=31/31{
foreach y in d_timeccare {
   **------------Coef Plot*------------  
   local j=`i'-28
   local v: label (wave) `i'
	#delimit ; 
	coefplot 
	(`y'_w`i', 
    mlc(gs10) ms(o) mlw(.3) mc(gs10) 
    offset(.2) ciopts(lc(gs10) recast(rcap)) 
    lc(red)label("OLS")) 
	(`y'hk_w`i' , 
    mlc(gs0) ms(x) mlw(.3) mc(gs0)
    offset(-0.1) ciopts(lc(gs0) recast(rcap)) 
    lc(gs0)label("Heckman")) ,
    name(`y'_w`i', replace)
	keep(female $coefv) 
    mlabel mlabp(12) mlabg(0.8)  mlabf(%5.2f)     
    xline(0,lc(black) lw(.1)) 
    ylab(,nolab notick) 
	graphregion(color(white) margin(zero)) bgcolor(white)
	title("`v'", size(medium))
    aspectratio(1.5)
    ;
     graph save `y'_w`i', replace;
	#delimit cr 
}
}
****

*-----------------------------------------------------------------

*                 Combine multiple waves graphs

*-----------------------------------------------------------*
  *All other continuous outcomes except for childcare
   foreach y in dp_fimnlab  d_workhrall d_howlng d_swb {
    grc1leg2  `y'_w29.gph `y'_w30.gph `y'_w31.gph,  ///
    name(`y', replace) ycommon xcommon  title("`: var label `y''") ///
    graphregion(color(white) margin(zero)) row(1)
  gr export "$onedrive/Stata_covid/coefplot/`y'.png", replace
   }  
   **   
   
   dp_fimnlab d_workhrall d_howlng d_swb
   
   
  *Childcare time:
    foreach y in d_timeccare  {
    grc1leg2 `y'_w30.gph `y'_w31.gph,  ///
     name(`y', replace) ycommon xcommon  title("`: var label `y''") ///
    graphregion(color(white) margin(zero)) row(1)
    gr export "$onedrive/Stata_covid/coefplot/`y'.png", replace  
}

**

*============================================================

*           Table Output: Append into one file

*============================================================
    *local v: label (femr) `i'

    foreach y in dp_fimnlab{
#delimit ;     
    esttab  `y'_w29 `y'hk_w29
       `y'_w30 `y'hk_w30
       `y'_w31 `y'hk_w31
    using "$onedrive/Stata_covid/coefplot/TA2.rtf",
    replace 
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles(
    "W29 OLS" "W29 Heckman"
    "W30 OLS" "W30 Heckman"
    "W31 OLS" "W31 Heckman"
    ) 
    collabels(,none)  
    nobase nodep title("`: var label `y''") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(6) varwidth(12) 
    star(* .05 ** .01 *** .001) 
    stats(r2 lambda rho chi2 p chi2_c p_c ic converged N, fmt(3 3 3 3 3 3 3 0 0 0) 
    labels("R2" "Lambda" "Rho" "Chi-squared model test" "P-value model test" "Chi-squared comparison test" "P-value comparison test" "Number of iterations" "Whether converged" "Number of individuals")) 
    addnotes("Data: UKHLS Understanding Society wave 8-9 and Covid waves 1-3. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
}
**


    foreach y in d_workhrall d_howlng d_swb {
#delimit ;     
    esttab  `y'_w29 `y'hk_w29
       `y'_w30 `y'hk_w30
       `y'_w31 `y'hk_w31
    using "$onedrive/Stata_covid/coefplot/TA2.rtf",
    append
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles(
    "W29 OLS" "W29 Heckman"
    "W30 OLS" "W30 Heckman"
    "W31 OLS" "W31 Heckman"
    ) 
    collabels(,none)  
    nobase nodep title("`: var label `y''") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(6) varwidth(12) 
    star(* .05 ** .01 *** .001) 
    stats(r2 lambda rho chi2 p chi2_c p_c ic converged N, fmt(3 3 3 3 3 3 3 0 0 0) 
    labels("R2" "Lambda" "Rho" "Chi-squared model test" "P-value model test" "Chi-squared comparison test" "P-value comparison test" "Number of iterations" "Whether converged" "Number of individuals")) 
    addnotes("Data: UKHLS Understanding Society wave 8-9 and Covid waves 1-3. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
}
**


    foreach y in d_timeccare {
#delimit ;     
    esttab `y'_w30 `y'hk_w30
       `y'_w31 `y'hk_w31
    using "$onedrive/Stata_covid/coefplot/TA2.rtf",
    append
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles(
    "W29 OLS" "W29 Heckman"
    "W30 OLS" "W30 Heckman"
    "W31 OLS" "W31 Heckman"
    ) 
    collabels(,none)  
    nobase nodep title("`: var label `y''") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(6) varwidth(12) 
    star(* .05 ** .01 *** .001) 
    stats(r2 lambda rho chi2 p chi2_c p_c ic converged N, fmt(3 3 3 3 3 3 3 0 0 0) 
    labels("R2" "Lambda" "Rho" "Chi-squared model test" "P-value model test" "Chi-squared comparison test" "P-value comparison test" "Number of iterations" "Whether converged" "Number of individuals")) 
    addnotes("Data: UKHLS Understanding Society wave 8-9 and Covid waves 1-3. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
}
**