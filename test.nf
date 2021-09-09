nextflow.enable.dsl=2

   params.data="${baseDir}/../Regina_file_deposit/*R{1,3}*.fastq.gz"


   output_dir = "${baseDir}/output"


include { Star_merge as star_merge } from './modules/Star_merge'
include { STAR_pass2 as star_2 } from './modules/STAR_pass2'


workflow {

data=Channel.fromPath("${baseDir}/output/STAR/align/*mapped.BAM_SJ.out.tab")
data.view()
data.first().view()

sj_loc=data.first().getParent().view()
// println "$sj_loc"

// star_merge(sj_loc, data.collect())
/*
star_2(fastp.out.reads, star_merge.out.merged_tab)
*/
}
