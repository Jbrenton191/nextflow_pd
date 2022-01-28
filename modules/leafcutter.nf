nextflow.enable.dsl=2

myDir = file("${projectDir}/output/leafcutter/diff_splicing")
myDir.mkdirs()

process leafcutter {

    publishDir "${projectDir}/output/leafcutter/diff_splicing", mode: 'copy', overwrite: true

    input:
    val(count_file)
    val(group_files)
    path(exon_file)

    output:
    path("*cluster_significance.txt"), emit: cluster_significance
    path("*effect_sizes.txt"), emit: effect_sizes
    
    script:
//  base_dir="${projectDir}"
    group_files_dir="${projectDir}/output/metadata_and_groupfiles"
    """
    Rscript ${projectDir}/../R_scripts/leafcutter_diff_splicing.R $count_file $group_files_dir $exon_file ${projectDir}
    """
}
