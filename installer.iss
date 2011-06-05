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

{
    XML parsing stuff
}

function GetFirstQuotedString(Name:String):String;
var
    p:Integer;
begin
    p:=Pos('"',Name);
    if p>0 then begin
        Delete(Name,1,p);
        p:=Pos('"',Name);
        if p>0 then begin
            Delete(Name,p,Length(Name));
            Result:=Trim(Name);
        end;
    end;
end;

procedure ParseForHierarchy(Lines:TArrayOfString;var List:TArrayOfString);
var
    i,p,s,l:Integer;
    Line,Name,Group:String;
begin
    for i:=0 to GetArrayLength(Lines)-1 do begin
        Line:=Lines[i];

        // Look for the begin of package group.
        p:=Pos('<package-group',Line);
        s:=Pos('/>',Line);
        if p>0 then begin
            Name:=GetFirstQuotedString(Line);

            // Append the name to the list.
            if Length(Name)>0 then begin
                if s=0 then begin
                    Group:=AddBackslash(Group)+Name;
                end else begin
                    l:=GetArraylength(List);
                    SetArrayLength(List,l+1);
                    List[l]:=Group+'\'+Name;
                end;
            end;
        end else begin
            // Look for the end of package group.
            p:=Pos('</package-group>',Line);
            if p>0 then begin
                l:=GetArraylength(List);
                SetArrayLength(List,l+1);
                List[l]:=Group;
                Group:=RemoveBackslash(ExtractFilePath(Group));
            end;
        end;
    end;
end;

procedure ParseForPackages(Lines:TArrayOfString;var List:TArrayOfString);
var
    i,p,l:Integer;
    Line,Name:String;
begin
    for i:=0 to GetArrayLength(Lines)-1 do begin
        Line:=Lines[i];

        // Look for a package name.
        p:=Pos('<package name',Line);
        if p>0 then begin
            Name:=GetFirstQuotedString(Line);

            // Append the name to the list.
            if Length(Name)>0 then begin
                l:=GetArraylength(List);
                SetArrayLength(List,l+1);
                List[l]:=Name;
            end;
        end else begin
            // Look for a group name.
            p:=Pos('<affiliate group',Line);
            if p>0 then begin
                Name:=GetFirstQuotedString(Line);

                // Append the group name to the current name.
                if Length(Name)>0 then begin
                    l:=GetArraylength(List)-1;
                    List[l]:=Name+'\'+List[l];
                end;
            end;
        end;
    end;
end;

function GetAvailablePackages:TArrayOfString;
var
    Path:String;
    FindRec:TFindRec;
    Lines,Groups,Packages:TArrayOfString;
    g,p,l:Integer;
    Group,Parent:String;
begin
    Path:=WizardDirValue+'\mingw\var\lib\mingw-get\data\';

    // Loop over all XML files.
    if FindFirst(Path+'*.xml',FindRec) then begin
        try
            repeat
                // Load all lines of text and parse them.
                if LoadStringsFromFile(Path+FindRec.Name,Lines) then begin
                    if Pos('-list.xml',FindRec.Name)>0 then begin
                        ParseForHierarchy(Lines,Groups);
                    end else begin
                        ParseForPackages(Lines,Packages);
                    end;
                end;
            until not FindNext(FindRec);
        finally
            FindClose(FindRec);
        end;
    end;

    // Sort packages into groups. Note that packages may belong to multiple groups
    // because their group belongs to mutiple parent groups (see "MinGW Standard Libraries").
    Log('There are '+IntToStr(GetArrayLength(Groups))+' groups and '+IntToStr(GetArrayLength(Packages))+' unique packages.');

    for g:=0 to GetArrayLength(Groups)-1 do begin
        Log('Sorting into group: '+Groups[g]);

        Group:=Lowercase(ExtractFileName(Groups[g]));
        for p:=0 to GetArrayLength(Packages)-1 do begin
            Parent:=Lowercase(ExtractFileDir(Packages[p]));
            if (Group=Parent) or ((Length(Parent)=0) and (Pos(Group,Lowercase(Packages[p]))>0)) then begin
                l:=GetArraylength(Result);
                SetArrayLength(Result,l+1);
                Result[l]:=Groups[g]+'\'+ExtractFileName(Packages[p]);
            end;
        end;
    end;

    Log('Created '+IntToStr(l+1)+' package entries.');
end;

{
    Installer callbacks
}

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

    // TODO: Check if at least one package is selected.
    Exec(WizardDirValue+'\mingw\bin\mingw-get.exe',GetCheckedPackages('install'),'',SW_SHOW,ewWaitUntilTerminated,ResultCode);
    Result:=(ResultCode=0);
end;
