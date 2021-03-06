process convert_juncs {

myDir = file("${projectDir}/output/leafcutter")
myDir.mkdirs()

    publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

    input:
    val(sj_loc)
    path(sj_tabs)

    output:
    path("*.txt"), emit: junc_list
//    path("*.junc"), emit: junc_files

    script:
    out_dir="${params.output}/leafcutter"
    """
    Rscript ${projectDir}/convert_STAR_SJ_to_junc.R $sj_loc ${projectDir} ${out_dir}
    """
}
