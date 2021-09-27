	
#delimit ; 
	coefplot pay_m0, 
	name (m0_1, replace)
	keep(*.covidwave) 
	mlw(.3) msiz(vsmall)
	ytitle(" ", height(6)) xline(6.8) xline(0.8) xline(5.8)
	/*xlabel(0.7 "1st lockdown")*/
	ysc(r(-0.9(0.3)0.1)) ylab(-0.9(0.3)0.1)
	xlabel(, labsize(small) /*notick*/ angle(30))
    yline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("1. Change in ln net earnings" "(reference period: Jan/Feb 2020)",size(medim)) vertical ;
	#delimit cr 	
	*gr export "$Output/1_earnings.png", replace	

	 
	#delimit ; 
	coefplot hours_m0, 
	name (m0_2, replace)
	keep(*.covidwave) 
	mlw(.3) msiz(vsmall)
	ytitle(" ", height(6)) xline(6.8) xline(0.8) xline(5.8)
	ysc(r(-13(2)1)) ylab(-13(2)1)
	xlabel(, labsize(small) /*notick*/ angle(30))
    yline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("2. Change in weekly paid work hours" "(reference period: Jan/Feb 2020)",size(medim)) vertical ;
	#delimit cr 	
	*gr export "$Output/2_workhrs.png", replace
	
	
	#delimit ; 
	coefplot swb_m0, 
	name (m0_3, replace)
	keep(*.covidwave) 
	mlw(.3) msiz(vsmall)
	ytitle(" ", height(6)) xline(6.8) xline(0.8) xline(5.8)
	ysc(r(-0.1(0.4)2)) ylab(-0.1(0.4)2)
	xlabel(, labsize(small) /*notick*/ angle(30))
    yline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("3. Change in distress level" "(reference period: 2017/19)",size(medim)) vertical ;
	#delimit cr 	
	*gr export "$Output/3_depress.png", replace	
	
		
    #delimit ; 
	coefplot howlng_m0, 
	name (m0_4, replace)
	keep(*.covidwave) 
	/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
	ytitle(" ", height(6)) xline(0.8) xline(4.8)
	ysc(r(-1(1)4)) ylab(-1(1)4)
	xlabel(, labsize(small) /*notick*/ angle(30))
    yline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("4. Change in weekly housework hours" "(reference period: 2017/19))",size(medim) ) vertical ;
	#delimit cr 	
	*gr export "$Output/4_housework.png", replace

	
	*Childcare - only within lockdown
	
	#delimit ; 
	coefplot ccare_m0, 
	name (m0_5ccare, replace)
	keep(*.covidwave) 
	ytitle(" ", height(6)) xline(0.8) xline(3.8)
	ysc(r(-7(1)1)) ylab(-7(1)1)
    yline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("Change in weekly childcare hours" "(reference period: Apr-2020, 1st lockdown)",size(medim)) vertical ;
	#delimit cr 	
	gr export "$Output/m0_5childcare.png", replace
	
	
*Impact of COVID-19 test

#delimit ; 
	coefplot pay_m0, 
	name (m0_1t, replace)
	keep(covidtest2 covidtest3 covidtest4) 
	mlw(.3) msiz(vsmall)
	xsc(r(-0.9(0.3)0.6)) xlab(-0.9(0.3)0.6)
	ylabel(, labsize(small) /*notick*/ angle(30))
    xline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("1. Change in ln net earnings",size(medim)) ;
	#delimit cr 	
	*gr export "$Output/1_earnings.png", replace	

	 
	#delimit ; 
	coefplot hours_m0, 
	name (m0_2t, replace)
	keep(covidtest2 covidtest3 covidtest4) 
	mlw(.3) msiz(vsmall)
	xsc(r(-10(2)2)) xlab(-10(2)2)
	ylabel(, labsize(small) /*notick*/ angle(30))
    xline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("2. Change in weekly paid work hours",size(medim))  ;
	#delimit cr 	
	*gr export "$Output/2_workhrs.png", replace
	
	
	#delimit ; 
	coefplot swb_m0, 
	name (m0_3t, replace)
	keep(covidtest2 covidtest3 covidtest4) 
	mlw(.3) msiz(vsmall)
	xsc(r(-0.1(0.4)2)) xlab(-0.1(0.4)2)
	xlabel(, labsize(small) /*notick*/ angle(30))
    xline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("3. Change in distress level",size(medim)) ;
	#delimit cr 	
	*gr export "$Output/3_depress.png", replace	
	
		
    #delimit ; 
	coefplot howlng_m0, 
	name (m0_4t, replace)
	keep(covidtest2 covidtest3 covidtest4) 
	/*mlc(red) ms(T) mc(white) */ mlw(.3) msiz(small)
	xsc(r(-3(1)2)) xlab(-3(1)2)
	ylabel(, labsize(small) /*notick*/ angle(30))
    xline(0,lc(black) lw(.1)) coeflabels() 
	graphregion(color(white)) bgcolor(white)
	title("4. Change in weekly housework hours",size(medim) ) ;
	#delimit cr 	
	*gr export "$Output/4_housework.png", replace