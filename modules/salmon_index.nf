process salmon_index_gen {
 echo true

myDir2 = file("${baseDir}/output/Salmon")
myDir2.mkdirs()

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

	input:
	path(gentrome)
	path(decoys)

	output:
	path("salmon_index"), emit: whole_index
	val(transcript_index_loc), emit: s_index

	script:
	transcript_index_loc="${baseDir}/output/Salmon/salmon_index"
	"""
	echo $transcript_index_loc
	salmon index -t $gentrome -i salmon_index -k 31 -d $decoys --gencode
	"""
}
