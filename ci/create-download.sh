#!/bin/sh

installer=$(ls -t -1 mingwGitDevEnv-*.exe | head -1)

if [ ! -f $installer ]; then
    echo "ERROR: No installer found, please build it first."
    exit 1
fi

cat > download.html << EOF
<html>
    <head>
        <title>mingwGitDevEnv Last Successful Artifact</title>
        <meta http-equiv="expires" content="0" />
        <meta http-equiv="refresh" content="0; URL=$installer" />
    </head>
</html>
EOF
