# Data Dictionary

This dictionary documents the restricted local inputs, derived variables, and generated outputs expected by the Splenectomy-PE workflow. It does not include patient-level values.

## Source Workbooks

| Workbook | Sheet | Unit of observation | Public status | Notes |
|---|---|---|---|---|
| `data/private/PE after splenectomy.xlsx` | `Included patients` | Acute PE case with prior splenectomy | Restricted clinical data | Imported by `Splenectomy PE data cleaning.do`; rows without `pe_diagnosis_dt` are dropped. |
| `data/private/PE without splenectomy.xlsx` | `Sheet1` | Matched acute PE case without prior splenectomy | Restricted clinical data | Imported by `Splenectomy PE data cleaning.do`; rows without `pe_diagnosis_dt` are dropped. |

## Source Variable Inventory

The cleaning script expects these source variables after Stata `import excel, firstrow case(lower)` normalization. Some workbooks use cohort-specific aliases; those are documented together.

### PE With Prior Splenectomy

`age_peyears`, `centraldarrensreview`, `qanadlifinal`, `centralmarksreview`, `marksqanadli`, `malegender1yes0no`, `chronicchanges1yes0no`, `bmi_pe`, `raceethnicity`, `pesi_pe`, `admissionlocation`, `hospitallosdays`, `iculos`, `bnp_max`, `troponin_max`, `rightheartstrain`, `dilatedpulmartery`, `rvlvratio_initial1abnormal`, `padiametermm`, `aorticdiametermm`, `paa`, `paenlargement1yes0no2`, `increasedpaa09`, `paenlargementorincreasedpaa`, `hxofpriorpedvt`, `hxofpriorthrombosispvtcva`, `highesthr_pe`, `lowestbp_pemap`, `o2max_pe`, `malignancy`, `immobilityinjurywithin30d`, `surgerywithin30d`, `sicklecell`, `clottingdisorder`, `chf`, `chroniclungdisease`, `afib`, `pregnancy`, `estrogenuse`, `obesity`, `cvcwithin30d`, `thyroiddisease`, `inflammatoryboweldisease`, `ef`, `septalflatteneningonecho`, `rvsp`, `pvacceltime`, `trvelocity_initial`, `tapse_initial`, `rvbasaldiameter_initial`, `raarea_initial`, `presenceofeffusiononecho`, `antiphospholipidab`, `lupusanticoagulant`, `factorviii`, `nonobloodgroup`, `pediagnosissettingoutptinp`, `edpedx1yes`, `petherapyactpamechanical`, `procedure_dt`, `pe_diagnosis_dt_reviseddw`, `dvtworkupdone1yes`, `dvtworkuppositive`, `rvlvratio`, `pesymptomduration2weeks`.

### PE Without Prior Splenectomy

`age_peyears`, `dwpelocation`, `dwqanadli`, `marklocation`, `markqanadli`, `malegender1yes0no`, `chronicchanges`, `bmi_pe`, `ethnicity`, `pesi_pe`, `admissionlocation`, `hospitallosdays`, `iculos`, `bnp_max`, `troponin_max` or `troponin_maxngml`, `rightheartstrain`, `dilatedpulmartery`, `rvlvratio_initial1abnormal`, `padiametermm`, `aorticdiametermm`, `paa`, `paenlargement1yes0no2`, `increasedpaa09`, `paenlargementorincreasedpaa`, `hxofpriorpedvt`, `hxofpriorthrombosispvtcva`, `highesthr_pe`, `lowestbp_pemap`, `o2max_pe`, `malignancy`, `immobilityinjurywithin30d`, `surgerywithin30d`, `sicklecell`, `clottingdisorder`, `chf`, `chroniclungdisease`, `afib`, `pregnancy`, `estrogenuse`, `obesity`, `cvcwithin30d`, `thyroiddisease`, `inflammatoryboweldisease`, `ef`, `septalflatteneningonecho`, `rvsp`, `pvacceltime`, `trvelocity_initial` or `trvelocity_initialms`, `tapse_initial`, `rvbasaldiameter_initial`, `raarea_initial` or `raarea_initialcm2`, `presenceofeffusiononecho`, `antiphospholipidab`, `lupusanticoagulant`, `factorviii`, `nonobloodgroup`, `petherapyactpamechanical`, `pe_diagnosis_dt_reviseddw`, `dvtworkupdone1yes`, `dvtworkuppositive`, `rvlvratio`, `symptomduration2weeksattime`.

## Derived Analysis Variables

| Variable | Definition | Derivation |
|---|---|---|
| `splenectomy` | Cohort indicator for prior splenectomy | Set to `1` for the prior-splenectomy workbook and `0` for the matched no-splenectomy workbook. |
| `years_since_splenectomy` | Years from splenectomy procedure to PE diagnosis | `(pe_diagnosis_dt_reviseddw - procedure_dt) / 365.25`; only meaningful for prior-splenectomy cases. |
| `central_darren`, `central_mark` | Reviewer-level central PE classification | Direct import or recode from location text. |
| `qanadli_darren`, `qanadli_mark` | Reviewer-level Qanadli score | Direct import from reviewer columns. |
| `qanadli` | Average Qanadli score | Mean of `qanadli_mark` and `qanadli_darren`. |
| `central` | Central PE by either reviewer | `1` if either reviewer classified PE as central. |
| `peripheral` | Peripheral PE | Reverse-coded from `central`. |
| `pa_d`, `aa_d`, `pa_aa` | PA diameter, aortic diameter, and PA:AA ratio | Renamed from source CT measurement variables. |
| `high_pa_aa`, `pa_aa_over_1` | PA:AA threshold indicators | Imported threshold flag for `>0.9`; derived threshold flag for `>=1`. |
| `rightheartstrain`, `rvlvratio_initial1abnormal` | RV strain indicators | Cleaned from CT text or derived from measured RV:LV ratio. |
| `dvt_workup`, `dvt_found`, `symptoms_two_weeks` | PE presentation features | Harmonized from cohort-specific DVT workup and symptom-duration columns. |
| `active_malig`, `wells_immobility`, `wells_surg`, `recent_cvc`, `curr_preg`, `curr_estr` | Provoking-factor indicators | Text fields normalized to binary indicators. |
| `sickle_cell`, `clotting_disorder`, `chf`, `chronic_lung`, `a_fib`, `obesity_dx`, `thyroid_dz`, `ibd` | Comorbidity indicators | Encoded or recoded from source clinical fields. |
| `anticoagulated`, `tpa`, `ivc_filter`, `mechanical_tx`, `no_treatment` | PE treatment indicators | Parsed from `petherapyactpamechanical`. |
| `is_white` | Race indicator used in optional narrative workflow | `1` when normalized `raceethnicity` equals `white`. |

Additional derived variables referenced by the scripts include `age`, `male_sex`, `bmi_pe`, `raceethnicity`, `pesi_pe`, `admissionlocation`, `hospitallosdays`, `iculos`, `bnp_max`, `troponin_max`, `prior_pe_dvt`, `prior_other_vte`, `highest_hr`, `max_resp`, `lowest_sbp`, `lowest_dbp`, `lowest_map`, `dilatedpulmartery`, `pa_enlarged`, `pa_enlarged_by_d_or_ratio`, `pe_date`, `lvef`, `septal_flattening`, `rvsp`, `insuff_tr_jet_for_rvsp`, `pv_accel_time`, `unmeasured_pv_accel_time`, `tr_velocity`, `unmeasured_tr_vel`, `tapse`, `unmeasured_tapse`, `rv_basal_diameter`, `ra_area`, `unquantified_ra_area`, `pericardial_eff`, `apl_ab`, `lupus_ac`, `factor_viii`, `non_o_blood`, `ed_encounter`, and `location`.

## Generated Outputs

| Output | Created by | Status |
|---|---|---|
| `outputs/stata/derived/splenectomy.dta` | Cleaning script | Local restricted derived data; ignored by git. |
| `outputs/stata/derived/no_splenectomy.dta` | Cleaning script | Local restricted derived data; ignored by git. |
| `outputs/stata/derived/full_db.dta` | Cleaning script | Local restricted analysis dataset; ignored by git. |
| `outputs/stata/derived/cleaned_splenectomy_pe_data.xlsx` | Cleaning script | Local restricted derived workbook; ignored by git. |
| `outputs/stata/<date>/*.xlsx` | Analysis script or optional narrative workflow | Generated aggregate tables; review before sharing. |
| `outputs/stata/<date>/*.png` | Analysis script or optional narrative workflow | Generated figures; review before sharing. |
| `outputs/stata/<date>/Logs/*.log` | Stata scripts | Local logs; ignored by git. |

## Review Flags

- `needs_review`: Some clinical definitions, value labels, and recoding choices are inferred from the existing scripts rather than a separately validated codebook.
- `restricted`: All workbook-level and row-level derived data remain restricted even when deidentified.
- `aggregate_review_required`: Generated figures and tables are aggregate outputs but should be reviewed before public release.
