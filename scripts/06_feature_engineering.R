###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 06_feature_engineering.R
# Objet   : Créer de nouvelles variables métier
###############################################################################
rm(list = ls())
library(tidyverse)

# ------------- Chargement des données nettoyées -------------------

path_data <- "data/processed/open_medic_clean.rds"
stopifnot(file.exists(path_data))
open_medic_clean <- readRDS(path_data)
glimpse(open_medic_clean)
message("Données nettoyées chargées.")

# ============= Taux de remboursement ==============
# Question métier :
# Quelle proportion de la base de remboursement est effectivement prise
# en charge par l'Assurance Maladie ?

open_medic_features <- open_medic_features |>
  mutate(taux_remboursement = if_else(base_remboursement > 0,remboursement / base_remboursement,NA_real_ ))
glimpse(open_medic_features)
message("Variable créée : taux_remboursement.")


# ============ Reste à charge ==============

# Question métier :
# Quel est le montant restant à la charge du patient après remboursement
# par l'Assurance Maladie ?

open_medic_features <- open_medic_features |>
  mutate(reste_a_charge = if_else(base_remboursement >= remboursement,base_remboursement - remboursement,NA_real_))
glimpse(open_medic_features)
message("Variable créée : reste_a_charge.")


# =========== Reste à charge par boîte =============

# Question métier :
# Quel est le reste à charge moyen par boîte délivrée ?

open_medic_features <- open_medic_features |>
  mutate(reste_a_charge_boite = if_else(boites > 0,reste_a_charge / boites,NA_real_))
glimpse(open_medic_features)
message("Variable créée : reste_a_charge_boite.")


#=============== Base de remboursement par boîte ===========

# Question métier :
# Quelle est la base moyenne de remboursement pour une boîte délivrée ?

open_medic_features <- open_medic_features |>
  mutate(base_par_boite = if_else(boites > 0,base_remboursement / boites,NA_real_))
glimpse(open_medic_features)
message("Variable créée : base_par_boite.")


# ============= Remboursement par boîte ===========

# Question métier :
# Quel est le remboursement moyen versé par boîte délivrée ?

open_medic_features <- open_medic_features |>
  mutate(remboursement_par_boite = if_else(boites > 0,remboursement / boites,NA_real_ ))
glimpse(open_medic_features)
message("Variable créée : remboursement_par_boite.")


# ============== Catégorie de consommation ===============

# Question métier :
# Ce médicament est-il peu ou fortement consommé ?

open_medic_features <- open_medic_features |>
  mutate(categorie_consommation = case_when(
      boites <= quantile(boites, 0.25, na.rm = TRUE) ~ "Faible",
      boites <= quantile(boites, 0.50, na.rm = TRUE) ~ "Moyenne",
      boites <= quantile(boites, 0.75, na.rm = TRUE) ~ "Forte",TRUE ~ "Très forte"))
count(open_medic_features, categorie_consommation)
message("Variable créée : categorie_consommation.")



#=============== Catégorie de remboursement =============

# Question métier :
# Ce médicament représente-t-il un faible ou un fort remboursement ?

open_medic_features <- open_medic_features |>
  mutate(categorie_remboursement = case_when(
      remboursement <= quantile(remboursement, 0.25, na.rm = TRUE) ~ "Faible",
      remboursement <= quantile(remboursement, 0.50, na.rm = TRUE) ~ "Moyen",
      remboursement <= quantile(remboursement, 0.75, na.rm = TRUE) ~ "Élevé",TRUE ~ "Très élevé"))
count(open_medic_features, categorie_remboursement)
message("Variable créée : categorie_remboursement.")


# ============= Part des remboursements===========

# Question métier :
# Quelle est la contribution de chaque observation au montant total des
# remboursements ?

total_remboursement <- sum(open_medic_features$remboursement, na.rm = TRUE)
open_medic_features <- open_medic_features |>
  mutate(part_remboursement = remboursement / total_remboursement)
summary(open_medic_features$part_remboursement)
message("Variable créée : part_remboursement.")


# ================= Part des boîtes délivrées ============

# Question métier :
# Quelle est la contribution de chaque observation au volume total de boîtes
# délivrées ?


total_boites <- sum(open_medic_features$boites, na.rm = TRUE)
open_medic_features <- open_medic_features |>
  mutate(part_boites = boites / total_boites)
summary(open_medic_features$part_boites)
message("Variable créée : part_boites.")



# =============== Indice budgétaire ===========

# Question métier :
# Quels médicaments ont le plus d'impact sur les dépenses de l'Assurance
# Maladie ?

open_medic_features <- open_medic_features |>
  mutate(indice_budget = remboursement * boites)
summary(open_medic_features$indice_budget)
message("Variable créée : indice_budget.")



# ============= Impact budgétaire =============

# Question métier :
# Ce médicament représente-t-il un faible ou un fort impact sur le budget
# de l'Assurance Maladie ?

q1 <- quantile(open_medic_features$indice_budget, 0.25, na.rm = TRUE)
q2 <- quantile(open_medic_features$indice_budget, 0.50, na.rm = TRUE)
q3 <- quantile(open_medic_features$indice_budget, 0.75, na.rm = TRUE)
open_medic_features <- open_medic_features |>
  mutate(impact_budgetaire = case_when(
      indice_budget <= q1 ~ "Faible",
      indice_budget <= q2 ~ "Moyen",
      indice_budget <= q3 ~ "Fort",TRUE ~ "Critique"))
count(open_medic_features, impact_budgetaire)
message("Variable créée : impact_budgetaire.")


# +++++++++++++++++++ Sauvegarde des  données enrichies ++++++++++++++++++


dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

saveRDS(open_medic_features,"data/processed/open_medic_features.rds")
write_csv(open_medic_features,"data/processed/open_medic_features.csv")
message("Feature engineering terminé avec succès.")