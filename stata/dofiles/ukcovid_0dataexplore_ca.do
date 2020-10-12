*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*

*Data Exploration - Understandinbg Society Harmonized Covid

*Web and telephone survey, around 50% response rate

*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*
 clear
 set more off
 global onedrive "C:\Users\Muzhi\OneDrive - Nexus365\Academia\Data\UKHLS_do"
 
 global pc "C:\Users\Muzhi\OneDrive - Nexus365"
 
 global local "D:\Academia\Data"
 do "$onedrive/Stata_covid\do/ukcovid_00dir"
 capture log close 
 *log using "$Output\log_ukcovid0", replace //log file
 
 use "$RawCovid/xsample",clear 
 //all sample members who were invited to the study in April 2020, will be updated per month
 count 
 ta ca_ff_prevsurv,m
 ta ca_outcome,m 
 //16379 full interview, abt 50% will be sample
 
 use "$RawCovid/ca_indresp_w",clear
 //_w: web result first
 //all ca_ prefix, indicating 1st month result
 rename ca_* * 
 gen doim=4 
*=============Shared do file start=================*
  gen year=2019 //used for merge income CPI, latest is 2019  
  gen doiy=2020
  
 rename betaindin_xw xweightcovid
 sum age
  
     ta testresult,m
     ta blhrshow,m
     ta pregnow //122 are pregant, now
     //could check mental status linking previous ones who plan to have kids?
     ta caring //half are caring outside!
     ta help
     ta ucredit
     ta foodbank_cv     
     ta chcomputer_childa,m
     ta chcomputer_childa if chcomputer_childa>0
     //half own and half shared
     ta couple
     ta hadsymp
     ta hassymp
     
     ta sex
     ta sclonely_cv sex if sclonely_cv>0, col nof
     //female more likely to feel lonely? but they are more likely to have kids....
     ta blwork //532 NA
     
     count if blpay_amount<0
    count if blhhearn_amount<0
    count if hhearn_amount<0 //5745
     
   do "$docovid/ukcovid_1var_indi_a.do"
   table sex, c (mean swb1)
     
   replace i_hidp=k_hidp if i_hidp<0
   replace i_hidp=j_hidp if i_hidp<0
   count if i_hidp<0
   
   rename i_hidp hh_hidp
    drop j_hidp k_hidp
   keep hh_hidp pidp psu strata sex age couple* hhcomp* ///
   hadsymp hassymp tested testresult ///
   parent* nchild*  sempderived transfers ///
   gor_dv outcome-useragentstring finnow1 finfut1 ///
   doim doiy working0-atschnchild xweight *child*   
   
   drop CPIH lastq fimnlabgrs_dv0 fimnlabgrs_dv1 fihhmn_all0  fihhmn_all1
   *drop if sex==3
   *drop if hh_hidp<0
      
   save "$WorkData/covid_indresp_widea", replace
   
   table sex, c(mean swb1)
   
   
*=====================================

*Reshape to long format

*=====================================
   use "$WorkData/covid_indresp_widea", clear
   *Reshape:
   reshape long couple hhcompa hhcompb hhcompc hhcompd hhcompe working parent nchild nchildc chageminc hh_hhsize workhrall new_jbft wah howlng timeccare fimnlab fihhmn swb help keyworker furlough sclonely finnow finfut, i(pid) j(j)
   
    la var j "covid wave"
    la var help " Receiving care from outside the household"
    la val help ca_help
    la var sclonely "How often feels lonely"
    la val sclonely ca_sclonely_cv
    la var furlough "Furloughed under the Coronavirus Job Retention Scheme"
    la val furlough ca_furlough

    /*
    la var lacknutr "Healthy and nutritious food"
    la val lacknutr ca_lacknutr
    la var hungry "hungry but did not eat"
    la val hungry ca_hungry
    */
    la val working working
    la val keyworker keyworker
    la var new_jbft new_jbft
    la val furlough keyworker
   * la val help ca_help
    
    ta keyworker working if j==1,m //close to half
    
    rename xweightcovid xweight
    drop if sex==3
   
  save "$WorkData/covid_indresp_longa", replace
   
*====================

*Child info

*======================

 use "$RawCovid/ca_schild_w",clear
 count //4559 children
 keep newpidp_c pidp_c pidp_m pidp_f pidp_1pg ///
 ca_childno_1pg ///
 ca_childdob_y ca_childage *pg ///
 chsex ca_eduks-ca_betasch_xw
 
 rename ca_* * 
 
 recode pidp_m -9/-1=.
 recode pidp_f -9/-1=.
 
 recode childage -9/-1=.
 
preserve
 rename pidp_m pidp
 rename pidp_f parentother
 order pidp
 sort pidp
 drop if pidp==.
 save "$WorkData/covid_childmom", replace 
restore

preserve
 rename pidp_f pidp
 rename pidp_m parentother
 order pidp
 sort pidp
 drop if pidp==.
 save "$WorkData/covid_childdad", replace 
restore

use "$WorkData/covid_childmom", clear
    append using "$WorkData/covid_childdad"
    count //9118 parents
    sort pidp
    
    rename pidp_1pg pidp_guard
    rename *_1pg *
    drop aid_dv
    
    global child "newpidp_c parentother pidp_guard pidp_c childdob_y childage atschool schoolwork lessonsoff lessonson marking compreq chcomputer hstime hshelp tutoring1 tutoring2 tutoring3 freemeals meals chsex eduks eduph betasch_xw"
    
    foreach v in $child {
    	replace `v'=. if `v'<0
    }

*---reshape from long into wide----*
    sort pidp childno
    duplicates report pidp childno
    duplicates list pidp childno
    duplicates tag pidp childno, gen(dupchild)
    order dupchild
    bysort pidp: gen childnonew=_n
    order dupchild-childno childnonew
    drop childno
    rename childnonew childno
    drop dupchild
    
*Each pidp has multiple kids records behind if >1 kid
  reshape wide newpidp_c parentother pidp_guard pidp_c childdob_y childage atschool schoolwork lessonsoff lessonson marking compreq chcomputer hstime hshelp tutoring1 tutoring2 tutoring3 freemeals meals chsex eduks eduph betasch_xw, i(pidp) j(childno)
 
 forval i=1/7{
        recode atschool`i' 2/4=0, gen (atsch`i')    
 }
 
 save "$WorkData/covid_childtomerge", replace
 
 erase "$WorkData/covid_childmom.dta"
 erase "$WorkData/covid_childdad.dta"
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
