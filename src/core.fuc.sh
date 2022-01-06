# basic func
function _jobage_displaytime {
    # help
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo '|-converget seconds to readable time.'
        echo '|-displaytime seconds'
        return
    fi

    local _jobage_core_T=$1
    local _jobage_core_D=$((_jobage_core_T/60/60/24))
    local _jobage_core_H=$((_jobage_core_T/60/60%24))
    local _jobage_core_M=$((_jobage_core_T/60%60))
    local _jobage_core_S=$((_jobage_core_T%60))
    (( $_jobage_core_D > 0 )) && printf '%dd-' $_jobage_core_D
    (( $_jobage_core_H > 0 )) && printf '%dh:' $_jobage_core_H
    (( $_jobage_core_M > 0 )) && printf '%dm:' $_jobage_core_M
    #   (( $D > 0 || $H > 0 || $M > 0 )) && printf ':'
    printf '%ds\n' $_jobage_core_S
}