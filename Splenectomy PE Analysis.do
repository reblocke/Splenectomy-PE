/* 
Splenectomy PE 

Analytic Code

Brian W Locke MD MSCI

Assumes that data cleaning has already been run and 

data/full_db has been generated 

export excel using "cleaned_splenectomy_pe_data.xlsx", replace firstrow(variables)
cd ..

Note: the PYTHON JUPYTER notebook is more recent. 

*/ 

capture log close
cd "/Users/blocke/Box Sync/Residency Personal Files/Scholarly Work/Locke Research Projects/Splenectomy-PE"
//cd "/Users/reblocke/Research/Splenectomy-PE"

capture mkdir "Results and Figures"
capture mkdir "Results and Figures/$S_DATE/" //make new folder for figure output if needed
capture mkdir "Results and Figures/$S_DATE/Logs/" //new folder for stata logs

/* Set up Do File Back-up*/ 
local a1=substr(c(current_time),1,2)
local a2=substr(c(current_time),4,2)
local a3=substr(c(current_time),7,2)
local b = "Splenectomy PE Analysis.do" // do file name
copy "`b'" "Results and Figures/$S_DATE/Logs/(`a1'_`a2'_`a3')`b'"

set scheme cleanplots
graph set window fontface "Helvetica"
log using temp.log, replace

* Load data
clear
use "data/full_db"




/* 
Assess Agreement Between Raters 
*/ 
	
kap central_darren central_mark, tab
//kappaetc central_darren central_mark, tab benchmark(d)  showscale

pvenn2 central_darren central_mark, plabel("Central_DW" "Central_MD") title("Agreement in Central Determination")
graph export "Results and Figures/$S_DATE/Overlap in Central Assessments.png", as(png) name("Graph") replace 

//Limits of agreement for Qanadli
kappaetc qanadli_mark qanadli_darren, loa 
graph export "Results and Figures/$S_DATE/Bland Altman Qanadli.png", as(png) name("Graph") replace 
kappaetc qanadli_mark qanadli_darren, loa returnonly
di "Number of subjects: " r(N)
di "Mean difference of ratings: " r(mean_diff)
di "Standard deviation of mean difference: " r(sd_diff)
di "Lower limit of agreement: " r(loa_ll)
di "Upper limit of agreement: " r(loa_ul)
di "Level for limits of agreement: " r(loa_level)

table1_mc, by(splenectomy) ///
		vars( ///
		central_darren bin %4.0f \ ///
		central_mark bin %4.0f \ ///
		qanadli_darren conts %4.2f \ ///
		qanadli_mark conts %4.2f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ratings mark darren by splenectomy.xlsx", replace)

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
	  
	 

/* 
Data description and crosstabulations with splenectomy statu
*/ 

/*
Baseline Characteristics, by spelenectomy status
*/
table1_mc, by(splenectomy) ///
		vars( ///
		age contn %4.0f \ ///
		male_sex bin %4.0f \ ///
		raceethnicity cat %4.0f \ ///
		bmi_pe conts %4.1f \ ///
		years_since_splenectomy conts %4.1f \ ///
		pe_date conts %td \ ///
		prior_pe_dvt bin %4.0f \ ///
		prior_other_vte bin %4.0f \ ///
		active_malig bin %4.0f \ ///
		sickle_cell bin %4.0f \ ///
		clotting_disorder bin %4.0f \ ///
		chf bin %4.0f \ ///
		chronic_lung bin %4.0f \ ///
		a_fib bin %4.0f \ ///
		curr_preg bin %4.0f \ ///
		obesity_dx bin %4.0f \ ///
		thyroid_dz bin %4.0f \ ///
		ibd bin %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/baseline chars by splenectomy.xlsx", replace)

		//ed_encounter only
table1_mc if ed_encounter, by(splenectomy) ///
		vars( ///
		age contn %4.0f \ ///
		male_sex bin %4.0f \ ///
		raceethnicity cat %4.0f \ ///
		bmi_pe conts %4.1f \ ///
		years_since_splenectomy conts %4.1f \ ///
		pe_date conts %td \ ///
		prior_pe_dvt bin %4.0f \ ///
		prior_other_vte bin %4.0f \ ///
		active_malig bin %4.0f \ ///
		sickle_cell bin %4.0f \ ///
		clotting_disorder bin %4.0f \ ///
		chf bin %4.0f \ ///
		chronic_lung bin %4.0f \ ///
		a_fib bin %4.0f \ ///
		curr_preg bin %4.0f \ ///
		obesity_dx bin %4.0f \ ///
		thyroid_dz bin %4.0f \ ///
		ibd bin %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ED only -baseline chars by splenectomy.xlsx", replace)
	
bysort obesity_dx: summ bmi_pe, detail //decent overlap
	
	
table1_mc, by(splenectomy) ///
		vars( ///
		symptoms_two_weeks bin %4.0f \ ///
		dvt_workup bin %4.0f \ ///
		dvt_found bin %4.0f \ ///
		) ///
		percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol saving("Results and Figures/$S_DATE/dvt presence by splenectomy.xlsx", replace)
	
table1_mc if ed_encounter, by(splenectomy) ///
		vars( ///
		symptoms_two_weeks bin %4.0f \ ///
		dvt_workup bin %4.0f \ ///
		dvt_found bin %4.0f \ ///
		) ///
		percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol saving("Results and Figures/$S_DATE/ED only - dvt presence by splenectomy.xlsx", replace)
	
	
/* 
CT and TTE Characteristics: 
*/

table1_mc, by(splenectomy) ///
		vars( ///
		central bin %4.0f \ ///
		qanadli conts %4.2f \ ///
		pa_d conts %4.2f \ ///
		aa_d conts %4.2f \ ///
		pa_aa conts %4.2f \ ///
		pa_enlarged bin %4.0f \ ///
		high_pa_aa bin %4.0f \ ///
		pa_enlarged_by_d_or_ratio bin %4.0f \ ///
		rvlvratio_initial1abnormal bin %4.0f \ ///
		rightheartstrain bin %4.0f \ ///
		lvef conts %4.2f \ ///
		septal_flattening bin %4.0f \ ///
		rvsp conts %4.2f \ ///
		insuff_tr_jet_for_rvsp bin %4.0f \ ///
		pv_accel_time conts %4.2f \ ///
		unmeasured_pv_accel_time bin %4.0f \ ///
		tr_velocity conts %4.2f \ ///
		unmeasured_tr_vel bin %4.0f \ ///
		tapse conts %4.2f \ ///
		unmeasured_tapse bin %4.0f \ ///
		rv_basal_diameter cat %4.0f \ ///
		ra_area conts %4.2f \ ///
		unquantified_ra_area bin %4.0f \ ///
		pericardial_eff cat %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ct and tte chars by splenectomy.xlsx", replace)	
		
table1_mc if ed_encounter, by(splenectomy) ///
		vars( ///
		central bin %4.0f \ ///
		qanadli conts %4.2f \ ///
		pa_d conts %4.2f \ ///
		aa_d conts %4.2f \ ///
		pa_aa conts %4.2f \ ///
		pa_enlarged bin %4.0f \ ///
		high_pa_aa bin %4.0f \ ///
		pa_enlarged_by_d_or_ratio bin %4.0f \ ///
		rvlvratio_initial1abnormal bin %4.0f \ ///
		rightheartstrain bin %4.0f \ ///
		lvef conts %4.2f \ ///
		septal_flattening bin %4.0f \ ///
		rvsp conts %4.2f \ ///
		insuff_tr_jet_for_rvsp bin %4.0f \ ///
		pv_accel_time conts %4.2f \ ///
		unmeasured_pv_accel_time bin %4.0f \ ///
		tr_velocity conts %4.2f \ ///
		unmeasured_tr_vel bin %4.0f \ ///
		tapse conts %4.2f \ ///
		unmeasured_tapse bin %4.0f \ ///
		rv_basal_diameter cat %4.0f \ ///
		ra_area conts %4.2f \ ///
		unquantified_ra_area bin %4.0f \ ///
		pericardial_eff cat %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ED only - ct and tte chars by splenectomy.xlsx", replace)	
		
// dilatedpulmartery bin %4.0f \ /// - not sure what this one is about. Comment in report?

//Very high rates of enlargment. 				
logistic high_pa_aa male age splenectomy, or //controlling for age, sex actually makes more dramatic.

// Penalized regression - may be more valid to use w small samples.
firthlogit high_pa_aa male age splenectomy, or 
					
/* 	
Acute Illness characteristics:
*/ 

table1_mc, by(splenectomy) ///
		vars( ///
		location cat %4.0f \ ///
		active_malig bin %4.0f \ ///
		wells_surg bin %4.0f \ ///
		wells_immobility bin %4.0f \ ///
		recent_cvc bin %4.0f \ ///
		curr_preg bin %4.0f \ ///
		curr_estr bin %4.0f \ ///
		pesi_pe conts %4.0f \ ///
		highest_hr conts %4.2f \ ///
		lowest_sbp conts %4.2f \ ///
		lowest_dbp conts %4.2f \ ///
		lowest_map conts %4.2f \ ///
		max_resp cat %4.0f \ ///
		troponin_max conts %4.2f \ ///
		bnp_max conts %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/phys by splenectomy.xlsx", replace)

table1_mc if ed_encounter, by(splenectomy) ///
		vars( ///
		location cat %4.0f \ ///
		active_malig bin %4.0f \ ///
		wells_surg bin %4.0f \ ///
		wells_immobility bin %4.0f \ ///
		recent_cvc bin %4.0f \ ///
		curr_preg bin %4.0f \ ///
		curr_estr bin %4.0f \ ///
		pesi_pe conts %4.0f \ ///
		highest_hr conts %4.2f \ ///
		lowest_sbp conts %4.2f \ ///
		lowest_dbp conts %4.2f \ ///
		lowest_map conts %4.2f \ ///
		max_resp cat %4.0f \ ///
		troponin_max conts %4.2f \ ///
		bnp_max conts %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ED only - phys by splenectomy.xlsx", replace)
		

/* 
Outcomes: 
*/ 
		
table1_mc, by(splenectomy) ///
		vars( ///
		apl_ab bin %4.0f \ ///
		lupus_ac bin %4.0f \ ///
		factor_viii bin %4.0f \ ///
		non_o_blood bin %4.0f \ ///
		anticoagulated bin %4.0f \ ///
		tpa bin %4.0f \ ///
		ivc_filter bin %4.0f \ ///
		mechanical_tx bin %4.0f \ ///
		no_treatment bin %4.0f \ ///
		admissionlocation cat %4.0f \ ///
		hospitallosdays conts %4.0f \ ///
		iculos conts %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/outcomes by splenectomy.xlsx", replace)

table1_mc if ed_encounter, by(splenectomy) ///
		vars( ///
		apl_ab bin %4.0f \ ///
		lupus_ac bin %4.0f \ ///
		factor_viii bin %4.0f \ ///
		non_o_blood bin %4.0f \ ///
		anticoagulated bin %4.0f \ ///
		tpa bin %4.0f \ ///
		ivc_filter bin %4.0f \ ///
		mechanical_tx bin %4.0f \ ///
		no_treatment bin %4.0f \ ///
		admissionlocation cat %4.0f \ ///
		hospitallosdays conts %4.0f \ ///
		iculos conts %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ED Only - outcomes by splenectomy.xlsx", replace)		
		
		
		
		
/* Analyses: 

"We have now gotten through the secondary data and added things as you requested for each group (Age, sex, BMI should be there for all pts and made the chronic changes into a 1 or 0 variable).   Also moved the excluded splenectomy patients to a different tab.  "

- Age, gender, BMI first ; subsequent analysis may include  - 

- Race/ethnicity
- Presence/absence of provoking factors for PE or CTEPH
- Cancer, immobility/injury within 30d, surgery within 30d, clotting d/o, chf, chronic lung dz, afib, pregnancy, estrogen use, obesity, CVC (central or picc line) presence within 30d), thyroid disease, prior VTE of any kind, antiphospholipid ab, lupus anticoagulant, factor VIII level if present, non-O blood group,  inflammatory bowel disease)
- DVT present, absent, or unknown based on chart records within 1 week of incident event.  
- VS related to PE hospitalization, PESI score at dx
- Hospital admission location, LOS in ICU and hospital
- PE therapy received
- RV strain on CTA
- Highest BNP and trop during hospitalization
- Echo findings/RHC findings with PH
- Eventual diagnosis of CTEPH, CTED or chronic PE on imaging
- History of splenectomy (as well as age at splenectomy and indication for it if present)
- Estrogen use

*/ 
		

	  
	  /* 
	  Visualize Distributions of Continuous Variables by Splenectomy Status 
	  */ 
	  
//Association between splenectomy and quanadli average
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


// pesi_pe "PESI"
twoway kdensity pesi_pe if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(10) range(0 240) || ///
kdensity pesi_pe if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(10) range(0 240) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0(40)240, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("PESI", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("PESI Score by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/PESI by Splenectomy Status.png", as(png) name("Graph") replace 

//and only ED 
twoway kdensity pesi_pe if splenectomy == 0 & ed_encounter, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(10) range(0 240) || ///
kdensity pesi_pe if splenectomy == 1 & ed_encounter, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(10) range(0 240) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0(40)240, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("PESI", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("PESI Score by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/ED only - PESI by Splenectomy Status.png", as(png) name("Graph") replace 

// PA diameter
twoway kdensity pa_d if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(2.5) range(10 45) || ///
kdensity pa_d if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(2.5) range(10 45) ||, ///
legend(pos(10) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(medlarge)) ///
xlabel(10(5)45, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("PA Diameter (mm)", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("PA Diameter by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/PA Diameter by Splenectomy Status.png", as(png) name("Graph") replace 

//PA:AA
twoway kdensity pa_aa if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(.05) range(0.5 1.5) || ///
kdensity pa_aa if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(.05) range(0.5 1.5) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0.5(.1)1.5, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("PA:AA Ratio", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("Pulm Artery to Ascending Aorta ratio, by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/PA to AA by Splenectomy Status.png", as(png) name("Graph") replace

//only ed
twoway kdensity pa_aa if splenectomy == 0 & ed_encounter, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(.05) range(0.5 1.5) || ///
kdensity pa_aa if splenectomy == 1 & ed_encounter, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(.05) range(0.5 1.5) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0.5(.1)1.5, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("PA:AA Ratio", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("Pulm Artery to Ascending Aorta ratio, by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/ED-only PA to AA by Splenectomy Status.png", as(png) name("Graph") replace


// variable hospitallosdays	"Hospital LOS"
twoway kdensity hospitallosdays if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(5) range(0 60) || ///
kdensity hospitallosdays if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(5) range(0 60) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0(10)60, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("Hospital LOS", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("Hospital LOS by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/Hospital LOS by Splenectomy Status.png", as(png) name("Graph") replace 

// iculos "ICU LOS"
twoway kdensity iculos if splenectomy == 0, recast(area) fcolor(navy%05) lcolor(navy) lpattern(solid) lwidth(*2.5) bwidth(2.5) range(0 30) || ///
kdensity iculos if splenectomy == 1, recast(area) fcolor(erose%05) lcolor(cranberry) lpattern(solid)  lwidth(*2.5) bwidth(2.5) range(0 30) ||, ///
legend(pos(2) ring(0) order(1 "No Splenectomy" 2 "Splenectomy") rows(2) size(large)) ///
xlabel(0(5)30, labsize(large)) ///
ylabel(0, labsize(large)) ///
xtitle("ICU LOS", size(medlarge)) ///
ytitle("Relative Frequency", size(medlarge)) ///
title("ICU LOS by Splenectomy Status", size(large)) ///
xsize(7) ///
ysize(5) ///
scheme(white_tableau)
graph export "Results and Figures/$S_DATE/ICU LOS by Splenectomy Status.png", as(png) name("Graph") replace 




/* 
Main Analyses 
*/ 


//Using poisson - because Qanadli score is actually a proportion (of possible occluded segments)
poisson qanadli splenectomy, irr //interpretation: patients with splenectomy have 0.84x [0.42-1.68] of non-splenectomy

poisson qanadli splenectomy if ed_encounter, irr // no diff if ED only

poisson qanadli splenectomy age male_sex bmi_pe, irr //similar accounting for age, sex, bmi
estimates store qanadli
poisson qanadli splenectomy age male_sex bmi_pe if ed_encounter, irr //no change


//Chi2 of binary association.
cs peripheral splenectomy //Gives absolute association: those with splenectomy are 17.9% [1.3-34.5%] more likely to have peripheral PE

cs peripheral splenectomy if ed_encounter //no longer significant, directionally similar

logistic peripheral splenectomy
logistic peripheral splenectomy if ed_encounter
logistic peripheral splenectomy age male_sex bmi_pe
estimates store peripheral
logistic peripheral splenectomy age male_sex bmi_pe if ed_encounter


// admissionlocation "Admit Location"
//catplot


// bnp_max "BNP (max)"
//log transform

// troponin_max "Troponin (max)"
//log transform

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

coefplot peripheral, eform ///
drop(_cons) ///
xline(1) ///
xlabel(0.25 0.5 1 2 4 8, labsize(large)) ///
xscale(log range(0.25 4 8) extend) ///
xtitle("Odds ratio of Peripheral PE" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.2f") + " [ " + string(@ll,"%9.2f") + " - " + string(@ul,"%9.2f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/Peripheral Logistic Regression.png", as(png) name("Graph") replace




/* PA Size Indices */ 
regress pa_d splenectomy age male_sex bmi_pe
estimates store regress_pa_d
regress pa_d splenectomy age male_sex bmi_pe if ed_encounter

coefplot regress_pa_d, ///
drop(_cons) ///
xline(0) ///
xlabel(-2(1)2, labsize(large)) ///
xscale(range(-3 3) extend) ///
xtitle("Change in PA diameter (mm)" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.2f") + " [ " + string(@ll,"%9.2f") + " - " + string(@ul,"%9.2f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/PA_d linear Regression.png", as(png) name("Graph") replace

regress pa_aa splenectomy age male_sex bmi_pe
estimates store regress_pa_aa
regress pa_aa splenectomy age male_sex bmi_pe if ed_encounter

coefplot regress_pa_aa, ///
drop(_cons) ///
xline(0) ///
xlabel(-.1(0.05).1, labsize(large)) ///
xscale(range(-.12 .12) extend) ///
xtitle("Change in PA:AA ratio (mm)" , size(large)) yscale(extend) ///
ylabel(, labsize(large)) ///
ciopts(recast(rcap) ///
lwidth(thick)) ///
mlabel(string(@b,"%9.3f") + " [ " + string(@ll,"%9.3f") + " - " + string(@ul,"%9.3f") + " ] " + cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", "")))) ///
mlabsize(medsmall) ///
mlabposition(12) ///
mlabgap(*1) ///
scheme(white_tableau) 
graph export "Results and Figures/$S_DATE/PA_AA linear Regression.png", as(png) name("Graph") replace




/* Not utilized as not confident enough in the ratings, particularly subjective */ 

//chronic changes

tab splenectomy chronic_changes, row
logistic chronic_changes splenectomy
logistic chronic_changes splenectomy age male_sex
logistic chronic_changes splenectomy age male_sex bmi_pe
estimates store chronic_changes

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

