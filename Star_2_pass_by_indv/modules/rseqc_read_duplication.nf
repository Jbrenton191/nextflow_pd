process rseqc_read_duplication {
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
read_duplication.py -i $bams -u 20000 -o $sample_name
"""
}
