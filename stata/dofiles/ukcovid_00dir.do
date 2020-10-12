*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*Common Do File for BHPS and Understanding Society Work-Harmonized BHPS&UnSoc
*Study Number: 6931-special license data including month of birth
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

*Author: Muzhi ZHOU
*file path directory:
 
*Path for Working through One Drive:

 global RawData    $local/UKHLS/RawData/UKDA-6614-stata\stata/stata11_se //latest understanding society data
 global RawCovid $local/UKHLS\RawData\UKDA-8644-stata\stata\stata13
 
 global RawDataBHPSfam   $local/UKHLS\RawData/UKDA-5629-stata8/stata8 
						//family history for BHPS
                        
  global RawDataUKfam   $local/UKHLS\RawData/UKDA-8473-stata\stata\stata13
						//family history for BHPS
						
 global RawDataSE   $local/UKHLS\RawData\UKDA-6931-stata\stata\stata11_se
						//Special License Data SN6931

		
 global Output    $onedrive\Stata_2020\Output
 global Do        $onedrive\Stata_2020\Do
 global docovid     $onedrive\Stata_covid/do
 
 global WorkData  $local\UKHLS\WorkData/covid

 
 
 ********************************************************************************
/*
*add programs

ssc install grstyle
ssc install kdens
ssc install moremata
ssc install coefplot
ssc install grc1leg
ssc install center 
ssc install esttab 
ssc install xtfeis

*/
