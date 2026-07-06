# Description technique du projet

## Nom du projet

**Analyse des données Open Medic (AMELI)**

---

# Objectif

Ce projet a pour objectif de construire un workflow complet d'analyse de données pharmaceutiques à partir de la base Open Medic publiée par l'Assurance Maladie.

L'ensemble du projet est développé en **R** en suivant les bonnes pratiques de la Data Science afin de garantir la qualité, la reproductibilité et la traçabilité des traitements.

---

# Contexte

La base Open Medic est issue du **Système National des Données de Santé (SNDS)**.

Elle recense les remboursements de médicaments délivrés en pharmacie de ville selon plusieurs dimensions :

- classification ATC ;
- médicament (CIP13) ;
- tranche d'âge ;
- sexe ;
- région de résidence ;
- spécialité du prescripteur ;
- nombre de boîtes délivrées ;
- base de remboursement ;
- montant remboursé.

Les données utilisées sont publiques et disponibles sur la plateforme Open Data de l'Assurance Maladie.

---

# Architecture du projet

Le projet suit un pipeline reproductible.

```text
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
Analyse exploratoire
      │
      ▼
Visualisations
      │
      ▼
Machine Learning (à venir)
```

---

# Organisation des dossiers

```text
data/
│
├── raw/
├── processed/
└── dictionnaires/

scripts/

outputs/
├── anomalies/
├── figures/
├── rapports/
└── tableaux/

docs/
```

---

# Description des scripts

| Script | Description |
|---------|-------------|
| 01_import_donnees.R | Importation des données Open Medic et des dictionnaires |
| 02_preparation_donnees.R | Préparation des données et jointure des dictionnaires |
| 03_controle_qualite_donnees.R | Audit complet de la qualité des données |
| 04_nettoyage_donnees.R | Nettoyage, harmonisation et validation finale |
| 05_analyse_exploratoire.R | Analyse descriptive des données |
| 06_visualisations.R | Production des graphiques |

---

# Contrôle qualité des données

Avant toute transformation, un audit complet est réalisé.

Les contrôles portent notamment sur :

- dimensions du jeu de données ;
- structure des variables ;
- types des variables ;
- valeurs manquantes ;
- valeurs négatives ;
- doublons complets ;
- doublons dans les dictionnaires ;
- cohérence métier ;
- statistiques descriptives.

Les résultats sont exportés dans :

```text
outputs/tableaux/
```

---

# Nettoyage des données

Le nettoyage est réalisé uniquement après validation des contrôles qualité.

Les principales opérations sont :

- suppression des valeurs négatives ;
- harmonisation des modalités inconnues ;
- sélection des variables utiles ;
- renommage des variables ;
- validation finale ;
- sauvegarde des données nettoyées.

---

# Registre de qualité

Toutes les anomalies détectées sont documentées dans un registre de qualité.

Chaque anomalie est :

- identifiée ;
- quantifiée ;
- documentée ;
- justifiée ;
- associée à une décision de traitement.

Le registre est enregistré dans :

```text
outputs/anomalies/registre_qualite_donnees.csv
```

---

# Choix méthodologiques

Plusieurs décisions ont été prises au cours du projet.

## Doublons du dictionnaire CIP13

Le dictionnaire contient plusieurs codes CIP13 associés à plusieurs libellés.

Ces situations sont probablement liées à des changements de dénomination commerciale ou de laboratoire.

Pour ce projet, le dernier libellé disponible est conservé.

---

## Valeurs négatives

Les variables **BOITES**, **REM** et **BSE** présentent un très faible nombre de valeurs négatives.

Ces observations correspondent vraisemblablement à des opérations de régularisation.

Elles sont exclues dans le cadre de l'analyse descriptive.

---

## Modalités inconnues

Les modalités :

- INCONNU
- VALEUR INCONNUE

sont conservées et harmonisées sous la modalité :

```text
Inconnu
```

afin d'éviter toute perte d'information.

---

## Cohérence métier

Quelques observations présentent :

```text
REM > BSE
```

Ces cas restent très minoritaires.

Ils sont conservés et documentés dans le registre qualité, car ils peuvent résulter :

- d'effets d'agrégation ;
- d'arrondis ;
- de régularisations.

---

# Reproductibilité

L'ensemble du projet est reproductible.

Chaque script possède une responsabilité unique et respecte l'ordre suivant :

```text
01
↓
02
↓
03
↓
04
↓
05
↓
06
```

---

# Conventions de développement

Le projet respecte les conventions suivantes :

- un script = une responsabilité ;
- noms de variables explicites ;
- commentaires structurés ;
- documentation des décisions métier ;
- contrôle qualité avant nettoyage ;
- reproductibilité des traitements.

---

# Évolutions prévues

Les prochaines évolutions du projet seront :

- analyse exploratoire détaillée ;
- visualisations professionnelles ;
- tableaux de bord interactifs ;
- modèles de Machine Learning ;
- documentation technique enrichie.

---

# Auteur

**Bile Isaac**

Projet réalisé dans le cadre de la construction d'un portfolio professionnel en **Data Science**.
