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
current_path ='C:/Users/juami/Dropbox/EA-Maps-Nathan-project/'
setwd(current_path)


#---------------------------------------------------------------------------------------
## PREPARING SHAPEFILES:
#
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Countries boundaries:
#---------------------------------------------------------------------------------------
#Importing World countries shapefile
countries <- st_read(dsn = "maps/raw/World_Countries_Generalized", layer = "World_Countries_Generalized")
countries <- st_make_valid(countries)
countries_crs <- st_crs(countries)

#Exporting values only
coutries_attributes <- as.data.frame(countries)
coutries_attributes <- coutries_attributes %>%
  dplyr::select(-geometry)

write.csv(coutries_attributes , "data/interim/countryISO_concordance.csv", row.names = FALSE)

#---------------------------------------------------------------------------------------
# Preparing Ethnologue:
#---------------------------------------------------------------------------------------
ethnologue <- st_read(dsn = "data/raw/ethnologue/ancestral_characteristics_database_language_level/Ancestral_Characteristics_Database_Language_Level/Ethnologue_16_shapefile", layer = "langa_no_overlap_biggest_clean")
ethnologue <- st_make_valid(ethnologue)
st_crs(ethnologue)==st_crs(countries)

#Creating ISO 
ethnologue <- ethnologue %>% 
  mutate(ISO = str_extract(toupper(ID_ISO_A2), "(?<=-).*")) 

#Importing data on Motifs 
motifs <- read.csv("C:/Users/juami/Dropbox/EA-Maps-Nathan-project/data/interim/Motifs_EA_Ethnologue_humanvsnature.csv")
names(motifs)[names(motifs) == "id"] <- "ID"

#Merging Ethonologue and Motifs together
ethnologueMotifs <- left_join(ethnologue, motifs, by="ID")

#Not necessary because ethnologue is already divided by country 
#new <- st_intersection(st_make_valid(countries), st_make_valid(ethnologueMotifs))


#---------------------------------------------------------------------------------------
## PREPARING RASTERS FILES:
#
#---------------------------------------------------------------------------------------
#Importing the LAndScan 2009 population density raster 
popDen <- raster('C:/Users/juami/Dropbox/EA-Maps-Nathan-project/maps/raw/Landscan/landscan-global-2009-assets/landscan-global-2009.tif')


#---------------------------------------------------------------------------------------
## Creating the weighted measure of Nature Motifs by Ethnic population density
#
#---------------------------------------------------------------------------------------
#Calculating population per country 
countries$pop_country<- exact_extract(popDen, countries, 'sum')
countryISO <- countries %>% 
  group_by(ISO) %>% 
  dplyr::summarise(total_pop_country = sum(pop_country, na.rm = TRUE))

#Calculating population per ethnicity-country  
ethnologueMotifs$pop_ethnic<- exact_extract(popDen, ethnologueMotifs, 'sum')

#Calculating I_e x sum_i N_{e,i,c} FOR ALL MEASURES RELATED TO NATURE 
ethnologueMotifs <- ethnologueMotifs %>%
  mutate(
    NexIe_v2 = pop_ethnic * shwrds_nature_v2,
    NexIe = pop_ethnic * shwrds_nature,
    NexIe_v2_cl2 = pop_ethnic * shwrds_nature_v2_cl2,
    NexIe_cl2 = pop_ethnic * shwrds_nature_cl2
    )

nonSpatial_ethnologueMotifs <- as.data.frame(ethnologueMotifs)
nonSpatial_ethnologueMotifs <- nonSpatial_ethnologueMotifs %>%
  dplyr::select(-geometry)

#Collapsing at the country level (summing up all ethinicities within a country)
country_motifs <- nonSpatial_ethnologueMotifs %>%
  group_by(ISO) %>%
  dplyr::summarise(
    TotalNexIe_v2 = sum(NexIe_v2, na.rm = TRUE),
    TotalNexIe = sum(NexIe, na.rm = TRUE),
    TotalNexIe_v2_cl2 = sum(NexIe_v2_cl2, na.rm = TRUE),
    TotalNexIe_cl2 = sum(NexIe_cl2, na.rm = TRUE)
    )

#Creating the final measure
countryISO <- left_join(countryISO, country_motifs, by="ISO")

countryISO <- countryISO %>%
  mutate(
    WIc_v2 = TotalNexIe_v2 / total_pop_country,
    WIc = TotalNexIe / total_pop_country,
    WIc_v2_cl2 = TotalNexIe_v2_cl2 / total_pop_country,
    WIc_cl2 = TotalNexIe_cl2 / total_pop_country
  )

#Eample of an Island with measure greater then 1
#X <- subset(countryISO, WIc >1)

#Correcting values greater than one
countryISO$WIc[countryISO$WIc > 1] <- 1
countryISO$WIc_v2[countryISO$WIc_v2 > 1] <- 1
countryISO$WIc_cl2[countryISO$WIc_cl2 > 1] <- 1
countryISO$WIc_v2_cl2[countryISO$WIc_v2_cl2 > 1] <- 1

st_write(countryISO, "maps/interim/countryISO_WIc.shp", driver = "ESRI Shapefile", append = FALSE)

#Exporting values only
nonSpatial_countries <- as.data.frame(countryISO)
nonSpatial_countries <- nonSpatial_countries %>%
  dplyr::select(-geometry)

write.csv(nonSpatial_countries , "data/interim/countryISO_Wmotifs_nature.csv", row.names = FALSE)






#END