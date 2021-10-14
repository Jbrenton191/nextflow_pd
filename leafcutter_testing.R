library(tidyverse)

# leafcutter_dir<-"~/nextflow_pd/output/leafcutter/"


# sample_names <- data.table::fread(
#   str_c(leafcutter_dir, "leafcutter_perind_numers.counts.gz")
# ) %>% 
#   dplyr::select(-V1) %>% 
#   colnames()

# need to find a way to make sure group column heading isn't hard coded! / need to use optoparse

leafcutter_dir<-"/home/jbrenton/test_run/leafcutter/intron_clustering"

sample_names <- data.table::fread(
  file.path(leafcutter_dir, "testrun_perind_numers.counts.gz") ) %>% dplyr::select(-V1) %>% 
  colnames()

base_dir="/home/jbrenton/nextflow_pd"
# base_dir=here::here()
metadata_cols<-read.table(file = str_c(base_dir, "metadata_cols_selected.txt", sep = "/"), header = T,
              sep = " ")

# metadata_cols<-read.table(file = metadata_cols_path, header = T, sep = " ")

samples<-metadata_cols[,1]

y<-sapply(samples, sample_names, FUN = grep)

samp_names<-unique(names(unlist(y)))
order<-unique(unlist(y))

metadata<-unique(metadata_cols[which(metadata_cols[,1] %in% samp_names),])

# metadata$order<-order
metadata$lc_names<-sample_names[order]

metadata_refined<-metadata %>% relocate(lc_names, Disease_Group)
metadata_refined<-select(metadata_refined, -c(CaseNo))

RNAseqProcessing::create_group_files_multi_pairwisecomp(df = metadata_refined, 
group_column_name = "Disease_Group", output_path = leafcutter_dir)

#--------------------------- Leafcutter DS

# Rscript /home/rreynolds/packages/RNAseqProcessing/analysis/leafcutter_ds_multi_pairwise.R \
# /home/rreynolds/projects/Aim2_PDsequencing_wd/results/leafcutter/intron_clustering/tissue_polyA_test_diseasegroups_perind_numers.counts.gz \
# /home/rreynolds/projects/Aim2_PDsequencing_wd/results/leafcutter/diff_splicing_PCaxes/group_files/ \
# --output_prefix=/home/rreynolds/projects/Aim2_PDsequencing_wd/results/leafcutter/diff_splicing_PCaxes/ \
# --max_cluster_size=Inf \
# --min_samples_per_intron=5 \
# --min_samples_per_group=3 \
# --min_coverage=20 \
# --timeout=30 \
# --num_threads=15 \
# --exon_file=/data/references/ensembl/gtf_gff3/v97/leafcutter/Homo_sapiens.GRCh38.97_LC_exon_file.txt.gz




# Comment in if want to test run script arguments
arguments <- list()
arguments$args[1] <- "/home/jbrenton/test_run/leafcutter/intron_clustering/testrun_perind_numers.counts.gz"
arguments$args[2] <- "/home/jbrenton/test_run/leafcutter/intron_clustering"
arguments$opt$output_prefix <- ""
arguments$opt$max_cluster_size <- "Inf"
arguments$opt$min_samples_per_intron  <- "5"
arguments$opt$min_samples_per_group  <- "3"
arguments$opt$min_coverage <- "20"
arguments$opt$timeout <- "30"
# arguments$opt$num_threads <- "15"
arguments$opt$exon_file <-"/home/jbrenton/nextflow_pd/output/leafcutter/gencode_LC_exon_file.txt.gz"

opt <- arguments$opt

count_file <- arguments$args[1]
groups_file_dir <- arguments$args[2]

group_file_df <- tibble(group_file_path = list.files(path = groups_file_dir, pattern = "_group_file.txt", full.names = T),
                        group_file_name = list.files(path = groups_file_dir, pattern = "_group_file.txt", full.names = T) %>%
                          str_replace("/.*/", "") %>%
                          str_replace("_group_file.txt", ""))

for(i in 1:nrow(group_file_df)){
  
  print(str_c("Performing leafcutter differential splicing using the group file entitled: ", group_file_df$group_file_name[i]))
  
  leafcutter_cmd <- str_c("Rscript /home/jbrenton/nextflow_pd/leafcutter_ds.R ",
                          count_file, " ", # path to count file
                          group_file_df$group_file_path[i], # path to group file
                          " --output_prefix ", group_file_df$group_file_name[i], # comparison-specific output prefix
                          " --max_cluster_size ", opt$max_cluster_size,
                          " --min_samples_per_intron ", opt$min_samples_per_intron,
                          " --min_samples_per_group ", opt$min_samples_per_group,
                          " --min_coverage ", opt$min_coverage,
                          " --timeout ", opt$timeout,
                          # " --num_threads ", opt$num_threads,
                          " --exon_file ", opt$exon_file
  )
  
  system(command = leafcutter_cmd)
  
}


# need to find a way to make sure group column heading isn't hard coded!

