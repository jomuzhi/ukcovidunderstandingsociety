use "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid/COVID_overview_2021-08-02",clear
codebook date
gen surveydate=date(date, "YMD")
format surveydate %td
replace surveydate=surveydate+1
//show report one days after the publication of the numbers

rename date pubdate

drop var*

sort surveydate

gen week_deathrate=(newdeaths28daysbydeathdaterate[_n-1]+newdeaths28daysbydeathdaterate[_n-2]+newdeaths28daysbydeathdaterate[_n-3]+newdeaths28daysbydeathdaterate[_n-4]+newdeaths28daysbydeathdaterate[_n-5]+newdeaths28daysbydeathdaterate[_n-6]+newdeaths28daysbydeathdaterate[_n-7])/7
la var week_deathrate "Average death rate of prior week"

foreach var in newadmissions newcasesbypublishdate newdeaths28daysbydeathdate newtestsbypublishdate {
	gen week_`var'=(`var'[_n-1] + `var'[_n-2] + `var'[_n-3] + `var'[_n-4] + `var'[_n-5] + `var'[_n-6] + `var'[_n-7]) /7
}


		
save "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid/COVID_overview_2021-08-07", replace

use "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid/COVID_overview_2021-08-07", clear
set scheme s1color	
		
drop if week_deathrate ==.
drop if surveydate>22400
la var week_newcasesbypublishdate "New cases by publish date"
la var week_deathrate "Crude death rate by death date, per 100,000 population"

gen surveymonth=month(surveydate) //date from 1960-01-01


twoway (line week_newcasesbypublishdate surveydate, c(l) yaxis(1) lpattern(solid)) ///
		(line week_deathrate surveydate, c(l) yaxis(2) lpattern(dash shortdash longdash_dot )) ,  ///
		ytitle("Daily new cases (7-day average)")  ytitle("Daily death rate  (7-day average)",axis(2)) xtitle(" ") ///
		xlabel(22006 "01Apr2020" 22097 "01July2020" 22189 "01Oct2020" 22281 "01Jan2021" 22371 "01Apr2021") ///
		/*legend(stack symplacement(left) symxsize(8) forcesize rowgap(2))*/ ///
		legend(size(small) symxsize(6))  legend(position(6)  region(lcolor(bluishgray)))  legend(order(1 4 2 3)) ///
		graphregion(fcolor(white)) plotregion(fcolor(white) lcolor(white)) ///
		note("Data source: https://coronavirus.data.gov.uk/details" "Note: Crude death rate is new deaths within 28 days of positive test per 100,000 population",size(vsmall))
		

graph export "E:\OneDrive - Nexus365\Academia\Data\UKHLS_do\Stata_covid/covidmacro.png", as(png) replace