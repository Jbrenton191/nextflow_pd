

process get_packages {
	
	// publishDir "${projectDir}", mode: 'copy', overwrite: true

	myDir = file("${params.output}")
	myDir.mkdirs()

	publishDir "${myDir}", mode: 'copy', overwrite: true
	
	output:
	val(fin_val), emit: pack_done_val
	
	script:
	fin_val="Package download didn't fail"
	"""
	Rscript ${projectDir}/R_scripts/Rpackage_download.R
	"""

// git clone https://github.com/RHReynolds/RNAseqProcessing.git
// also assumes you have git in command line!
// add in (also move yml file into folder): conda env create -f nextflow_env.yml -n nf_env
}
