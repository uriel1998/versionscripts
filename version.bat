@echo off
REM This is the Windows batch file version of this script for NT/XP and later.
REM
REM By Steven Saus
REM Licensed under a Creative Commons BY-SA 3.0 Unported license
REM To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
REM
REM Creates time/date stamped version of file for collaborative work.
REM 
REM Typically run with the filename (full path not needed, but will work with) as
REM the first argument from the commandline.
REM If run with no arguments (or argument that's not /z, /w, or a filename), gives usage
REM
REM ######################Graphical UI instructions#############################################
REM Please note that I have NOT tested Zenity/Wenity in a Windows environment.
REM I've used the example files from the programs to create this, though.
REM You do not need to alter the variables below if the files are in your path or you're just
REM using the command line interface.
REM
REM If Zenity is installed/desired, /z should be the first argument.
REM You should edit this file and put the path to zenity.exe in the line below!
set ZENITYPATH=c:\PATH\TO\zenity.exe
REM Get Zenity here:
REM Windows port of Zenity: http://www.placella.com/software/zenity/
REM
REM Get Wenity here:
REM http://kksw.zzl.org/wenity.html
REM If Wenity (a Java Zenity clone) is installed/desired, /w should be the first argument.
REM You should edit this file and put the path to the wenity.jar file in the line below!
set WENITYPATH=c:\PATH\TO\wenity.jar
REM Please remember that Java must be installed properly and found by your path to use Wenity.
REM You can specify the path to java.exe on the line below.
set JAVAEXE=c:\PATH\TO\java.exe
REM
REM
REM
REM datestamp from http://www.intelliadmin.com/index.php/2007/02/create-a-date-and-time-stamp-in-your-batch-files/
REM filename stripping from http://stackoverflow.com/questions/1472191/getting-the-file-name-without-extension-in-a-windows-batch-script
REM variable path stuff from http://stackoverflow.com/questions/654152/batch-files-get-absolute-path
REM and also from http://blogs.msdn.com/b/ben/archive/2007/03/09/path-manipulation-in-a-batch-file.aspx
REM timestamp from http://www.pcreview.co.uk/forums/batch-file-timestamp-t1466494.html
REM and http://justgeeks.blogspot.com/2008/07/getting-formatted-date-into-variable-in.html
REM argument catching from http://www.techsupportforum.com/forums/f10/check-existence-of-file-or-folder-in-batch-54164.html
REM setting var from output from http://www.tomshardware.com/forum/230090-45-windows-batch-file-output-program-variable
REM 
REM Revision history
REM 20121116: uriel1998: Error checking around java, wenity, and zenity
REM 20121116: uriel1998: Use temp file to avoid environment expansion limitations
REM 20121115: uriel1998: Added code to use wenity
REM 20121115: uriel1998: Added code to use zenity
REM 20121115_2115: uriel1998: Original code


REM initialization
set ORIGFILE=""
set ODRIVE=""
set OPATH=""
set ONAME=""
set OEXT=""
if EXIST %CD%v.tmp del %CD%v.tmp

REM setting time stamp properly so we have padding for hours
set /a UHH=%TIME:~0,2%
set OHH=0%UHH%
set HH=%OHH:~-2%
SET TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%HH%%time:~3,2%%time:~6,2%
REM echo %TIMESTAMP%


REM test if argument passed
if [%1] == [] (goto usage)
IF [%1]==[/w] (goto testjava)
if [%1] == [/W] (goto testjava)
if [%1] == [/z] (goto zenity)
if [%1] == [/Z] (goto zenity)

REM default, run from commandline
REM writing this to a temp file to get around variable expansion limitations
echo %1 > %CD%v.tmp
goto usage

:testzenity
REM Check if user set it in file correctly already
if EXIST %ZENITYPATH% (goto :zenity)
for %%i in (zenity.exe) DO (
	set ZENITYEXE=%%~$PATH:i
)
REM If not set in file correctly, we will end up with null for ZENITYPATH
if [%ZENITYPATH%]==[] (goto :nogui)
:zenity
REM The Windows port of Zenity writes output to a tempfile
%ZENITYEXE% --file-selection > %CD%v.tmp
goto usage

:testjava
if EXIST %JAVAEXE% (goto :wenity)
for %%i in (java.exe) DO (
	set JAVAEXE=%%~$PATH:i
)
if EXIST %JAVAEXE% (goto :testwenity)
@echo.
@echo Java not found in path.  Please ensure you have Java installed correctly to use Wenity.
goto :explain


:testwenity
REM check if user set it in file correctly
if EXIST %WENITYPATH% (goto :wenity)
for %%i in (wenity.jar) DO (
	set WENITYPATH=%%~$PATH:i
)
REM If not set in file correctly, we will end up with null for WENITYPATH
if [%WENITYPATH%]==[] (goto :nogui)

:nogui
	@echo.
	@echo Wenity or Zenity not found in path.  Please put in path or edit script with
	@echo full pathname to Wenity or Zenity.
	goto :explain


:wenity
%JAVAEXE% -jar %wenitypath% -d fileSelector "Please select a file to version"
if %ERRORLEVEL%==0 (
	copy %CD%wenity_response.txt %CD%v.tmp
	del %CD%wenity_response.txt
) else (
    rem this can also be an error, but that check is omitted
    echo File selector is cancelled by user.
	goto :explain
)

:usage
REM Extract file information and slice it into bits.
if EXIST %CD%v.tmp (
	for /f %%i in (%CD%v.tmp) DO (
		set ORIGFILE=%%~fi
		set ODRIVE=%%~di
		set OPATH=%%~pi
		set ONAME=%%~ni
		set OEXT=%%~xi
	)
)
if EXIST %CD%v.tmp (del %CD%v.tmp)

REM test if argument is file, otherwise give help script
if EXIST %ORIGFILE% goto doit
	:explain
	@echo.
	@echo This script copies the input filename with a time date stamp
	@echo Usage: version.bat [filename OR /z OR /w]
	@echo Use the /z option instead of a filename to use Zenity to choose the file
	@echo Use the /w option instead of a filename to use Wenity to choose the file
	@echo.	
	@echo Example:
	@echo Running "version.bat myfile.txt" right now would result in you having
	@echo myfile.txt and myfile_%TIMESTAMP%.txt
	@echo in the same directory.
	goto :eof

REM requirements fulfilled, perform actions
:doit
	set STAMPFILE=%ODRIVE%%OPATH%%ONAME%_%TIMESTAMP%%OEXT% 
	echo Copying %ORIGFILE% to %STAMPFILE%
	copy %ORIGFILE% %STAMPFILE%

:eof
