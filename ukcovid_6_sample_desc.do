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
	
	global weight "betaindin_xw_w0"
	
*-----------------------Merge with heckman to match invmills ratio------------*
	use "$WorkData/4covid_long_heckman.dta", clear
	
	capture drop age2020
	 gen age2020=2020-x_birthy
     la var age2020 "age in 2020"
 
	 ta covidwave if age2020>19&age2020<66
	sum age2020 //20 to 65
	xtset pidp covidwave
	order pidp covidwave waveall betaindin_xw
	
	*ta x_nchild

	bysort pidp: egen max_nchild=max(x_nchild)
	recode max_nchild 0=0 1/5=1, gen(x_parent)
	la def parent 0 "Non-parent" 1 "Parent"
	la val x_parent parent
	*xttab x_parent
	*ta x_nchild x_parent
	la var parent "Child<=15yrs"
	
	*ta edu3c
	recode edu3c 1/2=0 3=1, gen(degree)
	la def degree 0 "No degree" 1 "Has 1st degree"
	la val degree degree
	*xttab degree
	la def covidwave 0 "Jan/Feb-20" 1 "Apr-20" 2 "May-20" ///
	3 "Jun-20" 4 "Jul-20" 5 "Sep-20" 6 "Nov-20" 7 "Jan-21" 8 "Mar-21"
	la val covidwave covidwave
	
	tabulate covidwave, gen(ccovidwave)
	la var ccovidwave1 "Jan/Feb-20"
	la var ccovidwave2 "Apr-20" 
	la var ccovidwave3 "May-20"
	la var ccovidwave4 "Jun-20"
	la var ccovidwave5 "Jul-20"
	la var ccovidwave6 "Sep-20"
	la var ccovidwave7 "Nov-20"
	la var ccovidwave8 "Jan-21"
	la var ccovidwave9 "Mar-21"
	
	rename week_newdeaths28daysbydeathdate week_newdeaths28days
	rename week_newcasesbypublishdate week_newcases
	rename week_newtestsbypublishdate week_newtests
	
	foreach var in newadmissions newcasesbypublishdate newdeaths28daysbydeathdate  newtestsbypublishdate ///
	 week_newadmissions week_newcases week_newdeaths28days week_newtests {
	    gen `var'_k=`var'/1000 //no record in the reference group
		gen `var'_k2=`var'_k*`var'_k
	}
	
	
*---------------------Fixed-effect models COVID sample-----------------------*
	ta covidwave raceminor, row nof	
	ta covidwave if age2020>19&age2020<66
	*keep if covid_resp==1 //covid sample only	
	keep if age2020>19&age2020<66	
	ta covidwave
	drop if couple==.|parent==.
	*drop if female==.|degree==.|raceminor==.
    foreach v in $x {
		drop if `v'==.
	}
	
	ta covidwave
		
	*Select those who are workers in 1st wave:
	 gen xworker=working
	 bysort pidp: replace xworker=xworker[_n-1] if xworker~=xworker[_n-1]&xworker~=.&xworker[_n-1]~=.
	 la var xworker "Worker in covid wave0"
	 *xttab xworker
	 order pidp-working xworker lnnetpay
	 ta covidwave xworker
	 sum lnnetpay if xworker==1
	 replace lnnetpay=ln(0.5) if xworker==1&working==0 //assign zero income to those who used to work but did not work now
	 foreach v in hours netpay15_month {
	 replace `v'=0 if xworker==1&working==0
	 }
	 
	* ta covidwave if xworker==1&lnnetpay==.
	* ta covidwave if xworker==1&hours==.
	 ta covidwave if xworker==1&lnnetpay~=.
	 ta covidwave if xworker==1&hours~=.
	 
	 ta covidwave if scghq1~=.
	 ta covidwave if howlng~=.
	 ta covidwave if x_parent==1
	 ta covidwave if parent==1
	 ta covidwave if nchild>0&nchild~=.
	 count if timechcare>0&timechcare~=.&nchild==0|timechcare>0&timechcare~=.&nchild==.
	 ta covidwave if timechcare~=.
	 
	*xtdes //stayed at least wave0 and wave1 as long as answered first covid wave - which asked two records
	*ta covidwave,m
	
	*new parent and couple info needed to calculate change in howlng
	order pidp covidwave x_couple couple x_couple_pre x_parent parent x_nchild_pre
	
	gen howlngcouple=couple
	replace howlngcouple=x_couple_pre if covidwave==0
	order pidp covidwave x_couple couple x_couple_pre howlngcouple
	
	capture drop howlngparent
	gen howlngparent=parent
	replace howlngparent=[x_nchild_pre>0&x_nchild_pre~=.] if covidwave==0
	order pidp covidwave x_parent nchild parent x_nchild_pre howlngparent
	
	order pidp covidwave age age2020 howlngage
	replace howlngage=age if covidwave>0
	gen howlngagesq=howlngage*howlngage
	 
	*Select those who are keyworkers in covid:
	 *xttab xkeyworker
	 recode xkeyworker 2/3=0
	 
	*Select those who are ever parents in covid waves:
	 *xttab x_parent
	 rename x_parent xparent
	 
*Cross sectional weight for descriptive report; longitudinal weight for regression	 
	 order pidp covidwave betaindin*
     sort pidp covidwave
	 bysort pidp: egen covidwavemax=max(covidwave)
	 
	 gen betaindin_lw_last=betaindin_lw if covidwave==covidwavemax
	 order pidp covidwave covidwavemax betaindin_lw_last
	 gsort pidp -covidwave
	  bysort pidp: replace betaindin_lw_last=betaindin_lw_last[_n-1] if betaindin_lw_last==.
	  sort pidp covidwave
	 
	 gen noweight=1
	 
	 bysort pidp: replace betaindin_xw_w0=betaindin_xw_w0[_n-1] if betaindin_xw_w0==.
	 count if betaindin_xw_w0==.
	 
	*Non missing sample:
	 ta xkeyworker,m
	 ta covidtest,m
	 drop if covidtest==.
			
 save "$WorkData/5covid_long.dta", replace
	
*--------------------Sample descriptive statistics-----------------------*

use "$WorkData/5covid_long.dta", clear

	*table covidwave, c(mean netpay15_month mean hours mean howlng mean timechcare mean scghq1)	
	tabstat female xparent raceminor degree xworker couple age2020 ///
	if covidwave==0 [aw= $weight ], ///
	stat (mean sd median min max n)
		
	tabstat female xparent raceminor degree xworker couple age2020 ///
	if covidwave==0 , ///
	stat (mean sd median min max n)
	
	ta covidwave raceminor, row nof
	ta covidwave raceminor [aw= $weight ], row nof
	
	table parent, c(min timechcare max timechcare)
	count if  timechcare~=. &parent==0
	replace timechcare=. if parent==0
	
	tabstat $y week_newcases week_deathrate [aw=betaindin_xw_w0], by(covidwave) stat (mean /*sd median min max n*/)
	//for FE models, weight needs to be the same across individuals
	ta covidwave
	

	

    

	
	