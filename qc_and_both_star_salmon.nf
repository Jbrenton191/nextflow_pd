nextflow.enable.dsl = 2

params.data="${baseDir}/../nextflow_test/files/*R{1,3}*.fastq.gz"

// params.data='${baseDir}/../nextflow_test/files/*{1,2}.fastq.gz'


output_dir = file("${baseDir}/output")
output_dir

include { get_packages } from './modules/get_packages'
include { genome_download } from './modules/gencode_genome_download' 
include { fastp } from './modules/fastp'
include { fastqc } from './modules/fastqc'
include { Star_genome_gen as star_genome_gen } from './modules/Star_genome_gen'
include { STAR_pass1_post_genome_gen as star_1 } from './modules/STAR_pass1_post_genome_gen'
include { multiqc_1st_pass as multiqc_1 } from './modules/multiqc_1st_pass'
include { Star_merge as star_merge } from './modules/Star_merge'
include { STAR_pass2 as star_2 } from './modules/STAR_pass2'

include { decoy_gen } from './modules/salmon_decoy_gen'
include { salmon_index_gen as salmon_index } from './modules/salmon_index'
include { salmon as salmon_quantification } from './modules/salmon_quantification'
include { multiqc_post_star_salmon } from './modules/multiqc_both_aligners'


workflow {
   data=Channel.fromFilePairs("$params.data")
   data.view()
fastp(data)
get_packages()
genome_download()
fastqc(fastp.out.reads)
star_genome_gen(genome_download.out.fasta, genome_download.out.gtf)
star_1(fastp.out.reads, star_genome_gen.out.gdir_val)
multiqc_1(output_dir, star_1.out.sj_tabs)
star_merge(star_1.out.sj_loc, star_1.out.sj_tabs.collect().flatten().unique().first().collect())
star_2(fastp.out.reads, star_merge.out.merged_tab)

decoy_gen()
salmon_index(decoy_gen.out.gentrome, decoy_gen.out.decoys)
salmon_quantification(salmon_index.out.whole_index.collect(), fastp.out.reads)

multiqc_post_star_salmon(star_2.out.sj_tabs2, salmon_quantification.out.quant_dirs, output_dir)
}
