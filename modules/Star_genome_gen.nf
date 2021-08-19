process Star_genome_gen {

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
