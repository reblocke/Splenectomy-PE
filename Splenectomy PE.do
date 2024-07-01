/* 
Splenectomy PE 

Analytic Code

Brian W Locke MD MSCI

Last updated: 
7/1/2024


//TODO: for darren
Couple data cleaning requests - just so that I don't have to rewrite the data cleaning code if you make further updates. 

- for the PE after splenectomy group - make a separate spreadsheet for the ones you want excluded vs included (rather than having )
- chronic changes in after splenectomy group - reconcile these? e.g. currently there are a variety of answers but deciding which are yes and which are know will allow them to be analyzed (if wanted)
- ages make into numerical (not a mix of numbers and number+yo)
- need sex in both groups
- need bmi in the no splenectomy group 
*/ 



capture log close

* Load data
clear

cd "C:\Users\reblo\Box\Residency Personal Files\Scholarly Work\Locke Research Projects\Splenectomy-PE\"
//cd "/Users/blocke/Box Sync/Residency Personal Files/Scholarly Work/Locke Research Projects/TriNetX Code"

program define datetime 
end

capture mkdir "Results and Figures"
capture mkdir "Results and Figures/$S_DATE/" //make new folder for figure output if needed
capture mkdir "Results and Figures/$S_DATE/Logs/" //new folder for stata logs

/* Set up Do File Back-up*/ 
local a1=substr(c(current_time),1,2)
local a2=substr(c(current_time),4,2)
local a3=substr(c(current_time),7,2)
local b = "Splenectomy PE.do" // do file name
copy "`b'" "Results and Figures/$S_DATE/Logs/(`a1'_`a2'_`a3')`b'"

set scheme cleanplots
graph set window fontface "Helvetica"
log using temp.log, replace

/* Import Data and Reconcile/Combine Spreadsheets */ 

clear
cd "Data"


//Variables of interest: 
//age == age_peyears
//dwpelocation == centraldarrensreview
//qanadli == qanadlifinal
//marklocation == centralmarksreview
//markqanadli == marksqanadli

import excel "PE after splenectomy.xlsx", sheet("Included") firstrow case(lower)
drop if missing(age_peyears)
keep age_peyears centraldarrensreview qanadlifinal centralmarksreview marksqanadli
rename age_peyears age 
rename centraldarrensreview central_darren
replace central_darren = 0 if missing(central_darren)
rename qanadlifinal qanadli_darren
gen central_mark = 0
replace central_mark = 1 if centralmarksreview == "central"
drop centralmarksreview
rename marksqanadli qanadli_mark
gen splenectomy = 1
save splenectomy, replace
clear

import excel "PE without splenectomy.xlsx", sheet("Included") firstrow case(lower)
drop if missing(ageattimeofpe)
keep ageattimeofpe dwpelocation qanadli marklocation markqanadli
rename ageattimeofpe age
replace dwpelocation = lower(trim(dwpelocation))
gen central_darren = 0
replace central_darren = 1 if dwpelocation == "central"
drop dwpelocation
rename qanadli qanadli_darren
replace marklocation = lower(trim(marklocation))
gen central_mark = 0 
replace central_mark = 1 if marklocation == "interlobar"
replace central_mark = 1 if marklocation == "main pa"
replace central_mark = 1 if marklocation == "lobar"
drop marklocation
rename markqanadli qanadli_mark
gen  splenectomy = 0
save no_splenectomy, replace

append using splenectomy.dta


label variable age "Age (years)"
label variable qanadli_darren "Qanadli Score (Darren)"
label variable qanadli_mark "Qanadli Score (Mark)"
label variable central_darren "Central PE? (Darren)"
label variable central_mark "Central PE? (Mark)"
label variable splenectomy "Splenectomy"
label define splenectomy_lab 0 "No Splenectomy" 1 "Splenectomy"
label values splenectomy splenectomy_lab

save full_db, replace
export excel using "splenectomy_pe_data.xlsx", replace firstrow(variables)
//use subsample_db_5_perc
cd ..



/* Analysis */ 

table1_mc, by(splenectomy) ///
		vars( ///
		age contn %4.0f \ ///
		central_darren bin %4.0f \ ///
		central_mark bin %4.0f \ ///
		qanadli_darren contn %4.2f \ ///
		qanadli_mark contn %4.2f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol saving("Results and Figures/$S_DATE/overall by splenectomy.xlsx", replace)

//Kappa Score of Agreement
kap central_darren central_mark, tab
pvenn2 central_darren central_mark, plabel("Darren_Central" "Mark_Central") title("Agreement in Central Determination")
graph export "Results and Figures/$S_DATE/Overlap in Central Assessments.png", as(png) name("Graph") replace 

//Correlation between quanadli scores

corr qanadli_mark qanadli_darren

regress qanadli_mark qanadli_darren
local rsquared = round(e(r2), 0.01)
twoway (scatter qanadli_mark qanadli_darren) ///
       (lfit qanadli_mark qanadli_darren), ///
       xlabel(0(.1)1, format(%3.2f)) ylabel(0(.1)1, format(%3.2f)) ///
       title("Scatter plot with Regression Line") ///
       xtitle("Qanadli Darren") ytitle("Qanadli Mark") ///
       legend(off) ///
       text(0.9 0.1 "R-squared = `rsquared'", place(e)) ///
	   title("Agreement in Qanadli Score Assessments")
graph export "Results and Figures/$S_DATE/Overlap in Qanadli Assessments.png", as(png) name("Graph") replace 
	   
//Generate Averages 
* Create a new variable "qanadli" that is the average of "qanadli_mark" and "qanadli_darren"
generate qanadli = (qanadli_mark + qanadli_darren) / 2

//if either called central, call it central
generate central = 0
replace central = 1 if central_darren == 1 | central_mark == 1

twoway kdensity qanadli if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*1.25) bwidth(0.1) range(0 1) || ///
kdensity qanadli if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*1.25) bwidth(0.1) range(0 1) ||, ///
legend(pos(12) order(1 "No Splenectomy" 2 "Splenectomy") rows(2)) ///
xlabel(0(0.1)1, labsize(medlarge)) ///
ylabel(, labsize(medlarge)) ///
xtitle("Qanadli Score", size(medium)) ///
ytitle("Relative Frequency", size(medium)) ///
title("Qanadli Score Distribution by Splenectomy Status", size(medium)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/Qanadli by Splenectomy Status.png", as(png) name("Graph") replace 

//Association between splenectomy and quanadli average

regress qanadli splenectomy
regress qanadli splenectomy age

//Chi2 of binary association.

logistic central splenectomy
logistic central splenectomy age






