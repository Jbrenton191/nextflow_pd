process Star_merge {

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

echo true

    input:
    val(sj_loc)
    path(sj_tabs)

    output:
    path("merged_junctions.SJ.out.tab"), emit: merged_tab

    script:
    """
    Rscript ${baseDir}/STAR_splice_junction_merge.R $sj_loc -o .
    """

}
