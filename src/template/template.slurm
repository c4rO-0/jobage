#!/bin/bash -l

#|=======================================
#| set output and error file name
#| if not set, slurm will generate files 
#| with name stdout and stderr.
#|---------------------------------------
#+ #SBATCH -o output.%j
#+ #SBATCH -e error.%j

#|=======================================
#| name of the job
#|---------------------------------------
#SBATCH -J jbg_temp

#|=======================================
#| execute job from the current working directory
#| this is default slurm behavior
#|---------------------------------------
#SBATCH -D ./

#|=======================================
#| send mail
#| send when job done
#|---------------------------------------
#+ #SBATCH --mail-type=end
#+ #SBATCH --mail-user=YOUR_NAME@YOUR_MAIL_SERVER

#|=======================================
#| specify your job requires
#|---------------------------------------
#|- nodes you required
#SBATCH --nodes=1
#|- tasks on each node, it depends on the cluster
#|- use 'sinfo --Node --long' to know how many cores per node
#SBATCH --ntasks-per-node=16
#|---------------------------------------
#|- set memory limit 4000Mb
#|- #SBATCH --mem 4000
#|---------------------------------------
#|- PARTITION & time limit
#|- use `sinfo` to list PARTITION & TIMELIMIT
#SBATCH -p !!!!PARTITION!!!!!
#|- Quality
#+ #SBATCH -q !!!!QUALITY!!!!!
## time format day-hour:minute:second
#SBATCH --time=00-00:30:00

#|=======================================
#| start to set your environment for your job
#|---------------------------------------

#|-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
#- load intel modules
#|---------------------------------------
#+module load intel/2022
#+
#+export MKLPATH=$MKL_HOME/lib/intel64/
#+export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MKLPATH
#+export INTELPATH=$INTEL_HOME/lib/intel64/
#+export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INTELPATH


#|-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
#- set parallel environment
#|---------------------------------------
#- use mpi
#+ export OMP_NUM_THREADS=1
#+ export MKL_NUM_THREADS=1

#|-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
#| load your own lib path(if needed)
#|---------------------------------------
#+ export PATH=$PATH:your path

#|=======================================
#| start to run your job
#|---------------------------------------
# srun '/path/to/your/program' > output

#|=======================================
#| done
#|---------------------------------------
# exit 0