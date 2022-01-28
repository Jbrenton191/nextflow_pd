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
    out_dir="${projectDir}/output/leafcutter"
    """
    Rscript ${projectDir}/../R_scripts/convert_STAR_SJ_to_junc.R $sj_loc ${projectDir} ${out_dir} ${projectDir}/../hg38-blacklist.v2.bed.gz
    """
}
