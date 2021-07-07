nextflow.enable.dsl=2

process decoy_gen {


script:
"""
wget ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
wget ftp://ftp.ensembl.org/pub/release-97/fasta/homo_sapiens/ncrna/Homo_sapiens.GRCh38.ncrna.fa.gz

gunzip Homo_sapiens.GRCh38.cdna.all.fa.gz
gunzip Homo_sapiens.GRCh38.ncrna.fa.gz

cat Homo_sapiens.GRCh38.97.cdna.all.fa Homo_sapiens.GRCh38.97.ncrna.fa > Homo_sapiens.GRCh38.97.cdna.all.ncrna.fa
"""

}

process salmon_index_gen {
 echo true

myDir2 = file("${workflow.projectDir}/output/Salmon")
myDir2.mkdirs()

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

// storeDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

// publishDir "/home/jbrenton/nextflow_test/output/Salmon", mode: 'copy'

// println myDir2

	output:
	path("*index"), emit: index_files
	val("$transcript_index_loc"), emit: s_index
	
	script:
	transcript_file=file("${workflow.projectDir}/*transcripts.fa.gz")
	transcript_index_loc="/home/jbrenton/nextflow_test/output/Salmon/salmon_transcripts_index"
	"""
	echo "${transcript_file[0]}"
	echo $transcript_index_loc
	salmon index -t ${transcript_file[0]} -i salmon_transcripts_index -k 31
	"""
}

process salmon {

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true
// storeDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

	input:
	val(s_index)
	tuple val(meta), path(reads)

	output:
	tuple val(meta), path("$meta"), emit: quant_dirs

	 script:
   	 """
	salmon quant -i $s_index -l ISR -1 ${reads[0]} -2 ${reads[1]} --useVBOpt --numBootstraps 30 --seqBias --gcBias --posBias -o $meta --validateMappings --rangeFactorizationBins 4 --threads 30
	"""
}



workflow {
data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
// x=System.getProperty("user.dir")
// println "x is ${x}"
// y=Channel.value("${x}/output")
// y.view()
	salmon_index_gen()
//	salmon_index_gen.out.index_files.view { println "index output: $it" }
	salmon_index_gen.out.s_index.view {"Received: $it"}
	salmon(salmon_index_gen.out.s_index, data)
// salmon(salmon_index_gen.out.s_index, fastp.out.reads)
   }
