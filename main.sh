# detect PATH
_jobage_srcPath=''
if [[ $SHELL == *"/bash" ]]; then
    _jobage_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_srcPath=$(dirname $(readlink -f "$0"))
fi

# varibale
_jobage_wPath="$HOME/.local/jobage"
_jobage_dinfo1="$_jobage_wPath/sq.dat"
_jobage_dinfo2="$_jobage_wPath/sq-1.dat"

_jobage_default_setting="$_jobage_srcPath/src/setting.default.sh"
_jobage_setting="$_jobage_wPath/setting.sh"

_jobage_system=''
_jobage_is_lsf=''
_jobage_is_slurm=''

_jobage_array_jobDir=()
_jobage_array_jobID=()


_jobage_debug='off'

if [[ "$@" == *"--debug" ]]; then
    _jobage_debug='on'
    echo '*|-jobage(jbg) warning: debug mod is on'
fi


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
    source "$_jobage_setting"
fi

# detect cluster scheduling system
if [ -x "$(command -v bqueues)" ]; then
    _jobage_system='lsf'
    source "$_jobage_srcPath/src/lsf.fuc.sh"
elif [ -x "$(command -v squeue)" ]; then
    _jobage_system='slurm'
    source "$_jobage_srcPath/src/slurm.fuc.sh"
fi

if [[ ! "$_jobage_system" == '' ]]; then
    
    if [[ "$_jobage_debug" == 'on' ]]; then
        echo "*|-jbg debug: found " "$_jobage_system"
    fi
    source "$_jobage_srcPath/src/main.fuc.sh";
else
    if [[ "$_jobage_debug" == 'on' ]]; then
        echo "*|-jbg debug: not found cluster scheduling systems"
        echo "*|-in [lsf, slurm ...]"
    fi
fi