process convert_juncs {

myDir = file("${params.output}leafcutter")
myDir.mkdirs()

    publishDir "${params.output}/leafcutter", mode: 'copy', overwrite: true

    input:
    val(sj_loc)
//    path(sj_tabs)

    output:
    path("*.txt"), emit: junc_list
//    path("*.junc"), emit: junc_files

    script:
    out_dir="${params.output}/leafcutter"
    """
    Rscript ${projectDir}/R_scripts/convert_juncs_no_blacklist_removal.R $sj_loc ${out_dir}
    """
}
