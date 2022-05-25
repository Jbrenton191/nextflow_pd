process gtf_to_bed {

myDir = file("${params.output}/Samtools_Rseqc")
myDir.mkdirs()

publishDir "${params.output}/Samtools_Rseqc", mode: 'copy', overwrite: true

    input:
    path(gtf_file)

    output:
    path("*.bed"), emit: bed_model

    script:
    """
    $projectDir/gtf2bed $gtf_file > ${gtf_file}.bed
     rename 's/.gtf//' ${gtf_file}.bed
    """
}
