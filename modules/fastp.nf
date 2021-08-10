process fastp {
  myDir2 = file("${baseDir}/output/fastp")
  myDir2.mkdir()

    publishDir "${baseDir}/output/fastp", mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)

    output:
    tuple val("${sampleID}"), path("*trimmed.fastq.gz"), emit: reads
    tuple val("${sampleID}"), path("*.html"), emit: html
    tuple val("${sampleID}"), path("*.zip") , emit: zip optional true
    tuple val("${sampleID}"), path("*.json") , emit: json optional true

    script:
    """
    echo 'base dir is ${baseDir}'
    echo 'working dir is ${workflow.projectDir}'
    echo 'launch dir is ${workflow.launchDir}'
    echo '$reads'
    echo '${sampleID}'
    echo '${reads[0]}'
    echo '${reads[1]}'

    fastp --in1 ${reads[0]} \
    --out1 ${sampleID}_1_trimmed.fastq.gz \
    --in2 ${reads[1]} \
    --out2 ${sampleID}_2_trimmed.fastq.gz \
    --detect_adapter_for_pe \
    --qualified_quality_phred 15 \
    --unqualified_percent_limit 40 \
    --n_base_limit 5 \
    --length_required 36 \
    --correction \
    --overlap_len_require 30 \
    --overlap_diff_limit 5 \
    --overrepresentation_analysis \
    --overrepresentation_sampling 20 \
    --html ${sampleID}_fastp.html \
    --json ${sampleID}_fastp.json \
    --report_title '${sampleID}' \
    --thread 20
    """

}