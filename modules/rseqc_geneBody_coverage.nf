process rseqc_geneBody_coverage {
echo true

conda 'python=2.7 rseqc'

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

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
