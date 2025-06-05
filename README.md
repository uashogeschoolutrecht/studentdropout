# Predicting student drop-out
<a target="_blank" href="https://cookiecutter-data-science.drivendata.org/">
    <img src="https://img.shields.io/badge/CCDS-Project%20template-328F97?logo=cookiecutter" />
</a>

Project Lead = Bouba Ismalia & Fraukje Coopmans ([Data Science Pool](https://datasciencepool.hu.nl/))

Current drop-out rates of freshman students at the Hogeschool Utrecht averages 40% each year. We aim to create a ML-based tool that identifies freshman students at risk of dropping out early in their academic journey at Hogeschool Utrecht. This allows for timely interventions that are tailored to individual needs, thereby enhancing student success and promoting equity in educational outcomes.

Currently we are in Phase 2: extending the prototype model with more data, and we are loosely following the approach as proposed by [the Datacoalitie](https://datagedrevenonderzoekmbo.nl/themas/voorspelmodel/praktijkpilot-de-uitnodigingsregel/).


## Stakeholders & collaborators
- Timme Stols (Team Digitale Leeromgeving)
- Klaske de Hoop (Team Data & Analytics)
- Harald Breshamer (Analytics domain team Student & Marketing Analytics)
- Bram Versteeg (Analytics domain team Student & Marketing Analytics)
- Rick Ikkersheim (Program Manager Student Sucess)
- Herbert Wubben (Analytics domain team Educational Analytics)
- Justian Knobbout (Analytics domain team Learning Analytics)

## Data
The following data will be used to train the ML model to predict student drop-out and is collected on a student granularity:
- Student characteristics
    - Gender
    - Age at enrollment
    - Dutch national [yes/no]
    - Travel distance to university at enrollment
    - Previous education level
    - Time since previous education graduation (?)
- Student orientation
    - Number of events attended
    - What else? > advice Bram needed!
    - Advice from Choice of Degree Check (SKC) (?)
- Student application
    - Number of applications (?)
    - Date of application (?) 
    - Previous enrollments (?)
- Degree characteristics
    - Name of degree
    - Binding Study Advice (BSA) [yes/no]
    - Urgent Study Advice (DSA) [yes/no]
- Enrollment characteristics
    - Collegeyear
    - Propedeuse obtained [yes/no]
    - Drop-out [yes/no]
    - Degree switch [yes/no] >> exclude?
- Course results
    - Average degree after block A
    - Average degree after block B
    - Total number of credits after block A
    - Total number of credits after block B
    - Get advice from Harald?
- Student motivation & involvement
    - happiness with current choice of degree
    - intention to finish degree
    - perceived transition between previous eduction and current degree
    - perceived problems within the degree
    - perceived bond (with degree, teachers, peers, etc.)
    - perceived support 
    - rating of atmosphere
- Student well-being
    - perceived stress level
    - perceived energy level
    - perceived pressure

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
