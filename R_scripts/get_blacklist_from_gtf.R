library(tidyverse)
library(optparse)
library(Biostrings)
library(GenomicRanges)
library(GenomicFeatures)

arguments <- parse_args(OptionParser(), positional_arguments = 1)
gtf_file<-arguments$args[1]

path_to_ENCODE_blacklist<-"/home/jbrenton/nextflow_pd/hg38-blacklist.v2.bed.gz"

B_list_granges<-rtracklayer::import(path_to_ENCODE_blacklist)

# gtf_file<-"/home/jbrenton/output/reference_downloads/gencode.v38.chr_patch_hapl_scaff.annotation.gtf"

gencode_txdb<-makeTxDbFromGFF(gtf_file, format="gtf", organism = "Homo sapiens")

gtf_genes<-genes(gencode_txdb)

overlaps <- findOverlaps(query = B_list_granges, subject = gtf_genes)

co_ord<-subjectHits(overlaps)

blist_genes<-gtf_genes$gene_id[co_ord]

blist_genes_no_vers<-gsub("^(ENSG.*)\\..*$", "\\1", blist_genes)

blist_genes_no_vers<-unique(blist_genes_no_vers)

write_csv(x = blist_genes_no_vers, file =blist_genes_no_vers, col_names = F)
