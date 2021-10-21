process gtf_to_exons {

myDir = file("${projectDir}/output/leafcutter")
myDir.mkdirs()

publishDir "${projectDir}/output/leafcutter", mode: 'copy', overwrite: true

        input:
        path(gtf)

        output:
        path("*.txt.gz"), emit: exon_file

        script:
        """
        gzip -f $gtf
        Rscript ${projectDir}/gtf_to_exons.R \
        ${gtf}.gz \
        ${gtf.simpleName}_LC_exon_file.txt.gz
        """
}