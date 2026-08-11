#!/bin/sh

set -eu

target=${1:-.external-packages}
mkdir -p "$target"

clone_package () {
    name=$1
    tag=$2
    revision=$3
    repository=$4
    directory="$target/$name"

    if test ! -d "$directory/.git"; then
        git clone --depth 1 --branch "$tag" "$repository" "$directory"
    fi

    actual=$(git -C "$directory" rev-parse HEAD)
    if test "$actual" != "$revision"; then
        echo "$name: expected $revision, found $actual" >&2
        exit 1
    fi
}

clone_package avy 0.5.0 \
    f2cf43b5372a6e2a7c101496c47caaf03338de36 \
    https://github.com/abo-abo/avy.git
clone_package corfu 2.10 \
    4a9c67da16eb64cadaa4bfcc16713188145c83da \
    https://github.com/minad/corfu.git
clone_package diff-hl 1.10.0 \
    b80ff9b4a772f7ea000e86fbf88175104ddf9557 \
    https://github.com/dgutov/diff-hl.git
clone_package magit v4.6.0 \
    b6c512597fd66abe69883a058a2d13bcea76bf33 \
    https://github.com/magit/magit.git
clone_package tempel 1.14 \
    c5fdc3806b486d9d86a54c50efac3d4a141e789d \
    https://github.com/minad/tempel.git
clone_package transient v0.13.5 \
    3d20a780605f0a33d6360dc0a2ce9174c69a9a92 \
    https://github.com/magit/transient.git
clone_package vundo v2.4.0 \
    b89f719824fe5da0f6a7590fad3ece798fd59909 \
    https://github.com/casouri/vundo.git
