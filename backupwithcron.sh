#!/bin/bash

dirPath=$1
pathToBackups=`find /home -type d -name backups`

backupName="$(basename -- $dirPath)"-`date +%y%m%d-%H%M`

cd ~
	
destinationFolder="$(pwd)/backups/$backupName.tar.gz"
tar -czvf $destinationFolder $dirPath

echo -e "A backup of directory $dirPath has been done on "`date +%d/%m/%y`" at "`date +%H:%M`".\n" >> $pathToBackups/backup.log
	
echo -e "The file generated is $backupName and ocupies "`cat $destinationFolder | wc -c`" bytes.\n" >> $pathToBackups/backup.log
	
