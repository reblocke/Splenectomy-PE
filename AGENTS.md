# AGENTS

## Project Purpose

This public repository contains analysis code for the Pulmonary Circulation article "Splenectomy Increases CTEPH Risk and Modifies Clinical Features of Acute Pulmonary Embolism" (DOI `10.1002/pul2.70231`).

## Public And Data-Safety Rules

- Do not add PHI, patient-level clinical data, deidentified row-level exports, credentials, reviewer files, private manuscript drafts, or publisher-formatted article text.
- Keep raw and derived clinical inputs under ignored local folders such as `data/private/` and `outputs/`.
- Use DOI, PubMed, and PMC links for article discovery; do not mirror the full article in Markdown.
- Treat internal `Paper/` materials and rendered reports as non-source artifacts that should not return to the default branch.

## Workflow

From the repository root, use the Stata workflow first:

```bash
stata-mp -b do "Splenectomy PE data cleaning.do" "data/private" "outputs/stata"
stata-mp -b do "Splenectomy PE Analysis.do" "outputs/stata/derived" "outputs/stata"
```

Optional Quarto rendering requires the derived dataset:

```bash
STATA_HOME=/Applications/Stata STATA_EDITION=be quarto render splenectomy_analysis.qmd
```

## Documentation Maintenance

- Update `README.md`, `llms.txt`, `CITATION.cff`, and both data dictionary files together when publication metadata, run commands, expected inputs, or outputs change.
- Mark inferred data dictionary entries as `needs_review` instead of guessing.
- Preserve the distinction between MIT-licensed repository code and restricted clinical data.

## Verification Before Publishing

- Run `git diff --check`.
- Validate `CITATION.cff` with CFF tooling and parse it as YAML.
- Confirm no tracked files under `Paper/`, no rendered HTML report, no `.dta` files, no restricted workbooks, no logs, no `.DS_Store`, and no `.Rhistory`.
- If Stata is available, run the canonical commands or confirm they fail only with the documented missing-data message.
