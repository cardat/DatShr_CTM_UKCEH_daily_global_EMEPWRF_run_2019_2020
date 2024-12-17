library(targets)
source('config.R')
sapply(dir("R", pattern = ".R$", full.names = T), source)


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

list(
  #### dat_yy (list the variables) ####
  tar_target(dat_yy,
             load_nc(
               infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
             )
  )
  ,
  #### __ Surface pm2.5 __ ####
  #### qc_daily_aus: check against Aus NAPMD observed pm2.5 totals ####
  # note restriction jan to oct, because of extreme fires
  tar_target(qc_daily_aus,
             do_qc_daily_aus(
               varlist=dat_yy
               ,
               infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
               ,
               study_period = list(mindate="2019-01-01", maxdate ="2019-11-01")
               ,
               var_i = "SURF_ug_PM25"
               ,
               infile_daily_aus = file.path(cloud_car_dat, "Bushfire_Smoke_for_CAR_Project/PM25_and_PM10_daily_averages/data_derived/air_pollution_monitor_pm25_dly_20002020_20211108_imputed.rds")
             )
  )
  ,
  #### qc_annav_who: check against the WHO database's annual averages ####
  tar_target(qc_annav_who,
             do_qc_annav_who(
               varlist=dat_yy
               ,
               infile = file.path(datadir,"EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_BASE_trend2019_emiss2010_GLOBAL_2019_day.nc")
               ,
               study_period = list(mindate="2019-01-01", maxdate ="2019-12-31")
               ,
               var_i = "SURF_ug_PM25"
               ,
               infile_annav_who = "C:/Users/287658c/OneDrive - Curtin/Shared/cardat_uploads_from_ivan/WHO_air_quality_database/WHO_air_quality_database_v6/data_provided/who_ambient_air_quality_database_version_2024_(v6.1).csv"
             )
  )
  ,
  #### dat_aggrgt_grid_pm25: aggregate to annual: pm2.5 ####
  tar_target(dat_aggrgt_grid_pm25,
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
  #### __ NOFIRE run __ ####
  #### dat_aggrgt_grid_pm25_nofire ####
  # the model was run with the fires switched off
  tar_target(dat_aggrgt_grid_pm25_nofire,
             do_aggrgt_grid(
               varlist=dat_yy
               ,
               infile = file.path(datadir, "EMEP4UK_emep-ctm-rv4.36_wrf4.2.2_AUSTRALIA_NOFFIRE_trend2019_emiss2010_GLOBAL_2019_day.nc")
               ,
               study_period = list(mindate="2019-01-01", maxdate ="2019-12-31")
               ,
               var_i = "SURF_ug_PM25"
               ,
               do_save_tiffs = TRUE
               ,
               filename = "data_derived/SURF_ug_PM25_2019_annual_average_NOFIRE.tif"
             )
  )
  ,
  #### qc_nofire_vs_aus_v1_3: QC nofire versus Aust bushfire specific v1.3 ####
  tar_target(qc_nofire_vs_aus_v1_3,
             do_qc_nofire_vs_aus_v1_3(
               infile_pm_total = "data_derived/SURF_ug_PM25_2019_annual_average.tif"
               ,
               infile_pm_nofire = "data_derived/SURF_ug_PM25_2019_annual_average_NOFIRE.tif"
               ,
               infile_aus_v1_3 = "C:/Users/287658c/Nextcloud/Bushfire_specific_PM25_Aus_2001_2020_v1_3/data_derived/bushfiresmoke_v1_3_2019_compressed_20231130_7.nc"
             )
  )
  ,
  #### __ Dust __ ####
  #### dat_aggrgt_grid_dust: aggregate to annual: dust ####
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
