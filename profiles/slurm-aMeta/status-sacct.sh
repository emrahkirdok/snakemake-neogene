#!/usr/bin/env bash
# Snakemake 7 --cluster-status hook for SLURM.
# Called as: status-sacct.sh <slurm_job_id>
# Must print exactly one of: success | failed | running

jobid="$1"

# sacct is authoritative, but the accounting DB can lag a few seconds right
# after submission, so fall back to scontrol (which only knows live jobs).
status=$(sacct -j "$jobid" --format=State --noheader --parsable2 2>/dev/null \
         | head -n 1 | sed 's/ .*//')

if [ -z "$status" ]; then
  status=$(scontrol show job "$jobid" 2>/dev/null \
           | tr ' ' '\n' | grep '^JobState=' | cut -d= -f2)
fi

case "$status" in
  COMPLETED)
    echo "success"
    ;;
  BOOT_FAIL|CANCELLED|DEADLINE|FAILED|NODE_FAIL|OUT_OF_MEMORY|PREEMPTED|REVOKED|TIMEOUT)
    echo "failed"
    ;;
  *)
    # PENDING, RUNNING, COMPLETING, CONFIGURING, or not visible yet.
    echo "running"
    ;;
esac
