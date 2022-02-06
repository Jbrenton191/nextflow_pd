process rseqc_inner_distance {
echo true

conda 'python=2.7 rseqc'

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

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
