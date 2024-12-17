# tar_load(dat_yy)

do_qc_daily_aus <- function(
    varlist=dat_yy
    ,
    infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
    ,
    study_period = list(mindate="2019-01-01", maxdate ="2019-11-01")
    ,
    var_i = "SURF_ug_PM25"
    ,
    infile_daily_aus = file.path(cloud_car_dat, "Bushfire_Smoke_for_CAR_Project/PM25_and_PM10_daily_averages/data_derived/air_pollution_monitor_pm25_dly_20002020_20211108_imputed.rds")
){
  #### get the ctm ####
  b <- raster::brick(infile, varname = var_i)
  ##b
  b2 <- b[[which(getZ(b) >= as.Date(study_period[["mindate"]]) & getZ(b) <= as.Date(study_period[["maxdate"]]))]]
  crs(b2) <- "EPSG:4326"
  
  # plot(b2)
  
  
  #### get the australian monitoring data ####
  dat <- readRDS(infile_daily_aus)
  str(dat)
  # max(dat$date)
  dat$yymm <- paste(dat$Year, dat$Month, sep = "-")
  dat$mm <- dat$Month
  dat$yy <- dat$Year
  dat2 <- na.omit(dat[yy == 2019])
  dat2

  spd <- dat2[,.N, by = .(station, state, station_id,     lon,      lat)]
  setDF(spd)
  sf_object <- st_as_sf(spd, coords = c("lon", "lat"), crs = 4326)
  b2 <- brick(b2)
  
  #### check ####
  st_bbox(sf_object)
  plot(b2[[1]], xlim = c(114, 154), ylim = c(-38, -12))
  plot(st_geometry(sf_object), add = T)
  
  ### get data out of ctm ####
  extracted_data <- terra::extract(b2, sf_object)
  outdat <- cbind(sf_object, extracted_data)
  names(outdat)
  setDT(outdat)
  class(outdat)
  outdat$geometry <- NULL
  outdat2 <- melt(outdat, id.vars = c("station", "state", "station_id", "N"))
  
  #### compare to obs ####
  dat2
  outdat2$date <- as.Date(gsub("\\.", "-", gsub("X","",outdat2$variable)))
  merged_data <- merge(dat2, outdat2, by = c("station", "state", "station_id", "date"))
  
  # Calculate the standard deviation for each group
  valid_groups <- merged_data[, .(sd_value = sd(value, na.rm = TRUE), sd_pm25 = sd(pm25_final, na.rm = TRUE)), by =  c("station", "state", "station_id")]
  
  # Filter out groups with zero standard deviation
  valid_groups <- valid_groups[sd_value > 0 & sd_pm25 > 0]
  
  # Merge back to get the valid data
  valid_data <- merged_data[station_id %in% valid_groups$station_id]
  
  correlations <- valid_data[, .(correlation = cor(value, pm25_final, use = "complete.obs")), by =  c("station", "state", "station_id")]
  tail(correlations[order(correlation),],15)
  # Find the station_id with the strongest correlation
  strongest_correlation <- correlations[which.max(abs(correlation))]
  stn_todo <- 5 #  453 # 4 # 366 #2 # 1 # 364
  with(valid_data[station_id == stn_todo], plot(date, pm25_final, type = 'l', ylim = c(0,150)))
  with(valid_data[station_id == stn_todo], lines(date, value, col = 'green'))
  
  
  with(valid_data, plot(pm25_final, value, ylim = range(valid_data$pm25_final)))
  abline(0,1)  

  # relatively poor at daily scale 
  # try monthly
  qc2 <- valid_data[,.(pm25_model = mean(value, na.rm = T), pm25_obs = mean(pm25_final, na.rm = T), .N), by = c("station", "state", "station_id", "yy", "mm")]
  with(qc2[N > (0.7*30.25)], plot(pm25_obs, pm25_model, ylim = range(qc2[N > (0.7*30.25)]$pm25_obs)))    
  abline(0,1)

  # 10 month average (Jan to Oct)
  qc3 <- valid_data[,.(pm25_model = mean(value, na.rm = T), pm25_obs = mean(pm25_final, na.rm = T), .N), by = c("station", "state", "station_id", "yy")]
  with(qc3[N > (0.7*(10*30.25))], plot(pm25_obs, pm25_model, ylim = c(0,15), xlim = c(0,15) ))    
  abline(0,1)
  
  
  #### next task: look at the WHO database's annual averages ####
  
  
  
}
