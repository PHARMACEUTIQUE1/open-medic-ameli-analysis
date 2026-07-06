# Description du projet

## Nom

**Analyse des données Open Medic (AMELI)**

---

# Objectif

Ce projet a pour objectif de réaliser une analyse exploratoire des données Open Medic publiées par l'Assurance Maladie.

L'analyse suit un workflow reproductible en R, depuis l'importation des données jusqu'à la production d'indicateurs et de visualisations.

---

# Source des données

Les données proviennent de la plateforme Open Data de l'Assurance Maladie.

Jeux de données utilisés :

- OPEN_MEDIC_2025.csv
- descriptif.xls

---

# Organisation des données

- `data/raw/` : données brutes
- `data/interim/` : données intermédiaires
- `data/processed/` : données nettoyées
- `data/dictionnaires/` : dictionnaires des variables

---

# Organisation des scripts

Les scripts seront numérotés afin de respecter l'ordre d'exécution.

Exemple :

- 01_import_donnees.R
- 02_preparation_donnees.R
- 03_nettoyage_donnees.R
- 04_analyse_exploratoire.R
- 05_visualisations.R

---

# Convention de nommage

- noms de fichiers en minuscules
- mots séparés par "_"
- un script = une tâche principale

---

# Packages principaux

- tidyverse
- readxl
- janitor
- ggplot2

---

# Auteur

**Bile Isaac**

Projet réalisé dans le cadre de la construction d'un portfolio professionnel en Data Science.
