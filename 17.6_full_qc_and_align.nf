nextflow.enable.dsl=2

myDir = file('/home/jbrenton/nextflow_test/output')
myDir.mkdir()

workDir = '/home/jbrenton/nextflow_test/output'

process fastp {
  myDir2 = file('/home/jbrenton/nextflow_test/output/fastp')
  myDir2.mkdir()

    echo true
    publishDir '/home/jbrenton/nextflow_test/output/fastp', mode: 'copy', overwrite: true

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
    --thread 16
    """

}

process fastqc {

myDir2 = file('/home/jbrenton/nextflow_test/output/fastqc')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/fastqc', mode: 'copy', overwrite: true

    input:
    tuple val(sampleID), path(reads)

    output:
    path("*fastqc.html"), emit: html
    tuple val("${sampleID}"), path("*fastqc.zip"), emit: zip
    val("${fqc_files}"), emit: fqc_files

    script:
    fqc_files='/home/jbrenton/nextflow_test/output/'
    """
    fastqc $reads -t 20
    """
}

process multiqc {

myDir3 = file('/home/jbrenton/nextflow_test/output/multiqc')
myDir3.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/multiqc', mode: 'copy', overwrite: true

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

process STAR_genome_gen {

publishDir '/home/jbrenton/nextflow_test/output/STAR/genome_dir', mode: 'copy', overwrite: true

// storeDir '/home/jbrenton/nextflow_test/output/STAR/genome_dir'

myDir = file('/home/jbrenton/nextflow_test/output/STAR')
myDir.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
myDir2.mkdir()

    output:
//    path("*.tab"), emit: stdout_genome_gen
    val("${gdir_val}"), emit: gdir_val
//    path("*"), emit: full_stdout_genome_gen	

    script:
    gdir_val=file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
    """
cp /data/references/fasta/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa /home/jbrenton/nextflow_test/output/STAR/genome_dir
cp /data/references/ensembl/gtf_gff3/v97/Homo_sapiens.GRCh38.97.gtf /home/jbrenton/nextflow_test/output/STAR/genome_dir

STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir $gdir_val \
--genomeFastaFiles /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.dna.primary_assembly.fa \
--sjdbGTFfile /home/jbrenton/nextflow_test/output/STAR/genome_dir/Homo_sapiens.GRCh38.97.gtf \
--sjdbOverhang 99
  """
}

process STAR_pass1_post_genome_gen {

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/align')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/STAR/align', mode: 'copy', overwrite: true

  input:
  tuple val(sampleID), path(reads)
//  path(gg_stdout)
  val(genome_dir)

  output:
  path('*SJ.out.tab'), emit: sj_tabs
  val(sj_loc), emit: sj_loc

  script:
  sj_loc='/home/jbrenton/nextflow_test/output/STAR/align'
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

myDir = file('/home/jbrenton/nextflow_test/output/STAR')
myDir.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/genome_dir')
myDir2.mkdir()

myDir2 = file('/home/jbrenton/nextflow_test/output/STAR/align')
myDir2.mkdir()

publishDir '/home/jbrenton/nextflow_test/output/STAR/align', mode: 'copy', overwrite: true

storeDir '/home/jbrenton/nextflow_test/output/STAR/align'
echo true

  input:
  tuple val(sampleID), path(reads)

  output:
  path('*SJ.out.tab'), emit: sj_tabs
  val(sj_loc), emit: sj_loc

  script:
  sj_loc='/home/jbrenton/nextflow_test/output/STAR/align'
  """
  echo ${sampleID}
  echo ${reads[0]}
  echo ${reads[1]}

  STAR --runThreadN 25 \
  --genomeDir /home/jbrenton/nextflow_test/output/STAR/genome_dir \
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

process STAR_merge {

publishDir '/home/jbrenton/nextflow_test/output/STAR/align', mode: 'copy', overwrite: true

// storeDir '/home/jbrenton/nextflow_test/output/STAR/align'

echo true

    input:
    val(sj_loc)
    path(sj_tabs)

    output:
    path('*SJ.out.tab'), emit: merged_tab

    script:
    """
    Rscript /home/jbrenton/RNAseqProcessing/alignment/STAR_splice_junction_merge.R $sj_loc -o .
    """

}

process STAR_pass2 {

publishDir '/home/jbrenton/nextflow_test/output/STAR/align', mode: 'copy', overwrite: true

storeDir '/home/jbrenton/nextflow_test/output/STAR/align'
    echo true

    input:
    tuple val(sampleID), path(reads)
    path(merged_tab)

    output:
    tuple val(sampleID), path('*SJ.out.tab'), emit: sj_tabs2
    stdout emit: all_out

   script:
      """
  limits=`sh /home/jbrenton/nextflow_test/sj_length.sh $merged_tab`

  echo \$limits

  STAR --runThreadN 15 \
  --genomeDir /home/jbrenton/nextflow_test/output/STAR/genome_dir \
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
  --alignSJDBoverhangMin 3 \
  --sjdbFileChrStartEnd $merged_tab \
  --limitSjdbInsertNsj \$limits
  """
}

workflow {
  data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/files/*R{1,3}*.fastq.gz')
// data=Channel.fromFilePairs('/home/jbrenton/nextflow_test/output/fastp/*{1,2}*.fastq.gz')
// data2.view { "value: $it" }
     fastp(data)
	fastqc(fastp.out.reads)
           multiqc(fastqc.out.html.collect().flatten().unique().first().collect(), fastqc.out.fqc_files)

//  		STAR_genome_gen() 

// y=STAR_genome_gen.out.stdout_genome_gen.collect().flatten().first().collect()
   		STAR_pass1_post_genome_gen(fastp.out.reads, STAR_genome_gen.out.gdir_val)

//	STAR_pass1_post_genome_gen(data, y, STAR_genome_gen.out.gdir_val)
//  STAR_pass1_post_genome_gen(data, STAR_genome_gen.out.stdout_genome_gen.collect().flatten().first().collect(), STAR_genome_gen.out.gdir_val)

// need to collect below as after first instance passes the sj_loc would go ahead before all are done
			STAR_merge(STAR_pass1_post_genome_gen.out.sj_loc, STAR_pass1_post_genome_gen.out.sj_tabs.collect().flatten().unique().first().collect())

// data=Channel.fromPath('/home/jbrenton/nextflow_test/output/STAR/align/*.tab')
// data.view()
// sj_loc='/home/jbrenton/nextflow_test/output/STAR/align'
// STAR_merge(sj_loc, data.collect())



//        STAR_1(fastp.out.reads)
//	  data.view()
//	  STAR_1(data)
//          x=STAR_1.out.sj_tabs.collect().flatten().unique().first().collect()
//	  x.view {"flatten sj out: $it"}
//	  STAR_1.out.sj_loc.view{"sj loc: $it"}
//          STAR_merge(STAR_1.out.sj_loc, x)
	
 				STAR_pass2(fastp.out.reads, STAR_merge.out.merged_tab)
      }

