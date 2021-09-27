 clear
 set more off 
 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close 
 
 set scheme s2color
 
 *-----------------Macro setup------------------*   
    global x "female raceminor degree" // race2 race3 race4 
    global x1 "edu2 edu3"
    global x2 "couple chageminc2 chageminc3"    //for timeccare
    global p "furlough keyworker"     
        
    global y "netpay15_month hours scghq1 howlng timechcare "
    global coefv "female raceminor edu2 edu3 chageminc2 chageminc3 furlough keyworker _cons"  //coefplot
	global cage "age agesq"
	global howlngc "howlngage howlngagesq"
	
	global covidtest "covidtest2 covidtest3 covidtest4"
	global covidmacro "week_deathrate" /*week_newcases_k  week_deathrate week_newdeaths28days_k*/
	global weight "betaindin_xw_w0"
	
	
*---------------------Fixed-effect models: COVID sample-----------------------*
use "$WorkData/5covid_long.dta",clear
	order pidp covidwave $covidmacro
eststo clear
	
order pidp covidwave surveydate new* lnnetpay couple parent $cage $covidtest 

	*table covidwave, c(mean scghq1 mean howlng mean timechcare)
*----------------------------Net Pay FE Models---------------------------

  *======================Baseline Models - with macro-levle COVID indicator:====================== 
  //need to change the reference period group to make the std errors similar across period

	 xtreg lnnetpay ccovidwave1 ccovidwave3 ccovidwave4 ccovidwave5 ccovidwave6 ccovidwave7 ccovidwave8 ccovidwave9 ///
		/*newcasesbypublishdate*/ couple parent  $covidtest $covidmacro [aw=$weight], fe vce(cluster x_strata)
	  est store pay_m0c
	  vif, uncentered

	 xtreg hours ccovidwave1 ccovidwave3 ccovidwave4 ccovidwave5 ccovidwave6 ccovidwave7 ccovidwave8 ccovidwave9 ///
		/*newcasesbypublishdate*/ couple parent  $covidtest $covidmacro [aw=$weight], fe vce(cluster x_strata)
	  est store hours_m0c
	  vif, uncentered
	 
	xtreg howlng ccovidwave1 ccovidwave3 ccovidwave4 ccovidwave5 ccovidwave6 ccovidwave7 ccovidwave8 ccovidwave9 ///
		howlngcouple howlngparent $covidtest $covidmacro  [aw=$weight], fe vce(cluster x_strata)
	 est store howlng_m0c
	 vif, uncentered
	
	xtreg timechcare ccovidwave3 ccovidwave4 ccovidwave6 ccovidwave8 ///
	couple $covidtest $covidmacro [aw=$weight], fe vce(cluster x_strata)
	 est store ccare_m0c	 
	 vif, uncentered	
 
	 //model fitness is not improved, and $covidmacro is not associated with those outcomes

	 xtreg scghq1 ccovidwave1 ccovidwave3 ccovidwave4 ccovidwave5 ccovidwave6 ccovidwave7 ccovidwave8 ccovidwave9 ///
		howlngcouple howlngparent $covidtest  [aw=$weight], fe vce(cluster x_strata)	
	 est store swb_m0c0 //model without macro covid measure, covidwave2 as reference
	 *vif, uncentered
	 
	 xtreg scghq1 ccovidwave1 ccovidwave3 ccovidwave4 ccovidwave5 ccovidwave6 ccovidwave7 ccovidwave8 ccovidwave9 ///
		howlngcouple howlngparent $covidtest $covidmacro [aw=$weight], fe vce(cluster x_strata)	
	 est store swb_m0c //model with macro covid measure, covidwave2 as reference
	 vif, uncentered
	 
	 *Supplementary: 1. Overall change in each wave
	#delimit ; 
	esttab  pay_m0c hours_m0c howlng_m0c ccare_m0c swb_m0c swb_m0c0 
    using "$Output/ta2a_deathrate.rtf",
    replace 
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Weekly working hours"  
	"Weekly housework hours" "Weekly childcare hours" 
	"Subjective wellbeing" "Subjective wellbeing - No death rate") 
    collabels(,none)  
    nobase nodep title("Baseline Models (reference period: April 2020, 1st lockdown)") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
	 
	*Supplementary:  2. Two models for predicting subjective wellbeing:	 
	 #delimit ; 
	esttab  swb_m0c0 swb_m0c 
    using "$Output/ta3_swb.rtf",
    replace 
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Not including death rate" "Including death rate") 
    collabels(,none)  
    nobase nodep title("Table 2. Predicting subjecive wellbeing (distress level), reference period: April 2020, 1st lockdown") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
	 
	 
	
	*===============================Baseline models - No Macro-level COVID indicator:=============================*
	quietly {
		xtreg lnnetpay i.covidwave couple parent $covidtest  [aw= $weight ], fe vce(cluster x_strata)
		est store pay_m0	
		
		xtreg hours i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
		est store hours_m0	
		
		xtreg scghq1 i.covidwave howlngcouple howlngparent $covidtest  [aw=$weight], fe vce(cluster x_strata)
		est store swb_m0
		
		xtreg howlng i.covidwave howlngcouple howlngparent $covidtest   [aw=$weight], fe vce(cluster x_strata)
		est store howlng_m0	
		
		xtreg timechcare i.covidwave couple $covidtest  [aw=$weight], fe vce(cluster x_strata)
		est store ccare_m0	
	}
		
 *Coefplot of the baseline models- differences across waves:
	do "$Do/ukcovid_8_fe1_coefplot_baseline"
	
	graph combine m0_1 m0_2 m0_3 m0_4 , ///
	graphregion(color(white)) 
    
    graph export "$Output\m0.png", as(png) replace 
	
	graph combine m0_1t m0_2t m0_3t m0_4t , ///
	graphregion(color(white)) title(Reference: No COVID-19 test)
    
    graph export "$Output\m0t.png", as(png) replace 

	*1. Overall change in each wave
	#delimit ; 
	esttab  pay_m0 hours_m0 swb_m0 howlng_m0 ccare_m0
    using "$Output/ta2.rtf",
    replace 
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Weekly working hours" "Subjective wellbeing" 
	"Weekly housework hours" "Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("Baseline Models") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
	 

	 
	
*=======================================Interaction Models========================================*	
	
quietly {
 *2. covid wave 1 xweight used:	
	xtreg lnnetpay i.female##i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw1
	
	xtreg lnnetpay i.female##i.covidwave couple parent $covidtest  if xkeyworker~=1 [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw1_2 
	
	xtreg lnnetpay i.raceminor##i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw3
	
	xtreg lnnetpay i.raceminor##i.covidwave couple parent $covidtest  if xkeyworker~=1  [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw3_2
	
	xtreg lnnetpay i.degree##i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw4
	
	xtreg lnnetpay i.degree##i.covidwave couple parent $covidtest if xkeyworker~=1  [aw=$weight], fe vce(cluster x_strata)
	est store pay_mw4_2
}
	
	
*--------------------------Time use ------------------------		
	
 *1. working hours - select workers only, how about those who left labor market during this year, should be selected in.	
quietly {
foreach v in hours {
	
	xtreg `v' i.female##i.covidwave couple parent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw1	
	xtreg `v' i.female##i.covidwave couple parent $covidtest if xkeyworker~=1 [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw1_2
	
	xtreg `v' i.raceminor##i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw3
	
	xtreg `v' i.raceminor##i.covidwave couple parent $covidtest if xkeyworker~=1 [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw3_2
	
	xtreg `v' i.degree##i.covidwave couple parent $covidtest  [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw4
	
	xtreg `v' i.degree##i.covidwave couple parent $covidtest  if xkeyworker~=1 [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw4_2
	
}
}

**

 *2. Housework and subjective wellbeing - need to use info pooled from main survey, use howlngcouple howlngparent
quietly {
foreach v in howlng scghq1 {

	xtreg `v' i.female##i.covidwave howlngcouple howlngparent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw1
	/*
	xtreg `v' i.howlngparent##i.covidwave howlngcouple $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw2
	*/
	xtreg `v' i.raceminor##i.covidwave howlngcouple howlngparent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw3
	xtreg `v' i.degree##i.covidwave howlngcouple howlngparent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw4
}
}
**

  *---------------Childcare time - could drop this one as no earlier time info available:----------
  *And no interaction effect shown
   table covidwave, c(mean timechcare) //in waves 1, 2, 3, 5
   ta parent if covidwave==1|covidwave==2|covidwave==3|covidwave==5|covidwave==7 //14432 records
   count if timechcare==.&parent==1&covidwave==1| ///
			timechcare==.&parent==1&covidwave==2| ///
			timechcare==.&parent==1&covidwave==3| ///
			timechcare==.&parent==1&covidwave==5| ///
			timechcare==.&parent==1&covidwave==7| ///
			timechcare==.&parent==1&covidwave==8
  *reference point: covidwave1 - during April 2020
  
   quietly {
foreach v in timechcare{
	
	xtreg `v' i.female##i.covidwave couple $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw1
	
	xtreg `v' i.raceminor##i.covidwave couple $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw3
	
	xtreg `v' i.degree##i.covidwave couple $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store `v'_mw4
}
}


*=============================================================*
*Output to tables: lnnetpay hours scghq1 howlng timechcare
*=============================================================*	 

*By gender:

#delimit ; 
esttab  pay_mw1 pay_mw1_2 hours_mw1 hours_mw1_2 scghq1_mw1 howlng_mw1 timechcare_mw1
    using "$Output/ta2.rtf",
    append 
    label  b(2) nonum not nodep mti  
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker" 
	"Weekly working hours" 	"Weekly working hours - non-keyworker" 
	"Subjective wellbeing" 
	"Weekly housework hours" 
	"Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("Gender Models") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
	 
	*Output reporting p-value
#delimit ; 
esttab  pay_mw1 pay_mw1_2 hours_mw1 hours_mw1_2 scghq1_mw1 howlng_mw1 timechcare_mw1
    using "$Output/ta2.rtf",
    append b(2) p(3) nonum not nodep mti  
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker" 
	"Weekly working hours" 	"Weekly working hours - non-keyworker" 
	"Subjective wellbeing" 
	"Weekly housework hours" 
	"Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("Gender Models, p-value") 
    cells("b(fmt(3)star)" "p(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr  
  
  


*By 3.raceminority

#delimit ; 
esttab  pay_mw3 pay_mw3_2 hours_mw3 hours_mw3_2 scghq1_mw3 howlng_mw3 timechcare_mw3
    using "$Output/ta2.rtf",
    append
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker"  
	"Weekly working hours" "Weekly working hours - non-keyworker"  
	"Subjective wellbeing" 
	"Weekly housework hours" 
	"Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("BAME models") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
  #delimit cr 
   
   
   *Output reporting p-value
#delimit ; 
esttab  pay_mw3 pay_mw3_2 hours_mw3 hours_mw3_2 scghq1_mw3 howlng_mw3 timechcare_mw3
    using "$Output/ta2.rtf",
    append
    label b(2) p(3)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker"  
	"Weekly working hours" "Weekly working hours - non-keyworker"  
	"Subjective wellbeing" 
	"Weekly housework hours" 
	"Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("BAME models, p-value") 
    cells("b(fmt(3)star)" "p(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
  #delimit cr     


*By education

#delimit ; 
esttab  pay_mw4 pay_mw4_2 hours_mw4 hours_mw4_2 scghq1_mw4 howlng_mw4 timechcare_mw4
    using "$Output/ta2.rtf",
    append
    label b(2)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker"  
	"Weekly working hours" "Weekly working hours - non-keyworker"  
	"Subjective wellbeing" 
	"Weekly housework hours" "Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("Education models") 
    cells("b(fmt(3)star)" "se(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 

**
*Output reporting p-value
#delimit ; 
esttab  pay_mw4 pay_mw4_2 hours_mw4 hours_mw4_2 scghq1_mw4 howlng_mw4 timechcare_mw4
    using "$Output/ta2.rtf",
    append
    label b(2) p(3)  nonum not nodep mti   
    eqlabels(none) 
    mtitles("Ln net earnings" "Ln net earnings - non-keyworker"  
	"Weekly working hours" "Weekly working hours - non-keyworker"  
	"Subjective wellbeing" 
	"Weekly housework hours" 
	"Weekly childcare hours") 
    collabels(,none)  
    nobase nodep title("Education models, p-value") 
    cells("b(fmt(3)star)" "p(fmt(3)par)")
    modelwidth(8) varwidth(20) 
    star(* .05 ** .01 *** .001) 
    stats(r2_o r2_w r2_b rho N_g N , fmt(3 3 3 3 0 0)
    labels("R2" "Within R2" "Between R2" "Rho"  
    "Number of individuals" 
    "Number of person-years" ))
    addnotes("Data: UKHLS & Understanding Society Covid survey waves 1-8. Note: * p<0.05  ** p<0.01  *** p<0.001");
     #delimit cr 
	 
