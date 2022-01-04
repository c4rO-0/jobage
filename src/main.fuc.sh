
function _jobage_queue() {
    
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
            if [[ $line == *\ "$cPath" ]]; then
                strStart='\033[96;104m>\033[0m'
                # echo 'find cPath'
            fi

            if [[ "$outType" == "all" ]]; then
                if (( nline == 3 ));then
                    echo -e $strStart" == " $line; 
                elif [[ $(echo $line | awk '{print $5}') == 'RUN' ]]; then 
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
                elif [[ $(echo $line | awk '{print $5}') == 'RUN' ]]; then 
                    echo -e $strStart"\033[32m >> \033[0m" $line; 
                    echo '+----'
                elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
                    echo -e $strStart"\033[33m >< \033[0m" $line; 
                    echo '+----'
                fi
            fi
        fi
    done < "$_jobage_dinfo"
    IFS="$OLD_IFS"
}

function _jobage_queue_history()
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
            elif [[ $(echo $line | awk '{print $5}') == 'RUN' ]]; then 
                echo -e $strStart"\033[32m >> \033[0m" $line; 
            elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
                echo -e $strStart"\033[33m >< \033[0m" $line; 
            else 
                echo -e $strStart"\033[33m == \033[0m" $line; 
            fi
            # echo '|*' $line
            echo '+----'
            else
            echo '|#' $line
            fi
        done < "$_jobage_dinfo1"
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
                elif [[ $(echo $line | awk '{print $5}') == 'RUN' ]]; then 
                echo -e $strStart"\033[32m >> \033[0m" $line; 
                elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
                echo -e $strStart"\033[33m >< \033[0m" $line; 
                else 
                echo -e $strStart"\033[33m == \033[0m" $line; 
                fi
                # echo '|*' $line
                echo '+----'
            fi
        else
            if (( nline == 3 ));then
            echo -e $strStart" == " $line; 
            elif [[ $(echo $line | awk '{print $5}') == 'RUN' ]]; then 
            echo -e $strStart"\033[32m >> \033[0m" $line; 
            elif [[ $(echo $line | awk '{print $5}') == 'CG' ]]; then
            echo -e $strStart"\033[33m >< \033[0m" $line; 
            else 
            echo -e $strStart"\033[33m == \033[0m" $line; 
            fi
            # echo '|*' $line
            echo '+----'
        fi

	else
	    echo '|#' $line
	fi
    done < "$_jobage_dinfo"
    IFS="$OLD_IFS"

}