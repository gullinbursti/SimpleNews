#!/bin/bash

start_time=`date +%Y-%m-%d`
log_file="/var/log/content-retriever.log"

mv "${log_file}" "${log_file}."$(date +%Y-%m-%d)
touch "${log_file}"

#-- exit w/o error
exit 0;
