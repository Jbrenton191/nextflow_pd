nextflow.enable.dsl=2
process gencode_genemap {


myDir3 = file("${baseDir}/output/Salmon")
myDir3.mkdir()

publishDir "${baseDir}/output/Salmon", mode: 'move', overwrite: true

    input:
    path(transcript_ref)
    
    output:
    path("*.txt"), emit: gene_map

    script:
    """
    Rscript ${baseDir}/create_gencode_gene_map.R $transcript_ref
    """
}
