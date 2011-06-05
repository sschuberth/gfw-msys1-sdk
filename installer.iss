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
DefaultDirName={sd}\{#APP_NAME}
DisableReadyPage=yes
PrivilegesRequired=none

[Files]

Source: root\*; DestDir: {app}; Flags: recursesubdirs

[Code]

const
    // Note: A space before and after each package name is required!
    ForcePackages=' msys-base mingw32-gcc ';

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
                    l:=GetArrayLength(List);
                    SetArrayLength(List,l+1);
                    List[l]:=Group+'\'+Name;
                end;
            end;
        end else begin
            // Look for the end of package group.
            p:=Pos('</package-group>',Line);
            if p>0 then begin
                l:=GetArrayLength(List);
                SetArrayLength(List,l+1);
                List[l]:=Group;
                Group:=ExtractFileDir(Group);
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
                l:=GetArrayLength(List);
                SetArrayLength(List,l+1);
                List[l]:=Name;
            end;

            // Append the class (e.g. "virtual"), if any, to the name.
            p:=Pos('class',Line);
            if p>0 then begin
                Delete(Line,1,p);
                Name:=GetFirstQuotedString(Line);
                l:=GetArrayLength(List)-1;
                List[l]:=List[l]+'@'+Name;
            end;
        end else begin
            // Look for a group name.
            p:=Pos('<affiliate group',Line);
            if p>0 then begin
                Name:=GetFirstQuotedString(Line);

                // Append the group name to the current name.
                if Length(Name)>0 then begin
                    l:=GetArrayLength(List)-1;
                    List[l]:=Name+'\'+List[l];
                end;
            end;
        end;
    end;
end;

function GetAvailablePackages(var Entries:TArrayOfString):Integer;
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
                l:=GetArrayLength(Entries);
                SetArrayLength(Entries,l+1);
                Entries[l]:=Groups[g]+'\'+ExtractFileName(Packages[p]);
            end;
        end;
    end;

    Log('Created '+IntToStr(l+1)+' package entries.');
    Result:=GetArrayLength(Packages);
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
    NumPackages,i,Level,p:Integer;
    Hierarchy,Group,PrevPath,Path,PackageName,PackageClass:String;
    Forced:Boolean;
begin
    if CurStep<>ssPostInstall then begin
        Exit;
    end;

    NumPackages:=GetAvailablePackages(Packages);

    if NumPackages=0 then begin
        // This should never happen as we bundle the package catalogue files with the installer.
        MsgBox('No packages found, please report this as an error to the developers.',mbError,MB_OK);
        Exit;
    end;

    PackagesPage.Description:='Which of these '+IntToStr(NumPackages)+' packages would like to have installed?';

    for i:=0 to GetArrayLength(Packages)-1  do begin
        Hierarchy:=ExtractFilePath(Packages[i]);

        // Create only those groups of the hierarchy that were not previously created.
        Level:=0;
        p:=Pos('\',Hierarchy);
        while p>0 do begin
            Group:=Copy(Hierarchy,1,p-1);
            Path:=AddBackslash(Path)+Group;

            if Pos(Path,PrevPath)=0 then begin
                // Set a group entry's object to non-NIL to be able to easily distinguish them from package entries.
                PackagesList.AddCheckBox(Group,'',Level,False,True,False,True,PackagesList);
            end;

            Delete(Hierarchy,1,p);
            Inc(Level);

            p:=Pos('\',Hierarchy);
        end;
        PrevPath:=Path;
        Path:='';

        // Create the package entry.
        PackageName:=ExtractFileName(Packages[i]);
        PackageClass:='';
        p:=Pos('@',PackageName);
        if p>0 then begin
            PackageClass:=Copy(PackageName,p+1,Length(PackageName));
            Delete(PackageName,p,Length(PackageName));
        end;

        // Enclose the package name by spaces for the lookup as one name may be a substring of another name.
        Forced:=(Pos(' '+PackageName+' ',ForcePackages)>0);
        PackagesList.AddCheckBox(PackageName,PackageClass,Level,Forced,not Forced,False,True,nil);
    end;
end;

function GetCheckedPackages:String;
var
    i:Integer;
begin
    if PackagesList=nil then begin
        Exit;
    end;

    for i:=0 to PackagesList.Items.Count-1 do begin
        if PackagesList.Checked[i] and (PackagesList.ItemObject[i]=nil) then begin
            Result:=Result+' '+PackagesList.ItemCaption[i];
        end;
    end;
end;

function NextButtonClick(CurPageID:Integer):Boolean;
var
    Packages:String;
    ResultCode:Integer;
begin
    Result:=True;

    if (CurPageID=wpSelectDir) and (Pos(' ',WizardDirValue)>0) then begin
        MsgBox('The installation directory must not contain any spaces, please choose a different one.',mbError,MB_OK);
        Result:=False;
    end else if CurPageID=PackagesPage.ID then begin
        Packages:=GetCheckedPackages;
        if Length(Packages)>0 then begin
            Log('Installing the following packages: '+Packages);
            Exec(WizardDirValue+'\mingw\bin\mingw-get.exe','install '+Packages,'',SW_SHOW,ewWaitUntilTerminated,ResultCode);
            Result:=(ResultCode=0);
        end else begin
            Result:=(MsgBox('You have not selected any packages. Are you sure you want to continue?',mbConfirmation,MB_YESNO)=IDYES);
        end;
    end;
end;

function ShouldSkipPage(PageID:Integer):Boolean;
begin
    if (PageID=PackagesPage.ID) and (PackagesList.Items.Count=0) then begin
        Result:=True;
    end else begin
        Result:=False;
    end;
end;
