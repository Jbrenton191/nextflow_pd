process STAR_pass2 {

publishDir "${params.output}/STAR/align", mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)
    path(merged_tab)

    output:
  	path("*SJ.out.tab"), emit: sj_tabs2
  	//val(sj_loc), emit: sj_loc
        path('*BAM_Aligned.sortedByCoord.out.bam'), emit: bams

        tuple val(sampleID), path('*sortedByCoord.out.bam'), optional:true, emit: bam_sorted
        tuple val(sampleID), path('*toTranscriptome.out.bam'), optional:true, emit: bam_transcript
        tuple val(sampleID), path('*Aligned.unsort.out.bam'), optional:true, emit: bam_unsorted

        tuple val(sampleID), path('*Log.final.out'), emit: log_final
        tuple val(sampleID), path('*Log.out'), emit: log_out
        tuple val(sampleID), path('*Log.progress.out'), emit: log_progress

script:
// sj_loc="${params.output}/STAR/align"
"""
limits=`sh ${projectDir}/sj_length.sh $merged_tab`

STAR --runThreadN 25 \
--genomeDir ${params.output}/STAR/genome_dir \
--readFilesIn  ${reads[0]}, ${reads[1]} \
--readFilesCommand zcat \
--outFileNamePrefix ${sampleID}_mapped_post_merge.BAM_ \
--outReadsUnmapped Fastx \
--outSAMtype BAM SortedByCoordinate \
--outFilterType BySJout \
--outFilterMultimapNmax 1 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 25 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 3 \
--sjdbFileChrStartEnd $merged_tab \
--limitSjdbInsertNsj \$limits
"""
}
