# 优化Bash历史记录
export PROMPT_COMMAND="history -a; history -n"
export HISTSIZE=100000
export HISTFILESIZE=1000000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%F %T "

export PATH=$PATH:$HOME/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/usr/lib
# export LD_LIBRARY_PATH=$HOME/lib/lib/x86_64-linux-gnu/gconv:$HOME/lib/lib/x86_64-linux-gnu:$HOME/lib
export LD_LIBRARY_PATH=$HOME/lib
export TERM=xterm-256color
