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
  select(ATC1, l_ATC1,ATC2, L_ATC2,ATC3, L_ATC3,
    ATC4, L_ATC4,ATC5, L_ATC5,CIP13, `Libellé CIP13`,
    `Libellé Tranche d'Age Bénéficiaire`,
    `Libellé Sexe du Bénéficiaire`,
    `Libellé Région de Résidence du Bénéficiaire`,
    `Libellé Prescripteur`,BOITES, REM, BSE
  )
glimpse(open_medic_clean)
message("Nettoyage étape 2 terminé : colonnes pas importants supprimées.")


#------------------- Renommage des variables ------------------
open_medic_clean <- open_medic_clean |>
  rename(
    atc1 = ATC1,
    lib_atc1 = l_ATC1,
    atc2 = ATC2,
    lib_atc2 = L_ATC2,
    atc3 = ATC3,
    lib_atc3 = L_ATC3,
    atc4 = ATC4,
    lib_atc4 = L_ATC4,
    atc5 = ATC5,
    lib_atc5 = L_ATC5,
    cip13 = CIP13,
    lib_cip13 = `Libellé CIP13`,
    tranche_age = `Libellé Tranche d'Age Bénéficiaire`,
    sexe = `Libellé Sexe du Bénéficiaire`,
    region = `Libellé Région de Résidence du Bénéficiaire`,
    prescripteur = `Libellé Prescripteur`,
    boites = BOITES,
    remboursement = REM,
    base_remboursement = BSE
  )
glimpse(open_medic_clean)
message("Nettoyage étape 3 terminé : variables renommées.")




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





# ------------- Journal des anomalies -------------
anomalies <- tibble(
  anomalie = c(
    "Valeurs négatives",
    "Doublons dans le dictionnaire CIP13",
    "Modalités inconnues",
    "REM supérieur à BSE"
  ),
  nb_observations = c(
    nrow(valeurs_negatives),
    nrow(doublons_cip13),
    modalites_inconnues$prescripteur_inconnu +
      modalites_inconnues$age_inconnu +
      modalites_inconnues$sexe_inconnu +
      modalites_inconnues$region_inconnue,
    coherence_metier$rem_superieur_bse
  ),
  decision = c(
    "Supprimées",
    "Dernier libellé conservé",
    "Conservées",
    "À analyser"
  )
)
anomalies




# --------------- Journal des anomalies détectées ------------------

dir.create("outputs/anomalies", recursive = TRUE, showWarnings = FALSE)
anomalies <- tibble(
  anomalie = c(
    "Valeurs négatives",
    "Doublons dans le dictionnaire CIP13",
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
    "Supprimées pour l'analyse descriptive",
    "Dernier libellé conservé lors de la préparation",
    "Conservées et harmonisées sous la modalité 'Inconnu'",
    "Conservées pour analyse complémentaire"
  )
)
write_csv(anomalies, "outputs/anomalies/journal_anomalies.csv")
anomalies