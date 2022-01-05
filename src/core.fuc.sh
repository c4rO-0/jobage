# basic func
function _jobage_displaytime {
    # help
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-converget seconds to readable time.'
        echo '|-displaytime seconds'
        return
    fi

    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( $D > 0 )) && printf '%dd-' $D
    (( $H > 0 )) && printf '%dh:' $H
    (( $M > 0 )) && printf '%dm:' $M
    #   (( $D > 0 || $H > 0 || $M > 0 )) && printf ':'
    printf '%ds\n' $S
}