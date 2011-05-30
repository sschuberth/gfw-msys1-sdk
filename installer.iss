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

var
    PackagesPage:TWizardPage;
    PackagesList:TNewCheckListBox;

procedure InitializeWizard;
var
    PrevPageID:Integer;
begin
    PrevPageID:=wpInstalling;

    PackagesPage:=CreateCustomPage(
        PrevPageID,
        'Package selection',
        'Which packages would like to have installed?'
    );
    PrevPageID:=PackagesPage.ID;

    PackagesList:=TNewCheckListBox.Create(PackagesPage);
    with PackagesList do begin
        Parent:=PackagesPage.Surface;
        Width:=PackagesPage.SurfaceWidth;
        Height:=PackagesPage.SurfaceHeight;
    end;
end;

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
    NumPackages,i:Integer;
begin
    if CurStep<>ssPostInstall then begin
        Exit;
    end;

    Packages:=GetAvailablePackages;
    NumPackages:=GetArrayLength(Packages);

    if NumPackages=0 then begin
        // TODO: Error handling.
        Exit;
    end;

    PackagesPage.Description:='Which of these '+IntToStr(NumPackages)+' packages would like to have installed?';

    for i:=0 to GetArrayLength(Packages)-1  do begin
        PackagesList.AddCheckBox(Packages[i],'',0,False,True,False,True,nil);
    end;
end;
