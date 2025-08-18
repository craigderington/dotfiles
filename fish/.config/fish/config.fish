if status is-interactive
    # Commands to run in interactive sessions can go here
    
    if [ -f $HOME/.config/fish/alias.fish ]
        source $HOME/.config/fish/alias.fish
    end

    #zoxidestuff
    if [ -f $HOME/.config/fish/completions/zoxide.fish ]
        source $HOME/.config/fish/completions/zoxide.fish
    end

    # fzf
    if type -q fzf
        fzf --fish | source
    end

    # wormhole
    if test -f ~/.wormhole_completion.fish
        source ~/.wormhole_completion.fish
    end

    # trippy
    if test -f ~/.trip_completion.fish
        source ~/.trip_completion.fish
    end

    # gopath
    set -gx PATH $PATH $HOME/go/bin /usr/local/go/bin

    # cargo
    if test -f $HOME/.cargo/env.fish
        source $HOME/.cargo/env.fish
    end

    # television
    if type -q tv
        tv init fish | source
    end

    #zoxide    
    zoxide init --cmd cd fish | source
end

if status is-login
    # commands to run login shell
end
