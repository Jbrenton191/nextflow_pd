nextflow.enable.dsl=2

process get_name {
echo true

input:
path(data)

output:
stdout
// val("$name")

script:
"""
name=`echo "$data" | sed 's/_mapped.*//g'`
echo "\$name"
"""
/*
samtools sort -m 1000000000 ", bam_per_sample_paths -o ./${meta}_Aligned.sortedBysamtools.out.bam

samtools index ./${meta}_Aligned.sortedBysamtools.out.bam
*/
}
workflow {
data = channel.fromPath("${projectDir}/output/STAR/align/*.bam")
get_name(data)
}
