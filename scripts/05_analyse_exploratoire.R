###############################################################################
# Projet  : Analyse des données Open Medic AMELI
# Script  : 05_analyse_exploratoire.R
# Objet   : Réaliser l'analyse exploratoire des données nettoyées
###############################################################################


# ------------------- Vue d'ensemble du marché ---------------------
# Question métier :
# Quelle est l'ampleur du marché des médicaments remboursés observé dans
# les données Open Medic ?

vue_ensemble <- tibble(
  indicateur = c(
    "Nombre d'observations",
    "Nombre de variables",
    "Nombre de médicaments (CIP13)",
    "Nombre de classes ATC niveau 5",
    "Nombre de classes ATC niveau 1",
    "Nombre de régions",
    "Nombre de spécialités médicales",
    "Nombre total de boîtes délivrées",
    "Montant total remboursé (€)",
    "Base totale de remboursement (€)"
  ),
  valeur = c(nrow(open_medic_clean), ncol(open_medic_clean), n_distinct(open_medic_clean$cip13),
    n_distinct(open_medic_clean$atc5), n_distinct(open_medic_clean$atc1),n_distinct(open_medic_clean$region),
    n_distinct(open_medic_clean$prescripteur),
    sum(open_medic_clean$boites, na.rm = TRUE),
    sum(open_medic_clean$remboursement, na.rm = TRUE),
    sum(open_medic_clean$base_remboursement, na.rm = TRUE)
  )
)
vue_ensemble
write_csv(vue_ensemble,"outputs/tableaux/eda_01_vue_ensemble.csv")





# ---------------- Médicaments les plus remboursés ---------

# Question métier :
# Quels sont les médicaments qui représentent les montants de remboursement
# les plus élevés pour l'Assurance Maladie ?

top_medicaments_remboursement <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
            base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
            boites_delivrees = sum(boites, na.rm = TRUE),
            remboursement_moyen = mean(remboursement, na.rm = TRUE),
            nb_observations = n(),
            .groups = "drop") |>
          arrange(desc(remboursement_total)) |>
          slice_head(n = 20)
top_medicaments_remboursement
write_csv(top_medicaments_remboursement,"outputs/tableaux/eda_02_top_medicaments_remboursement.csv")

# -------------- Médicaments les plus  -----------------
#
# Question métier :
# Les médicaments les plus remboursés sont-ils également les plus délivrés
# en nombre de boîtes ?

top_medicaments_boites <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(boites_delivrees = sum(boites, na.rm = TRUE),
            remboursement_total = sum(remboursement, na.rm = TRUE),
            base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
            nb_observations = n(),
            .groups = "drop") |>
          arrange(desc(boites_delivrees)) |>
          slice_head(n = 20)
top_medicaments_boites
write_csv(top_medicaments_boites,"outputs/tableaux/eda_03_top_medicaments_boites.csv")


# ---------- Comparaison entre remboursements et volumes délivrés----------
#
# Question métier :
# Les médicaments les plus remboursés sont-ils également les plus délivrés ?

comparaison_remboursement_boites <- full_join(
  top_medicaments_remboursement |>
    select(cip13,lib_cip13,remboursement_total),top_medicaments_boites |>
    select(cip13,boites_delivrees),by = "cip13") |>
  arrange(desc(remboursement_total))
comparaison_remboursement_boites

write_csv(comparaison_remboursement_boites,"outputs/tableaux/eda_04_comparaison_remboursement_boites.csv")


# ------------------05. Analyse des classes thérapeutiques --------------

# Question métier :
# Quelles classes thérapeutiques (ATC) concentrent les dépenses et les volumes
# de médicaments les plus importants ?

analyse_atc1 <- open_medic_clean |>
  group_by(atc1, lib_atc1) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    nb_medicaments = n_distinct(cip13),
    .groups = "drop") |>
  arrange(desc(remboursement_total))
analyse_atc1

write_csv(analyse_atc1,"outputs/tableaux/eda_05_analyse_atc1.csv")

# ------------- Analyse des médicaments génériques ------------------

# Question métier :
# Quelle est la contribution des médicaments génériques dans les dépenses
# et les volumes remboursés ?

analyse_generiques <- open_medic_clean |>
  mutate(type_medicament = case_when(top_gen == "1" ~ "Générique", top_gen == "0" ~ "Non générique", TRUE ~ "Inconnu")) |>
  group_by(type_medicament) |>
  summarise(nb_medicaments = n_distinct(cip13),
          remboursement_total = sum(remboursement, na.rm = TRUE),
          base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
          boites_delivrees = sum(boites, na.rm = TRUE),
          .groups = "drop") |>
          mutate(part_remboursement = remboursement_total / sum(remboursement_total) * 100,
          part_boites = boites_delivrees / sum(boites_delivrees) * 100)
analyse_generiques

write_csv(analyse_generiques,"outputs/tableaux/eda_06_analyse_generiques.csv")



# ------------------- Analyse par tranche d'âge ----------------

# Question métier :
# Quelles tranches d'âge concentrent les remboursements et les consommations
# de médicaments ?

analyse_age <- open_medic_clean |>
  group_by(tranche_age) |>
  summarise(nb_medicaments = n_distinct(cip13),
            remboursement_total = sum(remboursement, na.rm = TRUE),
            base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
            boites_delivrees = sum(boites, na.rm = TRUE),
            .groups = "drop") |>
  mutate( part_remboursement = remboursement_total / sum(remboursement_total) * 100,
    part_boites = boites_delivrees / sum(boites_delivrees) * 100) |>
  arrange(desc(remboursement_total))
analyse_age

write_csv(analyse_age,"outputs/tableaux/eda_07_analyse_tranche_age.csv")


# -------------- Analyse par sexe --------------------

# Question métier :
# Existe-t-il des différences de consommation et de remboursement entre les
# femmes et les hommes ?

analyse_sexe <- open_medic_clean |>
  group_by(sexe) |>
  summarise(nb_medicaments = n_distinct(cip13),
    remboursement_total = sum(remboursement, na.rm = TRUE),
    base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    .groups = "drop") |>
  mutate(part_remboursement = remboursement_total / sum(remboursement_total) * 100,
    part_boites = boites_delivrees / sum(boites_delivrees) * 100) |>
  arrange(desc(remboursement_total))
analyse_sexe

write_csv(analyse_sexe,"outputs/tableaux/eda_08_analyse_sexe.csv")



#---------------------- Analyse territoriale ----------------

# Question métier :
# Les dépenses de médicaments sont-elles réparties de manière homogène entre
# les régions françaises ?

analyse_region <- open_medic_clean |>
  group_by(region) |>
  summarise(nb_medicaments = n_distinct(cip13),
            remboursement_total = sum(remboursement, na.rm = TRUE),
            base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
            boites_delivrees = sum(boites, na.rm = TRUE),
            .groups = "drop") |>
          mutate(part_remboursement = remboursement_total / sum(remboursement_total) * 100,
            part_boites = boites_delivrees / sum(boites_delivrees) * 100) |>
          arrange(desc(remboursement_total))
analyse_region

write_csv(analyse_region,"outputs/tableaux/eda_09_analyse_region.csv")



#----------------- Analyse des spécialités médicales ---------------

# Question métier :
# Quelles spécialités médicales génèrent les montants de remboursement les
# plus élevés ?

analyse_prescripteurs <- open_medic_clean |>
  group_by(prescripteur) |>
  summarise(nb_medicaments = n_distinct(cip13),
    remboursement_total = sum(remboursement, na.rm = TRUE),
    base_remboursement_totale = sum(base_remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    .groups = "drop") |>
  mutate(part_remboursement = remboursement_total / sum(remboursement_total) * 100,
    part_boites = boites_delivrees / sum(boites_delivrees) * 100) |>
  arrange(desc(remboursement_total))

analyse_prescripteurs

write_csv(analyse_prescripteurs,"outputs/tableaux/eda_10_analyse_prescripteurs.csv")



# ----------------- Coût moyen par boîte délivrée ------------------

# Question métier :
# Quels médicaments présentent le coût moyen par boîte le plus élevé ?

analyse_cout_boite <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    cout_moyen_boite = remboursement_total / boites_delivrees,
    .groups = "drop") |>
  filter(boites_delivrees > 0) |>
  arrange(desc(cout_moyen_boite)) |>
  slice_head(n = 20)
analyse_cout_boite

write_csv(analyse_cout_boite,"outputs/tableaux/eda_11_cout_moyen_boite.csv")


# ------------- Concentration des remboursements -------------------

# Question métier :
# Une faible proportion de médicaments concentre-t-elle la majorité des
# remboursements (principe de Pareto) ?

analyse_pareto <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),.groups = "drop") |>
  arrange(desc(remboursement_total)) |>
  mutate(rang = row_number(),
    remboursement_cumule = cumsum(remboursement_total),
    part_cumulee = remboursement_cumule / sum(remboursement_total) * 100)
analyse_pareto
# Indicateurs Pareto
pareto_resume <- tibble(
  top_10 = analyse_pareto$part_cumulee[10],
  top_20 = analyse_pareto$part_cumulee[20],
  top_50 = analyse_pareto$part_cumulee[50],
  top_100 = analyse_pareto$part_cumulee[100]
)
pareto_resume

write_csv(analyse_pareto,"outputs/tableaux/eda_12_analyse_pareto.csv")
write_csv(pareto_resume,"outputs/tableaux/eda_12_resume_pareto.csv")


# --------------- Médicaments atypiques ----------------------

# Question métier :
# Existe-t-il des médicaments très coûteux malgré un faible volume de
# délivrance ?


analyse_medicaments_atypiques <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    cout_moyen_boite = remboursement_total / boites_delivrees,
    .groups = "drop") |>
  filter(boites_delivrees > 0,
    remboursement_total >= quantile(remboursement_total, 0.95),
    boites_delivrees <= quantile(boites_delivrees, 0.25)) |>
  arrange(desc(cout_moyen_boite))
analyse_medicaments_atypiques

write_csv(analyse_medicaments_atypiques,"outputs/tableaux/eda_13_medicaments_atypiques.csv")


# ------------------ Médicaments à faible impact -----------------

# Question métier :
# Quels médicaments sont peu délivrés et représentent également une faible
# part des remboursements ?


analyse_medicaments_faible_impact <- open_medic_clean |>
  group_by(cip13, lib_cip13) |>
  summarise(remboursement_total = sum(remboursement, na.rm = TRUE),
    boites_delivrees = sum(boites, na.rm = TRUE),
    cout_moyen_boite = remboursement_total / boites_delivrees,
    .groups = "drop") |>
  filter(boites_delivrees > 0,
    remboursement_total <= quantile(remboursement_total, 0.25),
    boites_delivrees <= quantile(boites_delivrees, 0.25)) |>
  arrange(remboursement_total)
analyse_medicaments_faible_impact

# Export
write_csv(analyse_medicaments_faible_impact,"outputs/tableaux/eda_14_medicaments_faible_impact.csv")



# --------------- Synthèse des principaux enseignements -----------------

# Question métier :
# Quels sont les principaux indicateurs permettant à un décideur de disposer
# d'une vision globale du marché des médicaments remboursés ?


synthese_metier <- tibble(
  indicateur = c(
    "Nombre de médicaments",
    "Nombre de classes ATC1",
    "Nombre de régions",
    "Nombre de spécialités médicales",
    "Nombre total de boîtes",
    "Montant total remboursé (€)",
    "Base totale de remboursement (€)"
  ),
  valeur = c(
    n_distinct(open_medic_clean$cip13),
    n_distinct(open_medic_clean$atc1),
    n_distinct(open_medic_clean$region),
    n_distinct(open_medic_clean$prescripteur),
    sum(open_medic_clean$boites, na.rm = TRUE),
    sum(open_medic_clean$remboursement, na.rm = TRUE),
    sum(open_medic_clean$base_remboursement, na.rm = TRUE)
  )
)
synthese_metier

write_csv(synthese_metier,"outputs/tableaux/eda_15_synthese_metier.csv")
message("Analyse exploratoire terminée avec succès.")