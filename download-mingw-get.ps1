# Determine the last mingw-get release from the RSS feed.
$url = "http://sourceforge.net/projects/mingw/rss?path=/Installer/mingw-get&limit=200"
$feed = [xml](Invoke-WebRequest $url)
$item = $feed.rss.channel.item | Where-Object { $_.title.InnerText -CMatch "mingw-get-[0-9]+(\.[0-9]+){1,}-mingw32-.+-bin\.zip" } | Select-Object -First 1

# Download the ZIP archive if it does not exist yet.
$file = $PSScriptRoot + "\" + [System.IO.Path]::GetFileName($item.title.InnerText)

if (!(Test-Path $file)) {
    # Use a fake UserAgent to make the SourceForge redirection work.
    Invoke-WebRequest $item.link -OutFile $file -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -Verbose
} else {
    write "Skipping download, $file already exists."
}

# Extract the ZIP archive (silently overwriting existing files).
$shell = New-Object -ComObject Shell.Application
$zip = $shell.NameSpace((Get-Item -Path $file -Verbose).FullName)
$dest = $shell.namespace((Get-Item -Path "$PSScriptRoot\root\mingw" -Verbose).FullName)
$dest.CopyHere($zip.items(), 0x04 -bOr 0x10)

# Update the catalogue of mingw-get packages.
@'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<profile project="MinGW" application="mingw-get">
    <repository uri="http://prdownloads.sourceforge.net/mingw/%F.xml.lzma?download">
    </repository>
    <repository uri="https://github.com/sschuberth/gfw-msys1-packages/blob/master/%F.xml.lzma?raw=true">
      <package-list catalogue="git-win-sdk-package-list" />
    </repository>
    <system-map id="default">
      <sysroot subsystem="mingw32" path="%R" />
      <sysroot subsystem="msys" path="%R/../" />
    </system-map>
</profile>
'@ | Out-File "$PSScriptRoot\root\mingw\var\lib\mingw-get\data\profile.xml" -Encoding UTF8

& "$PSScriptRoot\root\mingw\bin\mingw-get.exe" update
