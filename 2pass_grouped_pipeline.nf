nextflow.enable.dsl=2

   params.data="${baseDir}/../ASAP_bulk_fastqs/*R{1,2}*.fastq.gz"
   params.salmon_dir = "${projectDir}/output/Salmon/"
   params.metadata_csv= "${projectDir}/ASAP_samples_master_spreadsheet_25.8.21.csv"
   params.metadata_key= "${projectDir}/key_for_metadata.txt"

   output_dir = "${baseDir}/output"


include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download'
include { fastp } from './modules/fastp'
include { fastqc } from './modules/fastqc'
include { Star_genome_gen as star_genome_gen } from './modules/Star_genome_gen'
include { STAR_pass1_post_genome_gen as star_1 } from './modules/STAR_pass1_post_genome_gen'
include { Star_merge as star_merge } from './modules/Star_merge'
include { STAR_pass2 as star_2 } from './modules/STAR_pass2'

include { gtf_to_bed } from './modules/gtf_to_bed'
include { sam_sort_index } from './modules/sam_sort_index'
include { rseqc } from './modules/rseqc'

include { decoy_gen } from './modules/salmon_decoy_gen'
include { salmon_index_gen as salmon_index } from './modules/salmon_index'
include { salmon as salmon_quantification } from './modules/salmon_quantification'
include { multiqc_post_star_salmon } from './modules/multiqc_both_aligners'

include { gencode_genemap as create_gene_map } from './modules/create_gencode_gene_map'
include { select_metadata_cols } from './modules/select_metadata_cols'
include { DESeq } from './modules/DESeq'

include { convert_juncs } from './modules/convert_juncs'
include { cluster_juncs } from './modules/cluster_juncs'
include { gtf_to_exons } from './modules/gtf_to_exons'
include { create_groupfiles } from './modules/create_groupfiles_for_leafcutter'
include { leafcutter } from './modules/leafcutter'

workflow {

//data=Channel.fromFilePairs("${params.data}")
 get_packages()
//output_dir=Channel.value("${baseDir}/output")
//fastp(data, get_packages.out.pack_done_val)
 genome_download()

/*
fastqc(fastp.out.reads)
star_genome_gen(genome_download.out.fasta, genome_download.out.gtf)
star_1(fastp.out.reads, star_genome_gen.out.gdir_val)
star_merge(star_1.out.sj_loc, star_1.out.sj_tabs.toList())
star_2(fastp.out.reads, star_merge.out.merged_tab)

// gtf_to_bed(genome_download.out.gtf)
// sam_sort_index(star_2.out.bams)
// rseqc(gtf_to_bed.out.bed_model, sam_sort_index.out.sorted_bams, sam_sort_index.out.bam_dir, sam_sort_index.out.bam_indexes.collect())

*/
data=Channel.fromFilePairs("/data/RNAseq_PD/tissue_polyA_samples/QC/fastp/*R{1,3}*.fastq.gz")
data2=data.take(5)
 decoy_gen(genome_download.out.fasta, genome_download.out.transcripts)
 salmon_index(decoy_gen.out.gentrome, decoy_gen.out.decoys)
 salmon_quantification(salmon_index.out.whole_index.toList(), data2)

/*
multiqc_post_star_salmon(salmon_quantification.out.quant_dirs.collect(), star_2.out.sj_tabs2.collect(), output_dir)


create_gene_map(genome_download.out.transcripts)

select_metadata_cols(params.metadata_csv, params.metadata_key, get_packages.out.pack_done_val)

DESeq(salmon_quantification.out.quant_dirs.collect(), select_metadata_cols.out.metadata_selected_cols, create_gene_map.out.gene_map)

convert_juncs(star_2.out.sj_loc, star_2.out.sj_tabs2.toList())
cluster_juncs(convert_juncs.out.junc_list)
gtf_to_exons(genome_download.out.gtf)

create_groupfiles(cluster_juncs.out.counts_file, select_metadata_cols.out.metadata_selected_cols)
leafcutter(cluster_juncs.out.counts_file, create_groupfiles.out.gf_out, gtf_to_exons.out.exon_file)
*/
}
