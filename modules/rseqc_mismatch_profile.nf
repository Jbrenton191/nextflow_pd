process rseqc_mismatch_profile {
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
mismatch_profile.py -i $bams -l $read_length -o $sample_name
"""
}
