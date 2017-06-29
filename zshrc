#

## General Options
setopt short_loops
setopt LONG_LIST_JOBS 
setopt NOTIFY
unsetopt BG_NICE 
export KEYTIMEOUT=1

## Key bindings
bindkey -e
bindkey '\e[1;5C' forward-word
bindkey '\e[1;5D' backward-word
bindkey "^[[3~" delete-char
bindkey "^[[P" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^Z" undo
bindkey "^U" redo
bindkey "^X" kill-word
bindkey "^[[Z" reverse-menu-complete
bindkey "^P" insert-last-word

export LS_COLORS=$LS_COLORS:'di=36:ln=31:so=37:pi=33:ex=32:'

myClear() {
    clear
    precmd
    local p="$(print -P $PROMPT)"
    printf "%s" "$p"
}
zle -N clear-screen myClear

function toggle-sudo {
  if [[ "$BUFFER" == "" ]];then
    BUFFER="$(fc -ln -1)"
  fi
  if [[ "$BUFFER" != sudo\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  else
    BUFFER="${BUFFER:5}"
  fi
}
zle -N toggle-sudo
bindkey "^S" toggle-sudo

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^O" edit-command-line

autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey "\e[A" up-line-or-beginning-search

autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "\e[B" down-line-or-beginning-search

## Theme
autoload -U colors && colors
color1=39
color2=161
precmd() { 
  # Vars
  local lastExitCode=$(print -P %?)
  # Left part
  local leftPart="$(print -P "%K{$color1} %n@%m %K{$color2} %~ %k")"
  # Right part
  local rightPart="$(print -P "%K{$color1}%F{$(($lastExitCode?$color2:256))} $lastExitCode %f%k")"
  # Position right part
  local lengthLeftPart=$(( $(echo $leftPart | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -c) - 1 ))
  local lengthRightPart=$(( $(echo $rightPart | sed -r "s:\x1B\[[0-9;]*[mK]::g" | wc -c) - 1 ))
  local padding=$(( $COLUMNS - $lengthLeftPart + ${#rightPart} - $lengthRightPart ))
  # Final print
  printf "%s%${padding}s\n" "$leftPart" "$rightPart"
}
PROMPT="%K{$color1} ❯❯❯ %k "


## History
HISTFILE="${HOME}/.zhistory"       # The path to the history file.
HISTSIZE=10000                   # The maximum number of events to save in the internal history.
SAVEHIST=10000                   # The maximum number of events to save in the history file.
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.

## Dirs
setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt AUTO_NAME_DIRS       # Auto add variable-stored paths to ~ list.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.

# Completion
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt PATH_DIRS           # Perform path search even on command names with slashes.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.
# Add zsh-completions to $fpath.
fpath=("${0:h}/external/src" $fpath)
# Load and initialize the completion system ignoring insecure directories.
autoload -Uz compinit && compinit -i

#
# Styles
#

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${HOME}/.zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
if zstyle -t ':prezto:module:completion:*' case-sensitive; then
    zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      setopt CASE_GLOB
      else
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
            unsetopt CASE_GLOB
            fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
    ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
      ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
      )'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
    dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
      hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
          named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
            operator pcap postfix postgres privoxy pulse pvm quagga radvd \
              rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true


# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Aliases
alias rr='rehash'
alias d='dirs -v'
for index ({1..9}) alias "cd$index"="cd +${index}"; unset index
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

function sm() {
  local IN="eDP-1"
  local EXT="HDMI-1"
  if [[ -n "$1" ]];then
    xrandr --output $EXT --auto --left-of $IN --output $IN --auto
    echo Laptop + Monitor
  elif (xrandr | grep -q "$EXT disconnected"); then
    xrandr --output $EXT --off --output $IN --auto
    echo Laptop
  else
    xrandr --output $IN --off --output $EXT --auto
    echo Monitor
  fi
}


# Aliases
alias d='dirs -v'
alias gut='sudo git'
alias e="$EDITOR"
alias se="sudoedit"

for index ({1..9}) alias "cd$index"="cd +${index}"; unset index
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

alias g="git"
for letter in a b c d e f g h i j k l m n o p q r s t u v w x y z; do                                                                                          
  if ! type "g${letter}" > /dev/null; then
    alias "g${letter}"="g ${letter}"
  fi
done

COMMON_OPTIONS="--color --group-directories-first -F -q"
alias l="ls -1 $COMMON_OPTIONS"
alias ll="ls -l $COMMON_OPTIONS"
alias la="ls -1A $COMMON_OPTIONS"
alias lla="ls -lA $COMMON_OPTIONS"

stty -ixon
export EDITOR="vim"
export VISUAL=$EDITOR
