# Introduction

This is [mingwGitDevEnv](https://github.com/sschuberth/mingwGitDevEnv), an Inno Setup based wrapper around [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) (similar to [mingw-get-inst](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/)) to install a development environment for building Git for Windows using MinGW.

# Features

The installer strives to supersede the existing [msysgit net installer](http://code.google.com/p/msysgit/downloads/list?q=netinstall) with some improvements that hopefully make the life of both Git for Windows developers and users much easier. In particluar, the improvements include:

* More consistent naming: As with [msysGit](http://code.google.com/p/msysgit/), the shipped Git executable is a native Windows application that has been compiled using MinGW. It is not an MSYS application using a Unix emulation layer. Only the shell environment and some tools Git depends on are provided by MSYS. As such, the project is called mingwGitDevEnv (instead of msysGitDevEnv). Moreover, this distinguishes the project from the upcoming "msys git" project, which will be a Git version by the MinGW folks that is actually compiled against MSYS.

* Real installer: Comes with an Inno Setup based installer with uninstall capabilities instead of just a self-extracting archive.

* Package management: All required packages are installed via MinGW's new [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) tool. This means that the installed packages can be updated independently of updates to the mingwGitDevEnv installer, and in turn that there is no need to create a new mingwGitDevEnv installer just because of updates to packages. You have full access to all upstream MSYS / MinGW packages in addition to custom mingwGitDevEnv packages.

# TODOs

* Create an mgwport file for Tk.
* Convert the current pkgbuild.sh script for OpenSSL to an mgwport file.
* Make all Git tests pass (compiling Git works, but there seems to be a permission problem with some of the tests).
* Create a new "Git for Windows" installer which also comes with mingw-get package management.
