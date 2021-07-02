nextflow.enable.dsl=2

myDir = file('/home/jbrenton/nextflow_test/output/leafcutter')
myDir.mkdir()

process convert_juncs {

        publishDir '/home/jbrenton/nextflow_test/output/leafcutter', mode: 'copy', overwrite: true

        input:
    val(sj_loc)

    output:
    path("*.txt"), emit: junc_list

    script:
    out_dir="/home/jbrenton/nextflow_test/output/leafcutter"
    """
    Rscript ${baseDir}/convert_STAR_SJ_to_junc.R $sj_loc ${baseDir} $out_dir
    """
}

process cluster_juncs {

publishDir '/home/jbrenton/nextflow_test/output/leafcutter', mode: 'copy', overwrite: true

      conda 'python=2.7.14'

        input:
        path(junc_list)

        output:
        path("*")

       script:
        """
        python ${baseDir}/leafcutter_cluster.py \
        -j $junc_list \
        -r . \
        -l 1000000 \
        -m 30 \
        -p 0.001 \
        -s True
        """
}

process gtf_to_exons {
        
        publishDir '/home/jbrenton/nextflow_test/output/leafcutter', mode: 'copy', overwrite: true

        output:
        path("*")

        script:
        """
        Rscript ${baseDir}/gtf_to_exons.R \
        ${baseDir}/Homo_sapiens.GRCh38.97.gtf.gz \
        ./Homo_sapiens.GRCh38.97_LC_exon_file.txt.gz
        """
}

workflow {
//        sj_loc='/home/jbrenton/nextflow_test/output/STAR/align'
//        convert_juncs(sj_loc)
//        cluster_juncs(convert_juncs.out.junc_list)
        gtf_to_exons()
}
