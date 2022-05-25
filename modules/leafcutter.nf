nextflow.enable.dsl=2

process leafcutter {

myDir = file("${params.output}/leafcutter/diff_splicing")
myDir.mkdirs()

    publishDir "${params.output}/leafcutter/diff_splicing", mode: 'copy', overwrite: true

    input:
    val(count_file)
    val(group_files)
    path(exon_file)

    output:
    path("*cluster_significance.txt"), emit: cluster_significance
    path("*effect_sizes.txt"), emit: effect_sizes
    
    script:
//  base_dir="${projectDir}"
    group_files_dir="${params.output}/metadata_and_groupfiles"
    """
    Rscript ${projectDir}/R_scripts/leafcutter_diff_splicing.R $count_file $group_files_dir $exon_file ${projectDir}
    """
}
