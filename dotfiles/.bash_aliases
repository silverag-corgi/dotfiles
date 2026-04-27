alias al='cat ~/.bash_aliases'

alias sudo='sudo ' # sudo コマンドでエイリアスを使えるように設定する

if [ -x /usr/bin/dircolors ]; then

test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
alias ls='ls --color=auto --time-style=+"%Y/%m/%d %H:%M:%S %Z"'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

fi

alias ll='ls -AlF'
alias ld='find `pwd` -maxdepth 10 -type d -print0 | xargs -0 ls -AlFd'
alias lf='find `pwd` -maxdepth 10 -type f -print0 | xargs -0 ls -AlFd'
alias li='find `pwd` -maxdepth 10 -print0 | xargs -0 ls -AlFd'

alias c='clear'

alias h='history'

alias date='date +"%Y/%m/%d %H:%M:%S %Z"'

alias mem='free --mega'

alias ipv4='ip -br -4 addr'
alias ipv6='ip -br -6 addr'
