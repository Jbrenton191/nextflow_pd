process STAR_pass1_post_genome_gen {

myDir2 = file("${baseDir}/output/STAR/align/pre_merge")
myDir2.mkdirs()

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

  input:
  tuple val(sampleID), path(reads)
  val(genome_dir)

  output:
	val(sj_loc), emit: sj_loc
	path('*SJ.out.tab'), emit: sj_tabs
        tuple val(sampleID), path('*Log.final.out'), emit: log_final

  script:
  sj_loc="${baseDir}/output/STAR/align/pre_merge"
  """
  echo ${sampleID}
  echo ${reads[0]}
  echo ${reads[1]}

  STAR --runThreadN 25 \
--genomeDir $genome_dir \
--readFilesIn  ${reads[0]}, ${reads[1]} \
--readFilesCommand zcat \
--outFileNamePrefix ${sampleID}_mapped.BAM_ \
--outReadsUnmapped Fastx \
--outSAMtype BAM SortedByCoordinate \
--outFilterType BySJout \
--outFilterMultimapNmax 1 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 3
"""
}
