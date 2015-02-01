#!/usr/bin/env bash

THEME_PROMPT_SEPARATOR=""
THEME_PROMPT_LEFT_SEPARATOR=""

SHELL_SSH_CHAR=" "
SHELL_THEME_PROMPT_COLOR=32
SHELL_SSH_THEME_PROMPT_COLOR=208

VIRTUALENV_CHAR="⒫ "
VIRTUALENV_THEME_PROMPT_COLOR=35

SCM_NONE_CHAR=""
SCM_GIT_CHAR=" "
PROMPT_CHAR="❯"

SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""

SCM_THEME_PROMPT_CLEAN_COLOR=4
SCM_THEME_PROMPT_DIRTY_COLOR=88
SCM_THEME_PROMPT_STAGED_COLOR=6
SCM_THEME_PROMPT_UNSTAGED_COLOR=92
SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}

CWD_THEME_PROMPT_COLOR=240
SEGMENT_AT_LEFT=0

LAST_STATUS_THEME_PROMPT_COLOR=196

CLOCK_THEME_PROMPT_COLOR=240

BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR=76
BATTERY_STATUS_THEME_PROMPT_LOW_COLOR=208
BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR=196
BATTERY_STATUS_THEME_PROMPT_COLOR=${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}

THEME_PROMPT_CLOCK_FORMAT=${THEME_PROMPT_CLOCK_FORMAT:=" %a %H:%M:%S "}

function set_rgb_color {
    if [[ "${1}" != "-" ]]; then
        fg="38;5;${1}"
    fi
    if [[ "${2}" != "-" ]]; then
        bg="48;5;${2}"
        [[ -n "${fg}" ]] && bg=";${bg}"
    fi
    echo -e "\[\033[${fg}${bg}m\]"
}

function powerline_shell_prompt {
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${USER}@${HOSTNAME}"
        SHELL_THEME_PROMPT_COLOR="${SHELL_SSH_THEME_PROMPT_COLOR}"
    else
        SHELL_PROMPT="${USER}"
    fi
    RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#SHELL_PROMPT} + 3 ))
    SHELL_PROMPT=$(set_rgb_color ${SHELL_THEME_PROMPT_COLOR} -)${THEME_PROMPT_LEFT_SEPARATOR}${normal}"${bold_white}$(set_rgb_color - ${SHELL_THEME_PROMPT_COLOR}) ${SHELL_PROMPT} ${normal}"
    LAST_THEME_COLOR=${SHELL_THEME_PROMPT_COLOR}
}

function powerline_virtualenv_prompt {
    local environ=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        environ="$CONDA_DEFAULT_ENV"
        VIRTUALENV_CHAR="⒞"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        environ=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$environ" ]]; then
        VIRTUALENV_PROMPT="$(set_rgb_color - ${VIRTUALENV_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$environ ${normal}"
        if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
            VIRTUALENV_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${VIRTUALENV_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${VIRTUALENV_PROMPT}
        fi
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
        (( SEGMENT_AT_LEFT += 1 ))
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars
    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 3 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_STAGED_COLOR}
        elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
        elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_DIRTY_COLOR}
        else
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            SCM_PROMPT=" ${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
        fi
        SCM_PROMPT="$(set_rgb_color - ${SCM_THEME_PROMPT_COLOR})${SCM_PROMPT} ${normal}"
        LAST_THEME_COLOR=${SCM_THEME_PROMPT_COLOR}
        (( SEGMENT_AT_LEFT += 1 ))
    else
        SCM_PROMPT=""
    fi
}

function powerline_cwd_prompt {
    CWD_PROMPT="$(set_rgb_color - ${CWD_THEME_PROMPT_COLOR}) \w ${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"
    if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
        CWD_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${CWD_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${CWD_PROMPT}
        SEGMENT_AT_LEFT=0
    fi
    LAST_THEME_COLOR=${CWD_THEME_PROMPT_COLOR}
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT=""
    else
        LAST_STATUS_PROMPT="$(set_rgb_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ${LAST_STATUS} ${normal}"
    fi
}

function powerline_clock_prompt {
    local CLOCK="$(date +"${THEME_PROMPT_CLOCK_FORMAT}")"

    CLOCK_PROMPT=$(set_rgb_color ${CLOCK_THEME_PROMPT_COLOR} -)${THEME_PROMPT_LEFT_SEPARATOR}${normal}$(set_rgb_color - ${CLOCK_THEME_PROMPT_COLOR})${CLOCK}${normal}
    RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#CLOCK} + 2 ))
    LAST_THEME_COLOR=${CLOCK_THEME_PROMPT_COLOR}
}

function powerline_battery_status_prompt {
    BATTERY_STATUS="$(battery_percentage)"
    if [[ "${BATTERY_STATUS}" -le 5 ]]; then
        BATTERY_STATUS_THEME_PROMPT_COLOR="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
    elif [[ "${BATTERY_STATUS}" -le 25 ]]; then
        BATTERY_STATUS_THEME_PROMPT_COLOR="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
    fi
    BATTERY_PROMPT="$(set_rgb_color ${BATTERY_STATUS_THEME_PROMPT_COLOR} ${LAST_THEME_COLOR})${THEME_PROMPT_LEFT_SEPARATOR}${normal}$(set_rgb_color - ${BATTERY_STATUS_THEME_PROMPT_COLOR}) ${BATTERY_STATUS}% "
    RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#BATTERY_STATUS} + 2 ))
    LAST_THEME_COLOR=${BATTERY_STATUS_THEME_PROMPT_COLOR}
}

function powerline_prompt_command() {
    local LAST_STATUS="$?"
    local MOVE_CURSOR_RIGHTMOST='\033[500C'
    RIGHT_PROMPT_LENGTH=0

    ## left prompt ##
    powerline_scm_prompt
    powerline_virtualenv_prompt
    powerline_cwd_prompt
    powerline_last_status_prompt LAST_STATUS
    ## right prompt ##
    powerline_clock_prompt
    powerline_battery_status_prompt
    powerline_shell_prompt
    FIRST_LINE="${SCM_PROMPT}${VIRTUALENV_PROMPT}${CWD_PROMPT}${MOVE_CURSOR_RIGHTMOST}\033[${RIGHT_PROMPT_LENGTH}D${CLOCK_PROMPT}${BATTERY_PROMPT}${SHELL_PROMPT}${normal}"

    PS1="${FIRST_LINE}\n${LAST_STATUS_PROMPT}${PROMPT_CHAR} "
}

PROMPT_COMMAND=powerline_prompt_command
