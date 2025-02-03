/* 
Splenectomy PE 

Analytic Code

Brian W Locke MD MSCI

Data cleaning notes: 

- la_area (splenectomy) vs la_volumelm2 (in no splenectomy) - ignored for now
- No PV-acceleration times found in the non splenectomy
- very high rates of PA enlargment (by PAd or PA:AA) compared to Scarpato's paper - presumably owing to the active PEs. Not sure if there's data to reference here. 
- Do we really want to count ITP and AIHA as clotting disorders? 

*/ 

capture log close

* Load data
clear

//cd "/Users/blocke/Box Sync/Residency Personal Files/Scholarly Work/Locke Research Projects/Splenectomy-PE"
cd "/Users/reblocke/Research/Splenectomy-PE"

capture mkdir "Results and Figures"
capture mkdir "Results and Figures/$S_DATE/" //make new folder for figure output if needed
capture mkdir "Results and Figures/$S_DATE/Logs/" //new folder for stata logs

/* Set up Do File Back-up*/ 
local a1=substr(c(current_time),1,2)
local a2=substr(c(current_time),4,2)
local a3=substr(c(current_time),7,2)
local b = "Splenectomy PE data cleaning.do" // do file name
copy "`b'" "Results and Figures/$S_DATE/Logs/(`a1'_`a2'_`a3')`b'"

set scheme cleanplots
graph set window fontface "Helvetica"
log using temp.log, replace


/* Import Data and Reconcile/Combine Spreadsheets */ 

clear
cd "Data"

import excel "PE after splenectomy.xlsx", sheet("Included patients") firstrow case(lower)

drop if missing(pe_diagnosis_dt)  // drop rows not corresponding to a pt 

keep age_peyears centraldarrensreview qanadlifinal centralmarksreview marksqanadli malegender1yes0no chronicchanges1yes0no bmi_pe raceethnicity pesi_pe admissionlocation hospitallosdays iculos bnp_max troponin_max rightheartstrain dilatedpulmartery rvlvratio_initial1abnormal padiametermm aorticdiametermm paa paenlargement1yes0no2 increasedpaa09 paenlargementorincreasedpaa hxofpriorpedvt hxofpriorthrombosispvtcva highesthr_pe lowestbp_pemap o2max_pe malignancy immobilityinjurywithin30d surgerywithin30d sicklecell  clottingdisorder chf chroniclungdisease afib pregnancy estrogenuse obesity cvcwithin30d thyroiddisease inflammatoryboweldisease ef septalflatteneningonecho rvsp pvacceltime trvelocity_initial tapse_initial rvbasaldiameter_initial raarea_initial presenceofeffusiononecho antiphospholipidab lupusanticoagulant factorviii nonobloodgroup pediagnosissettingoutptinp edpedx1yes petherapyactpamechanical procedure_dt pe_diagnosis_dt_reviseddw

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
replace edpedx1yes = 0 if missing(edpedx1yes)
gen years_since_splenectomy = (pe_diagnosis_dt_reviseddw - procedure_dt) / 365.25
drop procedure_dt

save splenectomy, replace
clear

import excel "PE without splenectomy.xlsx", sheet("Sheet1") firstrow case(lower)
drop if missing(pe_diagnosis_dt) // drop rows not corresponding to a pt 

keep age_peyears dwpelocation dwqanadli marklocation markqanadli malegender1yes0no chronicchanges bmi_pe ethnicity pesi_pe admissionlocation hospitallosdays iculos bnp_max troponin_max rightheartstrain dilatedpulmartery rvlvratio_initial1abnormal padiametermm aorticdiametermm paa paenlargement1yes0no2 increasedpaa09 paenlargementorincreasedpaa hxofpriorpedvt hxofpriorthrombosispvtcva highesthr_pe lowestbp_pemap o2max_pe malignancy immobilityinjurywithin30d surgerywithin30d sicklecell  clottingdisorder chf chroniclungdisease afib pregnancy estrogenuse obesity cvcwithin30d thyroiddisease inflammatoryboweldisease ef septalflatteneningonecho rvsp pvacceltime trvelocity_initial tapse_initial rvbasaldiameter_initial raarea_initial presenceofeffusiononecho antiphospholipidab lupusanticoagulant factorviii nonobloodgroup petherapyactpamechanical pe_diagnosis_dt_reviseddw

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
rename trvelocity_initialms trvelocity_initial 
rename raarea_initialcm2 raarea_initial
gen edpedx1yes = 1

save no_splenectomy, replace

append using splenectomy.dta


//Variable Defintions
label define binary_lab 0 "no" 1 "yes"
label define male_lab 0 "Female" 1 "Male"
label define splenectomy_lab 0 "No Splenectomy" 1 "Splenectomy"
label variable age "Age (years)"
label variable male_sex "Male Sex"
label values male_sex male_lab
label variable qanadli_darren "Qanadli [DW]"
label variable qanadli_mark "Qanadli [MD]"
label variable central_darren "Central PE [DW]"
label variable central_mark "Central PE [MD]"
label variable splenectomy "Splenectomy"
label variable chronic_changes "Chronic Changes on Imaging"
label values splenectomy splenectomy_lab
label variable bmi_pe "BMI"
label variable raceethnicity "Race/Ethnicity"
label variable pesi_pe "PESI"
label variable admissionlocation "Admit Location"
label variable hospitallosdays	"Hospital LOS"
label variable iculos "ICU LOS"
label variable bnp_max "BNP (max)"
label variable troponin_max "Troponin (max)"
label variable years_since_splenectomy "Years between Splenectomy and PE"

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

rename pe_diagnosis_dt_reviseddw pe_date
label variable pe_date "PE Date"

//Data cleaning / categorizing
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

replace rvlvratio_initial1abnormal = lower(strtrim(rvlvratio_initial1abnormal))
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "n/a"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "not listed"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "not measured"
replace rvlvratio_initial1abnormal = "" if rvlvratio_initial1abnormal == "indeterminate"
replace rvlvratio_initial1abnormal = "0.9" if rvlvratio_initial1abnormal == "<1" //normal RV:LV < 1
replace rvlvratio_initial1abnormal = "1.1" if rvlvratio_initial1abnormal == ">1"
destring rvlvratio_initial1abnormal, replace force
gen rvlvratio_initial1abnormal_bin = .
replace rvlvratio_initial1abnormal_bin = 1 if !missing(rvlvratio_initial1abnormal) & rvlvratio_initial1abnormal > 1
replace rvlvratio_initial1abnormal_bin = 0 if !missing(rvlvratio_initial1abnormal) &rvlvratio_initial1abnormal < 1
drop rvlvratio_initial1abnormal
rename rvlvratio_initial1abnormal_bin rvlvratio_initial1abnormal
label variable rvlvratio_initial1abnormal "Abnormal RV:LV?"

//echo params
destring ef, replace force
rename ef lvef
label variable lvef "Left Ventricular Ejection Fraction (%)"

replace septalflatteneningonecho = "" if septalflatteneningonecho == "n/a"
replace septalflatteneningonecho = "" if septalflatteneningonecho == "not found"
encode septalflatteneningonecho, label(binary_lab) generate(septal_flattening) noextend
drop septalflatteneningonecho

//TR jet - two variables: insufficient TR jet to measure, and the measurement if made
replace rvsp = lower(strtrim(rvsp))
replace rvsp = regexr(rvsp, " mmhg$", "")
gen insuff_tr_jet_for_rvsp = 1 if !missing(rvsp) //if any value in original rvsp
destring rvsp, replace force
replace insuff_tr_jet_for_rvsp = 0 if !missing(rvsp) //if no numeric
label values insuff_tr_jet_for_rvsp binary_lab
label variable rvsp "Right Ventricular Systolic Pressure (mmHg) on Echo"
label variable insuff_tr_jet_for_rvsp "Insufficient TR Jet to Estimate RVSP"

//same for pa_accell
replace pvacceltime = lower(strtrim(pvacceltime))
replace pvacceltime = regexr(pvacceltime, " msec$", "")
gen unmeasured_pv_accel_time = 1 if !missing(pvacceltime)
destring pvacceltime, replace force
replace unmeasured_pv_accel_time = 0 if !missing(pvacceltime)
rename pvacceltime pv_accel_time
label values unmeasured_pv_accel_time  binary_lab
label variable pv_accel_time "PV Acceleration Time (msec) on Echo"
label variable unmeasured_pv_accel_time "Unmeasured PV Accel Time"

//and trvelocity
replace trvelocity_initial = lower(strtrim(trvelocity_initial))
replace trvelocity_initial = regexr(trvelocity_initial, " m/s$", "")
//manual replacements for severe? one severe and one mild
gen unmeasured_tr_vel = 1 if !missing(trvelocity_initial)
destring trvelocity_initial, replace force
replace unmeasured_tr_vel = 0 if !missing(trvelocity_initial)
rename trvelocity_initial tr_velocity
label values unmeasured_tr_vel binary_lab
label variable tr_velocity "TR Jet Velocity (m/s) on Echo"
label variable unmeasured_tr_vel "Unquantified TR Velocity"

//and tapse
gen unmeasured_tapse = 1 if !missing(tapse_initial)
destring tapse_initial, replace force
replace unmeasured_tapse = 0 if !missing(tapse_initial)
rename tapse_initial tapse
label values unmeasured_tapse binary_lab
label variable tapse "TAPSE (cm) on Echo"
label variable unmeasured_tapse "Unmeasured TAPSE"

//rvbasal diam stay categorical
replace rvbasaldiameter_initial = regexr(rvbasaldiameter_initial, ", not measured", "")
replace rvbasaldiameter_initial = regexr(rvbasaldiameter_initial, ", not meaured", "")
replace rvbasaldiameter_initial = "mildly enlarged" if rvbasaldiameter_initial == "4.5 cm"
replace rvbasaldiameter_initial = "mildly enlarged" if rvbasaldiameter_initial == "midly enlarged"
replace rvbasaldiameter_initial = "mildly enlarged" if rvbasaldiameter_initial == "mildly dilated"
replace rvbasaldiameter_initial = "moderately enlarged" if rvbasaldiameter_initial == "mod enlarged"
replace rvbasaldiameter_initial = "normal" if rvbasaldiameter_initial == "nomal"
replace rvbasaldiameter_initial = "not measured" if rvbasaldiameter_initial == "not found"
replace rvbasaldiameter_initial = "not measured" if rvbasaldiameter_initial == "not visualized"
replace rvbasaldiameter_initial = "not measured" if rvbasaldiameter_initial == "n/a"
label define rv_basal_lab 0 "not measured" 1 "normal" 2 "mildly enlarged" 3 "moderately enlarged" 4 "severely enlarged"
encode rvbasaldiameter_initial, label(rv_basal_lab) generate(rv_basal_diameter)
label variable rv_basal_diameter "RV Basal Diameter (cm)"
drop rvbasaldiameter_initial

//raarea_initial
replace raarea_initial = lower(strtrim(raarea_initial))
replace raarea_initial = "14" if regexm(raarea_initial, "^normal") //est. for normal
replace raarea_initial = regexr(raarea_initial, " cm2$", "")
gen unquantified_ra_area = 1 if !missing(raarea_initial)
destring raarea_initial, replace force
replace unquantified_ra_area = 0 if !missing(raarea_initial)
rename raarea_initial ra_area
label values unquantified_ra_area binary_lab
label variable ra_area "RA Area (cm^2) on Echo"
label variable unquantified_ra_area "Unquantified RA Area"

replace presenceofeffusiononecho = lower(strtrim(presenceofeffusiononecho))
replace presenceofeffusiononecho = "no" if regexm(presenceofeffusiononecho, "^pleur")
replace presenceofeffusiononecho = "no" if regexm(presenceofeffusiononecho, "^no")
replace presenceofeffusiononecho = "small" if regexm(presenceofeffusiononecho, "^small")
replace presenceofeffusiononecho = "moderate" if regexm(presenceofeffusiononecho, "moderate$")
replace presenceofeffusiononecho = "yes, no size given" if presenceofeffusiononecho == "yes"
replace presenceofeffusiononecho = "" if presenceofeffusiononecho == "n/a"
label define peri_eff_lab 0 "no" 1 "trivial" 2 "small" 3 "moderate" 4 "large" 5 "yes, no size given"
encode presenceofeffusiononecho, label(peri_eff_lab) generate(pericardial_eff) noextend
drop presenceofeffusiononecho
label variable pericardial_eff "Pericardial Effusion on Echo"

replace antiphospholipidab = "no" if regexm(antiphospholipidab, "^pending")
encode antiphospholipidab, label(binary_lab) generate(apl_ab) noextend
label variable apl_ab "Antiphospholipid Antibody Positive"
drop antiphospholipidab

replace lupusanticoagulant = "no" if regexm(lupusanticoagulant, "^pending")
encode lupusanticoagulant, label(binary_lab) generate(lupus_ac) noextend
label variable lupus_ac "Lupus Anticoagulant"
drop lupusanticoagulant

encode factorviii, label(binary_lab) generate(factor_viii) noextend
label variable factor_viii "Factor VIII"
drop factorviii

replace nonobloodgroup = "no" if regexm(nonobloodgroup, "^n")
encode nonobloodgroup, label(binary_lab) generate(non_o_blood) noextend
label variable non_o_blood "Non O Bloodgroup"
drop nonobloodgroup

rename edpedx1yes ed_encounter
label values ed_encounter binary_lab
label variable ed_encounter "Workup for PE in ED?"

replace pediagnosissettingoutptinp = "ED" if missing(pediagnosissettingoutptinp)
replace pediagnosissettingoutptinp = "Outpt" if regexm(pediagnosissettingoutptinp, "^Outpt")
replace pediagnosissettingoutptinp = "Inpt" if regexm(pediagnosissettingoutptinp, "^Inpt")
label define location_lab 0 "Unknown" 1 "Outpt" 2 "ED" 3 "Inpt"
encode pediagnosissettingoutptinp, label(location_lab) generate(location) noextend
label variable location "Location of PE Workup"
drop pediagnosissettingoutptinp
tab location

//expand vars for the reatments
replace petherapyactpamechanical = lower(strtrim(petherapyactpamechanical))

gen anticoagulated = 0
replace anticoagulated = 1 if regexm(petherapyactpamechanical, "ac")
label values anticoagulated binary_lab
label variable anticoagulated "Treated with Anticoagulation"

gen tpa = 0 
replace tpa = 1 if regexm(petherapyactpamechanical, "tpa")
label values tpa binary_lab
label variable tpa "Treated with TPA"

gen ivc_filter = 0 
replace ivc_filter = 1 if regexm(petherapyactpamechanical, "ivc")
label values ivc_filter binary_lab
label variable ivc_filter "Treated with IVC filter"

gen mechanical_tx = 0 
replace mechanical_tx = 1 if regexm(petherapyactpamechanical, "mech")
replace mechanical_tx = 1 if regexm(petherapyactpamechanical, "thrombect")
replace mechanical_tx = 1 if regexm(petherapyactpamechanical, "embolect")
label values mechanical_tx binary_lab
label variable mechanical_tx "Treated with Mechanical Thrombectomy"

gen no_treatment = 0 
replace no_treatment = 1 if regexm(petherapyactpamechanical, "none")
replace no_treatment = 1 if regexm(petherapyactpamechanical, "no int")
label values no_treatment binary_lab
label variable no_treatment "Received No Treatment for PE"

drop petherapyactpamechanical


//Generate Rating Averages (of DW and MD)
* Create a new variable "qanadli" that is the average of "qanadli_mark" and "qanadli_darren"
generate qanadli = (qanadli_mark + qanadli_darren) / 2
label variable qanadli "Qanadli Score (Avg)"

generate central = 0 //if either called central, call it central
replace central = 1 if central_darren == 1 | central_mark == 1
label variable central "Central? (either rater)"

recode central (0=1) (1=0), generate(peripheral)
label variable peripheral "Peripheral PE"

save full_db, replace
export excel using "cleaned_splenectomy_pe_data.xlsx", replace firstrow(variables)
cd ..



