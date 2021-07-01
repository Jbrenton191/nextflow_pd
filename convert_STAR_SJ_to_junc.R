library(optparse)
library(tidyverse)

arguments <- parse_args(OptionParser(), positional_arguments = 3)

sj_dir_paths <- arguments$args[1] %>% str_split(",") %>% unlist()
base_dir<- arguments$args[2]
output_path <- arguments$args[3]

RNAseqProcessing::convert_STAR_SJ_to_junc(sj_dir_path, base_dir, 
filter_out_blacklist_regions=TRUE, path_to_ENCODE_blacklist = base_dir)

junc_df <- tibble(junc_file_name = list.files(path = output_path,
                                              pattern = "_SJ_leafcutter.junc", full.names = TRUE))
 
write_delim(junc_df,
             path = str_c(output_path, "/list_juncfiles.txt"),
             delim = "\t", col_names = F)