# Investigating 100 Dagen Monitor Data on Full Student Drop-out Model Performance

| | |
|---|---|
| **Author** | Fraukje Coopmans & Bouba Ismalia (updated with final CV-10 validation) |
| **Date** | 2026-04-09 |
| **Status** | Final |

---

## 1. Problem Statement and Hypothesis
Earlier work showed gains from 100 Dagen Monitor (SDO78) data on a responder-only subset. This study tests whether adding SDO78 features improves the full student drop-out model. The hypothesis is that SDO78 data improves PR-AUC, ROC-AUC, Recall, and F1.

## 2. Data and Method
- SDO78 data from 2021-2023 was merged with student drop-out data.
- 12 questionnaire features were selected (consistent across years), including aggregated topic scores.
- Response type was added (complete, partial, non-responder), and non-responders were retained via imputation.
- Pipeline settings were restored to production baseline: Stratified CV-10 with 5 repeats and low-frequency threshold 100.
- Models were compared in notebook 11; XGBoost was selected and tuned in notebook 12 (Bayesian optimization, 30 iterations, PR-AUC objective).

We used the following selected SDO78 questions:
![Selected SDO78 questions](img/sdo78_questions_selected.png)

## 3. Data Quality Summary
- SDO78 records before match filtering: 4,233
- Matched and retained: 3,940 (93.1%)
- Dropped unmatched: 293 (6.9%)

Scale reliability:
- Support_Avg (HU27_01-03): alpha = 0.470 (low, retained for MVP)
- Belonging_Avg (HU28_01-03): alpha = 0.713 (acceptable)

Final modeling dataset:
- 21,595 students
- 76 features without SDO78
- 88 features with SDO78 (+12)

## 4. Results

### 4.1 Best Model Without SDO78
XGBoost was best in CV-10x5 model comparison.

### 4.2 Tuning Effect (Without SDO78)
Tuning yielded a small gain in CV PR-AUC (0.6335 -> 0.6366), indicating the baseline model was already close to optimal.

### 4.3 SDO78 Impact (Tuned XGBoost, CV Means)

| Metric | Without SDO78 | With SDO78 | Delta | p-value |
|---|---:|---:|---:|---:|
| PR-AUC | 0.6366 | **0.6463** | +0.0097 | < 0.001 |
| ROC-AUC | 0.7772 | **0.7866** | +0.0094 | < 0.001 |
| Recall | 0.6786 | **0.6989** | +0.0203 | < 0.001 |
| F1 | 0.6060 | **0.6141** | +0.0081 | < 0.001 |
| Accuracy | 0.7169 | 0.7181 | +0.0012 | 0.288 |
| Precision | 0.5477 | 0.5478 | +0.0001 | 0.833 |

Including SDO78 gives statistically significant improvements for PR-AUC, ROC-AUC, Recall, and F1; no significant change for Accuracy or Precision.

## 5. Target Check
Project targets are not yet met with SDO78 (Recall 69.9%, Precision 54.8%, F1 61.4%).

## 6. Key Limitations
1. Support_Avg reliability is low (alpha 0.47).
2. Selection bias remains: responders have much lower dropout than non-responders.
3. HU22_01 missing in 2021 and excluded for consistency.
4. 12 SDO78 items were expert-selected, not systematically optimized.
5. Unmatched 2021/2022 records still need investigation.

## 7. Conclusion and Next Steps
The hypothesis is partially supported: SDO78 data improves ranking and retrieval metrics meaningfully and significantly, but model performance remains below project targets. Next steps are to investigate unmatched records, reassess support items, run systematic feature selection, and add new predictive data sources.
