#!/bin/bash
#
# This is the bash version of this script for *nix and Mac.
#
# By Steven Saus
# Licensed under a Creative Commons BY-SA 3.0 Unported license
# To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
#
# Creates time/date stamped version of file for collaborative work.
# 
# Typically run with the filename (full path not needed, but will work with) as
# the first argument.  
# If run with no arguments (or argument that's not -z or a filename), gives usage
#
# Optional -s switch to work on symlinks - it works on the LINKED file, not the link.
#
# Tested with bash;  should work with zsh (for you OSX folks) 
# If you are using a different shell than bash, you'll probably need to change 
# the "/bin/bash" to your shell interpreter.
# To know what shell you're using, type 
#
# echo $SHELL
#
# in your terminal.
#
######################Graphical UI instructions#############################################
#
# You do not need to alter the variables below if the files are in your path or you're just
# using the command line interface.
#
# If Zenity is installed/desired, -z should be the first argument.
#
# Get Zenity here:
# Zenity: https://live.gnome.org/Zenity
# For OS X: With MacPorts: sudo port install zenity 
#
# If Wenity (java Zenity clone) is installed/desired, -w should be the first argument.
# The script tries to find it if it's executable and in your path, but you
# SHOULD edit this file and put the path to the wenity.jar file in the line below!
wenitypath="/home/steven/Apps/wenity/wenity.jar"
# Get Wenity here:
# http://kksw.zzl.org/wenity.html
#
# You can specify which java executable to use here
javapath="/PATH/TO/java"
#
# realpath answer from 
# http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
#
# Revision history
# 20121116: uriel1998: Error checking around java, wenity, and zenity
# 20121115: uriel1998: Added code to use wenity
# 20121115: uriel1998: Added code to use zenity
# 20121115: uriel1998: Original code

time=`date +_%Y%m%d_%H%M%S` 

# avoiding goto statements or duplication of text here
usage=0
numargs="$#"

# test for arguments
if [ "$numargs" -gt "0" ]; then       
	# test our commandline arguments
	case "$1" in
	"-z" | "-Z" ) 
        # Use zenity test (there will be no filename, so it's the first argument)
                zenitypath=$(which zenity)
                if [ -f "$zenitypath" ]; then
                        origfile=$(`$zenitypath --file-selection`)
                else
                        echo "Zenity either not executable or not found in path."
                fi
                ;;
        "-w" | "-W" )
                # doublechecking if executable and in path if not specified by user above
                if [ ! -f "$wenitypath" ]; then
                        wenitypath=$(which wenity.jar)
                fi
                # ensuring java is present and in path if not specified by user above
                if [ ! -f "$javapath" ]; then
                        javapath=$(which java)
                fi
                if [ -f "$wenitypath" -a -f "$javapath" ]; then
                        "$javapath" -jar "$wenitypath" -d fileselector "Please select an existing file" 
			if [ "$?" -eq 0 ]; then
				# wenity_response is the tempfile output, in the $PWD.
				origfile=$(cat $PWD/wenity_response.txt)
				rm $PWD/wenity_response.txt
			else
				#file not selected, so setting this so it fails.
				origfile=""
			fi
		else
			echo ""
                	echo "Wenity or java not found properly.  Please ensure you have java installed and"
                	echo "wenity either executable and in your path or edit the script with its location."
			echo "Java path=$javapath  Wenity path=$wenitypath"                	
	        fi
		;;
	*)
		#used from the commandline
                origfile="$1"
	esac
	# test if we have a file of some type    
	if [ -f "$origfile" ]; then
		# Tests if not a symlink OR the -s flag is used
		if [ ! -h "$origfile" -o "$2" = "-s" ]; then
			fullpath=$(realpath "$origfile")
			dir=$(dirname "$fullpath")
			filename=$(basename "$fullpath")
			ext=${filename##*.}
			file=${filename%.*}
			newname=$(echo "$dir/$file$time.$ext")
			echo "Copying $fullpath to $newname"
			cp "$fullpath" "$newname"
		else
			echo "Symlink detected and following symlinks not enabled."
			usage=1
		fi
	else
		usage=1
	fi
else
	# no arguments        
        usage=1
fi

# This is separate because I didn't want to write it as a function so others
# could easily learn from and modify this script.

if [ $usage = 1 ];then
        echo " "
        echo "This script copies the input filename with a time date stamp"
        echo "Usage: version.sh [filename | -z | -w] [-s]"
        echo "Use the -z option instead of a filename to use Zenity to choose the file"
        echo "Use the -w option instead of a filename to use Wenity to choose the file"
        echo "Use the -s option if you want it to follow a symlink, otherwise symlinks are ignored."
        echo "Example:"
        echo "Running \"bash version.sh $PWD/myfile.txt\" right now would result in"
        newname=$(echo "$PWD/myfile$time.txt")
        echo "$PWD/myfile.txt and $newname"
        echo "in the same directory."
fi
