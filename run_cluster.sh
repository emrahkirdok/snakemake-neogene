#!/usr/bin/env bash
# Submit the pipeline to SLURM. Any extra args are passed through to snakemake.
#   ./run_cluster.sh                        # normal run
#   ./run_cluster.sh -n                     # dry run
#   ./run_cluster.sh --default-resources slurm_partition="'debug'" mem_mb=1000 runtime=10
set -euo pipefail
cd "$(dirname "$0")"
exec snakemake --profile profiles/slurm "$@"
