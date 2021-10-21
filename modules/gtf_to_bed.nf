process gtf_to_bed {

myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdirs()

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

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
