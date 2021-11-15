process rseqc_RNA_fragment_size {
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
RNA_fragment_size.py -i $bams -r $bed_model > ${sample_name}_RNA_fragment_size.txt
"""
}
