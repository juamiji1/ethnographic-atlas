rm(list = ls())

library(dplyr)
library(ggplot2)
library(readxl)
library(tidyverse)
library(ggtext)
library(haven)
library(sf)

set.seed("123")

# change to your working directory here
setwd("C:/Users/juami/Dropbox/Nathan project/oldra/")

Main <- function() {
  words_cat <- CategorizeWords()
  
  motifs <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motif_Master.dta") 
  motifs <- GetWordCounts(motifs, words_cat)
  
  groups <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motifs_Berezkin_groups.dta") %>% 
    dplyr::select(group_Berezkin, a1:n9)
  
  groups_geo <- CreateGroupsGeo()
  countries_map <- ImportCountryMap()
  groups_geo <- st_join(groups_geo, countries_map)

  groups_motifs <- CreateGroupMotifData(groups, motifs)
  groups_motifs_col <- CreateGroupColumns(groups_motifs)

  countries <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motifs_Countries.dta")
  countries_col <- CreateCountryColumns(motifs, countries)
  
  countries_map <- countries_map %>% 
    full_join(countries_col, by = "cntry") %>% 
    filter(!is.na(country_name)) %>% 
    filter(!is.na(share_all))
  
  groups_motifs_col <- groups_geo %>% 
    full_join(groups_motifs_col, by = "group_Berezkin")

  groups_motifs <- groups_motifs %>% 
    full_join(groups_geo, by = "group_Berezkin")
  
  OutputColTables(groups_motifs_col)
  
  OutputGroupList(groups_motifs)
  
  OutputGroupCSV(groups_motifs, group = "French")
  OutputGroupCSV(groups_motifs, group = "Mende,Bandi,Loma")
  OutputGroupCSV(groups_motifs, group = "Trans NG East Lowlands North")
  
  OutputConceptCSV(motifs, concept_col = "nature_count", 
                   abbr = "nat", num_motifs = 200)  
  
  groups_motifs <- groups_motifs %>% 
    mutate(europe = as.numeric(continent == "Europe"),
           africa = as.numeric(continent == "Africa"))
  
  OutputConceptCSV(groups_motifs, concept_col = "europe",
                   abbr = "eur", num_motifs = 50)

  OutputConceptCSV(groups_motifs, concept_col = "africa",
                   abbr = "afr", num_motifs = 50)
  
  OutputMap(groups_motifs_col, countries_map)
}


OutputColTables <- function(groups_motifs_col) {
  # output ranked summary statistics
  # across different geographic units (continents, groups, ...)
  # dep. var: share of any theme-related motifs out of all motifs
  
  groups_motifs_col <- groups_motifs_col %>% 
    as.data.frame %>% 
    dplyr::select(-geometry) %>% 
    filter(!is.na(continent))
  
  group_var <- "continent"
  rel_var <- "animal_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "continent"
  rel_var <- "animal_not_human_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "continent"
  rel_var <- "plant_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "continent"
  rel_var <- "inanimate_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "continent"
  rel_var <- "human_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "continent"
  rel_var <- "nature_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  
  group_var <- "subregion"
  rel_var <- "animal_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "subregion"
  rel_var <- "animal_not_human_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "subregion"
  rel_var <- "plant_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "subregion"
  rel_var <- "inanimate_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "subregion"
  rel_var <- "human_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)
  
  group_var <- "subregion"
  rel_var <- "human_not_nature_any"
  
  groups_motifs_col %>% 
    group_by(!!sym(group_var)) %>% 
    summarize("{rel_var}" := mean(!!sym(rel_var), rm.na = T)) %>% 
    arrange(-!!sym(rel_var)) %>% 
    rename("{rel_var}_sh" := !!sym(rel_var)) %>% 
    write.csv(sprintf("output/analysis/tables/aggr_%s_%s_sh.csv", group_var, rel_var),
              row.names = F)

  
}


OutputMap <- function(groups_motifs_col, countries_map) {
  # Output map that has a point for every Berezkin group
  # with today's countries as basemap
  
  plot_var <- "nature_not_human_any_med"
  treat_label <- "Nature Motif Share (Exclusive, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "animal_not_human_any_med"
  treat_label <- "Animal Motif Share (Exclusive, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "human_not_animal_any_med"
  treat_label <- "Human Motif Share (Exclusive, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "human_not_nature_any_med"
  treat_label <- "Human Motif Share (Exclusive, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "human_any_med"
  treat_label <- "Human Motif Share (Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "animal_any_med"
  treat_label <- "Animal Motif Share (Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "plant_any_med"
  treat_label <- "Plant Motif Share (Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)

  plot_var <- "inanimate_any_med"
  treat_label <- "Inanimate Motif Share (Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)

  plot_var <- "nature_any_med"
  treat_label <- "Nature Motif Share (Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "nature_maj_any_med"
  treat_label <- "Nature Motif Share (Majority, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
  
  plot_var <- "human_maj_any_med"
  treat_label <- "Human Motif Share (Majority, Above Med.)"
  
  OutputBinaryMap(groups_motifs_col, countries_map,
                  plot_var = plot_var, treat_label = treat_label)
}


OutputBinaryMap <- function(groups_motifs_col, countries_map,
                            plot_var, treat_label) {
  # outputs map of binary dependent variable, with country basemap
  
  plt <- ggplot() + 
    geom_sf(data = countries_map, aes(),
            fill = 'white', color = 'lightgrey') +
    theme(panel.background = element_rect(fill = 'white', color = 'white')) +
    geom_sf(data = groups_motifs_col,
            aes(color = as.factor(!!sym(plot_var)))) +
    scale_color_grey(start = 0.8, end = 0.2)
  # tbd: scale_color_discrete instead
  
  plt <- plt + theme_bw() +
    theme(panel.grid.major = element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5),
          plot.margin=grid::unit(c(0,0,0,0), "mm"),
          legend.position = "bottom") +
    labs(color = treat_label,
         fill = treat_label)
  
  ggsave(sprintf("output/analysis/maps/group_%s.png", plot_var),
         width = 6.92, height = 3.42)
  
  return(plt)
}



CreateGroupsGeo <- function() {
  # merge Berezkin group to their lat-lon
  
  groups_geo <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Replication_Tables_Figures/Berezkin_groups_Regressions_Ready.dta") %>% 
    dplyr::select(group_Berezkin, motifs_total,
                  nmbr_author, nmbr_language, nmbr_publisher, nmbr_title,    
                  year_firstpub, year_avgpub,
                  latitude_forgeo, longitude_forgeo)
  groups_geo <- groups_geo %>% 
    st_as_sf(coords = c("longitude_forgeo", "latitude_forgeo"))
  st_crs(groups_geo) <- 4326
  # library(mapview)
  # mapview(group_geo)
  
  return(groups_geo)
}



OutputGroupList <- function(groups_motifs) {
  # output list of all groups
  
  groups <- groups_motifs %>% 
    group_by(group_Berezkin) %>% 
    summarize(n_motifs = n())
  write.csv(groups, "output/analysis/tables/groups.csv", row.names = F)
}


OutputGroupCSV <- function(groups_motifs, group) {
  # output list of 50 motifs for certain Berezkin group
  
  groups_motifs <- groups_motifs %>% 
    dplyr::select("group_Berezkin", "motif_id","desc_eng", contains("_count"))
  
  groups_motifs_sub <- groups_motifs %>% 
    filter(group_Berezkin == group)
  
  groups_motifs_sub <- groups_motifs_sub %>% 
    sample_n(50)
  
  group_name <- tolower(group)
  group_name <- gsub(",", "_", group_name)
  
  write.csv(groups_motifs_sub, sprintf("output/analysis/tables/motifs_%s.csv", tolower(group_name)),
            row.names = F)  
}

OutputConceptCSV <- function(motifs, concept_col, abbr, num_motifs) {
  # output list of concept-related motifs
  
  
  motifs_sub <- motifs %>% 
    filter(!!sym(concept_col) > 0)
  
  motifs_sub <- motifs_sub %>% 
    dplyr::select(motif_id, desc_eng) %>% 
    sample_n(num_motifs)
  
  write.csv(motifs_sub, sprintf("output/analysis/tables/motifs_%s.csv", abbr),
            row.names = F)
}


BinaryMap <- function(data, treat_var, treat_label) {
  # creates binary map
  
  plt <- data %>% 
    mutate(!!sym(treat_var) := as.factor(!!sym(treat_var))) %>% 
    ggplot() + 
    geom_sf(aes(fill=!!sym(treat_var))) +
    theme_bw() +
    theme(panel.grid.major = element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5),
          plot.margin=grid::unit(c(0,0,0,0), "mm")) +
    labs(color = treat_label,
         fill = treat_label) +
    scale_fill_manual(values = c("grey", "black")) +
    scale_color_manual(values = c("grey", "black"))
  
  return(plt)
}


CategorizeWords <- function() {
  # import all categorized words from word lists
  
  words_cat <- read.csv("source/analysis/words_categorized.csv") 
  names(words_cat) <- c("word", "animal", "plant", "inanimate", "human", "object")
  
  words_cat <- words_cat %>% 
    mutate(word = tolower(word))
  
  animals <- read.csv("source/raw/animal_names/data/animals.txt")
  colnames(animals) <- "word"
  
  animals <- animals %>% 
    mutate(word = tolower(word))
  
  animals <- animals %>% 
    filter(!grepl(' ', word))
  
  animals <- animals %>% 
    filter(!grepl('list', word))
  
  
  animals <- animals %>% 
    mutate(animal = 1)
  
  words_cat <- words_cat %>% 
    bind_rows(animals)
  
  words_cat <- words_cat %>% 
    distinct(word, .keep_all = T)
  
  return(words_cat)
}


GetWordCounts <- function(motifs, words_cat) {
  # for each motif description, compare to word list and create
  # indicator if category-related word is present in description
  # also create indicator if category A is present but category B not
  # and create indicator if category A has more words than any category not A
  
  # all_words <- unlist(str_split(motifs$desc_eng, pattern = " "))
  # word_list <- as.data.frame(table(all_words)) %>% 
  #   arrange(-Freq)
  
  motifs <- motifs %>% 
    mutate(desc_eng_lc = tolower(desc_eng))
  
  motifs <- motifs %>% 
    mutate(animal_count = stringr::str_count(desc_eng_lc, 
                                             paste0("\\b", words_cat[words_cat$animal == 1, ]$word, "\\b", collapse = "|")),
           plant_count = stringr::str_count(desc_eng_lc, 
                                             paste0("\\b", words_cat[words_cat$plant == 1, ]$word, "\\b", collapse = "|")),
           inanimate_count = stringr::str_count(desc_eng_lc, 
                                             paste0("\\b", words_cat[words_cat$inanimate == 1, ]$word, "\\b", collapse = "|")),
           human_count = stringr::str_count(desc_eng_lc, 
                                            paste0("\\b", words_cat[words_cat$human == 1, ]$word, "\\b", collapse = "|")),
           word_count = str_count(desc_eng, "\\S+"))
  
  
  #View(motifs %>% select(, animal_count, nature_count, human_count))
  
  motifs <- motifs %>% 
    select("motif_id", "desc_eng", "animal_count", "plant_count", "inanimate_count", "human_count", "word_count")
  
  motifs <- motifs %>% 
    mutate(nature_count = animal_count + plant_count + inanimate_count)
  # mutate(nature_count = animal_count + plant_count + inanimate_count)
  
  motifs <- motifs %>% 
    mutate(nature_maj = as.numeric(nature_count > human_count),
           human_maj = 1-nature_maj,
           not_human = as.numeric(human_count == 0),
           not_animal = as.numeric(animal_count == 0),
           not_plant = as.numeric(plant_count == 0),
           not_nature = as.numeric(nature_count == 0),
           nature_maj_count = nature_count * nature_maj,
           human_maj_count = human_count * human_maj,
           nature_sh = nature_count / word_count,
           human_sh = human_count / word_count,
           nature_sh_rel = nature_count / (nature_count + human_count),
           human_sh_rel = human_count / (nature_count + human_count),
           human_not_nature_count = human_count * not_nature,
           nature_not_human_count = nature_count * not_human,
           human_not_animal_count = human_count * not_animal,
           animal_not_human_count = animal_count * not_human)
  
  return(motifs)
}


CreateGroupMotifData <- function(groups, motifs) {
  # merge groups to motifs
  
  groups_motifs <- groups %>% 
    pivot_longer(a1:n9, names_to = "motif_id", values_to = "share") %>% 
    mutate(motif_id = gsub("_$", "", motif_id))
  
  groups_motifs <- groups_motifs %>% 
    mutate(share = as.numeric(share)) %>% 
    filter(share != 0) %>% 
    mutate(share = ifelse(share == 2, 1, share)) %>% 
    filter(!is.na(share))
  
  groups_motifs <- groups_motifs %>% 
    left_join(motifs, by = "motif_id")
  
  stopifnot(sum(is.na(groups_motifs$word_count)) == 0)
  
  return(groups_motifs)
}


CreateCountryColumns <- function(motifs, countries) {
  # merge motifs to countries (currently not used downstream)
  
  countries_long <- countries %>% 
    pivot_longer(a1:n9, names_to = "motif_id", values_to = "share") %>% 
    mutate(motif_id = gsub("_$", "", motif_id))
  
  countries_long <- countries_long %>% 
    left_join(motifs, by = "motif_id")
  
  stopifnot(sum(is.na(countries_long$word_count)) == 0)
  
  rel_vars <- c("animal_count", "plant_count", "inanimate_count", "human_count", "nature_count")
  
  # countries_long <- countries_long %>% 
  #   mutate(share_half = as.numeric(share >= 0.5))
  
  countries_long <- countries_long %>% 
    mutate(across(all_of(rel_vars), ~ as.numeric(. > 0),
                  .names = '{col}_any'))
  
  names(countries_long) <- gsub('_count_any', '_any', names(countries_long))
  
  countries_long <- countries_long %>% 
    mutate(across(ends_with('_any'), ~ . * share,
                  .names = '{col}Xshare'))
  
  countries_col <- countries_long %>% 
    group_by(cntry) %>% 
    summarize(
      share_all = sum(share),
      across(ends_with('_anyXshare'), ~ sum(.))
    )
  
  
  countries_col <- countries_col %>% 
    mutate(across(ends_with('_anyXshare'), ~ . / share_all))
  
  countries_col <- countries_col %>% 
    mutate(across(ends_with('_anyXshare'), ~ as.numeric(. > median(., na.rm = T)),
                  .names = '{col}_med'))
  
  return(countries_col)
}


CreateGroupColumns <- function(groups_motifs) {
  # for each group, get number of category-related motifs
  
  
  rel_vars <- c("animal_count", "plant_count", "inanimate_count", 
                "human_count", "nature_count",
                "nature_maj_count", "human_maj_count",
                "nature_not_human_count", "human_not_nature_count",
                "human_not_animal_count", "animal_not_human_count")
  
  # countries_long <- countries_long %>% 
  #   mutate(share_half = as.numeric(share >= 0.5))
  
  groups_motifs_long <- groups_motifs %>% 
    mutate(across(all_of(rel_vars), ~ as.numeric(. > 0),
                  .names = '{col}_any'))
  
  names(groups_motifs_long) <- gsub('_count_any', '_any', names(groups_motifs_long))
  
  groups_motifs_col <- groups_motifs_long %>% 
    group_by(group_Berezkin) %>% 
    summarize(
      motif_all = sum(share),
      across(ends_with('_any'), ~ sum(.))
    )
  
  
  groups_motifs_col <- groups_motifs_col %>% 
    mutate(across(ends_with('_any'), ~ . / motif_all))
  
  groups_motifs_col <- groups_motifs_col %>% 
    mutate(across(ends_with('_any'), ~ as.numeric(. > median(., na.rm = T)),
                  .names = '{col}_med'))
  
  groups_motifs_col <- groups_motifs_col %>% 
    mutate(across(ends_with('_any'), ~ log(. + 0.01),
                  .names = '{col}_ln'))
  
  return(groups_motifs_col)
}


ImportCountryMap <- function() {
  # import country shapefile.
  # st_make_valid is necessary but produces strange geometries (lines through Brasil Russia)
  # tbd: use better country map here
  
  countries_map <- st_read("source/raw/world_administrative_boundaries/data/WB_countries_Admin0_10m.shp") %>% 
    mutate(ISO_A3_EH = ifelse(ISO_A3_EH == -99, ISO_A3, ISO_A3_EH),
           ISO_A3_EH = ifelse(ISO_A3_EH == -99, WB_A3, ISO_A3_EH)) %>% 
    dplyr::select(FORMAL_EN, ISO_A3_EH, CONTINENT, SUBREGION) %>% 
    rename(continent = CONTINENT,
           subregion = SUBREGION,
           country_name = FORMAL_EN,
           cntry = ISO_A3_EH) %>% 
    mutate(cntry = as.character(cntry)) %>% 
    filter(!is.na(country_name))
  
  countries_map <- countries_map %>% 
    st_make_valid()
  
  return(countries_map)
}


Main()
