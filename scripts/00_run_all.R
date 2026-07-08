###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 00_run_all.R
# Objet   : Exécuter tout le pipeline du projet
###############################################################################

rm(list = ls())

source("config.R")

library(stringr)

message("Début du pipeline Open Medic ", annee_open_medic, "...")

###############################################################################
# 1. Téléchargement et décompression des données brutes
###############################################################################

dir.create(path_raw_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(path_zip)) {
  
  message("Recherche du lien ZIP Open Medic...")
  
  page_html <- readLines(
    con = url_open_medic_page,
    warn = FALSE
  )
  
  lien_zip <- page_html |>
    str_extract('href="[^"]+\\.zip"') |>
    na.omit() |>
    str_remove('href="') |>
    str_remove('"') |>
    unique()
  
  if (length(lien_zip) == 0) {
    stop("Aucun lien ZIP trouvé sur la page : ", url_open_medic_page)
  }
  
  lien_zip <- lien_zip[1]
  
  if (!str_starts(lien_zip, "https://")) {
    lien_zip <- paste0(
      "https://open-data-assurance-maladie.ameli.fr/medicaments/",
      lien_zip
    )
  }
  
  message("Téléchargement du fichier Open Medic : ", lien_zip)
  
  download.file(
    url = lien_zip,
    destfile = path_zip,
    mode = "wb"
  )
  
} else {
  message("Fichier ZIP déjà présent.")
}

if (length(list.files(path_raw_dir, pattern = "\\.csv$")) == 0) {
  
  message("Décompression du fichier ZIP...")
  
  unzip(
    zipfile = path_zip,
    exdir = path_raw_dir
  )
  
} else {
  message("Fichier CSV déjà décompressé.")
}

message("Fichier CSV utilisé : ", get_path_open_medic_csv())

###############################################################################
# 2. Exécution du pipeline
###############################################################################

source("scripts/01_import_donnees.R")
source("scripts/02_preparation_donnees.R")
source("scripts/03_controle_qualite_donnees.R")
source("scripts/04_nettoyage_donnees.R")
source("scripts/05_analyse_exploratoire.R")
source("scripts/06_feature_engineering.R")
source("scripts/07_visualisations.R")


# ============ Génération du rapport ===========


dir.create("docs", recursive = TRUE, showWarnings = FALSE)

rmarkdown::render(
  input = "scripts/08_article_metier.Rmd",
  output_dir = dirname(path_report),
  output_file = basename(path_report)
)


# ========Création d'un alias vers le dernier rapport ==========

file.copy(from = path_report, to = file.path("docs", "article_open_medic.html"), overwrite = TRUE)

#============ Génération du rapport PDF =============
path_report_pdf <- file.path("docs",paste0("article_open_medic_", annee_open_medic, ".pdf"))
pagedown::chrome_print(input = path_report,output = path_report_pdf)
file.copy(from = path_report_pdf,to = file.path("docs", "article_open_medic.pdf"),overwrite = TRUE)
message("Rapport PDF généré.")

message("Alias du dernier rapport créé.")
message("Pipeline terminé avec succès.")