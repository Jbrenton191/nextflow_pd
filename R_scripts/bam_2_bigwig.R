library(megadepth)
library(tidyverse)
library(optparse)

# arguments <- parse_args(OptionParser(), positional_arguments = 1)
# 
# bam_files<-arguments$args[1]
# metadata_cols_path<-arguments$args[2]

metadata_cols_path<-"/home/jbrenton/nextflow_pd/metadata_cols_selected.txt"
bams<-list.files(path = '/home/jbrenton/bam_dir', pattern = ".bam", full.names = T)

# quick getting sample names extension free
metadata_cols<-read.table(file = metadata_cols_path, header = T, sep = " ")

md_samples<-metadata_cols[,1]

searched_md_samps<-sapply(md_samples, bams, FUN = grep)

samp_names_key<-unique(names(unlist(searched_md_samps)))
order<-unique(unlist(searched_md_samps))

bam_df<-unique(metadata_cols[which(metadata_cols[,1] %in% samp_names_key),])

bam_df$names<-bams[order]

bam_df$bam_samples<-bams[order]
bam_df<-bam_df %>% relocate(bam_samples, everything())

## 
# for (i in length(bam_df$bam_samples)) {
for (i in c(1:5)) {
megadepth::bam_to_bigwig(bam_file = bam_df$bam_samples[i], 
                         prefix = bam_df$CaseNo[i], overwrite=TRUE)
}
