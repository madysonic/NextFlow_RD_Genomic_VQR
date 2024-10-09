/*
 * Mark duplicates in BAM files
 */
process markDuplicates {

    label 'process_single'
    container 'variantvalidator/indexgenome:1.1.0'

    tag "$bamFile"

    // Publish deduplicated BAM files to the specified directory
    publishDir("$params.outdir/BAM", mode: "copy")

    input:
    tuple val(sample_id), file(bamFile)

    output:
    tuple val(sample_id), file("${bamFile.baseName}_dedup.bam")

    script:
    """
    echo "Running Mark Duplicates"

    outputBam="${bamFile.baseName}_dedup.bam"
    metricsFile="${bamFile.baseName}_dedup_metrics.txt"

    # Use Picard tools to mark duplicates in the input BAM file
    picard MarkDuplicates I=${bamFile} \\
                            O="\${outputBam}" \\
                            M="\${metricsFile}"

    echo "\${outputBam}"

    echo "Mark Duplicates Complete"
    """
}