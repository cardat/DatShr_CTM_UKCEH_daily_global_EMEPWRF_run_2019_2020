do_qc_nofire_vs_aus_v1_3 <- function(
    infile_pm_total = "data_derived/SURF_ug_PM25_2019_annual_average.tif"
    ,
    infile_pm_nofire = "data_derived/SURF_ug_PM25_2019_annual_average_NOFIRE.tif"
    ,
    infile_aus_v1_3 = "C:/Users/287658c/Nextcloud/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived/bushfiresmoke_v1_3_2019_compressed_20231130_7.nc"
){
  #### load the aus data ####
  nc <- ncdf4::nc_open(infile_aus_v1_3)
  names(nc$var)
  nc_close(nc)
  
  ## retrieve the following layers into a list
  lyrs <- c("pm25_pred","remainder", "trend", "seasonal")
  big_list <- lapply(lyrs, function(x){
    inraster <- terra::rast(infile_aus_v1_3, x)
    raster_reprojected <- project(inraster, "EPSG:4326")
    return(raster_reprojected)
  }) 
  names(big_list) <- lyrs
  # big_list
  # plot(big_list[[1]][[1]])
  
  #### create NOFIRE ####
  # (each day has the trend + seasonal summed)
  nofire <- big_list[["trend"]] + big_list[["seasonal"]] 
  
  # 
  # par(mfrow =c(2,2))
  # for(i in 1:2){
  #   plot(nofire[[i]], range = c(0, 80))
  #   plot(big_list[["pm25_pred"]][[i]], range = c(0, 80))
  # }
  
  big_list2 <- list(nofire, big_list[["pm25_pred"]])
  
  # get annual average of baseline (nofire) and total pm2.5 (withfire)
  big_list_annav <- lapply(1:2, function(x){
    annav <- mean(big_list2[[x]])
    return(annav)
  })
  names(big_list_annav) <- c("nofire", "pm25_pred")
  
  ## make a plot 
  par(mfrow = c(1,2))
  plot(big_list_annav[[2]], col = terrain.colors(100),range = c(0,25)); title("2019 PM2.5 total")
  plot(big_list_annav[[1]], col = terrain.colors(100),range = c(0,25)); title("2019 PM2.5 no fire")
  
  #### load the ctm ####
  ctm_total <- rast(infile_pm_total)
  plot(ctm_total, col = terrain.colors(100),range = c(0,25));
  ctm_nofire <- rast(infile_pm_nofire)
  plot(ctm_nofire, col = terrain.colors(100),range = c(0,25));
  
  diff <- ctm_total - ctm_nofire
  
  plot(diff, ext = ext(big_list_annav[[2]]), col = terrain.colors(100))
  
  
  par(mfrow = c(2,3))
  plot(big_list_annav[[2]], col = terrain.colors(100),range = c(0,25)); title("2019 PM2.5 total")
  plot(big_list_annav[[1]], col = terrain.colors(100),range = c(0,25)); title("2019 PM2.5 no fire")
  plot(big_list_annav[[2]] - big_list_annav[[1]], range = c(0,10)); title("2019 PM2.5 difference")
  
  # NEED THE BOUNDARY
  aus <- st_read("C:/Users/287658c/Nextcloud/Environment_General/Water_bodies_GA/Australian_maritime_boundaries_2014/data_provided/ocean_20210519.shp")
  plot(ctm_total, ext = ext(big_list_annav[[2]]), col = terrain.colors(100),range = c(0,25)); title("CTM 2019 PM2.5 total")
  plot(st_geometry(aus), add = T)
  plot(ctm_nofire, ext = ext(big_list_annav[[2]]), col = terrain.colors(100),range = c(0,25)); title("CTM 2019 PM2.5 no fire")
  plot(st_geometry(aus), add = T)
  plot(diff, ext = ext(big_list_annav[[2]]))
  plot(st_geometry(aus), add = T)
  
}