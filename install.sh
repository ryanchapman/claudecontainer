#!/bin/bash

set -o pipefail

declare -r BOLD="$(tput bold)"
declare -r CLR="$(tput sgr0)"
declare -r RED="$(tput setaf 1 0)"
declare -r GREEN="$(tput setaf 10 0)"
declare -r CYAN="$(tput setaf 14 0)"
declare -r FALSE=0
declare -r TRUE=1
declare -r STATUS_OK=0

function log
{
    if [[ "${1}" == "FATAL" ]]; then
        fatal="FATAL"
        shift
    fi
    echo -n "$(date '+%b %d %H:%M:%S.%N %Z') $(basename -- $0)[$$]: "
    if [[ "${fatal}" == "FATAL" ]]; then echo -n "${RED}${fatal} "; fi
    echo "$*"
    if [[ "${fatal}" == "FATAL" ]]; then echo -n "${CLR}"; exit 1; fi
}

function run_ignerr
{
    _run warn $*
}

function run
{
    _run fatal $*
}

function _run
{
    if [[ $1 == fatal ]]; then
        errors_fatal=$TRUE
    else
        errors_fatal=$FALSE
    fi
    shift
    local cmd="$@"
    log "${BOLD}${cmd}${CLR}"
    eval "${cmd}"
    rc=$?
    if [[ $rc != 0 ]]; then
        msg="${BOLD}${RED}$*${CLR}${RED} returned $rc${CLR}"
    else
        msg="${BOLD}${GREEN}$*${CLR}${GREEN} returned $rc${CLR}"
    fi
    log "$msg"
    # fail fast
    if [[ $rc != 0 && $errors_fatal == $TRUE ]]; then
        pwd
        exit 1
    fi
    return $rc
}

function main
{
  echo "==============================="
  echo "Claude Code Container Installer"
  echo "==============================="

  # sanity check
  if [[ ! -f "$(pwd)/claude.sh" ]]; then
    echo "ERROR: you must run this script in the directory that contains the claude.sh source file"
    exit 1
  fi

  # see if ~/bin is part of PATH
  local needs_bin_added_to_path=$TRUE
  local fullpath_bin="$(dirname ~/bin/.)"
  local tilde_bin="~/bin"
  echo "$PATH" | grep "${fullpath_bin}" &>/dev/null && needs_bin_added_to_path=$FALSE
  echo "$PATH" | grep "${tilde_bin}" &>/dev/null && needs_bin_added_to_path=$FALSE

  echo "This script installs claude.sh into your ~/bin directory."
  if [[ "$needs_bin_added_to_path" == "$TRUE" ]]; then
    echo "You'll need to then add ~/bin to your PATH manually in your ~/.bash_profile"
  fi
  
  local ans=""
  while [[ "$ans" != "y" && "$ans" != "n" ]]; do
    echo -n "Continue? [y/n] "
    read ans
  done

  if [[ "$ans" != "y" ]]; then
      echo "Aborting install."
      exit 1
  fi

  run "mkdir -p ~/bin && cd ~/bin && ln -sf $(pwd)/claude.sh ."

  local hn_short="$(echo $HOSTNAME | cut -f1 -d.)"
  echo "================================================================================================="
  echo "${GREEN}Install complete.${CLR} You can start claude by going to a source directory and executing 'claude.sh .'"
  echo "For example:"
  echo
  echo "  $USER@${hn_short}:~\$ ${BOLD}cd ~/src/kapi${CLR}"
  echo "  $USER@${hn_short}:~/src/kapi\$ ${BOLD}claude.sh .${CLR}"
  echo

  if [[ "$needs_bin_added_to_path" == "$TRUE" ]]; then
    echo "${RED}ACTION REQUIRED:${CLR} You still need to manually add this line to your ~/.bash_profile so that ~/bin will be included:"
    echo
    echo "${BOLD}export PATH=~/bin:$PATH${CLR}"
    echo
    echo "Then restart your terminal session, or run:"
    echo "  $USER@${hn_short}:$(pwd)\$ ${BOLD}source ~/.bash_profile${CLR}"
    echo
  fi

}

main $*
