nextflow.enable.dsl=2

process STAR_genome_gen {

myDir = file('/home/jbrenton/nextflow_test/output/STAR')
myDir.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/STAR/genome_dir', mode: 'copy'

    output:
    path("*"), emit: stdout_genome_gen
    val("${gdir_val}"), emit: gdir_val
    path("*.tab"), emit: some_path

    script:
    gdir_val="/home/jbrenton/nextflow_test/output/STAR/genome_dir"
    """
cp /data/references/fasta/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa /home/jbrenton/nextflow_test/output/STAR/genome_dir
cp /data/references/ensembl/gtf_gff3/v97/Homo_sapiens.GRCh38.97.gtf /home/jbrenton/nextflow_test/output/STAR/genome_dir

STAR --runThreadN 35 --runMode genomeGenerate --genomeDir . --genomeFastaFiles /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa --sjdbGTFfile /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.gtf --sjdbOverhang 99
  """
}

process STAR_pass1_post_genome_gen {

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/align')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/STAR/align', mode: 'copy'

  input:
  tuple val(sampleID), path(reads)
   path(some_tabs)
   val(genome_dir)

  output:
  path('*SJ.out.tab'), emit: sj_tabs
  val("${sj_loc}"), emit: sj_loc

  script:
  sj_loc='/home/jbrenton/nextflow_test/output/STAR/align'
  """
  echo ${sampleID}
  echo ${reads[0]}
  echo ${reads[1]}

STAR --runThreadN 25 --genomeDir $genome_dir --readFilesIn  ${reads[0]}, ${reads[1]} --readFilesCommand zcat --outFileNamePrefix ${sampleID}_mapped.BAM_ --outReadsUnmapped Fastx --outSAMtype BAM SortedByCoordinate --outFilterType BySJout --outFilterMultimapNmax 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --alignSJoverhangMin 8 --alignSJDBoverhangMin 3
"""
}

workflow {
 data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
	STAR_genome_gen()
//	STAR_genome_gen.out.stdout_genome_gen.view { "the stdout value is $it " }
	STAR_genome_gen.out.some_path.view { "the path value is $it" }
	 STAR_genome_gen.out.gdir_val.view { "the gdir_val is $it" }
	STAR_pass1_post_genome_gen(data, STAR_genome_gen.out.stdout_genome_gen.collect(), STAR_genome_gen.out.gdir_val)
//   gdir_val='/home/jbrenton/nextflow_test/output/STAR/genome_dir' 
//   STAR_pass1_post_genome_gen(data, gdir_val)
}
