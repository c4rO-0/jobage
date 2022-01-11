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

_jobage_pbs_fuc_srcPath=''

# detect PATH
if [[ "$_jbg_SHELL" == *"/bash" ]]; then
    _jobage_pbs_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_pbs_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

_jobage_lsf_raw_xml_dinfo="$_jobage_wPath/qstat.raw.xml"
_jobage_lsf_xml_dinfo="$_jobage_wPath/qstat.xml"
_jobage_lsf_json_dinfo="$_jobage_wPath/qstat.json"


# basic func
source "$_jobage_pbs_fuc_srcPath/core.fuc.sh"

function _jobage_pbs_raw() {
    # help
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-get job raw info'
        return
    fi

    _jobage_lsf_info=$(bjobs -u $USER -o "jobid:7 queue:10 job_name:20 stat:5 run_time exec_host:12 sub_cwd")

    if [[ "$_jobage_lsf_info" == *"No unfinished job found"* ]]; then
        echo ""
    else
        _jobage_lsf_secs=$(echo "$_jobage_lsf_info" | awk '{print $5}' | tail --lines=+2 | sed 's/ //g')
        
        _jobage_lsf_info_r=$_jobage_lsf_info
        OLD_IFS="$IFS"
        IFS=
        while read _jobage_lsf_t
        do
                _jobage_lsf_tRead_raw=$(_jobage_displaytime "$_jobage_lsf_t")
                _jobage_lsf_tRead=$(printf '%-16s' "$_jobage_lsf_tRead_raw")
                _jobage_lsf_info_r=$(echo "$_jobage_lsf_info_r" | sed "s/$_jobage_lsf_t second(s)/$_jobage_lsf_tRead/g")
        done <<< "$_jobage_lsf_secs"
        IFS="$OLD_IFS"
        
        _jobage_lsf_info_r=$(echo "$_jobage_lsf_info_r" | sed "s|\$HOME|$HOME|g")
        echo "$_jobage_lsf_info_r"
    fi
}


function _jobage_pbs_save_queue() {


    # .all.Data[].Job| [.Job_Id, .Job_Name, .job_state, .init_work_dir, .resources_used.walltime]

    # save xml files
    qstat -u "$USER" -f -x > "$_jobage_lsf_raw_xml_dinfo"
    
    # convert to json
    # github.com/hay/xml2json
    "$_jobage_pbs_fuc_srcPath/xml2json.py" -t xml2json -o "$_jobage_lsf_json_dinfo" "$_jobage_lsf_raw_xml_dinfo"

    # read json
    # https://github.com/owenthereal/jqplay
    "$_jobage_pbs_fuc_srcPath/jq-linux64" ".Data.Job[] | [.Job_Id, .Job_Name, .job_state, .init_work_dir, .resources_used.walltime]" "$_jobage_lsf_json_dinfo"
    
    # _jobage_lsf_timestampNow=$(date +%s)

    # if [ -f "$_jobage_dinfo1" ] && [ -s "$_jobage_dinfo1" ]; then
    #     if [ -f "$_jobage_dinfo2" ] && [ -s "$_jobage_dinfo2" ]; then
    #         _jobage_lsf_timestampPre=$(head -n1 "$_jobage_dinfo2" | awk '{print $7}')
    #         # echo $timestampNow $timestampPre 
    #         # echo $(echo "scale=0 ;$timestampNow-$timestampPre > 300" | bc )
    #         if [[ $(echo "scale=0 ;$_jobage_lsf_timestampNow-$_jobage_lsf_timestampPre > 300" | bc ) -eq 1 ]]; then
    #         cp "$_jobage_dinfo1" "$_jobage_dinfo2"
    #         fi
    #         # echo 'cp end'
    #     else
    #         cp "$_jobage_dinfo1" "$_jobage_dinfo2"
    #     fi
    # fi

    # _jobage_lsf_jobs=$(_jobage_lsf_raw | tail -n +2 | sort -k 2n)

    # { { date ; echo " " $_jobage_lsf_timestampNow ;}  | tr -d '\n' ; echo ; } > "$_jobage_dinfo1"
    
    # # echo "debug:--->"
    # # cat ~/.local/sq.dat
    # # echo "debug---|"
    # echo "----------" >> "$_jobage_dinfo1"

    # printf "%6s %10s %11s %10s %3s %8s %8s %s\n" "num" "JOBID" "PARTITION" "NAME" "ST" "TIME" "NODES" "WORK_DIR" >>  "$_jobage_dinfo1"
    # # echo "$jobs" | nl -v 1
    
    # _jobage_array_jobDir=($(echo "$_jobage_lsf_jobs" | awk '{print $7}'))
    # _jobage_array_jobID=($(echo "$_jobage_lsf_jobs" | awk '{print $1}'))

    # echo "$_jobage_lsf_jobs" | nl -v 1 | sed "s/\/.*\/$USER/~/g" | sed 's/\/\.\///g' | sed 's/\$HOME/~/g' >> "$_jobage_dinfo1"
}



# function _jobage_pbs_cancel() 
# {

#     if [[ "$_jobage_debug" == 'on' ]]; then
#         echo "$_jbg_debug_title" "_jobage_lsf_cancel " "$@"
#     fi

#     if [[ "$_jbg_SHELL" ==  *"/bash" ]]; then

#         if [ "$#" -eq 0 ]; then
#             bkill ${_jobage_array_jobID[0]}
#         else
#             bkill ${_jobage_array_jobID[$1-1]}
#         fi
#     else
#         if [ "$#" -eq 0 ]; then
#             bkill ${_jobage_array_jobID[1]}
#         else
#             bkill ${_jobage_array_jobID[$1]}
#         fi	
#     fi

# }

# function _jobage_pbs_cancel_all()
# {

#     echo 'Will cancel all jobs !!!'
#     echo '-------------------'
#     echo '| confirm : y/n ?'
#     read _jobage_lsf_confirm
#     if [[ $_jobage_lsf_confirm == 'y' ]];then
#         echo 'confirm. cancling...'

#         for i in $(bjobs | grep "$USER" | awk '{print $1}');
#         do
#             bkill $i;
#         done

# 	    echo 'done.'
#     else
# 	    echo 'not confirm'
#     fi

# }

# function _jobage_pbs_submit()
# {
#     _jobage_lsf_filename="$@"
#     if [[ -f "$_jobage_lsf_filename" ]]; then
#         bsub < "$_jobage_lsf_filename";
#     else
#         echo "jbg error: do not find file " "$_jobage_lsf_filename";
#     fi
# }

# -------------------------------------
# end here
# =====================================

# public and unique function list
function _jobage_save_queue()
{
    echo "test"
    # _jobage_pbs_save_queue "$@"
}

# function _jobage_cancel_index()
# {
#     if [[ "$_jobage_debug" == 'on' ]]; then
#         echo "$_jbg_debug_title" "_jobage_cancel_index " "$@"
#     fi

#     _jobage_pbs_cancel "$@"
# }

# function _jobage_cancel_all()
# {
#     _jobage_pbs_cancel_all "$@"
# }

# function _jobage_submit()
# {
#     _jobage_pbs_submit "$@"
# }