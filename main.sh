
# varibale
_jobage_wPath="$HOME/.local/jobage"
_jobage_dinfo1="$_jobage_wPath/sq.dat"
_jobage_dinfo2="$_jobage_wPath/sq-1.dat"

_jobage_system=''
_jobage_is_lsf=''
_jobage_is_slurm=''

_jobage_array_jobDir=()
_jobage_array_jobID=()

_jobage_srcPath=''

# detect PATH
if [[ $SHELL == *"/bash" ]]; then
    _jobage_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_srcPath=$(dirname $(readlink -f "$0"))
fi

# check saving directory
if [ ! -d "$_jobage_wPath" ]; then
    mkdir -p "$_jobage_wPath"
fi

# detect cluster scheduling system
if [ -x "$(command -v bqueues)" ]; then
    _jobage_system='lsf'
elif [ -x "$(command -v squeue)" ]; then
    _jobage_system='slurm'
fi

if [[ ! "$_jobage_system" == '' ]]; then
    # echo "found " "$_jobage_system"
    source "$_jobage_srcPath/src/main.fuc.sh";
fi