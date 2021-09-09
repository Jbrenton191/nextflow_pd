nextflow.enable.dsl=2

myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdir()

process get_name {
echo true

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

input:
path(data)

output:
path("*")
// val("$name")

script:
"""
name=`echo "$data" | sed 's/_mapped.*//g'`
echo "\$name"
samtools sort -m 1000000000 $data -o ./\${name}_Aligned.sortedBysamtools.out.bam

samtools index ./\${name}_Aligned.sortedBysamtools.out.bam
"""
}
workflow {
data = channel.fromPath("${projectDir}/output/STAR/align/*.bam")
get_name(data)
}
