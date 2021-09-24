*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*

*Data Exploration - Understandinbg Society Covid: a,b,c,d,e, xbaseline, xsample

*Web and telephone survey, around 50% response rate

*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*
 clear
 set more off 
 
 do "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\do/ukcovid_00dir.do"
 capture log close 
 *log using "$Output\log_ukcovid0", replace //log file
 
 use "$RawCovid/xsample",clear 
 //This one is the sampling framework, including all sample members from main wave 9 
 //who were invited to the study in April 2020, will be updated per month
 count 
 
 foreach i in a b c d e f {
 ta c`i'_outcome,m 
 gen x_c`i'outcome=[c`i'_outcome==11|c`i'_outcome==12]
 replace x_c`i'outcome=1 if c`i'_outcome==31 //deceased, unable to send the request
 }
 **
 capture drop new_incovid
 gen x_incovid=0
  foreach i in a b c d e f{
 replace x_incovid=1 if x_c`i'outcome==1
 la var x_incovid "Fully or partly completed COVID survey in any wave"
  }
  **
 
 order pidp i_ioutcome j_ioutcome k_ioutcome x_c*outcome
 
 //from b,c,d,e,f
 gen x_blwork=.
 foreach i in b c d e f{
 replace x_blwork=c`i'_ff_blwork if c`i'_ff_blwork>0&c`i'_ff_blwork~=.
 la val x_blwork cb_ff_blwork
 la var x_blwork "Baseline: worked in Jan Feb 2020"
 }
 **
 
 gen x_hcond=.
 foreach i in b c d e f {
 replace x_hcond=c`i'_ff_hcondhas if c`i'_ff_hcondhas>0&c`i'_ff_hcondhas~=.
 //fed forward values
 la val x_hcond cb_ff_hcondhas
 la var x_hcond "Has long term health condition"
 }
 *
 //some are pregnant!
 
 keep pidp-preletter sex_dv  birthy  racel_dv bornuk_dv x_* psu strata *hidp
 drop emailknown mobknown 
 
*Sex and Birth Year
     recode sex_dv -9/0=. 1=0 2=1, gen(sex)
     la def sex 0 "Men" 1 "Women"
     la val sex sex
	 ta sex_dv sex,m
	 drop sex_dv
	 
	 replace birthy=. if birthy<0

 rename x_caoutcome xoutcome1
 rename x_cboutcome xoutcome2
 rename x_ccoutcome xoutcome3
 rename x_cdoutcome xoutcome4
 rename x_ceoutcome xoutcome5
 rename x_cfoutcome xoutcome6

 rename preletter x_preletter
 rename (i_ioutcome j_ioutcome k_ioutcome) ///
		(xi_ioutcome xj_ioutcome xk_ioutcome)
 
   order pidp xi_ioutcome xj_ioutcome xk_ioutcome ///
    psu strata sex birthy racel_dv bornuk_dv ///
    x_incovid x_blwork x_hcond
	
   count //44067 individuals
 
   rename *_dv *
  save "$WorkData/0covidxsample.dta", replace   
 
  
*==========================================================*

*Baseline Sample - Wave 0
*no semp info

*==========================================================* 
 use "$RawCovid/xbaseline",clear //20468 individuals
 count //number of ppl who ever completed or partly completed covid survey
 ta hcond_cv96_dv hcond_cv1_dv 
 keep pidp nhsshield_dv hcond_cv96_dv ///
    blwork_dv blhours_dv blpayhow_dv blpay_amount_dv blpay_period_dv blnonwork_dv ///
    bl_betaindin_xw blhhearn_amount_dv blhhearn_period_dv blwah_dv blhrshow_dv ///
	blbenefitsb656_dv ///
	firstinterview bl_outcome bl_betaindin_xw
    
 rename hcond_cv96_dv hcondnew_cv96
 
 codebook blbenefitsb656_dv
 rename blbenefitsb656_dv blbenefits6
 
 rename *_dv *
 rename bl* *
 rename _* *
 rename benefits6 blbenefits6
 
 gen covidwave=0
 count
 rename pay* netpay*
 
 rename betaindin_xw betaindin_xw_w0
 
 save "$WorkData/1covid_w0.dta", replace 
 
