Set shell = CreateObject("WScript.Shell")
Set env = shell.Environment("Process")

' Optionally set the MSYSTEM environment variable to a custom value ("MINGW32" or "MSYS").
linkname = "Git Bash.lnk"
If WScript.Arguments.Length > 0 Then
    msystem = WScript.Arguments(0)
    env("MSYSTEM") = msystem
    linkname = "Git Bash (" & msystem & ").lnk"
End If

' Optionally set a custom start directory.
If WScript.Arguments.Length > 1 Then env("LOGIN_DIR") = WScript.Arguments(1)

Const TemporaryFolder = 2
Set fso = CreateObject("Scripting.FileSystemObject")
linkfile = fso.BuildPath(fso.GetSpecialFolder(TemporaryFolder), linkname)
rootdir = fso.GetParentFolderName(WScript.ScriptFullName)

' Dynamically create a shortcut with the current directory as the working directory.
Set link = shell.CreateShortcut(linkfile)
link.TargetPath = fso.BuildPath(rootdir, "bin\sh.exe")
link.Arguments = "--login -i"
link.IconLocation = fso.BuildPath(rootdir, "mingw\etc\git.ico")
link.Save

Set app = CreateObject("Shell.Application")
app.ShellExecute linkfile
