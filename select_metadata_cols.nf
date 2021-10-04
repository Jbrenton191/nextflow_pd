nextflow.enable.dsl=2
process select_metadata_cols {


myDir3 = file("${baseDir}/output/Salmon")
myDir3.mkdir()

publishDir "${baseDir}/output/Salmon", mode: 'move', overwrite: true

    input:
    val(meta_csv)
    val(meta_key)

    output:
    path("*.txt"), emit: metadata_selected_cols

    script:
    """
    Rscript ${baseDir}/select_metadata_cols.R ${projectDir}/$meta_csv ${projectDir}/$meta_key 
    """
}
workflow{
select_metadata_cols("20201229_MasterFile_SampleInfo.csv", "key_for_metadata.txt")
}
