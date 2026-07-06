###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 02_preparation_donnees.R
# Objet   : Préparer les données avec les dictionnaires
###############################################################################

rm(list = ls())

source("scripts/01_import_donnees.R")

# Conversion des clés de jointure
open_medic_2025 <- open_medic_2025 |>
  mutate(
    BEN_REG = as.character(BEN_REG),
    CIP13 = as.character(CIP13),
    TOP_GEN = as.character(TOP_GEN),
    GEN_NUM = as.character(GEN_NUM),
    sexe = as.character(sexe),
    PSP_SPE = as.character(PSP_SPE)
  )

cip13 <- cip13 |> mutate(CIP13 = as.character(CIP13))
top_gen <- top_gen |> mutate(TOP_GEN = as.character(TOP_GEN))
gen_num <- gen_num |> mutate(GEN_NUM = as.character(GEN_NUM))
sexe <- sexe |> mutate(SEXE = as.character(SEXE))
ben_reg <- ben_reg |> mutate(BEN_REG = as.character(BEN_REG))
psp_spe <- psp_spe |> mutate(PSP_SPE = as.character(PSP_SPE))

# Jointure avec les dictionnaires
open_medic_prepare <- open_medic_2025 |>
  left_join(cip13, by = "CIP13") |>
  left_join(top_gen, by = "TOP_GEN") |>
  left_join(gen_num, by = "GEN_NUM") |>
  left_join(age, by = "AGE") |>
  left_join(sexe, by = c("sexe" = "SEXE")) |>
  left_join(ben_reg, by = "BEN_REG") |>
  left_join(psp_spe, by = "PSP_SPE")

# Contrôle
glimpse(open_medic_prepare)

message("Préparation des données terminée.")