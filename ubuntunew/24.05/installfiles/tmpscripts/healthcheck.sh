#!/bin/bash
log="/var/log/healthcheck.log"

# Redirect all output to a file.
exec 2>&1
exec 1>>${log}
echo "Running healthcheck.sh: $(date)"
env
echo ""
echo ""
