nextflow.enable.dsl=2

   params.data="${baseDir}/../Regina_file_deposit/*R{1,3}*.fastq.gz"
   params.salmon_dir = "${projectDir}/output/Salmon/"
   params.metadata_csv= "${projectDir}/20201229_MasterFile_SampleInfo.csv"
   params.metadata_key= "${projectDir}/key_for_metadata.txt"

   output_dir = "${baseDir}/output"


include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download'
include { fastp } from './modules/fastp'
include { Star_genome_gen as star_genome_gen } from './modules/Star_genome_gen'
include { STAR_pass1_post_genome_gen as star_1 } from './modules/STAR_pass1_post_genome_gen'
include { Star_merge as star_merge } from './modules/Star_merge'
include { STAR_pass2 as star_2 } from './modules/STAR_pass2'

include { convert_juncs } from './modules/convert_juncs.nf'
include { cluster_juncs } from './modules/cluster_juncs.nf'
include { gtf_to_exons } from './modules/gtf_to_exons.nf'

include { create_groupfiles } from './modules/create_groupfiles_for_leafcutter.nf'
include { leafcutter } from './modules/leafcutter.nf'

workflow {
/*
data=Channel.fromFilePairs("${params.data}")
output_dir=Channel.value("${baseDir}/output")
fastp(data)
get_packages()
genome_download()
star_genome_gen(genome_download.out.fasta, genome_download.out.gtf)

fastp_reads=Channel.fromFilePairs("${baseDir}/output/fastp/*trimmed_{1,2}.fastq.gz")
gdir="${baseDir}/output/STAR/genome_dir"

// star_1(fastp.out.reads, star_genome_gen.out.gdir_val)
star_1(fastp_reads, gdir)
star_merge(star_1.out.sj_loc, star_1.out.sj_tabs.collect())
// star_2(fastp.out.reads, star_merge.out.merged_tab)
star_2(fastp_reads, star_merge.out.merged_tab)

// sj_loc="${projectDir}/output/STAR/align"
// convert_juncs(star_2.out.sj_loc, star_2.out.sj_tabs2.collect())
*/
sj_loc="${projectDir}/output/STAR/align"
sj_tabs2=Channel.fromPath("${projectDir}/output/STAR/align/*SJ.out.tab")
// convert_juncs(sj_loc, sj_tabs2.collect())
convert_juncs(sj_loc)
// junc_list=Channel.fromPath

// convert_juncs.out.junc_files.collect().flatten().unique().first().collect().view()

// cluster_juncs(convert_juncs.out.junc_list, convert_juncs.out.junc_files.collect().flatten().unique().first().collect())

cluster_juncs(convert_juncs.out.junc_list)


// gtf_to_exons(genome_download.out.gtf)

gtf="${projectDir}/output/reference_downloads/gencode.v38.chr_patch_hapl_scaff.annotation.gtf"
gtf_to_exons(gtf)

create_groupfiles(cluster_juncs.out.counts_file, "${projectDir}/output/metadata_and_groupfiles/metadata_cols_selected.txt")
leafcutter(cluster_juncs.out.counts_file, create_groupfiles.out.group_files.collect(), gtf_to_exons.out.exon_file)
}
