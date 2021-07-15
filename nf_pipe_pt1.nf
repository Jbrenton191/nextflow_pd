nextflow.enable.dsl=2

myDir = file("${baseDir}/output")
myDir.mkdir()

workDir = "${baseDir}"

cache = 'lenient'

process get_packages {
cache = 'lenient'

	publishDir "${baseDir}", mode: 'copy', overwrite: true

	output:
	stdout

	script:
	"""
	Rscript $baseDir/Rpackage_download.R
	git clone https://github.com/RHReynolds/RNAseqProcessing.git
	"""
// also assumes you have git in command line!
// add in (also move yml file into folder): conda env create -f nextflow_env.yml -n nf_env
}

process fastp {
  myDir2 = file("${baseDir}/output/fastp")
  myDir2.mkdir()

cache = 'lenient'

    echo true
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

process fastqc {

cache = 'lenient'

myDir2 = file("${baseDir}/output/fastqc")
myDir2.mkdir()

publishDir "${baseDir}/output/fastqc", mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)

    output:
    path("*fastqc.html"), emit: html
    tuple val("${sampleID}"), path("*fastqc.zip"), emit: zip
    val("${fqc_files}"), emit: fqc_files

    script:
    fqc_files="${baseDir}/output"
    """
    fastqc $reads -t 20
    """
}

process multiqc {

cache = 'lenient'

myDir3 = file("${baseDir}/output/multiqc")
myDir3.mkdir()

publishDir "${baseDir}/output/multiqc", mode: 'copy', overwrite: true

    input:
    path(htmls)
    val(files)

    output:
    path("*")

    script:
      """
      multiqc $files -n "multiqc_exp" -o .
      """
}

process genome_download {

cache = 'lenient'

myDir3 = file("${baseDir}/output/reference_downloads")
myDir3.mkdir()

publishDir "${baseDir}/output/reference_downloads", mode: 'move', overwrite: true

	output:
	path("*.fa"), emit: fasta
	path("*.gtf"), emit: gtf	
	
	script:
	"""
	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.chr_patch_hapl_scaff.annotation.gtf.gz
	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/GRCh38.p13.genome.fa.gz

	gunzip GRCh38.p13.genome.fa.gz
	gunzip gencode.v38.chr_patch_hapl_scaff.annotation.gtf.gz
	"""
}
process STAR_genome_gen {

cache = 'lenient'

myDir = file("${baseDir}/output/STAR")
myDir.mkdir()

myDir2 = file("${baseDir}/output/STAR/genome_dir")
myDir2.mkdir()

publishDir "${baseDir}/output/STAR/genome_dir", mode: 'copy', overwrite: true

    input:
    path(fasta)
    path(gtf)
    
    output:
    val("${gdir_val}"), emit: gdir_val

    script:
    gdir_val=file("${baseDir}/output/STAR/genome_dir")
    ref_dir="${baseDir}/output/reference_downloads"
    """

STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir $gdir_val \
--genomeFastaFiles $ref_dir/$fasta \
--sjdbGTFfile $ref_dir/$gtf \
--sjdbOverhang 99
  """
}

process STAR_pass1_post_genome_gen {

cache = 'lenient'

myDir2 = file("${baseDir}/output/STAR/align")
myDir2.mkdir()

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

  input:
  tuple val(sampleID), path(reads)
  val(genome_dir)

  output:
  path('*SJ.out.tab'), emit: sj_tabs
  val(sj_loc), emit: sj_loc

  script:
  sj_loc="${baseDir}/output/STAR/align"
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


process STAR_1 {

cache = 'lenient'

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
  path("*SJ.out.tab"), emit: sj_tabs
  val(sj_loc), emit: sj_loc

  script:
  sj_loc="${baseDir}/output/STAR/align"
  """
  echo ${sampleID}
  echo ${reads[0]}
  echo ${reads[1]}

  STAR --runThreadN 25 \
  --genomeDir ${baseDir}/output/genome_dir \
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

process STAR_merge {

cache = 'lenient'

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

// storeDir "/home/jbrenton/nextflow_test/output/STAR/align"

echo true

    input:
    val(sj_loc)
    path(sj_tabs)

    output:
    path("*SJ.out.tab"), emit: merged_tab

    script:
    """
    Rscript ${baseDir}/STAR_splice_junction_merge.R $sj_loc -o .
    """

}

process STAR_pass2 {

cache = 'lenient'

publishDir "${baseDir}/output/STAR/align", mode: 'copy', overwrite: true

storeDir "${baseDir}/output/STAR/align"
    echo true

    input:
    tuple val(sampleID), path(reads)
    path(merged_tab)

    output:
    tuple val(sampleID), path("*SJ.out.tab"), emit: sj_tabs2
    stdout emit: all_out

   script:
      """
  limits=`sh ${baseDir}/sj_length.sh $merged_tab`

  echo \$limits

  STAR --runThreadN 15 \
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

workflow {
   get_packages()
   data=Channel.fromFilePairs("${baseDir}/../Regina_file_deposit/*R{1,3}*.fastq.gz")
	fastp(data)
	fastqc(fastp.out.reads)
             multiqc(fastqc.out.html.collect().flatten().unique().first().collect(), fastqc.out.fqc_files)

		genome_download()
//		STAR_genome_gen(genome_download.out.fasta, genome_download.out.gtf) 

 //		STAR_pass1_post_genome_gen(fastp.out.reads, STAR_genome_gen.out.gdir_val)

// need to collect below as after first instance passes the sj_loc would go ahead before all are done
//			STAR_merge(STAR_pass1_post_genome_gen.out.sj_loc, STAR_pass1_post_genome_gen.out.sj_tabs.collect().flatten().unique().first().collect())

//				STAR_pass2(fastp.out.reads, STAR_merge.out.merged_tab)
}
