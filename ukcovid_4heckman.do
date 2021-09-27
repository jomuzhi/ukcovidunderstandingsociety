 clear
 set more off 
 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close 

use "$WorkData/3covid_long_mergedwith3pooled.dta", clear
 drop if waveall<19 //BHPS sample not related
 xtset pidp waveall
 sum x_birthy
 la var age "age"
 
 gen agesq=age*age

 gen age2020=2020-x_birthy
 la var age2020 "age in 2020"
 
 ta covidwave if age2020>19&age2020<66
 recode x_race 1/3=1, gen(raceminor)
 ta raceminor, m
 la var raceminor "BAME"
 la def raceminor 0 "Whites" 1 "BAME"
 la val raceminor raceminor
 ta covidwave raceminor, row nof	

 tabulate covidtest, gen(covidtest)
 la var covidtest1 "Not tested"
 la var covidtest2 "Positive"
 la var covidtest3 "Negative"
 la var covidtest4 "Pending"
 

 *6. Variables used in Selection Equation:
 
 global xheck "female working raceminor age agesq x_couple chageminc lhh_fihhmnnet1_dv15 tenure2 tenure3 tenure4 edu2 edu3 region2 region3 region4 region5 region6 region7"
*===============================================================  
	*-----------Heckman Variables and Lambda Ratio--------------------
 *Make working, jbft, earnings consistent from wave 28 and in covid survey
	*codebook jbft jbft_dv  new_jbft
	drop jbft_dv 
	replace jbft=new_jbft if jbft==.
	drop new_jbft 
	
  replace nchild=. if nchild<0
  *ta nchild,m
  replace nchild=x_nchild if nchild==.
  *ta waveall nchild,m //some in covidwave 0 ONLY, incomplete later covid surveys
  
  order pidp waveall covidwave nchild chageminc x_chageminc chagemin
  
  replace chageminc=x_chageminc if chageminc==.
  replace chageminc=0 if chageminc==.&chagemin<5
  replace chageminc=1 if chageminc==.&chagemin>4&chagemin~=.
  
  gen chageminc_all=0 if nchild==0
  replace chageminc_all=1 if chageminc==0
  replace chageminc_all=2 if chageminc==1
  la def chageminc_all 0 "Non-parent" 1 "youngest child<5yr" 2 "youngest child5-15"
  la val chageminc_all chageminc_all
  tabulate chageminc_all, gen(chageminc)
  *ta waveall chageminc_all,m //only some in covidwave0 missing
  
  recode nchild 0=0 1=1 2=2 3/10=3, gen(nchildc)
  tabulate nchildc, gen(nchild4c)
  *ta waveall nchildc,m
 
  *ta waveall x_race,m
  tabulate x_race, gen(race)
  
 *Before wave 29 variables, for heckman ONLY:
  *order pidp waveall covidwave hh_tenure_dv
  recode hh_tenure_dv -9=. 3/4=3 5/8=4, gen(housetenure)
  la def housetenure 1 "owned outright" 2 "owned mortgage" 3 "rented public" 4 "rent private"
  ta hh_tenure_dv housetenure
  la val housetenure housetenure  
  tabulate housetenure, gen(tenure)
  
  tabulate edu3c, gen(edu)
  *ta waveall edu3c,m
  
  recode new_hlstat 4/5=4
  *ta waveall new_hlstat,m
  tabulate new_hlstat, gen(sfhealth)
  
 *COVID ONLY - not in covidwave0
  *ta waveall furlough,m
  bysort pidp: replace furlough=furlough[_n+1] if covidwave==0
  tabulate furlough, gen(furloughc)
  
  *ta waveall xkeyworker,m  
  *ta xkeyworker working if wave>28,m
  replace xkeyworker=3 if xkeyworker==.&working==0 //not working
  tabulate xkeyworker, gen(xkeyworkerc)
  la var xkeyworkerc1 "Not keyworker"
  la var xkeyworkerc2 "Keyworker"
  la var xkeyworkerc3 "Not working"
  
 *Income/Earnings:
  order pidp waveall covidwave netpay15_month netpay15_month_pre
  *table waveall, c(min netpay15_month min netpay15_month_pre)
  replace netpay15_month_pre=0 if netpay15_month_pre<0
  *table waveall, c(mean netpay15_month mean netpay15_month_pre)
  replace netpay15_month=0 if netpay15_month<0
  
  replace netpay15_month=. if netpay15_month<0.5&working==0|netpay15_month==.&working==0 

  replace netpay15_month=0.5 if netpay15_month<0.5
  replace netpay15_month_pre=0.5 if netpay15_month_pre<0.5
  
  count if netpay15_month==.&working==1&covidwave~=.
  di 6597/105828
  
  gen lnnetpay=ln(netpay15_month)
  la var lnnetpay "Log net monthly earnings (workers)"
  
  gen lnnetpay_pre=ln(netpay15_month_pre)
  la var lnnetpay_pre "covidsample:Log net monthly earnings from latest main survey"
  
  
  la var x_ukborn "Born in the UK"  
  la var chageminc1 "Child age<5 (ref: No child)"
  la var chageminc2 "Child age5-15"
  la var chageminc3 "Non-parent"
  la var working "Has a job"
 
  la var nchild4c1 "No child"
  la var nchild4c2 "One child (ref: No child)"
  la var nchild4c3 "Two children"
  la var nchild4c4 ">=Three children"
  
  la var tenure2 "Owned mortgage (ref: Owned outright)"
  la var tenure3 "Rent-public"
  la var tenure4 "Rent-private"
  la var edu2 "Higher second.(Ref: GCSE)"
  la var edu3 "University or above"
  la var sfhealth2 "Good health (ref: Excellent)"
  la var sfhealth3 "Fair health"
  la var sfhealth4 "Poor health"
  *ta waveall chronic,m
  la var chronic "Chronic disease"
  *ta waveall x_couple,m
  la var x_couple "Couple"
  *table waveall, c(mean hours mean workhrall)
  la var workhrall "Weekly paid work hours"
  
	rename sex female
    la var female "Women"
    la var race2 "Asian (ref: White)"
    la var race3 "Black"
    la var race4 "Others"
   * la var age "Age"     
    la var furlough "Furloughed"
    la var xkeyworker "Keyworker"
     
  
  count if sf12pcs_dv==.
  *ta proxy //10%
  count if sf12mcs_dv==.
  //lots are proxy and inapplicable cases  
  
  recode gor_dv -9/-1=. 7=0 1/2=1 3=2 4/5=3 6=4 8/9=5 10/13=6, gen(region)
  la def govregion 0 "London" 1 "North" 2 "Yorkshire & Humber" ///
           3 "Midlands" 4 "East" 5 "South" 6 "Wales/Scot/NI"
  la val region  govregion
  *ta region,m
  gsort pidp -waveall
  bysort pidp: replace region=region[_n-1] if region==.
  sort pidp waveall
    
  tabulate region, gen(region)
  la var region1 "London"
  la var region2 "North (ref: London)"
  la var region3 "Yorkshire & Humber"
  la var region4 "Midlands"
  la var region5 "East"
  la var region6 "South"
  la var region7 "Wales/Scot/NI"  

*===============================================================     
     sort pidp waveall
     order pidp wave hh_hidp
     gsort pidp -waveall
     bysort pidp: replace hh_hidp=hh_hidp[_n-1] if hh_hidp==.
     sort pidp wave
   
    gsort pidp -waveall
    foreach v in $xheck {
    bysort pidp: replace `v'=`v'[_n-1] if `v'==.
    }
    **
    sort pidp waveall
    foreach v in $xheck {
    bysort pidp: replace `v'=`v'[_n-1] if `v'==.
    }
    **
	
		
	order pidp covidwave working netpay15_month hours howlng timechcare scghq1
	foreach v in netpay15_month hours howlng timechcare scghq1 {
		replace `v'=. if `v'<0
	}
	
	capture drop lnnetpay
	gen lnnetpay=ln(netpay15_month+0.5)
	la var lnnetpay "log netpay15_month"
	
 *Pool weight from 1st covid wave:
	bysort pidp: replace betaindin_xw=betaindin_xw[_n-1] if betaindin_xw==.
	count if betaindin_xw==.
     
save "$WorkData/4covid_long_heckman.dta", replace
