# 💊 Analyse exploratoire des remboursements de médicaments en France

## Données Open Medic — Assurance Maladie (AMELI)

<p align="center">

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![tidyverse](https://img.shields.io/badge/tidyverse-1A162D?style=for-the-badge&logo=rstudio)
![ggplot2](https://img.shields.io/badge/ggplot2-DataViz-blue?style=for-the-badge)
![R Markdown](https://img.shields.io/badge/R%20Markdown-Report-orange?style=for-the-badge)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github)

</p>

---

# Présentation

Ce projet propose une analyse exploratoire des données **Open Medic** publiées par l'Assurance Maladie.

L'objectif est de construire un workflow complet d'analyse de données pharmaceutiques avec **R**, depuis l'importation des données jusqu'à la production d'indicateurs, de visualisations et d'un rapport métier permettant de mieux comprendre les remboursements de médicaments en France.

Cette étude met l'accent sur la production d'**insights métier** à partir de données publiques de santé, en appliquant une démarche reproductible de Data Analytics sous R.

---

# Rapport métier

➡️ https://bileisaac.github.io/open-medic-ameli-analysis/article_open_medic.html.

---

# Contexte

Les données **Open Medic** proviennent du **Système National des Données de Santé (SNDS)**.

Elles recensent les remboursements de médicaments délivrés en pharmacie de ville selon plusieurs dimensions :

- classification ATC ;
- médicament ;
- région ;
- sexe ;
- tranche d'âge ;
- spécialité du prescripteur ;
- montants remboursés ;
- nombre de boîtes délivrées.

Ces données sont librement accessibles via la plateforme Open Data de l'Assurance Maladie.

---

# Objectifs

Les principaux objectifs du projet sont :

- importer les données Open Medic ;
- préparer les données ;
- réaliser un audit de la qualité des données ;
- nettoyer les données ;
- documenter les décisions de traitement ;
- construire un registre de qualité des données ;
- créer des variables métier ;
- réaliser une analyse exploratoire orientée métier ;
- produire des visualisations professionnelles ;
- générer un rapport d'analyse reproductible avec R Markdown.

---

# Pipeline du projet

```text
Données Open Medic
        │
        ▼
Importation
        │
        ▼
Préparation
        │
        ▼
Contrôle qualité
        │
        ▼
Nettoyage
        │
        ▼
Feature engineering
        │
        ▼
Analyse exploratoire
        │
        ▼
Visualisations
        │
        ▼
Rapport métier
```

---

# Structure du dépôt

```text
open-medic-ameli-analysis/

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
│   ├── 06_feature_engineering.R
│   ├── 07_visualisations.R
│   └── 08_article_metier.Rmd
│
├── outputs/
│   ├── anomalies/
│   ├── figures/
│   ├── rapports/
│   └── tableaux/
│
├── docs/
│   └── article_open_medic.html
│
├── README.md
├── DESCRIPTION.md
├── .gitignore
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
| Cartographie | sf, mapsf |
| Rapport | R Markdown |
| Documentation | Markdown |
| Versionning | Git & GitHub |

---

# Données utilisées

Le projet utilise :

- Open Medic AMELI 2025 ;
- dictionnaires descriptifs AMELI ;
- classification ATC ;
- tables de correspondance associées.

Les fichiers de données ne sont pas versionnés dans le dépôt afin de respecter les bonnes pratiques GitHub.

---

# Analyses réalisées

L'analyse répond à plusieurs questions métier :

- Quelle est l'ampleur du marché des médicaments remboursés ?
- Quels médicaments représentent les montants remboursés les plus élevés ?
- Quels médicaments sont les plus délivrés ?
- Les médicaments les plus remboursés sont-ils aussi les plus délivrés ?
- Quelles classes thérapeutiques concentrent les remboursements ?
- Quelle est la place des médicaments génériques ?
- Comment les remboursements se répartissent-ils selon l'âge et le sexe ?
- Les dépenses sont-elles réparties de manière homogène entre les régions ?
- Quelles spécialités médicales génèrent les plus forts remboursements ?
- Les remboursements sont-ils concentrés sur une faible proportion de médicaments ?
- Quels médicaments présentent un fort impact budgétaire ?
- Quels médicaments présentent le remboursement moyen par boîte le plus élevé ?

---

# Qualité des données

Le projet intègre un audit qualité avant tout nettoyage.

Les contrôles réalisés portent notamment sur :

- les valeurs manquantes ;
- les valeurs négatives ;
- les doublons complets ;
- les doublons dans les dictionnaires ;
- les modalités inconnues ;
- la cohérence métier ;
- les valeurs atypiques.

Un registre de qualité des données est produit dans :

```text
outputs/anomalies/
```

---

# Visualisations produites

Le projet produit plusieurs visualisations professionnelles :

- cartes KPI de synthèse ;
- top médicaments remboursés ;
- top médicaments délivrés ;
- comparaison remboursement versus volume ;
- treemap des classes thérapeutiques ;
- analyse des génériques ;
- heatmap âge × sexe ;
- carte régionale ;
- analyse des prescripteurs ;
- courbe de concentration ;
- quadrant coût-volume ;
- classification de l'impact budgétaire ;
- coût moyen par boîte.

Les figures sont enregistrées dans :

```text
outputs/figures/
```

---

# Avancement du projet

| Étape | Statut |
|---------|:------:|
| Création du dépôt | ✅ |
| Documentation | ✅ |
| Importation des données | ✅ |
| Préparation des données | ✅ |
| Contrôle qualité | ✅ |
| Nettoyage des données | ✅ |
| Feature engineering | ✅ |
| Analyse exploratoire | ✅ |
| Visualisations | ✅ |
| Rapport métier HTML | ✅ |

---

# Évolutions possibles

Des prolongements possibles du projet seraient :

- publication du rapport via GitHub Pages ;
- amélioration du design du rapport HTML ;
- création d'une version PDF téléchargeable ;
- création d'un tableau de bord interactif Shiny ;
- comparaison avec plusieurs années Open Medic ;
- analyse plus détaillée par classe thérapeutique ;
- analyse régionale rapportée à la population.

---

# Auteur

**Bile Isaac**

Data Analytics • Data Science • R • Visualisation • Santé

---

> **Objectif du projet :** proposer une analyse exploratoire reproductible des données Open Medic en appliquant les bonnes pratiques de la Data Science : importation, contrôle qualité, préparation, nettoyage, visualisation et production d'insights métier.
