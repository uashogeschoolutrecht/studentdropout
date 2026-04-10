# Appendix A — Final CV-10 Validation Snapshot (SDO78)

**Date**: 2026-04-09  
**Status**: Appendix (summary)

Primary report: [20260325_sdo78_data_performance full model.md](20260325_sdo78_data_performance%20full%20model.md)

---

This appendix captures the final validation run used to finalize the SDO78 integration conclusions.

## Validation Scope
- End-to-end rerun with production setting: Stratified CV-10, 5 repeats
- Dataset after full pipeline: 21,595 students
- Features: 76 (without SDO78) vs 88 (with SDO78)

## Key Data Quality Checks
- SDO78 matched records retained: 3,940 of 4,233 (93.1%)
- Dropped unmatched: 293 (6.9%)
- Cronbach alpha: Support_Avg = 0.470 (low), Belonging_Avg = 0.713 (acceptable)

## Final SDO78 Impact (Tuned XGBoost, CV Means)

| Metric | Without SDO78 | With SDO78 | Delta | p-value |
|---|---:|---:|---:|---:|
| PR-AUC | 0.6366 | **0.6463** | +0.0097 | < 0.001 |
| ROC-AUC | 0.7772 | **0.7866** | +0.0094 | < 0.001 |
| Recall | 0.6786 | **0.6989** | +0.0203 | < 0.001 |
| F1 | 0.6060 | **0.6141** | +0.0081 | < 0.001 |
| Accuracy | 0.7169 | 0.7181 | +0.0012 | 0.288 |
| Precision | 0.5477 | 0.5478 | +0.0001 | 0.833 |

Conclusion: SDO78 adds statistically significant gains in PR-AUC, ROC-AUC, Recall, and F1, while Accuracy and Precision remain unchanged.
