

_jobage_main_fuc_srcPath=''

# detect PATH
if [[ $SHELL == *"/bash" ]]; then
    _jobage_main_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_main_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

function _jobage_queue_display() {
    
    outType='all'

    if [[ $# == 1 ]]; then

	    outType=$1;
    fi
    
    cPath=$(pwd| sed "s/\/.*\/$USER/~/g" | sed 's/\/\.\///g')

    OLD_IFS="$IFS"
    IFS=
    nline=0
    while read line
    do
	    nline=$((nline+1))
        if (( nline > 2 ));then
            strStart='*'
            if [[ "$line" == *\ "$cPath" ]]; then
                strStart='\033[96;104m>\033[0m'
                # echo 'find cPath'
            fi

            if [[ "$outType" == "all" ]]; then
                if (( nline == 3 ));then
                    echo -e $strStart" == " "$line"; 
                else
                    strStatus=$(echo "$line" | awk '{print $5}')
                    if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                        echo -e $strStart"\033[32m >> \033[0m" $line; 
                    elif [[ "$strStatus" == 'CG' ]]; then
                        echo -e $strStart"\033[33m >< \033[0m" $line; 
                    else 
                        echo -e $strStart"\033[33m == \033[0m" $line; 
                    fi
                fi
                echo '+----'
            else
                if (( nline == 3 ));then
                    echo -e $strStart" == " $line; 
                    echo '+----'
                else
                    strStatus=$(echo "$line" | awk '{print $5}')
                    if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                        echo -e $strStart"\033[32m >> \033[0m" $line; 
                        echo '+----'
                    elif [[ "$strStatus" == 'CG' ]]; then
                        echo -e $strStart"\033[33m >< \033[0m" $line; 
                        echo '+----'
                    fi
                fi
            fi
        fi
    done < "$_jobage_dinfo1"
    IFS="$OLD_IFS"
}


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

        OLD_IFS="$IFS"
        IFS=
        nline=0
        while read line
        do
            nline=$((nline+1))
            if (( $nline > 2 ));then
            strStart='*'
            if [[ $line == *\ "$cPath" ]]; then
                strStart='\033[96;104m>\033[0m'
                # echo 'find cPath'
            fi
            if (( nline == 3 ));then
                echo -e $strStart" == " $line; 
            else
                strStatus=$(echo "$line" | awk '{print $5}')
                if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                    echo -e $strStart"\033[32m >> \033[0m" $line; 
                elif [[ "$strStatus" == 'CG' ]]; then
                    echo -e $strStart"\033[33m >< \033[0m" $line; 
                else 
                    echo -e $strStart"\033[33m == \033[0m" $line; 
                fi
            fi
            # echo '|*' $line
            echo '+----'
            else
            echo '|#' $line
            fi
        done < "$_jobage_dinfo2"
        IFS="$OLD_IFS"
    fi

    printf "%s\n" "==============="
    # cat ~/.local/sq.dat
    OLD_IFS="$IFS"
    IFS=
    nline=0
    while read line
    do
	nline=$((nline+1))
	if (( $nline > 2 ));then
	    strStart='*'
	    if [[ $line == *\ "$cPath" ]]; then
		strStart='\033[96;104m>\033[0m'
		# echo 'find cPath'
	    fi

        if (( $hline == 1 )); then
            if [[ $line == *\ "$cPath" ]]; then
                if (( nline == 3 ));then
                    echo -e $strStart" == " $line; 
                else
                    strStatus=$(echo "$line" | awk '{print $5}')
                    if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                        echo -e $strStart"\033[32m >> \033[0m" $line; 
                    elif [[ "$strStatus" == 'CG' ]]; then
                        echo -e $strStart"\033[33m >< \033[0m" $line; 
                    else 
                        echo -e $strStart"\033[33m == \033[0m" $line; 
                    fi
                fi
                # echo '|*' $line
                echo '+----'
            fi
        else
            if (( nline == 3 ));then
                echo -e $strStart" == " $line; 
            else
                strStatus=$(echo "$line" | awk '{print $5}')
                if [[ "$strStatus" == 'RUN' ]] || [[ "$strStatus" == 'R' ]]; then 
                    echo -e $strStart"\033[32m >> \033[0m" $line; 
                elif [[ "$strStatus" == 'CG' ]]; then
                    echo -e $strStart"\033[33m >< \033[0m" $line; 
                else 
                    echo -e $strStart"\033[33m == \033[0m" $line; 
                fi
            fi
            # echo '|*' $line
            echo '+----'
        fi

	else
	    echo '|#' $line
	fi
    done < "$_jobage_dinfo1"
    IFS="$OLD_IFS"

}


_jobage_cd()
{
    if [[ $SHELL ==  *"/bash" ]]; then
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

_jobage_kill_grep() {

    jobInfo=$(_jobage_queue_display | grep "$@")

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


# function list
jbg.help() 
{
    echo "| a job-management tool for cluster scheduling systems."
    echo '| author   : C4r-bs'
    echo '| homepage : https://gitee.com/C4r/jobage'
    echo '| --------'
    echo '| command list :'
    echo '| .q      | display queue infomation.'
    echo '| .qrun   | display running queue infomation.'
    echo '| .qh     | display last two queue infomation.'
    echo '| - - - - '
    echo '| .kill   | kill specific jobs by index/grep/all.'
    echo '| .cd     | go to the working dirctory of job.'
    echo '| - - - - '
    echo '| run .any -h/--help to get the help information for any command.' 
    echo '| --------'
}

jbg.q() 
{
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-display queue infomation.'
        return
    fi

    _jobage_save_queue "$@"    

    _jobage_queue_display "$@"
}

jbg.qrun() 
{
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-only display running queue infomation.'
        return
    fi

    _jobage_save_queue "$@"

    _jobage_queue_display "run" "$@"
}


jbg.kill() {
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-kill spicific job.'
        echo '|-kill [id]'
        echo '|-- kill the job with the [id]. [id] is the index shwon in jbg.q '
        echo '|-kill [grep str]'
        echo '|-- kill jobs in which job name or working path contains str'
        echo '|-kill [all]'
        echo '|-- kill all jobs '
        return
    fi
    if [[ "$1" == "grep" ]]; then
        _jobage_kill_grep "${@:2}"
    elif [ "$1" == "all" ]; then
        _jobage_cancel_all "$@"
    else
        _jobage_cancel_index "$@"


    fi
    
}

jbg.qh() {
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-show the last two queue informantion.'
        return
    fi

    _jobage_queue_history_display "$@"
}

jbg.cd()
{
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-go to the work dirctory of job.'
        echo '|-cd [num]'
        return
    fi
    _jobage_cd "$@"
}