// Returns the first quoted string contained in "Name" (without the quotes).
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
            Result:=Name;
        end;
    end;
end;

// Parses the "Lines" of the given XML file to extract a package group hierarchy.
// The hierarchy is returned as a "List" of path strings separated by backslashes.
procedure ParseForHierarchy(Lines:TArrayOfString;var List:TStringList);
var
    i,p,s:Integer;
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
                    List.Append(Group+'\'+Name);
                end;
            end;
        end else begin
            // Look for the end of package group.
            p:=Pos('</package-group>',Line);
            if p>0 then begin
                List.Append(Group);
                Group:=ExtractFileDir(Group);
            end;
        end;
    end;
end;

// Parses the "Lines" of the given XML file to extract package names. The package
// name is returned as a "List" of strings in the form "<affiliate group>\<package>[@class]",
// e.g. "MinGW Developer Toolkit\mingw-developer-toolkit@virtual".
procedure ParseForPackages(Lines:TArrayOfString;var List:TStringList);
var
    WithinPackageTag:Boolean;
    i,p:Integer;
    Line,Name,LocalGroup,GlobalGroup:String;
begin
    WithinPackageTag:=False;

    for i:=0 to GetArrayLength(Lines)-1 do begin
        Line:=Lines[i];

        // Look for a package name.
        if (Pos('<package name',Line)>0) and not WithinPackageTag then begin
            WithinPackageTag:=True;
            Name:=GetFirstQuotedString(Line);

            // Append the class (e.g. "virtual"), if any, to the name.
            p:=Pos('class',Line);
            if p>0 then begin
                Delete(Line,1,p);
                Name:=Name+'@'+GetFirstQuotedString(Line);
            end;
        end else if (Pos('</package>',Line)>0) and WithinPackageTag then begin
            WithinPackageTag:=False;

            if Length(LocalGroup)>0 then begin
                Name:=LocalGroup+'\'+Name;
            end else if Length(GlobalGroup)>0 then begin
                Name:=GlobalGroup+'\'+Name;
            end;
            List.Append(Name);

            LocalGroup:='';
        end else if Pos('<affiliate group',Line)>0 then begin
            // Look for a group name. Usually the group is a child of the package, but for some
            // meta packages the group is defined before the package.
            if WithinPackageTag then begin
                LocalGroup:=GetFirstQuotedString(Line);
            end else begin
                GlobalGroup:=GetFirstQuotedString(Line);
            end;
        end;
    end;
end;

// Gets the list of available packages by parsing mingw-get's XML files. The packages
// "Entries" are returned as strings in the form "<group hierarchy>\<package>[@class]",
// e.g. "MSYS\MinGW Developer Toolkit\mingw-developer-toolkit@virtual".
function GetAvailablePackages(var Entries:TArrayOfString):Integer;
var
    Groups,Packages:TStringList;
    Path:String;
    FindRec:TFindRec;
    Lines:TArrayOfString;
    g,p,l:Integer;
    Group,Parent,Name,Members:String;
begin
    Groups:=TStringList.Create;
    Packages:=TStringList.Create;

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

    Packages.Sort;

    // Assigning packages to groups. Note that packages may belong to multiple groups
    // if their group belongs to multiple parent groups (see "MinGW Standard Libraries").
    Log('There are '+IntToStr(Groups.Count)+' groups and '+IntToStr(Packages.Count)+' unique packages.');

    SetArrayLength(Entries,0);
    for g:=0 to Groups.Count-1 do begin
        Members:='    ';
        Log('Assigning the following packages to group "'+Groups[g]+'":');

        // For each group hierarchy, try if its name is a prefix of the package and affiliate group.
        Group:=Lowercase(ExtractFileName(Groups[g]));
        for p:=0 to Packages.Count-1 do begin
            Parent:=Lowercase(ExtractFileDir(Packages[p]));
            if (Group=Parent) or ((Length(Parent)=0) and (Pos(Group,Lowercase(Packages[p]))>0)) then begin
                l:=GetArrayLength(Entries);
                SetArrayLength(Entries,l+1);
                Name:=ExtractFileName(Packages.Strings[p]);
                Entries[l]:=Groups.Strings[g]+'\'+Name;
                Members:=Members+Name+', ';
            end;
        end;

        // Remove the trailing whitespace and comma.
        Delete(Members,Length(Members)-1,2);

        Log(Members);
    end;

    Log('Created a total of '+IntToStr(l+1)+' package entries.');

    Result:=Packages.Count;

    Groups.Free;
    Packages.Free;
end;
