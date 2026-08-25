# ---------------------------------------------------------------------------
# Minimal dummy pipeline to smoke-test Snakemake 7.32.4 + SLURM.
#
#   make_dummy   fan-out: one SLURM job per sample, each writes a dummy file
#                that records WHICH node/partition it actually ran on.
#   summarize    fan-in: one job that concatenates them.
#
# Nothing here does real work -- it just sleeps so the jobs stay visible in
# `squeue` long enough for you to inspect them.
# ---------------------------------------------------------------------------

configfile: "config/config.yaml"

SAMPLES = config["samples"]


rule all:
    input:
        "results/summary.txt",


rule make_dummy:
    output:
        "results/dummy/{sample}.txt",
    log:
        "logs/make_dummy/{sample}.log",
    params:
        sleep=config["sleep_seconds"],
    threads: 1
    resources:
        mem_mb=500,
        runtime=5,
        # To send THIS rule to a different partition than the profile default,
        # uncomment and set it -- this overrides profiles/slurm/config.yaml:
        # slurm_partition="bigmem",
    shell:
        r"""
        {{
          echo "sample     : {wildcards.sample}"
          echo "hostname   : $(hostname)"
          echo "job id     : ${{SLURM_JOB_ID:-<not-slurm>}}"
          echo "partition  : ${{SLURM_JOB_PARTITION:-<not-slurm>}}"
          echo "nodelist   : ${{SLURM_JOB_NODELIST:-<not-slurm>}}"
          echo "cpus       : ${{SLURM_CPUS_PER_TASK:-{threads}}}"
          echo "mem_mb req : {resources.mem_mb}"
          echo "started    : $(date "+%Y-%m-%dT%H:%M:%S%z")"
          sleep {params.sleep}
          echo "finished   : $(date "+%Y-%m-%dT%H:%M:%S%z")"
        }} > {output} 2> {log}
        """


rule summarize:
    input:
        expand("results/dummy/{sample}.txt", sample=SAMPLES),
    output:
        "results/summary.txt",
    log:
        "logs/summarize/summarize.log",
    threads: 1
    resources:
        mem_mb=500,
        runtime=5,
    shell:
        r"""
        {{
          echo "=== summary written by $(hostname) at $(date "+%Y-%m-%dT%H:%M:%S%z") ==="
          echo
          for f in {input}; do
            echo "--- $f ---"
            cat "$f"
            echo
          done
        }} > {output} 2> {log}
        """
