nextflow.enable.dsl=2

process STAR_genome_gen {

myDir = file('/home/jbrenton/nextflow_test/output/STAR')
myDir.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/STAR/genome_dir', mode: 'copy', overwrite: true

    output:
    val(gdir_val), emit: gdir_val

    script:
    gdir_val=file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
    """
cp /data/references/fasta/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa /home/jbrenton/nextflow_test/output/STAR/genome_dir
cp /data/references/ensembl/gtf_gff3/v97/Homo_sapiens.GRCh38.97.gtf /home/jbrenton/nextflow_test/output/STAR/genome_dir

STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir /home/jbrenton/nextflow_test/output/STAR/genome_dir \
--genomeFastaFiles /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa \
--sjdbGTFfile /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.gtf \
--sjdbOverhang 99
  """
}

workflow {
 data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
	STAR_genome_gen()
//	STAR_genome_gen.out.stdout_genome_gen.view("stdout $it")
//	STAR_genome_gen.out.all_path.view("path $it") 
}
