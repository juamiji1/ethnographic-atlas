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


#-------------------------------------------------------------------------------
# Fixing categories and word lists
#-------------------------------------------------------------------------------  

#Importing all categories
words_cat <- read.csv("source/analysis/words_categorized.csv") 
names(words_cat) <- c("word", "animal", "plant", "inanimate", "human", "object")

words_cat <- words_cat %>% 
  mutate(word = tolower(word))

#Importing animals list
animals <- read.csv("source/raw/animal_names/data/animals.txt")
colnames(animals) <- "word"

animals <- animals %>% 
  mutate(word = tolower(word))

#Keeping only one word
animals <- animals %>% 
  filter(!grepl(' ', word))

animals <- animals %>% 
  filter(!grepl('list', word))

animals <- animals %>% 
  mutate(animal = 1)

#Adding more animals to categories data frame
words_cat <- words_cat %>% 
  bind_rows(animals)

words_cat <- words_cat %>% 
  distinct(word, .keep_all = T)
  
#Importing god vs gods list
words_cat_god <- read.csv("source/analysis/words_categorized_god_vs_other.csv") 

#-------------------------------------------------------------------------------
# Counting categories in Motifs from Folklore raw data 
#-------------------------------------------------------------------------------  
motifs <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motif_Master.dta")   
  
motifs <- motifs %>% 
  mutate(desc_eng_lc = tolower(desc_eng))

#Counting words by creating a regex pattern from the word categories chosen 
motifs <- motifs %>% 
  mutate(animal_count = stringr::str_count(desc_eng_lc, 
                                           paste0("\\b", words_cat[words_cat$animal == 1, ]$word, "\\b", collapse = "|")),
         plant_count = stringr::str_count(desc_eng_lc, 
                                          paste0("\\b", words_cat[words_cat$plant == 1, ]$word, "\\b", collapse = "|")),
         inanimate_count = stringr::str_count(desc_eng_lc, 
                                              paste0("\\b", words_cat[words_cat$inanimate == 1, ]$word, "\\b", collapse = "|")),
         human_count = stringr::str_count(desc_eng_lc, 
                                          paste0("\\b", words_cat[words_cat$human == 1, ]$word, "\\b", collapse = "|")),
         god_count = stringr::str_count(desc_eng_lc, 
                                          paste0("\\b", words_cat[words_cat_god$god == 1, ]$word, "\\b", collapse = "|")),
         othergods_count = stringr::str_count(desc_eng_lc, 
                                          paste0("\\b", words_cat[words_cat_god$other == 1, ]$word, "\\b", collapse = "|")),
         ancestor_count = stringr::str_count(desc_eng_lc, 
                                        paste0("\\b", words_cat[words_cat_god$ancestor == 1, ]$word, "\\b", collapse = "|")),
         word_count = str_count(desc_eng, "\\S+"))

motifs <- motifs %>% 
  select("motif_id", "desc_eng", "animal_count", "plant_count", "inanimate_count", "human_count", "god_count", "othergods_count", "ancestor_count", "word_count")

motifs <- motifs %>% 
  mutate(nature_count = animal_count + plant_count + inanimate_count,
         ancesplusgod_count = ancestor_count + god_count)

#Creating different versions of Nature vs non-Nature
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

#-------------------------------------------------------------------------------
# Preparing groups and motifs together 
#-------------------------------------------------------------------------------  
#groups <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motifs_Berezkin_groups.dta") %>% 
#  dplyr::select(group_Berezkin, a1:n9)
groups <- read_dta("source/raw/folklore/data/Replication_Data_Folklore/Original_Files/Motifs_EA_groups.dta") %>% 
  dplyr::select(atlas, group_Berezkin, a1:n9)
  
#Wide to long data set 
groups_motifs <- groups %>% 
  pivot_longer(a1:n9, names_to = "motif_id", values_to = "share") %>% 
  mutate(motif_id = gsub("_$", "", motif_id))

groups_motifs <- groups_motifs %>% 
  mutate(share = as.numeric(share)) %>% 
  filter(share != 0) %>% 
  mutate(share = ifelse(share == 2, 1, share)) %>% 
  filter(!is.na(share))

#Joining motifs to groups using the Motifs IDs as the key variable
groups_motifs <- groups_motifs %>% 
  left_join(motifs, by = "motif_id")

#Fixing variables of interest 
rel_vars <- c("animal_count", "plant_count", "inanimate_count", 
              "human_count", "nature_count",
              "nature_maj_count", "human_maj_count",
              "nature_not_human_count", "human_not_nature_count",
              "human_not_animal_count", "animal_not_human_count", "god_count", "othergods_count", "ancestor_count", "ancesplusgod_count")

#Creating vars that account for the topic instead of the actual times a category was mentioned
# What to do when mentionting two categories? 
groups_motifs_long <- groups_motifs %>% 
  mutate(across(all_of(rel_vars), ~ as.numeric(. > 0),
                .names = '{col}_any'))

#Renaming
names(groups_motifs_long) <- gsub('_count_any', '_any', names(groups_motifs_long))

#Collapsing at the Group level by only calculating totals
groups_motifs_coll <- groups_motifs_long %>% 
  group_by(atlas, group_Berezkin) %>% 
  summarize(
    motif_all = sum(share),
    across(ends_with('_any'), ~ sum(.))
  )

#Calculating god vs gods measures + ancestor*/(Ancestor* + God)
groups_motifs_coll <- groups_motifs_coll %>% 
  mutate(godvsgods = god_any/othergods_any, 
         ancestor_sh_v2 = ancestor_any/ancesplusgod_any)

#Calculating shares 
groups_motifs_coll <- groups_motifs_coll %>% 
  mutate(across(ends_with('_any'), 
                ~ . / motif_all, 
                .names = "{.col}_sh"))

names(groups_motifs_coll) <- gsub('_any_sh', '_sh', names(groups_motifs_coll))

#Calculating median dummies
medians <- sapply(groups_motifs_coll %>% select(ends_with('_sh')), median, na.rm = TRUE)

groups_motifs_coll <- groups_motifs_coll %>% 
  mutate(across(ends_with('_sh'), 
                ~ as.numeric(. > medians[cur_column()]), 
                .names = '{col}_med'))


write.csv(groups_motifs_coll, "C:/Users/juami/Dropbox/Nathan project/data/interim/folklore_ea_nature.csv", row.names=FALSE)





#END









  
  