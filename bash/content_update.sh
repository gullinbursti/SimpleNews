#!/bin/bash


start_time=`date +%Y-%m-%d\ %H-%M-%S`
retriever_path="/usr/local/retriever"
time_file="/var/log/content-retriever.time"
log_file="/var/log/content-retriever.log"

##"/var/log/content-retriever.log."$(date +%Y-%m-%d)

echo "" >> $log_file
echo "" >> $log_file
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file
echo "STARTING JOB [`date +%Y-%m-%d\ %H-%M-%S`]" >> $log_file
echo "[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]" >> $log_file

cd $retriever_path


#-- grab tweets
echo "TWEET GRAB [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
php index.php "${start_time}"

#-- run thru readability
echo "READABILITY [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
php readability.php "${start_time}"

#-- transfer app ready articles
echo "TRANSFER [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
php article_transfer.php "${start_time}"

#-- get app store images
echo "APP IMAGES [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
php app_images.php "${start_time}"

#-- fill retweets
echo "RETWEETS [`date +%Y-%m-%d\ %H-%M-%S`]" >> $time_file
php retweets.php "${start_time}"


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


# */15	*	*	*	*	/usr/local/bin/content_update.sh >> /var/log/content-retriever 2>&1   
# */15	*	*	*	*	/usr/local/bin/content_update.sh >> /var/log/content-retriever.log.`date +%Y-%m-%d` 2>&1 
