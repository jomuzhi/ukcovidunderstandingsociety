*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*Common Do File for BHPS and Understanding Society Work-Harmonized BHPS&UnSoc
*Study Number: 6931-special license data including month of birth
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

*Author: Muzhi ZHOU
*file path directory:

 
*Path for Working through One Drive:

 global RawDataSL  E:\Academia\Data\UKHLS\RawData\UKDA-6931-stata\stata\stata13_se
 global RawCovid   E:\Academia\Data\UKHLS\RawData\Covid\UKDA-8644-stata\stata\stata13_se

		
 global Output    E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021\output/covid
 global Do        E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid\2021/do
 
 global WorkData  E:\Academia\Data\UKHLS\WorkData\covid

 
 
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
ssc install xtheckmanfe
ssc install ftools

*/