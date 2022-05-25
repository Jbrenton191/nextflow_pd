process fastqc {

myDir2 = file("${params.output}/fastqc")
myDir2.mkdir()

publishDir "${params.output}/fastqc", mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)

    output:
    path("*fastqc.html"), emit: html
    tuple val("${sampleID}"), path("*fastqc.zip"), emit: zip
    val("${fqc_files}"), emit: fqc_files

    script:
    fqc_files="${params.output}"
    """
    fastqc $reads -t 20
    """
}
