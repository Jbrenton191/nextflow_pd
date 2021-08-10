process STAR_pass2 {

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

storeDir "${baseDir}/output/STAR/align"

    input:
    tuple val(sampleID), path(reads)
    path(merged_tab)

    output:
	tuple val(sampleID), path("*SJ.out.tab"), emit: sj_tabs2
	val(sj_loc), emit: sj_loc
        tuple val(meta), path('*.out.bam'), emit: bam

        tuple val(sampleID), path('*sortedByCoord.out.bam'), optional:true, emit: bam_sorted
        tuple val(sampleID), path('*toTranscriptome.out.bam'), optional:true, emit: bam_transcript
        tuple val(sampleID), path('*Aligned.unsort.out.bam'), optional:true, emit: bam_unsorted

        tuple val(meta), path('*Log.final.out'), emit: log_final
        tuple val(meta), path('*Log.out'), emit: log_out
        tuple val(meta), path('*Log.progress.out'), emit: log_progress
        path  '*.version.txt', emit: version

   script:
      """
  limits=`sh ${baseDir}/sj_length.sh $merged_tab`

  echo \$limits

  STAR --genomeDir ${baseDir}/output/STAR/genome_dir \
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
