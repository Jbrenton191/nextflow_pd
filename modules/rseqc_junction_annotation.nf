process rseqc_junction_annotation {
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
junction_annotation.py -i $bams -r $bed_model -m 20 -o $sample_name
"""
}
