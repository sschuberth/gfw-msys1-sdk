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

procedure ParseForPackages(Lines:TArrayOfString;var List:TStringList);
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
                List.Append(Name);
            end;

            // Append the class (e.g. "virtual"), if any, to the name.
            p:=Pos('class',Line);
            if p>0 then begin
                Delete(Line,1,p);
                Name:=GetFirstQuotedString(Line);
                l:=List.Count-1;
                List.Strings[l]:=List.Strings[l]+'@'+Name;
            end;
        end else begin
            // Look for a group name.
            p:=Pos('<affiliate group',Line);
            if p>0 then begin
                Name:=GetFirstQuotedString(Line);

                // Append the group name to the current name.
                if Length(Name)>0 then begin
                    l:=List.Count-1;
                    List.Strings[l]:=Name+'\'+List.Strings[l];
                end;
            end;
        end;
    end;
end;

function GetAvailablePackages(var Entries:TArrayOfString):Integer;
var
    Groups,Packages:TStringList;
    Path:String;
    FindRec:TFindRec;
    Lines:TArrayOfString;
    g,p,l:Integer;
    Group,Parent:String;
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
        Log('Assigning to group: '+Groups[g]);

        Group:=Lowercase(ExtractFileName(Groups[g]));
        for p:=0 to Packages.Count-1 do begin
            Parent:=Lowercase(ExtractFileDir(Packages[p]));
            if (Group=Parent) or ((Length(Parent)=0) and (Pos(Group,Lowercase(Packages[p]))>0)) then begin
                l:=GetArrayLength(Entries);
                SetArrayLength(Entries,l+1);
                Entries[l]:=Groups.Strings[g]+'\'+ExtractFileName(Packages.Strings[p]);
            end;
        end;
    end;

    Log('Created '+IntToStr(l+1)+' package entries.');

    Result:=Packages.Count;

    Groups.Free;
    Packages.Free;
end;
