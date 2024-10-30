# qc-wf
QC workflow for Illumina reads
# Dependencies
1) Nexflow
2) Docker or Apptainer (Singularity)
# How to run
```
nextflow run qc-wf.nf \
    --reads1 /path/to/sample_R1_001.fastq.gz \
    --reads2 /path/to/sample_R2_001.fastq.gz \ 
    --outdir qc-wf_out \
    --samplename my_sample \
    -profile singularity
```
