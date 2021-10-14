process cluster_juncs {

publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

      conda 'python=2.7.14'

        input:
        path(junc_list)
//      path(junc_files)
        
        output:
      	path("*perind.counts.gz"), emit: counts_1
      	path("*perind_numers.counts.gz"), emit: counts_file
        
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
