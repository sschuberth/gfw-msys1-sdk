Set shell = CreateObject("WScript.Shell")
command = "cmd /c msys.bat"
If WScript.Arguments.Length > 0 Then command = command & " " & WScript.Arguments(0)
shell.Run command, 0, false
