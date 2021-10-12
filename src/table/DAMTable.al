table 91001 "DAMTable"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "To Table ID"; Integer)
        {
            CaptionML = DEU = 'Nach Tabellen ID', ENU = 'To Table ID';
            DataClassification = SystemMetadata;

        }
        field(2; "Old Version Table ID"; Integer)
        {
            CaptionML = DEU = 'Von Tab.-ID', ENU = 'From Tab.-ID';
            DataClassification = SystemMetadata;

        }
        field(3; "Old Version Table Caption"; Text[250])
        {
            CaptionML = DEU = 'Von Tabelle', ENU = 'From Table';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.LookUpOldVersionTable(Rec);
                if "To Table ID" = 0 then begin
                    Rec.Validate("To Table Caption", Format("Old Version Table ID"));
                    ProposeObjectIDs();
                end;
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.ValidateFromTableCaption(Rec, xRec);
                if ("To Table ID" = 0) and ("Old Version Table ID" <> 0) then begin
                    Rec.Validate("To Table Caption", Format("Old Version Table ID"));
                    ProposeObjectIDs();
                end;
            end;
        }
        field(4; "To Table Caption"; Text[250])
        {
            CaptionML = DEU = 'In Tabelle', ENU = 'To Table';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.LookUpToTable(Rec);
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.ValidateToTableCaption(Rec, xRec);
            end;
        }
        field(21; "Qty.Lines In Src. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Zeilen in Puffertabelle', ENU = 'Qty.Lines in buffer table';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("Buffer Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent("Buffer Table ID");
            end;
        }
        field(31; "Qty.Lines In Trgt. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Zeilen in Zieltabelle', ENU = 'Qty.Lines in source table';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("To Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent("Old Version Table ID");
            end;
        }
        field(50; DataFilePath; Text[250])
        {
            CaptionML = DEU = 'Dateipfad Exportdatei', ENU = 'Export File Path';
            trigger OnValidate()
            var
                FileMgt: Codeunit "File Management";
                FileNotAccessibleFromServiceLabelMsg: TextConst DEU = 'Der Pfad "%1" konnte vom Service Tier nicht erreicht werden', ENU = 'The path "%1" is not accessibly for the service tier';
            begin
                if rec.DataFilePath <> '' then begin
                    rec.DataFilePath := CopyStr(rec.DataFilePath.TrimEnd('"').TrimStart('"'), 1, MaxStrLen(rec.DataFilePath));
                    if not FileMgt.ServerFileExists(rec.DataFilePath) then
                        Message(FileNotAccessibleFromServiceLabelMsg, DataFilePath);
                end;
            end;
        }
        field(51; "Import XMLPort ID"; Integer)
        {
            CaptionML = DEU = 'XMLPort ID für Import', ENU = 'Import XMLPortID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "Object ID" = filter('50000..'));
            MinValue = 50000;
            MaxValue = 99999;
        }
        field(52; "Buffer Table ID"; Integer)
        {
            CaptionML = DEU = 'Puffertabelle ID', ENU = 'Buffertable ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "Object ID" = filter('50000..'));
            MinValue = 50000;
            MaxValue = 99999;
        }
        field(60; "Use OnInsert Trigger"; boolean)
        {
            CaptionML = DEU = 'OnInsert Trigger verwenden', ENU = 'Use OnInsert Trigger';
            InitValue = true;
        }
        field(100; LastImportToTargetAt; DateTime)
        {
            CaptionML = DEU = 'Letzter Import am', ENU = 'Last Import At';
        }
        field(101; LastImportBy; Code[50])
        {
            CaptionML = DEU = 'Benutzer-ID', ENU = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
    }

    keys
    {
        key(PK; "To Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DAMFields: Record "DAMField";
    begin
        if DAMFields.FilterBy(Rec) then
            DAMFields.DeleteAll(true);
    end;

    internal procedure ImportToBufferTable()
    var
        File: File;
        InStr: InStream;
    begin
        rec.TestField("Import XMLPort ID");
        rec.Testfield(DataFilePath);
        file.Open(DataFilePath, TextEncoding::MSDos);
        file.CreateInStream(InStr);
        Xmlport.Import(Rec."Import XMLPort ID", InStr);
    end;

    internal procedure ShowTableContent(TableID: Integer)
    begin
        if TableID = 0 then exit;
        Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;

    local procedure ProposeObjectIDs()
    var
        DAMSetup: Record "DAM Object Setup";
        DAMTable: Record DAMTable;
        Numbers: Record Integer;
        UsedBufferTableIDs: List of [Integer];
        UsedXMLPortIDs: List of [Integer];
    begin
        if not DAMSetup.Get() then
            DAMSetup.InsertWhenEmpty();
        DAMSetup.Get();
        // Collect used numbers
        if DAMTable.FindSet() then
            repeat
                if DAMTable."Import XMLPort ID" <> 0 then
                    UsedXMLPortIDs.Add(DAMTable."Import XMLPort ID");
                if DAMTable."Buffer Table ID" <> 0 then
                    UsedBufferTableIDs.Add(DAMTable."Buffer Table ID");
            until DAMTable.Next() = 0;
        // Buffer Table ID - Assign Next Number in Filter
        if DAMSetup."Obj. ID Range Buffer Tables" <> '' then
            if rec."Buffer Table ID" = 0 then begin
                Numbers.SetFilter(Number, DAMSetup."Obj. ID Range Buffer Tables");
                if Numbers.FindSet() then
                    repeat
                        if not UsedBufferTableIDs.Contains(Numbers.Number) then begin
                            Rec."Buffer Table ID" := Numbers.Number;
                        end;
                    until (Numbers.Next() = 0) or (rec."Buffer Table ID" <> 0);
            end;
        // Import XMLPort ID - Assign Next Number in Filter
        if DAMSetup."Obj. ID Range XMLPorts" <> '' then
            if rec."Import XMLPort ID" = 0 then begin
                Numbers.SetFilter(Number, DAMSetup."Obj. ID Range XMLPorts");
                if Numbers.FindSet() then
                    repeat
                        if not UsedXMLPortIDs.Contains(Numbers.Number) then begin
                            Rec."Import XMLPort ID" := Numbers.Number;
                        end;
                    until (Numbers.Next() = 0) or (rec."Import XMLPort ID" <> 0);
            end;
    end;

    procedure TryFindExportDataFile()
    var
        DAMSetup: Record "DAM Object Setup";
        FileMgt: Codeunit "File Management";
        FilePath: Text;
    begin
        DAMSetup.Get();
        if DAMSetup."Default Export Folder Path" = '' then exit;
        if Rec.DataFilePath <> '' then exit;
        FilePath := FileMgt.CombinePath(DAMSetup."Default Export Folder Path", StrSubstNo('%1.txt', Rec."Old Version Table Caption"));
        if FileMgt.ServerFileExists(FilePath) then begin
            Rec.DataFilePath := FilePath;
            Rec.Modify();
        end;
    end;

}