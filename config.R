###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Fichier : config.R
# Objet   : Centraliser les paramètres du projet
###############################################################################

library(stringr)

#=============== Détection automatique de la dernière année Open Medic disponible ======


url_open_medic_base <- paste0(
  "https://open-data-assurance-maladie.ameli.fr/medicaments/download.php?",
  "Dir_Rep=Open_MEDIC_Base_Complete&Annee=")

detect_last_open_medic_year <- function() {
  
  annees_a_tester <- seq(
    from = as.integer(format(Sys.Date(), "%Y")),to = 2014,by = -1)
  for (annee in annees_a_tester) {
    url_test <- paste0(url_open_medic_base, annee)
    page_test <- tryCatch(readLines(url_test, warn = FALSE),
      error = function(e) NULL)
    if (is.null(page_test)) {
      next
    }
    lien_zip <- page_test |>
      str_extract("OPEN_MEDIC_[0-9]{4}\\.zip") |>
      na.omit() |>
      unique()
    if (length(lien_zip) > 0) {
      return(annee)
    }
  }
  stop("Aucune année Open Medic disponible détectée automatiquement.")
}


#=============== Choix de l'année==========

# Mettre NULL pour détecter automatiquement la dernière année disponible.
# Ou renseigner une année précise (2022, 2023, 2024, ...)

#annee_open_medic <- NULL
#annee_open_medic <- 2024
 annee_open_medic <- 2023
# annee_open_medic <- 2022
# annee_open_medic <- 2021
# annee_open_medic <- 2020
# annee_open_medic <- 2019



if (is.null(annee_open_medic)) {
  annee_open_medic <- detect_last_open_medic_year()
}
message("Année Open Medic utilisée : ", annee_open_medic)


#============ URL officielle AMELI de téléchargement Open Medic ==========


url_open_medic_page <- paste0(url_open_medic_base,annee_open_medic)

#=========== Chemins locaux==========

path_raw_dir <- file.path("data","raw",paste0("open_medic_", annee_open_medic))
path_zip <- file.path(path_raw_dir,paste0("OPEN_MEDIC_", annee_open_medic, ".zip"))

# Fichier descriptif AMELI
path_descriptif <- file.path("data", "raw", "descriptif.xls")


#============= Chemins des données produites============

path_clean <- file.path("data","processed",paste0("open_medic_clean_", annee_open_medic, ".rds"))

path_features <- file.path("data","processed",
  paste0("open_medic_features_", annee_open_medic, ".rds"))
 
#============= Chemin du rapport HTML ===============


path_report <- file.path("docs",paste0("article_open_medic_", annee_open_medic, ".html"))


# ======== Fonction utilitaire : retrouver automatiquement le CSV/TXT après décompression

get_path_open_medic_csv <- function() {
  fichiers <- list.files(
    path_raw_dir,
    pattern = "\\.(csv|txt)$",
    full.names = TRUE,
    ignore.case = TRUE)
  if (length(fichiers) == 0) {
    stop("Aucun fichier CSV/TXT Open Medic trouvé dans : ", path_raw_dir)
  }
  fichiers[1]
}
