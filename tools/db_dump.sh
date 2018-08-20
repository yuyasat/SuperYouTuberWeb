#!/bin/bash

file_path="/tmp/superyoutuber_dumpfile_$(date '+%Y%m%d_%H%M%S').sql"
database="ebdb"
hostname=$1
username=$2

pg_dump -a -h $hostname -U $username -p 5432 -t categories -t featured_movies -t locations -t movie_categories -t movie_tags -t movies -t sns_accounts -t tags -t users -t video_artists -t special_categories -t advertisements -t movie_registration_definitions $database | gzip > "$file_path.gz"

# scp -i ~/.ssh/super-youtuber-eb ec2-user@ip_address:/tmp/superyoutuber_dumpfile_xxx.sql.gz tmp/superyoutuber_dumpfile_xxx.sql.gz
