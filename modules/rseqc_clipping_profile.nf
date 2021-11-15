process rseqc_clipping_profile {
echo true

conda 'python=2.7 rseqc'

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

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
