 clear
 set more off 
 
 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close
 
 
//For all waves, no longer need: interview outcome, some from xsample
global wavelast "7" //change this when new wave is in
*1. Identify variables to be selected:
*global baseline "blwah blhrshow"
/*foreach v in blwork blhours blpay_amount blpayhow blpay_period ///
 blhhearn_amount blhhearn_period*/ /*already in baseline xsample*/

global basevar "pidp age couple hhcomp* clinvuln_dv hadsymp pregnow scghq1_dv surveystart surveyend racel_dv" /*tested testresult* */
/*furlough keyworker*/
global timevar "howlng timechcare " //missing in some waves
global economic "hours wah netpay_amount netpay_period hhearn_amount hhearn_period sempderived"
global benefit "blbenefits6 ucredit foodbank" //missing in some waves
global covid "testresult* tested"

*--------------Covid Wave 1----------------------*
 use "$RawCovid/ca_indresp_w",clear //April
     //_w: web result first
     //all ca_ prefix, indicating 1st month result
     rename ca_* *  
     rename *_cv *
 
     keep $basevar $timevar $economic $benefit child1  child2 ///
     furlough keyworker ///
     $baseline ///
	 $covid ///
	 betaindin_xw betaindin_xw_t
     
     gen covidwave=1    
	 order pidp covidwave
     ta sempderived  furlough,m //mostly self-employed and not working ppl and some retired?
save "$WorkData/1covid_w1.dta", replace   


use "$RawCovid/cb_indresp_w",clear //May
     rename cb_* * 
     rename *_cv *
     ta sempderived ,m //no missing
     
     keep $basevar $timevar $economic $benefit ///
     furlough keyworksector hhnum hcondnew_cv96 ///
     $baseline ///
	  $covid ///
	 betaindin*
   
     gen covidwave=2    
save "$WorkData/1covid_w2.dta", replace 


use "$RawCovid/cc_indresp_w",clear //no benefit info asked
     rename cc_* *  
     rename *_cv *
     ta sempderived ,m //no missing
     
     keep $basevar $timevar $economic  ///
     furlough keyworksector hhnum hcondnew_cv96 ///
     $baseline ///
	  $covid ///
	 betaindin*
   
     gen covidwave=3    
save "$WorkData/1covid_w3.dta", replace 


use "$RawCovid/cd_indresp_w",clear //no time use info asked, July
     rename cd_* *  
     rename *_cv *
     *codebook furlough
     ta sempderived ,m //no missing
     rename blbenefitsb656 blbenefits6 //baseline benefits - i make them unchanged throughout
     rename ucreditb65 ucredit  
     
    keep $basevar $economic $benefit ///
     furlough keyworksector hhnum hcondnew_cv96 blfoodbank ///
     $baseline aidhh ///
	  $covid ///
	 betaindin*
     
     gen covidwave=4  
save "$WorkData/1covid_w4.dta", replace 


use "$RawCovid/ce_indresp_w",clear //September
     rename ce_* *  
     rename *_cv *
     ta sempderived ,m //no missing 
     codebook stillfurl
     recode stillfurl -9=. -7/-1=. 1/2=1 3/5=0, gen(furlough)
     drop stillfurl
     
    keep $basevar $timevar $economic  ///
     furlough keyworksector hhnum hcondnew_cv96 blfoodbank ///
     $baseline ///
	  $covid ///
	 betaindin*
     
     gen covidwave=5
     
save "$WorkData/1covid_w5.dta", replace 


use "$RawCovid/cf_indresp_w",clear //Interviewed end of November
//The lockdown in England is set to begin on Thursday 5 November, and it will last until Wednesday 2 December 2020. 
     rename cf_* *  
     rename *_cv *
     ta sempderived ,m //no missing 
     codebook stillfurl
	 ta stillfurl,m
     recode stillfurl -9=. -7/-1=. 1/2=1 3/6=0, gen(furlough)
     drop stillfurl
	 
	 ta testresult
     
    keep $basevar hours $economic  ///
	 $covid ///
     furlough hhnum hcondnew_cv96  aidhh betaindin* 
     gen covidwave=6
     
save "$WorkData/1covid_w6.dta", replace 

use "$RawCovid/cg_indresp_w",clear //Interviewed end of January
//3rd UK lockdown It officially began on January 6
     rename cg_* *  
     rename *_cv *
     ta sempderived ,m //no missing 
     codebook newfurlough
	 ta newfurlough,m
     recode newfurlough -9=. -7/-1=. 1=1 2=0, gen(furlough)
     drop newfurlough
	 
	 forval i=1/3{
	 	ta testresult_test1,m
	 }
     
    keep $basevar hours $economic  $timevar ///
	 $covid ///
     furlough hhnum hcondnew_cv96  aidhh betaindin*
     gen covidwave=7
     
save "$WorkData/1covid_w7.dta", replace 

use "$RawCovid/ch_indresp_w",clear //Interviewed end of March
     rename ch_* *  
     rename *_cv *
	 /*
     ta sempderived ,m //no missing 
     codebook newfurlough
	 ta newfurlough,m
	 */
     recode newfurlough -9=. -7/-1=. 1=1 2=0, gen(furlough)
     drop newfurlough
	 
    keep $basevar hours $economic  ///
	 tested ntests testpos ntestpos ///
     furlough hhnum hcondnew_cv96  aidhh betaindin*
     gen covidwave=8
     
save "$WorkData/1covid_w8.dta", replace 


*---------------Append all waves------------------------*

	use "$WorkData/1covid_w0.dta", replace
	append using "$WorkData/1covid_w1.dta"
	append using "$WorkData/1covid_w2.dta"
	append using "$WorkData/1covid_w3.dta"
	append using "$WorkData/1covid_w4.dta"
	append using "$WorkData/1covid_w5.dta" 
	append using "$WorkData/1covid_w6.dta" 
	append using "$WorkData/1covid_w7.dta" 
	append using "$WorkData/1covid_w8.dta"
	order pidp covidwave
	sort pidp covidwave
	rename racel_dv covidracel

	merge n:1 pidp using  "$WorkData/0covidxsample.dta" //match with personal fixed info
	drop _merge
	replace work=x_blwork if x_blwork>0&x_blwork~=.&covidwave==0
	drop  x_blwork
	replace x_incovid=1 if work~=. //not always consistent, interesting
	order pidp covidwave xoutcome* x_incovid 
	
	gen xracel=racel
	replace xracel=covidracel if xracel==.
	la val xracel racel_dv
	drop racel covidracel
	
	  gen doiy=2020
	  capture drop doim
	  table covidwave, c(mean surveyend)
	  gen doim=4 if covidwave==1
	  replace doim=2 if covidwave==0
	  replace doim=5 if covidwave==2
	  replace doim=6 if covidwave==3
	  replace doim=7 if covidwave==4
	  replace doim=9 if covidwave==5
	  replace doim=11 if covidwave==6
	  replace doim=1 if covidwave==7
	  replace doim=3 if covidwave==8
	  replace doiy=2021 if covidwave>6&covidwave~=.
	  replace doiy=. if covidwave==.
	  ta x_preletter,m
	 sort pidp covidwave
	 order pidp covidwave doiy doim
	 
save "$WorkData/1covid_long.dta", replace 
 
