# snakemake-neogene — SLURM smoke test

A throwaway pipeline that creates dummy files, built to verify that
Snakemake **7.32.4** can submit to and collect results from SLURM.

```
Snakefile                       2 rules: fan-out (4 jobs) -> fan-in (1 job)
config/config.yaml              sample list + sleep duration
profiles/slurm/config.yaml      the sbatch submit command  <-- EDIT THIS
profiles/slurm/status-sacct.sh  tells Snakemake if a job succeeded/failed
run_cluster.sh                  convenience wrapper
```

Each dummy job records `hostname`, `SLURM_JOB_PARTITION` and
`SLURM_JOB_NODELIST` into its output file, so `results/summary.txt` is direct
proof of which nodes the work actually landed on.

## About `-p`

These are two different things and it matters here:

| Flag | Belongs to | Means |
|---|---|---|
| `-p` | **Snakemake** | `--printshellcmds` (already on in the profile) |
| `-p` | **sbatch** | `--partition` |

You cannot pass a partition to Snakemake with `-p`. The partition is set in
`profiles/slurm/config.yaml` under `default-resources`, and reaches sbatch via
`--partition={resources.slurm_partition}` in the `cluster:` command.

## Setup (one time, on the cluster)

1. Copy this directory to a path on the **shared** filesystem — one visible
   from both the login node and the compute nodes (`/scratch`, `/work`, your
   group share). A home dir that isn't mounted on the nodes will fail.

2. Set your partition in `profiles/slurm/config.yaml`:

   ```yaml
   default-resources:
     - slurm_partition="short"     # <-- replace CHANGE_ME
   ```

   List what's available with `sinfo -s`.

3. If your site requires an account/project code, add it as an extra indented
   line inside the `cluster:` block:

   ```yaml
       --account=your_project_code
   ```

   Check with `sacctmgr -nP show assoc user=$USER format=account,partition,qos`.
   Skip this entirely if your site doesn't use accounts — an empty
   `--account=` will make every submission fail.

4. Make sure the status script is executable (it should already be):

   ```bash
   chmod +x profiles/slurm/status-sacct.sh
   ```

## Run it

Dry run first — this needs no SLURM at all and catches syntax errors:

```bash
snakemake -n --profile profiles/slurm
```

Then submit for real:

```bash
snakemake --profile profiles/slurm
```

Watch the queue from a second shell:

```bash
watch -n 5 squeue -u $USER
```

You should see 4 `smk.make_dummy.*` jobs, then a single `smk.summarize.*`
once they've all finished.

## Check the result

```bash
cat results/summary.txt
```

Every block should show a real compute node in `hostname` / `nodelist` and
your chosen partition — that's the test passing.

## Trying a different partition without editing files

`--default-resources` on the command line overrides the profile. Note the
double quoting — Snakemake evaluates these as Python expressions, so the
string needs quotes that survive the shell:

```bash
snakemake --profile profiles/slurm --default-resources slurm_partition="'debug'" mem_mb=1000 runtime=10
```

To rerun from scratch after changing something:

```bash
snakemake --profile profiles/slurm --forceall
```

## Pinning to one specific node

Add to the `cluster:` block in the profile:

```yaml
    --nodelist={resources.nodelist}
```

and a matching default:

```yaml
  - nodelist="node042"
```

Beware: if that node is busy or drained, your jobs sit in `PENDING` forever.

## If something goes wrong

- **Jobs rejected instantly** — read `logs/slurm/*.err`. Usually a bad
  partition name, a missing `--account`, or requesting more mem/time than the
  partition permits.
- **Snakemake hangs after jobs finish** — the `cluster-status` script isn't
  running. Confirm it's executable and that `sacct` works for you:
  `sacct -j <jobid> --format=State --noheader --parsable2`. Some sites don't
  run the accounting DB, in which case the `scontrol` fallback carries it.
- **"Missing files after N seconds"** — filesystem lag. Raise `latency-wait`
  in the profile.
- **`.snakemake` lock left behind** after a killed run:
  `snakemake --profile profiles/slurm --unlock`.
