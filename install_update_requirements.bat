@echo off
pip install %*
pip freeze > requirements.txt
