library(tidyverse)
library(optparse)
library(Biostrings)

arguments <- parse_args(OptionParser(), positional_arguments = 1)
gencode_fasta_file<-arguments$args[1]

# base_dir<-"/home/jbrenton/nextflow_pd"
# gencode_fasta_file<-file.path(base_dir, 
# "/output/reference_downloads/gencode.v38.transcripts.fa")
# # gencode_fasta_file<-file.path(base_dir, "output/Salmon/gentrome.fa")

gencode_fasta = readDNAStringSet(gencode_fasta_file)

writeLines("####### reading transcriptome FASTA")

genes_gencode<- names(gencode_fasta)

parseGencode<-function(genestring){
  
  identifier<-sub("^(ENST.+)\\|.+\\|.+\\|.+\\|.+\\|(.+)\\|.+\\|(.+)\\|$", "\\1", genestring)
  geneName<-sub("^(ENST.+)\\|.+\\|.+\\|.+\\|.+\\|(.+)\\|.+\\|(.+)\\|$", "\\2", genestring)
  description<-sub("^(ENST.+)\\|.+\\|.+\\|.+\\|.+\\|(.+)\\|.+\\|(.+)\\|$", "\\3", genestring)
  
  return(c(identifier, geneName, description))
}
######apply the function to the gencode information to extract the terms above

extracted_gencode<-do.call("rbind", lapply(genes_gencode,parseGencode))

colnames(extracted_gencode)<-c("Transcript_ID", "Gene_Name", "Description")

extracted_gencode<-as.data.frame(extracted_gencode)

write.table(x=extracted_gencode, file="gencode_txid_to_geneid.txt", sep = " ", col.names = T, row.names = F)
