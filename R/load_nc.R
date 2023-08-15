load_nc <- function(infile){
  r_nc <- ncdf4::nc_open(infile)
  # sink("working_ivan/netcdf_metadtata.txt")
  # print(r_nc)
  # sink()
  varlist <- names(r_nc[['var']])
  # excclude lon, lat 
  varlist <- varlist[3:length(varlist)]
  ##varlist <- c("dust_merra_2_p50", "remainder","seasonal","season_plus_trend", "smoke_p95","whs_12degreec")
  return(varlist)
}