# Splenectomy–PE

> Analysis code and materials supporting a retrospective study of splenectomy, pulmonary embolism (PE), and chronic thromboembolic pulmonary hypertension (CTEPH).

**Links & IDs**
- Repository: https://github.com/reblocke/Splenectomy-PE
- Paper: *Manuscript in preparation* (preprint forthcoming)
- Conference abstract: American Thoracic Society (ATS) 2025 — *Central Versus Peripheral Location of Pulmonary Embolism in Splenectomized Patients* (A6391). URL: https://www.atsjournals.org/doi/abs/10.1164/ajrccm.2025.211.Abstracts.A6391
- License: MIT (see [`LICENSE`](./LICENSE))

---

## Study overview (what this repository contains)

This repository hosts code and analysis notebooks used to compare the frequency of splenectomy across clinical cohorts and to evaluate how prior splenectomy relates to clinical features of PE at presentation.

**Design (two substudies):**
1. **Retrospective 4‑arm case–control** comparing the frequency of prior splenectomy among:
   - CTEPH patients with available CTPA (n=179)
   - All acute PE diagnosed in the ED by CTPA (n=333)
   - *Unprovoked* acute PE (n=326)
   - ED CTPA patients with **no** lifetime history of VTE and negative index CTPA (n=839)

2. **Matched cohort of PE hospitalizations**, stratified by prior splenectomy:
   - PE with prior splenectomy (n=40, inpatient)
   - PE without prior splenectomy (n=100, inpatient)

**Key analyses (high level):**
- Substudy 1 (frequency): greater splenectomy prevalence in CTEPH vs controls; odds ratios (CTEPH relative to controls): 7.8 vs No‑PE; 4.3 vs All‑PE; 5.3 vs Unprovoked‑PE.
- Substudy 2 (presentation features): adjusted odds of **peripheral** (vs central) PE were higher with prior splenectomy (OR≈3.1, 95% CI ≈1.1–8.6); longer symptom duration (≥2 weeks) and lower DVT detection were observed in the splenectomy group. Inter‑rater agreement: κ≈0.71 (central/peripheral) and κ≈0.95 (Qanadli).

> Ethics: retrospective study approved by the Intermountain Medical Center (IMC) IRB under a waiver of informed consent. No identifiable data are included in this repository.

---

## How to reproduce the main results

> **Important:** The underlying clinical data reside behind institutional controls (PHI/PII). No patient‑level data are stored here. You can still run the full pipeline with your own appropriately governed dataset, or dry‑run the scripts to verify the environment.

### Option A — Render the Quarto analysis
This will reproduce figures/tables created in the Quarto document.

```bash
# 1) Install Quarto (https://quarto.org) and an engine (R ≥4.3 and/or Python ≥3.10)
# 2) From the repo root:
quarto render splenectomy_analysis.qmd
# Outputs will appear next to the qmd (e.g., HTML, figures/).
```

### Option B — Run the Stata workflow
Two Stata do-files are provided. Execute them in order in a Stata console or batch session.

```bash
# (example; adjust the Stata binary for your platform)
stata-mp -b do "Splenectomy PE data cleaning.do"
stata-mp -b do "Splenectomy PE Analysis.do"
```

### Option C — Execute the Jupyter notebook
```bash
# Create/activate a Python env with Jupyter
pip install jupyter
jupyter nbconvert --to html --execute splenectomy_analysis.ipynb
```

---

## Data access

- **Sources:** CTPA, ICD-coded hospital encounters, and EDW queries at Intermountain Health.
- **Access:** Controlled. Patient‑level data cannot be shared herein. Researchers seeking reproducibility access should coordinate a data use agreement (DUA) with Intermountain Health (open a GitHub issue to start the conversation), or substitute an institutionally approved dataset with the same variables.
- **Safe re‑runs:** The scripts check for input paths and will execute in “dry‑run” mode if data are unavailable; feel free to adapt to your local environment.

---

## Computational environment

- **OS/arch:** Linux, macOS, or Windows (x86_64); analysis primarily developed on modern desktops/laptops.
- **Dependencies:**  
  - *Stata* (version ≥17 recommended) for `.do` files.  
  - *Quarto* (≥1.3) with either R (≥4.3) or Python (≥3.10) for `splenectomy_analysis.qmd`.  
  - *Jupyter* for the optional notebook.  
- **Reproducibility:** No stochastic modeling is used in the primary analyses; seed control is not required.

> If you containerize the workflow (e.g., Apptainer or Docker), add your recipe under `docker/` and mention it here.

---

## Repository layout

```
├── Paper/                         # manuscript/figures (no PHI)
├── Splenectomy PE data cleaning.do
├── Splenectomy PE Analysis.do
├── splenectomy_analysis.qmd
├── splenectomy_analysis.ipynb
├── splenectomy_analysis.html      # rendered report (example)
├── LICENSE                        # MIT
└── README.md                      # this file
```

---

## Results mapping (paper ↔ code)

| Paper item | Script/notebook | Command / section | Output(s) |
|---|---|---|---|
| Table 1. CTEPH cohort characteristics | `splenectomy_analysis.qmd` | Render; “CTEPH cohort summary” section | figures + table in HTML |
| Table 2. Splenectomy frequency & ORs | `Splenectomy PE Analysis.do` | `do "Splenectomy PE Analysis.do"` | CSV/LaTeX/HTML table (configure in do‑file) |
| Table 3–4. PE presentation by splenectomy | `splenectomy_analysis.qmd` + Stata outputs | Render; “PE cohorts” section | tables in HTML |
| Fig. 1. Peripheral vs central PE (logistic regression) | `splenectomy_analysis.qmd` | Render; “Logistic regression” section | `figures/fig1_peripheral_vs_central.png` |

---

## Ethics & compliance

- **IRB:** IMC IRB approval; waiver of informed consent.
- **PHI/PII:** Do not commit any patient‑level data, identifiers, or derived fields that could re‑identify a person. This repository is for code and non‑identifiable artifacts only.

---

## Citation

If you use this repository, please cite the software (see [`CITATION.cff`](./CITATION.cff)) and, once available, the associated preprint/journal article.

---

## Funding & acknowledgements

> *Add funding sources, grant numbers, and required disclaimers here once finalized.*

---

## Contributing, conduct & security

We welcome issues and pull requests that improve documentation, transparency, or portability. Please see:
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) for how to propose changes
- [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) for community expectations
- [`SECURITY.md`](./SECURITY.md) for reporting vulnerabilities

---

## Maintainers / contact

- Maintainer: Brian Locke, MD MSc (GitHub: @reblocke)  
- Questions? Please open an issue in the repository.
