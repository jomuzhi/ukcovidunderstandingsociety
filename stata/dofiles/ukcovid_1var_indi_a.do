
     recode sex 1=0 2=1
     la def sex 0 "Men" 1 "Women"
     la val sex sex
     
     recode blwork -9/-1=. 4=0 1/3=1, gen(working0)
     ta working0 sex, col
     la def working 0 "not working" 1 "working"
     la val working0 working
     
     recode sempderived -9/-1=. 1/3=1 4=0,gen(working1)
     replace working1=working0 if sempderived==-8
     
     ta blwah working0
     replace working0=0 if blwah==-8
     replace working0=. if blwah==-2|blwah==-9
     replace working0=1 if working0==0&blwah>0
     
     ta sempderived working1
     ta wah working1,m
     replace working1=. if wah==-9|wah==-2
     
     ta keyworker working1,m
     replace working1=. if keyworker==-9|keyworker==-1|keyworker==-2
     replace working1=0 if keyworker==-8&working1==1
     ta furlough working1,m
     * order pidp hours working1 keyworker furlough
     replace working1=0 if furlough==-8&working1==1&keyworker<0 
     
 *Baseline benefits:
    recode blbenefits6 -9/-1=. , gen(notonbenefits0)
 
 *Baseline health:
    recode nhsshield -9/-1=. , gen(nhsshieldnew)
    
    recode hcond_cv96 -9/-1=. , gen(chronic0) 
    //1 - yes, chronic disease
     
 * Demographic:
    recode couple 2=0 1=1
    
    gen parent=[hhcompa>0|hhcompb>0]
    la var parent "has child<=age15 at household"
    gen nchild=.
    replace nchild=hhcompa+hhcompb
    la var nchild "number of children<=age15"
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
    gen hh_hhsize=. //wave a not asked this info
   /* 
    gen hh_hhsize=hhcompa+hhcompb+hhcompc+hhcompd+hhcompe+1 //add back herself
    
    ta hh_hhsize
    ta sex parent, row nof 
    ta sex couple, row nof 
    //more men are reporting living with a partner!
    table sex, c(mean hh_hhsize)
    //women tend to live in larger household
   */
  *  order pidp couple hhcomp* parent nchild
    
    rename (couple hhcomp* parent nchild nchildc chageminc hh_hhsize)(couple1 hhcomp*1 parent1 nchild1 nchildc1 chageminc1 hh_hhsize1)
 
 *Paid work and housework time, childcare time 
    recode blhours -9=-9 -8/-1=. 97/200=97, ///
        gen(workhrall0)
        
    recode workhrall0 -9=3 0/29=2 30/97=1,gen(new_jbft0)
    la def new_jbft 1 "FT:30hr+" 2 "PT<30hr" 3 "NotWorking"
    la val new_jbft0 new_jbft  
    replace workhrall0=. if workhrall0<0
    
    replace new_jbft0=3 if working0==0
    ta new_jbft0 working0,m
        
    recode hours -9=-9 -8/-1=. 97/200=97, ///
        gen(workhrall1)        
    recode workhrall1 -9=3 0/29=2 30/97=1,gen(new_jbft1)
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
     replace timeccare1=. if parent==0

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
	la var fihhmn0  "new: monthly HOUSEHOLD income[net]adj 2015"
     
    recode hhearn_amount -9/-1=., gen(fihhmn_all1)
    replace fihhmn_all1=fihhmn_all1*4 if hhearn_period==1
    replace fihhmn_all1=fihhmn_all1*2 if hhearn_period==2
    replace fihhmn_all1=fihhmn_all1/12 if hhearn_period==4   
    
    replace fihhmn_all1=20000 if fihhmn_all1>20000&fihhmn_all1~=.
  
    gen fihhmn1=fihhmn_all1*100/CPIH
	la var fihhmn1  "new: monthly HOUSEHOLD income[net]adj 2015" 
    
    foreach v in fimnlab0 fimnlab1 ///
            fihhmn0 fihhmn1 {
    	replace `v'=0.5 if `v'==0
    }
  
 *Subjective financial perception:
    ta finnow, m
    ta finfut_cv,m 
    rename finnow finnow1
    rename finfut_cv finfut1
 
 *Wellbeing
     ta scghq1_dv,m //14% missing...
     codebook scghq1_dv
 
   recode scghq1_dv -9/-1=.,gen(swb1)
   sum swb1 if sex==1
   revrs swb1, replace 
   
 
  *Others
    ta keyworker working1, m
    recode keyworker -8=2 -2/-1=. 2=0 , gen(keyworker1)
    la def keyworker 0 "No" 1 "Yes" 2 "Not working"
    la val keyworker1 keyworker
    ta keyworker keyworker1, m
    
   * codebook furlough
    recode furlough -8=2 2=0 -9=. -2/-1=., gen(furlough1)
    la val furlough1 keyworker
    ta furlough1 working1,m
    
    codebook sclonely_cv
    recode sclonely_cv -8/-1=. ,gen(sclonely1)
    la val sclonely1  ca_sclonely_cv
    ta sclonely1, m

    codebook sempgovt
    codebook lacknutr hungry
   
*Care info:
    recode caring -9/-1=., gen(caring1)
    la val caring1 ca_caring
    
    forval i=1/10{
    	ta carehow`i'
    } //shopping for them is most common
    
    forval i=1/8{
        ta carewho`i'
    } //helping for parents most common
    
    ta help //help last four weeks
    recode help -9/-1=., gen(help1)
    la val help1 ca_help
    
    forval i=1/5{
    ta carechange`i', m
    }
    
    forval i= 1/10{
    	ta helpwhat`i' if helpwhat`i'>0
    }
   *Received shopping help a lot
    forval i = 1/8 {
   	ta helpwho`i',m
   }
   //Adult kids, neighbours, friends
   
    
    
*Home schooling info:
    ta child1 //ask if children 0-4 or 5-16 or 16-18 living in household
    ta child2
    capture drop childscha
    recode child1 -9=. -2=. -1=., gen(childscha)
    la val childscha ca_child1
    ta childscha
    
    capture drop childschb
    recode child2 -9=. -2=. -1=., gen(childschb)
    la val childschb ca_child2
    ta childschb
    la def dummy -8 "Inapplicable" -2 "Refusal" -1 "Don't know" 0 "No" 1 "Yes"
    
    foreach i in a b c d e f g h i j {
    	recode childage`i' -9=. -8=. -7/-1=., gen(nchildage`i')
        la val nchildage`i' ca_childagea
        recode atschool_child`i' -9=. -8=. -7/-1=. 1=0 2/4=1, gen(natschool_child`i')
        la val natschool_child`i' dummy
        recode schoolwork_child`i' -9=. -7/-1=. 2=0, gen(nschoolwork_child`i')
        la val nschoolwork_child`i' dummy
        recode marking_child`i' -9=. -7/-1=. 1=0 5=0 2/4=1, gen(nmarking_child`i')
        la val nmarking_child`i' dummy        
        recode compreq_child`i' -9=. -7/-1=. 1=0  5=0 2/4=1, gen(ncompreq_child`i') 
        //if school work
        la val ncompreq_child`i' dummy        
        recode chcomputer_child`i' -9=. -7/-1=. 2/3=0 , gen(nchcomputer_child`i')
        //very few do not hv computer
        la val nchcomputer_child`i' dummy
        //if school work
        recode hstime_child`i' -9=. -7/-1=. 7=., gen(nhstime_child`i')
        recode hshelp_child`i'  -9=. -7/-1=. 8=., gen(nhshelp_child`i')        
    }
    
    
    capture drop chageminsch
    gen chageminsch=min(nchildagea,nchildageb,nchildagec,nchildaged,nchildagee,nchildagef,nchildageg,nchildageh,nchildagei,nchildagej)
    gen chagemaxsch=max(nchildagea,nchildageb,nchildagec,nchildaged,nchildagee,nchildagef,nchildageg,nchildageh,nchildagei,nchildagej)
    *order pidp *hidp chageminsch chagemaxsch nchildage*
    //this info is tied to individuals, not household members
    la var chageminsch "age of the youngest sch-aged kid"
    la var chagemaxsch "age of the oldest sch-aged kid"
    
   *Number of kids at school now during covid
   *Key workers - this is a comparison group!
    capture drop atschnchild    
    gen atschnchild = 0 
    qui foreach v of var natschool_childa natschool_childb natschool_childc natschool_childd natschool_childe natschool_childf natschool_childg natschool_childh natschool_childi natschool_childj { 
        replace atschnchild = atschnchild + `v' if !missing(`v') 
    }
    
    la var atschnchild "number of kid at school"
    *order pidp  *hidp childscha childschb atschnchild natschool_child*
    *ta atschnchild if child1==1
    //Please select all that apply, parents could use:
    //1. use freely available sources; 2. pay for additional sources; 3. none
    ta tutoring1_childa if tutoring1_childa>-1
    ta tutoring2_childa if tutoring2_childa>-1
    ta tutoring3_childa if tutoring3_childa>-1
    **
    
    