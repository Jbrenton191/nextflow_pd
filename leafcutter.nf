nextflow.enable.dsl=2

myDir = file('/home/jbrenton/nextflow_test/output/leafcutter')
myDir.mkdir()

process convert_juncs {
	publishDir '/home/jbrenton/nextflow_test/output/leafcutter', mode: 'copy', overwrite: true
	
    input:
    val(sj_loc)

    output:
    path("*.junc"), emit: juncs
    path("*.txt"), emit: junc_path_txt

    script:
    out_dir="/home/jbrenton/nextflow_test/output/leafcutter"
    """
    Rscript convert_STAR_SJ_to_junc.R $sj_loc ${baseDir} $out_dir
    """
}

process cluster_juncs {

	conda 'python=2.7.14'

	input:
		

	output:

	script:

	"""
	
	"""
}
