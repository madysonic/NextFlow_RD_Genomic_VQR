process alignReadsMinimap2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'niemasd/minimap2_samtools'  // Minimap2 with Samtools

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)   // reads is a tuple of paths for paired-end reads
    path requiredIndexFiles

    output:
    tuple val(sample_id), file("${sample_id}.bam")

    script:
    """
    # Identify the reference FASTA file
    INDEX=\$(find -L ./ -name "*.fasta" | head -n 1)

    echo "Running Align Reads with Minimap2"
    echo "Reference FASTA: \$INDEX"

    # Check if the input FASTQ files exist
    if [ -f "${reads[0]}" ]; then
        if [ -f "${reads[1]}" ]; then
            # Paired-end mode
            minimap2 -ax sr -t ${task.cpus} \$INDEX ${reads[0]} ${reads[1]} |
            samtools view -b - |
            samtools addreplacerg -r "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" - > ${sample_id}.bam
        else
            # Single FASTQ mode
            minimap2 -ax sr -t ${task.cpus} \$INDEX ${reads[0]} |
            samtools view -b - |
            samtools addreplacerg -r "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" - > ${sample_id}.bam
        fi
    else
        echo "Error: Read file ${reads[0]} does not exist for sample ${sample_id}."
        exit 1
    fi

    echo "Alignment complete"
    """
}