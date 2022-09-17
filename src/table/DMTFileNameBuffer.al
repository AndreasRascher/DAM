table 110012 DMTDataFileBuffer
{
    TableType = Temporary;
    DataClassification = ToBeClassified;
    LookupPageId = DMTSelectDataFile;

    fields
    {
        field(1; Path; Code[98]) { Caption = 'Path'; Editable = false; }
        field(2; Name; Text[99]) { Caption = 'Name'; Editable = false; }
        field(10; Size; Integer) { Caption = 'Size'; Editable = false; }
        field(11; "DateTime"; DateTime) { Caption = 'DateTime'; Editable = false; }
        field(20; "NAV Src.Table No."; Integer) { Caption = 'NAV Src.Table No.', Comment = 'NAV Tabellennr.'; }
        field(21; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; }
        field(22; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption'; }
    }
    keys
    {
        key(Key1; Path, Name) { Clustered = true; }
    }


    procedure LoadFiles() OK: Boolean
    var
        FileRec: Record File;
        DMTSetup: Record DMTSetup;
    begin
        DMTSetup.GetRecordOnce();
        DMTSetup.TestField("Default Export Folder Path");
        FileRec.SetRange(Path, DMTSetup."Default Export Folder Path");
        FileRec.SetRange("Is a file", true);
        If not FileRec.FindSet() then exit(false);
        repeat
            Rec.Path := FileRec.Path;
            Rec.Name := FileRec.Name;
            Rec.Size := FileRec.Size;
            Rec.DateTime := CreateDateTime(FileRec.Date, FileRec.Time);
            Rec.Insert();
            FindNAVTableByFileName();
        until FileRec.Next() = 0;
    end;

    local procedure FindNAVTableByFileName()
    var
        DMTFieldBufferQry: Query DMTFieldBufferQry;
        NAVTableID: Integer;
    begin
        LoadFileNameMapping();
        if FileNameTableCaptionMapping.Get(Rec.Name, NAVTableID) then begin
            DMTFieldBufferQry.SetRange(TableNo, NAVTableID);
            DMTFieldBufferQry.Open();
            DMTFieldBufferQry.Read();
            Rec."NAV Src.Table No." := DMTFieldBufferQry.TableNo;
            Rec."NAV Src.Table Name" := DMTFieldBufferQry.TableName;
            Rec."NAV Src.Table Caption" := DMTFieldBufferQry.Table_Caption;
            Rec.Modify()
        end;
    end;

    local procedure LoadFileNameMapping()
    var
        DMTFieldBufferQry: Query DMTFieldBufferQry;
        FileNameFromCaption: Text;
    begin
        if FileNameTableCaptionMapping.Count > 0 then exit;
        DMTFieldBufferQry.SetFilter(TableNo, '1..49999|100000..');
        DMTFieldBufferQry.Open();
        while DMTFieldBufferQry.Read() do begin
            //Land/Region -> Land_Region
            FileNameFromCaption := StrSubstNo('%1.csv', ConvertStr(DMTFieldBufferQry.Table_Caption, '<>*\/|"', '_______'));
            // TODO: Doppelte Captions im Standard
            if not FileNameTableCaptionMapping.ContainsKey(FileNameFromCaption) then
                FileNameTableCaptionMapping.Add(FileNameFromCaption, DMTFieldBufferQry.TableNo);
        end;
        DMTFieldBufferQry.Close();

        // ignore Custom Tables with duplicate captions
        DMTFieldBufferQry.SetFilter(TableNo, '50000..99999');
        DMTFieldBufferQry.Open();
        while DMTFieldBufferQry.Read() do begin
            FileNameFromCaption := StrSubstNo('%1.csv', ConvertStr(DMTFieldBufferQry.Table_Caption, '<>*\/|"', '_______'));
            if not FileNameTableCaptionMapping.ContainsKey(FileNameFromCaption) then
                FileNameTableCaptionMapping.Add(FileNameFromCaption, DMTFieldBufferQry.TableNo);
        end;
        DMTFieldBufferQry.Close();
    end;

    var
        FileNameTableCaptionMapping: Dictionary of [Text, Integer];
}