process salmon {

publishDir "${params.output}/Salmon", mode: 'copy', overwrite: true

	input:
	path(whole_index)
	tuple val(meta), path(reads)

	output:
	path("$meta"), emit: quant_dirs

	 script:
   	 """
	echo $meta

salmon quant -i $whole_index -l A -1 ${reads[0]} -2 ${reads[1]} --useVBOpt --numBootstraps 30 --seqBias --gcBias --posBias -o $meta --validateMappings --rangeFactorizationBins 4 --threads 25
	"""
}
