if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

    alias config '/usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME/"'

    switch $TERM
        case "linux"
            echo "detected linux terminal, not running oh-my-posh"
        case "*"
             oh-my-posh init fish --config $HOME/.config/oh-my-posh/hanselman.omp.json | source
    end
end
# If not running interactively, don't do anything



