library(optparse)
library(tidyverse)

arguments <- parse_args(OptionParser(), positional_arguments = 3)

sj_dir_path <- arguments$args[1] %>% str_split(",") %>% unlist()
base_dir<- arguments$args[2]
output_path <- arguments$args[3]

# sj_dir_path <- "/home/jbrenton/nextflow_test/output/STAR/align"
# base_dir<- "/home/jbrenton/nextflow_test"
# output_path <- "/home/jbrenton/nextflow_test/output/leafcutter"


RNAseqProcessing::convert_STAR_SJ_to_junc(sj_dir_path, output_path, filter_out_blacklist_regions=F, path_to_ENCODE_blacklist = base_dir)

junc_df <- tibble(junc_file_name = list.files(path = output_path,
                                              pattern = "_SJ_leafcutter.junc", full.names = TRUE))
 
write_delim(junc_df,
             path = str_c(".", "/list_juncfiles.txt"),
             delim = "\t", col_names = F)
