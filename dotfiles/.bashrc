# 対話型シェルでない場合、スクリプトの実行を終了する
case $- in
    *i*) ;;
      *) return;;
esac

# コマンド履歴ファイルの設定を追加する
export HISTSIZE=10000                               # メモリで保持するコマンド履歴の最大数
export HISTFILESIZE=10000                           # ファイルに保存するコマンド履歴の最大数
export HISTCONTROL=ignoredups                       # 直前と重複するコマンド履歴をファイルに保存しない
export HISTTIMEFORMAT='[%Y/%m/%d %H:%M:%S %Z] '     # コマンド履歴の時間フォーマット
export PROMPT_COMMAND='h -a; change_prompt_format;' # プロンプトが表示される前に実行するコマンド
shopt -s histappend                                 # シェルを終了する度にコマンド履歴をファイルに追記する

# コマンドラインの設定を追加する
shopt -s checkwinsize   # コマンド実行後にウィンドウサイズをチェックして、自動的にウィンドウサイズを再計算する

# less コマンドで非テキストファイル(pdfやzipなど)を確認する際、より見やすくするために適切なフィルタリングが行われるように設定する
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# エイリアス定義ファイルを読み込む
export BASH_ALIASES_PATH=~/.bash_aliases
if [ -f "${BASH_ALIASES_PATH}" ]; then
    # echo "DBG: '.bash_aliases' is found at '${BASH_ALIASES_PATH}'."
    . "${BASH_ALIASES_PATH}"
fi

# 入力補完機能ファイルを読み込む
export BASH_COMPLETION_USR_PATH=/usr/share/bash-completion/bash_completion
export BASH_COMPLETION_ETC_PATH=/etc/bash_completion
if [ ! $(shopt -oq posix) ]; then
  if [ -f "${BASH_COMPLETION_USR_PATH}" ]; then
    # echo "DBG: 'bash_completion' is found at '${BASH_COMPLETION_USR_PATH}'."
    . "${BASH_COMPLETION_USR_PATH}"
  elif [ -f "${BASH_COMPLETION_ETC_PATH}" ]; then
    # echo "DBG: 'bash_completion' is found at '${BASH_COMPLETION_ETC_PATH}'."
    . "${BASH_COMPLETION_ETC_PATH}"
  fi
fi

# プロンプトの表示形式を変更する
export GIT_PROMPT_SH_PATH=~/workspace/Git/private/git/git/contrib/completion/git-prompt.sh
function change_prompt_format() {
    local remove_color='\[\033[00;00m\]'
    local ps1_user_color='\[\033[01;32m\]'
    local ps1_work_color='\[\033[01;34m\]'

    if [ ! -f "${GIT_PROMPT_SH_PATH}" ]; then
        echo "ERR: 'git-prompt.sh' is not found at '${GIT_PROMPT_SH_PATH}'."
        PS1="\n[${ps1_user_color}\u${remove_color} ${ps1_work_color}\w${remove_color}]\n\$ "
    else
        # echo "DBG: 'git-prompt.sh' is found at '${GIT_PROMPT_SH_PATH}'."
        . "${GIT_PROMPT_SH_PATH}"

        if [ ! "$(declare -F __git_ps1)" ]; then
            echo "ERR: '__git_ps1' function is not defined after sourcing 'git-prompt.sh'."
            PS1="\n[${ps1_user_color}\u${remove_color} ${ps1_work_color}\w${remove_color}]\n\$ "
        else
            # echo "DBG: '__git_ps1' function is defined after sourcing 'git-prompt.sh'."

            GIT_PS1_SHOWCOLORHINTS=true     # 色付きで表示する(true/"")
            GIT_PS1_SHOWCONFLICTSTATE=yes   # 未解決のコンフリクト(CONFLICT)の有無を表示する(yes/no)
            GIT_PS1_SHOWDIRTYSTATE=true     # ステージ(+)、未ステージ(*)の有無を表示する(true/"")
            GIT_PS1_SHOWSTASHSTATE=true     # スタッシュ($)の有無を表示する(true/"")
            GIT_PS1_SHOWUNTRACKEDFILES=true # 未追跡ファイル(%)の有無を表示する(true/"")
            GIT_PS1_SHOWUPSTREAM=auto       # upstreamとの差分の有無を表示する(auto/"")

            local ps1_git_info="$(__git_ps1 ' (%s)')"
            # echo "DBG: output by '__git_ps1' function is '${ps1_git_info}'."
            PS1="\n[${ps1_user_color}\u${remove_color} ${ps1_work_color}\w${remove_color}${ps1_git_info}]\n\$ "
        fi
    fi
}

# SSHの自動認証を有効化する
export SSH_KEY_PATH=~/.ssh/id_rsa
export KEYCHAIN_PATH=/usr/bin/keychain
if [ ! -f "${SSH_KEY_PATH}" ]; then
    # echo "DBG: 'id_rsa' is not found at '${SSH_KEY_PATH}'."
    :
elif [ ! -x "${KEYCHAIN_PATH}" ]; then
    # echo "DBG: '${KEYCHAIN_PATH}' is not found or not executable."
    :
else
    # echo "DBG: 'id_rsa' is found at '${SSH_KEY_PATH}'."
    ${KEYCHAIN_PATH} -q --nogui ${SSH_KEY_PATH}
    source ~/.keychain/${HOSTNAME}-sh
fi
