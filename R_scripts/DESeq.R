library(tidyverse)
library(optparse)
library(Biostrings)
library(DESeq2)
library(tximport)

# Also need to add the deseq parts

# To do/plan:
# 1. Need a csv file for metadata
# 2. Need a grouping/cofactors text file to match and extract group names and other metadata
#    order of this text file needs to be sample name, groups, then all other cofactors or covariates
# 3. use this to grep names of sample and assign groups and other cofactors a tibble/dataframe with
#    the name of either salmon folders or leafcutter ready files perind_num etc in the dataframe too
# 4. Then can use this new dataframe to perform DESeq (equation can be extracted from 
#     colnames and mixed with + symbols) or leafcutter analyses
# 5. Any new cofactors can be added to text file names and dataframe and tibble

# Potential problems:
# 1. Can this work with non-categorical/numerical variables such as cell type normalisation coming from Scaden
# 2. Will the equation idea/concatentating of colnames work for DESeq and Leafcutter?


arguments <- parse_args(OptionParser(), positional_arguments = 4)

salmon_dir_path<-arguments$args[1]
metadata_cols_path<-arguments$args[2]
gene_map_path<-arguments$args[3]
blacklist_genes<-arguments$args[4]
  
  
# base_dir<-"/home/jbrenton/nextflow_pd"
# setwd(str_c(base_dir, "output/Salmon", sep = "/"))
# setwd(salmon_dir_path)
# dir<-getwd()
# files<-list.files(dir, recursive = TRUE)
files<-list.dirs(salmon_dir_path, recursive = F)
no_take_index<-"salmon_index"

# Find folders that aren't the index - This will cause process to fail 
# if there are other folders or directories in the output/Salmon folder
files<-files[-grep(no_take_index, files)]
# files<-files[grep("quant.sf", files)]
# filenames<-sub("^.*/(.*)$", "\\1", files)

# names(files)<-filenames
all(file.exists(files))

# metadata_cols<-read.table(file = str_c(base_dir, "metadata_cols_selected.txt", sep = "/"), header = T,
#               sep = " ")

metadata_cols<-read.table(file = metadata_cols_path, header = T, sep = " ")

samples<-metadata_cols[,1]

y<-sapply(samples, files, FUN = grep)

samp_names<-unique(names(unlist(y)))
order<-unique(unlist(y))

metadata<-unique(metadata_cols[which(metadata_cols[,1] %in% samp_names),])

metadata$order<-order
samples_with_NAs<-metadata[rowSums(is.na(metadata)) > 0, ]
cat("These samples contain NAs in their  metadata columns (they will be removed - update them or ): ", samples_with_NAs[,1])
write_csv(x = samples_with_NAs, col_names = T,
          file = "samples_removed_from_DESeq_comparisons_because_of_NAs.csv")

metadata<-metadata[!rowSums(is.na(metadata)) > 0, ]
# metadata<-na.omit(metadata)
# These are in the order of the original metatdata csv file not the quant files 
# in the output folder
write_csv(x = metadata, col_names = T,
          file = "samples_groups_and_metadata_in_DESeq_comparisons.csv")

eqn_names<-names(metadata[2:(length(names(metadata))-1)])
deseq_equation<-str_c("~", str_c(eqn_names, collapse  = " + "), sep = " ")

print(paste0("This is the equation used: ", deseq_equation))
########


  # which(!is.na(str_match(string = files[i], pattern = meta_samps_present$CaseNo)))
samples<-file.path(files, "quant.sf")
samples<-samples[metadata$order]
names(samples)<-metadata[,1]


# gene_map_path<-file.path(base_dir, "output/Salmon/gencode_txid_to_geneid.txt")
gencode_txid_to_geneid<-read.delim(file= gene_map_path, sep=" ")

colnames(gencode_txid_to_geneid)<-c("tx_id", "gene_id","gene_name", "description")
gencode_txid_to_geneid$tx_id<-sub("\\..+", "", gencode_txid_to_geneid$tx_id)
gencode_txid_to_geneid$gene_id<-sub("\\..+", "", gencode_txid_to_geneid$gene_id)

txi.salmon <- tximport(samples, type = "salmon", 
                     tx2gene = gencode_txid_to_geneid, ignoreTxVersion=TRUE)


# From old RNAseq stuff  ------------------------------------------------------------------------------


# sampleMetadata <- data.frame(
#    samples = names(samples), metadata[,2] )

 dds <- DESeqDataSetFromTximport(txi.salmon,
                                      colData = metadata,
                                      design = formula(deseq_equation))
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

#remove blacklist genes
dds<-dds[!rownames(counts(dds)) %in% blacklist_genes,]

dds <- DESeq(dds)
res_dds <- results(dds)
res_dds$gene <- row.names(res_dds)
resOrdered <- res_dds[order(res_dds$padj),]
resOrdered$gene <- row.names(resOrdered)
resOrdered <- as.data.frame(resOrdered)


sigGenesOrdered <- subset(resOrdered, padj < 0.05 & 
                                 abs(log2FoldChange) > 1)


write_csv(x = sigGenesOrdered, col_names = T, 
          file = "significant_genes_padj_0.05_and_log2FoldChange_abs1.csv")

