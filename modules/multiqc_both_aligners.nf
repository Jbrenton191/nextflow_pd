process multiqc_post_star_salmon {

cache = 'lenient'

myDir3 = file("${baseDir}/output/multiqc")
myDir3.mkdir()

publishDir "${baseDir}/output/multiqc", mode: 'copy', overwrite: true

    input:
    path(salmon_files)
    path(star_files)
    val(file_dir)

    output:
    path("*")

    script:
      """
      multiqc $file_dir -n "multiqc_post_star_salmon" -o .
      """
}
