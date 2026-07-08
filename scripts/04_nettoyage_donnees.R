###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 04_nettoyage_donnees.R
# Objet   : Nettoyer les données après contrôle qualité
###############################################################################

rm(list = ls())

source("scripts/03_controle_qualite_donnees.R")

# -------------Suppression des valeurs négatives -----------

# Justification :
# Les valeurs négatives représentent des cas très minoritaires.
# Elles correspondent probablement à des régularisations.
# Pour une analyse descriptive, elles sont exclues.

open_medic_clean <- open_medic_prepare |>
  filter(BOITES >= 0,REM >= 0,BSE >= 0)
glimpse(open_medic_clean)
message("Nettoyage étape 1 terminé : valeurs négatives supprimées.")



#-------------- Sélection des colonnes utiles --------

# Les variables techniques AGE, sexe, BEN_REG et PSP_SPE sont supprimées
# car leurs libellés sont plus explicites.
# Les codes ATC sont conservés car ils constituent une classification
# internationale utilisée en pharmacie.

open_medic_clean <- open_medic_clean |>
  select(
    atc1 = ATC1,
    lib_atc1,
    atc2 = ATC2,
    lib_atc2,
    atc3 = ATC3,
    lib_atc3,
    atc4 = ATC4,
    lib_atc4,
    atc5 = ATC5,
    lib_atc5,
    cip13 = CIP13,
    lib_cip13,
    top_gen = TOP_GEN,
    lib_top_gen,
    gen_num = GEN_NUM,
    lib_gen_num,
    tranche_age,
    sexe,
    region,
    prescripteur,
    boites = BOITES,
    remboursement = REM,
    base_remboursement = BSE
  )
glimpse(open_medic_clean)
message("Nettoyage étape 3 terminé : variables sélectionnées et renommées.")


#-------------- Traitement des modalités inconnues -----------------
# Décision :
# Les modalités inconnues ne sont pas supprimées.
# Elles correspondent à une information manquante mais exploitable.
# Elles sont conservées pour éviter de biaiser l'analyse.

open_medic_clean <- open_medic_clean |>
  mutate(tranche_age = if_else(tranche_age %in% c("INCONNU", "VALEUR INCONNUE", "AGE INCONNU"), "Inconnu", tranche_age),
    sexe = if_else(sexe %in% c("INCONNU", "VALEUR INCONNUE"),"Inconnu", sexe),
    region = replace_na(region, "Inconnu"),
    prescripteur = if_else(prescripteur %in% c("INCONNU", "VALEUR INCONNUE"),
                           "Inconnu", prescripteur)
  )

open_medic_clean |>count(tranche_age, sort = TRUE)
open_medic_clean |>count(sexe, sort = TRUE)
open_medic_clean |>count(region, sort = TRUE)
open_medic_clean |>count(prescripteur, sort = TRUE)


# ------------- Contrôle des CIP13 ----------------
# Décision :
# Les CIP13 ne sont pas supprimés.
# Un même médicament peut apparaître plusieurs fois car les données sont croisées
# par âge, sexe, région, prescripteur et classe ATC.

controle_cip13 <- open_medic_clean |>
  count(cip13, lib_cip13, sort = TRUE)
controle_cip13
nb_cip13_distincts <- n_distinct(open_medic_clean$cip13)
nb_cip13_distincts


# --------------- Journal des anomalies détectées ------------------

dir.create("outputs/anomalies", recursive = TRUE, showWarnings = FALSE)
registre_qualite <- tibble(
  id = c("AQ-001", "AQ-002", "AQ-003", "AQ-004"),
  anomalie = c(
    "Valeurs négatives",
    "Doublons du dictionnaire CIP13",
    "Modalités inconnues",
    "REM supérieur à BSE"
  ),
  nb_observations = c(
    nrow(valeurs_negatives),
    nrow(doublons_cip13),
    modalites_inconnues$age_inconnu +
      modalites_inconnues$sexe_inconnu +
      modalites_inconnues$region_inconnue +
      modalites_inconnues$prescripteur_inconnu,
    coherence_metier$rem_superieur_bse
  ),
  decision = c(
    "Supprimées",
    "Dernier libellé conservé",
    "Conservées",
    "Conservées"
  ),
  justification = c(
    "Régularisations ; impact inférieur à 0,01 %",
    "Historique probable des dénominations commerciales",
    "Information absente mais exploitable",
    "Probables effets d'agrégation ou d'arrondis"
  ),
  statut = c("Résolu", "Résolu", "Résolu", "À surveiller")
)
registre_qualite
write_csv(registre_qualite,"outputs/anomalies/registre_qualite_donnees.csv")
message("Registre de qualité des données créé.")



# ------------- Validation finale des données nettoyées -----


# Dimensions
dim(open_medic_clean)
# Structure
glimpse(open_medic_clean)

# Valeurs négatives restantes
open_medic_clean |>
  summarise(boites_neg = sum(boites < 0),
    remboursement_neg = sum(remboursement < 0),
    base_remboursement_neg = sum(base_remboursement < 0) )
# Valeurs manquantes
open_medic_clean |>
  summarise(across(everything(), ~sum(is.na(.)))) |>
  pivot_longer(
    everything(),
    names_to = "variable",
    values_to = "nb_na") |>
  arrange(desc(nb_na))

message("Validation finale terminée.")


#-------------- Sauvegarde des données nettoyées ------------

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
saveRDS(open_medic_clean, path_clean)
write_csv(open_medic_clean, file.path("data","processed",paste0("open_medic_clean_", annee_open_medic, ".csv")))
message("Données nettoyées sauvegardées pour l'année ", annee_open_medic, ".")