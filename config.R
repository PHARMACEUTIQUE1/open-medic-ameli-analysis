###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Fichier : config.R
# Objet   : Centraliser les paramètres du projet
###############################################################################

# Année analysée
annee_open_medic <- 2022

# URL officielle AMELI de téléchargement Open Medic
# Pour changer d'année, modifier uniquement annee_open_medic.
url_open_medic_page <- paste0(
  "https://open-data-assurance-maladie.ameli.fr/medicaments/download.php?",
  "Dir_Rep=Open_MEDIC_Base_Complete&Annee=",
  annee_open_medic
)

# Chemins locaux
path_raw_dir <- file.path(
  "data",
  "raw",
  paste0("open_medic_", annee_open_medic)
)

path_zip <- file.path(
  path_raw_dir,
  paste0("OPEN_MEDIC_", annee_open_medic, ".zip")
)

# Fichier descriptif AMELI
path_descriptif <- file.path("data", "raw", "descriptif.xls")

# Chemins des données produites
path_clean <- file.path(
  "data",
  "processed",
  paste0("open_medic_clean_", annee_open_medic, ".rds")
)

path_features <- file.path(
  "data",
  "processed",
  paste0("open_medic_features_", annee_open_medic, ".rds")
)

# Chemin du rapport HTML
path_report <- file.path(
  "docs",
  paste0("article_open_medic_", annee_open_medic, ".html")
)

# Fonction utilitaire : retrouver automatiquement le CSV après décompression
get_path_open_medic_csv <- function() {
  fichiers <- list.files(
    path_raw_dir,
    pattern = "\\.(csv|txt)$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  if (length(fichiers) == 0) {
    stop("Aucun fichier CSV/TXT Open Medic trouvé dans : ", path_raw_dir)
  }
  
  fichiers[1]
}