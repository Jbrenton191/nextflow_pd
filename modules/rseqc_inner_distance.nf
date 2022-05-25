process rseqc_inner_distance {
echo true

// conda 'rseqc'

myDir = file("${params.output}/Rseqc")
myDir.mkdir()
// conda 'python=2.7.14 bioconda::rseqc'
// conda "${projectDir}/rseqc_env.yml"

publishDir "${params.output}/Rseqc", mode: 'copy', overwrite: true

input:
path(bams)
path(bed_model)

output:
path("*")

script:
sample_name=bams.simpleName
"""
inner_distance.py -i $bams -r $bed_model -o $sample_name
"""
}
