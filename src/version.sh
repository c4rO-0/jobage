# detect PATH
if [[ "$_jbg_SHELL" == *"/bash" ]]; then
    _jobage_version_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_version_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

_jobage_version=$(git show --no-color --pretty=oneline --abbrev-commit | head -n 1 | awk '{print $1}');
_jobage_date=$(date +"%Y-%m-%d")

echo "| jobage version : $_jobage_version on $_jobage_date"> "$_jobage_version_fuc_srcPath/version.dat"
