#!/bin/bash

# make sure this script works even if it was symlinked
# for example, ~/bin/claude.sh -> ~/src/claudecode/claude.sh
#   where claude.sh and docker-compose.yml live
export DOCKERCOMPOSEFILE_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"

function usage
{
    echo "usage: $0 [source_dir]"
    echo
    echo "  source_dir   directory path to share into claude container (read-write access)"
    echo "               defaults to current directory"
    exit 1
}

declare CONTAINER_NAME
function set_container_name
{
    # Convert path to a valid container name
    local path="$1"
    echo "path=$path"
    export CONTAINER_NAME=claude-$(echo "$path" | sed 's|^/*||g;s|/*$||g;s|/|_|g')
}

function main
{
    if [[ "$1" == "-h" ]]; then
        usage
    fi

    local source_dir="${1:-.}"

    if [[ "$source_dir" == "" ]]; then
        usage
        exit 1
    fi

    if [[ "$source_dir" == "." ]]; then
        source_dir="$(pwd)"
    fi

    if [[ ! -d "$source_dir" ]]; then
        echo "ERROR: <source_dir> must be a directory"
        usage
        exit 1
    fi
    
    urls=()
    urls+=("https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/Dockerfile")
    urls+=("https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/init-firewall.sh")
    displayed_message=0
    for url in ${urls[@]}; do
        dstfile="${DOCKERCOMPOSEFILE_DIR}/claudecode/$(basename ${url})"
        if [[ ! -f "${dstfile}" ]]; then
            mkdir -p ${DOCKERCOMPOSEFILE_DIR}/claudecode
            if [[ "$displayed_message" != "1" ]]; then
                echo "Downloading official claude code files"
                displayed_message=1
            fi
            curl -sSL -o "${dstfile}" "${url}"
            echo " ${url} -> ${dstfile}"
        fi
    done
    
    if [[ "$displayed_message" == "1" ]]; then
        echo "Downloading official claude code files: done"
    fi

    # make sure ~/.claude.json exists as a file; otherwise, it gets mounted as a dir in the container and claude won't work
    if [[ ! -f ~/.claude.json ]]; then
        echo '{}' > ~/.claude.json
    fi

    export SRC_FULLPATH="$(realpath $source_dir)"
    export SRC_BASEDIR="$(basename ${SRC_FULLPATH})"

    set_container_name "$(pwd)" # sets CONTAINER_NAME global, used by docker-compose.yml
    local project_name="$(echo $CONTAINER_NAME | tr '[A-Z]' '[a-z]')"
    
    echo "Starting container: $CONTAINER_NAME"

    (cd ${DOCKERCOMPOSEFILE_DIR} ; docker compose -p ${project_name} up claude -d)
    (cd ${DOCKERCOMPOSEFILE_DIR} ; docker compose -p ${project_name} exec -it claude bash)
}

main $*

