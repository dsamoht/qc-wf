process REMOVE_SYNTHETIC_CONTAMINANTS {
	
    if (workflow.containerEngine == 'singularity') {
        container params.singularity_container_bbmap
    } else {
        container params.docker_container_bbmap
    }

	input:
	tuple file(artefacts), file(phix174ill), val(name), file(reads) 
   
	output:
	tuple val(name), path("${name}_no_synthetic_contaminants*.fastq.gz"), emit: to_trim

   	script:
	def input = "in1=\"${reads[0]}\" in2=\"${reads[1]}\""
	def output = "out=\"${name}_no_synthetic_contaminants_R1.fastq.gz\" out2=\"${name}_no_synthetic_contaminants_R2.fastq.gz\""
	"""
	bbduk.sh $input $output k=31 ref=$phix174ill,$artefacts qin=$params.qin threads=${task.cpus} ow &> synthetic_contaminants_out.log
	"""
}

/**
	Quality control - STEP 3. Trimming of low quality bases and of adapter sequences. 
	Short reads are discarded. 
	
	If dealing with paired-end reads, when either forward or reverse of a paired-read
	are discarded, the surviving read is saved on a file of singleton reads.
*/

process TRIM {
	
    if (workflow.containerEngine == 'singularity') {
        container params.singularity_container_bbmap
    } else {
        container params.docker_container_bbmap
    }

	publishDir "${params.outdir}/${params.samplename}/trimmed", mode: 'copy'
	
	input:
	tuple file(adapters), val(name), file(reads)
	
	output:
	tuple val(name), path("${name}_trimmed*.fastq.gz"), emit: to_decontaminate

   	script:
	def input = "in1=\"${reads[0]}\" in2=\"${reads[1]}\""
	def output = "out=\"${name}_trimmed_R1.fastq.gz\" out2=\"${name}_trimmed_R2.fastq.gz\" outs=\"${name}_trimmed_singletons.fastq.gz\""
	"""
	bbduk.sh $input $output ktrim=r k=$params.kcontaminants mink=$params.mink hdist=$params.hdist qtrim=rl trimq=$params.phred  minlength=$params.minlength ref=$adapters qin=$params.qin threads=${task.cpus} tbo tpe ow &> trimming_out.log
	"""
}