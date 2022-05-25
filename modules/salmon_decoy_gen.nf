process decoy_gen {

nextflow.enable.dsl=2

myDir2 = file("${params.output}/Salmon")
myDir2.mkdirs()

publishDir "${params.output}/Salmon", mode: 'copy', overwrite: true

// cache = 'lenient' // (Best in HPC and shared file systems) Cache keys are created indexing input files path and size attributes

input:
path(fasta)
path(transcripts)

output:
path("gentrome.fa"), emit: gentrome
path("decoys.txt"), emit: decoys
path("*.bak"), emit: bak

script:
"""
cat $transcripts $fasta > gentrome.fa

grep "^>" $fasta | cut -d " " -f 1 > decoys.txt
sed -i.bak -e 's/>//g' decoys.txt
"""
}
