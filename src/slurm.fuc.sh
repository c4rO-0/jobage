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
if [[ "$_jbg_SHELL" == *"/bash" ]]; then
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

    if [ "$#" -eq 0 ]; then
        _jobage_slurm_jobs=$(squeue -u "$USER" -o "%.10i %.9P %.12j %.2t %.10M %Dx%c %.Z" | tail -n +2 | sort -k 2n)
    else
        if [[ "$@" == "all" ]]; then
            _jobage_slurm_jobs=$(squeue -o "%.10i %.9P %.12j %.2t %.10M %Dx%c %.8u" | tail -n +2 | sort -k 2n)
        else
            _jobage_slurm_jobs=$(squeue "$@"  | tail -n +2 | sort -k 2n)
        fi
    fi

    { { date ; echo " " $_jobage_slurm_timestampNow ;}  | tr -d '\n' ; echo ; } > "$_jobage_dinfo1"
    
    echo "----------" >> "$_jobage_dinfo1"

    if [ "$#" -eq 0 ]; then
        printf "%6s %10s %11s %20s %3s %8s %11s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODExCPU" "WORK_DIR" >>  "$_jobage_dinfo1"
    else
        if [[ "$@" == "all" ]]; then
            printf "%6s %10s %11s %20s %3s %8s %11s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODExCPU" "USER" >>  "$_jobage_dinfo1"
        else
            printf "%6s %9s\n" "num" "SPECIFIED" >>  "$_jobage_dinfo1"
        fi
    fi

    
    
    _jobage_array_jobDir=($(echo "$_jobage_slurm_jobs" | awk '{print $7}'))
    _jobage_array_jobID=($(echo "$_jobage_slurm_jobs" | awk '{print $1}'))

    echo "$_jobage_slurm_jobs" | nl -v 1 | sed "s| /.*$HOME| ~|g" | sed "s| $HOME| ~|g" | sed 's/\/\.\///g' >> "$_jobage_dinfo1"
    
}

function _jobage_slurm_cancel()
{

    if [[ "$_jbg_SHELL" ==  *"/bash" ]]; then

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

function _jobage_slurm_generate()
{

    if [[ -f "$_jobage_slurm_fuc_srcPath/template/template.group.slurm" ]]; then
        cp "$_jobage_slurm_fuc_srcPath/template/template.group.slurm" "$@"
    else
        cp "$_jobage_slurm_fuc_srcPath/template/template.slurm" "$@"
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

function _jobage_generate()
{
    _jobage_slurm_generate "$@"
}