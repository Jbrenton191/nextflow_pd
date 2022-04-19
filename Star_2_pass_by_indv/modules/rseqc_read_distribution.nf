process rseqc_read_distribution {
echo true

// conda 'python=2.7.14 bioconda::rseqc'
// conda "${projectDir}/rseqc_env.yml"

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

input:
path(bams)
path(bed_model)

output:
path("*")

script:
sample_name=bams.simpleName
"""
read_distribution.py -i $bams -r $bed_model > ${sample_name}_read_distribution.txt
"""
}
