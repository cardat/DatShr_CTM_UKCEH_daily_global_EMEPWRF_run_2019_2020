# tar_load(dat_yy)

do_aggrgt_grid <- function(
    varlist=dat_yy
    ,
    infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
    ,
    study_period = list(mindate="2019-01-01", maxdate ="2019-12-31")
    ,
    var_i = "SURF_ug_PM25"
    ,
    do_save_tiffs = TRUE
    ,
    filename = "data_derived/SURF_ug_PM25_2019_annual_average.tif"
    ){
  
  b <- raster::brick(infile, varname = var_i)
  ##b
  b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
  crs(b2) <- "EPSG:4326"
  b_avg <- mean(b2)
  #plot(b_avg)
  b_avg2 <- rast(b_avg)
  
  if(do_save_tiffs){
    terra::writeRaster(b_avg2, filename)
  }
  b_avg2 <- terra::wrap(b_avg2)
  return(b_avg2)
}