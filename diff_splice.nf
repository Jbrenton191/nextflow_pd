nextflow.enable.dsl=2

process leafcutter_multi {

	input:
	val(ex_file)

	output:
	path("*.txt")

script:
"""
Rscript /home/jbrenton/RNAseqProcessing/analysis/leafcutter_ds_multi_pairwise.R \
/home/jbrenton/nextflow_test/output/leafcutter/leafcutter_perind_numers.counts.gz \
/home/jbrenton/nextflow_test \
--output_prefix=/home/jbrenton/nextflow_test/output/leafcutter/ \
--max_cluster_size=Inf \
--min_samples_per_intron=5 \
--min_samples_per_group=3 \
--min_coverage=20 \
--timeout=30 \
--num_threads=15 \
--exon_file=$ex_file
"""

}

workflow{
// WHERE UP TO (7.6.21): had problem with recognition of prefix in next stage of group file and leafcutter analysis, NM prefix messed things up, and making group file R script!

ex_file='/home/jbrenton/nextflow_test/output/leafcutter/Homo_sapiens.GRCh38.97_LC_exon_file.txt.gz'
leafcutter_multi(ex_file)
}
