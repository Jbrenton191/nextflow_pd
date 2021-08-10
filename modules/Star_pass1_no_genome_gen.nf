process Star_pass1_no_genome_gen {

myDir = file("${baseDir}/output/STAR")
myDir.mkdir()

myDir2 = file("${baseDir}/output/STAR/genome_dir")
myDir2.mkdir()

myDir2 = file("${baseDir}/output/STAR/align")
myDir2.mkdir()

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

storeDir "${baseDir}/output/STAR/align"
echo true

  input:
  tuple val(sampleID), path(reads)

	output:
	val(sj_loc), emit: sj_loc
        tuple val(sampleID), path('*SJ.out.tab'), emit: sj_tabs

  script:
  sj_loc="${baseDir}/output/STAR/align"
  """
  echo ${sampleID}
  echo ${reads[0]}
  echo ${reads[1]}

  STAR --genomeDir ${baseDir}/output/genome_dir \
  --readFilesIn  ${reads[0]}, ${reads[1]} \
  --readFilesCommand zcat \
  --outFileNamePrefix ${sampleID}_ \
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
