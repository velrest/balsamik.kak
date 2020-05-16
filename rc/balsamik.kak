# My own attempt at a explorer with Blackjack and Lego: balsamik
define-command -docstring  "balsamik <path>: vim-vinegar like file browser" -params 1 -file-completion balsamik %{

    # Save the previous selection so we can get back
    execute-keys <c-s>

    # Save the real path to the file
    evaluate-commands %sh{
        path=$(realpath $1)
        if [ -f $path ]; then
            echo "set-register p $(dirname $path)"
            echo "set-register f $(basename $path)"
        else
            echo "set-register p $path"
        fi
    }

    # echo -debug "[balsamik.kak] Output register set: %reg{o}"

    # echo -debug %sh{
    #     echo "[balsamik.kak] Test if $kak_reg_o exists"
    #     test -e $kak_reg_o && echo "exists" || echo "File does not extst using mkfif"
    # }
    nop %sh{
        # Create a temporary fifo for communication if none exists
        test -e $kak_reg_o || mkfifo $kak_reg_o
        command="ls -ap1 $kak_reg_p"
        # run command detached from the shell
        (echo "Command: $command" > $kak_reg_o 2>&1 &) > /dev/null 2>&1 < /dev/null
        ((eval $command) > $kak_reg_o 2>&1 &) > /dev/null 2>&1 < /dev/null
    }

    # Open the file in Kakoune
    edit! -fifo %reg{o} *balsamik*


}

define-command -hidden -docstring  "balsamik-traverse-up: traverse one dir up" balsamik-traverse-up %{
    # If we dont remove the buffer we have weird selection issues 
    delete-buffer *balsamik*
    balsamik "%reg{p}/../"
}

hook global BufOpenFifo \*balsamik\* %{

    map -- buffer normal - ": balsamik-traverse-up<ret>"

    # Replace this with a usermode since this is overriding the default <c> command
    map buffer normal c "/<c-r><f><ret>"

    hook buffer NormalKey <ret> %{
        # We use this instead of <x> to remove the newline
        execute-keys <g><i><s-g><l>
        # echo -debug "[balsamik.kak] Open file: %reg{p}/%val{selection}"
        set-register s %val{selection}
        # If we dont remove the buffer we have wierd selection issues 
        delete-buffer *balsamik*
        try %{
            edit "%reg{p}/%reg{s}"
        } catch %{
            echo -debug "[balsamik.kak] Error while opening %reg{p}/%reg{s} . Trying again with balsamik"
            balsamik "%reg{p}/%reg{s}"
        }

    }
}

hook global KakBegin .* %{
    set-register o %sh{ echo $(mktemp -d -t kak-temp-balsamik-${kak_session}-XXXXXXXX)/fifo }
    # echo -debug "[balsamik.kak] Setup tmp file : %reg{o}"
}

hook global KakEnd .* %{
    try %{ nop %sh{rm -r /tmp/kak-temp-balsamik-${kak_session}-*} }
}
