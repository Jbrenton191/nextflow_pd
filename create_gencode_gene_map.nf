nextflow.enable.dsl=2
process gencode_genemap {


myDir3 = file("${baseDir}/output/Salmon")
myDir3.mkdir()

publishDir "${baseDir}/output/Salmon", mode: 'move', overwrite: true

    output:
    path("*.txt"), emit: gene_map

    script:
    """
    Rscript ${baseDir}/create_gencode_gene_map.R ${baseDir}/output/reference_downloads/gencode.v38.pc_transcripts.fa
    """
}
workflow{
gencode_genemap()
}
