#!/usr/bin/bash
export PATH=$PATH:/home/container/bin
tmux new -s disk-usage "ncdu -r --enable-refresh --apparent-size --enable-natsort -e --show-percent --show-graph --show-mtime --show-itemcount"';sleep1'
