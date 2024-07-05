#--------------------------------------------------------------------------------------------------
# PROJECT: Motifs Nature/Human 
# AUTHOR: JMJR
#
# TOPIC: Preparing GIS data
#--------------------------------------------------------------------------------------------------


#---------------------------------------------------------------------------------------
## PACKAGES AND LIBRARIES:
#
#---------------------------------------------------------------------------------------
#install.packages('bit64')
#install.packages('raster')
#install.packages('exactextractr')
#install.packages('rmapshaper')
#install.packages('geojsonio')

library(data.table)
library(rgdal)
library(rgeos)
library(ggplot2)
library(ggrepel)
library(sf)
library(spdep)
library(sp)
library(ggpubr)
library(dplyr)
library(tidyr)
library(scales) 
library(tidyverse)
library(lubridate)
library(gtools)
library(foreign)
library(ggmap)
library(maps)
library(gganimate)
library(gifski)
library(transformr)
library(tmap)
library(raster)
library(exactextractr)
library(matrixStats)
library(rgeos)
library(rmapshaper)
library(geojsonio)
library(plyr)
library(spatialEco)
library(haven)

#Directory: 
current_path ='C:/Users/juami/Dropbox/EA-Maps-Nathan-project/data'
setwd(current_path)

#---------------------------------------------------------------------------------------
## PREPARING FILES FOR THE WES+SEE EXTENSION:
#
#---------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# FIXING NA groups using the BEREZKIN group number in the EA 
#-------------------------------------------------------------------------------  
groups <- read_dta("interim/Motifs_EA_WESEE_groups.dta") %>% 
  dplyr::select(atlas, group_Berezkin, a1:n9)

#Fixing the BRAZILIAN's Berezkin group (Replacing with the PORTUGUES info)
source_row <- which(groups$atlas == "PORTUGUES")  
target_row <- which(groups$atlas == "BRAZILIAN")  

columns_to_copy <- setdiff(names(groups), "atlas")
groups[target_row, columns_to_copy] <- groups[source_row, columns_to_copy]

#Fixing the BAGIRMI's Berezkin group (Replacing with the v114=70 in EA info)
groups[which(groups$atlas == "BAGIRMI"), columns_to_copy] <- groups[which(groups$atlas == "SARA"), columns_to_copy]

#Fixing the CANTONESE's Berezkin group (Replacing with the v114=164 in EA info - only other group in the book)
groups[which(groups$atlas == "CANTONESE"), columns_to_copy] <- groups[which(groups$atlas == "MINCHINES"), columns_to_copy]

#Fixing the Berezkin group v144=369 (Replacing with PORTUGUES in EA info - Language based on portugues according to the book)
groups[which(groups$atlas == "DJUKA"), columns_to_copy] <- groups[which(groups$atlas == "PORTUGUES"), columns_to_copy]
groups[which(groups$atlas == "SARAMACCA"), columns_to_copy] <- groups[which(groups$atlas == "PORTUGUES"), columns_to_copy]

#Fixing the FUR's Berezkin group (No other group in berezkin cluster nor language reference in the book - v144=98)
#groups[which(groups$atlas == "FUR"), columns_to_copy] <- groups[which(groups$atlas == ""), columns_to_copy]

#Fixing the GUATO's Berezkin group (No other group in berezkin cluster nor language reference in the book - v144=398)
#groups[which(groups$atlas == "GUATO"), columns_to_copy] <- groups[which(groups$atlas == ""), columns_to_copy]

#Fixing the HUTSUL's Berezkin group (Replacing with the v114=126 in EA info - closer ethnicity within group in the book)
groups[which(groups$atlas == "HUTSUL"), columns_to_copy] <- groups[which(groups$atlas == "CZECHS"), columns_to_copy]

#Fixing the IDOMA's Berezkin group (Replacing with the v114=42 in EA info - closest ethnicity within group in the book)
groups[which(groups$atlas == "IDOMA"), columns_to_copy] <- groups[which(groups$atlas == "AFO"), columns_to_copy]
groups[which(groups$atlas == "IGALA"), columns_to_copy] <- groups[which(groups$atlas == "AFO"), columns_to_copy]
groups[which(groups$atlas == "KORO"), columns_to_copy] <- groups[which(groups$atlas == "AFO"), columns_to_copy]

#Fixing the KURAMA's Berezkin group (Replacing with the v114=63 in EA info - closer ethnicity within group in the book)
groups[which(groups$atlas == "KURAMA"), columns_to_copy] <- groups[which(groups$atlas == "KAGORO"), columns_to_copy]

#Fixing the CANTONESE's Berezkin group (Replacing with the v114=71 in EA info - closer ethinicity in the book)
groups[which(groups$atlas == "MBANDJA"), columns_to_copy] <- groups[which(groups$atlas == "NGBANDI"), columns_to_copy]

#Fixing the CANTONESE's Berezkin group (Replacing with the v114=120 in EA info - 1st group in the book)
groups[which(groups$atlas == "TRISTAN"), columns_to_copy] <- groups[which(groups$atlas == "NEWENGLAN"), columns_to_copy]

#Fixing the CANTONESE's Berezkin group (Replacing with the v114=233 in EA info - 1st group in the book)
groups[which(groups$atlas == "YIRYORONT"), columns_to_copy] <- groups[which(groups$atlas == "WIKMUNKAN"), columns_to_copy]

#Fixing the CANTONESE's Berezkin group (Replacing with the v114=66 in EA info - 1st group in the book)
groups[which(groups$atlas == "YUNGUR"), columns_to_copy] <- groups[which(groups$atlas == "MUMUYE"), columns_to_copy]

#Wide to long data set 
groups_motifs <- groups %>% 
  pivot_longer(a1:n9, names_to = "motif_id", values_to = "share") %>% 
  mutate(motif_id = gsub("_$", "", motif_id))

#keeping only stories belonging to each group 
groups_motifs <- groups_motifs %>% 
  mutate(share = as.numeric(share)) %>% 
  filter(share != 0) %>% 
  mutate(share = ifelse(share == 2, 1, share)) %>% 
  filter(!is.na(share))

#For later use
write.csv(groups_motifs, "interim/Motifs_EA_WESEE_groups_long.csv", row.names=FALSE)

