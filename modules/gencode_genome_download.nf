process genome_download {


myDir3 = file("${baseDir}/output/reference_downloads")
myDir3.mkdir()

publishDir "${baseDir}/output/reference_downloads", mode: 'move', overwrite: true

	output:
	path("*.fa"), emit: fasta
	path("*.gtf"), emit: gtf

	script:
	"""
	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.chr_patch_hapl_scaff.annotation.gtf.gz
	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/GRCh38.p13.genome.fa.gz

	gunzip GRCh38.p13.genome.fa.gz
	gunzip gencode.v38.chr_patch_hapl_scaff.annotation.gtf.gz
	"""
}
