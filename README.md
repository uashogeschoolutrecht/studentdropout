# Predicting student drop-out
<a target="_blank" href="https://cookiecutter-data-science.drivendata.org/">
    <img src="https://img.shields.io/badge/CCDS-Project%20template-328F97?logo=cookiecutter" />
</a>

Project Lead = Bouba Ismalia & Fraukje Coopmans ([Data Science Pool](https://datasciencepool.hu.nl/))

Current drop-out rates of freshman students at the Hogeschool Utrecht averages 40% each year. We aim to create a ML-based tool that identifies freshman students at risk of dropping out early in their academic journey at Hogeschool Utrecht. This allows for timely interventions that are tailored to individual needs, thereby enhancing student success and promoting equity in educational outcomes.

Currently we are in Phase 2: extending the prototype model with more data, and we are loosely following the approach as proposed by [the Datacoalitie](https://datagedrevenonderzoekmbo.nl/themas/voorspelmodel/praktijkpilot-de-uitnodigingsregel/).

## Stakeholders & collaborators
- Rick Ikkersheim (previous Project Lead)
- Timme Stols (initial client)
- Team Data & Analytics
- Harald Breshamer (Analytics domain team Student & Marketing Analytics)
- Bram Versteeg (Analytics domain team Student & Marketing Analytics)
- Herbert Wubben (Analytics domain team Educational Analytics)
- Justian Knobbout (Analytics domain team Learning Analytics)

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
