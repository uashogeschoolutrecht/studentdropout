# Investigating 100 Dagen Monitor Data on Predicting Student Drop-out Model Performance

| | |
|---|---|
| **Author** | Fraukje Coopmans & Bouba Ismalia |
| **Date** | 2026-03-20 |
| **Status** | In Progress |

---

## 1. Problem statement
Currently the performance of the student drop-out prediction model is below our target metrics (i.e. recall < 75%, precision < 60% and F1 < 65%), hindering our ability to effectively identify at-risk students. We believe that the model's performance can be improved by incorporating additional data sources, such as the student behavior data collected in the 100 Dagen Monitor. 

## 2. Hypothesis
Student behavior data from the 100 Dagen Monitor significantly improves the performance of the student drop-out prediction model, leading to higher recall, precision, and F1-score compared to the current model without this data.

## 3. Background & Context
The 100 Dagen Monitor is a questionnaire that collects data on various aspects of student behavior, including engagement, support, stress, and motivation. Based on literature adding student behavior data, such as collecting in the 100 Dagen Monitor, can potentially improve a model's ability to predict drop-out cases. 

## 4. Data
The 100 Dagen Monitor datasets contain 2 seperate files for each year, one containing the questionnaire responses and one containing the corresponding student information. The questionnaire consists of about 100 questions (depending on the year). 

We have manually selected the following subset of questions from the 100 Dagen Monitor:
![alt text](img/sdo78_questions_selected.png)

The only criterium for selecting these questions was that they were present in all 3 years of the 100 Dagen Monitor data. Future work should involve a more systematic approach to selecting the most relevant questions for predicting drop-out cases.

## 5. Methods
- Topics with multiple questions were aggregated by calculating the mean of the responses to those questions. 
- Feature added: response type (Complete-responder, Partial-responder, Non-responder) to account for the different response types. 

_Describe the approach, models, preprocessing steps, and evaluation metrics used._

### 5.1 Preprocessing
Two changes were made to the ML pipeline to incorporate the 100 Dagen Monitor data:
- CV-10 was reduced to CV-5
- Low-frequency categories threshold was lowered from 100 to 50 to retain more information from the 100 Dagen Monitor data.

### 5.2 Model(s)
XGBoost

### 5.3 Evaluation Metrics
- Recall
- Precision
- F1-Score
- PR-AUC
- ROC-AUC

## 6. Results

_Present the results of the test. Use tables, figures, and metrics as appropriate._

### 6.1 Performance Comparison

| Model | Accuracy | Precision | Recall | F1-Score | PR-AUC | ROC-AUC |
|---|---|---|---|---|---|---|
| | | | | | | |

### 6.2 Key Observations


## 7. Discussion

_Interpret the results. Were they expected? What do they imply?_

### 7.1 Hypothesis Verdict

- **H₀ rejected / not rejected:**
- **Conclusion:**

### 7.2 Limitations
- Low response rate in the 100 Dagen Monitor may lead to biased results.
- The selected subset of questions may not capture all relevant aspects of student behavior.

## 8. Next Steps

_What follow-up actions or experiments are suggested by these results?_

- [ ] 

## 9. References

_Link to relevant notebooks, papers, or documentation._

- 