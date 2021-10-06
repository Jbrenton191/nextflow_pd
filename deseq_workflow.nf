nextflow.enable.dsl=2

   params.data="${projectDir}/../Regina_file_deposit/*R{1,3}*.fastq.gz"
   params.salmon_dir = "${projectDir}/output/Salmon/"
   params.metadata_csv= "${projectDir}/20201229_MasterFile_SampleInfo.csv"
   params.metadata_key= "${projectDir}/key_for_metadata.txt"


include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download'
include { fastp } from './modules/fastp'

include { decoy_gen } from './modules/salmon_decoy_gen'
include { salmon_index_gen as salmon_index } from './modules/salmon_index'
include { salmon as salmon_quantification } from './modules/salmon_quantification'

include { gencode_genemap as create_gene_map } from './modules/create_gencode_gene_map.nf'
include { select_metadata_cols } from './modules/select_metadata_cols.nf'
include { DESeq } from './modules/DESeq.nf'

workflow {

data=Channel.fromFilePairs("${params.data}")
get_packages()
genome_download()
create_gene_map(genome_download.out.transcripts)

fastp(data)

decoy_gen(genome_download.out.fasta, genome_download.out.transcripts)
salmon_index(decoy_gen.out.gentrome, decoy_gen.out.decoys)
salmon_quantification(salmon_index.out.whole_index.collect(), fastp.out.reads)

select_metadata_cols(params.metadata_csv, params.metadata_key)


DESeq(salmon_quantification.out.quant_dirs.collect(), select_metadata_cols.out.metadata_selected_cols, create_gene_map.out.gene_map)

}
