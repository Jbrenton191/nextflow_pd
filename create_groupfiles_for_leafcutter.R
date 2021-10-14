library(optparse)
library(tidyverse)

arguments <- parse_args(OptionParser(), positional_arguments = 3)

count_file<-arguments$args[1]
metadata_cols_path<-arguments$args[2]
out_dir<-arguments$args[3]


# leafcutter_dir<-"/home/jbrenton/nextflow_pd/output/leafcutter/intron_clustering"

# sample_names <- data.table::fread(
#   file.path(leafcutter_dir, "testrun_perind_numers.counts.gz") ) %>% dplyr::select(-V1) %>%
#   colnames()

cf_sample_names <- data.table::fread(
  file.path(count_file) ) %>% dplyr::select(-V1) %>%
  colnames()


# base_dir=here::here()
# metadata_cols<-read.table(file = str_c(base_dir, "metadata_cols_selected.txt", sep = "/"), header = T,
#                           sep = " ")



metadata_cols<-read.table(file = metadata_cols_path, header = T, sep = " ")

Sample_col_header<-names(metadata_cols)[1]
Group_col_header<-names(metadata_cols)[2]

md_samples<-metadata_cols[,1]

searched_md_samps<-sapply(md_samples, cf_sample_names, FUN = grep)

samp_names_key<-unique(names(unlist(searched_md_samps)))
order<-unique(unlist(searched_md_samps))

metadata<-unique(metadata_cols[which(metadata_cols[,1] %in% samp_names_key),])

# metadata$order<-order
metadata$lc_names<-cf_sample_names[order]

metadata_refined<-metadata %>% relocate(lc_names, Group_col_header)
metadata_refined<-select(metadata_refined, -c(Sample_col_header))

RNAseqProcessing::create_group_files_multi_pairwisecomp(df = metadata_refined, 
                                                        group_column_name = Group_col_header, output_path = out_dir)
