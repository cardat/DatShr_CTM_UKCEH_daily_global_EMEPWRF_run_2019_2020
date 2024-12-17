library(targets)

if(!dir.exists("data_derived"))dir.create("data_derived")

source('config.R')
sapply(dir("R", pattern = ".R$", full.names = T), source)
load_packages()

tar_visnetwork(targets_only = T)

tar_make()



