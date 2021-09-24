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
    global c "age2020 age2020sq"    
	global covidtest "covidtest2 covidtest3 covidtest4"
    global y "netpay15_month hours howlng timechcare scghq1"
    global coefv "female raceminor edu2 edu3 chageminc2 chageminc3 furlough keyworker _cons"  //coefplot
	
	global weight "betaindin_xw_w0"
  
 *========================================================================================
	 
*Check differential estimates across social groups

*========================================================================================

use "$WorkData/5covid_long.dta",clear

	eststo clear
	recode female 0=1 1=0, gen(male)
	recode raceminor 0=1 1=0, gen(whites)
	recode degree 0=1 1=0, gen(nondegree)
	la var lnnetpay "Ln net earnings"
	la var hours "Weekly paid work hours"
	la var howlng "Weekly housework hours"
	la var scghq1 "Distress level"
	la var timechcare  "Weekly childcare hours"
	
	*xtreg lnnetpay i.female##i.covidwave couple parent [aw=betaindin_xw], fe 
	
	quietly {
	foreach v in female male raceminor whites degree nondegree {
	xtreg lnnetpay i.`v'##i.covidwave couple parent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store lnnetpay_non`v'	
	
	xtreg hours i.`v'##i.covidwave couple parent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store hours_non`v'
	
	xtreg scghq1 i.`v'##i.covidwave howlngcouple howlngparent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store scghq1_non`v'
	
	xtreg howlng i.`v'##i.covidwave howlngcouple howlngparent $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store howlng_non`v'
			
	xtreg timechcare i.`v'##i.covidwave couple $covidtest [aw=$weight], fe vce(cluster x_strata)
	est store timechcare_non`v'	
}
}
**

  *Non-keyworkers ONLY
	quietly {
	foreach v in female male raceminor whites degree nondegree {
	xtreg lnnetpay i.`v'##i.covidwave couple parent $covidtest [aw=$weight] if xkeyworker~=1 , fe vce(cluster x_strata)
	est store lnnetpaynonkwk_non`v'	
	
	xtreg hours i.`v'##i.covidwave couple parent $covidtest [aw=$weight] if xkeyworker~=1 , fe vce(cluster x_strata)
	est store hoursnonkwk_non`v'
	}
	}


*Coefplot:
*---------------------1. gender interaction - mw1-----------------
	foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'_female, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-1.6(0.4)-0.2))   ylab(-1.6(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'nonkwk_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'nonkwk_female, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-1.6(0.4)-0.2))   ylab(-1.6(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'_female, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-24(4)-4)) ylab(-24(4)-4)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
		foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'nonkwk_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'nonkwk_female, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-24(4)-4)) ylab(-24(4)-4)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
		
	    grc1leg2  lnnetpay_female hours_female lnnetpaynonkwk_female hoursnonkwk_female,  ///
		xcommon xtob xtitlefrom(lnnetpaynonkwk_female)  ///
		graphregion(color(white))  legendfrom(lnnetpay_female)  labsize(small)
		gr export "$Output/m1_women1.png", replace
		
	
	foreach var in  scghq1 /*changing reference period*/ {
	#delimit ; 
		coefplot 
		(`var'_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'_nonfemale,
		offset(0.1) mlc(black) ms(S) mlw(.3) mc(black) 
		ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'_female, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		coeflabels() aspectratio(1)
		graphregion(color(white)) bgcolor(white)
		xtitle("(reference period: 2017/2019)")
		ytitle("`: var label `var''" ,size(medim) ) 
		title("Subjective wellbeing") vertical ;
	#delimit cr 	
	}

	foreach var in  howlng /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'_female, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(4.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		 coeflabels() aspectratio(1)
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''",size(medim) ) 
		title(Housework) vertical ;
	#delimit cr 	
	}

		grc1leg2  scghq1_female howlng_female,  ///
		xcommon xtob  ///
		graphregion(color(white))  legendfrom(scghq1_female)  labsize(small) 
		gr export "$Output/m1_women2.png", replace
		

	
	
*----------------2. raceminor interaction - mw3------------------------
/*
	la var lnnetpay "1. Change in Ln net earnings"
	la var hours "2. Change in weekly paid work hours"
	la var howlng "3. Change in weekly housework hours"
	la var scghq1 "4. Change in depression level"
	la var timechcare  "5. Change in weekly childcare hours"
*/	
		foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'_race, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-2.4(0.4)-0.2))   ylab(-2.4(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
    foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'nonkwk_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'nonkwk_race, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-2.4(0.4)-0.2))   ylab(-2.4(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'_race, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-20(4)2)) ylab(-20(4)2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'nonkwk_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'nonkwk_race, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-20(4)2)) ylab(-20(4)2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	
	  grc1leg2  lnnetpay_race hours_race  lnnetpaynonkwk_race hoursnonkwk_race,  ///
		xcommon xtob xtitlefrom(lnnetpaynonkwk_race)  ///
		graphregion(color(white))  legendfrom(lnnetpay_race)  labsize(small)
		gr export "$Output/m2_race1.png", replace
		

	foreach var in  scghq1 {
	#delimit ; 
		coefplot 
		(`var'_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'_race, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		yline(0,lc(black) lw(.1)) coeflabels() 
		graphregion(color(white)) bgcolor(white) aspectratio(1)
		title("`: var label `var''" "(reference period: 2017/2019)",size(medim) ) vertical ;
	#delimit cr 	
	}

	foreach var in  howlng /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'_race, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(4.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		 coeflabels() 
		graphregion(color(white)) bgcolor(white) aspectratio(1)
		title("`: var label `var''" "(reference period: 2017/2019)",size(medim) ) vertical ;
	#delimit cr 	
	}

		grc1leg2  scghq1_race howlng_race,  ///
		xcommon ///
		graphregion(color(white))  legendfrom(scghq1_race)  labsize(small)
		gr export "$Output/m2_race2.png", replace
		
		
*----------------3. degree interaction - mw4------------------------
foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'_degree, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-2(0.4)-0.2))   ylab(-2(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
    foreach var in lnnetpay {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'nonkwk_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'nonkwk_degree, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-2(0.4)-0.2))   ylab(-2(0.4)-0.2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''")
		title( "Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'_degree, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-20(4)2)) ylab(-20(4)2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Full sample",size(medim) ) vertical ;
	#delimit cr 	
	}
	
	foreach var in hours {
	#delimit ; 
		coefplot 
		(`var'nonkwk_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'nonkwk_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'nonkwk_degree, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		ysc(r(-20(4)2)) ylab(-20(4)2)
		xlabel(, labsize(small) /*notick*/ angle(30))
		/*yline(0,lc(black) lw(.1))*/ coeflabels() 
		graphregion(color(white)) bgcolor(white)
		ytitle("`: var label `var''") 
		xtitle("(reference period: Jan/Feb 2020)") 
		title("Non-keyworkers",size(medim) ) vertical ;
	#delimit cr 	
	}
	

	grc1leg2   lnnetpay_degree hours_degree   lnnetpaynonkwk_degree hoursnonkwk_degree,  ///
		xcommon xtob xtitlefrom(lnnetpaynonkwk_degree)  ///
		graphregion(color(white))  legendfrom(lnnetpay_degree)  labsize(small)
		gr export "$Output/m3_degree1.png", replace
		

	foreach var in scghq1 /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'_degree, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(5.8) xline(6.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		 coeflabels() 
		graphregion(color(white)) bgcolor(white) aspectratio(1)
		title("`: var label `var''" "(reference period: 2017/2019)",size(medim) ) vertical ;
	#delimit cr 	
	}

	foreach var in  howlng /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'_degree, replace)
		keep(*.covidwave) drop(*#*)
		mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(4.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		 coeflabels() 
		graphregion(color(white)) bgcolor(white) aspectratio(1)
		title("`: var label `var''" "(reference period: 2017/2019)",size(medim) ) vertical ;
	#delimit cr 	
	}

		grc1leg2 scghq1_degree howlng_degree,  ///
		xcommon ///
		graphregion(color(white))  legendfrom(howlng_degree)  labsize(small)
		gr export "$Output/m3_degree2.png", replace
		
		
*-----------------------4. Childcare only - 
	foreach var in timechcare /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nonmale,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Women"))
		(`var'_nonfemale,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Men")),
		name (`var'_female, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(3.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		yline(0,lc(black) lw(.1)) coeflabels() 
		graphregion(color(white)) bgcolor(white)
		vertical ;
	#delimit cr 	
	}

	foreach var in timechcare /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nonwhites,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("BAME"))
		(`var'_nonraceminor,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Whites")),
		name (`var'_race, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(3.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		yline(0,lc(black) lw(.1)) coeflabels() 
		graphregion(color(white)) bgcolor(white)
		vertical ;
	#delimit cr 	
	}

	foreach var in timechcare /*changing reference period and xline*/ {
	#delimit ; 
		coefplot 
		(`var'_nondegree,
		mlc(black) ms(T) mlw(.3) mc(white) 
		offset(-0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Non-degree"))
		(`var'_nonnondegree,
		mlc(black) ms(S) mlw(.3) mc(black) 
		offset(0.1) ciopts(lc(black) recast(rcap)) 
		lc(red)label("Degree")),
		name (`var'_degree, replace)
		keep(*.covidwave) drop(*#*)
		/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
		ytitle(" ", height(6)) xline(0.8) xline(3.8)
		xlabel(, labsize(small) /*notick*/ angle(30))
		yline(0,lc(black) lw(.1)) coeflabels() 
		graphregion(color(white)) bgcolor(white)
		 vertical ;
	#delimit cr 	
	}

		graph combine timechcare_female timechcare_race timechcare_degree,  ///
		xcommon title("Change in weekly childcare hours" "(reference period: Apr 2020, 1st lockdown)",size(medim) ) ///
		graphregion(color(white))  
		gr export "$Output/m4_timeccare.png", replace
	 
 