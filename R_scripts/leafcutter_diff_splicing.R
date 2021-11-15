library(optparse)
library(tidyverse)
library(leafcutter)

arguments <- parse_args(OptionParser(), positional_arguments = 4)

# arguments <- list()
# arguments$args[1] <- "/home/jbrenton/test_run/leafcutter/intron_clustering/testrun_perind_numers.counts.gz"
# arguments$args[2] <- "/home/jbrenton/test_run/leafcutter/intron_clustering"

count_file <- arguments$args[1]
groups_file_dir <- arguments$args[2]
exon_file<-arguments$args[3]
base_dir<-arguments$args[4]

arguments$opt$output_prefix <- ""
arguments$opt$max_cluster_size <- "Inf"
arguments$opt$min_samples_per_intron  <- "5"
arguments$opt$min_samples_per_group  <- "3"
arguments$opt$min_samples_per_intron  <- "3"
arguments$opt$min_samples_per_group  <- "3"
arguments$opt$min_coverage <- "20"
arguments$opt$timeout <- "30"

# arguments$opt$num_threads <- "15"
# arguments$args[3]<-"/home/jbrenton/nextflow_pd/output/leafcutter/gencode_LC_exon_file.txt.gz"

opt <- arguments$opt

# print(arguments$args)
# cat("this is gp dir:", groups_file_dir, sep = " ")

group_file_path<-list.files(path = groups_file_dir, pattern = "_group_file.txt", full.names = T)
group_file_name<-list.files(path = groups_file_dir, pattern = "_group_file.txt", full.names = T) %>%
  str_replace("/.*/", "") %>%
  str_replace("_group_file.txt", "")
# 
# 
group_file_df <- data_frame(group_file_path = group_file_path,
                        group_file_name = group_file_name)
# 
# print(group_file_df)
for(i in 1:nrow(group_file_df)){

  print(str_c("Performing leafcutter differential splicing using the group file entitled: ", group_file_df$group_file_name[i]))

leafcutter_cmd <- str_c("Rscript ", base_dir, "/leafcutter_ds.R ",
                        count_file, " ", # path to count file
                        group_file_df$group_file_path[i], # path to group file
                        " --output_prefix ", group_file_df$group_file_name[i], # comparison-specific output prefix
                        " --max_cluster_size ", opt$max_cluster_size,
                        " --min_samples_per_intron ", opt$min_samples_per_intron,
                        " --min_samples_per_group ", opt$min_samples_per_group,
                        " --min_coverage ", opt$min_coverage,
                        " --timeout ", opt$timeout,
                        " --exon_file ", exon_file
)

  system(command = leafcutter_cmd)

}
