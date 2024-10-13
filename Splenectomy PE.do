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

//cd "C:\Users\reblo\Box\Residency Personal Files\Scholarly Work\Locke Research Projects\Splenectomy-PE\"
cd "/Users/blocke/Box Sync/Residency Personal Files/Scholarly Work/Locke Research Projects/Splenectomy-PE"

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

/* 

"We have now gotten through the secondary data and added things as you requested for each group (Age, sex, BMI should be there for all pts and made the chronic changes into a 1 or 0 variable).   Also moved the excluded splenectomy patients to a different tab.  "

Age, gender, BMI first ; subsequent analysis may include  - 

Race/ethnicity
Presence/absence of provoking factors for PE or CTEPH
Cancer, immobility/injury within 30d, surgery within 30d, clotting d/o, chf, chronic lung dz, afib, pregnancy, estrogen use, obesity, CVC (central or picc line) presence within 30d), thyroid disease, prior VTE of any kind, antiphospholipid ab, lupus anticoagulant, factor VIII level if present, non-O blood group,  inflammatory bowel disease)
DVT present, absent, or unknown based on chart records within 1 week of incident event.  
VS related to PE hospitalization, PESI score at dx
Hospital admission location, LOS in ICU and hospital
PE therapy received
RV strain on CTA
Highest BNP and trop during hospitalization
Echo findings/RHC findings with PH
Eventual diagnosis of CTEPH, CTED or chronic PE on imaging
History of splenectomy (as well as age at splenectomy and indication for it if present)
Estrogen use

*/ 



//Variables of interest: 
//age == age_peyears
//dwpelocation == centraldarrensreview
//qanadli == qanadlifinal
//marklocation == centralmarksreview
//markqanadli == marksqanadli

import excel "PE after splenectomy.xlsx", sheet("Included patients") firstrow case(lower)
drop if missing(age_peyears)
keep age_peyears centraldarrensreview qanadlifinal centralmarksreview marksqanadli malegender1yes0no chronicchanges1yes0no bmi_pe raceethnicity
destring chronicchanges1yes0no, replace
rename age_peyears age 
rename centraldarrensreview central_darren
replace central_darren = 0 if missing(central_darren)
rename qanadlifinal qanadli_darren
gen central_mark = 0
replace central_mark = 1 if centralmarksreview == "central"
drop centralmarksreview
rename marksqanadli qanadli_mark
gen splenectomy = 1
rename malegender1yes0no male_sex 
rename chronicchanges1yes0no chronic_changes
replace raceethnicity = lower(trim(raceethnicity))
destring bmi_pe, replace force
save splenectomy, replace
clear

import excel "PE without splenectomy.xlsx", sheet("Sheet1") firstrow case(lower)
drop if missing(age_peyears)
keep age_peyears dwpelocation dwqanadli marklocation markqanadli malegender1yes0no chronicchanges bmi_pe ethnicity
rename age_peyears age
replace dwpelocation = lower(trim(dwpelocation))
gen central_darren = 0
replace central_darren = 1 if dwpelocation == "central"
drop dwpelocation
rename dwqanadli qanadli_darren
replace marklocation = lower(trim(marklocation))
gen central_mark = 0 
replace central_mark = 1 if marklocation == "interlobar"
replace central_mark = 1 if marklocation == "main pa"
replace central_mark = 1 if marklocation == "lobar"
drop marklocation
rename markqanadli qanadli_mark
gen  splenectomy = 0
rename malegender1yes0no male_sex 
gen chronic_changes = 0 
replace chronic_change = 1 if chronicchanges == 1
drop chronicchanges
rename ethnicity raceethnicity
replace raceethnicity = lower(trim(raceethnicity))
destring bmi_pe, replace force
save no_splenectomy, replace

append using splenectomy.dta


label variable age "Age (years)"
label variable male_sex "Male Sex"
label define male_lab 0 "Female" 1 "Male"
label values male_sex male_lab
label variable qanadli_darren "Qanadli Score (Darren)"
label variable qanadli_mark "Qanadli Score (Mark)"
label variable central_darren "Central PE? (Darren)"
label variable central_mark "Central PE? (Mark)"
label variable splenectomy "Splenectomy"
label variable chronic_changes "Chronic Changes on Imaging"
label define splenectomy_lab 0 "No Splenectomy" 1 "Splenectomy"
label values splenectomy splenectomy_lab
label variable bmi_pe "BMI"
label variable raceethnicity "Race/Ethnicity"


//Generate Averages 
* Create a new variable "qanadli" that is the average of "qanadli_mark" and "qanadli_darren"
generate qanadli = (qanadli_mark + qanadli_darren) / 2
label variable qanadli "Qanadli Score (Avg)"

//if either called central, call it central
generate central = 0
replace central = 1 if central_darren == 1 | central_mark == 1
label variable central "Central? (either rater)"

save full_db, replace
export excel using "splenectomy_pe_data.xlsx", replace firstrow(variables)
//use subsample_db_5_perc
cd ..



/* Analysis */ 

table1_mc, by(splenectomy) ///
		vars( ///
		age contn %4.0f \ ///
		male_sex bin %4.0f \ ///
		raceethnicity cat %4.0f \ ///
		bmi_pe conts %4.1f \ ///
		central_darren bin %4.0f \ ///
		central_mark bin %4.0f \ ///
		qanadli_darren conts %4.2f \ ///
		qanadli_mark conts %4.2f \ ///
		central bin %4.0f \ ///
		qanadli conts %4.2f \ ///
		chronic_changes bin %4.0f  ///
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
	   
twoway kdensity qanadli if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(0.1) range(0 1) || ///
kdensity qanadli if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(0.1) range(0 1) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0(0.1)1, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("Qanadli Score", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("Qanadli Score by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/Qanadli by Splenectomy Status.png", as(png) name("Graph") replace 

//Association between splenectomy and quanadli average

//poisson? 

poisson qanadli splenectomy, irr
poisson qanadli splenectomy age male_sex, irr
poisson qanadli splenectomy age male_sex bmi_pe, irr
estimates store qanadli

//regress qanadli splenectomy
//regress qanadli splenectomy age male_sex

//Chi2 of binary association.

logistic central splenectomy
logistic central splenectomy age male_sex
logistic central splenectomy age male_sex bmi_pe
estimates store central



//chronic changes

tab splenectomy chronic_changes, row
logistic chronic_changes splenectomy
logistic chronic_changes splenectomy age male_sex
logistic chronic_changes splenectomy age male_sex bmi_pe
estimates store chronic_changes


coefplot qanadli, eform ///
drop(_cons) ///
xscale(log range(0.25 4) extend) ///
xline(1) ///
xlabel(0.25 0.5 1 2 4, labsize(large)) ///
xscale(extend) ///
xtitle("Multiplicative Change in Qanadli Score" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.2f") + " [ " + string(@ll,"%9.2f") + " - " + string(@ul,"%9.2f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/Qanadli Poisson Regression.png", as(png) name("Graph") replace 

coefplot central, eform ///
drop(_cons) ///
xline(1) ///
xlabel(0.125 0.25 0.5 1 2 4, labsize(large)) ///
xscale(log range(0.125 4) extend) ///
xtitle("Odds ratio of Central PE" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.2f") + " [ " + string(@ll,"%9.2f") + " - " + string(@ul,"%9.2f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/Central Logistic Regression.png", as(png) name("Graph") replace


coefplot chronic_changes, eform ///
drop(_cons) ///
xline(1) ///
xlabel(0.5 1 2 4 8 16 32, labsize(large)) ///
xscale(log range(0.5 32) extend) ///
xtitle("Odds ratio of Chronic Changes on CT" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.2f") + " [ " + string(@ll,"%9.2f") + " - " + string(@ul,"%9.2f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/Chronic Changes Logistic Regression.png", as(png) name("Graph") replace

