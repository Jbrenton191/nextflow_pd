process STAR_pass2 {
echo true

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true


    input:
    tuple val(sampleID), path(reads)
    path(merged_tab)

    output:
	stdout

  script:
  """
  limits=`sh ${baseDir}/sj_length.sh $merged_tab`
  echo \$limits
  
  STAR --runThreadN 20 \
  --genomeDir ${baseDir}/output/STAR/genome_dir \
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
  --alignSJDBoverhangMin 3 \
  --sjdbFileChrStartEnd $merged_tab \
  --limitSjdbInsertNsj \$limits
  """
}
