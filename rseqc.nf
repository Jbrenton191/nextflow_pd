nextflow.enable.dsl=2
myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdir()

process sam_sort_index {
echo true

publishDir "${projectDir}/output/Samtools_Rseqc", mode: 'copy', overwrite: true

input:
path(data)

output:
path("*.bai"), emit: bam_indexes
path("*.bam"), emit: sorted_bams

script:
"""
name=`echo "$data" | sed 's/_mapped.*//g'`
samtools sort -m 1000000000 $data -o ./\${name}_Aligned.sortedBysamtools.out.bam

samtools index ./\${name}_Aligned.sortedBysamtools.out.bam
"""
}

myDir = file("${projectDir}/output/Samtools_Rseqc")
myDir.mkdir()

process rseqc {
echo true

conda 'python=2.7'

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

bam_stat.py -i $bams > ${sample_name}_bam_stat.txt

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

workflow {
// data = channel.fromPath("${projectDir}/../bam_dir/*.bam")
   data = channel.fromPath("${projectDir}/output/STAR/align/*.bam")

   sam_sort_index(data)

// data = channel.fromPath("${projectDir}/output/Samtools_Rseqc/*.bai")
// data.view { "data name: $it" }
   bed_model=channel.fromPath("${projectDir}/output/Samtools_Rseqc/gencode.v38.chr_patch_hapl_scaff.annotation.bed")

// bed_model=channel.fromPath("${projectDir}/output/Samtools_Rseqc/Homo_sapiens.GRCh38.97.bed")
// bam_dir=sam_sort_index.out.bam_indexes.first().parent 
   bam_dir="${projectDir}/output/Samtools_Rseqc"
// sam_sort_index.out.sample_name.simpleName.view { "output name: $it" }
// sam_sort_index.out.bam_indexes.simpleName.view { "output name: $it" }

// data.getName.view { "getName: $it" }


rseqc(bed_model, sam_sort_index.out.sorted_bams, bam_dir, sam_sort_index.out.bam_indexes.collect())

// rseqc(bed_model, sam_sort_index.out.sample_name, sam_sort_index.out.bam_indexes.collect(), bam_dir)
// rseqc(bed_model, data, data.first().parent)
}
