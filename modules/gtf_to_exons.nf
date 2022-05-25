process gtf_to_exons {

myDir = file("${params.output}/leafcutter")
myDir.mkdirs()

publishDir "${params.output}/leafcutter", mode: 'copy', overwrite: true

        input:
        path(gtf)

        output:
        path("*.txt.gz"), emit: exon_file

        script:
        """
        gzip -f $gtf
        Rscript ${projectDir}/R_scripts/gtf_to_exons.R \
        ${gtf}.gz \
        ${gtf.simpleName}_LC_exon_file.txt.gz
        """
}
