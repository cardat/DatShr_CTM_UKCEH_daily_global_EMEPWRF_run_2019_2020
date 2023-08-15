library(targets)

sapply(dir("R", pattern = ".R$", full.names = T), source)

datadir <- "~/cloudstor/Shared/CTM_UKCEH_daily_global_EMEPWRF_run_2019_2020/data_provided"

tar_option_set(
  packages = c("targets",
               "ncdf4",
               "sf",
               "data.table",
               "terra",
               "raster",
               "exactextractr",
               "lubridate"),
  error = "continue"
)

list(tar_target(dat_yy,
                load_nc(
                  infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
                  )
                )
     ,
     tar_target(dat_aggrgt_grid,
                do_aggrgt_grid(
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
                )
     )
     ,
     tar_target(dat_aggrgt_grid_dust,
                do_aggrgt_grid(
                  varlist=dat_yy
                  ,
                  infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
                  ,
                  study_period = list(mindate="2019-01-01", maxdate ="2019-12-31")
                  ,
                  var_i = "SURF_ug_DUST"
                  ,
                  do_save_tiffs = TRUE
                  ,
                  filename = "data_derived/DUST_ug_PM25_2019_annual_average.tif"
                )
     )
)
