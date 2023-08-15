load_packages <- function(do_it = T){
if(!require(ncdf4)) install.packages("ncdf4"); library(ncdf4)
if(!require(sf)) install.packages("sf"); library(sf)
if(!require(raster)) install.packages("raster"); library(raster)
if(!require(exactextractr)) install.packages("exactextractr"); library(exactextractr)
if(!require(data.table)) install.packages("data.table"); library(data.table)
if(!require(terra)) install.packages("terra"); library(terra)
  
}