nextflow.enable.dsl=2

process bam_2_bigwig {
echo true

input:
path(bam)

output:
// path("*.bw")
stdout

script:
name=bam.simpleName
"""
name2=`echo $name | awk -F "_" '{print \$2}'`
echo \$name2
megadepth $bam --prefix \$name2 --bigwig
"""
}
workflow {
   data=Channel.fromPath("${projectDir}/../bam_dir/*.bam")
   x=data.take(3)
   bam_2_bigwig(x)
}
