#define APP_NAME    'mingwGitDevEnv'
#define APP_VERSION '0.1'

[Setup]

; Compiler-related
Compression=lzma2/ultra
LZMAUseSeparateProcess=yes
OutputBaseFilename={#APP_NAME+'-v'+APP_VERSION}
OutputDir=.
SolidCompression=yes
SourceDir=..

; Installer-related
AllowNoIcons=yes
AppName={#APP_NAME}
AppVersion={#APP_VERSION}
ChangesEnvironment=yes
DefaultDirName={sd}\{#APP_NAME}
DefaultGroupName={#APP_NAME}
DisableReadyPage=yes
PrivilegesRequired=none

; Cosmetic
SetupIconFile=resources\git.ico
WizardImageBackColor=clWhite
WizardImageStretch=no
WizardImageFile=resources\git-large.bmp
WizardSmallImageFile=resources\git-small.bmp

[Files]

Source: installer\is-procap.dll; Flags: dontcopy
Source: root\*; DestDir: {app}; Flags: recursesubdirs

[Icons]

Name: "{group}\Git Development Environment"; Filename: "{app}\msys.bat"; IconFilename: "{uninstallexe}"

[Run]

Filename: "{app}\msys.bat"; Description: "Start the development environment"; Flags: postinstall

[UninstallDelete]

Type: filesandordirs; Name: "{app}"

[Messages]

ConfirmUninstall=This will uninstall %1 and remove all files in the installation directory including those that were added after installation (like custom packages and configuration files). Are you sure that you want to continue?

[Code]

#include "environment.inc.iss"
#include "xmlparser.inc.iss"

const
    RequiredPackages = 'msys-base '
                     + 'msys-lndir '
                     + 'msys-patch '
                     + 'msys-perl '
                     + 'msys-wget '
                     + 'mingw32-gcc '
                     + 'mingw32-libiconv '
                     + 'mingw32-libopenssl '
                     + 'mingw32-libz '
                     + 'mingw32-mgwport '
                     + 'mingw32-tcl '
                     ;

var
    PackagesPage:TWizardPage;
    PackagesList:TNewCheckListBox;
    SelectedPackages:String;
    ProgressPage:TWizardPage;
    ProgressLog:TNewMemo;

procedure InitializeWizard;
var
    PrevPageID:Integer;
begin
    PrevPageID:=wpInstalling;

    {
        Package selection page
    }

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

    {
        Package installation page
    }

    ProgressPage:=CreateCustomPage(
        PrevPageID,
        'Package installation',
        'Running mingw-get to install the selected packages'
    );
    PrevPageID:=ProgressPage.ID;

    ProgressLog:=TNewMemo.Create(ProgressPage);
    with ProgressLog do begin
        Parent:=ProgressPage.Surface;
        Width:=ProgressPage.SurfaceWidth;
        Height:=ProgressPage.SurfaceHeight;
        //ScrollBars:=ssBoth;
        ScrollBars:=ssBoth;
    end;
end;

procedure CurStepChanged(CurStep:TSetupStep);
var
    Packages:TArrayOfString;
    NumPackages,i,Level,p:Integer;
    Hierarchy,Group,PrevPath,Path,PackageName,PackageClass:String;
    Required:Boolean;
begin
    // Initialize the package selection page just after the actual installation finishes.
    if CurStep<>ssPostInstall then begin
        Exit;
    end;

    // Note that NumPackages is the number of unique packages while GetArrayLength(Packages)
    // is the number of entries in the tree (which is greater or equal).
    NumPackages:=GetAvailablePackages(Packages);

    if NumPackages=0 then begin
        // This should never happen as we bundle the package catalogue files with the installer.
        MsgBox('No packages found, please report this as an error to the developers.',mbError,MB_OK);
        Exit;
    end;

    PackagesPage.Description:='Which of these '+IntToStr(NumPackages)+' packages would like to have installed?';

    for i:=0 to GetArrayLength(Packages)-1 do begin
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
        Required:=(Pos(' '+PackageName+' ',' '+RequiredPackages+' ')>0);
        PackagesList.AddCheckBox(PackageName,PackageClass,Level,Required,not Required,False,True,nil);
    end;
end;

function GetSelectedPackages:String;
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
begin
    Result:=True;

    if (CurPageID=wpSelectDir) and (Pos(' ',WizardDirValue)>0) then begin
        MsgBox('The installation directory must not contain any spaces, please choose a different one.',mbError,MB_OK);
        Result:=False;
    end else if CurPageID=PackagesPage.ID then begin
        SelectedPackages:=GetSelectedPackages;
        if Length(SelectedPackages)=0 then begin
            Result:=(MsgBox('You have not selected any packages. Are you sure you want to continue?',mbConfirmation,MB_YESNO)=IDYES);
        end;
    end;
end;

function ShouldSkipPage(PageID:Integer):Boolean;
begin
    if (PageID=PackagesPage.ID) and (PackagesList.Items.Count=0) then begin
        // This should never happen as we bundle the package catalogue files with the installer.
        Result:=True;
    end else begin
        Result:=False;
    end;
end;

function BeginProcessCapture(Executable,Arguments:PAnsiChar):Boolean;
external 'BeginProcessCapture@files:is-procap.dll setuponly';

function GetProcessOutput(var Text:PAnsiChar):Boolean;
external 'GetProcessOutput@files:is-procap.dll setuponly';

procedure EndProcessCapture;
external 'EndProcessCapture@files:is-procap.dll setuponly';

procedure CurPageChanged(CurPageID:Integer);
var
    Output:PAnsiChar;
    OutputStr:String;
    LineIndex,CarriagePos,FeedPos:Integer;
    HomePath:String;
    Home:TArrayOfString;
begin
    if CurPageID<>ProgressPage.ID then begin
        Exit;
    end;

    Log('Installing the following packages: '+SelectedPackages);

    if BeginProcessCapture(WizardDirValue+'\mingw\bin\mingw-get.exe','install '+SelectedPackages) then begin
        while GetProcessOutput(Output) do begin
            if Output<>nil then begin
                OutputStr:=Output;

                LineIndex:=ProgressLog.Lines.Count-1;
                //ProgressLog.SelStart:=Length(ProgressLog.Text);
                //ProgressLog.SelLength:=0;

                CarriagePos:=Pos(#13,OutputStr);
                FeedPos:=Pos(#10,OutputStr);
                if (CarriagePos>0) and (CarriagePos+1<>FeedPos) then begin
                    Delete(OutputStr,1,CarriagePos);
                    ProgressLog.Lines.Strings[LineIndex]:=OutputStr;
                    //ProgressLog.Update;
                end else if (FeedPos>0) then begin
                    ProgressLog.Text:=ProgressLog.Text+OutputStr;
                
                    // Auto-scroll to the end of the text.
                    //SendMessage(ProgressLog.Handle,{EM_SCROLLCARET} $00b7,0,0);
                end else begin
                    ProgressLog.Lines.Strings[LineIndex]:=ProgressLog.Lines.Strings[LineIndex]+OutputStr;
                    //ProgressLog.Update;
                end;
            end;
        end;

        EndProcessCapture;
    end;

    // Set the HOME environment variable if not set. This is better than changing /etc/profile
    // because that file will be overwritten on msys-core upgrades.
    HomePath:=ExpandConstant('{%HOME}');
    if not DirExists(HomePath) then begin
        HomePath:=ExpandConstant('{%HOMEDRIVE}')+ExpandConstant('{%HOMEPATH}');
        if not DirExists(HomePath) then begin
            HomePath:=ExpandConstant('{%USERPROFILE}');
        end;
        if DirExists(HomePath) then begin
            SetArrayLength(Home,1);
            Home[0]:=HomePath;
            SetEnvStrings('HOME',False,False,Home);
        end;
    end;
end;
