[Setup]

; Compiler-related
Compression=lzma2/ultra
LZMAUseSeparateProcess=yes
SolidCompression=yes

; Installer-related
AppName=msysGitDevEnv
AppVersion=0.1
DefaultDirName={pf}\msysGitDevEnv
DisableReadyPage=yes
PrivilegesRequired=none

[Files]

Source: root\*; DestDir: {app}; Flags: recursesubdirs

[Code]

function GetAvailablePackages:TArrayOfString;
var
    Path,Name:String;
    FindRec:TFindRec;
    Lines:TArrayOfString;
    i,p,l:Integer;
begin
    Path:=WizardDirValue+'\mingw\var\lib\mingw-get\data\';

    // Loop over all XML files.
    if FindFirst(Path+'*.xml',FindRec) then begin
        try
            repeat
                if LoadStringsFromFile(Path+FindRec.Name,Lines) then begin
                    for i:=0 to GetArrayLength(Lines)-1 do begin
                        Name:=Lines[i];

                        // If look for the package name.
                        p:=Pos('<package name',Name);
                        if p>0 then begin
                            p:=Pos('"',Name);
                            Delete(Name,1,p);
                            p:=Pos('"',Name);
                            Delete(Name,p,Length(Name));
                            Name:=Trim(Name);

                            // Append the name to the list.
                            if Length(Name)>0 then begin
                                l:=GetArraylength(Result);
                                SetArrayLength(Result,l+1);
                                Result[l]:=Name;
                                Log(Name);
                                break;
                            end;
                        end;
                    end;
                end;
            until not FindNext(FindRec);
        finally
            FindClose(FindRec);
        end;
    end;
end;

procedure CurStepChanged(CurStep:TSetupStep);
var
    Packages:TArrayOfString;
begin
    if CurStep<>ssPostInstall then begin
        Exit;
    end;

    Packages:=GetAvailablePackages;
    Log(IntToStr(GetArraylength(Packages)));
end;
