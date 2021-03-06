#!/bin/bash
#
# Add the time and date onto reports and timeline names

nf_pipeline=$1

## Get current date ##
_date=$(date +"%m_%d_%Y")
_time=$(date +"%H:%M:%S")
## Appending a current date from a $_now to a filename stored in $_file ##
timing="${_date}-${_time}"

## Run nextflow in background with dated timeline and report ##
nextflow run $nf_pipeline -bg -with-timeline ${nf_pipeline}_timeline_${timing}.html -with-report ${nf_pipeline}_report_${timing}.html --data "/home/jbrenton/nextflow_test/files/*R{1,3}*.fastq.gz" 
