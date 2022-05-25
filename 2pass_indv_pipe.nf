nextflow.enable.dsl=2

//  change below:
//	params.data="${projectDir}/../R1_001/*R{1,2}*.fastq.gz"
//   params.data="${projectDir}/../../Regina_raw_fastqs/*R{1,3}*.fastq.gz"
//   params.salmon_dir = "${projectDir}/output/Salmon/"
//     params.data="${projectDir}/../ASAP_bulk_fastqs/*R{1,2}*.fastq.gz"  
     params.data="${projectDir}/Star_2_pass_by_indv/output/fastp/*{1,2}*.fastq.gz"  


     params.metadata_csv= "${projectDir}/ASAP_samples_master_spreadsheet_25.8.21.csv"
     params.metadata_key= "${projectDir}/key_for_metadata.txt"

     // output_dir = "${projectDir}/output"
     params.output= "${projectDir}/output_2pass_indv"

include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download'
include { fastp } from './modules/fastp'
include { fastqc; fastqc as fastqc2 } from './modules/fastqc'
include { Star_genome_gen as star_genome_gen } from './modules/Star_genome_gen'
include { STAR_2pass_indv as star } from './modules/STAR_2pass_indv'

include { gtf_to_bed } from './modules/gtf_to_bed'
include { sam_sort_index } from './modules/sam_sort_index'
include { rseqc } from './modules/rseqc'
include { rseqc_read_distribution } from './modules/rseqc_read_distribution'

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

include { rseqc_bam_stat } from './modules/rseqc_bam_stat'
include { rseqc_clipping_profile } from './modules/rseqc_clipping_profile'
include { rseqc_inner_distance } from './modules/rseqc_inner_distance'
include { rseqc_junction_annotation } from './modules/rseqc_junction_annotation'
include { rseqc_mismatch_profile } from './modules/rseqc_mismatch_profile'
include { rseqc_read_duplication } from './modules/rseqc_read_duplication'
include { rseqc_read_GC } from './modules/rseqc_read_GC'
include { rseqc_RNA_fragment_size } from './modules/rseqc_RNA_fragment_size'

workflow {

// data=Channel.fromFilePairs("${params.data}")

data=Channel.fromFilePairs("${params.data}")
data=data.take(6)
data.view()

get_packages()
// fastqc(data)
/*
output_dir=Channel.value("${baseDir}/output")
fastp(data, get_packages.out.pack_done_val)
*/
genome_download()
// fastqc2(fastp.out.reads)
star_genome_gen(genome_download.out.fasta, genome_download.out.gtf)
// star(fastp.out.reads, star_genome_gen.out.gdir_val)
star(data, star_genome_gen.out.gdir)

gtf_to_bed(genome_download.out.gtf)
sam_sort_index(star.out.bams)
rseqc_read_distribution(sam_sort_index.out.sorted_bams, gtf_to_bed.out.bed_model)

decoy_gen(genome_download.out.fasta, genome_download.out.transcripts)
salmon_index(decoy_gen.out.gentrome, decoy_gen.out.decoys)
// salmon_quantification(salmon_index.out.whole_index.collect(), fastp.out.reads)
salmon_quantification(salmon_index.out.whole_index.collect(), data)

multiqc_post_star_salmon(salmon_quantification.out.quant_dirs.collect(), star.out.sj_tabs.collect(), params.output)

create_gene_map(genome_download.out.transcripts)

select_metadata_cols(params.metadata_csv, params.metadata_key, get_packages.out.pack_done_val)

DESeq(salmon_quantification.out.quant_dirs.collect(), select_metadata_cols.out.metadata_selected_cols, create_gene_map.out.gene_map)

sj_loc="${params.output}/STAR/align"
convert_juncs(sj_loc, star.out.sj_tabs.collect())
// convert_juncs(star.out.sj_loc.collect().first(), star.out.sj_tabs.collect())

cluster_juncs(convert_juncs.out.junc_list)

gtf_to_exons(genome_download.out.gtf)

create_groupfiles(cluster_juncs.out.counts_file, select_metadata_cols.out.metadata_selected_cols)

leafcutter(cluster_juncs.out.counts_file, create_groupfiles.out.gf_out, gtf_to_exons.out.exon_file)
/*
rseqc_bam_stat(bams)
rseqc_clipping_profile(bams
rseqc_inner_distance(bams, bed_model)
rseqc_junction_annotation(bams, bed_model)
rseqc_mismatch_profile(bams
rseqc_read_duplication(bams
rseqc_read_GC(bams
rseqc_RNA_fragment_size(bams, bed_model)
*/
}