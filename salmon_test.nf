nextflow.enable.dsl=2

process decoy_gen {

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

cache = 'lenient' // (Best in HPC and shared file systems) Cache keys are created indexing input files path and size attributes

output:
path("gentrome.fa"), emit: gentrome
path("decoys.txt"), emit: decoys
path("*.bak"), emit: bak

script:
"""
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.pc_transcripts.fa.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.lncRNA_transcripts.fa.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/GRCh38.p13.genome.fa.gz

gunzip gencode.v38.pc_transcripts.fa.gz
gunzip gencode.v38.lncRNA_transcripts.fa.gz
gunzip GRCh38.p13.genome.fa.gz

cat gencode.v38.pc_transcripts.fa gencode.v38.lncRNA_transcripts.fa GRCh38.p13.genome.fa > gentrome.fa

grep "^>" GRCh38.p13.genome.fa | cut -d " " -f 1 > decoys.txt
sed -i.bak -e 's/>//g' decoys.txt
"""

/*
 * salmon index -t gentrome.fa.gz -d decoys.txt -p 12 -i salmon_index --gencode
 */
}

process salmon_index_gen {
 echo true

myDir2 = file("${workflow.projectDir}/output/Salmon")
myDir2.mkdirs()

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

// storeDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

// publishDir "/home/jbrenton/nextflow_test/output/Salmon", mode: 'copy'

// println myDir2

	input:
	path(gentrome)
	path(decoys)

	output:
	stdout emit: index_files
	val(transcript_index_loc), emit: s_index
	
	script:
	transcript_index_loc="/home/jbrenton/nextflow_test/output/Salmon/salmon_index"
	"""
	echo $transcript_index_loc
	salmon index -t $gentrome -i salmon_index -k 31 -d $decoys -p 20
	"""
}

process salmon {

publishDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true
// storeDir "${baseDir}/output/Salmon", mode: 'copy', overwrite: true

	input:
	val(s_index)
	tuple val(meta), path(reads)

	output:
	path("$meta"), emit: quant_dirs

	 script:
   	 """
	echo $meta
	echo $s_index

salmon quant -i $s_index -l ISR -1 ${reads[0]} -2 ${reads[1]} --useVBOpt --numBootstraps 30 --seqBias --gcBias --posBias -o $meta --validateMappings --rangeFactorizationBins 4 --threads 30
	"""
}



workflow {
data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
// x=System.getProperty("user.dir")
// println "x is ${x}"
// y=Channel.value("${x}/output")
// y.view()
	decoy_gen()
	salmon_index_gen(decoy_gen.out.gentrome, decoy_gen.out.decoys)
//	salmon_index_gen.out.index_files.view { println "index output: $it" }
	salmon_index_gen.out.s_index.view {"Received: $it"}

//	s_index="/home/jbrenton/nextflow_test/output/Salmon/salmon_index"
//	salmon(s_index, data)
	salmon(salmon_index_gen.out.s_index, data)
// salmon(salmon_index_gen.out.s_index, fastp.out.reads)
   }
