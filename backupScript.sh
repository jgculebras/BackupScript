#!/bin/bash

function Menu
{
while ! [[ $option =~ $posibleOptions ]]

do
	clear
	echo -e "ASO 2021-2022\nStudent Javier García Culebras"
	echo -e "\nBackup tool for directories"
	echo "-------------------------"
	echo -e "\nMenu"
	echo -e "\t1)Perform a backup"
	echo -e "\t2)Program a backup with cron"
	echo -e "\t3)Restore the content of a backup"
	echo -e "\t4)Exit"
	echo -e "\nOption:"
	
	read option
	
	cd ~ 
	if [ ! -d "$(pwd)/backups" ]
	then
		mkdir backups
	fi
	
	pathToBackups=`find /home -type d -name backups`
	
	clear
	
done

case "$option" in
	1)
		option=0
		performBackup
;;

	2)
		option=0
		programBackup
;;

	3)
		option=0
		recoverBackup
;;

	4)
		echo -e `date +%d/%m/%y-%H:%M`" Program terminated\n"
		sleep 1
		clear
		exit 1
;;
esac
}

function performBackup
{
echo "Menu 1"
echo "Path of the directory:"
read dirPath

clear

if [[ $dirPath == ./* ]]
then
	dirPath="$(pwd)${dirPath:1}"
fi

if [ ! -d "$dirPath" ]
then
	echo -e `date +%d/%m/%y-%H:%M`" The directory doesn't exists.\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
	
else
echo "We will do a backup of the directory $dirPath"
echo "Do you want to proceed(y/n)?"
read yesorno

if [ "$yesorno" != "y" ] && [ "$yesorno" != "n" ]
then
	echo -e `date +%d/%m/%y-%H:%M`" Write a correct input (y/n).\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
else
if [ "$yesorno" == "y" ]
then
	backupName="$(basename -- $dirPath)"-`date +%y%m%d-%H%M`

	cd ~
	
	destinationFolder="$(pwd)/backups/$backupName.tar.gz"
	tar -czvf $destinationFolder $dirPath
	
	echo -e "A backup of directory $dirPath has been done on "`date +%d/%m/%y`" at "`date +%H:%M`".\n" | tee -a $pathToBackups/backup.log
	
	echo -e "The file generated is $backupName and ocupies "`cat $destinationFolder | wc -c`" bytes.\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	clear
fi
fi
fi
}

function programBackup
{
echo "Menu 2"
echo "Absolute path of the directory:"
read absdirPath

if [ ! -d "$absdirPath" ]
then
	echo -e `date +%d/%m/%y-%H:%M`" The directory doesn't exists\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
else
echo "Hour for the backup (0:00-23:59):"
read hour

hours="${hour%%:*}"
minutes="${hour#*:}"
if [[ $hours -ge 0 && $hours -le 23 ]] 
then
if [[ $minutes -ge 0 && $minutes -le 59 ]]
then
	backupName="$(basename -- $absdirPath)"-`date +%y%m%d-`"$hours$minutes"

	echo -e "\nThe backup will execute at $hour. Do you agree? (y/n):"
	read yesorno
	
if [ "$yesorno" != "y" ] && [ "$yesorno" != "n" ]
then
	echo -e `date +%d/%m/%y-%H:%M`" Write a correct input (y/n).\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
else
if [ "$yesorno" == "y" ]
then
	echo "$minutes $hours * * * " $pathToBackupCronScript $absdirPath >> crontasks.sh
crontab crontasks.sh

	echo -e "A backup has been programed to execute at $hours:$minutes\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	clear

fi
fi
else
	echo -e `date +%d/%m/%y-%H:%M`" Minutes to program a backup must be in range [0-59]\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
fi
else
	echo -e `date +%d/%m/%y-%H:%M`" Hours to program a backup must be in range [0-23]\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
fi
fi
}

function recoverBackup
{
echo "Menu 3"
echo "The list of existing backups is:"

cd ~
for file in "$(pwd)/backups"/*
do
	fileName=$(basename -- $file)
	if [ "${fileName##*.}" == "gz" ]
	then
	echo $fileName
	fi
done
echo "Which one do you want to recover:"
read optionRecover

cd ~
optionRecover="$(pwd)/backups/$optionRecover"
if [ ! -f "$optionRecover" ]
then
	echo -e `date +%d/%m/%y-%H:%M`" The backup you specified doesn't exists.\n" | tee -a $pathToBackups/backup.log
	
	sleep 1.5
	
	Menu
else
	tar -xvzf $optionRecover -C /
	
	echo -e "Backup with name $(basename -- $optionRecover) has been restored.\n" | tee -a $pathToBackups/backup.log
		
	sleep 1.5
	
	clear
fi
}

posibleOptions='^[1-4]+$'

pathToBackupScript=`find /home -type f -name backupScript.sh`
pathToBackupCronScript=`find /home -type f -name backupwithcron.sh`

Menu
