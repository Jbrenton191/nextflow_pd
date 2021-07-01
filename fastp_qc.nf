nextflow.enable.dsl=2


// fastas = Channel.fromPath( '/home/jbrenton/nextflow_test/files/*.fastq.gz' )

myDir = file('/home/jbrenton/nextflow_test/output')
myDir.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/fastp')
myDir2.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/fastqc')
myDir2.mkdir()

myDir3 = file('/home/jbrenton/nextflow_test/output/multiqc')
myDir3.mkdir()

workDir = '/home/jbrenton/nextflow_test/output'

process fastp {
    echo true
    publishDir '/home/jbrenton/nextflow_test/output/fastp', mode: 'copy', overwrite: true 

    input:
    tuple val(sampleID), path(reads)

    output:
 /*   path("$sampleID")
    path("${reads[0]}")
    path("${reads[1]}")
    */
    tuple val("${sampleID}"), path("*trimmed.fastq.gz"), emit: reads
    // val("${sampleID}"), emit: meta
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
    --thread 16
    """

}

process fastqc {

publishDir '/home/jbrenton/nextflow_test/output/fastqc', mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)


    output:
    tuple val("${sampleID}"), path("*fastqc.html"), emit: html
    tuple val("${sampleID}"), path("*fastqc.zip"), emit: zip
    val("${fqc_files}"), emit: fqc_files

    script:
    fqc_files='/home/jbrenton/nextflow_test/output/'
	"""
    fastqc $reads -t 20
    """
}

process multiqc {

publishDir '/home/jbrenton/nextflow_test/output/multiqc', mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(htmls)
    path(files)

    output:
	path('*')

	script:
    	"""
	multiqc $files -o . -n "multiqc_exp"
    	"""
}

workflow {
  //  data = '/home/jbrenton/nextflow_test/files'
 //   data.view()

    data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/files/*R{1,3}*.fastq.gz')
    data.view { "value: $it" }

// data2=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
// data2.view { "value: $it" }
    fastp(data)
    fastqc(fastp.out.reads)
//    fastqc(data2)
    fastqc.out.fqc_files.view() 
    multiqc(fastqc.out.html.collect(), fastqc.out.fqc_files)

//	x=channel.fromPath('/home/jbrenton/nextflow_test/output')
//	multiqc()
      }

