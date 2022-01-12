
_jbg_SHELL="$(readlink /proc/$$/exe)"

_jobage_debug='off'
_jbg_debug_title="*|-jbg debug: "

_jobage_main_help='off'

_jobage_wPath="$HOME/.local/jobage"

_jobage_system=''

# -------------
# read args from answer :
# https://stackoverflow.com/a/14203146
# -------------
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --jbg_prefix)
      _jobage_wPath="$2"
      shift # past argument
      shift # past value
      ;;
    # -s|--searchpath)
    #   SEARCHPATH="$2"
    #   shift # past argument
    #   shift # past value
    #   ;;
    --jbg_help)
      _jobage_main_help='on'
      shift # past argument
      ;;
    --jbg_debug)
      _jobage_debug='on'
      shift # past argument
      ;;
    --jbg_system)
      _jobage_system="$2"
      shift # past argument
      shift # past value
      ;;
    # -*|--*)
    #   echo "Unknown option $1"
    #   exit 1
    #   ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ "$_jobage_main_help" == "on" ]]; then
    echo '|-jobage(jbg) help: '
    echo "|-source main.sh [--help] [--debug] [--prefix path]"
    echo "|--jbg_help        | show this help infomation"
    echo "|--jbg_debug       | run jobage with debug mod. Runing jbg will print detals."
    echo "|--jbg_prefix path | path to save jobage setting and data. default is $HOME/.local/jobage"
else

    if [[ "$_jobage_debug" == "on" ]]; then
        echo '*|-jobage(jbg) warning: debug mod is on'
        echo "*|-jbg shell " $_jbg_SHELL
    fi

    # detect PATH
    _jobage_srcPath=''
    if [[ "$_jbg_SHELL" == *"/bash" ]]; then
        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "*|-jbg debug: _jobage_srcPath " "${BASH_SOURCE[0]}"
        fi
        _jobage_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))

    else
        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "*|-jbg debug: _jobage_srcPath " "$0"
        fi
        _jobage_srcPath=$(dirname $(readlink -f "$0"))
    fi


    # detect type fuc
    if [[ "$_jbg_SHELL" == *"/bash" ]]; then

        # _jbg_fuc_exist="type -t"

        function _jbg_fuc_exist()
        {
            if [[ "$( type -t $@ )" ]]; then
                echo 'exist'
            else 
                return
            fi
        }

    else
        # _jbg_fuc_exist="type -t"
        # _jbg_fuc_exist=( whence -w $@ | grep -q 'function' ) # Changes variable type as well
        
        function _jbg_fuc_exist()
        {
            # echo "$(whence -w $@ | grep -q 'function')"
            if whence -w "$@" | grep -q 'function'; then
                echo 'exist'
            else 
                return
            fi
        }

    fi


    # varibale
    _jobage_dinfo1="$_jobage_wPath/sq.dat"
    _jobage_dinfo2="$_jobage_wPath/sq-1.dat"

    _jobage_default_setting="$_jobage_srcPath/src/setting.default.sh"
    _jobage_setting_loaded='no'
    _jobage_setting="$_jobage_wPath/setting.sh"


    _jobage_array_jobDir=()
    _jobage_array_jobID=()


    # check saving directory
    if [ ! -d "$_jobage_wPath" ]; then
        mkdir -p "$_jobage_wPath"
    fi

    # default setting
    # color 
    _jbg_set_color_start="39m"
    _jbg_set_color_start_checked="96;104m"
    _jbg_set_color_job_wait="33m"
    _jbg_set_color_job_run="32m"
    _jbg_set_color_job_warn="35m"

    # mark
    # one character is required
    _jbg_set_mark_start="*"
    _jbg_set_mark_start_checked=">"
    # two characters are required
    _jbg_set_mark_job_wait="=="
    _jbg_set_mark_job_run=">>"
    _jbg_set_mark_job_warn="><"

    # split line
    # split line : y/n
    _jbg_split_line="y"
    _jbg_split_line_mark="+----"

    # load user setting
    if [ -f "$_jobage_setting" ]; then
        _jobage_setting_loaded='yes'
        source "$_jobage_setting"
    fi

    # detect cluster scheduling system
    n_system=0
    if [[ "$_jobage_system" == '' ]]; then
        if [[ -x "$(command -v bqueues)" ]] && [[ "$(bqueues -V 2>&1 | head -1)" == *'IBM Spectrum LSF'* ]]; then
            _jobage_system='lsf'
            n_system=$((n_system+1))
        fi
        
        if [[ -x "$(command -v squeue)" ]] && [[ "$(squeue -V 2>&1 | head -1)" == *'slurm '* ]]; then
            _jobage_system='slurm'
            n_system=$((n_system+1))
        fi
        
        if [[ -x "$(command -v qstat)" ]] \
            && ( [[ "$(qstat --version 2>&1 | head -1)" =~ "Version" ]] \
                || [[ "$(qstat --version 2>&1 | head -1)" =~ "pbs_version" ]] ); then
            _jobage_system='pbs'
            n_system=$((n_system+1))       
        fi
    else
        if [[ "$_jobage_system" == 'lsf' ]] || [[ "$_jobage_system" == 'slurm' ]] || [[ "$_jobage_system" == "pbs" ]]; then
            n_system=1
        fi
    fi

    if (( n_system == 0 ));then

        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "*|-jbg debug: not found cluster scheduling systems"
            echo "*|-in [lsf, slurm pbs ...]"
        fi
        jbg.help() 
        {
            echo "| a job-management tool for cluster scheduling systems."
            cat "$_jobage_srcPath/src/version.dat";
            echo '| author   : C4r-bs'
            # echo '| C4r homepage : http://papercomment.tech/'
            echo -e '| project link (gitee)  : https://gitee.com/C4r/jobage'
            echo -e '| project link (github) : https://github.com/c4rO-0/jobage'
            echo '| --------'
            echo '| no supported cluster scheduling system found.'
            echo '| please check you are using one of the systems:'
            echo '| lsf   : ' ' run "bqueues -V"'
            echo '| slurm : ' ' run "squeue -V"'
            echo '| pbs   : ' ' run "qstst --version"'
            echo '| --------'
            echo '| found ' "$_jbg_SHELL" " enviroment."
            echo '| found ' "$_jobage_wPath" " as working path."
            if [[ "$_jobage_setting_loaded" == 'no' ]]; then
                echo '| found ' "default setting."
            else
                echo '| found ' "user defined setting."
            fi
            echo '| --------'

        }

    elif (( n_system > 1 ));then
        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "*|-jbg debug: found multiple cluster scheduling systems"
            echo "*|-in [lsf, slurm pbs ...]"
        fi
        jbg.help() 
        {
            echo "| a job-management tool for cluster scheduling systems."
            cat "$_jobage_srcPath/src/version.dat";
            echo '| author   : C4r-bs'
            # echo '| C4r homepage : http://papercomment.tech/'
            echo -e '| project link (gitee)  : https://gitee.com/C4r/jobage'
            echo -e '| project link (github) : https://github.com/c4rO-0/jobage'
            echo '| --------'
            echo '| multiple supported cluster scheduling systems found.'
            echo '| please check you are using one of the systems:'
            echo '| lsf   : ' ' run "bqueues -V"'
            echo '| slurm : ' ' run "squeue -V"'
            echo '| pbs   : ' ' run "qstst --version"'
            echo '| --------'
            echo '| choose one by run:'
            echo '| source mian.sh --jbg_system lsf/slurm/pbs'
            echo '| --------'
            echo '| found ' "$_jbg_SHELL" " enviroment."
            echo '| found ' "$_jobage_wPath" " as working path."
            if [[ "$_jobage_setting_loaded" == 'no' ]]; then
                echo '| found ' "default setting."
            else
                echo '| found ' "user defined setting."
            fi
            echo '| --------'

        }
    else
        if [[ "$_jobage_debug" == 'on' ]]; then
            echo "*|-jbg debug: found " "$_jobage_system"
        fi

        if [[ "$_jobage_system" == 'lsf' ]] && [[ -x "$(command -v bqueues)" ]] && [[ "$(bqueues -V 2>&1 | head -1)" == *'IBM Spectrum LSF'* ]]; then
            if [[ "$_jobage_debug" == 'on' ]]; then
                echo "*|-jbg debug: source " "src/lsf.fuc.sh"
            fi        
            source "$_jobage_srcPath/src/lsf.fuc.sh"
        fi
        
        if [[ "$_jobage_system" == 'slurm' ]] &&  [[ -x "$(command -v squeue)" ]] && [[ "$(squeue -V 2>&1 | head -1)" == *'slurm '* ]]; then
            if [[ "$_jobage_debug" == 'on' ]]; then
                echo "*|-jbg debug: source " "src/slurm.fuc.sh"
            fi             
            source "$_jobage_srcPath/src/slurm.fuc.sh"
        fi
        
        if [[ "$_jobage_system" == 'pbs' ]] && [[ -x "$(command -v qstat)" ]] \
            && ( [[ "$(qstat --version 2>&1 | head -1)" =~ "Version" ]] \
                || [[ "$(qstat --version 2>&1 | head -1)" =~ "pbs_version" ]] ); then
            if [[ "$_jobage_debug" == 'on' ]]; then
                echo "*|-jbg debug: source " "src/pbs.fuc.sh"
            fi   
            source "$_jobage_srcPath/src/pbs.fuc.sh"   
        fi
        
        source "$_jobage_srcPath/src/main.fuc.sh";
    fi

fi
