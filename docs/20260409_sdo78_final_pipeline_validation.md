# SDO78 Integration — Final Pipeline Validation (CV-10)

**Date**: 2026-04-09  
**Author**: Copilot / pipeline re-run  
**Purpose**: End-to-end pipeline validation after completing all sdo78 integration quality steps (path standardisation, imputation, Cronbach alpha, data quality report, inline documentation). Establishes the definitive CV-10 baseline for the sdo78 feature branch before merge into main.

---

## Context

Previous experimentation used CV-5 for speed. This run uses the **production setting of CV-10 (N_FOLDS=10, N_REPEATS=5)** throughout, matching the project baseline. Results documented in earlier docs (20260320 and 20260325) used CV-5 and are not directly comparable to the numbers below.

---

## Data Quality Report (wrangle_sdo78_data.ipynb)

| Year | SDO78 records | Matched to dropout data | Match rate |
|------|--------------|------------------------|------------|
| 2021 | 1,328        | 1,243                  | 93.6%      |
| 2022 | 1,375        | 1,299                  | 94.5%      |
| 2023 | 1,530        | 1,398                  | 91.4%      |

- Records before dropping unmatched: 4,233
- Records after dropping unmatched: **3,940** (293 dropped, 6.9%)
- Unmatched 2023 records are primarily Ad students (out of scope); unmatched 2021/2022 flagged for future investigation.

### Scale Reliability (Cronbach's alpha)

| Scale | Items | α | Assessment |
|-------|-------|---|------------|
| Support_Avg (HU27_01–03) | 3 | **0.470** | ⚠️ Below 0.7 threshold — limited internal consistency; Support_Avg retained for MVP but noted as a limitation for future review |
| Belonging_Avg (HU28_01–03) | 3 | **0.713** | ✅ Acceptable — aggregation justified |

---

## Pipeline Dataset

- Dataset (after full pipeline): **21,595 students**
- Features without sdo78: **76**
- Features with sdo78: **88** (+12 sdo78 features)
- Train/Val/Test split consistent with project baseline

---

## Model Comparison Without SDO78 (notebook 11, CV-10)

Evaluation method: **Stratified 10-fold CV, 5 repeats** (CV-10×5).

| Model | PR-AUC (±std) | ROC-AUC (±std) | Recall (±std) | F1 (±std) |
|-------|--------------|----------------|---------------|-----------|
| 🥇 XGBoost | **0.633 ± 0.019** | 0.776 ± 0.012 | 0.697 ± 0.022 | 0.607 ± 0.014 |
| Logistic Regression | 0.625 ± 0.019 | 0.772 ± 0.012 | 0.694 ± 0.021 | 0.604 ± 0.015 |
| Random Forest | 0.612 ± 0.020 | 0.765 ± 0.012 | 0.686 ± 0.021 | 0.593 ± 0.014 |
| Neural Network | 0.595 ± 0.021 | 0.753 ± 0.014 | 0.569 ± 0.038 | 0.567 ± 0.020 |
| Decision Tree | 0.321 ± 0.000 | 0.500 ± 0.000 | — | — |

**XGBoost selected for hyperparameter tuning** (highest PR-AUC, +3.2 pp over baseline).

Test set performance (XGBoost, default hyperparameters):

| Accuracy | Recall | Precision | F1 | ROC-AUC | PR-AUC |
|----------|--------|-----------|-----|---------|--------|
| 0.731 | 0.651 | 0.557 | 0.600 | 0.779 | 0.620 |

---

## Hyperparameter Tuning — XGBoost Without SDO78 (notebook 12)

Bayesian optimisation: N_ITER=30, CV-10×5, optimising PR-AUC.

**Best hyperparameters:**
```
colsample_bytree: 0.632
learning_rate:    0.021
max_depth:        7
min_child_weight: 4
n_estimators:     294
reg_alpha:        0.0001
reg_lambda:       0.633
subsample:        0.723
```

| Metric | Baseline CV | Tuned CV | Δ |
|--------|------------|----------|---|
| PR-AUC | 0.6335 | **0.6366** | +0.0031 |
| ROC-AUC | 0.7762 | **0.7772** | +0.0010 |
| Recall | 0.6966 | 0.6786 | −0.0180 |
| F1 | 0.6071 | 0.6060 | −0.0010 |
| Accuracy | 0.7106 | 0.7169 | +0.0063 |

Tuning yields marginal PR-AUC improvement (+0.003); model is already near-optimal at baseline hyperparameters.

**Final test set (tuned, without sdo78):**
- PR-AUC: **0.622** | ROC-AUC: **0.779**

---

## SDO78 Impact — With vs Without (notebook 12, Wilcoxon signed-rank test)

| Metric | Without sdo78 (CV mean) | With sdo78 (CV mean) | Δ | p-value | Sig. |
|--------|------------------------|---------------------|---|---------|------|
| PR-AUC | 0.6366 | **0.6463** | +0.0097 | < 0.001 | *** |
| ROC-AUC | 0.7772 | **0.7866** | +0.0094 | < 0.001 | *** |
| Recall | 0.6786 | **0.6989** | +0.0203 | < 0.001 | *** |
| F1 | 0.6060 | **0.6141** | +0.0081 | < 0.001 | *** |
| Accuracy | 0.7169 | 0.7181 | +0.0012 | 0.288 | ns |
| Precision | 0.5477 | 0.5478 | +0.0001 | 0.833 | ns |

**Conclusion**: Including the 100 Dagen Monitor (sdo78) data provides a **statistically significant improvement** in PR-AUC (+1.0 pp), ROC-AUC (+0.9 pp), Recall (+2.0 pp), and F1 (+0.8 pp). Accuracy and Precision show no significant difference.

---

## Project Targets Assessment

| Target | Threshold | With sdo78 (CV) | Status |
|--------|-----------|-----------------|--------|
| Recall | ≥ 75% | 69.9% | ⚠️ Below target |
| Precision | ≥ 60% | 54.8% | ⚠️ Below target |
| F1 | ≥ 65% | 61.4% | ⚠️ Below target |

Current model performance remains below the stated project targets on all three metrics, consistent with the earlier Phase 2 assessment. Adding sdo78 data moves performance in the right direction. Further data sources or model improvements are recommended for Phase 3.

---

## Key Limitations

1. **Support_Avg reliability**: Cronbach's α = 0.47 (below 0.7 threshold) — 3 HU27 items do not form a reliable scale; retained for MVP
2. **Selection bias**: sdo78 responders have ~19% dropout rate vs ~36% for non-responders; imputation with cohort medians mitigates but does not eliminate this
3. **Question HU22_01**: absent in 2021 data and excluded from all years for consistency
4. **Non-systematic question selection**: 12 questions selected by expert judgment; post-hoc feature importance analysis is future work
5. **Unmatched records**: 6.9% of SDO78 records could not be linked; 2021/2022 unmatched cases not fully investigated

---

## Next Steps (Future Work)

- Investigate remaining unmatched SDO78 records (2021/2022)
- Validate Support scale items with domain expert; consider dropping or replacing HU27 items
- Run systematic feature importance analysis on the 12 SDO78 questions
- Explore additional data sources to close the gap to project performance targets
