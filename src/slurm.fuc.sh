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
    
    outType='all'

    if [[ $# == 1 ]]; then

	    outType=$1;
    fi

    timestampNow=$(date +%s)

    if [ -f ~/.local/sq.dat ] && [ -s ~/.local/sq.dat ]; then
	if [ -f ~/.local/sq-1.dat ] && [ -s ~/.local/sq-1.dat ]; then
	    timestampPre=$(head -n1 ~/.local/sq-1.dat | awk '{print $7}')
	    # echo $timestampNow $timestampPre 
	    # echo $(echo "scale=0 ;$timestampNow-$timestampPre > 300" | bc )
	    if [[ $(echo "scale=0 ;$timestampNow-$timestampPre > 300" | bc ) -eq 1 ]]; then
		cp ~/.local/sq.dat ~/.local/sq-1.dat
	    fi
	    # echo 'cp end'
	else
	    cp ~/.local/sq.dat ~/.local/sq-1.dat
	fi
    fi

    jobs=$(squeue -u shengbi -o "%.10i %.9P %.12j %.2t %.10M %.5D %.Z" | tail -n +2 | sort -k 2n)

    { { date ; echo " " $timestampNow ;}  | tr -d '\n' ; echo ; } > ~/.local/sq.dat
    
    # echo "debug:--->"
    # cat ~/.local/sq.dat
    # echo "debug---|"
    echo "----------" >> ~/.local/sq.dat

    printf "%6s %10s %11s %10s %3s %8s %8s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODES" "WORK_DIR" >>  ~/.local/sq.dat
    # echo "$jobs" | nl -v 1
    
    array_jobDir=($(echo "$jobs" | awk '{print $7}'))
    array_jobID=($(echo "$jobs" | awk '{print $1}'))

    echo "$jobs" | nl -v 1 | sed 's/\/.*\/shengbi/~/g' | sed 's/\/\.\///g' >> ~/.local/sq.dat
    
    cPath=$(pwd| sed 's/\/.*\/shengbi/~/g' | sed 's/\/\.\///g')

    OLD_IFS="$IFS"
    IFS=
    nline=0
    while read line
    do
	    nline=$((nline+1))
        if (( nline > 2 ));then
            strStart='*'
            if [[ $line == *\ "$cPath" ]]; then
                strStart='\033[96;104m>\033[0m'
                # echo 'find cPath'
            fi

            if [[ "$outType" == "all" ]]; then
                if (( nline == 3 ));then
                    echo -e $strStart" == " $line; 
                elif [[ $(echo $line | awk '{print $5}') == 'R' ]]; then 
                    echo -e $strStart"\033[32m >> \033[0m" $line; 
                elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
                    echo -e $strStart"\033[33m >< \033[0m" $line; 
                else 
                    echo -e $strStart"\033[33m == \033[0m" $line; 
                fi
                echo '+----'
            else
                if (( nline == 3 ));then
                    echo -e $strStart" == " $line; 
                    echo '+----'
                elif [[ $(echo $line | awk '{print $5}') == 'R' ]]; then 
                    echo -e $strStart"\033[32m >> \033[0m" $line; 
                    echo '+----'
                elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
                    echo -e $strStart"\033[33m >< \033[0m" $line; 
                    echo '+----'
                fi
            fi
        fi
    done < ~/.local/sq.dat
    IFS="$OLD_IFS"
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