nextflow.enable.dsl=2

myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdir()

process get_name {
echo true

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

input:
path(bed_model)
path(bams)
val(bam_dir)

output:
path("*")

script:
"""
geneBody_coverage.py -r $bed_model -i $data -o all_files_
"""
// geneBody_coverage.py -r ./output/Samtools_Rseqc/Homo_sapiens.GRCh38.97.bed -i ./output/Samtools_Rseqc/ -o all_files_

}

workflow {
data = channel.fromPath("${projectDir}/output/Samtools_Rseqc/*.bai")
bed_model=channel.fromPath("${projectDir}/output/Samtools_Rseqc/Homo_sapiens.GRCh38.97.bed")
bam_dir=data.first().parent
get_name(bed_model, data, bam_dir)
}
