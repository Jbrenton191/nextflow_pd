process rseqc_junction_annotation {
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
junction_annotation.py -i $bams -r $bed_model -m 20 -o $sample_name
"""
}
