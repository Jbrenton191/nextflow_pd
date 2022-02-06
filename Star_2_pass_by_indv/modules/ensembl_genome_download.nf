process ensembl_genome_download {


myDir3 = file("${baseDir}/output/reference_downloads")
myDir3.mkdir()

publishDir "${baseDir}/output/reference_downloads", mode: 'copy', overwrite: true

	output:
	path("*.fa"), emit: fasta
	path("*.gtf"), emit: gtf

	script:
	"""
	wget ftp://ftp.ensembl.org/pub/current_gtf/homo_sapiens/Homo_sapiens.GRCh38.104.gtf.gz

	wget ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

	gunzip Homo_sapiens.GRCh38.104.gtf.gz
	gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
	"""
}
