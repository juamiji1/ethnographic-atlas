#--------------------------------------------------------------------------------------------------
# PROJECT: Motifs Nature/Human 
# AUTHOR: JMJR
#
# TOPIC: Preparing GIS data
#--------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# PACKAGES AND LIBRARIES:
#---------------------------------------------------------------------------------------

# Install packages if not already installed
required_packages <- c('data.table', 'rgdal', 'rgeos', 'ggplot2', 'ggrepel', 'sf', 'spdep', 'sp', 
                       'ggpubr', 'dplyr', 'tidyr', 'scales', 'tidyverse', 'lubridate', 'gtools', 
                       'foreign', 'ggmap', 'maps', 'gganimate', 'gifski', 'transformr', 'tmap', 
                       'raster', 'exactextractr', 'matrixStats', 'rmapshaper', 'geojsonio', 
                       'plyr', 'spatialEco', 'here')

install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
}
install_if_missing(required_packages)

# Load libraries
lapply(required_packages, library, character.only = TRUE)

#---------------------------------------------------------------------------------------
# DIRECTORY SETUP:
#---------------------------------------------------------------------------------------
current_path <- 'C:/Users/juami/Dropbox/EA-Maps-Nathan-project/'
setwd(current_path)

set_here()
# Use 'here' package for managing file paths
library(here)
here::i_am('.here') 

#---------------------------------------------------------------------------------------
# PREPARING SHAPEFILES:
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Preparing Countries boundaries:
#---------------------------------------------------------------------------------------
# Importing World countries shapefile
countries <- st_read(dsn = here("maps/raw/World_Countries_Generalized"), layer = "World_Countries_Generalized")
countries_crs <- st_crs(countries)

#---------------------------------------------------------------------------------------
# Preparing Ethnologue:
#---------------------------------------------------------------------------------------
ethnologue <- st_read(dsn = here("data/raw/ethnologue/ancestral_characteristics_database_language_level/Ancestral_Characteristics_Database_Language_Level"), layer = "langa_no_overlap_biggest_clean")

# Check if CRS match and transform if necessary
if (!st_crs(ethnologue) == st_crs(countries)) {
  ethnologue <- st_transform(ethnologue, st_crs(countries))
}

# Importing data on Motifs
motifs <- read.csv(here("data/interim/Motifs_EA_Ethnologue_humanvsnature.csv"))
names(motifs)[names(motifs) == "id"] <- "ID"

# Merging Ethnologue and Motifs together
ethnologueMotifs <- left_join(ethnologue, motifs, by = "ID")

# Ensure geometries are valid before intersection
countries <- st_make_valid(countries)
ethnologueMotifs <- st_make_valid(ethnologueMotifs)

# Intersecting the countries and ethnologue motifs
new <- st_intersection(countries, ethnologueMotifs)

# Save the resulting shapefile (if needed)
st_write(new, here("data/interim/ethnologue_motifs_countries_intersection.shp"))
