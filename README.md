versionscripts
==============

Versioning Scripts in Bash and Windows Batch file formats with documentation in files.

Licensed under a Creative Commons BY-SA 3.0 Unported license
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.

Creates time/date stamped version of any file for collaborative work by creating a copy of FILENAME.EXTENSION to FILENAME_YYYYMMDD_HHMMSS.EXTENSION .  Particularly designed for people who need versioning but their partners don't use/understand/etc things like git.  Includes hooks for a GUI interface using Zenity or its Java clone Wenity.

Typically run with the filename (full path not needed, but will work with) as the first argument.

Originally found at https://gist.github.com/4083393
