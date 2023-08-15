library(targets)
tar_visnetwork(targets_only = T)

dir.create("data_derived")

tar_make()



