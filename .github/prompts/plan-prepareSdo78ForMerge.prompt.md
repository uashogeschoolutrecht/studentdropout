## Plan: Prepare sdo78 Data Integration for Main Branch Merge

**TL;DR**: The feature branch adds "100 Dagen Monitor" (sdo78) survey data to the student dropout ML pipeline. The integration was done quickly and has several quality gaps: hardcoded paths, no missing value imputation strategy, non-systematic question selection, documentation needs clarification, no testing, and unvalidated scale aggregations. To merge into main, we need to: (1) fix path handling to match codebase standards, (2) revert CV-fold to production setting (10), (3) add explicit sdo78 missing value imputation, (4) document all decisions and changes, (5) validate data quality and aggregated scales, (6) add data quality reporting, and (7) prepare for merge with proper Git workflow.

---

## Steps

### **Phase 1: Path Standardization & Configuration** (*Dependencies: None*)

1. **Fix hardcoded paths in wrangle_sdo78_data.ipynb** (*parallel with step 2*)
   - Replace `Path.home() / 'local-share' / 'raw' / 'sdo78'` with pattern: `Path(f"/home/{current_user}/local-share/raw/sdo78")`
   - Apply to all data loading paths (Excel files, Q_selection.xlsx, keys files)
   - Add `current_user = os.getlogin()` to imports section
   - Validate with print statements showing resolved paths

2. **Revert CV-fold and repeats parameters for production** (*parallel with step 1*)
   - Change `N_FOLDS = 5` back to `N_FOLDS = 10` in notebooks 11 and 12
   - Verify `N_REPEATS` is set appropriately (check baseline value)
   - Note: Documentation mentions CV-5 experiments, which is fine - it describes what was tested
   - Add markdown cell clarifying final merged code uses CV-10 (experimental CV-5 results documented separately)

### **Phase 2: Missing Value Strategy** (*Depends on Phase 1*)

3. **Design sdo78 missing value imputation strategy**
   - Options to investigate:
     - A: Use median imputation by cohort year + create `sdo78_responder` flag feature
     - B: Create explicit "non-responder" category values
     - C: Use MICE/iterative imputation with other features
   - Document trade-offs and selection bias implications (18.9% vs 36.4% dropout rate)
   - Add this strategy to notebook 04 missing_values_imputation.ipynb

4. **Implement chosen imputation strategy**
   - Add sdo78-specific section to notebook 04
   - Create helper function if complex logic needed (with type hints, docstring)
   - Include validation print statements showing before/after NaN counts
   - Consider creating `sdo78_responder` flag for stratified analysis

### **Phase 3: Data Quality & Validation** (*Depends on Phase 1*)

5. **Create sdo78 data quality report** (*parallel with step 6*)
   - Document merge match rates per year (2021, 2022, 2023)
   - Investigate dropped records from wrangle_sdo78_data.ipynb line 161
   - Show SINH_ID linkage success rates
   - Report response rates by year and cohort characteristics
   - Add as new section to wrangle_sdo78_data.ipynb or separate notebook

6. **Validate aggregated scales** (*parallel with step 5*)
   - Calculate Cronbach's alpha for Support_Avg (HU27_01, HU27_02, HU27_03)
   - Calculate Cronbach's alpha for Belonging_Avg (HU28_01, HU28_02, HU28_03)
   - **Decision criteria**: 
     - If α ≥ 0.7: Document validation success; aggregation is reliable
     - If α < 0.7: Document limitation; note that scale should be validated in future work but keep aggregation for MVP
   - Document findings in wrangle_sdo78_data.ipynb with markdown cells

7. **Review and justify question selection**
   - Document rationale for 12-question selection in markdown cell
   - Investigate HU22_01 exclusion (missing in 2021) - was this correct?
   - Note limitations and recommend future feature importance analysis
   - Consider SME (subject matter expert) review if available

### **Phase 4: Code Quality & Maintainability** (*Depends on Phase 2 & 3*)

8. **Standardize merging logic in wrangle_sdo78_data.ipynb**
   - Review three different merge strategies (studentnr vs SINH_ID)
   - Document why different keys are needed per year
   - Consider refactoring into helper function if pattern can be unified
   - Add error handling for merge failures

9. **Add data validation checkpoints**
   - Add shape validation: `print(f"Records before sdo78 merge: {data.shape}")`, `print(f"Records after sdo78 merge: {data.shape}")`
   - Add duplicate check after merges
   - Add NaN count summary for sdo78 columns
   - Follow pattern from existing notebooks (e.g., notebook 02)

10. **Code formatting compliance**
    - Run Black with 99-char line length on wrangle_sdo78_data.ipynb (if notebook formatted)
    - Ensure consistent naming: `sdo78_` prefix for all columns
    - Add type hints to any new helper functions
    - Add docstrings following existing patterns

### **Phase 5: Documentation** (*Depends on Phase 2, 3, 4*)

11. **Document sdo78 in README.md**
    - Add sdo78 (100 Dagen Monitor) to "Data categories" section
    - List the 12 questions/features added
    - Note limitations: response rate, selection bias, prediction only valid for responders
    - Update data overview diagram if sdo78 not shown

12. **Create comprehensive sdo78 integration documentation**
    - Consolidate findings from docs/20260320_sdo78_data_performance.md and docs/20260325_sdo78_data_performance full model.md
    - Document implementation decisions made in Phases 2-4
    - Include known limitations and future work recommendations
    - Follow dated logbook format

13. **Add inline documentation to notebooks**
    - Add markdown cells explaining sdo78 left-join rationale in notebook 02
    - Document why sdo78_*_missing_flag columns dropped in notebook 10
    - Explain comparison strategy (with/without sdo78) in notebooks 11-12
    - Add note clarifying final production settings: CV-fold=10, threshold=100 (experiments with other values documented in docs/)

### **Phase 6: Testing & Validation** (*Depends on Phase 5*)

14. **Create data processing validation (if adding test infrastructure)**
    - If establishing tests: Create tests/test_sdo78_wrangling.py
    - Test cases: merge key logic, aggregation calculations, missing value handling
    - Use pytest framework
    - Otherwise: Document validation steps performed manually in docs/

15. **End-to-end pipeline validation**
    - Re-run full pipeline (notebooks 01-13) with changes
    - Verify no breaking changes to downstream notebooks
    - **Baseline comparison**: Compare CV-10 results against original baseline (before experimentation), NOT against CV-5 experimental results
    - Document performance metrics with CV-10 and note they differ from CV-5 experiments due to cross-validation strategy change
    - Verify results are reasonable and within expected ranges

### **Phase 7: Merge Preparation** (*Depends on Phase 6*)

16. **Commit strategy and Git workflow**
    - Review all changes with `git status` and `git diff`
    - Create logical commits grouped by phase:
      - Commit 1: "Fix hardcoded paths in sdo78 wrangling"
      - Commit 2: "Revert N_FOLDS to 10 for production"
      - Commit 3: "Add sdo78 missing value imputation strategy"
      - Commit 4: "Add data quality validation for sdo78"
      - Commit 5: "Document sdo78 integration and limitations"
    - Write clear commit messages following project conventions
    - Push branch and create pull request with summary of changes

---

## Relevant Files

**Core sdo78 files:**
- [notebooks/wrangle_sdo78_data.ipynb](notebooks/wrangle_sdo78_data.ipynb) — Primary wrangling logic; fix paths, add validation, document choices
- [notebooks/02 cleaning_data.ipynb](notebooks/02%20cleaning_data.ipynb#L52-L57) — sdo78 merge point; document rationale
- [notebooks/04 missing_values_imputation.ipynb](notebooks/04%20missing_values_imputation.ipynb) — Add sdo78 imputation section

**Modified in integration:**
- [notebooks/03 low_frequency_categories.ipynb](notebooks/03%20low_frequency_categories.ipynb#L98) — threshold=100 (no change needed)
- [notebooks/10 feature selection.ipynb](notebooks/10%20feature%20selection.ipynb#L157-L164) — Drops sdo78_*_missing_flag columns
- [notebooks/11 prediction_model_comparison.ipynb](notebooks/11%20prediction_model_comparison.ipynb#L123) — N_FOLDS needs revert from 5→10; also has comparison with/without sdo78 (L176-L177)
- [notebooks/12 hyperparameter_tuning.ipynb](notebooks/12%20hyperparameter_tuning.ipynb#L294) — N_FOLDS needs revert from 5→10; also has Bayesian optimization comparison (L729-L766)

**Documentation:**
- [docs/20260320_sdo78_data_performance.md](docs/20260320_sdo78_data_performance.md) — Initial performance analysis
- [docs/20260325_sdo78_data_performance full model.md](docs/20260325_sdo78_data_performance%20full%20model.md) — Full model results
- [README.md](README.md#L65) — Data categories section needs sdo78 entry

**Configuration:**
- [pyproject.toml](pyproject.toml) — Black/Flake8 config (99 chars)
- [requirements.txt](requirements.txt) — Check if any new dependencies added

---

## Verification

1. **Code quality checks**
   - [ ] All paths use `current_user` pattern (no hardcoded paths)
   - [ ] All helper functions have type hints and docstrings
   - [ ] Code passes Flake8 with 99-char line length
   - [ ] Consistent naming conventions (sdo78_ prefix)

2. **Data quality checks**
   - [ ] sdo78 merge match rates documented per year
   - [ ] Missing value imputation strategy explicitly defined in notebook 04
   - [ ] Cronbach's alpha calculated for Support_Avg and Belonging_Avg
   - [ ] Dropped records investigated and documented
   - [ ] Data validation prints show expected shapes and NaN counts

3. **Documentation checks**
   - [ ] README.md updated with sdo78 data category
   - [ ] CV-fold confirmed at 10 in notebooks 11 & 12 (production setting)
   - [ ] N_REPEATS validated against baseline
   - [ ] Low-frequency threshold confirmed at 100 in notebook 03
   - [ ] Experimental documentation (CV-5 tests) preserved as historical record
   - [ ] Inline markdown cells explain sdo78-specific logic in notebooks
   - [ ] Limitations and selection bias documented
   - [ ] Future work recommendations captured

4. **Pipeline checks**
   - [ ] Full pipeline (notebooks 01-13) runs without errors
   - [ ] Model performance metrics compared against CV-10 baseline (not CV-5 experiments)
   - [ ] Performance differences documented and explained
   - [ ] No unintended side effects from changes
   - [ ] Output files (sdo78_combined.csv) validated

5. **Testing checks** (if applicable)
   - [ ] Test suite created for sdo78 wrangling logic
   - [ ] All tests pass
   - [ ] Coverage report generated

6. **Merge preparation checks**
   - [ ] All changes reviewed with git diff
   - [ ] Commits organized logically by phase/topic
   - [ ] Commit messages are clear and descriptive
   - [ ] Branch is up to date with main (rebase/merge if needed)
   - [ ] Pull request description summarizes changes and rationale

---

## Decisions

**Assumed scope boundaries:**
- **Included**: Fix immediate quality gaps (paths, imputation, documentation, validation)
- **Included**: Revert CV-fold to 10 in notebooks 11 & 12 (currently incorrectly set to 5)
- **Included**: Verify and document threshold=100 (no change from baseline)
- **Included**: Document known limitations (selection bias, non-systematic question selection)
- **Excluded**: Reselecting questions with feature importance analysis (future work)
- **Excluded**: Addressing selection bias with non-responder modeling (future work)
- **Excluded**: CI/CD pipeline setup (not currently in codebase)
- **Optional**: Formal test infrastructure (establish if adding validation logic, otherwise document manually)

**Key assumptions:**
- Existing sdo78 question selection is acceptable for MVP; systematic review is future work
- Simple aggregation (mean) for Support/Belonging is acceptable if Cronbach's α ≥ 0.7
- Selection bias (18.9% vs 36.4%) is acceptable limitation if documented
- Missing value imputation will use median + responder flag (pending confirmation in step 3)
- CV-fold=10 and threshold=100 match baseline pipeline (no parameter changes for sdo78)

---

## Further Considerations

**1. Imputation strategy trade-offs**
- **Option A (Recommended)**: Median imputation by year + `sdo78_responder` binary flag
  - Pros: Simple, interpretable, enables stratified analysis
  - Cons: Assumes missing completely at random (MCAR) within year
- **Option B**: Create "non-responder" categorical value
  - Pros: Explicit representation of non-response
  - Cons: Changes feature space significantly
- **Option C**: MICE iterative imputation
  - Pros: Uses correlation with other features
  - Cons: Complex, computationally expensive, may overfit

**2. Question selection validation**
- Should we run post-hoc feature importance analysis on the 12 selected questions?
- Should we consult with student wellbeing experts (SME) for question selection review?

**3. Testing infrastructure scope**
- Should we establish formal testing infrastructure now or document validation manually?
- If yes to tests: Focus only on sdo78 or expand to other pipeline components?
