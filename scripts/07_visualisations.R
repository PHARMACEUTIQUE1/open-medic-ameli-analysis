###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 07_visualisations.R
# Objet   : Produire les visualisations du projet Open Medic
###############################################################################

rm(list = ls())
# install.packages("rnaturalearthhires",
#                  repos = "https://ropensci.r-universe.dev")

library(tidyverse)
library(scales)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(mapsf)
library(treemapify)
library(patchwork)


# ============ Chargement des données enrichies =============

source("config.R")
stopifnot(file.exists(path_features))
open_medic_features <- readRDS(path_features)
source_caption <- paste0("Source : Open Medic AMELI ", annee_open_medic)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
glimpse(open_medic_features)
message("Données enrichies chargées.")

              ###############################################################################
              #                      Charte graphique du projet
              ###############################################################################

couleur_primaire <- "#2563EB"      
couleur_secondaire <- "#14B8A6"   
couleur_accent <- "#F59E0B"        
couleur_alerte <- "#DC2626"        
couleur_texte <- "#111827"
couleur_grille <- "#E5E7EB"

theme_open_medic <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 18, color = couleur_texte),
      plot.subtitle = element_text(size = 12, color = "#4B5563"),
      axis.title = element_text(color = couleur_texte),
      axis.text = element_text(color = couleur_texte),
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = couleur_grille),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(size = 9, color = "#6B7280"),
      legend.position = "none"
    )
}

# ================= Vue d'ensemble du marché ==================

kpi_vue_ensemble <- tibble(
  indicateur = c(
    "Observations",
    "Médicaments",
    "Classes ATC5",
    "Régions",
    "Boîtes délivrées",
    "Montant remboursé"
  ),
  icone = c("📊", "💊", "🧬", "🌍", "📦", "💶"),
  signal = c("Périmètre national", "Offre médicament", "Classification", 
             "Couverture territoriale", "Volume délivré", "Dépense remboursée"),
  etiquette = c(
    scales::label_comma(big.mark = " ", decimal.mark = ",")(nrow(open_medic_features)),
    scales::label_comma(big.mark = " ", decimal.mark = ",")(n_distinct(open_medic_features$cip13)),
    scales::label_comma(big.mark = " ", decimal.mark = ",")(n_distinct(open_medic_features$atc5)),
    scales::label_comma(big.mark = " ", decimal.mark = ",")(n_distinct(open_medic_features$region)),
    scales::label_comma(big.mark = " ", decimal.mark = ",")(sum(open_medic_features$boites, na.rm = TRUE)),
    paste0(
      scales::label_comma(big.mark = " ", decimal.mark = ",")(sum(open_medic_features$remboursement, na.rm = TRUE)),
      " €"
    ) ), ordre = 1:6)

fig_00_vue_ensemble_marche <- ggplot(kpi_vue_ensemble,aes(x = ordre, y = 1, fill = indicateur)) +
  geom_tile(width = 0.92,height = 0.86,color = "white",linewidth = 1.8) +
  geom_text(aes(label = icone),y = 1.23,size = 8) +
  geom_text(aes(label = etiquette),y = 1.07,size = 5.8,fontface = "bold",color = "white") +
  geom_text( aes(label = indicateur),y = 0.92,size = 3.9,fontface = "bold",color = "white") +
  geom_text(aes(label = signal),y = 0.78,size = 3,color = "white") +
  scale_fill_manual(
    values = c(
      "Observations" = couleur_primaire,
      "Médicaments" = couleur_secondaire,
      "Classes ATC5" = couleur_accent,
      "Régions" = "#7C3AED",
      "Boîtes délivrées" = "#0891B2",
      "Montant remboursé" = couleur_alerte
    )) +
  labs(
    title = "Vue d'ensemble du marché Open Medic",
    subtitle = "Synthèse exécutive des principaux indicateurs du périmètre analysé",
    caption = source_caption) +
  coord_cartesian(ylim = c(0.65, 1.35), clip = "off") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 22, color = couleur_texte),
    plot.subtitle = element_text(size = 12, color = "#4B5563"),
    plot.caption = element_text(size = 9, color = "#6B7280"),
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(20, 20, 20, 20))

fig_00_vue_ensemble_marche
ggsave("outputs/figures/fig_00_vue_ensemble_marche.png",
  fig_00_vue_ensemble_marche,width = 15, height = 5.5,dpi = 300)

#================ Top 20 des médicaments les plus délivrés =============

# Question métier :
# Quels médicaments sont les plus consommés en nombre de boîtes ?

top20_medicaments_boites <- open_medic_features |>
  group_by(lib_cip13) |>
  summarise( boites_total = sum(boites, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_cip13)) |>
  arrange(desc(boites_total)) |>
  slice_head(n = 20) |>
  mutate(lib_cip13 = fct_reorder(lib_cip13, boites_total))

fig_02_top20_medicaments_boites <- ggplot(
  top20_medicaments_boites,
  aes(x = lib_cip13, y = boites_total)) +
  geom_col(fill = couleur_secondaire, width = 0.75) +
  geom_text(aes(label = label_number(scale_cut = cut_short_scale(), accuracy = 0.1)(boites_total)),
    hjust = -0.1,
    size = 3.5,
    color = couleur_texte) +
  coord_flip() +
  scale_y_continuous(
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Les 20 médicaments les plus délivrés en pharmacie",
    subtitle = "Classement par nombre total de boîtes délivrées",
    x = NULL,
    y = "Nombre de boîtes délivrées",
    caption = source_caption) +
  theme_open_medic()
fig_02_top20_medicaments_boites

ggsave(filename = "outputs/figures/fig_02_top20_medicaments_boites.png",
  plot = fig_02_top20_medicaments_boites,
  width = 13,height = 8,dpi = 300)



# ================= Comparaison remboursement vs volume =====================

comparaison_remboursement_boites <- open_medic_features |>
  group_by(lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    boites_total = sum(boites, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_cip13)) |>
  arrange(desc(remboursement_total)) |>
  slice_head(n = 15) |>
  mutate(lib_cip13 = factor(lib_cip13,levels = rev(lib_cip13)),
    remboursement_index =remboursement_total /max(remboursement_total) * 100,
    boites_index =boites_total /max(boites_total) * 100,
    etiquette_remboursement =paste0(number(
          remboursement_total / 1e6,accuracy = 0.1,big.mark = " ",decimal.mark = ",")," M€"),
    etiquette_boites =paste0(number(boites_total / 1e3,accuracy = 1,big.mark = " ",decimal.mark = ",")," k")) |>
  pivot_longer(
    cols = c(remboursement_index, boites_index),
    names_to = "indicateur",
    values_to = "valeur") |>
  mutate(valeur =if_else(indicateur == "boites_index",-valeur,valeur),
    etiquette =if_else(indicateur == "boites_index",etiquette_boites,etiquette_remboursement),
    indicateur =recode(indicateur,boites_index = "Boîtes délivrées",
        remboursement_index = "Montant remboursé"))

fig_03_remboursement_vs_boites <-
  ggplot(comparaison_remboursement_boites,
    aes(
      x = lib_cip13,
      y = valeur,
      fill = indicateur)) +
  geom_col(width = .75) +
  geom_text(
    aes(
      label = etiquette,
      hjust = if_else(valeur < 0, 1.05, -0.05)),
    size = 3.4,
    colour = couleur_texte,
    fontface = "bold") +
  
  coord_flip() +
  scale_fill_manual(
    values = c("Boîtes délivrées" = couleur_secondaire,"Montant remboursé" = couleur_primaire)) +
  scale_y_continuous(breaks = c(-100, -75, -50, -25, 0, 25, 50, 75, 100),
    labels = c("10 k","7 k","5 k","2 k","","250 M€","500 M€","750 M€","1000 M€"),
    expand = expansion(mult = c(.18, .18))) +
  labs(title = "Les médicaments les plus remboursés sont-ils aussi les plus délivrés ?",
    subtitle = "Longueur des barres : indice base 100 • Étiquettes : valeurs réelles",
    x = NULL,
    y = "Indice relatif (%)",
    fill = NULL,
    caption = source_caption) +
  theme_open_medic() +
  theme(legend.position = "top",
    panel.grid.major.y = element_blank())
fig_03_remboursement_vs_boites
ggsave(filename = "outputs/figures/fig_03_remboursement_vs_boites.png",
  plot = fig_03_remboursement_vs_boites,
  width = 13,height = 8,dpi = 300)
# ================= Classes thérapeutiques les plus coûteuses ==============

# Question métier :
# Quelles grandes classes thérapeutiques concentrent le plus de remboursements 

treemap_atc <- open_medic_features |>
  group_by(lib_atc1) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_atc1)) |>
  mutate(part = remboursement_total / sum(remboursement_total) * 100,
    etiquette = paste0(
      lib_atc1, "\n",
      label_number(scale_cut = cut_short_scale(), accuracy = 0.1)(remboursement_total)," €", "\n",round(part, 1), " %"))

fig_10_treemap_atc <- ggplot(
  treemap_atc,
  aes(area = remboursement_total,fill = lib_atc1,label = etiquette)) +
  geom_treemap(colour = "white",linewidth = 1) +
  geom_treemap_text(
    colour = "white",
    place = "centre",
    grow = FALSE,
    reflow = TRUE,
    size = 10,
    fontface = "bold",
    min.size = 4
  ) +
  scale_fill_manual(
    values = c(
      "#2563EB", "#14B8A6", "#F59E0B", "#DC2626",
      "#7C3AED", "#0891B2", "#65A30D", "#EA580C",
      "#DB2777", "#4F46E5", "#0F766E", "#9333EA",
      "#475569", "#CA8A04")) +
  labs(
    title = "Quelles classes thérapeutiques concentrent les remboursements ?",
    subtitle = "Répartition des remboursements par grande classe ATC",
    caption = source_caption) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 18, color = couleur_texte),
    plot.subtitle = element_text(size = 12, color = "#4B5563"),
    plot.caption = element_text(size = 9, color = "#6B7280"),
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA))
fig_10_treemap_atc

ggsave("outputs/figures/fig_10_treemap_atc.png",
  fig_10_treemap_atc,
  width = 13,height = 8,dpi = 300)

# ======= Les médicaments génériques occupent-ils une place importante ? ===

# Question métier :
# Quelle est la part des médicaments génériques dans les remboursements ?

analyse_generiques <- open_medic_features |>
  mutate(type_medicament = case_when(
      lib_top_gen == "Générique" ~ "Génériques",
      lib_top_gen == "Non générique" ~ "Non génériques",
      TRUE ~ "Information indisponible")) |>
  group_by(type_medicament) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  mutate(part = remboursement_total / sum(remboursement_total) * 100,
    etiquette = paste0(round(part, 1), " %"))
fig_05_generiques_remboursement <- ggplot(
  analyse_generiques,
  aes(x = reorder(type_medicament, remboursement_total),
    y = remboursement_total,
    fill = type_medicament)) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = etiquette),
    vjust = -0.5,
    size = 4,
    fontface = "bold",
    color = couleur_texte) +
  scale_fill_manual(values = c(
    "Génériques" = couleur_secondaire,
    "Non génériques" = couleur_primaire,
    "Information indisponible" = "grey70")) +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Quelle est la place des médicaments génériques ?",
    subtitle = "Répartition des remboursements selon le type de médicament",
    x = NULL,
    y = "Montant remboursé (€)",
    fill = NULL,
    caption = source_caption) +
  theme_open_medic() +
  theme(legend.position = "top")

fig_05_generiques_remboursement

ggsave("outputs/figures/fig_05_generiques_remboursement.png",
  fig_05_generiques_remboursement,
  width = 10, height = 7, dpi = 300)


# ========== Les remboursements diffèrent-ils selon le sexe ? ============

# Question métier :
# Quelle est la répartition des remboursements entre les hommes et les femmes ?


analyse_sexe <- open_medic_features |>
  group_by(sexe) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  mutate(part = remboursement_total / sum(remboursement_total),
    etiquette = paste0(sexe,"\n",scales::percent(part, accuracy = 0.1)))

fig_06_repartition_sexe <- ggplot(
  analyse_sexe,
  aes(x = 2,y = remboursement_total,fill = sexe )) +
  geom_col( width = 1,color = "white") +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  geom_text(
    aes(label = etiquette),
    position = position_stack(vjust = 0.5),
    size = 4,
    fontface = "bold",
    color = "white" ) +
  scale_fill_manual(
    values = c(
      "MASCULIN" = couleur_primaire,
      "FEMININ" = couleur_secondaire,
      "Inconnu" = "grey70")) +
  labs(
    title = "Comment se répartissent les remboursements selon le sexe ?",
    subtitle = "Part des montants remboursés par sexe",
    fill = NULL,
    caption = source_caption) +
  theme_void() +
  theme(plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 12),
    plot.caption = element_text(size = 9),
    legend.position = "top"
  )

fig_06_repartition_sexe

ggsave("outputs/figures/fig_06_repartition_sexe.png",
  fig_06_repartition_sexe,
  width = 8,height = 8,dpi = 300)


#============Carte des remboursements par région ============

regions <- st_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions.geojson",
  quiet = TRUE)

regions <- regions |>
rename(LIBGEO = nom, CODE_REG = code)

paca_corse <- regions |>
filter(LIBGEO %in% c("Provence-Alpes-Côte d'Azur", "Corse")) |>
  summarise(LIBGEO = "Provence-Alpes-Côte d'Azur et Corse",CODE_REG = NA_character_)

regions <- regions |>
  filter(!LIBGEO %in% c("Provence-Alpes-Côte d'Azur", "Corse")) |>
  bind_rows(paca_corse)

analyse_region <- open_medic_features |>
  group_by(region) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop")

table_correspondance <- c(
  "Ile-de-France"                          = "Île-de-France",
  "Auvergne-Rhône-Alpes"                   = "Auvergne-Rhône-Alpes",
  "Aquitaine-Limousin-Poitou-Charentes"     = "Nouvelle-Aquitaine",
  "Languedoc-Roussillon-Midi-Pyrénées"      = "Occitanie",
  "Nord-Pas-de-Calais-Picardie"             = "Hauts-de-France",
  "Alsace-Champagne-Ardenne-Lorraine"       = "Grand Est",
  "Pays de la Loire"                        = "Pays de la Loire",
  "Normandie"                               = "Normandie",
  "Bretagne"                                = "Bretagne",
  "Bourgogne-Franche-Comté"                 = "Bourgogne-Franche-Comté",
  "Centre-Val de Loire"                     = "Centre-Val de Loire",
  "Provence-Alpes-Côte d'Azur et Corse"     = "Provence-Alpes-Côte d'Azur et Corse"
)

analyse_region <- analyse_region |>
  mutate(region_carte = recode(region, !!!table_correspondance))
total_national <- sum(analyse_region$remboursement_total, na.rm = TRUE)

regions <- left_join(regions,analyse_region,by = c("LIBGEO" = "region_carte"))

# Vérification : régions du fond de carte sans correspondance
regions_sans_donnees <- regions |>
  filter(is.na(remboursement_total)) |>
  pull(LIBGEO)
if (length(regions_sans_donnees) > 0) {
  message("Régions du fond de carte sans donnée de remboursement : ",
    paste(regions_sans_donnees, collapse = ", ")
  )
}


regions_non_cartographiees <- setdiff(analyse_region$region_carte, regions$LIBGEO)
if (length(regions_non_cartographiees) > 0) {
  message("Régions de la base non représentées sur la carte (normal pour DOM/Inconnu) : ",
    paste(regions_non_cartographiees, collapse = ", ")
  )
}


regions <- regions |>
  mutate(pct = remboursement_total / total_national * 100,
    montant_formate = ifelse(is.na(remboursement_total),NA_character_,
      paste0(format(round(remboursement_total / 1e6, 1), decimal.mark = ","), " M€")),
    label_montant_pct = ifelse( is.na(remboursement_total),"N/D",
      paste0(montant_formate," (", format(round(pct, 1), decimal.mark = ","), " %)"
      )))

mf_theme("default")
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
png(filename = "outputs/figures/fig_07_carte_remboursement_region.png",
    width = 1600,height = 1200,res = 180)
mf_map(
  x = regions,
  var = "remboursement_total",
  type = "choro",
  pal = "Blues",
  border = "black",
  lwd = 1,
  col_na = "grey75",
  leg_title = "Montant remboursé (€)",
  leg_val_rnd = 0,
  leg_no_data = "Pas de donnée"
)
mf_label(
  x = regions,
  var = "label_montant_pct",
  cex = 0.65,
  font = 2,
  col = "black",
  halo = TRUE,
  bg = "white",
  r = 0.15,
  overlap = FALSE
)
mf_title("Remboursements de médicaments par région : où va l'argent de l'Assurance Maladie ?")
mf_credits(source_caption)
dev.off()



#====== Quelles spécialités médicales génèrent le plus de remboursements ? ==

# Question métier :
# Quelles spécialités de prescripteurs concentrent les dépenses les plus élevées ?


top_prescripteurs <- open_medic_features |>
  group_by(prescripteur) |>
  summarise(
    remboursement_total = sum(remboursement, na.rm = TRUE),
    .groups = "drop") |>
  filter(!is.na(prescripteur)) |>
  arrange(desc(remboursement_total)) |>
  slice_head(n = 15) |>
  mutate(prescripteur = fct_reorder(prescripteur, remboursement_total)
  )
fig_08_remboursement_prescripteurs <- ggplot(
  top_prescripteurs,
  aes(x = prescripteur, y = remboursement_total)) +
  geom_col(fill = couleur_primaire, width = 0.75) +
  geom_text(
    aes(label = label_number(scale_cut = cut_short_scale(), accuracy = 0.1)(remboursement_total)),
    hjust = -0.1,
    size = 3.5,
    color = couleur_texte) +
  coord_flip() +
  scale_y_continuous(
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Les spécialités médicales qui génèrent le plus de remboursements",
    subtitle = "Top 15 des spécialités de prescripteurs",
    x = NULL,
    y = "Montant remboursé (€)",
    caption = source_caption) +
  theme_open_medic()

fig_08_remboursement_prescripteurs

ggsave(
  filename = "outputs/figures/fig_08_remboursement_prescripteurs.png",
  plot = fig_08_remboursement_prescripteurs,
  width = 13, height = 8,dpi = 300)


# =========Concentration des remboursements ==========

# Question métier :
# Une faible proportion de médicaments concentre-t-elle une grande partie
# des remboursements ?


concentration_remboursements <- open_medic_features |>
  group_by(lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_cip13)) |>
  arrange(desc(remboursement_total)) |>
  mutate(rang = row_number(),
    pct_medicaments = rang / n() * 100,
    pct_remboursement_cumule = cumsum(remboursement_total) / sum(remboursement_total) * 100)

fig_09_concentration_remboursements <- ggplot(
  concentration_remboursements,
  aes(x = pct_medicaments, y = pct_remboursement_cumule)) +
  geom_area(fill = couleur_secondaire, alpha = 0.35) +
  geom_line(color = couleur_primaire, linewidth = 1.2) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    color = "#9CA3AF") +
  annotate(
    "text",
    x = 55,
    y = 45,
    label = "Répartition parfaitement équilibrée",
    color = "#6B7280",
    size = 3.5) +
  scale_x_continuous(labels = function(x) paste0(x, " %")) +
  scale_y_continuous(labels = function(x) paste0(x, " %"), limits = c(0, 100)) +
  labs(title = "Les remboursements sont-ils concentrés sur peu de médicaments ?",
    subtitle = "Part cumulée des remboursements selon la part cumulée des médicaments",
    x = "Part cumulée des médicaments",
    y = "Part cumulée des remboursements",
    caption = source_caption) +
  theme_open_medic() +
  theme(
    panel.grid.major.y = element_line(color = couleur_grille),
    legend.position = "none")
fig_09_concentration_remboursements
ggsave(
  filename = "outputs/figures/fig_09_concentration_remboursements.png",
  plot = fig_09_concentration_remboursements,
  width = 11,height = 7,dpi = 300)



#======== Quelles classes thérapeutiques représentent le plus de dépenses ? =========

# Question métier :
# Les remboursements sont-ils concentrés sur quelques grandes classes ATC ?
treemap_atc <- open_medic_features |>
  group_by(lib_atc1) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    .groups = "drop") |>
  filter(!is.na(lib_atc1)) |>
  mutate(part = remboursement_total / sum(remboursement_total) * 100,
    etiquette = paste0(lib_atc1, "\n",label_number(scale_cut = cut_short_scale(), accuracy = 0.1)(remboursement_total),
      " €", "\n",round(part, 1), " %"))

fig_10_treemap_atc <- ggplot(
  treemap_atc,
  aes(area = remboursement_total,fill = lib_atc1,label = etiquette)) +
  geom_treemap(colour = "white",linewidth = 1) +
  geom_treemap_text(colour = "white",place = "centre",
    grow = FALSE,
    reflow = TRUE,size = 10,fontface = "bold", min.size = 4) +
  scale_fill_manual(
    values = c(
      "#2563EB", "#14B8A6", "#F59E0B", "#DC2626",
      "#7C3AED", "#0891B2", "#65A30D", "#EA580C",
      "#DB2777", "#4F46E5", "#0F766E", "#9333EA",
      "#475569", "#CA8A04")) +
  labs(
    title = "Quelles classes thérapeutiques concentrent les remboursements ?",
    subtitle = "Répartition des remboursements par grande classe ATC",
    caption = source_caption) +
  theme_void() +
  theme( plot.title = element_text(face = "bold", size = 18, color = couleur_texte),
    plot.subtitle = element_text(size = 12, color = "#4B5563"),
    plot.caption = element_text(size = 9, color = "#6B7280"),
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA))

fig_10_treemap_atc
ggsave("outputs/figures/fig_10_treemap_atc.png",
  fig_10_treemap_atc,
  width = 13,height = 8,dpi = 300)

# ============== Remboursements par tranche d'âge et sexe =========

# Question métier :
# Les remboursements diffèrent-ils selon l'âge et le sexe ?


age_sexe <- open_medic_features |>
  group_by(tranche_age, sexe) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE), .groups = "drop") |>
  mutate(part = remboursement_total / sum(remboursement_total) * 100,
    etiquette = paste0(
      scales::label_number(
        scale_cut = cut_short_scale(),
        accuracy = 0.1
      )(remboursement_total),
      " €","\n",round(part, 1)," %"))

fig_11_remboursement_age_sexe <- ggplot(
  age_sexe,
  aes(x = tranche_age,y = sexe,
    fill = remboursement_total)) +
  
  geom_tile(colour = "white",linewidth = 1) +
  geom_text(aes(label = etiquette),colour = "white",fontface = "bold",size = 3.6 ) +
  scale_fill_gradient(low = "#DBEAFE",high = couleur_primaire,labels = label_number(scale_cut = cut_short_scale())) +
  labs(title = "Comment les remboursements se répartissent-ils selon l'âge et le sexe ?",
    subtitle = "Montant remboursé et part dans le total pour chaque combinaison âge × sexe",
    x = "Tranche d'âge",
    y = NULL,
    fill = "Montant remboursé",
    caption = source_caption) +
  
  theme_open_medic() +
  
  theme(
    axis.text.x = element_text(
      angle = 30,
      hjust = 1,
      face = "bold"),
    axis.text.y = element_text(face = "bold"),
    panel.grid = element_blank(),
    legend.position = "bottom")

fig_11_remboursement_age_sexe

ggsave("outputs/figures/fig_11_remboursement_age_sexe.png",
  fig_11_remboursement_age_sexe,
  width = 13,height = 6,dpi = 300)


#==== Quels médicaments ont un fort impact budgétaire malgré un faible volume ? ===

quadrant <- open_medic_features |>
  group_by(lib_cip13) |>
  summarise(boites = sum(boites, na.rm = TRUE),
    remboursement = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_cip13))
x_mediane <- median(quadrant$boites, na.rm = TRUE)
y_mediane <- median(quadrant$remboursement, na.rm = TRUE)

quadrant <- quadrant |>
  mutate(groupe = case_when(
      boites < x_mediane & remboursement >= y_mediane ~ "Fort coût - Faible volume",
      boites >= x_mediane & remboursement >= y_mediane ~ "Fort coût - Fort volume",
      boites < x_mediane & remboursement < y_mediane ~ "Faible coût - Faible volume",
      boites >= x_mediane & remboursement < y_mediane ~ "Faible coût - Fort volume" ))
couleurs_groupes <- c(
  "Fort coût - Faible volume" = couleur_alerte,
  "Fort coût - Fort volume" = couleur_primaire,
  "Faible coût - Faible volume" = "#6B7280",
  "Faible coût - Fort volume" = couleur_secondaire
)

fig_12_quadrant_impact_budgetaire <- ggplot(
  quadrant,
  aes( x = boites, y = remboursement, color = groupe)) +
  geom_point(alpha = .65,size = 2.2) +
  geom_vline(
    xintercept = x_mediane,
    colour = "#9CA3AF",
    linetype = "dashed") +
  geom_hline(
    yintercept = y_mediane,
    colour = "#9CA3AF",
    linetype = "dashed") +
  geom_text(
    data = quadrant |>
      slice_max(remboursement, n = 12),
    aes(label = lib_cip13),
    size = 3,
    check_overlap = TRUE,
    nudge_y = 0.03 * max(quadrant$remboursement, na.rm = TRUE),
    show.legend = FALSE) +
  annotate(
    "text",
    x = max(quadrant$boites, na.rm = TRUE) * .80,
    y = max(quadrant$remboursement, na.rm = TRUE) * .95,
    label = "Fort coût\nFort volume",
    colour = couleur_primaire,
    fontface = "bold") +
  annotate(
    "text",
    x = max(quadrant$boites, na.rm = TRUE) * .15,
    y = max(quadrant$remboursement, na.rm = TRUE) * .95,
    label = "Fort coût\nFaible volume",
    colour = couleur_alerte,
    fontface = "bold") +
  annotate(
    "text",
    x = max(quadrant$boites, na.rm = TRUE) * .15,
    y = max(quadrant$remboursement, na.rm = TRUE) * .12,
    label = "Faible coût\nFaible volume",
    colour = "#6B7280",
    fontface = "bold" ) +
  annotate(
    "text",
    x = max(quadrant$boites, na.rm = TRUE) * .80,
    y = max(quadrant$remboursement, na.rm = TRUE) * .12,
    label = "Faible coût\nFort volume",
    colour = couleur_secondaire,
    fontface = "bold") +
  scale_color_manual(values = couleurs_groupes) +
  scale_x_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  labs(
    title = "Quels médicaments présentent un impact budgétaire élevé ?",
    subtitle = "Quadrant coût / volume des médicaments",
    x = "Nombre total de boîtes délivrées",
    y = "Montant remboursé (€)",
    color = "Groupe",
    caption = source_caption) +
  theme_open_medic() +
  theme(
    legend.position = "bottom"
  )
fig_12_quadrant_impact_budgetaire
ggsave("outputs/figures/fig_12_quadrant_impact_budgetaire.png",
  fig_12_quadrant_impact_budgetaire,
  width = 12,height = 8,dpi = 300)


# ======== Répartition de l'impact budgétaire ============

# Question métier :
# Quelle part des observations présente un impact budgétaire faible, moyen,
# fort ou critique ?

impact_budgetaire <- open_medic_features |>
  count(impact_budgetaire) |>
  mutate(part = n / sum(n) * 100,
    etiquette = paste0(round(part, 1), " %"),
    impact_budgetaire = factor(impact_budgetaire,levels = c("Faible", "Moyen", "Fort", "Critique")))
fig_13_impact_budgetaire <- ggplot(impact_budgetaire,
  aes(x = impact_budgetaire, y = part, fill = impact_budgetaire)) +
  geom_col(width = 0.65) +
  geom_text(
    aes(label = etiquette),
    vjust = -0.4,
    size = 4,
    fontface = "bold",
    color = couleur_texte) +
  scale_fill_manual(
    values = c(
      "Faible" = "#6B7280",
      "Moyen" = couleur_secondaire,
      "Fort" = couleur_accent,
      "Critique" = couleur_alerte )) +
  scale_y_continuous(
    labels = function(x) paste0(x, " %"),
    expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Quelle part des médicaments présente un impact budgétaire critique ?",
    subtitle = "Répartition des observations selon l'impact budgétaire",
    x = NULL,
    y = "Part des observations",
    fill = NULL,
    caption = source_caption ) +
  theme_open_medic() +
  theme(legend.position = "none")
fig_13_impact_budgetaire
ggsave(
  "outputs/figures/fig_13_impact_budgetaire.png",
  fig_13_impact_budgetaire,
  width = 10,height = 7,dpi = 300)


# ========= Médicaments les plus coûteux par boîte ==========

# Question métier :
# Quels médicaments présentent le remboursement moyen par boîte le plus élevé ?

cout_moyen_boite <- open_medic_features |>
  group_by(lib_cip13) |>
  summarise(remboursement_par_boite = mean(remboursement_par_boite, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(lib_cip13), !is.na(remboursement_par_boite)) |>
  arrange(desc(remboursement_par_boite)) |>
  slice_head(n = 15) |>
  mutate(lib_cip13 = fct_reorder(lib_cip13, remboursement_par_boite))

fig_14_cout_moyen_boite <- ggplot(
  cout_moyen_boite,
  aes(x = lib_cip13, y = remboursement_par_boite)) +
  geom_col(fill = couleur_alerte, width = 0.75) +
  geom_text(aes(label = paste0(round(remboursement_par_boite, 0), " €")),
    hjust = -0.1,
    size = 3.5,
    fontface = "bold",
    color = couleur_texte) +
  coord_flip() +
  scale_y_continuous(
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Quels médicaments sont les plus coûteux par boîte ?",
    subtitle = "Top 15 selon le remboursement moyen par boîte",
    x = NULL,
    y = "Remboursement moyen par boîte (€)",
    caption = source_caption) +
  theme_open_medic()
fig_14_cout_moyen_boite

ggsave("outputs/figures/fig_14_cout_moyen_boite.png",
  fig_14_cout_moyen_boite,width = 13,
  height = 8,dpi = 300)


# ============== Indicateurs métier clés ================

# Question métier :
# Quel est le niveau moyen de remboursement observé dans la base Open Medic ?

indicateurs_metier_cles <- open_medic_features |>
  summarise(
    remboursement_moyen = mean(remboursement, na.rm = TRUE),
    base_moyenne = mean(base_remboursement, na.rm = TRUE),
    boites_moyennes = mean(boites, na.rm = TRUE),
    remboursement_par_boite = mean(remboursement_par_boite, na.rm = TRUE),
    reste_a_charge_moyen = mean(reste_a_charge, na.rm = TRUE),
    taux_remboursement_moyen = mean(taux_remboursement, na.rm = TRUE) * 100) |>
  pivot_longer(
    cols = everything(),
    names_to = "indicateur",
    values_to = "valeur") |>
  mutate(
    indicateur = recode(
      indicateur,
      "remboursement_moyen" = "Remboursement moyen",
      "base_moyenne" = "Base moyenne",
      "boites_moyennes" = "Boîtes moyennes",
      "remboursement_par_boite" = "Remboursement / boîte",
      "reste_a_charge_moyen" = "Reste à charge moyen",
      "taux_remboursement_moyen" = "Taux moyen"
    ),
    etiquette = case_when(
      indicateur == "Boîtes moyennes" ~ as.character(round(valeur, 1)),
      indicateur == "Taux moyen" ~ paste0(round(valeur, 1), " %"),
      TRUE ~ paste0(
        label_number(big.mark = " ", decimal.mark = ",", accuracy = 0.1)(valeur),
        " €"
      )
    ),
    ordre = row_number()
  )

fig_15_indicateurs_metier_cles <- ggplot(
  indicateurs_metier_cles,
  aes(x = ordre, y = 1, fill = indicateur)
) +
  geom_tile(
    width = 0.92,
    height = 0.82,
    color = "white",
    linewidth = 1.5
  ) +
  geom_text(
    aes(label = etiquette),
    y = 1.07,
    size = 5.2,
    fontface = "bold",
    color = "white"
  ) +
  geom_text(
    aes(label = indicateur),
    y = 0.88,
    size = 3.5,
    color = "white"
  ) +
  scale_fill_manual(
    values = c(
      "Remboursement moyen" = couleur_primaire,
      "Base moyenne" = couleur_secondaire,
      "Boîtes moyennes" = couleur_accent,
      "Remboursement / boîte" = "#7C3AED",
      "Reste à charge moyen" = "#0891B2",
      "Taux moyen" = couleur_alerte
    )
  ) +
  labs(
    title = "Quels sont les indicateurs moyens clés du remboursement ?",
    subtitle = "Lecture synthétique par ligne agrégée Open Medic",
    caption = source_caption
  ) +
  coord_cartesian(ylim = c(0.65, 1.30), clip = "off") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 20, color = couleur_texte),
    plot.subtitle = element_text(size = 12, color = "#4B5563"),
    plot.caption = element_text(size = 9, color = "#6B7280"),
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA)
  )

fig_15_indicateurs_metier_cles

ggsave("outputs/figures/fig_15_indicateurs_metier_cles.png",
  fig_15_indicateurs_metier_cles,
  width = 14,height = 5,dpi = 300)

#============ Remboursement moyen par âge et sexe ===========

# Question métier :
# Le remboursement moyen varie-t-il selon l'âge et le sexe ?


remboursement_moyen_age_sexe <- open_medic_features |>
  group_by(tranche_age, sexe) |>
  summarise(remboursement_moyen = mean(remboursement, na.rm = TRUE),.groups = "drop") |>
  filter(!is.na(tranche_age), !is.na(sexe)) |>
  mutate(
    etiquette = paste0(
      label_number(big.mark = " ", decimal.mark = ",", accuracy = 1)(remboursement_moyen),
      " €"
    )
  )
fig_16_remboursement_moyen_age_sexe <- ggplot(
  remboursement_moyen_age_sexe,
  aes(x = tranche_age, y = remboursement_moyen, fill = sexe)) +
  geom_col(position = position_dodge(width = 0.75),
    width = 0.65) +
  geom_text(
    aes(label = etiquette),
    position = position_dodge(width = 0.75),
    vjust = -0.35,
    size = 3.4,
    fontface = "bold",
    color = couleur_texte ) +
  scale_fill_manual(
    values = c(
      "FEMININ" = couleur_secondaire,
      "MASCULIN" = couleur_primaire,
      "Inconnu" = "#9CA3AF")) +
  scale_y_continuous(
    labels = label_number(big.mark = " ", decimal.mark = ","),
    expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Le remboursement moyen varie-t-il selon l'âge et le sexe ?",
    subtitle = "Comparaison du remboursement moyen par ligne agrégée Open Medic",
    x = "Tranche d'âge",
    y = "Remboursement moyen (€)",
    fill = "Sexe",
    caption = source_caption) +
  theme_open_medic() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 25, hjust = 1, face = "bold") )

fig_16_remboursement_moyen_age_sexe
ggsave(
  "outputs/figures/fig_16_remboursement_moyen_age_sexe.png",
  fig_16_remboursement_moyen_age_sexe,
  width = 12,height = 7,dpi = 300)


# ============== Top spécialités par remboursement moyen======

# Question métier :
# Quelles spécialités présentent les remboursements moyens les plus élevés ?

top_prescripteurs_moyen <- open_medic_features |>
  group_by(prescripteur) |>
  summarise(remboursement_moyen = mean(remboursement, na.rm = TRUE),
    nb_observations = n(),.groups = "drop") |>
  filter(!is.na(prescripteur), prescripteur != "Inconnu", nb_observations >= 100) |>
  arrange(desc(remboursement_moyen)) |>
  slice_head(n = 15) |>
  mutate(prescripteur = fct_reorder(prescripteur, remboursement_moyen),
    etiquette = paste0(
      label_number(scale_cut = cut_short_scale(), accuracy = 0.1)(remboursement_moyen), " €"))

fig_17_remboursement_moyen_prescripteur <- ggplot(
  top_prescripteurs_moyen,
  aes(x = remboursement_moyen, y = prescripteur)) +
  geom_segment(
    aes(x = 0, xend = remboursement_moyen, y = prescripteur, yend = prescripteur),
    color = couleur_grille,
    linewidth = 1.2 ) +
  geom_point(
    color = couleur_alerte,
    size = 4) +
  geom_text(
    aes(label = etiquette),
    hjust = -0.15,
    size = 3.5,
    fontface = "bold",
    color = couleur_texte) +
  scale_x_continuous(
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0, 0.20))) +
  labs(title = "Quelles spécialités ont le remboursement moyen le plus élevé ?",
    subtitle = "Top 15 des spécialités avec au moins 100 observations",
    x = "Remboursement moyen (€)",
    y = NULL,
    caption = source_caption ) +
  theme_open_medic()

fig_17_remboursement_moyen_prescripteur
ggsave("outputs/figures/fig_17_remboursement_moyen_prescripteur.png",
  fig_17_remboursement_moyen_prescripteur,
  width = 13,height = 8,dpi = 300)



# ============== Signature thérapeutique par spécialité médicale ============

# Question métier :
# Quelles classes thérapeutiques sont principalement prescrites
# par chaque spécialité médicale ?

signature_prescripteurs <- open_medic_features |>
  filter(!is.na(prescripteur),!is.na(lib_atc1),prescripteur != "Inconnu",lib_atc1 != "Inconnu") |>
  group_by(prescripteur, lib_atc1) |>
  summarise(boites_total = sum(boites, na.rm = TRUE),.groups = "drop")

top_prescripteurs_signature <- signature_prescripteurs |>
  group_by(prescripteur) |>
  summarise(boites_total_prescripteur = sum(boites_total, na.rm = TRUE),.groups = "drop") |>
  arrange(desc(boites_total_prescripteur)) |>
  slice_head(n = 10)
top_atc_signature <- signature_prescripteurs |>
  group_by(lib_atc1) |>
  summarise(boites_total_atc = sum(boites_total, na.rm = TRUE),.groups = "drop") |>
  arrange(desc(boites_total_atc)) |>
  slice_head(n = 12)

signature_heatmap <- signature_prescripteurs |>
  semi_join(top_prescripteurs_signature, by = "prescripteur") |>
  semi_join(top_atc_signature, by = "lib_atc1") |>
  group_by(prescripteur) |>
  mutate(part_boites = boites_total / sum(boites_total, na.rm = TRUE) * 100) |>
  ungroup() |>
  mutate(prescripteur_court = prescripteur |>
      str_replace_all("\n", " ") |>
      str_replace_all(" LIBERALE", "") |>
      str_replace_all("PRESCRIPTEURS DE VILLE AUTRES QUE MEDECINS.*", "Autres prescripteurs ville") |>
      str_replace_all("PRESCRIPTEURS SALARIES", "Prescripteurs salariés") |>
      str_to_sentence() |>
      str_trunc(width = 34, side = "right"),
    
    lib_atc1_court = lib_atc1 |>
      str_replace_all("Anti-infectieux \\(usage systémique\\)", "Anti-infectieux") |>
      str_replace_all("Antinéoplasiques et agents immunomodulants", "Antinéoplasiques") |>
      str_replace_all("Antiparasitaires, insecticides et répulsifs", "Antiparasitaires") |>
      str_replace_all("Hormones systémiques, à l'exclusion des hormones sexuelles et des insulines", "Hormones systémiques") |>
      str_replace_all("Sang et organes hématopoïétiques", "Sang / hémato.") |>
      str_replace_all("Système cardio-vasculaire", "Cardio-vasculaire") |>
      str_replace_all("Système digestif et métabolisme", "Digestif / métabolisme") |>
      str_replace_all("Système génito-urinaire et hormones sexuelles", "Génito-urinaire") |>
      str_replace_all("Système musculo-squelettique", "Musculo-squelettique") |>
      str_replace_all("Système nerveux", "Système nerveux") |>
      str_replace_all("Système respiratoire", "Respiratoire") |>
      str_replace_all("Organes sensoriels", "Organes sensoriels") |>
      str_trunc(width = 24, side = "right"),
    
    etiquette = paste0(round(part_boites, 0)," %\n",
      scales::label_number(
        big.mark = " ",
        decimal.mark = ",", accuracy = 0.1)(boites_total / 1000)," k")) |>
  mutate(prescripteur_court = fct_reorder(prescripteur_court,boites_total,.fun = sum),
    lib_atc1_court = fct_reorder(lib_atc1_court,boites_total,.fun = sum))
fig_20_signature_atc_prescripteurs <- ggplot(
  signature_heatmap,
  aes(x = lib_atc1_court,y = prescripteur_court, fill = part_boites)) +
  geom_tile(color = "white",linewidth = 0.8) +
  geom_text(aes(label = etiquette),
    size = 2.4,
    fontface = "bold",
    color = couleur_texte,
    lineheight = 0.85) +
  scale_fill_gradient(
    low = "#EFF6FF",
    high = couleur_primaire,
    labels = label_percent(scale = 1)) +
  labs(title = "Profil de prescription par spécialité médicale",
    subtitle = "Part des boîtes par classe ATC ; étiquette = part (%) et boîtes moyennes en k",
    x = "Classe thérapeutique ATC niveau 1",
    y = NULL,
    fill = "% des boîtes",
    caption = source_caption ) +
  theme_open_medic() +
  theme(axis.text.x = element_text(
      angle = 35,
      hjust = 1,
      size = 9,
      face = "bold"),
    axis.text.y = element_text(
      size = 10,
      face = "bold"),
    legend.position = "right",
    panel.grid = element_blank(),
    plot.margin = margin(15, 25, 15, 15))
fig_20_signature_atc_prescripteurs
ggsave(filename = "outputs/figures/fig_20_signature_atc_prescripteurs.png",
  plot = fig_20_signature_atc_prescripteurs,
  width = 15,height = 8,dpi = 300)