process rseqc {
echo true

conda 'python=2.7 rseqc'

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

input:
path(bed_model)
path(bams)
val(bam_dir)
path(bams_indexes)

output:
path("*")

// change read length as go!!! Can change to 150
// read_length=100
//echo "Have you changed the read length parameter in this file? It's currently set to \$read_length"
// mismatch_profile.py -i $bams -l \$read_length -o $sample_name

// sample_name=bams.simpleName
script:
sample_name=bams.simpleName
read_length=100

// geneBody_coverage.py -r $bed_model -i $bam_dir -o all_files_
"""

clipping_profile.py -i $bams -s "PE" -o $sample_name

inner_distance.py -i $bams -r $bed_model -o $sample_name

junction_annotation.py -i $bams -r $bed_model -m 20 -o $sample_name

junction_saturation.py -i $bams -r $bed_model -m 20 -o $sample_name

mismatch_profile.py -i $bams -l $read_length -o $sample_name

read_distribution.py -i $bams -r $bed_model > ${sample_name}_read_distribution.txt

read_duplication.py -i $bams -u 20000 -o $sample_name

read_GC.py -i $bams -o $sample_name

RNA_fragment_size.py -i $bams -r $bed_model > ${sample_name}_RNA_fragment_size.txt

bam_stat.py -i $bams > ${sample_name}_bam_stat.txt
"""
}
