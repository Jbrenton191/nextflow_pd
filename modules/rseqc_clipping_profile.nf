process rseqc_clipping_profile {
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
"""
clipping_profile.py -i $bams -s "PE" -o $sample_name
"""
}
