###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 02_preparation_donnees.R
# Objet   : Préparer les données avec les dictionnaires
###############################################################################

rm(list = ls())

source("scripts/01_import_donnees.R")
open_medic <- open_medic |>
  rename_with(toupper)

# Harmonisation des noms de colonnes des dictionnaires
cip13 <- cip13 |> rename_with(toupper)
top_gen <- top_gen |> rename_with(toupper)
gen_num <- gen_num |> rename_with(toupper)
age <- age |> rename_with(toupper)
sexe <- sexe |> rename_with(toupper)
ben_reg <- ben_reg |> rename_with(toupper)
psp_spe <- psp_spe |> rename_with(toupper)

# Conversion des clés de jointure
open_medic <- open_medic |>
  mutate(
    BEN_REG = as.character(BEN_REG),
    CIP13 = as.character(CIP13),
    TOP_GEN = as.character(TOP_GEN),
    GEN_NUM = as.character(GEN_NUM),
    AGE = as.character(AGE),
    SEXE = as.character(SEXE),
    PSP_SPE = as.character(PSP_SPE)
  )

cip13 <- cip13 |>
  mutate(CIP13 = as.character(CIP13)) |>
  group_by(CIP13) |>
  slice_tail(n = 1) |>
  ungroup()

top_gen <- top_gen |> mutate(TOP_GEN = as.character(TOP_GEN))
gen_num <- gen_num |> mutate(GEN_NUM = as.character(GEN_NUM))
age <- age |> mutate(AGE = as.character(AGE))
sexe <- sexe |> mutate(SEXE = as.character(SEXE))
ben_reg <- ben_reg |> mutate(BEN_REG = as.character(BEN_REG))
psp_spe <- psp_spe |> mutate(PSP_SPE = as.character(PSP_SPE))

open_medic_prepare <- open_medic |>
  left_join(cip13, by = "CIP13") |>
  left_join(top_gen, by = "TOP_GEN") |>
  left_join(gen_num, by = "GEN_NUM") |>
  left_join(age, by = "AGE") |>
  left_join(sexe, by = "SEXE") |>
  left_join(ben_reg, by = "BEN_REG") |>
  left_join(psp_spe, by = "PSP_SPE")

open_medic_prepare <- open_medic_prepare |>
  rename(
    lib_cip13 = `LIBELLÉ CIP13`,
    lib_top_gen = `LIBELLÉ TOP GÉNÉRIQUE`,
    lib_gen_num = `LIBELLÉ NUMÉRO GROUPE GÉNÉRIQUE`,
    tranche_age = `LIBELLÉ TRANCHE D'AGE BÉNÉFICIAIRE`,
    sexe = `LIBELLÉ SEXE DU BÉNÉFICIAIRE`,
    region = `LIBELLÉ RÉGION DE RÉSIDENCE DU BÉNÉFICIAIRE`,
    prescripteur = `LIBELLÉ PRESCRIPTEUR`
  ) |>
  rename(
    lib_atc1 = L_ATC1,
    lib_atc2 = L_ATC2,
    lib_atc3 = L_ATC3,
    lib_atc4 = L_ATC4,
    lib_atc5 = L_ATC5
  )

# Contrôle
glimpse(open_medic_prepare)

message("Préparation des données terminée pour l'année ", annee_open_medic, ".")