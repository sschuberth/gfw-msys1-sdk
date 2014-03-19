Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

Const TemporaryFolder = 2
linkfile = fso.BuildPath(fso.GetSpecialFolder(TemporaryFolder), "Git Bash.lnk")
gitdir = fso.GetParentFolderName(WScript.ScriptFullName)

' Dynamically create a shortcut with the current directory as the working directory.
Set link = shell.CreateShortcut(linkfile)
link.TargetPath = fso.BuildPath(gitdir, "bin\sh.exe")
link.Arguments = "--login -i"
link.IconLocation = fso.BuildPath(gitdir, "mingw\etc\git.ico")
link.Save

' Set the HOME environment variable if unset.
Set env = shell.Environment("Process")
If env("HOME") = "" Then env("HOME") = env("HOMEDRIVE") & env("HOMEPATH")

' Set the optional MSYSTEM environment variable (valid values are "MINGW" or "MSYS").
If WScript.Arguments.Length > 0 Then env("MSYSTEM") = WScript.Arguments(0)

' Set the optional start directory.
If WScript.Arguments.Length > 1 Then env("START_DIR") = WScript.Arguments(1)

Set app = CreateObject("Shell.Application")
app.ShellExecute linkfile
