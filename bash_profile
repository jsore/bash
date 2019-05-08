alias open='open -a "Sublime Text"'
alias ssh='ssh -R 52698:localhost:52698 admin@127.0.0.1 -p 2222'
#alias ls='ls -Gp'
# -A    show all files, including hidden, exclude . & ..
# -C    force multicolumn
# -G    enable colors ( equivalent to setting CLICOLOR )
# -p    print '/' after directories
# -T    use with -l, display time info
# -t    sort by recently modified
# -u    sort by recently accessed
alias ls='ls -ACGp'
alias myDefaults='history | grep "defaults write"'
alias cat='bat'
#PS1='OSX \[\e[31m\]\w\[\e[0m\] \n\$ '

# PROMPT_COMMAND='echo "$(history | grep "defaults")" | sed '/^$/d' >> ~/Core/defaults-write-history.txt'
# PROMPT_COMMAND='echo "$(history | grep "defaults")" >> ~/Core/defaults-write-history.txt'

#----------  linode clone  ----------#
#----------  git integration  ----------#
# get current branch in git repo
function parse_git_branch() {
    BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
        STAT=`parse_git_dirty`
        echo "[${BRANCH}${STAT}]"
    else
        #echo "This isn't a Git repo"
        echo "No GitHub remote found"
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
        # if nothing to report, just echo the branch name
        echo ""
    fi
}
#----------  git integration  ----------#


#----------  attempt 2, cleaned  ----------#
#
# Note to self: raw version can be found on Node.js/Apache VBox VM
#

if [ $(id -u) -eq 0 ];
# if we're root...
then
    # print a line breaker based on length of our $PWD and PS1 settings
    printer() {
        #num=`echo $(pwd) | wc -c`
        #snum=`echo $(yes "_" | head -n $num)`
        #trim="$(echo -e "${snum}" | tr -d '[:space:]')"
        #echo -e "\n\e[38;5;180mGit: `parse_git_branch`\e[0m\n__________${trim}"
        #echo -e "\nGit: `parse_git_branch`\n__________${trim}"
        #echo -e "\nGit: `parse_git_branch`\n${trim}"
        echo -e "\nGit: `parse_git_branch`\n"
    }

    # spits out printer(), parse_git_branch(), then continues to $PS1
    PROMPT_COMMAND=printer  # TODO: clean this up, line breaker while in ~ dir is broken

    # foreground:  \e[38;5;$VAL
    # background:  \e[48;5;$VAL
    # TODO: The color options are a mess, convert to variabls and echo them instead
    #PS1="\e[0;38;5;231;48;5;240mjsore \u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> #\[\e[0m\] "
    PS1="\e[0;38;5;231;48;5;240mjsore \u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]\[\e[0m\]"

# else, if we're any other user...
else
    # print a line breaker based on length of our $PWD and PS1 settings
    printer() {
        #num=`echo $(pwd) | wc -c`
        #snum=`echo $(yes "_" | head -n $num)`
        #trim="$(echo -e "${snum}" | tr -d '[:space:]')"
        #echo -e "\nGit: `parse_git_branch`\n_____${trim}"
        #echo -e "\nGit: `parse_git_branch`\n${trim}"

        # attempting to recreate Linode server
        # old
        #echo -e "\nGitHub: `parse_git_branch`\n"
        # 1st attempt, broken, prints to shell as: "\e[38;5;180mGitHub: [master]\e[0m"
        #echo -e "\n\e[38;5;180mGitHub: `parse_git_branch`\e[0m\n"
        #echo -e "\n\e[0;38;5;231;48;5;240m\e[38;5;38mGitHub: `parse_git_branch`\n\[\e[0m\]"

        # http://blog.taylormcgann.com/tag/prompt-color/
        #echo -e "\n\[\033[COLOR_CODE_HERE\]PROMPT_ESCAPE_OR_TEXT_HERE\[\033[0m\]"
        #echo -e "\n\[\033[41m\]GitHub: `parse_git_branch`\[\033[0m\]\n"
        #echo -e "\nGitHub: `parse_git_branch`\n"
        # working:
        # red bg:
        #echo -e "\n\033[41mGitHub: `parse_git_branch`\033[0m\n"
        # light highlight bg white text:
        #echo -e "\n\033[0;38;5;231;48;5;240mGitHub: `parse_git_branch`\033[0m\n"
        # light highlight bg blueish text:
        echo -e "\n\033[0;38;5;231;48;5;240m\033[38;5;38mGitHub: `parse_git_branch`\033[0m"
    }

    # spits out printer(), parse_git_branch(), then continues to $PS1
    PROMPT_COMMAND=printer
    #PROMPT_COMMAND=`echo -e "\[\033[41m\]${printer}\[\033[0m\]"`
    #PROMPT_COMMAND="\e[38;5;180m`printer`\e[0m\n"

    # foreground:  \e[38;5;$VAL
    # background:  \e[48;5;$VAL
    # TODO: The color options are a mess, convert to variabls and echo them instead
    #PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\u \e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]--> $\[\e[0m\] "
    # edit after fixing parse_git_branch colors
    PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\e[38;5;231m\w\e[0m \n\[\e[38;5;231;48;5;240m\]\[\e[0m\]"
    #PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\u \e[38;5;231m\w\e[0m \[\e[38;5;231;48;5;240m\]\[\e[0m\]"
    #PS1="\e[0;38;5;231;48;5;240m\e[38;5;38m\e[38;5;231m\w\e[0m \[\e[38;5;231;48;5;240m\]\e[38;5;38m[\e[0m\]"
fi




### # Setting PATH for Python 3.6
### # The original version is saved in .bash_profile.pysave
### PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
### export PATH
###
### # Setting PATH for Python 3.6
### # The original version is saved in .bash_profile.pysave
### PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
### export PATH
###
### ##
### # Your previous /Users/jsorensen/.bash_profile file was backed up as /Users/jsorensen/.bash_profile.macports-saved_2017-07-05_at_15:28:58
### ##
###
### # MacPorts Installer addition on 2017-07-05_at_15:28:58: adding an appropriate PATH variable for use with MacPorts.
### export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
### # Finished adapting your PATH environment variable for use with MacPorts.


test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export HOMEBREW_GITHUB_API_TOKEN=e751a13fd3b246bc49081f7357e28e5f5aef419a
export BAT_THEME="GitHub"
