###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 03_controle_qualite_donnees.R
# Objet   : Auditer la qualité des données avant nettoyage
###############################################################################

rm(list = ls())

source("scripts/02_preparation_donnees.R")

# Dimensions
dim(open_medic_prepare)
nrow(open_medic_prepare)
ncol(open_medic_prepare)

# Structure des données
glimpse(open_medic_prepare)


# Types des variables
types_variables <- tibble(variable = names(open_medic_prepare),type = sapply(open_medic_prepare, class))
types_variables


# Valeurs manquantes
valeurs_manquantes <- open_medic_prepare |>
  summarise(across(everything(), ~ sum(is.na(.)))) |>
  pivot_longer(cols = everything(), names_to = "variable",values_to = "nb_na") |>
  mutate(pct_na = nb_na / nrow(open_medic_prepare) * 100) |>
  arrange(desc(nb_na))
valeurs_manquantes


# Valeurs négatives
valeurs_negatives_resume <- open_medic_prepare |>
  summarise(boites_neg = sum(BOITES < 0),
    rem_neg = sum(REM < 0),
    bse_neg = sum(BSE < 0),
    pct_boites_neg = mean(BOITES < 0) * 100,
    pct_rem_neg = mean(REM < 0) * 100,
    pct_bse_neg = mean(BSE < 0) * 100
  )
valeurs_negatives_resume

valeurs_negatives <- open_medic_prepare |>
  filter(BOITES < 0 | REM < 0 | BSE < 0)
valeurs_negatives



# Doublons complets dans la base principale
nb_doublons_complets <- open_medic_prepare |>
  duplicated() |>
  sum()
nb_doublons_complets

# Doublons dans les dictionnaires
doublons_cip13 <- cip13 |>
  count(CIP13) |>
  filter(n > 1)

doublons_top_gen <- top_gen |>
  count(TOP_GEN) |>
  filter(n > 1)

doublons_gen_num <- gen_num |>
  count(GEN_NUM) |>
  filter(n > 1)

doublons_age <- age |>
  count(AGE) |>
  filter(n > 1)

doublons_sexe <- sexe |>
  count(SEXE) |>
  filter(n > 1)

doublons_ben_reg <- ben_reg |>
  count(BEN_REG) |>
  filter(n > 1)

doublons_psp_spe <- psp_spe |>
  count(PSP_SPE) |>
  filter(n > 1)


resume_doublons_dictionnaires <- tibble(
  dictionnaire = c("CIP13", "TOP_GEN", "GEN_NUM", "AGE", "SEXE", "BEN_REG", "PSP_SPE"),
  nb_cles_dupliquees = c(
    nrow(doublons_cip13),
    nrow(doublons_top_gen),
    nrow(doublons_gen_num),
    nrow(doublons_age),
    nrow(doublons_sexe),
    nrow(doublons_ben_reg),
    nrow(doublons_psp_spe)
  )
)

resume_doublons_dictionnaires
doublons_cip13


# Contrôle des identifiants
controle_identifiants <- tibble(
  indicateur = c(
    "Nombre de CIP13 distincts",
    "Nombre de classes ATC5 distinctes",
    "Nombre de régions distinctes",
    "Nombre de spécialités prescripteurs distinctes"
  ),
  valeur = c(
    n_distinct(open_medic_prepare$CIP13),
    n_distinct(open_medic_prepare$ATC5),
    n_distinct(open_medic_prepare$BEN_REG),
    n_distinct(open_medic_prepare$PSP_SPE)
  )
)
controle_identifiants


# Modalités inconnues
modalites_inconnues <- open_medic_prepare |>
  summarise(
    age_inconnu = sum(tranche_age == "INCONNU", na.rm = TRUE),
    sexe_inconnu = sum(sexe == "VALEUR INCONNUE", na.rm = TRUE),
    region_inconnue = sum(region == "INCONNU", na.rm = TRUE),
    prescripteur_inconnu = sum(prescripteur == "VALEUR INCONNUE", na.rm = TRUE)
  )
modalites_inconnues


# Cohérence métier
coherence_metier <- open_medic_prepare |>
  summarise(
    boites_zero = sum(BOITES == 0),
    rem_zero = sum(REM == 0),
    bse_zero = sum(BSE == 0),
    bse_inferieur_rem = sum(BSE < REM, na.rm = TRUE),
    rem_superieur_bse = sum(REM > BSE, na.rm = TRUE)
  )
coherence_metier


# Statistiques descriptives
resume_numerique <- open_medic_prepare |>
  summarise(
    boites_min = min(BOITES, na.rm = TRUE),
    boites_median = median(BOITES, na.rm = TRUE),
    boites_max = max(BOITES, na.rm = TRUE),
    rem_min = min(REM, na.rm = TRUE),
    rem_median = median(REM, na.rm = TRUE),
    rem_max = max(REM, na.rm = TRUE),
    bse_min = min(BSE, na.rm = TRUE),
    bse_median = median(BSE, na.rm = TRUE),
    bse_max = max(BSE, na.rm = TRUE)
  )
resume_numerique


#  Export des contrôles
dir.create("outputs/tableaux", recursive = TRUE, showWarnings = FALSE)
write_csv(valeurs_manquantes, "outputs/tableaux/controle_valeurs_manquantes.csv")
write_csv(valeurs_negatives_resume, "outputs/tableaux/controle_valeurs_negatives.csv")
write_csv(controle_identifiants, "outputs/tableaux/controle_identifiants.csv")
write_csv(modalites_inconnues, "outputs/tableaux/controle_modalites_inconnues.csv")
write_csv(coherence_metier, "outputs/tableaux/controle_coherence_metier.csv")
write_csv(resume_numerique, "outputs/tableaux/resume_statistiques_numeriques.csv")
write_csv(resume_doublons_dictionnaires, "outputs/tableaux/controle_doublons_dictionnaires.csv")
write_csv(doublons_cip13, "outputs/tableaux/doublons_cip13.csv")

message("Contrôle qualité des données terminé pour l'année ", annee_open_medic, ".")