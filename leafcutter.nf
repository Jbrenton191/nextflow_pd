nextflow.enable.dsl=2

myDir = file("/${projectDir}/output/leafcutter")
myDir.mkdir()

process convert_juncs {

    publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

    input:
    val(sj_loc)

    output:
    path("*.txt"), emit: junc_list

    script:
    out_dir="${projectDir}/output/leafcutter"
    """
    Rscript ${projectDir}/convert_STAR_SJ_to_junc.R $sj_loc ${projectDir} $out_dir
    """
}

process cluster_juncs {

publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

      conda 'python=2.7.14'

        input:
        path(junc_list)

        output:
        path("*")

       script:
        """
        python ${projectDir}/leafcutter_cluster.py \
        -j $junc_list \
        -r . \
        -l 1000000 \
        -m 30 \
        -p 0.001 \
        -s True
        """
}

process gtf_to_exons {
        
publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

input:
path(gtf)

        output:
        path("*.txt.gz")

        script:
        """
        gzip -f $gtf
        Rscript ${projectDir}/gtf_to_exons.R \
        ${gtf}.gz \
        ${gtf.simpleName}_LC_exon_file.txt.gz
        """
}

workflow {
 gtf="${projectDir}/output/reference_downloads/gencode.v38.chr_patch_hapl_scaff.annotation.gtf"
        sj_loc="${projectDir}/output/STAR/align"
        convert_juncs(sj_loc)
        cluster_juncs(convert_juncs.out.junc_list)
        gtf_to_exons(gtf)
}

