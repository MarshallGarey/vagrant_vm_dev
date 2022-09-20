#!/bin/bash
#echo "hf1"
#echo "hf2"


helpers_variable_file=/opt/slurm/22.05/install/etc/slurm/helpers_variables
touch $helpers_variable_file
if [ -n \"$1\" ]; then
	echo $1 > $helpers_variable_file
fi
cat $helpers_variable_file
