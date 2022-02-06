process rseqc_mismatch_profile {
echo true

conda 'python=2.7 rseqc'

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

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
