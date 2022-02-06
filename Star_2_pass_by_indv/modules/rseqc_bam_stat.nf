process rseqc_bam_stat {
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
bam_stat.py -i $bams > ${sample_name}_bam_stat.txt
"""
}
