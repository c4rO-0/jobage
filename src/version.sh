# detect PATH
if [[ "$_jbg_SHELL" == *"/bash" ]]; then
    _jobage_version_fuc_srcPath=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
else
    _jobage_version_fuc_srcPath=$(dirname $(readlink -f "$0"))
fi

_jobage_version=$(git show --no-color --pretty=oneline --abbrev-commit | head -n 1);

echo "| jobage version : $_jobage_version" > "$_jobage_version_fuc_srcPath/version.dat"
