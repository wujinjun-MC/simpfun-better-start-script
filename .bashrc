# 优化Bash历史记录
export PROMPT_COMMAND="history -a"
export HISTSIZE=100000
export HISTFILESIZE=1000000
#export HISTCONTROL=ignoredups:ignorespace
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

export PATH=$PATH:$HOME/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/usr/lib
# export LD_LIBRARY_PATH=$HOME/lib/lib/x86_64-linux-gnu/gconv:$HOME/lib/lib/x86_64-linux-gnu:$HOME/lib
export LD_LIBRARY_PATH=$HOME/lib
export TERM=xterm-256color
