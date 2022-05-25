process rseqc_read_GC {
echo true

// conda 'rseqc'

myDir = file("${params.output}/Rseqc")
myDir.mkdir()
// conda 'python=2.7.14 bioconda::rseqc'
// conda "${projectDir}/rseqc_env.yml"

publishDir "${params.output}/Rseqc", mode: 'copy', overwrite: true

input:
path(bams)

output:
path("*")

script:
sample_name=bams.simpleName
read_length=params.read_length
"""
read_GC.py -i $bams -o $sample_name
"""
}
