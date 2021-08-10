process multiqc_2nd_pass {

cache = 'lenient'

myDir3 = file("${baseDir}/output/multiqc")
myDir3.mkdir()

publishDir "${baseDir}/output/multiqc", mode: 'copy', overwrite: true

    input:
    path(files)
    val(file_dir)

    output:
    path("*")

    script:
      """
      multiqc $file_dir -n "multiqc_star_pass_2_and_qc" -o .
      """
}
