#!/bin/bash

PYTHON_SCRIPT_PATH="${1}"

# unused variable: TMP="This variable might become useful at some point. Otherwise delete it." 

while true; do
    if ! python3 "${PYTHON_SCRIPT_PATH}"; then 
        exit_status=$?
        echo "Script crashed with exit code ${exit_status}. Restarting..." >&2
        sleep 1
    fi
done
