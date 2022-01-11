jbg_title='| jbg info | '

_jobage_main_fuc_srcPath=''

# detect PATH
if [[ "$_jbg_SHELL" == *"/bash" ]]; then
    _jobage_main_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_main_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

if [[ "$(type -t _jobage_save_queue)" ]]; then
    function _jobage_queue_display() {
        
        outType='all'

        if [[ $# == 1 ]]; then

            outType=$1;
        fi
        
        cPath=$(pwd| sed "s/\/.*\/$USER/~/g" | sed 's/\/\.\///g')

        OLD_IFS="$IFS"
        IFS=
        nline=0
        n_run=0
        n_cg=0
        n_wait=0
        n_job=0
        while read line
        do
            if [[ ! -z "${line// }" ]];then

                nline=$((nline+1))
                if (( nline > 2 ));then
                    strStart="\033[$_jbg_set_color_start$_jbg_set_mark_start\033[0m";
                    if [[ "$line" == *\ "$cPath" ]]; then
                        strStart="\033[$_jbg_set_color_start_checked$_jbg_set_mark_start_checked\033[0m";
                        # echo 'find cPath'
                    fi

                    if [[ "$outType" == "all" ]]; then
                        if (( nline == 3 ));then
                            echo -e "$strStart $_jbg_set_mark_job_wait " "$line"; 
                        else
                            strStatus=$(echo "$line" | awk '{print $5}')
                            if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                                echo -e "$strStart""\033[$_jbg_set_color_job_run $_jbg_set_mark_job_run \033[0m" "$line";
                                n_run=$((n_run+1)) ;
                            elif [[ "$strStatus" == 'PD' ]] || [[ "$strStatus" == 'PEND' ]]; then
                                echo -e "$strStart""\033[$_jbg_set_color_job_wait $_jbg_set_mark_job_wait \033[0m" "$line"; 
                                n_wait=$((n_cg+1)) ;
                            else
                                # [[ "$strStatus" == 'CG' ]]; then
                                if [[ "$_jobage_debug" == 'on' ]]; then
                                    echo "$_jbg_debug_title" "found warn line " ">$line<"
                                fi
                                echo -e "$strStart""\033[$_jbg_set_color_job_warn $_jbg_set_mark_job_warn \033[0m" "$line"; 
                                n_cg=$((n_cg+1)) ;
                            fi
                            n_job=$((n_job+1));
                        fi
                        if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                            echo "$_jbg_split_line_mark";
                        fi
                    else
                        if (( nline == 3 ));then
                            echo -e "$strStart $_jbg_set_mark_job_wait " "$line"; 
                            if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                echo "$_jbg_split_line_mark";
                            fi
                        else
                            strStatus=$(echo "$line" | awk '{print $5}')
                            if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                                echo -e "$strStart""\033[$_jbg_set_color_job_run $_jbg_set_mark_job_run \033[0m" "$line";

                                if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                    echo "$_jbg_split_line_mark";
                                fi
                                n_run=$((n_run+1)) ;
                            elif [[ "$strStatus" == 'PD' ]] || [[ "$strStatus" == 'PEND' ]]; then
                                n_wait=$((n_cg+1)) ;
                            else 
                                # [[ "$strStatus" == 'CG' ]]; then
                                if [[ "$_jobage_debug" == 'on' ]]; then
                                    echo "$_jbg_debug_title" "found warn line " ">$line<"
                                fi

                                echo -e "$strStart""\033[$_jbg_set_color_job_warn $_jbg_set_mark_job_warn \033[0m" "$line"; 
                                if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                    echo "$_jbg_split_line_mark";
                                fi
                                n_cg=$((n_cg+1)) ;
                            fi
                            n_job=$((n_job+1));
                        fi # nline == 3
                    fi #outtype
                fi # nline check
            fi # empty check
        done < "$_jobage_dinfo1"
        IFS="$OLD_IFS"
        echo -e "$jbg_title" "total " "\033[$_jbg_set_color_job_wait $n_job \033[0m" " | run " "\033[$_jbg_set_color_job_run $n_run \033[0m" " | warn " "\033[$_jbg_set_color_job_warn $n_cg \033[0m"
    }
else
    _jobage_save_queue
    command -v _jobage_save_queue
    echo "not found _jobage_save_queue"
fi

if [[ "$(type -t _jobage_save_queue)" ]]; then
    function _jobage_queue_history_display()
    {

        hline=2
        if [ "$#" -ne 0 ]; then

            if [ "$1" -eq '1' ]; then
                hline=1
            fi
        fi

        cPath=$(pwd| sed "s/\/.*\/$USER/~/g" | sed 's/\/\.\///g')

        if (( $hline == 2 )); then
            printf "%s\n" "==============="
            # cat ~/.local/sq-1.dat
            if [[ ! -f "$_jobage_dinfo2" ]];then
                echo "jobage queue the first information not found."
            else
                OLD_IFS="$IFS"
                IFS=
                nline=0
                while read line
                do
                    if [[ ! -z "${line// }" ]];then

                        nline=$((nline+1))
                        if (( $nline > 2 ));then
                            strStart="\033[$_jbg_set_color_start$_jbg_set_mark_start\033[0m";
                            if [[ "$line" == *\ "$cPath" ]]; then
                                strStart="\033[$_jbg_set_color_start_checked$_jbg_set_mark_start_checked\033[0m";
                                # echo 'find cPath'
                            fi
                            if (( nline == 3 ));then
                                echo -e "$strStart $_jbg_set_mark_job_wait " "$line"; 
                            else
                                strStatus=$(echo "$line" | awk '{print $5}')
                                if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                                    echo -e "$strStart""\033[$_jbg_set_color_job_run $_jbg_set_mark_job_run \033[0m" "$line";
                                elif [[ "$strStatus" == 'PD' ]] || [[ "$strStatus" == 'PEND' ]]; then
                                    echo -e "$strStart""\033[$_jbg_set_color_job_wait $_jbg_set_mark_job_wait \033[0m" "$line"; 
                                else
                                    # [[ "$strStatus" == 'CG' ]]; then
                                echo -e "$strStart""\033[$_jbg_set_color_job_warn $_jbg_set_mark_job_warn \033[0m" "$line"; 
                                fi
                            fi
                            # echo '|*' $line
                            if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                echo "$_jbg_split_line_mark";
                            fi
                            else
                            echo '|#' $line
                        fi
                    fi # check empty line
                done < "$_jobage_dinfo2"
                IFS="$OLD_IFS"
            fi
        fi

        printf "%s\n" "==============="
        if [[ ! -f "$_jobage_dinfo1" ]];then
            echo "jobage queue the second information not found."
        else
            # cat ~/.local/sq.dat
            OLD_IFS="$IFS"
            IFS=
            nline=0
            while read line
            do
                if [[ ! -z "${line// }" ]];then
                    nline=$((nline+1))
                    if (( $nline > 2 ));then
                        strStart="\033[$_jbg_set_color_start$_jbg_set_mark_start\033[0m";
                        if [[ "$line" == *\ "$cPath" ]]; then
                            strStart="\033[$_jbg_set_color_start_checked$_jbg_set_mark_start_checked\033[0m";
                            # echo 'find cPath'
                        fi

                        if (( $hline == 1 )); then
                            if [[ $line == *\ "$cPath" ]]; then
                                if (( nline == 3 ));then
                                    strStart="\033[$_jbg_set_color_start$_jbg_set_mark_start\033[0m";
                                else
                                    strStatus=$(echo "$line" | awk '{print $5}')
                                    if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                                        echo -e "$strStart""\033[$_jbg_set_color_job_run $_jbg_set_mark_job_run \033[0m" "$line";
                                    elif [[ "$strStatus" == 'PD' ]] || [[ "$strStatus" == 'PEND' ]]; then
                                        echo -e "$strStart""\033[$_jbg_set_color_job_wait $_jbg_set_mark_job_wait \033[0m" "$line"; 
                                    else 
                                        # [[ "$strStatus" == 'CG' ]]; then
                                        echo -e "$strStart""\033[$_jbg_set_color_job_warn $_jbg_set_mark_job_warn \033[0m" "$line"; 
                                    fi
                                fi
                                # echo '|*' $line
                                if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                    echo "$_jbg_split_line_mark";
                                fi
                            fi
                        else
                            if (( nline == 3 ));then
                                echo -e "$strStart == " "$line"; 
                            else
                                strStatus=$(echo "$line" | awk '{print $5}')
                                if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                                    echo -e "$strStart""\033[$_jbg_set_color_job_run $_jbg_set_mark_job_run \033[0m" "$line";
                                elif [[ "$strStatus" == 'PD' ]] || [[ "$strStatus" == 'PEND' ]]; then
                                    echo -e "$strStart""\033[$_jbg_set_color_job_wait $_jbg_set_mark_job_wait \033[0m" "$line"; 
                                else 
                                    # [[ "$strStatus" == 'CG' ]]; then
                                    echo -e "$strStart""\033[$_jbg_set_color_job_warn $_jbg_set_mark_job_warn \033[0m" "$line"; 
                                fi
                            fi
                            # echo '|*' $line
                            if [[ "$_jbg_split_line" == 'y' ]] || [[ "$_jbg_split_line" == 'Y' ]];then
                                echo "$_jbg_split_line_mark";
                            fi
                        fi

                    else
                        echo '|#' $line
                    fi
                fi # check empty line
            done < "$_jobage_dinfo1"
            IFS="$OLD_IFS"
        fi

    }
fi

if [[ "$(type -t _jobage_queue_history_display)" ]]; then
    _jobage_cd()
    {
        if [[ "$_jbg_SHELL" ==  *"/bash" ]]; then
            if [ "$#" -eq 0 ]; then
                cd "${_jobage_array_jobDir[0]}"
            else
                cd "${_jobage_array_jobDir[$1-1]}"
            fi
        else
            if [ "$#" -eq 0 ]; then
                cd "${_jobage_array_jobDir[1]}"
            else
                cd "${_jobage_array_jobDir[$1]}"
            fi
        fi

        _jobage_queue_history_display 1
    }  
fi

if [[ "$(type -t _jobage_cancel_index)" ]]; then
    _jobage_kill_grep() {

        jobInfo=$(_jobage_queue_display | grep -v "$jbg_title" | grep "$@")

    #    for iJobInfo in $(echo $jobInfo); 
        
        echo 'Will cancel following jobs :'

        OLD_IFS="$IFS"
        IFS=
        while read -r iJobInfo;
        do 
            echo $iJobInfo
            # iJobNum=$(echo $iJobInfo | awk '{print $5}') 
            # # scancelJob $i;
            # # debug
            # echo 'cancel '  "$iJobNum"
        done < <(printf '%s\n' "$jobInfo")
        IFS="$OLD_IFS"

        echo '-------------------'
        echo '| confirm : y/n ?'

        read confirm
        if [[ "$confirm" == 'y' ]];then
            echo 'confirm. cancling...'
            OLD_IFS="$IFS"
            IFS=
            while IFS= read -r iJobInfo;
            do 
                # echo '| ', $iJobInfo
                iJobNum=$(echo "$iJobInfo" | awk '{print $4}') 
                _jobage_cancel_index "$iJobNum";
                # echo $iJobNum;
            done < <(printf '%s\n' "$jobInfo")
            IFS="$OLD_IFS"

            echo 'done.'
        else
            echo 'not confirm'
        fi

    }
fi

if [[ "$(type -t _jobage_save_queue)" ]] && [[ "$(type -t _jobage_queue_display)" ]]; then
    jbg.q() 
    {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-display queue infomation.'
            return
        fi

        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "$_jbg_debug_title" "_jobage_save_queue" "$@"
        fi

        _jobage_save_queue "$@"    

        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "$_jbg_debug_title" "_jobage_queue_display" "$@"
        fi

        _jobage_queue_display "$@"
    }
fi

if [[ "$(type -t _jobage_save_queue)" ]] && [[ "$(type -t _jobage_queue_display)" ]]; then
    jbg.qrun() 
    {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-only display running queue infomation.'
            return
        fi

        _jobage_save_queue "$@"

        _jobage_queue_display "run" "$@"
    }
fi

if [[ "$(type -t _jobage_kill_grep)" ]] && [[ "$(type -t _jobage_cancel_all)" ]] && [[ "$(type -t _jobage_cancel_index)" ]]; then
    jbg.kill() {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-kill spicific job.'
            echo '|-kill [num]'
            echo '|-- kill the job with the [num]. [num] is the index shwon in jbg.q '
            echo '|-kill [grep str]'
            echo '|-- kill jobs in which job name or working path contains str'
            echo '|-kill [all]'
            echo '|-- kill all jobs '
            return
        fi
        if [[ "$1" == "grep" ]]; then
            _jobage_kill_grep "${@:2}"
        elif [[ "$1" == "all" ]]; then
            _jobage_cancel_all "$@"
        else
            if [[ "$_jobage_debug" == 'on' ]]; then
                echo "$_jbg_debug_title" "jbg.kill " "$@"
            fi
            _jobage_cancel_index "$@"
        fi
        
    }
fi

if [[ "$(type -t _jobage_queue_history_display)" ]]; then
    jbg.qh() {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-show the last two queue informantion.'
            return
        fi

        _jobage_queue_history_display "$@"
    }
fi

if [[ "$(type -t _jobage_cd)" ]]; then
    jbg.cd()
    {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-go to the work dirctory of job.'
            echo '|-cd [num]'
            return
        fi
        _jobage_cd "$@"
    }
fi

if [[ "$(type -t _jobage_submit)" ]]; then
    jbg.sub()
    {
        if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
            echo '|-submit job using [script].'
            echo '|-sub [script]'
            return
        fi
        _jobage_submit "$@"
    }
fi


# function list
jbg.help() 
{
    echo "| a job-management tool for cluster scheduling systems."
    cat "$_jobage_main_fuc_srcPath/version.dat";
    echo '| author   : C4r-bs'
    # echo '| C4r homepage : http://papercomment.tech/'
    echo -e '| project link (gitee)  : https://gitee.com/C4r/jobage'
    echo -e '| project link (github) : https://github.com/c4rO-0/jobage'
    echo '| --------'
    echo '| found ' "$_jobage_system" " system."
    echo '| found ' "$_jbg_SHELL" " enviroment."
    echo '| found ' "$_jobage_wPath" " as working path."
    if [[ "$_jobage_setting_loaded" == 'no' ]]; then
        echo '| found ' "default setting."
    else
        echo '| found ' "user defined setting."
    fi
    echo '| --------'
    echo '| (run .any -h/--help to get the detailed help information for any command.)' 
    echo '| command list :'
    if [[ "$(type -t jbg.q)" ]]; then
        echo '| .q      | display queue infomation.'
    fi
    if [[ "$(type -t jbg.qrun)" ]]; then
        echo '| .qrun   | display running queue infomation.'
    fi    
    if [[ "$(type -t jbg.qh)" ]]; then
        echo '| .qh     | display last two queue infomation.'
    fi 
    echo '| - - - - ' 
    if [[ "$(type -t jbg.sub)" ]]; then
        echo '| .sub    | submit job.'
    fi      
    if [[ "$(type -t jbg.kill)" ]]; then
        echo '| .kill   | kill specific jobs.'
    fi     
    if [[ "$(type -t jbg.cd)" ]]; then
        echo '| .cd     | go to the working dirctory of job.'
    fi
    echo '| - - - - '
    echo '| custom setting : '
    echo '| $ cp "$_jobage_default_setting" "$_jobage_setting"; '
    echo '| $ edit "$_jobage_setting"; '
    echo '| $ source main.sh ;'
    echo '| - - - - '
    echo '| specify working path :'
    echo '| (only suggested for users having single linux account)'
    echo '| source main.sh --jbg_prefix path'
    echo "| path is the specific working path, default is $HOME/.local/jobage"
    echo '| --------'
}