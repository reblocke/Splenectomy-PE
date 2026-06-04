# Splenectomy-PE

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![DOI](https://img.shields.io/badge/DOI-10.1002%2Fpul2.70231-blue.svg)](https://doi.org/10.1002/pul2.70231)
[![PMCID](https://img.shields.io/badge/PMCID-PMC12745883-green.svg)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12745883/)

Analysis code for the Pulmonary Circulation article **"Splenectomy Increases CTEPH Risk and Modifies Clinical Features of Acute Pulmonary Embolism."**

## Links And Identifiers

| Item | Value |
|---|---|
| Repository | <https://github.com/reblocke/Splenectomy-PE> |
| Final article | <https://doi.org/10.1002/pul2.70231> |
| PubMed | <https://pubmed.ncbi.nlm.nih.gov/41472662/> |
| PubMed Central | <https://pmc.ncbi.nlm.nih.gov/articles/PMC12745883/> |
| PMID | `41472662` |
| PMCID | `PMC12745883` |
| Journal | *Pulmonary Circulation*, 2025 Dec 29;16(1):e70231; eCollection 2026 Jan |
| Conference abstract | ATS 2025 abstract A6391, DOI `10.1164/ajrccm.2025.211.Abstracts.A6391` |
| License | MIT for repository code and documentation unless otherwise noted |

## Study Overview

This repository supports two retrospective analyses of splenectomy, pulmonary embolism (PE), and chronic thromboembolic pulmonary hypertension (CTEPH):

1. A four-arm case-control comparison of prior splenectomy frequency among CTEPH, all acute PE, unprovoked acute PE, and no-PE CTPA control cohorts.
2. A matched acute PE cohort analysis comparing presentation features among hospitalized PE patients with and without prior splenectomy.

The repository contains Stata cleaning/analysis scripts plus optional Quarto/Jupyter narrative analysis files. Patient-level clinical data are restricted and are not included.

## Authors, Affiliations, Funding, And COI

Article authors: Darren White; Brian W. Locke; Brittany M. Scarpato; Meghan M. Cirulis; Kaan Raif; Mark W. Dodson.

Affiliations represented in the article: Division of Pulmonary and Critical Care Medicine, University of Utah, Salt Lake City, Utah, USA; and Department of Pulmonary and Critical Care Medicine, Intermountain Medical Center, Murray, Utah, USA.

Structured citation metadata are in [`CITATION.cff`](CITATION.cff). The PMC article reports no specific funding and no conflicts of interest for the work.

## Data Access And Restrictions

The source workbooks are derived from protected clinical records and are not public. Do not commit raw, deidentified, or derived row-level patient data.

Expected local inputs:

| Path | Description |
|---|---|
| `data/private/PE after splenectomy.xlsx` | Restricted workbook for PE cases with prior splenectomy; canonical sheet `Included patients` |
| `data/private/PE without splenectomy.xlsx` | Restricted workbook for matched PE cases without prior splenectomy; canonical sheet `Sheet1` |

The data dictionary files document expected variables and transformations without exposing row-level data: [`data_dictionary.md`](data_dictionary.md) and [`data_dictionary.csv`](data_dictionary.csv).

## Reproduce The Workflow

Run commands from the repository root after placing governed local copies of the restricted workbooks under `data/private/`.

```bash
stata-mp -b do "Splenectomy PE data cleaning.do" "data/private" "outputs/stata"
stata-mp -b do "Splenectomy PE Analysis.do" "outputs/stata/derived" "outputs/stata"
```

The cleaning script writes derived local artifacts under `outputs/stata/derived/`, including `full_db.dta` and `cleaned_splenectomy_pe_data.xlsx`. The analysis script writes logs, tables, and figures under a dated folder in `outputs/stata/`.

Optional Quarto workflow after the Stata-derived dataset exists:

```bash
STATA_HOME=/Applications/Stata STATA_EDITION=be quarto render splenectomy_analysis.qmd
```

Optional environment overrides:

| Variable | Default | Purpose |
|---|---|---|
| `SPLENECTOMY_PE_DERIVED` | `outputs/stata/derived/full_db.dta` | Derived Stata dataset used by Quarto/Jupyter |
| `SPLENECTOMY_PE_OUTPUT` | `outputs/stata/quarto` | Output folder for Quarto-generated tables and figures |
| `STATA_HOME` | `/Applications/Stata` | Local Stata installation for `stata_setup` |
| `STATA_EDITION` | `be` | Stata edition passed to `stata_setup` |

## Dependencies

| Component | Required for | Notes |
|---|---|---|
| Stata 17 or newer | Primary cleaning and analysis | Developed for Stata-based workflows |
| `table1_mc` | Summary tables | User-written Stata command |
| `pvenn2`, `kappaetc` | Rater agreement checks | User-written Stata commands |
| `firthlogit`, `coefplot` | Regression and coefficient plots | User-written Stata commands |
| `cleanplots`, `white_tableau` | Optional graph schemes | Scripts continue if `cleanplots` is absent; graph appearance may differ |
| Quarto | Optional narrative rendering | Requires Python and a working Stata bridge |
| Python packages in `requirements.txt` | Optional notebook/Quarto bridge | Install with `python -m pip install -r requirements.txt` |

## Repository Layout

| Path | Purpose |
|---|---|
| `Splenectomy PE data cleaning.do` | Imports restricted source workbooks, harmonizes variables, and writes local derived data |
| `Splenectomy PE Analysis.do` | Produces rater-agreement checks, tables, models, and figures from the derived dataset |
| `splenectomy_analysis.qmd` | Optional narrative analysis source using the derived Stata dataset |
| `splenectomy_analysis.ipynb` | Optional notebook version with execution outputs stripped |
| `data_dictionary.md` / `data_dictionary.csv` | Human-readable and machine-usable data dictionary |
| `llms.txt` | Machine-readable repository index for LLMs and search tools |
| `AGENTS.md` | Repository-specific instructions for future coding agents |

Internal manuscript drafts, reviewer-response files, rendered HTML reports, and generated figures/tables are intentionally excluded from the default branch. Use the final DOI, PubMed, and PMC links above as the public article record.

## Results Mapping

| Article or supplement item | Main source file | Local output |
|---|---|---|
| Cohort construction and harmonized PE dataset | `Splenectomy PE data cleaning.do` | `outputs/stata/derived/full_db.dta` |
| Rater agreement for central/peripheral PE and Qanadli score | `Splenectomy PE Analysis.do` | Agreement figures and tables under `outputs/stata/<date>/` |
| Baseline and PE presentation tables by splenectomy status | `Splenectomy PE Analysis.do` | Excel tables under `outputs/stata/<date>/` |
| Association of splenectomy with peripheral PE | `Splenectomy PE Analysis.do`; optional `splenectomy_analysis.qmd` | Logistic regression outputs and coefficient plots |
| PA diameter and PA:AA analyses | `Splenectomy PE Analysis.do`; optional `splenectomy_analysis.qmd` | Linear model outputs and figures |

## Citation

If you use this repository, cite the final article and the repository version or commit you used:

> White D, Locke BW, Scarpato BM, Cirulis MM, Raif K, Dodson MW. Splenectomy Increases CTEPH Risk and Modifies Clinical Features of Acute Pulmonary Embolism. *Pulmonary Circulation*. 2025;16(1):e70231. doi:10.1002/pul2.70231.

Use [`CITATION.cff`](CITATION.cff) for machine-readable citation metadata.

## License

Repository code and original documentation are released under the MIT license. Restricted clinical data are not licensed for public reuse. The final article is open access under its publisher terms; use the DOI/PMC links rather than copying publisher-formatted article text into this repository.

## Contributing, Conduct, And Security

Contributions should improve transparency, portability, documentation, or code hygiene without adding restricted data. See [`CONTRIBUTING.md`](CONTRIBUTING.md), [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), and [`SECURITY.md`](SECURITY.md).

## Contact

Maintainer: Brian W. Locke, MD MSc (`@reblocke`, ORCID `0000-0002-3588-5238`). Use GitHub issues for repository-specific questions.
