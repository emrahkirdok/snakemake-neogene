#!/usr/bin/env bash
# Run aMeta with this profile and the tool paths from tools.sh.
# Call it from the aMeta directory; extra args go straight to snakemake:
#   /path/to/profiles/slurm-aMeta/run.sh -n          # dry run
#   /path/to/profiles/slurm-aMeta/run.sh             # real run
#   SNAKEMAKE_PYTHON=/opt/apps/python-3.10/bin/python run.sh   # pick the Python
set -euo pipefail
PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Module systems often reference unset variables, so relax -u while sourcing.
set +u
source "$PROFILE_DIR/tools.sh"
set -u

echo "Tools resolved on $(hostname):" >&2
for tool in bowtie2 krakenuniq malt-run mapDamage samtools; do
  printf '  %-12s %s\n' "$tool" "$(command -v "$tool" || echo 'NOT FOUND')" >&2
done

exec "${SNAKEMAKE_PYTHON:-python3}" -m snakemake --profile "$PROFILE_DIR" "$@"
