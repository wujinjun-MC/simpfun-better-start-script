if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.inputrc ]
then
    bind -f ~/.inputrc
fi

# 优化Bash历史记录
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
export HISTSIZE=100000
export HISTFILESIZE=1000000
#export HISTCONTROL=ignoredups:ignorespace
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize
stty -ixon

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export PATH=$PATH:$HOME/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/usr/lib
# export LD_LIBRARY_PATH=$HOME/lib/lib/x86_64-linux-gnu/gconv:$HOME/lib/lib/x86_64-linux-gnu:$HOME/lib
export LD_LIBRARY_PATH=$HOME/lib
export TERM=xterm-256color
