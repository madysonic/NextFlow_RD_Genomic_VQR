/*
 * Run fastq on the read fastq files
 */
process readTrimming {

    label 'process_single'

    container 'staphb/trimmomatic'

    tag "$sample_id"

    publishDir("$params.outdir/trimmed_reads", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("trimmed_${sample_id}_R1.fastq.gz"), path("trimmed_${sample_id}_R2.fastq.gz")

    script:
    """
    echo "Running Trimmomatic on $sample_id"

    trimmomatic PE \\
        ${reads[0]} ${reads[1]} \\
        trimmed_${sample_id}_R1.fastq.gz unpaired_${sample_id}_R1.fastq.gz \\
        trimmed_${sample_id}_R2.fastq.gz unpaired_${sample_id}_R2.fastq.gz \\
        ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50

    echo "Trimmomatic Complete"
    """
}