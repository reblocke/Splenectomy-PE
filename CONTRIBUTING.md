# Contributing to Splenectomy–PE

Thanks for your interest in improving the transparency and reproducibility of this work!

## Ways to contribute
- Fix or clarify documentation (README, mapping table, comments).
- Improve portability (e.g., add a container recipe or environment files).
- Add smoke tests that exercise the pipeline without PHI data.
- Refactor analysis code for clarity, determinism, or performance.

## Ground rules
- **No PHI/PII in the repo or pull requests.** Use synthetic or fully de-identified examples.
- **One focused change per pull request.** Explain the *why* and *what* in the PR description.
- **Respect the Code of Conduct.** See `CODE_OF_CONDUCT.md`.

## Getting started
1. Fork the repo and create a branch: `git checkout -b feat/<short-description>`.
2. If changing results or scripts, update the **Results mapping** table in `README.md`.
3. If adding new analysis steps, prefer scripted pipelines (Stata do-files, Quarto, or Make) and include exact commands to run.
4. If adding dependencies, document them and pin versions where feasible.
5. Run the relevant scripts locally to ensure they execute without errors (with your institutionally approved data, or in dry-run mode).

## Commit style
- Write clear, descriptive commit messages (imperative mood): `Add smoke test for logistic regression figure`.
- Reference issues when applicable: `Fixes #12` or `Refs #34`.

## Pull request checklist
- [ ] Documentation updated (README and mapping where needed).
- [ ] Commands to reproduce are provided/updated.
- [ ] No secrets or PHI/PII committed.
- [ ] License headers preserved.
- [ ] CI (if present) passes.

## Releasing (for maintainers)
- Create a tagged GitHub release that corresponds to the manuscript version (e.g., `v0.1.0`).
- Archive the release with Zenodo to mint a DOI and add it to `README.md` and `CITATION.cff`.
- If figures/tables changed, confirm the mapping table is accurate and that outputs render.

## Questions?
Open an issue in the repository. We prefer open, searchable discussions to email.
