# Predicting student drop-out
<a target="_blank" href="https://cookiecutter-data-science.drivendata.org/">
    <img src="https://img.shields.io/badge/CCDS-Project%20template-328F97?logo=cookiecutter" />
</a>

Project Lead = Bouba Ismalia & Fraukje Coopmans ([Data Science Pool](https://datasciencepool.hu.nl/))

Collaborators: 
- Anne Leemans (Team Data & Analytics)
- Harald Breshamer (Analytics domain team Student & Marketing Analytics)
- Bram Versteeg (Analytics domain team Student & Marketing Analytics)

# Goal
Current drop-out rates of freshman students at the Hogeschool Utrecht averages 40% each year. We aim to create a ML-based tool that identifies freshman students at risk of dropping out early in their academic journey at Hogeschool Utrecht. This allows for timely interventions that are tailored to individual needs, thereby enhancing student success and promoting equity in educational outcomes.

Currently we are in Phase 2: extending the prototype model with more data, and we loosely follow the approach as proposed by [the Datacoalitie](https://datagedrevenonderzoekmbo.nl/themas/voorspelmodel/praktijkpilot-de-uitnodigingsregel/). The goal of this phase is to predict freshman student drop-out with an accuracy of 75+%, a recall of 70+%, a precision of 60+% and a F1 score of 65+% [add references].

## Stakeholders & collaborators
- Timme Stols (Team Digitale Leeromgeving)
- Klaske de Hoop (Team Data & Analytics)
- Rick Ikkersheim (Program Manager Student Sucess)
- Gerwin Hendriks (Team Institutional Research)
- Justian Knobbout (Analytics domain team Learning Analytics)

## Data
The following data will be used to train the ML model to predict student drop-out and is collected on a student-enrollment granularity:
- 1. Student characteristics at enrollment
    - Gender
    - Age (feature: age group at enrollment)
    - Dutch national [yes/no]
    - Postal code (feature: travel distance to university)
    - Previous education postal code (feature: previous education distance to university) 
    - Previous education level
    - Is previous education a foreign degree [yes/no]
    - Previous education profile
    - Previous education school graduation rate
    - Previous education average exam grade
    - Exam date (feature: time since previous education graduation)
- 2. Student orientation
    - Number of events attended
    - Type of events attended
    - Time before start degree
    - Timing of event within the year
    - Advice from Choice of Degree Check (SKC)
- 3. Student application
    - Number of applications
    - Date of application
    - Previous enrollments
    - Previous enrollment in same domain
- 4. Degree characteristics
    - Name of degree
    - Entry requirements
    - Binding Study Advice (BSA) [yes/no]
    - Urgent Study Advice (DSA) [yes/no]
- 5. Enrollment characteristics
    - Collegeyear
    - Propedeuse obtained [yes/no]
    - Drop-out [yes/no]
    - Degree switch [yes/no] -> ask business
- 6. Course results
    - Average degree after block A
    - Average degree after block B
    - Total number of credits after block A
    - Potential number of credits after block A
    - Total number of credits after block B
    - Potential number of credits after blok B
- 7. Student motivation & involvement
    - happiness with current choice of degree
    - intention to finish degree
    - perceived transition between previous eduction and current degree
    - perceived problems within the degree
    - perceived bond (with degree, teachers, peers, etc.)
    - perceived support 
    - rating of atmosphere
- 8. Student well-being
    - perceived stress level
    - perceived energy level
    - perceived pressure

## Features


### Impossible sources of extra data
- Course attendance? Is not available currently
- Course digital attendance? Is possibly available in Canvas

### Scope
Only the following students are included to limit the scope:
- First year's (freshmen)
- Bachelor degree
- Full-time
- Enrolled
- Not a minor/exchange
- Start period = 1st of september

Exclude non-typical degrees? E.g. law, nursing

#### Training data scope
- Collegeyear between 2018 and 2023

## Project Organization

```
├── LICENSE            <- Open-source license if one is chosen
├── Makefile           <- Makefile with convenience commands like `make data` or `make train`
├── README.md          <- The top-level README for developers using this project.
├── data
│   ├── external       <- Data from third party sources.
│   ├── interim        <- Intermediate data that has been transformed.
│   ├── processed      <- The final, canonical data sets for modeling.
│   └── raw            <- The original, immutable data dump.
│
├── docs               <- A default mkdocs project; see mkdocs.org for details
│
├── models             <- Trained and serialized models, model predictions, or model summaries
│
├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
│                         the creator's initials, and a short `-` delimited description, e.g.
│                         `1.0-jqp-initial-data-exploration`.
│
├── pyproject.toml     <- Project configuration file with package metadata for studentdropout
│                         and configuration for tools like black
│
├── references         <- Data dictionaries, manuals, and all other explanatory materials.
│
├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
│   └── figures        <- Generated graphics and figures to be used in reporting
│
├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
│                         generated with `pip freeze > requirements.txt`
│
├── setup.cfg          <- Configuration file for flake8
│
└── studentdropout                <- Source code for use in this project.
    │
    ├── __init__.py    <- Makes studentdropout a Python module
    │
    ├── data           <- Scripts to download or generate data
    │   └── make_dataset.py
    │
    ├── features       <- Scripts to turn raw data into features for modeling
    │   └── build_features.py
    │
    ├── models         <- Scripts to train models and then use trained models to make
    │   │                 predictions
    │   ├── predict_model.py
    │   └── train_model.py
    │
    └── visualization  <- Scripts to create exploratory and results oriented visualizations
        └── visualize.py
```

--------
