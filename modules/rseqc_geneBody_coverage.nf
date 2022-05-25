process rseqc_geneBody_coverage {
echo true

// conda 'rseqc'

myDir = file("${params.output}/Rseqc")
myDir.mkdir()
// conda 'python=2.7.14 bioconda::rseqc'
// conda "${projectDir}/rseqc_env.yml"

publishDir "${params.output}/Rseqc", mode: 'copy', overwrite: true

input:
path(bed_model)
val(bam_dir)

output:
path("*")

script:
"""
geneBody_coverage.py -r $bed_model -i $bam_dir -o all_files_
"""
}
