process decoy_gen {

nextflow.enable.dsl=2

myDir2 = file("${baseDir}/output/Salmon")
myDir2.mkdirs()

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
