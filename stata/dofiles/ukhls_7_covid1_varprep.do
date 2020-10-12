*-----------Heckman Variables and Lambda Ratio--------------------
    la var dp_fimnlab "Change in monthly labour earnings"
    la var d_workhrall "Change in weekly paid work hours"
    la var d_howlng "Change in weekly housework time"
    la var d_timeccare "Change in weekly childcare time"
    la var d_swb "Change in subjective wellbeing"
    
    foreach y in dp_fimnlab  d_workhrall  d_howlng d_timeccare d_swb {
    	replace `y'=. if wave<29
    }

    
  count if chagemin==.
  gen chageminall=chagemin
  replace chageminall=0 if nchild==0
  *ta chageminall,m
  ta chageminc
  order chageminc chagemin
  replace chagemin=0 if chageminc==0&chagemin==.
  ta chageminc if chagemin==.
  replace chageminc=0 if chagemin<5&chageminc==.
  replace chageminc=1 if chagemin>4&chagemin<16&chageminc==.
  ta chageminc if nchild>0,m
  replace chageminc=2 if nchild==0  
  
  tabulate nchildc, gen(nchild3c)
  tabulate chageminc, gen(chageminc)
  tabulate x_race, gen(race)
  tabulate housetenure, gen(tenure)
  tabulate edu3c, gen(edu)
  recode new_hlstat 4/5=4
  tabulate new_hlstat, gen(sfhealth)
  
  tabulate furlough, gen(furloughc)
  tabulate keyworker, gen(keyworkerc)
  la var keyworkerc1 "Not keyworker"
  la var keyworkerc2 "Keyworker"
  la var keyworkerc3 "Not working"
  
  la var furloughc1 "Not furloughed"
  la var furloughc2 "Furloughed"
  la var furloughc3 "Not working"
  
 *Income:
  replace fimnlab=. if fimnlab<0.5&working==0|fimnlab==.&working==0 //value is 0.5 among nonworking ppl
  replace fihhmn=0.5 if fihhmn<0.5
  count if fihhmn==.
  *replace fihhmn=fimnlab if fihhmn==.
  gen lnfimnlab=ln(fimnlab)
  la var lnfimnlab "Log monthly wage earnngs (workers)"
  
  gen fihhmnpre=.
  bysort pidp: replace fihhmnpre=fihhmn[_n-1] if fihhmnpre==.&wave>27
  //replace this value only for covid sample
  replace fihhmnpre=fihhmn if fihhmnpre==.
  gen lnfihhmnpre=ln(fihhmnpre)
  count if lnfihhmnpre==.
  order pidp wave fihhmn fihhmnpre  
  la var lnfihhmnpre "Ln household income (full ukhls sample)"
  
  recode ukborn -9=. 1/4=1 5=0, gen(ukbornd)
  la var ukbornd "Born in the UK"
  
  la var chageminall "Age of youngest child"
  la var chageminc1 "Child age<5 (ref: No child)"
  la var chageminc2 "Child age5-15"
  la var chageminc3 "Non-parent"
  la var working "Has a job"
  la var lnfihhmn "Ln household net income"
  la var nchild3c2 "One child (ref: No child)"
  la var nchild3c3 "Two children"
  la var nchild3c4 ">=Three children"
  la var tenure2 "Owned mortgage (ref: Owned outright)"
  la var tenure3 "Rent-public"
  la var tenure4 "Rent-private"
  la var edu2 "Higher second.(Ref: GCSE)"
  la var edu3 "University or above"
  la var sfhealth2 "Good health (ref: Excellent)"
  la var sfhealth3 "Fair health"
  la var sfhealth4 "Poor health"
  la var chronic "Chronic disease"
  la var couple "Couple"
  la var workhrall "Weekly paid work hours"
  
  recode sex 1=0 2=1, gen(female)
    la var female "Women"
    la var race2 "Black (ref: White)"
    la var race3 "Asian"
    la var race4 "Others"
    la var age "Age"     
    la var furlough "Furloughed"
    la var keyworker "Keyworker"
    
  recode race1 1=0 0=1, gen(raceminor)
  la var raceminor "BAME"  
  
  count if sf12pcs_dv==.
  ta proxy //10%
  count if sf12mcs_dv==.
  //lots are proxy and inapplicable cases  
  
  recode gor_dv -9/-1=. 7=0 1/2=1 3=2 4/5=3 6=4 8/9=5 10/13=6, gen(region)
  la def govregion 0 "London" 1 "North" 2 "Yorkshire & Humber" ///
           3 "Midlands" 4 "East" 5 "South" 6 "Wales/Scot/NI"
  la val region  govregion
  ta region,m
  gsort pidp -wave
  bysort pidp: replace region=region[_n-1] if region==.
  sort pidp wave
    
  tabulate region, gen(region)
  la var region1 "London"
  la var region2 "North (ref: London)"
  la var region3 "Yorkshire & Humber"
  la var region4 "Midlands"
  la var region5 "East"
  la var region6 "South"
  la var region7 "Wales/Scot/NI"  
   
  *------------Interaction Variables------------------*
   gen intsp=.
   replace intsp=1 if couple==0&chageminc==2
   replace intsp=2 if couple==0&chageminc==0
   replace intsp=3 if couple==0&chageminc==1
   replace intsp=4 if couple==1&chageminc==2
   replace intsp=5 if couple==1&chageminc==0
   replace intsp=6 if couple==1&chageminc==1
   la def intsp 1 "single&no child" 2 "single&child<5" ///
    3 "single&child5-15" 4  "couple&no child" ///
    5 "couple&child<5" 6 "couple&child5-15"
    la val intsp intsp
    la var intsp "interaction:couplexparenthood"
    ta intsp, m
    tabulate intsp, gen(intsp)
    
   gen genderparent=.
    replace genderparent=1 if sex==1&parent==0
    replace genderparent=2 if sex==2&parent==0
    replace genderparent=3 if sex==1&parent==1
    replace genderparent=4 if sex==2&parent==1
    la def genderparent 1 "Chidless men" 2 "Childless women" 3 "Fathers" 4 "Mothers"
    la val genderparent genderparent
    la var genderparent "Interaction:Gender x Parent"
    ta genderparent sex,m
    ta genderparent parent,m
    tabulate genderparent, gen(genderparent)
    la var genderparent1 "Chidless men"
    la var genderparent2 "Childless women (ref: childless men)"
    la var genderparent3 "Father"
    la var genderparent4 "Mother"
   