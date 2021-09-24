 clear
 set more off 
 
 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close
 
 
use "$WorkData/1covid_long.dta", clear //All sample from the last wave of UKHLS are in
//not only that, some pidp, like 22445, not in last three waves, also included

  sum age

  sort pidp covidwave 
  
  ta covidwave x_incovid,m 
  replace x_incovid=0 if covidwave==.
  
  
*================COVID Variable recode===================*
*Covid test and result:
	
	recode tested -9/-1=.
	ta covidwave tested, m
	ta covidwave testpos,m
	recode testpos -7/-1=.
	ta covidwave testresult if tested==1,m //wave 7 asked multiple test result
	order pidp covidwave tested testpos testresult*
	replace testresult=testresult_test1 if covidwave==7
	replace testpos=testresult if testpos<0|testpos==.
	ta covidwave testpos if tested==1,m
	capture drop covidtest
	gen covidtest=0 if tested==2
	replace covidtest=1 if testpos==1
	replace covidtest=2 if testpos==2
	replace covidtest=3 if testpos==3|testpos==4
	la def covidtest 0 "No test" 1 "Test positive" 2 "Test negative" 3 "Test result pending"
	la val covidtest covidtest
	ta covidwave covidtest, m
	ta covidwave covidtest, row
	drop tested testpos ntests testresult testresult* ntestpos
	ta covidwave covidtest,m
	replace covidtest=0 if covidwave==0 //no test in the reference group
	
  *Merge to include macro-level covid indicator
  *UK macro-level infection and death rate by date - date before the survey starting date
	order pidp covidwave surveystart surveyend
	gen surveydate=dofc(surveystart)
	order pidp covidwave surveydate
	format surveydate %td
	order pidp covidwave surveydate
	merge n:1 surveydate using "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid/COVID_overview_2021-08-07"
	order pidp covidwave surveystart surveyend surveydate new* _merge
	
	sort pidp covidwave
	drop if _merge==2
	drop _merge
	order pidp covidwave new*
	foreach var in newadmissions newcasesbypublishdate newdeaths28daysbydeathdate  newdeaths28daysbydeathdaterate newtestsbypublishdate ///
	week_deathrate week_newadmissions week_newcasesbypublishdate week_newdeaths28daysbydeathdate week_newtestsbypublishdate {
	    replace `var'=0 if covidwave==0 //no record in the reference group
	}
	**
	
	order pidp covidwave surveydate
	
 *Sex and Age
     count if age==.
	 sum birthy

     replace age=2020-birthy if age==.     
	 sum age
	 
	 ta covidwave if age>19&age<66
	 
 *On benefits[baseline]:
	capture drop benefit 
    gen benefit=0 if blbenefits6==1
	replace benefit=1 if blbenefits6==0 //on benefit
    replace benefit=. if blbenefits6==-8 //NA
    replace benefit=1 if ucredit==6
    replace benefit=1 if foodbank>1&foodbank~=.
    replace benefit=1 if blfoodbank>1&blfoodbank~=.
	replace benefit=. if covidwave==.
    ta benefit,m
    la var benefit ///
        "Baseline:on any benefit(Universal credit, working tax credit, child tax credit, jobseeker's allownace, foodbank)"
    order pidp covidwave benefit blbenefits6 ucredit foodbank blfoodbank
	rename benefit blbenefit
	
    drop   blbenefits6 ucredit foodbank blfoodbank   
    
	sort pidp covidwave
	by pidp: replace blbenefit=blbenefit[_n-1] if blbenefit==.
	gsort pidp -covidwave
	by pidp: replace blbenefit=blbenefit[_n-1] if blbenefit==.
	sort pidp covidwave
     
*Employment:     
     recode work -9/-1=. 4=0 1/3=1, gen(working)
     ta work working,m    
     la def working 0 "not working" 1 "working"
     la val working working
     
	 replace working=. if sempderived<0&covidwave>0&covidwave~=. 
	 replace working=1 if sempderived>0&sempderived<4
	 replace working=0 if sempderived==4
	 
     ta sempderived working,m     
	 drop work  nonwork  
	 
	 order pidp covidwave working sempderived keyworker keyworksector furlough
	 
	 bysort pidp: replace keyworker=keyworker[_n-1] if keyworker==.|keyworker<0
	 gsort pidp -covidwave
	 bysort pidp: replace keyworker=keyworker[_n-1] if keyworker==.|keyworker<0
	 sort pidp covidwave
	 rename keyworker xkeyworker
	 bysort pidp: replace keyworksector=keyworksector[_n-2] if keyworksector<0|keyworksector==.
	 gsort pidp -covidwave
	 bysort pidp: replace keyworksector=keyworksector[_n-2] if keyworksector<0|keyworksector==.
	 sort pidp covidwave
	 rename keyworksector xkeyworkersector
	 
	 ta xkeyworkersector xkeyworker ,m
	 //in keyworkersector may not be a keyworker!
	 ta xkeyworkersector working,m
	 //working, xkeyworkersector, and xkeyworker are not always consistent
    
   * codebook furlough
    capture drop furlough1
    recode furlough -9=. -8=3 -7/-1=. 0=0 1=1 2=0, gen(furlough1)
    replace furlough1=2 if sempderived==4
    la def furlough  0 "No but working" 1 "Yes-furloughed" 2 "Not working" 3 "Self-employed or NA"
    la val furlough1 furlough
    ta furlough1 sempderived,m
    drop furlough
    rename furlough1 furlough
 
 *Baseline health:    
	order pidp covidwave hcondnew_cv96 x_hcond 
	replace x_hcond =0 if hcondnew_cv96==1&x_hcond==.
    replace x_hcond =1 if hcondnew_cv96==0&x_hcond==.  //new disease diagnosed     
	bysort pidp: replace x_hcond=x_hcond[_n-1] if x_hcond==.|x_hcond~=x_hcond[_n-1]&x_hcond[_n-1]~=.
	la var hcondnew_cv96 "Wave:Health condition-none of the above"
     
 * Demographic - wave specific and time fixed:
	order pidp covidwave couple hhcomp*
    recode couple -9/-1=. 2=0 1=1
    la def couple 0 "Not couple" 1 "Couple"
    la val couple couple
    ta couple
    
    gen parent=[hhcompa>0&hhcompa~=.|hhcompb>0&hhcompb~=.] //check 68576647
    la var parent "child<=age15 in household"
	
    gen nchild=.
    replace nchild=hhcompa+hhcompb
    la var nchild "number of children<=age15"
    ta nchild parent,m
	replace nchild=. if nchild<0
    
    recode nchild 16=. 3/10=3, gen(nchildc)
    la def nchildc 0 "No child" ///
            1 "One" 2 "Two" 3 ">=Three"
    la val nchildc nchildc
    ta nchild nchildc
    ta nchildc parent
    
    gen chageminc=0 if hhcompa>0&hhcompa~=.
    replace chageminc=1 if chageminc==.&parent==1
    
    ta chageminc parent,m
    la def chageminc 0 "Children younger than 5" 1 "Children age 5-15"
    la val chageminc chageminc
    
    ta chageminc parent,m
    ta hhcompe //15% has aged 70+

    la var hhnum "Household size(not in covidwave1)"
	
	order pidp covidwave age couple parent nchild chagemin chageminc hhnum
	
	foreach v in couple parent nchild chageminc {
	    gen x_`v'=`v'
		la val x_`v' `v'
		bysort pidp: replace x_`v'=x_`v'[_n-1] if x_`v'==.
	}
	
	gsort pidp -covidwave
	foreach v in couple parent nchild chageminc {
		bysort pidp: replace x_`v'=x_`v'[_n-1] if x_`v'==.
	}
	
	sort pidp covidwave
	order pidp covidwave age couple x_couple parent x_parent ///
		nchild x_nchild chageminc x_chageminc
	
	ta covidwave x_nchild,m
    
 *Paid work and housework time, childcare time 
	order pidp covidwave hours howlng timechcare	
	foreach v in hours howlng timechcare{
    recode `v' -9=. -8=-8 -7/-1=. 97/200=97
    }
	**
	
    recode hours -8=3 0/28=2 28.1/97=1,gen(jbft)
    la def jbft 1 "FT:30hr+" 2 "PT<30hr" 3 "NotWorking"
    la val jbft jbft  
    
    replace jbft=3 if working==0
    ta jbft working,m
	
	order pidp covidwave working hours jbft
	
    replace working=0 if working==1&hours==-8
    replace working=0 if working==.&jbft==3
    la var jbft "full or parttime"
	la var hours " how many hours did you usually work per week?"
    la var howlng "Weekly housework hours(not in covidwave4&6)" 
    la var timechcare "Weekly childcare hours(not in covidwave4&6)"
    
 *Income - full income, labour income, and net income  
    /*fimngrs15 fimnlabgrs15 fimnnet15*/
    gen year=2020
	merge n:1 year using ///
	"E:\OneDrive - Nexus365\Academia\Literature\Area\UK\Income Inflation/UK1989_2020CPI" 
    keep if _merge==3
	drop _merge year 
    
*Individual Earnings:
//What is your usual take-home pay/earnings now? Take-home pay is after tax, National Insurance and pension contributions have been deducted. Please include all jobs and self-employment activities.
	order pidp covidwave netpay*

    recode netpayhow -9/-1=. 1=0 2/5=1, gen(fixpay)
    la def fixpay 0 "fixed salary" 1 "non-fixed"
    la val fixpay fixpay
    
    recode netpay_amount -9/-1=. , gen(netpay_month)
   
    replace netpay_month=netpay_month*4 if netpay_period ==1 |netpay_period ==5    
    replace netpay_month=netpay_month*2 if netpay_period ==2    
    replace netpay_month=netpay_month/12 if netpay_period ==4
	*table covidwave, c(min netpay_month max netpay_month mean netpay_month)
    *replace netpay_month=16000 if netpay_month>16000&netpay_month~=.
    
    gen netpay15_month=netpay_month*100/CPIH
    la var netpay15_month "Individual last month take-home pay/earnings adj2015"
    
  *Household Earnings:
  //Thinking about everyone who was living with you in January/February 2020, what was the usual total take-home pay/earnings of your household
  //Please only include earnings from paid work or self-employment, after tax, National Insurance and pension contributions have been deducted. If you are not sure, please tell us an approximate amount.
  
     
    *table covx_blhhearn_period, c(min covx_blhhearn_amount max covx_blhhearn_amount)
    recode hhearn_amount -9/-1=., gen(hhearn_month)
    
    replace hhearn_month=hhearn_month*4 if hhearn_period==1 |hhearn_period==5
    replace hhearn_month=hhearn_month*2 if hhearn_period==2
    replace hhearn_month=hhearn_month/12 if hhearn_period==4   
	*table covidwave, c(min hhearn_month max hhearn_month mean hhearn_month)
  
    gen hhearn15_month=hhearn_month*100/CPIH
	la var hhearn15_month  "monthly HOUSEHOLD pay/earnings[net]adj 2015"
        
    drop *_amount *_period netpayhow
 
 *Wellbeing
	order pidp covidwave scghq1_dv
	
	rename *_dv *
	order pidp covidwave xracel
    ta covidwave xracel, row nof
	
   
save "$WorkData/2covid_long.dta", replace

**
