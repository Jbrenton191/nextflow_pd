process fastqc {

myDir2 = file("${projectDir}/output/fastqc")
myDir2.mkdir()

publishDir "${projectDir}/output/fastqc", mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)

    output:
    path("*fastqc.html"), emit: html
    tuple val("${sampleID}"), path("*fastqc.zip"), emit: zip
    val("${fqc_files}"), emit: fqc_files

    script:
    fqc_files="${projectDir}/output"
    """
    fastqc $reads -t 20
    """
}
