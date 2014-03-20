# Introduction

This is [mingwGitDevEnv](https://github.com/sschuberth/mingwGitDevEnv), an Inno Setup based wrapper around [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) (similar to [mingw-get-inst](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/)) to install a development environment for building Git for Windows using MinGW.

# Features

The installer strives to supersede the existing [msysgit net installer](http://code.google.com/p/msysgit/downloads/list?q=netinstall) with some improvements that hopefully make the life of both Git for Windows developers and users much easier. In particluar, the improvements include:

* **Real installer:** Comes with an Inno Setup based installer with uninstall capabilities instead of just a self-extracting archive.

* **Package management:** All required packages are installed via MinGW's new [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) tool. This means that the installed packages can be updated independently of updates to the mingwGitDevEnv installer, and in turn that there is no need to create a new mingwGitDevEnv installer just because of updates to packages. You have full access to all upstream MSYS / MinGW packages in addition to custom mingwGitDevEnv packages.

* **Custom packages:** mingwGitDevEnv provides several updated and custom packages to improve the Git experience on Windows.

* **Execution of batch files:** You can execute _*.bat_ / _*.cmd_ files right away without manually prefixing them with _cmd.exe_.

* **More consistent naming:** The included Git executable is a native Windows application that has been compiled using MinGW, it is not an MSYS application using a Unix emulation layer. Only the shell environment and some tools Git depends on are provided by MSYS. This is also the case for the [msysgit](http://code.google.com/p/msysgit/) project, but as it contains "msys" in its name this has always been a source of confusion. Consequently, this project is called _mingwGitDevEnv_.

# Download

Choose between the latest [stable release](https://github.com/sschuberth/mingwGitDevEnv/releases/download/v0.2/mingwGitDevEnv-v0.2.exe) or the latest [snapshot release](http://mingwgitdevenv.cloudapp.net/job/mingwGitDevEnv-installer/lastSuccessfulBuild/artifact/download.html).

# Getting involved

## Setting up the environment

If you start from scratch without an existing MSYS environment (or Git client, for that matter) you have sort of a chicken-and-egg problem: In order to build the mingwGitDevEnv installer or create mingw-get packages (see the [next section](#creating-mingw-get-packages)) you need various MSYS tools like curl or wget, sed, lzma, tar, unzip. The mingwGitDevEnv installer provides those tools, but you do not have the installer yet. The easiest way to solve this is by downloading an already existing [snapshot release](http://mingwgitdevenv.cloudapp.net/job/mingwGitDevEnv-installer/lastSuccessfulBuild/artifact/download.html) of the mingwGitDevEnv installer, run it to set up the development environment, and use that environment to work on mingwGitDevEnv itself. To do so, select _Start the development environment_ on the installer's final page and type at the prompt:

    $ git clone https://github.com/sschuberth/mingwGitDevEnv.git  # Clone the repository (or your fork of it)
    $ cd mingwGitDevEnv                                           # Change to the working tree

**Then, start hacking on mingwGitDevEnv!** Everything in the _root_ directory goes as-is to the installation directory as created by the mingwGitDevEnv installer. In particular, the [mgwport / msysport](http://gitorious.org/mgwport/mgwport/blobs/master/README) and catalogue / package description files for our custom MinGW / MSYS packages are in the _packages_ subdirectory. In case you would like to update one of the packages to a more recent version or create  new package, that is the place to go.

When you are done, building an up-to-date mingwGitDevEnv installer is done by these steps:

    $ ./update-mingw-get.sh  # Download the most recent catalogue / package description files
    $ ./build-installer.sh   # Create the installer

If everything went fine you should now have a file matching _mingwGitDevEnv-*.exe_ which you can use to install the Git Development Environment including your changes.

## Creating mingw-get packages

Please see the separate [mingwGitDevEnv-packages](https://github.com/sschuberth/mingwGitDevEnv-packages) repository for details.

## TODOs (roughly in order of priority)

* Make `git help -a` work when built-ins are removed.
* Make all Git tests pass, see the [test results](http://mingwgitdevenv.cloudapp.net/job/mingwGitDevEnv-test/lastSuccessfulBuild/) for the latest [snapshot build](http://mingwgitdevenv.cloudapp.net/job/mingwGitDevEnv-installer/lastSuccessfulBuild/).
* Upgrade Perl (to a version that includes [this patch](https://github.com/msysgit/msysgit/issues/61#issuecomment-10695361))
* Upgrade SVN libraries (requires new Perl)
* Create a new "Git for Windows" installer which also comes with mingw-get package management.
* Integrate [Karsten Blees' Unicode patches](https://github.com/kblees/msysgit).
* Create a 64-bit version of "Git for Windows".
* Contribute [patches to MSYS](https://github.com/sschuberth/mingwGitDevEnv-packages/tree/master/msys-core) back upstream.
* Capture the console output of mingw-get and show the progress in the mingwGitDevEnv GUI.
