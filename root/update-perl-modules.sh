#!/bin/sh

# Patch the default to be automatic configuration.
patch -p 0 -N << "EOF"
--- lib/perl5/5.8/CPAN/FirstTime.pm.orig	Wed Apr 24 14:09:49 2013
+++ lib/perl5/5.8/CPAN/FirstTime.pm	Thu Apr 25 11:41:06 2013
@@ -70,7 +70,7 @@
 
     my $manual_conf =
 	ExtUtils::MakeMaker::prompt("Are you ready for manual configuration?",
-				    "yes");
+				    "no");
     my $fastread;
     {
       local $^W;
EOF

# In order to ignore some failing tests we have to use "force" because our version of CPAN does not yet support "notest".

# Update Prove to a version that has "--jobs" and enable "--archive" support.
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "CPAN::Shell->force(qw(install App::Prove TAP::Harness::Archive));" | tee $(basename $0 .sh).log
