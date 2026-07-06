# 💊 Analyse des données Open Medic (AMELI)

<p align="center">

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![tidyverse](https://img.shields.io/badge/tidyverse-1A162D?style=for-the-badge&logo=rstudio)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github)
![Licence MIT](https://img.shields.io/badge/Licence-MIT-success?style=for-the-badge)

</p>

---

# Présentation

Ce projet propose une analyse exploratoire des données **Open Medic** publiées par l'Assurance Maladie (AMELI).

L'objectif est de construire un workflow complet d'analyse de données pharmaceutiques avec **R**, depuis l'importation des données jusqu'à la production d'indicateurs et de visualisations permettant de mieux comprendre les remboursements de médicaments en France.

Ce projet s'inscrit dans la construction de mon portfolio de **Data Scientist**.

---

# Contexte

Les données **Open Medic** proviennent du **Système National des Données de Santé (SNDS)**.

Elles recensent les remboursements de médicaments délivrés en pharmacie de ville selon plusieurs dimensions :

- Classification ATC
- Médicament (CIP13)
- Région
- Sexe
- Classe d'âge
- Spécialité du prescripteur
- Montants remboursés
- Nombre de boîtes délivrées

Ces données sont librement accessibles via la plateforme Open Data de l'Assurance Maladie.

---

# Objectifs

Les principaux objectifs sont :

- Importer les données Open Medic
- Préparer les données
- Réaliser un audit de la qualité des données
- Nettoyer les données
- Documenter les décisions de traitement
- Construire un registre de qualité des données
- Réaliser une analyse exploratoire (EDA)
- Produire des visualisations professionnelles
- Préparer les données pour des modèles de Machine Learning

---

# Architecture du projet

```text
Données Open Medic
        │
        ▼
 Importation
        │
        ▼
 Nettoyage
        │
        ▼
 Analyse exploratoire
        │
 ┌──────┴─────────┐
 ▼                ▼
Indicateurs   Visualisations
        │
        ▼
 Conclusions
```

---

# Structure du dépôt

```text
open-medic-ameli-analysis/

│
├── data/
│   ├── raw/
│   ├── processed/
│   └── dictionnaires/
│
├── scripts/
│   ├── 01_import_donnees.R
│   ├── 02_preparation_donnees.R
│   ├── 03_controle_qualite_donnees.R
│   ├── 04_nettoyage_donnees.R
│   ├── 05_analyse_exploratoire.R
│   └── 06_visualisations.R
│
├── outputs/
│   ├── anomalies/
│   ├── figures/
│   ├── rapports/
│   └── tableaux/
│
├── docs/
│
├── README.md
├── DESCRIPTION.md
│
└── LICENSE
```

---

# Technologies utilisées

| Domaine | Outils |
|----------|---------|
| Langage | R |
| Manipulation de données | tidyverse |
| Import Excel | readxl |
| Visualisation | ggplot2 |
| Documentation | R Markdown |
| Versionning | Git & GitHub |

---

# Jeux de données

Le projet utilise :

- Open Medic
- Dictionnaires AMELI
- Classification ATC
- Tables descriptives associées

---

# Analyses réalisées

Les analyses porteront notamment sur :
- Audit de la qualité des données
- Contrôle des valeurs manquantes
- Contrôle des doublons
- Contrôle de la cohérence métier
- Distribution des remboursements
- Médicaments les plus remboursés
- Analyse par classe ATC
- Analyse régionale
- Analyse par âge
- Analyse par sexe
- Analyse des spécialités médicales
- Détection des valeurs atypiques

---

# Évolutions prévues

Les prochaines étapes du projet seront :

- Création d'indicateurs métier
- Tableaux de bord interactifs
- Rapports automatisés
- Modèles de Machine Learning
- Prévision des remboursements
- Classification des médicaments

---

# Avancement du projet

| Étape | Statut |
|---------|:------:|
| Création du dépôt | ✅ |
| Documentation | ✅ |
| Importation des données | ✅ |
| Préparation des données | ✅ |
| Contrôle qualité des données | ✅ |
| Nettoyage des données | ✅ |
| Analyse exploratoire | ⏳ |
| Visualisations | ⏳ |
| Dashboard | ⏳ |
| Machine Learning | ⏳ |

---

# Auteur

**Bile Isaac**

Portfolio Data Science • Analyse de données • Machine Learning • Pharmacie

---

> **Objectif du projet :** développer une analyse reproductible des données Open Medic en appliquant les bonnes pratiques de la Data Science avec R. Le projet applique les bonnes pratiques de la Data Science en séparant les étapes d'importation, de préparation, d'audit qualité, de nettoyage et d'analyse des données afin de garantir la reproductibilité des traitements.
