library(tidyverse)
library(readxl)
library(optparse)
library(data.table)

arguments <- parse_args(OptionParser(), positional_arguments = 1)

base_dir<- arguments$args[1]
base_dir<-"/home/jbrenton/nextflow_test"

sample_info <- 
  read_excel(
    path = 
      file.path(
        base_dir,
        "20201229_MasterFile_SampleInfo.xlsx"
      ), 
    sheet = "SampleInfo", skip = 1
  )  %>% 
  dplyr::filter(Sample_Type == "Tissue section" & sent_to_bulk_seq == "yes") %>% 
  dplyr::rename(sample_id = CaseNo, 
                RIN = RINe_bulkRNA_Tapestation) %>% 
  dplyr::mutate(Disease_Group = fct_relevel(Disease_Group,
                                            c("Control", "PD", "PDD","DLB")))

# %>% 
#   dplyr::select(sample_id, Disease_Group, Sex, AoO, AoD, DD, PMI, aSN, TAU, 'thal AB', 'aCG aSN score', Genetics, RIN) %>% 
#   dplyr::inner_join(PCaxes)


#### Making groups

list.files(path = file.path(str_c(base_dir, "/output/leafcutter")), pattern = "*perind_numers.counts.gz")

sample_names <- fread(
  file.path(str_c(base_dir, "/output/leafcutter/leafcutter_perind_numers.counts.gz"))
) %>% 
  dplyr::select(-V1) %>% 
  colnames()

# Create master df of sample info, with grouping variable (Disease_Group) and confounders (RIN, Sex, AoD)
master <- 
  tibble(lc_sample_name = sample_names,
         sample_name = sample_names %>% 
           str_replace("_.*", "")) %>% 
  inner_join(sample_info, by = c("sample_name" = "sample_id")) %>% 
  dplyr::select(lc_sample_name, Disease_Group, RIN, Sex, AoD) %>% 
  arrange(Disease_Group)

RNAseqProcessing::create_group_files_multi_pairwisecomp(df = master, 
                                                        group_column_name = "Disease_Group", 
                                                        output_path = str_c(leafcutter_dir, "diff_splicing/group_files/"))