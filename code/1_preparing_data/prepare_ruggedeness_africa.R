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
current_path ='C:/Users/juami/Dropbox/2-Folklore-Nathan-Project/EA-Maps-Nathan-project/Measures_work/maps/raw'
setwd(current_path)

africaShp <- st_read(dsn = "Africa_Countries", layer = "Africa_Countries")
sourceShp <- st_read(dsn = "gtopo30", layer = "gtopo30")

r <-raster("tri/tri.txt")
crs(r)<-crs(sourceShp)
writeRaster(r, filename=file.path(current_path, "tri/tri.tif"), format="GTiff", overwrite=TRUE)


#tri_crop1 <- crop(r, africaShp)
#tri_crop2 <- mask(tri_crop1, africaShp)

#writeRaster(tri_crop1, filename=file.path(current_path, "tri/tri.tif"), format="GTiff", overwrite=TRUE)

#lot(tri_crop2)

