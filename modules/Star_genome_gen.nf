process Star_genome_gen {

myDir2 = file("${params.output}/STAR/genome_dir")
myDir2.mkdirs()

publishDir "${params.output}/STAR/genome_dir", mode: 'copy', overwrite: true

    input:
    path(fasta)
    path(gtf)

    output:
    val(gdir), emit: gdir

  script:
  gdir="${params.output}/STAR/genome_dir"
//    ref_dir="${baseDir}/output/reference_downloads"
    """
STAR --runThreadN 25 \
--runMode genomeGenerate \
--genomeDir $gdir \
--genomeFastaFiles $fasta \
--sjdbGTFfile $gtf \
--sjdbOverhang 99
  """
}