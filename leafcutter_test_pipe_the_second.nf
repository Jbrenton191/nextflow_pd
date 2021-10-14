nextflow.enable.dsl=2

   params.data="${baseDir}/../Regina_file_deposit/*R{1,3}*.fastq.gz"
   params.salmon_dir = "${projectDir}/output/Salmon/"
   params.metadata_csv= "${projectDir}/20201229_MasterFile_SampleInfo.csv"
   params.metadata_key= "${projectDir}/key_for_metadata.txt"

   output_dir = "${baseDir}/output"

include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download'

include { convert_juncs } from './modules/convert_juncs.nf'
include { cluster_juncs } from './modules/cluster_juncs.nf'
include { gtf_to_exons } from './modules/gtf_to_exons.nf'
include { create_groupfiles } from './modules/create_groupfiles_for_leafcutter.nf'
include { leafcutter } from './modules/leafcutter.nf'


workflow {

get_packages()

// genome_download()

sj_tabs=channel.fromPath("${projectDir}/output/STAR/align/*mapped_post_merge*SJ.out.tab")
// sj_tabs.view()
sj_loc="${projectDir}/output/STAR/align"
// convert_juncs(sj_loc, sj_tabs.collect())
convert_juncs(sj_loc)

cluster_juncs(convert_juncs.out.junc_list)

// gtf_to_exons(genome_download.out.gtf)

gtf_to_exons("${projectDir}/output/reference_downloads/gencode.v38.chr_patch_hapl_scaff.annotation.gtf")

create_groupfiles(cluster_juncs.out.counts_file, "${projectDir}/output/metadata_and_groupfiles/metadata_cols_selected.txt")
leafcutter(cluster_juncs.out.counts_file, create_groupfiles.out.gf_out, gtf_to_exons.out.exon_file)

}
