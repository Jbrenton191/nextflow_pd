nextflow.enable.dsl=2

process sam_sort {
input:
path(bam_files)

output:
path(sorted_bam_files)

script:
"""
samtools sort -m 1000000000 ", bam_per_sample_paths -o ./${meta}_Aligned.sortedBysamtools.out.bam
"""
}
workflow {
   data=Channel.fromPath("${baseDir}/*.bam")
   meta=data.collect().simpleName.view()
//   tups=data.collect().merge(meta)
//   tups.view()
}
