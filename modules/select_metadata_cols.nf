nextflow.enable.dsl=2
process select_metadata_cols {


myDir3 = file("${projectDir}/output/metadata_and_groupfiles")
myDir3.mkdirs()

publishDir "${projectDir}/output/metadata_and_groupfiles", mode: 'copy', overwrite: true

    input:
    val(meta_csv)
    val(meta_key)
    val(pack_done_val)
	
    output:
    path("*.txt"), emit: metadata_selected_cols

    script:
    """
    Rscript ${projectDir}/../Rscripts/select_metadata_cols.R $meta_csv $meta_key 
    """
}
