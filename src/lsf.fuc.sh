

_jobage_fuc_srcPath=''

# detect PATH
if [[ $SHELL == *"/bash" ]]; then
    _jobage_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

# basic func
source "$_jobage_fuc_srcPath/core.fuc.sh"

function _jobage_lsf_raw() {
    # help
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        echo '|-get job raw info'
        exit 0
    fi

    info=$(bjobs -u $USER -o "jobid:7 queue:10 job_name:20 stat:5 run_time exec_host:12 sub_cwd")

    if [[ "$info" == *"No unfinished job found"* ]]; then
        echo ""
    else
        secs=$(echo "$info" | awk '{print $5}' | tail --lines=+2 | sed 's/ //g')
        
        info_r=$info
        OLD_IFS="$IFS"
        IFS=
        while read t
        do
                tRead_raw=$(_jobage_displaytime "$t")
                tRead=$(printf '%-16s' "$tRead_raw")
                info_r=$(echo "$info_r" | sed "s/$t second(s)/$tRead/g")
        done <<< "$secs"
        IFS="$OLD_IFS"
        
        info_r=$(echo "$info_r" | sed "s|\$HOME|$HOME|g")
        echo "$info_r"
    fi
}


function _jobage_lsf_save_queue() {
    
    timestampNow=$(date +%s)

    if [ -f "$_jobage_dinfo1" ] && [ -s "$_jobage_dinfo1" ]; then
        if [ -f "$_jobage_dinfo2" ] && [ -s "$_jobage_dinfo2" ]; then
            timestampPre=$(head -n1 "$_jobage_dinfo2" | awk '{print $7}')
            # echo $timestampNow $timestampPre 
            # echo $(echo "scale=0 ;$timestampNow-$timestampPre > 300" | bc )
            if [[ $(echo "scale=0 ;$timestampNow-$timestampPre > 300" | bc ) -eq 1 ]]; then
            cp "$_jobage_dinfo1" "$_jobage_dinfo2"
            fi
            # echo 'cp end'
        else
            cp "$_jobage_dinfo1" "$_jobage_dinfo2"
        fi
    fi

    jobs=$(_jobage_lsf_raw | tail -n +2 | sort -k 2n)

    { { date ; echo " " $timestampNow ;}  | tr -d '\n' ; echo ; } > "$_jobage_dinfo1"
    
    # echo "debug:--->"
    # cat ~/.local/sq.dat
    # echo "debug---|"
    echo "----------" >> "$_jobage_dinfo1"

    printf "%6s %10s %11s %10s %3s %8s %8s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODES" "WORK_DIR" >>  "$_jobage_dinfo1"
    # echo "$jobs" | nl -v 1
    
    _jobage_array_jobDir=($(echo "$jobs" | awk '{print $7}'))
    _jobage_array_jobID=($(echo "$jobs" | awk '{print $1}'))

    echo "$jobs" | nl -v 1 | sed "s/\/.*\/$USER/~/g" | sed 's/\/\.\///g' | sed 's/\$HOME/~/g' >> "$_jobage_dinfo1"
}



function _jobage_lsf_cancel() 
{

    if [[ $SHELL ==  *"/bash" ]]; then

        if [ "$#" -eq 0 ]; then
            bkill ${_jobage_array_jobID[0]}
        else
            bkill ${_jobage_array_jobID[$1-1]}
        fi
    else
        if [ "$#" -eq 0 ]; then
            bkill ${_jobage_array_jobID[1]}
        else
            bkill ${_jobage_array_jobID[$1]}
        fi	
    fi

}

function _jobage_lsf_cancel_all()
{

    echo 'Will cancel all jobs !!!'
    echo '-------------------'
    echo '| comfirm : y/n ?'
    read comfirm
    if [[ $comfirm == 'y' ]];then
        echo 'comfirm. cancling...'

        for i in $(bjobs | grep "$USER" | awk '{print $1}');
        do
            bkill $i;
        done

	    echo 'done.'
    else
	    echo 'not comfirm'
    fi

}

# !!!!!!!!!!!!!!!!!!!!!!!!!!
# FIXME
# ==========================
function _working_jobage_lsf_cancel_grep()
{
    jobInfo=$(grep "$@" "$_jobage_dinfo1")

#    for iJobInfo in $(echo $jobInfo); 
    
    echo 'Will cancel following jobs :'

    OLD_IFS="$IFS"
    IFS=
    while read -r iJobInfo;
    do 
	echo $iJobInfo
	iJobNum=$(echo $iJobInfo | awk '{print $5}') 
	# scancelJob $i;
	# debug
	# echo 'cancel ' $iJobNum
    done < <(printf '%s\n' "$jobInfo")
    IFS="$OLD_IFS"

    echo '-------------------'
    echo '| comfirm : y/n ?'

    read comfirm
    if [[ $comfirm == 'y' ]];then
        echo 'comfirm. cancling...'
        OLD_IFS="$IFS"
        IFS=
        while IFS= read -r iJobInfo;
        do 
            # echo '| ', $iJobInfo
            iJobNum=$(echo $iJobInfo | awk '{print $5}') 
            bkill $iJobNum;
            # echo $iJobNum;
        done < <(printf '%s\n' "$jobInfo")
        IFS="$OLD_IFS"

	    echo 'done.'
    else
	    echo 'not comfirm'
    fi


}