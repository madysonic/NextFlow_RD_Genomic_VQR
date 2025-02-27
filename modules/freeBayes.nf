nextflow.enable.dsl = 2

process freeBayes {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'broadinstitute/freebayes:v1.3.1'

    tag "$bamFile"

    input:
    tuple val(sample_id), file(bamFile), file(bamIndex)
    path indexFiles

    output:
    tuple val(sample_id), file("*.vcf"), file("*.vcf.idx")

    script:
    """
    echo "Running FreeBayes for Sample: ${bamFile}"

    if [[ -n ${params.genome_file} ]]; then
        genomeFasta=\$(basename ${params.genome_file})
    else
        genomeFasta=\$(find -L . -name '*.fasta')
    fi

    echo "Genome File: \${genomeFasta}"

    # Rename the dictionary file to the expected name if it exists
    if [[ -e "\${genomeFasta}.dict" ]]; then
        mv "\${genomeFasta}.dict" "\${genomeFasta%.*}.dict"
    fi

    outputVcf="\$(basename ${bamFile} _sorted_dedup_recalibrated.bam).vcf"

    # Run FreeBayes to call variants
    freebayes -f \${genomeFasta} -b ${bamFile} --genotype-qualities --vcf \${outputVcf}

    echo "Sample: ${sample_id} VCF: \${outputVcf}"

    # Index the VCF file using bgzip and tabix
    bgzip \${outputVcf}
    tabix -p vcf \${outputVcf}.gz

    echo "Variant Calling for Sample: ${sample_id} Complete"
    """
}
