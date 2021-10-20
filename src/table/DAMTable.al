table 91001 "DAMTable"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "To Table ID"; Integer)
        {
            CaptionML = DEU = 'Nach Tabellen ID', ENU = 'To Table ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
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
                    InitTableFieldMapping();
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
            CaptionML = DEU = 'Anz. Zeilen in Zieltabelle', ENU = 'Qty. lines in target table';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("To Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent("Old Version Table ID");
            end;
        }
        field(32; "No.of Fields in Trgt. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Felder in Zieltabelle', ENU = 'No. of fields in target table';
            FieldClass = FlowField;
            CalcFormula = count(DAMField where("To Table No." = field("To Table ID")));
            Editable = false;
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

            trigger OnLookup()
            var
                DAMMgt: Codeunit DAMMgt;
            begin
                Rec.DataFilePath := DAMMgt.LookUpPath(Rec.DataFilePath, false);
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
        field(61; "Sort Order"; Integer)
        {
            CaptionML = DEU = 'Sortierung', ENU = 'Sort Order';
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
        field(102; LastView; Blob)
        {
        }
        field(103; "Import Duration (Longest)"; Duration)
        {
            CaptionML = DEU = 'Import Dauer(Längste)', ENU = 'Import Duration (Longest)';
        }
    }

    keys
    {
        key(PK; "To Table ID")
        {
            Clustered = true;
        }
        key(Sorted; "Sort Order") { }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "To Table ID", "To Table Caption")
        {
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
        rec.CalcFields("Qty.Lines In Src. Table");
    end;

    procedure DownloadALBufferTableFile()
    var
        DAMObjectGenerator: Codeunit DAMObjectGenerator;
    begin
        DAMObjectGenerator.DownloadFile(
            DAMObjectGenerator.CreateALTable(Rec),
            Rec.GetALBufferTableName());
    end;

    procedure DownloadALXMLPort()
    var
        DAMObjectGenerator: Codeunit DAMObjectGenerator;
    begin
        DAMObjectGenerator.DownloadFile(DAMObjectGenerator.CreateALXMLPort(Rec), Rec.GetALXMLPortName());
    end;

    internal procedure ShowTableContent(TableID: Integer)
    begin
        if TableID = 0 then exit;
        Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;

    local procedure ProposeObjectIDs()
    var
        DAMSetup: Record "DAM Setup";
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
        TryFindBufferTableID(false);
        TryFindXMLPortID(false);
    end;

    local procedure InitTableFieldMapping()
    var
        DAMFields: Record DAMField;
        DAMSetup: record "DAM Setup";
    begin
        DAMSetup.CheckSchemaInfoHasBeenImporterd();
        if not DAMFields.FilterBy(Rec) then begin
            DAMFields.InitForTargetTable(Rec);
            DAMFields.ProposeMatchingTargetFields(Rec);
        end;

    end;

    procedure TryFindExportDataFile()
    var
        DAMSetup: Record "DAM Setup";
        FileMgt: Codeunit "File Management";
        FilePath: Text;
    begin
        DAMSetup.Get();
        if DAMSetup."Default Export Folder Path" = '' then exit;
        if Rec.DataFilePath <> '' then exit;
        FilePath := FileMgt.CombinePath(DAMSetup."Default Export Folder Path", StrSubstNo('%1.txt', CONVERTSTR(Rec."Old Version Table Caption", '<>*\/|"', '_______')));
        if FileMgt.ServerFileExists(FilePath) then begin
            Rec.DataFilePath := CopyStr(FilePath, 1, MaxStrLen(Rec.DataFilePath));
            Rec.Modify();
        end;
    end;

    procedure TryFindBufferTableID(DoModify: Boolean)
    var
        TableMeta: Record "Table Metadata";
    begin
        TableMeta.SetRange(ID, 50000, 99999);
        TableMeta.SetRange(Name, StrSubstNo('T%1Buffer', Rec."Old Version Table ID"));
        if TableMeta.FindFirst() then begin
            Rec."Buffer Table ID" := TableMeta.ID;
            if DoModify then
                Rec.Modify();
        end;
    end;

    procedure TryFindXMLPortID(DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.SetRange("Object ID", 50000, 99999);
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Import', Rec."Old Version Table ID"));
        if AllObjWithCaption.FindFirst() then begin
            Rec."Import XMLPort ID" := AllObjWithCaption."Object ID";
            if DoModify then
                Rec.Modify();
        end;
    end;

    procedure GetALBufferTableName() Name: Text;
    begin
        Name := StrSubstNo('TABLE %1 - T%2Buffer.al', Rec."Buffer Table ID", Rec."Old Version Table ID");
    end;

    procedure GetALXMLPortName() Name: Text;
    begin
        Name := StrSubstNo('XMLPORT %1 - T%2Import.al', Rec."Import XMLPort ID", "Old Version Table ID");
    end;

    procedure DownloadAllALBufferTableFiles(var DAMTable: Record DAMTable)
    var
        DAMTable2: Record DAMTable;
        ObjGen: Codeunit DAMObjectGenerator;
        DataCompression: Codeunit "Data Compression";
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: text;
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        DAMTable2.Copy(DAMTable);
        if DAMTable2.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr);
                OStr.WriteText(ObjGen.CreateALTable(DAMTable2).ToText());
                FileBlob.CreateInStream(IStr);
                DataCompression.AddEntry(IStr, DAMTable2.GetALBufferTableName());
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr);
                OStr.WriteText(ObjGen.CreateALXMLPort(DAMTable2).ToText());
                FileBlob.CreateInStream(IStr);
                DataCompression.AddEntry(IStr, DAMTable2.GetALXMLPortName());
            until DAMTable2.Next() = 0;
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(iStr, 'Download', 'ToFolder', ZIPFileTypeTok, toFileName);
    end;

    procedure SaveTableLastView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastView);
        Rec.Modify();
        rec.LastView.CreateOutStream(Ostr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;

    procedure LoadTableLastView() TableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(LastView);
        if not rec.LastView.HasValue then exit('');
        rec.LastView.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

}