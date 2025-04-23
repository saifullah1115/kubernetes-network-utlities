#/bin/bash

archiving_date=$(date -D "%s" -d $(( $(/bin/date +%s ) - 86400 )) +%Y%m%d)
today=$(date +%Y%m%d)
 
mkdir -p "/$dname/archive/logs"
 
for dname in $(cat /scripts/mi-dname.txt)
do
    if [ ! -d "/$dname/archive/logs" ]; then
        mkdir -p /$dname/archive/logs
        echo "- Archiver.API.$dname - WARNING - Archive was not available inside $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
        echo "- Archiver.API.$dname - WARNING - archive directory created inside $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
        echo "- Archiver.API.$dname - INFO    - Archiving started for $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
    else
        echo "- Archiver.API.$dname - INFO - Directory archive already exists in $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
        echo "- Archiver.API.$dname - INFO - Archiving started for $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
    fi
 
    if [ "$(ls /$dname/wso2*.log 2> /dev/null | wc -l)" -ne 0 ]; then
        echo "- Archiver.API.$dname - INFO - Files available for archiving in $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
 
        mkdir -p /$dname/archive/$archiving_date
 
        echo "- Archiver.API.$dname - INFO - Copying file for archiving to /$dname/archive/$archiving_date directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
 
        mv /$dname/wso2*.log /$dname/archive/$archiving_date
        mv /$dname/http_access_*[0-9]* /$dname/archive/$archiving_date
        cd /$dname/archive
 
        echo "- Archiver.API.$dname - INFO - Creating TAR file inside /$dname/archive/$archiving_date directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
       
        # Check if the tar file already exists for today's date
        tar_file="/$dname/archive/$archiving_date.tar.gz"
        counter=1
        while [ -e "$tar_file" ]; do
          tar_file="/$dname/archive/${archiving_date}_${counter}.tar.gz"
          counter=$((counter + 1))
        done 
       
        tar czf "$tar_file" "$archiving_date"
 
        if [[ -f "$tar_file" ]]; then
            echo "- Archiver.API.$dname - INFO - TAR file created for /$dname/archive/$archiving_date directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
            rm -rf $archiving_date
        else
            echo "- Archiver.API.$dname - ERROR - TAR file not created for /$dname/archive/$archiving_date directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
        fi
    else
        echo "- Archiver.API.$dname - WARNING - Nothing to archive in $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
    fi
 
    echo "- Archiver.API.$dname - INFO - Archiving completed for $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
    echo "- Archiver.API.$dname - INFO - Deleting files older than 90 days in $dname directory.." | ts '[%d-%m-%Y %H:%M:%S]' >> /$dname/archive/logs/"$dname"-"$archiving_date".log
    find /$dname/archive/ -type f -mtime +91 -name '*.gz' -exec rm -- '{}' \;
 
    echo -e "\n"
done
