do_qc_nofire_vs_aus_v1_3 <- function(
  infile_pm_total = "data_derived/SURF_ug_PM25_2019_annual_average.tif"
  ,
  infile_pm_nofire = "data_derived/SURF_ug_PM25_2019_annual_average_NOFIRE.tif"
  ,
  infile_aus_v1_3 = "C:/Users/287658c/Nextcloud/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived/bushfiresmoke_v1_3_2019_compressed_20231130_7.nc"
){
  #### load the aus data ####
  
  ## retrieve the following layers into a list
  lyrs <- c("remainder", "trend", "seasonal")
  big_list <- lapply(lyrs, function(x){
    terra::rast(infile_aus_v1_3, x)
  }) 
  names(big_list) <- lyrs
  big_list
  
  ## make a plot for selected day
  # From left to right, top to bottom: seasonal, trend, remainder, full PM2.5.
  
  # get single day of rasters
  sel_date <- "2019-12-10"
  r1 <- big_list[["seasonal"]][[time(big_list[["seasonal"]]) == as.Date(sel_date)]]
  r2 <- big_list[["trend"]][[time(big_list[["trend"]]) == as.Date(sel_date)]]
  r3 <- big_list[["remainder"]][[time(big_list[["remainder"]]) == as.Date(sel_date)]]
  # plot
  par(mfrow = c(2,2))
  plot(r1); title(paste(sel_date, "seasonal bit"))
  plot(r2); title(paste(sel_date, "trend bit"))
  plot(r3); title(paste(sel_date, "remainder bit"))
  plot(r1+r2+r3); title(paste(sel_date, "total PM2.5 bit"))
}