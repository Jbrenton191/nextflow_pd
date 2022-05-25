process rseqc_read_distribution {
echo true

myDir = file("${params.output}/Rseqc")
myDir.mkdir()
// conda 'python=2.7.14 bioconda::rseqc'
// conda "${projectDir}/rseqc_env.yml"

publishDir "${params.output}/Rseqc", mode: 'copy', overwrite: true

input:
path(bams)
each(bed_model)

output:
path("*")

script:
sample_name=bams.simpleName
"""
read_distribution.py -i $bams -r $bed_model > ${sample_name}_read_distribution.txt
"""
}
