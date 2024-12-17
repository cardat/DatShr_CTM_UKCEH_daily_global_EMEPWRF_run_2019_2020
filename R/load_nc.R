# infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")

load_nc <- function(infile){
  r_nc <- ncdf4::nc_open(infile)
  # sink("working_ivan/netcdf_metadtata.txt")
  # print(r_nc)
  # sink()
  varlist <- names(r_nc[['var']])

  return(varlist)
}