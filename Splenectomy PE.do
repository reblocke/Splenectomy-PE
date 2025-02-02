/* 
Splenectomy PE 

Analytic Code

Brian W Locke MD MSCI


//TODO: for darren
Couple data cleaning requests - just so that I don't have to rewrite the data cleaning code if you make further updates. 

- for the PE after splenectomy group - make a separate spreadsheet for the ones you want excluded vs included (rather than having )
- chronic changes in after splenectomy group - reconcile these? e.g. currently there are a variety of answers but deciding which are yes and which are know will allow them to be analyzed (if wanted)
- ages make into numerical (not a mix of numbers and number+yo)
- need sex in both groups
- need bmi in the no splenectomy group 




Main: 

peripheral vs central PE

secondary: restricting to only Emergency

Ignore chronic changes. 


*/ 



capture log close

* Load data
clear

//cd "C:\Users\reblo\Box\Residency Personal Files\Scholarly Work\Locke Research Projects\Splenectomy-PE\"
//cd "/Users/blocke/Box Sync/Residency Personal Files/Scholarly Work/Locke Research Projects/Splenectomy-PE"
cd "/Users/reblocke/Research/Splenectomy-PE"


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

//Splenectomy: procedure_dt procedure_dsp 
//PE: pe_diagnosis_dt_reviseddw (= same?) radiologydescription dweval

//TODO: Calculate time from Procedure_dt to pe_diagnosis_dt

//Echo params: ef la_area septalflatteneningonecho rvsp pvacceltime trvelocity_initial tapse_initial rvbasaldiameter_initial raarea_initial presenceofeffusiononecho
//workup: antiphospholipidab lupusanticoagulant factorviii nonobloodgroup 
//setting: pediagnosissettingoutptinp edpedx1yes
//Outcomes: petherapyactpamechanical



import excel "PE after splenectomy.xlsx", sheet("Included patients") firstrow case(lower)

drop if missing(pe_diagnosis_dt)  // drop rows not corresponding to a pt 

keep age_peyears centraldarrensreview qanadlifinal centralmarksreview marksqanadli malegender1yes0no chronicchanges1yes0no bmi_pe raceethnicity pesi_pe admissionlocation hospitallosdays iculos bnp_max troponin_max rightheartstrain dilatedpulmartery rvlvratio_initial1abnormal padiametermm aorticdiametermm paa paenlargement1yes0no2 increasedpaa09 paenlargementorincreasedpaa hxofpriorpedvt hxofpriorthrombosispvtcva highesthr_pe lowestbp_pemap o2max_pe malignancy immobilityinjurywithin30d surgerywithin30d sicklecell  clottingdisorder chf chroniclungdisease afib pregnancy estrogenuse obesity cvcwithin30d thyroiddisease inflammatoryboweldisease

destring chronicchanges1yes0no, replace
rename age_peyears age 
destring age, replace 
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
//pesi_pe - already int
//admissionlocation - string; make categories later.
replace hospitallosdays = 0 if missing(hospitallosdays)
replace iculos = 0 if missing(iculos)
replace bnp_max = "0" if bnp_max == "<10"
destring bnp_max, replace force
replace troponin_max = "0" if troponin_max == "<0.02"
replace troponin_max = "0" if troponin_max == "<0.01"
destring troponin_max, replace force
replace paenlargement1yes0no2 = 0 if missing(paenlargement1yes0no2)
replace increasedpaa09 = 0 if missing(increasedpaa09)
replace paenlargementorincreasedpaa = 0 if missing(paenlargementorincreasedpaa)

save splenectomy, replace
clear


//nusance variables: id ctreport ctimageavailable  central1yes  dwanalysis k fupedata q br bs bt bu
//  marklocation has finer substitution, k is binary rating
// comments  mostly about if they died or not.


//date: pe_diagnosis_dt_reviseddw


//antiphospholipidab lupusanticoagulant factorviii nonobloodgroup 

//comorbidities: sicklecell    clottingdisorder chf chroniclungdisease afib pregnancy estrogenuse obesity cvcwithin30d thyroiddisease  inflammatoryboweldisease 

//wells: 

//echo ef la_volumemlm2 septalflatteneningonecho rvsp pvacceltime trvelocity_initialms tapse_initial rvbasaldiameter_initial raarea_initialcm2 presenceofeffusiononecho

//course: petherapyactpamechanical 


//done
//patient chars: ethnicity 
//vitals bnp_max troponin_maxngml pesi_pe rightheartstrain dilatedpulmartery rvlvratio_initial1abnormal
//setting: admissionlocation 
//outcomes: deathreported [don't have for ED?] hospitallosdays iculos 



import excel "PE without splenectomy.xlsx", sheet("Sheet1") firstrow case(lower)
drop if missing(pe_diagnosis_dt) // drop rows not corresponding to a pt 

keep age_peyears dwpelocation dwqanadli marklocation markqanadli malegender1yes0no chronicchanges bmi_pe ethnicity pesi_pe admissionlocation hospitallosdays iculos bnp_max troponin_max rightheartstrain dilatedpulmartery rvlvratio_initial1abnormal padiametermm aorticdiametermm paa paenlargement1yes0no2 increasedpaa09 paenlargementorincreasedpaa hxofpriorpedvt hxofpriorthrombosispvtcva highesthr_pe lowestbp_pemap o2max_pe malignancy immobilityinjurywithin30d surgerywithin30d sicklecell  clottingdisorder chf chroniclungdisease afib pregnancy estrogenuse obesity cvcwithin30d thyroiddisease inflammatoryboweldisease

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
//pesi_pe - already int
//admissionlocation - string; make categories later.
replace hospitallosdays = 0 if missing(hospitallosdays)
replace iculos = 0 if missing(iculos)
replace bnp_max = "0" if bnp_max == "<10"
destring bnp_max, replace force
rename troponin_maxngml troponin_max
replace troponin_max = "0" if troponin_max == "<0.02"
replace troponin_max = "0" if troponin_max == "<0.01"
destring troponin_max, replace force
replace paenlargement1yes0no2 = 0 if missing(paenlargement1yes0no2)
replace increasedpaa09 = 0 if missing(increasedpaa09)
replace paenlargementorincreasedpaa = 0 if missing(paenlargementorincreasedpaa)
destring highesthr_pe, replace force
replace lowestbp_pemap = "" if lowestbp_pemap == "arrest"

save no_splenectomy, replace

append using splenectomy.dta


//Variable Defintions

label define binary_lab 0 "no" 1 "yes"

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
label variable pesi_pe "PESI"
label variable admissionlocation "Admit Location"
label variable hospitallosdays	"Hospital LOS"
label variable iculos "ICU LOS"
label variable bnp_max "BNP (max)"
label variable troponin_max "Troponin (max)"

rename padiametermm pa_d 
label variable pa_d "Pulm Art diameter (mm)"
rename aorticdiametermm aa_d
label variable aa_d "Asc Aorta diameter (mm)"
rename paa pa_aa 
label variable pa_aa "PA to AA ratio"
rename paenlargement1yes0no2 pa_enlarged
label variable pa_enlarged "PA Enlarged? (>27 mm fem; >29 mm male)"
rename increasedpaa09 high_pa_aa 
label variable high_pa_aa "PA:AA > 0.9?"
rename paenlargementorincreasedpaa pa_enlarged_by_d_or_ratio
label variable pa_enlarged_by_d_or_ratio "PA Enlargment by diam or ratio?"


//Data cleaning
replace admissionlocation = "ICU" if admissionlocation == "Neuro ICU"
replace admissionlocation = "ICU" if admissionlocation == "STICU"
replace admissionlocation = "Outpatient" if admissionlocation == "ED discharge"
replace admissionlocation = "Outpatient" if admissionlocation == "no admission document"
replace admissionlocation = "OSH" if admissionlocation == "Admitted OSH"
replace admissionlocation = "Ward" if admissionlocation == "Medicine Wards"
replace admissionlocation = "Ward" if admissionlocation == "Cardiology Wards"
replace admissionlocation = "Ward" if admissionlocation == "Medcine Wards"
replace admissionlocation = "Ward" if admissionlocation == "Medicine Wards "
replace admissionlocation = "Ward" if admissionlocation == "Neuro Wards"
replace admissionlocation = "Ward" if admissionlocation == "Trauma Surgery"

replace rightheartstrain = lower(strtrim(rightheartstrain))
replace rightheartstrain = "" if rightheartstrain == "n/a"
replace rightheartstrain = "yes" if rightheartstrain == "mild"
gen rightheartstrain_binary = .
replace rightheartstrain_binary = 1 if rightheartstrain == "yes"
replace rightheartstrain_binary = 0 if rightheartstrain == "no"
drop rightheartstrain
rename rightheartstrain_binary rightheartstrain
label variable rightheartstrain "R Heart Strain? (CT)"

replace hxofpriorpedvt = "yes" if hxofpriorpedvt == "DVT"
replace hxofpriorpedvt = "yes" if lower(substr(hxofpriorpedvt, 1, 3)) == "yes"
gen prior_pe_dvt = 0 
replace prior_pe_dvt = 1 if hxofpriorpedvt == "yes"
label variable prior_pe_dvt "Prior PE or DVT?"
drop hxofpriorpedvt

replace hxofpriorthrombosispvtcva = "yes" if lower(substr(hxofpriorthrombosispvtcva, 1, 3)) == "yes"
gen prior_other_vte = 0 
replace prior_other_vte = 1 if hxofpriorthrombosispvtcva == "yes"
label variable prior_other_vte "Prior Other VTE? (PVT, SMV)"
drop hxofpriorthrombosispvtcva

replace malignancy = "no" if strpos(malignancy, "poss") > 0  //no confirmed
replace malignancy = "yes" if lower(substr(malignancy, 1, 3)) == "yes"
gen active_malig = 0 
replace active_malig = 1 if malignancy == "yes" 
drop malignancy
label variable active_malig "Malignancy"

replace immobilityinjurywithin30d  = "yes" if lower(substr(immobilityinjurywithin30d , 1, 3)) == "yes"
gen wells_immobility = . 
replace wells_immobility = 0 if immobilityinjurywithin30d  == "no" 
replace wells_immobility = 1 if immobilityinjurywithin30d  == "yes" 
drop immobilityinjurywithin30d 
label variable wells_immobility "Injury/Immobility w/n 30d"

replace surgerywithin30d   = "yes" if lower(substr(surgerywithin30d, 1, 3)) == "yes"
gen wells_surg = . 
replace wells_surg = 0 if surgerywithin30d == "no" 
replace wells_surg = 1 if surgerywithin30d == "yes" 
drop surgerywithin30d 
label variable wells_surg "Surgery w/n 30d"

replace sicklecell = strtrim(sicklecell)
encode sicklecell, label(binary_lab) generate(sickle_cell)
drop sicklecell
label variable sickle_cell "Sickle Cell"

replace clottingdisorder = strtrim(clottingdisorder)
replace clottingdisorder = "yes" if lower(substr(clottingdisorder, 1, 3)) == "yes"
replace clottingdisorder = "yes" if lower(substr(clottingdisorder, 1, 3)) == "fac"
replace clottingdisorder = "yes" if lower(substr(clottingdisorder, 1, 3)) == "itp"
encode clottingdisorder, label(binary_lab) generate(clotting_disorder)
drop clottingdisorder
label variable clotting_disorder "Clotting Disorder (including ITP, AIHA)"

gen chf_temp = strtrim(chf)
drop chf
encode chf_temp, label(binary_lab) generate(chf)
drop chf_temp
label variable chf "Congestive Heart Failure"

replace chroniclungdisease = strtrim(chroniclungdisease)
replace chroniclungdisease = "yes" if lower(substr(chroniclungdisease, 1, 3)) == "yes"
replace chroniclungdisease = "yes" if lower(substr(chroniclungdisease, 1, 3)) == "pul"
encode chroniclungdisease, label(binary_lab) generate(chronic_lung)
drop chroniclungdisease
label variable chronic_lung "Chronic Lung Disease (inc. asthma, OSA, etc.)"

replace afib = strtrim(afib)
encode afib, label(binary_lab) generate(a_fib)
drop afib
label variable a_fib "Atrial Fibrillation"

replace pregnancy = strtrim(pregnancy)
encode pregnancy, label(binary_lab) generate(curr_preg)
drop pregnancy 
label variable curr_preg "Current Pregnancy"

replace estrogenuse = strtrim(estrogenuse)
encode estrogenuse, label(binary_lab) generate(curr_estr)
drop estrogenuse 
label variable curr_estr "Current Exogenous Estrogen Use"

replace obesity = strtrim(obesity)
encode obesity, label(binary_lab) generate(obesity_dx)
drop obesity
label variable obesity_dx "Obesity diagnosis"

replace cvcwithin30d = strtrim(cvcwithin30d)
encode cvcwithin30d, label(binary_lab) generate(recent_cvc)
drop cvcwithin30d
label variable recent_cvc "Recent Central Line (30d)"

replace thyroiddisease = strtrim(thyroiddisease)
replace thyroiddisease = "no" if thyroiddisease == "on"
replace thyroiddisease = "yes" if lower(substr(thyroiddisease, 1, 3)) == "yes"
encode thyroiddisease, label(binary_lab) generate(thyroid_dz)
drop thyroiddisease
label variable thyroid_dz "Thyroid Disease"

replace inflammatoryboweldisease = strtrim(inflammatoryboweldisease)
replace inflammatoryboweldisease = "no" if lower(substr(inflammatoryboweldisease, 1, 3)) == "sus"
encode inflammatoryboweldisease, label(binary_lab) generate(ibd)
drop inflammatoryboweldisease
label variable ibd "Inflammatory Bowel Disease"


rename highesthr_pe highest_hr 
label variable highest_hr "Highest Heart Rate"

replace o2max_pe = lower(o2max_pe)
replace o2max_pe = "Vent" if strpos(o2max_pe, "vent") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "vent") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "hfnc") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "nrb") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "pap") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "mask") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "fio2") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "10l") > 0 
replace o2max_pe = "NIV, HFNC, Facemask" if strpos(o2max_pe, "15l") > 0 
replace o2max_pe = regexr(o2max_pe, "\(.+\)$", "") // remove parentheses
replace o2max_pe = "1l" if o2max_pe == "1"
replace o2max_pe = "2l" if o2max_pe == "2"
replace o2max_pe = "2l" if o2max_pe == "2.5l"
replace o2max_pe = "3l" if o2max_pe == "3"
replace o2max_pe = "3l" if o2max_pe == "2-3l"
replace o2max_pe = "4l" if o2max_pe == "4l "
replace o2max_pe = "4l" if o2max_pe == "4"
replace o2max_pe = "6l" if o2max_pe == "5-6l"
replace o2max_pe = "0l (RA)" if o2max_pe == "ra"
encode o2max_pe, generate(max_resp)
drop o2max_pe
label variable max_resp "Max Respiratory Support"

replace lowestbp_pemap = regexr(lowestbp_pemap , "\(.+\)$", "") // remove parentheses
gen sbp_str = substr(lowestbp_pemap, 1, strpos(lowestbp_pemap, "/") - 1)
destring sbp_str, generate(lowest_sbp) force
gen dbp_str = substr(lowestbp_pemap, strpos(lowestbp_pemap, "/") + 1, .)
destring dbp_str, generate(lowest_dbp) force
gen lowest_map = (lowest_sbp/3)+(2*lowest_dbp/3)
drop lowestbp_pemap sbp_str dbp_str
label variable lowest_sbp "Lowest Sys. BP (mmHg)"
label variable lowest_dbp "Lowest Dia. BP (mmHg)"
label variable lowest_map "Lowest MAP (mmHg)"

replace dilatedpulmartery = lower(strtrim(dilatedpulmartery))
replace dilatedpulmartery = "" if dilatedpulmartery == "n/a"
replace dilatedpulmartery = "" if dilatedpulmartery == "not listed"
replace dilatedpulmartery = "yes" if substr(dilatedpulmartery, 1, 4) == "mild"
replace dilatedpulmartery = "yes" if substr(dilatedpulmartery, 1, 3) == "yes"
replace dilatedpulmartery = "yes" if dilatedpulmartery == "borderline"
replace dilatedpulmartery = "yes" if substr(dilatedpulmartery, 1, 3) == "sev"
gen dilatedpulmartery_binary = .
replace dilatedpulmartery_binary = 1 if dilatedpulmartery == "yes"
replace dilatedpulmartery_binary = 0 if dilatedpulmartery == "no"
drop dilatedpulmartery
rename dilatedpulmartery_binary dilatedpulmartery
label variable dilatedpulmartery "Dilated PA on CT?"

//normal RV:LV < 1

replace rvlvratio_initial1abnormal = lower(strtrim(rvlvratio_initial1abnormal))
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "n/a"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "not listed"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "not measured"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "indeterminate"
replace rvlvratio_initial1abnormal = "0.9" if rvlvratio_initial1abnormal == "<1"
replace rvlvratio_initial1abnormal = "1.1" if rvlvratio_initial1abnormal == ">1"
destring rvlvratio_initial1abnormal, replace force
gen rvlvratio_initial1abnormal_bin = .
replace rvlvratio_initial1abnormal_bin = 1 if !missing(rvlvratio_initial1abnormal) & rvlvratio_initial1abnormal > 1
replace rvlvratio_initial1abnormal_bin = 0 if !missing(rvlvratio_initial1abnormal) &rvlvratio_initial1abnormal < 1
drop rvlvratio_initial1abnormal
rename rvlvratio_initial1abnormal_bin rvlvratio_initial1abnormal
label variable rvlvratio_initial1abnormal "Abnormal RV:LV?"



//Generate Average of raters vars
* Create a new variable "qanadli" that is the average of "qanadli_mark" and "qanadli_darren"
generate qanadli = (qanadli_mark + qanadli_darren) / 2
label variable qanadli "Qanadli Score (Avg)"

//if either called central, call it central
generate central = 0
replace central = 1 if central_darren == 1 | central_mark == 1
label variable central "Central? (either rater)"

recode central (0=1) (1=0), generate(peripheral)
label variable peripheral "Peripheral PE"

save full_db, replace
export excel using "cleaned_splenectomy_pe_data.xlsx", replace firstrow(variables)
//use subsample_db_5_perc
cd ..





/* Analysis */ 



//Baseline Characteristics, by spelenectomy status

/* Add past medical history, etc. */ 


table1_mc, by(splenectomy) ///
		vars( ///
		age contn %4.0f \ ///
		male_sex bin %4.0f \ ///
		raceethnicity cat %4.0f \ ///
		bmi_pe conts %4.1f \ ///
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
	
	
bysort obesity_dx: summ bmi_pe, detail
	
		
// PE/Physiologic  Characteristics: 

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
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/pe chars by splenectomy.xlsx", replace)
		
				// dilatedpulmartery bin %4.0f \ /// - not sure what this one is about. Comment in report?

//Very high rates of enlargment. 				
logistic high_pa_aa male age splenectomy, or //controlling for age, sex actually makes more dramatic.
				
				
		
// Acute Illness characteristics:
table1_mc, by(splenectomy) ///
		vars( ///
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
		rightheartstrain bin %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/phys tte by splenectomy.xlsx", replace)


// Outcomes: 
		
table1_mc, by(splenectomy) ///
		vars( ///
		admissionlocation cat %4.0f \ ///
		hospitallosdays conts %4.0f \ ///
		iculos conts %4.0f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/outcomes by splenectomy.xlsx", replace)

		
		
		
		
//Patient chars

// [ ] add prior PE etc? 


//Presentation chars

//add wells?


//PE chars


//Outcomes		

//add therapy? 


*** Correcting for illness severity = PESI-adjusted?
		
		
		
//Kappa Score of Agreement
kap central_darren central_mark, tab
pvenn2 central_darren central_mark, plabel("Darren_Central" "Mark_Central") title("Agreement in Central Determination")
graph export "Results and Figures/$S_DATE/Overlap in Central Assessments.png", as(png) name("Graph") replace 

//Correlation between quanadli scores
corr qanadli_mark qanadli_darren

table1_mc, by(splenectomy) ///
		vars( ///
		central_darren bin %4.0f \ ///
		central_mark bin %4.0f \ ///
		qanadli_darren conts %4.2f \ ///
		qanadli_mark conts %4.2f \ ///
		) ///
		total(before) percent_n percsign("%") iqrmiddle(",") sdleft(" (±") sdright(")") missing onecol test saving("Results and Figures/$S_DATE/ratings mark darren by splenectomy.xlsx", replace)

//TODO: actually probably want agreement? 

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



//Association between splenectomy and quanadli average - decide on method

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

logistic peripheral splenectomy
logistic peripheral splenectomy age male_sex
logistic peripheral splenectomy age male_sex bmi_pe
estimates store peripheral




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



// admissionlocation "Admit Location"
//catplot


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

/* Used for abstract */ 

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




