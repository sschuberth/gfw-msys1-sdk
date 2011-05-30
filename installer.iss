#define APP_NAME    'msysGitDevEnv'
#define APP_VERSION '0.1'

[Setup]

; Compiler-related
Compression=lzma2/ultra
LZMAUseSeparateProcess=yes
OutputBaseFilename={#APP_NAME+'-v'+APP_VERSION}
OutputDir=installer
SolidCompression=yes

; Installer-related
AppName={#APP_NAME}
AppVersion={#APP_VERSION}
DefaultDirName={pf}\{#APP_NAME}
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

function GetCheckedPackages(Param:String):String;
var
    i:Integer;
begin
    Result:=Param;

    if PackagesList=nil then begin
        Exit;
    end;

    for i:=0 to PackagesList.Items.Count-1 do begin
        if PackagesList.Checked[i] then begin
            Result:=Result+' '+PackagesList.ItemCaption[i];
        end;
    end;
end;

function NextButtonClick(CurPageID:Integer):Boolean;
var
    ResultCode:Integer;
begin
    if CurPageID<>PackagesPage.ID then begin
        Result:=True;
        Exit;
    end;

    Exec(WizardDirValue+'\mingw\bin\mingw-get.exe',GetCheckedPackages('install'),'',SW_SHOW,ewWaitUntilTerminated,ResultCode);
    Result:=(ResultCode=0);
end;
