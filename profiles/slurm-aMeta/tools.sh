# ---------------------------------------------------------------------------
# Where aMeta's programs live on our cluster. EDIT THIS FILE.
#
# Sourced by run.sh before Snakemake starts. sbatch is called with
# --export=ALL (see config.yaml), so every SLURM job inherits exactly this
# environment -- no conda, no changes to the aMeta code.
#
# Paths must be on a filesystem the compute nodes can see.
# ---------------------------------------------------------------------------

# --- Option A: the cluster's module system ---------------------------------
# module load bowtie2/2.5.1
# module load samtools/1.17

# --- Option B: plain install directories, added to the front of PATH -------
# One line per tool directory (the folder that contains the executable).
export PATH="/usr/local/sw/FastQC/:$PATH"
export PATH="/usr/local/sw/bowtie2-2.5.1/$PATH"
export PATH="/usr/local/sw/krakenuniq-1.0.4/:$PATH"
#export PATH="/usr/local/sw/PMDtools/pmdtools.0.60.py:$PATH"
# export PATH="/opt/apps/krakenuniq-1.0.4/bin:$PATH"
# export PATH="/opt/apps/malt-0.62:$PATH"
# export PATH="/opt/apps/mapdamage-2.2.1/bin:$PATH"

# --- Python packages (pandas etc.) that are not in the default Python ------
# Point at the site-packages folder that contains pandas/, or at a Python
# that already has it (then also set SNAKEMAKE_PYTHON in run.sh's env).
# export PYTHONPATH="/opt/apps/python-libs/lib/python3.10/site-packages:${PYTHONPATH:-}"

# --- Shared libraries some tools need at runtime ---------------------------
# export LD_LIBRARY_PATH="/opt/apps/htslib-1.17/lib:${LD_LIBRARY_PATH:-}"
