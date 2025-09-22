#!/bin/bash

function usage
{
    echo "usage: $0 <source_dir>"
    echo
    echo "  source_dir   directory path to share into claude container (read-write access)"
    exit 1
}

if [[ "$1" == "" ]]; then
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "ERROR: <source_dir> must be a directory"
    usage
    exit 1
fi

urls=()
urls+=("https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/Dockerfile")
urls+=("https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/init-firewall.sh")
displayed_message=0
for url in ${urls[@]}; do
    dstfile="claudecode/$(basename ${url})"
    if [[ ! -f "${dstfile}" ]]; then
        mkdir -p ./claudecode
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

export SRC_FULLPATH="$(realpath $1)"
export SRC_BASEDIR="$(basename ${SRC_FULLPATH})"
docker compose up claude -d
docker compose exec -it claude bash
