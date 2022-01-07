# ----------------------------------------------
# |rules for cluster scheduling system
# ----------------------------------------------
#-| gloable varible :
# |
#-|- local varible :
# |  | _jobage_[name]_xx
#-| fuction name rule:
# | _jobage_[name]_XX
#-| XX list:
# |- save_queue(none) [none]
# |  | save job queue info into files:
# |  | "$_jobage_dinfo1" and "$_jobage_dinfo2"
# |  | format : 
# |  | *1* date
# |  | *2* ----------
# |  | *3* num      JOBID   PARTITION       NAME  ST         TIME            NODES WORK_DIR
# |  | *4* num      JOBID   PARTITION       NAME  status     runging time    NODES [working directory]
# |  | save job queue info into array: _jobage_array_jobDir _jobage_array_jobID
# |- cancel(num) [none]
# |  | cancel job with index [num]
# |- cancel_all(none) [none]
# |  | cancel all jobs
# ----------------------------------------------

# =====================================
# start here
# -------------------------------------

_jobage_slurm_fuc_srcPath=''

# detect PATH
if [[ $SHELL == *"/bash" ]]; then
    _jobage_slurm_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_slurm_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

# basic func
source "$_jobage_slurm_fuc_srcPath/core.fuc.sh"


_jobage_slurm_save_queue()
{
    _jobage_slurm_timestampNow=$(date +%s)

    if [ -f "$_jobage_dinfo1" ] && [ -s "$_jobage_dinfo1" ]; then
        if [ -f "$_jobage_dinfo2" ] && [ -s "$_jobage_dinfo2" ]; then
            _jobage_slurm_timestampPre=$(head -n1 "$_jobage_dinfo2" | awk '{print $7}')
            if [[ "$_jobage_debug" == 'on' ]]; then
                echo "$_jbg_debug_title" "_jobage_slurm_save_queue time "
                echo "$_jbg_debug_title" $_jobage_slurm_timestampNow $_jobage_slurm_timestampPre 
                echo "$_jbg_debug_title" $(echo "scale=0 ;$_jobage_slurm_timestampNow-$_jobage_slurm_timestampPre > 300" | bc )

            fi

            if [[ $(echo "scale=0 ;$_jobage_slurm_timestampNow-$_jobage_slurm_timestampPre > 300" | bc ) -eq 1 ]]; then
                cp "$_jobage_dinfo1" "$_jobage_dinfo2"
            fi
            # echo 'cp end'
        else
            cp "$_jobage_dinfo1" "$_jobage_dinfo2"
        fi
    fi

    _jobage_slurm_jobs=$(squeue -u "$USER" -o "%.10i %.9P %.12j %.2t %.10M %.5D %.Z" | tail -n +2 | sort -k 2n)

    { { date ; echo " " $_jobage_slurm_timestampNow ;}  | tr -d '\n' ; echo ; } > "$_jobage_dinfo1"
    
    echo "----------" >> "$_jobage_dinfo1"

    printf "%6s %10s %11s %10s %3s %8s %8s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODES" "WORK_DIR" >>  "$_jobage_dinfo1"
    
    _jobage_array_jobDir=($(echo "$_jobage_slurm_jobs" | awk '{print $7}'))
    _jobage_array_jobID=($(echo "$_jobage_slurm_jobs" | awk '{print $1}'))

    echo "$_jobage_slurm_jobs" | nl -v 1 | sed 's/\/.*\/shengbi/~/g' | sed 's/\/\.\///g' >> "$_jobage_dinfo1"
    
}

function _jobage_slurm_cancel()
{

    if [[ $SHELL ==  *"/bash" ]]; then

        if [ "$#" -eq 0 ]; then
            scancel ${_jobage_array_jobID[0]}
        else
            scancel ${_jobage_array_jobID[$1-1]}
        fi
    else 

        if [ "$#" -eq 0 ]; then
            scancel ${_jobage_array_jobID[1]}
        else
            scancel ${_jobage_array_jobID[$1]}
        fi
    fi

}

function _jobage_slurm_cancel_all()
{
    echo 'Will cancel all jobs !!!'
    echo '-------------------'
    echo '| confirm : y/n ?'
    read _jobage_slurm_confirm
    if [[ $_jobage_slurm_confirm == 'y' ]];then
        echo 'confirm. cancling...'

        scancel -u "$USER"

	    echo 'done.'
    else
	    echo 'not confirm'
    fi
}

function _jobage_slurm_submit()
{
    _jobage_slurm_filename="$@"
    if [[ -f "$_jobage_slurm_filename" ]]; then
        sbatch "$_jobage_slurm_filename";
    else
        echo "jbg error: do not find file " "$_jobage_slurm_filename";
    fi
}

# -------------------------------------
# end here
# =====================================

# public and unique function list
function _jobage_save_queue()
{
    _jobage_slurm_save_queue "$@"
}

function _jobage_cancel_index()
{
    _jobage_slurm_cancel "$@"
}

function _jobage_cancel_all()
{
    _jobage_slurm_cancel_all "$@"
}

function _jobage_submit()
{
    _jobage_slurm_submit "$@"
}