#!/bin/bash

export CARGO_TARGET_DIR=/home/whoknows_project/target
while true; do
    if ! cargo run ; then
        exit_status=$?
        echo "Script crashed with exit code ${exit_status}. Restarting..." >&2
        sleep 1
    fi
done
