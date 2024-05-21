#!/bin/bash
log_file="/var/log/powersave.log"
# Redirect all stdout/stderr to a log file
exec 2>&1
exec 1>>$log_file

echo "RESUME FAIL PROGRAM: ran at: $(date)"
echo "All args:"
echo $@
printenv
echo ""
echo ""
