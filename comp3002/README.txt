
You need to extend the PATH variable to refer to the "Smalltalk\lib" directory,
which depends on where you placed the Smalltalk folder on your machine.

In Windows 10, just search for "edit the system environment variables"
which brings up a prompter with an "Environment Variables" button
that you click on, then select "Path" in the top section and click
on Edit. Add a new line with the full path to the lib folder; e.g.,

	c:\3D\Smalltalk\lib

Another way to get to the same place is to click on settings,
click on system, click on "Advanced System Settings", click on the
"Advanced Tab", click on "Environment variables", select path
and then click on edit.

Warning: DO NOT REMOVE EXISTING STUFF IN THE Path variable. What
you are doing is appending a new path to the existing path.
