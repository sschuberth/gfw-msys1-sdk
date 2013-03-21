# Introduction

This is [mingwGitDevEnv](https://github.com/sschuberth/mingwGitDevEnv), an Inno Setup based wrapper around [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) (similar to [mingw-get-inst](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/)) to install a development environment for building Git for Windows using MinGW.

# Features

The installer strives to supersede the existing [msysgit net installer](http://code.google.com/p/msysgit/downloads/list?q=netinstall) with some improvements that hopefully make the life of both Git for Windows developers and users much easier. In particluar, the improvements include:

* **Real installer:** Comes with an Inno Setup based installer with uninstall capabilities instead of just a self-extracting archive.

* **Package management:** All required packages are installed via MinGW's new [mingw-get](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/) tool. This means that the installed packages can be updated independently of updates to the mingwGitDevEnv installer, and in turn that there is no need to create a new mingwGitDevEnv installer just because of updates to packages. You have full access to all upstream MSYS / MinGW packages in addition to custom mingwGitDevEnv packages.

* **More consistent naming:** As with [msysgit](http://code.google.com/p/msysgit/), the shipped Git executable is a native Windows application that has been compiled using MinGW. It is not an MSYS application using a Unix emulation layer. Only the shell environment and some tools Git depends on are provided by MSYS. As such, the project is called mingwGitDevEnv (instead of msysGitDevEnv). Moreover, this distinguishes the project from the upcoming "msys git" project, which will be a Git distribution by the MinGW folks that is actually compiled against MSYS.

# Creating mingw-get packages

In order to create packages for use with mingw-get the following steps are necessary:

* Create an [mgwport](http://gitorious.org/mgwport/mgwport/blobs/master/README) / msysport "build recipe" file that downloads the source code, applies optional patches, and packages the archives. Just like MSYS started out as a fork of Cygwin, mgwport is a fork of [cygport](http://sourceware.org/cygwinports/) and thus uses (almost) the same syntax. However, as there seems to be very little documentation about either syntax available and mgwport / cygport are heavily inspired by [Gentoo's Portage](http://en.gentoo-wiki.com/wiki/Portage), the best resource I could possibly find is the [Gentoo Development Guide](http://devmanual.gentoo.org/)'s section about [Ebuild Writing](http://devmanual.gentoo.org/ebuild-writing/), in particular the [Variables](http://devmanual.gentoo.org/ebuild-writing/variables/) article. _(See the [mgwport file for mingw32-openssl](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingw32-openssl/openssl-1.0.0j-1.mgwport) as an example.)_
* Create an xml catalogue / package description file which lists meta-information and dependencies. This is the hardest part as there seems to be no documentation of the format available at all (and cygport does not have this type of file). So probably the best thing you can do is to derive the syntax from the [existing catalogue files](http://sourceforge.net/projects/mingw/files/Installer/mingw-get/catalogue/). _(See the [catalogue file for mingw32-openssl](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingw32-openssl.xml) as an example.)_
* Add the package catalogue's file name to the [master package catalogue file](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/mingwgitdevenv-package-list.xml).
* Run the [compress-xml.sh](https://github.com/sschuberth/mingwGitDevEnv/blob/master/root/packages/compress-xml.sh) script to run LZMA on the xml files.
* Upload the compressed catalogue and updated master catalogue files to one of the web server locations listed as "repository uri" at the end of the [update-mingw-get.sh](https://github.com/sschuberth/mingwGitDevEnv/blob/master/update-mingw-get.sh) script. _(Currently only I have access to this location, so please contact me instead.)_
* Upload the package archives to the web server location that is listed as "download-host uri" in its catalogue file. _(As it probably makes sense to host all mingwGitDevEnv related packages in one place, please contact me instead.)_

# TODOs

* Make all Git tests pass. The tests that are currently failing are:
  * t0061-run-command.sh (1 subtest fails)
  * t1506-rev-parse-diagnosis.sh (11 subtests fail)
  * t3404-rebase-interactive.sh (1 subtest fails)
  * t3703-add-magic-pathspec.sh (2 subtests fail)
  * t3900-i18n-commit.sh (16 subtests fail)
  * t3901-i18n-patch.sh (10 subtests fail)
  * t4003-diff-rename-1.sh (3 subtests fail)
  * t4013-diff-various.sh (83 subtests fail)
  * t4014-format-patch.sh (4 subtests fail)
  * t4034-diff-words.sh (15 subtests fail)
  * t4100-apply-stat.sh (2 subtests fail)
  * t4101-apply-nonl.sh (12 subtests fail)
  * t4109-apply-multifrag.sh (3 subtests fail)
  * t4110-apply-scan.sh (1 subtest fails)
  * t4135-apply-weird-filenames.sh (9 subtests fail)
  * t4208-log-magic-pathspec.sh (2 subtests fail)
  * t4252-am-options.sh (3 subtests fail)
  * t5000-tar-tree.sh (2 subtests fail)
  * t5100-mailinfo.sh (30 subtests fail)
  * t5300-pack-object.sh (4 subtests fail)
  * t5302-pack-index.sh (9 subtests fail)
  * t5303-pack-corruption-resilience.sh (8 subtests fail)
  * t5509-fetch-push-namespaces.sh (1 subtest fails)
  * t5510-fetch.sh (3 subtests fail)
  * t5515-fetch-merge-logic.sh (64 subtests fail)
  * t5516-fetch-push.sh (3 subtests fail)
  * t5602-clone-remote-exec.sh (2 subtests fail)
  * t7003-filter-branch.sh (1 subtest fails)
  * t7201-co.sh (1 subtest fails)
  * t7400-submodule-basic.sh (1 subtest fails)
  * t7401-submodule-summary.sh (11 subtests fail)
  * t7405-submodule-merge.sh (2 subtests fail)
  * t9001-send-email.sh (2 subtests fail)
  * t9700-perl-git.sh (1 subtest fails)
  * t9903-bash-prompt.sh (4 subtests fail)
* Create a new "Git for Windows" installer which also comes with mingw-get package management.
* Capture the console output of mingw-get and show the progress in the mingwGitDevEnv GUI.
* Contribute msysGit's patches to MSYS / MinGW back upstream.
