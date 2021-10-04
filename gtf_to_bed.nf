nextflow.enable.dsl=2

myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdirs()

process gtf_to_bed {

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

echo true

    input:
    path(gtf_file)

    output:
    path("*.bed")

    script:
    """
    $projectDir/gtf2bed $gtf_file > ${gtf_file}.bed
     rename 's/.gtf//' ${gtf_file}.bed
    """
}
workflow {
//  gtf_file=file("$projectDir/Homo_sapiens.GRCh38.97.gtf")

 gtf_file=file("$projectDir/output/reference_downloads/gencode.v38.chr_patch_hapl_scaff.annotation.gtf")
gtf_to_bed(gtf_file)
}
