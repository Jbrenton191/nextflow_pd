library(tidyverse)
library(optparse)
# x<-read_xlsx(path = "nextflow_pd/20201229_MasterFile_SampleInfo.xlsx" , sheet = 2, skip=1)
# write_csv(path = "nextflow_pd/20201229_MasterFile_SampleInfo.csv", x=x)

#1 is csv file #2 is key; both should be values
arguments <- parse_args(OptionParser(), positional_arguments = 2)
metadata_file<-arguments$args[1]
metadata_key<-arguments$args[2]

# meta_df<-read_csv(file = "20201229_MasterFile_SampleInfo.csv", col_names = T)
meta_df<-read_csv(file = metadata_file, col_names = T)

# name_df<-as.vector(read.table(file = "key_for_metadata.txt", sep = ",", header = F))
name_df<-as.vector(read.table(file = metadata_key, sep = ",", header = F))

name_vec<-as.vector(unlist(name_df))

key<-which(names(meta_df) %in% name_vec)

selected_metadata<-meta_df[,key]

write.table(file = "metadata_cols_selected.txt", x = selected_metadata, row.names = F)
