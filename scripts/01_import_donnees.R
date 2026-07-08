###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 01_import_donnees.R
# Objet   : Importer les données brutes du projet
###############################################################################

rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)

source("config.R")


path_open_medic <- get_path_open_medic_csv()

message("Fichier Open Medic utilisé :")
message(path_open_medic)

stopifnot(file.exists(path_open_medic))
stopifnot(file.exists(path_descriptif))

open_medic <- read_delim(file = path_open_medic,
  delim = ";",locale = locale(decimal_mark = ","),show_col_types = FALSE)

cip13 <- read_excel(path = path_descriptif,sheet = "CIP13")
top_gen <- read_excel(path = path_descriptif,sheet = "TOP_GEN")
gen_num <- read_excel(path = path_descriptif,sheet = "GEN_NUM")
age <- read_excel(path = path_descriptif,sheet = "AGE")
sexe <- read_excel(path = path_descriptif,sheet = "SEXE")
ben_reg <- read_excel(path = path_descriptif,sheet = "BEN_REG")
psp_spe <- read_excel(path = path_descriptif,sheet = "PSP_SPE")

message("Import terminé avec succès.")
glimpse(open_medic)
message("Nombre d'observations : ", nrow(open_medic))
message("Nombre de variables   : ", ncol(open_medic))