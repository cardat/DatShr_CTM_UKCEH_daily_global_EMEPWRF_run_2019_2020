# tar_load(dat_yy)

do_qc_annav_who <- function(
    varlist=dat_yy
    ,
    infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
    ,
    study_period = list(mindate="2019-01-01", maxdate ="2019-12-31")
    ,
    var_i = "SURF_ug_PM25"
    ,
    infile_annav_who = "C:/Users/287658c/OneDrive - Curtin/Shared/cardat_uploads_from_ivan/WHO_air_quality_database/WHO_air_quality_database_v6/data_provided/who_ambient_air_quality_database_version_2024_(v6.1).csv"
){
  #### get the ctm ####
  b <- raster::brick(infile, varname = var_i)
  ##b
  b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
  crs(b2) <- "EPSG:4326"
  b2 <- brick(b2)
  b_avg <- mean(b2)
  # plot(b_avg)
  
  
  #### get the australian monitoring data ####
  dat <- fread(infile_annav_who)
  str(dat)
  # max(dat$date)
  dat2 <- dat[year == 2019]
  dat2

  spd <- dat2[,.N, by = .(city, country_name,     longitude,      latitude)]
  setDF(spd)
  sf_object <- st_as_sf(spd, coords = c("longitude", "latitude"), crs = 4326)
  st_write(sf_object, "figures_and_tables/qc_map_who.gpkg", append = F)
  # 
  ##  the 2019 lat,lons are wrong, 2016 and 2010-15 differ
  # dat2.1 <- dat[year == 2016]
  # spd2.1 <- dat2.1[,.N, by = .(city, country_name,    longitude,      latitude)]
  # sf_object2.1 <- st_as_sf(spd2.1, coords = c("longitude", "latitude"), crs = 4326)
  # st_write(sf_object2.1, "figures_and_tables/qc_map_who_2016.gpkg", append = F)
  # # 
  # dat2.2 <- dat[year == 2015]
  # spd2.2 <- dat2.2[,.N, by = .(city,     longitude,      latitude)]
  # sf_object2.2 <- st_as_sf(spd2.2, coords = c("longitude", "latitude"), crs = 4326)
  # st_write(sf_object2.2, "figures_and_tables/qc_map_who_2015.gpkg")
  
  # GO WITH 2019
  
  sf_object <- st_read("figures_and_tables/qc_map_who.gpkg")
  
  #### check ####
  st_bbox(sf_object)
  plot(b_avg)#, xlim = c(114, 154), ylim = c(-38, -12))
  plot(st_geometry(sf_object), add = T)
  
  ### get data out of ctm ####
  extracted_data <- terra::extract(b_avg, sf_object)
  outdat <- cbind(sf_object, extracted_data)
  names(outdat)
  setDT(outdat)
  # class(outdat)
  # outdat$geometry <- NULL
  # outdat2 <- melt(outdat, id.vars = c("station", "state", "station_id", "N"))
  # 
  #### compare to obs ####
  dat2
  # outdat2$date <- as.Date(gsub("\\.", "-", gsub("X","",outdat2$variable)))
  merged_data <- merge(dat2, outdat, by = c("city", "country_name"))
  
  
  with(merged_data, plot(pm25_concentration , extracted_data, xlim = c(0,120), ylim = c(0,120)))
  abline(0,1)  
  fit <- lm(extracted_data ~ pm25_concentration, data = merged_data)
  abline(fit, col = 'red')  
  summary(fit)
  
  with(merged_data[country_name == 'Malaysia'], plot(pm25_concentration , extracted_data, xlim = c(0,30), ylim = c(0,30)))
  abline(0,1)  
  fit2 <- lm(extracted_data ~ pm25_concentration, data = merged_data[country_name == 'Malaysia'])
  abline(fit2, col = 'red')  
  summary(fit2)
  
  # with(merged_data[country_name == 'Australia'], points(pm25_concentration , extracted_data, pch = 16))
}
