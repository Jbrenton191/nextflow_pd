nextflow.enable.dsl=2

myDir = file("${projectDir}/output/metadata_and_groupfiles")
myDir.mkdir()

process create_groupfiles {

    publishDir "${projectDir}/output/metadata_and_groupfiles", mode: 'copy', overwrite: true

    input:
    val(count_file)
    val(metadata_cols_path)

    output:
//    path("*.txt"), emit: group_files
    val(out_dir), emit: gf_out

    script:
    out_dir="${projectDir}/output/metadata_and_groupfiles"
    """
    Rscript ${projectDir}/../R_scripts/create_groupfiles_for_leafcutter.R $count_file $metadata_cols_path $out_dir
    """
}
