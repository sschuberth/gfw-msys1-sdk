# Introduction

This is [mingwGitDevEnv](https://github.com/sschuberth/mingwGitDevEnv), an Inno Setup based wrapper around [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) (similar to [mingw-get-inst](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/)) to install a development environment for building Git for Windows using MinGW.

# Features

The installer strives to supersede the existing [msysgit net installer](http://code.google.com/p/msysgit/downloads/list?q=netinstall) with some improvements that hopefully make the life of both Git for Windows developers and users much easier. In particluar, the improvements include:

* **Real installer:** Comes with an Inno Setup based installer with uninstall capabilities instead of just a self-extracting archive.

* **Package management:** All required packages are installed via MinGW's new [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) tool. This means that the installed packages can be updated independently of updates to the mingwGitDevEnv installer, and in turn that there is no need to create a new mingwGitDevEnv installer just because of updates to packages. You have full access to all upstream MSYS / MinGW packages in addition to custom mingwGitDevEnv packages.

* **More consistent naming:** As with [msysgit](http://code.google.com/p/msysgit/), the shipped Git executable is a native Windows application that has been compiled using MinGW. It is not an MSYS application using a Unix emulation layer. Only the shell environment and some tools Git depends on are provided by MSYS. As such, the project is called mingwGitDevEnv (instead of msysGitDevEnv). Moreover, this distinguishes the project from the upcoming "msys git" project, which will be a Git distribution by the MinGW folks that is actually compiled against MSYS.

# Creating mingw-get packages

To create packages for use with mingw-get the following steps are necessary:

* Create an [mgwport](http://gitorious.org/mgwport/mgwport/blobs/master/README) / msysport "build recipe" file that downloads the source code, applies optional patches, and packages the archives. Just like MSYS started out as a fork of Cygwin, mgwport is a fork of [cygport](http://sourceware.org/cygwinports/) and thus uses (almost) the same syntax. However, as there seems to be very little documentation about either syntax available and mgwport / cygport are heavily inspired by [Gentoo's Portage](http://en.gentoo-wiki.com/wiki/Portage), the best resource I could possibly find is the [Gentoo Development Guide](http://devmanual.gentoo.org/)'s section about [Ebuild Writing](http://devmanual.gentoo.org/ebuild-writing/), in particular the [Variables](http://devmanual.gentoo.org/ebuild-writing/variables/) article. _(See the [mgwport file for mingw32-openssl](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingw32-openssl/openssl-1.0.0j-1.mgwport) as an example.)_
* Create an xml catalogue / package description file which lists meta-information and dependencies. This is the hardest part as there seems to be no documentation of the format available at all (and cygport does not have this type of file). So probably the best thing you can do is to derive the syntax from the [existing catalogue files](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/catalogue/). _(See the [catalogue file for mingw32-openssl](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingw32-openssl.xml) as an example.)_
* Add the package catalogue's file name to the [master package catalogue file](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingwgitdevenv-package-list.xml).
* Run the [compress-xml.sh](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/compress-xml.sh) script to run LZMA on the xml files.
* Upload the compressed catalogue and updated master catalogue files to one of the web server locations listed as "repository uri" at the end of the [update-mingw-get.sh](https://github.com/sschuberth/mingwGitDevEnv/blob/master/update-mingw-get.sh) script. _(Currently only I have access to this location, so please contact me instead.)_
* Upload the package archives to the web server location that is listed as "download-host uri" in its catalogue file. _(As it probably makes sense to host all mingwGitDevEnv related packages in one place, please contact me instead.)_

# TODOs

* Create an mgwport file for Tk.
* Make all Git tests pass (compiling Git works, but there seems to be a permission problem with some of the tests).
* Create a new "Git for Windows" installer which also comes with mingw-get package management.
* Capture the console output of mingw-get and show the progress in the mingwGitDevEnv GUI.
* Contribute msysGit's patches to MSYS / MinGW back upstream.
