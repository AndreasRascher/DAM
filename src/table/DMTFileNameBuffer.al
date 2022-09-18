table 110041 DMTDataFileBuffer
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
        field(21; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; Editable = false; }
        field(22; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption'; Editable = false; }
        field(30; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(31; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table Caption', comment = 'Zieltabelle Bezeichnung';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
        }
        field(32; "File is already assigned"; Boolean)
        {
            Caption = 'Already assigned', Comment = 'Bereits zugeordnet';
            Editable = false;
        }

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
            Rec.Init();
            Rec.Path := FileRec.Path;
            Rec.Name := FileRec.Name;
            Rec.Size := FileRec.Size;
            Rec.DateTime := CreateDateTime(FileRec.Date, FileRec.Time);
            Rec."File is already assigned" := IsFileAlreadyAssigned();
            Rec.Insert();
            FindNAVTableByFileName();
            ProposeTargetTable();
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
            //Land/Region -> Land_Regsion
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

    local procedure IsFileAlreadyAssigned(): Boolean
    var
        DMTTable: Record DMTTable;
    begin
        if rec.Name = '' then exit;
        DMTTable.SetRange(DataFileFolderPath, Rec.Path);
        DMTTable.SetRange(DataFileName, Rec.Name);
        exit(DMTTable.FindFirst());
    end;

    procedure ProposeTargetTable()
    var
        TableMetadata: Record "Table Metadata";
        FeatureKey: Record "Feature Key";
    begin
        // Feature: If Target Table Obsolete, switch to alternative
        if TableMetadata.Get(rec."NAV Src.Table No.") then begin
            if not (TableMetadata.ObsoleteState in [TableMetadata.ObsoleteState::Removed, TableMetadata.ObsoleteState::Pending]) then begin
                Rec."Target Table ID" := TableMetadata.ID;
            end else begin
                Case Rec."NAV Src.Table No." of
                    5105: // Customer Template
                        Rec."Target Table ID" := Database::"Customer Templ.";
                    5717: //Item Cross Reference
                        Rec."Target Table ID" := Database::"Item Reference";
                    7002,// Sales Price - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7004,// Sales Line Discount - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7012,// Purchase Price - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                    7014:// Purchase Line Discount - 'Replaced by the new implementation (V16) of price calculation: table Price List Line'
                        begin
                            if FeatureKey.Get('SalesPrices') and (FeatureKey.Enabled = FeatureKey.Enabled::"All Users") then
                                Rec."Target Table ID" := Database::"Price List Line"
                            else
                                Rec."Target Table ID" := Rec."NAV Src.Table No.";
                        end;
                    else
                        Error('unhandled obsolete Table %1', Rec."NAV Src.Table No.");
                end;
            end;
            Rec.Modify();
        end;
    end;

    var
        FileNameTableCaptionMapping: Dictionary of [Text, Integer];
}