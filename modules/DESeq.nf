nextflow.enable.dsl=2
process DESeq {

myDir3 = file("${params.output}/DESeq")
myDir3.mkdirs()

publishDir "${params.output}/DESeq", mode: 'copy', overwrite: true

    input:
    path(quant_dirs)
    val(metadata_cols)
    val(gencodetx2gene)

    output:
    path("significant_genes_padj_0.05_and_log2FoldChange_abs1.csv"), emit: sig_genes
    path("samples_groups_and_metadata_in_DESeq_comparisons.csv"), emit: used_samples_metadata
    path("samples_removed_from_DESeq_comparisons_because_of_NAs.csv"), emit: not_used_samples_metadata

    script:
    meta_cols="${params.output}/metadata_and_groupfiles/${metadata_cols.name}"
    gencode_tx2gene="${params.output}/Salmon/${gencodetx2gene.name}"
    
    """
    Rscript ${projectDir}/R_scripts/DESeq.R ${params.output}/Salmon $meta_cols $gencode_tx2gene ${projectDir}/hg38-blacklist.v2.bed.gz
    """
}
