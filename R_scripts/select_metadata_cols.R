library(tidyverse)
library(optparse)
# x<-read_xlsx(path = "nextflow_pd/20201229_MasterFile_SampleInfo.xlsx" , sheet = 2, skip=1)
# write_csv(path = "nextflow_pd/20201229_MasterFile_SampleInfo.csv", x=x)

#1 is csv file #2 is key; both should be values
arguments <- parse_args(OptionParser(), positional_arguments = 2)
metadata_file<-arguments$args[1]
metadata_key<-arguments$args[2]

# meta_df<-read_csv(file = "ASAP_samples_master_spreadsheet_25.8.21.csv", col_names = T)
meta_df<-read_csv(file = metadata_file, col_names = T)

# name_df<-read.table(file = "key_for_metadata.txt", sep = ",", header = F)
name_df<-read.table(file = metadata_key, sep = ",", header = F)

name_vec<-as.vector(unlist(name_df))

key<-c()

for(i in 1:length(name_vec)){
key[i]<-which(names(meta_df) %in% name_vec[i])
}
selected_metadata<-meta_df[,key]

write.table(file = "metadata_cols_selected.txt", x = selected_metadata, row.names = F)
