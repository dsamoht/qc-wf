nextflow.enable.dsl = 2

include { REMOVE_SYNTHETIC_CONTAMINANTS; TRIM } from './modules/quality_control'


def helpMessage() 
{
	log.info"""

  Usage: 
  nextflow run qc-wf.nf profile singularity,base --reads1 R1 --reads2 R2 --samplename samplename --outdir path [options]
  
  Mandatory arguments:
    --reads1       R1          Forward reads file path
    --reads2       R2          Reverse reads file path
    --samplename   samplename  Prefix used to name the result files
    --outdir       path        Output directory (will be outdir/samplename/)
  
  Other options:
  BBduk parameters for removing synthetic contaminants and trimming:
    --qin                 <33|64> Input quality offset 
    --kcontaminants       value   kmer length used for identifying contaminants
    --phred               value   regions with average quality BELOW this will be trimmed 
    --minlength           value   reads shorter than this after trimming will be discarded
    --mink                value   shorter kmer at read tips to look for 
    --hdist               value   maximum Hamming distance for ref kmer
    --artefacts           path    FASTA file with artefacts
    --phix174ill          path    FASTA file with phix174_ill
    --adapters            path    FASTA file with adapters         
"""
}


if (params.help) {
	helpMessage()
	exit 0
}

if (params.qin != 33 && params.qin != 64) {  
	exit 1, "Input quality offset (qin) not available. Choose either 33 (ASCII+33) or 64 (ASCII+64)" 
}

if ( !params.reads1) {
    log.info "Error: reads1 not specified."
    exit 1
}

if ( !params.reads2) {
    log.info "Error: reads2 not specified."
    exit 1
}

if ( !params.samplename) {
    log.info "Error: samplename not specified."
    exit 1
}

if ( !params.outdir) {
    log.info "Error: outdir not specified."
    exit 1
}

workflow { 
	
	// Define inputs
	Channel.from([[params.samplename, [file(params.reads1), file(params.reads2)]]] ).set{ read_files }

	// Throw the reads into a channel
	to_synthetic_contaminants = read_files
	
	// Defines channels for resources file 
	Channel.fromPath( "${params.artefacts}", checkIfExists: true ).set { artefacts }
	Channel.fromPath( "${params.phix174ill}", checkIfExists: true ).set { phix174ill }
	
	// Remove synthetic contaminants
	REMOVE_SYNTHETIC_CONTAMINANTS(artefacts.combine(phix174ill).combine(to_synthetic_contaminants))

	Channel.fromPath( "${params.adapters}", checkIfExists: true ).set { adapters }

	// Quality and adapter trimming
	TRIM(adapters.combine(REMOVE_SYNTHETIC_CONTAMINANTS.out.to_trim))

}