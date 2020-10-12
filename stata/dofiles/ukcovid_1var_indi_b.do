*New sample included, re-asking baseline info, ok
     recode sex 1=0 2=1
     la def sex 0 "Men" 1 "Women"
     la val sex sex
     
     recode blwork -9/-1=. 4=0 1/3=1, gen(working0)
     ta working0 sex, col
     la def working 0 "not working" 1 "working"
     la val working0 working
     
     gen working1=0 if hours==-9
     replace working1=1 if hours>-1&hours~=.
     replace working1=0 if sempderived==4
     replace working1=working0 if working1==.&sempderived==-8
     *order blwork-hours working*
     
     ta blwah working0 //working0 only for ppl not asked
     
     ta keyworksector working1,m //new variable
     
     *replace working1=. if keyworksector==-9|keyworksector==-1|keyworksector==-2
     *replace working1=0 if keyworksector==-8&working1==1
     ta furlough working1,m
     
 *Baseline benefits:
    recode blbenefits6 -9/-1=. , gen(notonbenefits0)
 
 *Baseline health:
    recode nhsshield -9/-1=. , gen(nhsshieldnew)
    
    recode hcond_cv96 -9/-1=. , gen(chronic0) 
    //1 - yes, chronic disease 
    codebook mhealthtyp_cv20 mhealthtypn_cv20
    recode mhealthtyp_cv20 -9/-1=., gen(mhealth0)
    recode mhealthtypn_cv20 -9/-1=., gen(mhealth1)

* Demographic:
    recode couple 2=0 1=1
    
    gen parent=[hhcompa>0|hhcompb>0]
    gen nchild=.
    replace nchild=hhcompa+hhcompb
    ta nchild parent,m
    
    recode nchild 3/10=3, gen(nchildc)
    la def nchildc 0 "No child" ///
            1 "One" 2 "Two" 3 ">=Three"
    la val nchildc nchildc
    ta nchild nchildc
    
    gen chageminc=0 if hhcompa>0
    replace chageminc=1 if chageminc==.&parent==1
    
    ta chageminc parent,m
    la def chageminc 0 "Children younger than 5" 1 "Children age 5-15"
    la val chageminc chageminc
    
    ta chageminc parent,m
    
    order pidp couple hhcomp* parent nchild
    
    rename (couple hhcomp* parent nchild nchildc chageminc hh_hhsize)(couple1 hhcomp*1 parent1 nchild1 nchildc1 chageminc1 hh_hhsize1)
    
*Paid work and housework time, childcare time 
    recode blhours -9=-9 -8/-1=. 97/200=97, ///
        gen(workhrall0)
        
    recode workhrall0 -9=3 0/29.9=2 30/97=1,gen(new_jbft0)
    la def new_jbft 1 "FT:30hr+" 2 "PT<30hr" 3 "NotWorking"
    la val new_jbft0 new_jbft  
    replace workhrall0=. if workhrall0<0
    
    replace new_jbft0=3 if working0==0
    ta new_jbft0 working0,m
        
    recode hours -9=-9 -8/-1=. 97/200=97, ///
        gen(workhrall1)        
    recode workhrall1 -9=3 0/29.9=2 30/97=1,gen(new_jbft1)
    la val new_jbft1 new_jbft
    replace new_jbft1=3 if working1==0
    ta new_jbft1 working1,m
    ta new_jbft1,m
    
    replace workhrall1=. if workhrall1<0
        
    ta blwah,m    
    recode blwah -9=. -8=3 -2/-1=. 1/2=2 4=0 3=1 , gen(wah0)
    la def wah 0 "Never" 1 "Sometimes" 2 "Often/Always" 3 "Not working"
    la val wah0 wah
    ta wah0 working0,m
    
    recode wah -9=. -8=3 -2/-1=. 1/2=2 4=0 3=1 , gen(wah1)
    la val wah1 wah
    ta wah1 working1,m
    ta wah wah1,m    
    
    forval i=1/11{
    	ta hrschange1`i' if hrschange1`i'>-8
    }
        
    recode howlng_cv -9/-1=. 97/144=97, gen(howlng1)
 
    recode timechcare -9/-1=. , gen(timeccare1)
    //childcare: child <=18 yrs old
    replace timeccare1=. if parent1==0

 *Income - full income, labour income, and net income
  
    /*fimngrs15 fimnlabgrs15 fimnnet15*/
   
    merge n:1 year using ///
	"$pc\Academia\Literature\0Statistics\Income Inflation/UK1989_2019CPI" 
    keep if _merge==3
	drop _merge year 
    
*Individual Income:
    recode blpayhow -9/-1=. 1=0 2/5=1, gen(bpayhow)
    la def fixpay 0 "fixed salary" 1 "non-fixed"
    la val bpayhow fixpay
    ta bpayhow    
    count if blpay_amount<0
    table blpay_period, c(min blpay_amount max blpay_amount)
    
    recode blpay_amount -9/-1=. , ///
        gen(fimnlabgrs_dv0)
   
    replace fimnlabgrs_dv0=fimnlabgrs_dv0*4 if blpay_period ==1 |blpay_period ==5
    
    replace fimnlabgrs_dv0=fimnlabgrs_dv0*2 if blpay_period ==2
    
    replace fimnlabgrs_dv0=fimnlabgrs_dv0/12 if blpay_period ==4
    replace fimnlabgrs_dv0=16000 if fimnlabgrs_dv0>16000&fimnlabgrs_dv0~=.
    
    gen fimnlabgrs0=fimnlabgrs_dv0*100/CPIH
    la var fimnlabgrs0 "new: Individual last month gross LABOR income adj2015"
    
    table netpay_period, c(min netpay_amount max netpay_amount )    
    
    recode netpay_amount -9/-1=. , ///
        gen(fimnlabgrs_dv1)
   sum fimnlabgrs_dv1 if netpay_period==3
    replace fimnlabgrs_dv1=fimnlabgrs_dv1*4 if netpay_period ==1 |netpay_period ==5
    
    replace fimnlabgrs_dv1=fimnlabgrs_dv1*2 if netpay_period ==2
    
    replace fimnlabgrs_dv1=fimnlabgrs_dv1/12 if netpay_period ==4
    
    replace fimnlabgrs_dv1=20000 if fimnlabgrs_dv1>20000&fimnlabgrs_dv1~=.
    
     gen fimnlabgrs1=fimnlabgrs_dv1*100/CPIH
    la var fimnlabgrs1 "new: Individual last month gross LABOR income adj2015"
        rename (fimnlabgrs0 fimnlabgrs1) (fimnlab0 fimnlab1)
        
        
  *Household Income:
    table blhhearn_period, c(min blhhearn_amount max blhhearn_amount)
    recode blhhearn_amount -9/-1=., gen(fihhmn_all0)
    sum fihhmn_all0 if blhhearn_period==3
    sum blhhearn_amount
    
    replace fihhmn_all0=fihhmn_all0*4 if blhhearn_period==1 |blhhearn_period==5
    replace fihhmn_all0=fihhmn_all0*2 if blhhearn_period==2
    replace fihhmn_all0=fihhmn_all0/12 if blhhearn_period==4   
    replace fihhmn_all0=20000 if fihhmn_all0>20000&fihhmn_all0~=.
  
    gen fihhmn0=fihhmn_all0*100/CPIH
	la var fihhmn0  "new: monthly HOUSEHOLD earnings[net]adj 2015"
     
    count if hhearn_amount<0
    recode hhearn_amount -9/-1=., gen(fihhmn_all1)
    replace fihhmn_all1=fihhmn_all1*4 if hhearn_period==1
    replace fihhmn_all1=fihhmn_all1*2 if hhearn_period==2
    replace fihhmn_all1=fihhmn_all1/12 if hhearn_period==4   
    
    replace fihhmn_all1=20000 if fihhmn_all1>20000&fihhmn_all1~=.
  
    gen fihhmn1=fihhmn_all1*100/CPIH
	la var fihhmn1  "new: monthly HOUSEHOLD earnings[net]adj 2015" 
    
    foreach v in fimnlab0 fimnlab1 ///
            fihhmn0 fihhmn1 {
    	replace `v'=0.5 if `v'==0
    }
  
*Subjective financial perception:
    ta finnow, m
    ta finfut_cv,m 
    rename finnow finnow1
    rename finfut_cv finfut1
    rename finsec finsec1
 *Wellbeing
     ta scghq1_dv,m //14% missing...
     codebook scghq1_dv
 
   recode scghq1_dv -9/-1=.,gen(swb1)
   sum swb1 if sex==1
   revrs swb1, replace 
   table sex, c (mean swb1) //25.71 men and 23.96 women
   
   
* codebook furlough
    recode furlough -8=2 2=0 -9=. -2/-1=., gen(furlough1)
    la val furlough1 keyworker
    ta furlough1 working1,m
    
    codebook sclonely_cv
    recode sclonely_cv -8/-1=. ,gen(sclonely1)
    la val sclonely1  ca_sclonely_cv
    ta sclonely1, m

    codebook sempgovt
    
    ta keyworksector working1
    gen keyworker1=[keyworksector>0&keyworksector<9]
    replace keyworker1=2 if keyworksector==-8
    replace keyworker1=. if keyworksector==-9|keyworksector==-2|keyworksector==-1
    ta keyworker working1,m
    replace working1=1 if keyworker==1
    replace working1=0 if keyworker==-8
    ta keyworksector keyworker,m