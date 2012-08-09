#!/bin/bash

cnt=0
start_time=`date +%Y-%m-%d\ %H-%M-%S`
retriever_path="/usr/local/retriever"
time_file="/var/log/content-retriever.time"
log_file="/var/log/content-retriever.log."$(date +%Y-%m-%d)

##/var/www/discover.getassembly.com/retriever

echo "" >> $log_file
echo "" >> $log_file
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file
echo "STARTING JOB [`date +%Y-%m-%d\ %H-%M-%S`]" >> $log_file
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file

#-- grab tweets
while [ $cnt -eq 0 ]; do
	echo "TWEET GRAB [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
	cd $retriever_path && php index.php "${start_time}"
	cnt=$((cnt + 1))
done

#-- run thru readability
while [ $cnt -eq 1 ]; do
	echo "READABILITY [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
	cd $retriever_path && python readability_api.py
	cnt=$((cnt + 1))
done

#-- transfer app ready articles
while [ $cnt -eq 2 ]; do
	echo "TRANSFER [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
	cd $retriever_path && php article_transfer.php "${start_time}"
	cnt=$((cnt + 1))
done 

#-- get app store images
while [ $cnt -eq 3 ]; do
	echo "APP IMAGES [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
	cd $retriever_path && php app_images.php "${start_time}"
	cnt=$((cnt + 1))
done

#-- fill retweets
while [ $cnt -eq 4 ]; do
	echo "RETWEETS [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
	cd $retriever_path && php retweets.php "${start_time}"
	cnt=$((cnt + 1))
done

#-- appends extra line w/ finish date
echo "-/>> [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
echo "" >> $time_file


echo "" >> $log_file
echo "" >> $log_file 
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file
echo "FINISHED JOB [`date +%Y-%m-%d\ %H-%M-%S`]" >> $log_file
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file
echo "" >> $log_file
echo "" >> $log_file

#-- exit w/o error
exit 0;
