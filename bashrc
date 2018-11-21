# /etc/bashrc

#======================================
#            File Defaults            =
#======================================
#
# System wide functions and aliases
# Environment stuff goes in /etc/profile
#
# It's NOT a good idea to change this file unless you know what you
# are doing. It's much better to create a custom.sh shell script in
# /etc/profile.d/ to make custom changes to your environment, as this
# will prevent the need for merging in future updates.

# are we an interactive shell?
if [ "$PS1" ]; then
  if [ -z "$PROMPT_COMMAND" ]; then
    case $TERM in
    xterm*|vte*)
      if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
          PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
      elif [ "${VTE_VERSION:-0}" -ge 3405 ]; then
          PROMPT_COMMAND="__vte_prompt_command"
      else
          PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      fi
      ;;
    screen*)
      if [ -e /etc/sysconfig/bash-prompt-screen ]; then
          PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
      else
          PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      fi
      ;;
    *)
      [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
      ;;
    esac
  fi
  # Turn on parallel history
  shopt -s histappend
  history -a
  # Turn on checkwinsize
  shopt -s checkwinsize
  [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
  # You might want to have e.g. tty in prompt (e.g. more virtual machines)
  # and console windows
  # If you want to do so, just add e.g.
  # if [ "$PS1" ]; then
  #   PS1="[\u@\h:\l \W]\\$ "
  # fi
  # to your custom modification shell script in /etc/profile.d/ directory
fi

if ! shopt -q login_shell ; then # We're not a login shell
    # Need to redefine pathmunge, it get's undefined at the end of /etc/profile
    pathmunge () {
        case ":${PATH}:" in
            *:"$1":*)
                ;;
            *)
                if [ "$2" = "after" ] ; then
                    PATH=$PATH:$1
                else
                    PATH=$1:$PATH
                fi
        esac
    }

    # By default, we want umask to get set. This sets it for non-login shell.
    # Current threshold for system reserved uid/gids is 200
    # You could check uidgid reservation validity in
    # /usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi

    SHELL=/bin/bash
    # Only display echos from profile.d scripts if we are no login shell
    # and interactive - otherwise just process them to set envvars
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null
            fi
        fi
    done

    unset i
    unset -f pathmunge
fi
# vim:ts=4:sw=4

#================================================
#            User-edited (my) Prompt            =
#================================================
#
# Pretty CLI options

#----------  attempt 1, keeping solely for the sake of documentation  ----------#
#if [ $(id -u) -eq 0 ];
#then
#    # you are root, set the env variables for root
#    # old:
#    #PS1="\njsore \u \[\e[31m\]\w\[\e[0m\] \n# "
#    # new:
#    #PS1="________________________________________________________________________________\njsore \u \[\e[31m\]\w\[\e[0m\] \n# "
#    # basically, ^^ this ^^ is saying:
#    # ___  newline  "jsore"  username  [color_start  current_directory  color_end_reset_ANSI_escape_sequence]  newline  #
#
#    # working BOLD hash:
#    #PS1="________________________________________________________________________________\njsore \u \[\e[100m\]\w\[\e[0m\] \n \[\e[1m\]#\[\e[0m\] "
#
#    # working background:
#    #PS1="________________________________________________________________________________\njsore \u \[\e[48;5;29m\]\w\[\e[0m\] \n \[\e[1m\]#\[\e[0m\] "
#
#    # WORKING WORKING FINAL I THINK
#    #PS1="________________________________________________________________________________\n\e[0;38;5;231;48;5;240mjsore \u \w\e[0m \n \[\e[1m\]#\[\e[0m\] "
#
#    # attempting to make it smart
#    printer() {
#        num=`echo $(pwd) | wc -c`
#        snum=`echo $(yes "_" | head -n $num)`
#        trim="$(echo -e "${snum}" | tr -d '[:space:]')"
#        echo -e "\n__________${trim}"
#    }
#    #printer
#    PROMPT_COMMAND=printer
#    #if [[ "$PWD" = /root/* ]]; then
#    #    PROMPT_COMMAND=printer
#    #else
#    #    PROMPT_COMMAND="__"
#    #fi
#    #PS1="\e[0;38;5;231;48;5;240mjsore \u \w\e[0m \n\[\e[1m\]#\[\e[0m\] "
#    PS1="\e[0;38;5;231;48;5;240mjsore \e[38;5;38m\u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> #\[\e[0m\] "
#    # echo $(pwd) | wc -c
#
#    # FG colors I like:
#    # BG colors I like:
#    #   42m (light grey, white text)
#    #   100m (darker grey, lesser white text)
#    #   104m (lightish blue, black text)
#else
#    # you are not root, remove root-only variables
#    # old:
#    #PS1="\n\u \[\e[31m\]\w\[\e[0m\] \n\$ "
#    # new:
#    #PS1="________________________________________________________________________________\n\u \[\e[31m\]\w\[\e[0m\] \n\$ "
#    # basically, ^^ this ^^ is saying:
#    # ___  newline  username  [color_start  current_directory  color_end_reset_ANSI_escape_sequence]  newline  $
#    printer() {
#        num=`echo $(pwd) | wc -c`
#        snum=`echo $(yes "_" | head -n $num)`
#        trim="$(echo -e "${snum}" | tr -d '[:space:]')"
#        echo -e "\n_____${trim}"
#    }
#    PROMPT_COMMAND=printer
#    #PS1="\e[0;38;5;231;48;5;240m\u \w\e[0m \n\[\e[1m\]$\[\e[0m\] "
#    PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> $\[\e[0m\] "
#fi
#----------  attempt 1, keeping solely for the sake of documentation  ----------#



#----------  TODO: git integration  ----------#
    # get current branch in git repo
    function parse_git_branch() {
        BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
            STAT=`parse_git_dirty`
            echo "[${BRANCH}${STAT}]"
        else
            echo "No git branch found"
        fi
    }

    # get current status of git repo
    function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
        deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
        bits=''
        if [ "${renamed}" == "0" ]; then
            bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
            bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
            bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
            bits="?${bits}"
        fi
        if [ "${deleted}" == "0" ]; then
            bits="x${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
            bits="!${bits}"
        fi
        if [ ! "${bits}" == "" ]; then
            echo " ${bits}"
        else
            echo "error"
        fi
    }

    #export PS1="\`parse_git_branch\` "
#----------  TODO: git integration  ----------#


#----------  attempt 2, cleaned  ----------#
#
# Note to self: raw version can be found on Node.js/Apache VBox VM


if [ $(id -u) -eq 0 ];
then
    # if we're root...

    # print a line breaker based on length of our $PWD
    printer() {
        num=`echo $(pwd) | wc -c`
        snum=`echo $(yes "_" | head -n $num)`
        trim="$(echo -e "${snum}" | tr -d '[:space:]')"
        echo -e "\n__________${trim}`parse_git_branch`\n"
    }

    # go ahead and spit out ^^^ then continue to $PS1
    PROMPT_COMMAND=printer
    # TODO: clean this up, line breaker while in ~ dir is broken

    # \e[38;5;$VAL  for foreground
    # \e[48;5;$VAL  for background
    # >> _______________________________
    # >> jsore root /var/www/html/assets
    # >> --> #
    PS1="\e[0;38;5;231;48;5;240mjsore \e[38;5;38m\u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> #\[\e[0m\] "
else
    # if we're any other user...

    printer() {
        num=`echo $(pwd) | wc -c`
        snum=`echo $(yes "_" | head -n $num)`
        trim="$(echo -e "${snum}" | tr -d '[:space:]')"
        # less text in prompt so less _'s required here
        echo -e "\n_____${trim}"
    }
    PROMPT_COMMAND=printer

    # \e[38;5;$VAL  for foreground
    # \e[48;5;$VAL  for background
    # >> __________________________
    # >> jsore /var/www/html/assets
    # >> --> $
    PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> $\[\e[0m\] "
fi