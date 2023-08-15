library(targets)
tar_visnetwork(targets_only = T)

if(!dir.exists("data_derived"))dir.create("data_derived")

tar_make()



