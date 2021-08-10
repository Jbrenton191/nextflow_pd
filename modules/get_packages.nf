process get_packages {
	
	publishDir "${baseDir}", mode: 'copy', overwrite: true

	output:
	stdout

	script:
	"""
	Rscript $baseDir/Rpackage_download.R
	"""
// git clone https://github.com/RHReynolds/RNAseqProcessing.git
// also assumes you have git in command line!
// add in (also move yml file into folder): conda env create -f nextflow_env.yml -n nf_env
}
