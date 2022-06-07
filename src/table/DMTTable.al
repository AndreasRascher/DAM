table 81128 "DMTTable"
{
    DataClassification = SystemMetadata;
    LookupPageId = DMTTableList;
    DrillDownPageId = DMTTableList;

    fields
    {
        field(1; "To Table ID"; Integer)
        {
            Caption = 'To Table ID', comment = 'Nach Tabellen ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(4; "Dest.Table Caption"; Text[250])
        {
            CaptionML = DEU = 'Ziel Tabelle', ENU = 'Destination Table';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.LookUpToTable(Rec);
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.ValidateToTableCaption(Rec, xRec);
            end;
        }
        field(21; "No.of Records in Buffer Table"; Integer)
        {
            Caption = 'No.of Records in Buffer Table', comment = 'Anz. Datensätze in Puffertabelle';
            trigger OnLookup()
            begin
                ShowBufferTable();
            end;
        }
        field(31; "Qty.Lines In Trgt. Table"; Integer)
        {
            Caption = 'Qty. lines in target table', Comment = 'Anz. Zeilen in Zieltabelle';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("To Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowBufferTable();
            end;
        }
        field(32; "No.of Fields in Trgt. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Felder in Zieltabelle', ENU = 'No. of fields in target table';
            FieldClass = FlowField;
            CalcFormula = count("DMTField" where("To Table No." = field("To Table ID")));
            Editable = false;
        }
        field(50; BufferTableType; Option)
        {
            CaptionML = DEU = 'Puffertabellenart', ENU = 'Buffer Table Type';
            OptionMembers = "Generic Buffer Table for all Files","Custom Buffer Table per file";
            OptionCaptionML = DEU = 'Generische Puffertabelle für alle Dateien,Eine Puffertabelle pro CSV',
                              ENU = 'Generic Buffer Table for all Files,Seperate Buffer Table per CSV';
            trigger OnValidate()
            begin
                ProposeObjectIDs();
            end;
        }
        field(52; DataFilePath; Text[250])
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
                DMTMgt: Codeunit DMTMgt;
            begin
                Rec.DataFilePath := DMTMgt.LookUpPath(Rec.DataFilePath, false);
            end;
        }
        field(53; "Import XMLPort ID"; Integer)
        {
            CaptionML = DEU = 'XMLPort ID für Import', ENU = 'Import XMLPortID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "Object ID" = filter('50000..'));
            ValidateTableRelation = false;
            trigger OnValidate()
            begin
                if not ("Import XMLPort ID" in [50000 .. 99999, 0]) then
                    Error(ObjectIDNotInIDRangeErr);
            end;
        }
        field(54; "Buffer Table ID"; Integer)
        {
            CaptionML = DEU = 'Puffertabelle ID', ENU = 'Buffertable ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "Object ID" = filter('50000..'));
            ValidateTableRelation = false;
            trigger OnValidate()
            begin
                if not ("Import XMLPort ID" in [50000 .. 99999, 0]) then
                    Error(ObjectIDNotInIDRangeErr);
            end;
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
        field(102; LastView; Blob) { }
        field(103; "Import Duration (Longest)"; Duration) { Caption = 'Import Duration (Longest)', Comment = 'Import Dauer(Längste)'; }
        field(104; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'Nur neue Datensätze importieren'; }

        #region NAVDataSourceFields
        field(40; "Data Source Type"; Enum DMTDataSourceType) { Caption = 'Data Source Type'; }
        field(41; "NAV Schema File Status"; Option)
        {
            CaptionML = DEU = 'NAV Schema Datei Status', ENU = 'NAV Schema File Status';
            Editable = false;
            OptionMembers = "Import required",Imported;
            OptionCaptionML = ENU = '"Import required",Imported', DEU = '"Import erforderlich",Importiert';
        }
        field(42; "NAV Src.Table No."; Integer)
        {
            CaptionML = DEU = 'NAV Tabellennr.', ENU = 'NAV Src.Table No.';
        }
        field(43; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; }
        field(44; "NAV Src.Table Caption"; Text[250])
        {
            Caption = 'NAV Source Table Caption';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.LookUpOldVersionTable(Rec);
                if "To Table ID" = 0 then begin
                    Rec.Validate("Dest.Table Caption", Format("NAV Src.Table No."));
                    ProposeObjectIDs();
                    InitTableFieldMapping();
                end;
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.ValidateFromTableCaption(Rec, xRec);
                if ("To Table ID" = 0) and ("NAV Src.Table No." <> 0) then begin
                    Rec.Validate("Dest.Table Caption", Format("NAV Src.Table No."));
                    ProposeObjectIDs();
                end;
            end;
        }
        #endregion NAVDataSourceFields
    }

    keys
    {
        key(PK; "To Table ID") { Clustered = true; }
        key(Sorted; "Sort Order") { }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "To Table ID", "Dest.Table Caption") { }
        fieldgroup(Brick; "Dest.Table Caption", "No.of Records in Buffer Table") { }
    }

    trigger OnDelete()
    var
        DMTFields: Record "DMTField";
    begin
        if DMTFields.FilterBy(Rec) then
            DMTFields.DeleteAll(true);
    end;

    internal procedure ImportToBufferTable()
    var
        GenBuffImport: XmlPort DMTGenBuffImport;
        File: File;
        InStr: InStream;
        Progress: Dialog;
        ImportFileFromPathLbl: Label 'Importing %1';
    begin
        case Rec.BufferTableType of
            Rec.BufferTableType::"Custom Buffer Table per file":
                begin
                    rec.TestField("Import XMLPort ID");
                    rec.Testfield(DataFilePath);
                    file.Open(DataFilePath, TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    Xmlport.Import(Rec."Import XMLPort ID", InStr);
                    UpdateQtyLinesInBufferTable();
                end;
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    rec.Testfield(DataFilePath);
                    file.Open(DataFilePath, TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    GenBuffImport.SetSource(InStr);
                    GenBuffImport.SetDMTTable(Rec);
                    Progress.Open(StrSubstNo(ImportFileFromPathLbl, ConvertStr(Rec.DataFilePath, '\', '/')));
                    GenBuffImport.Import();
                    Progress.Close();
                    UpdateQtyLinesInBufferTable();
                end;
        end
    end;

    procedure DownloadALBufferTableFile()
    var
        DMTObjectGenerator: Codeunit DMTObjectGenerator;
    begin
        DMTObjectGenerator.DownloadFile(
            DMTObjectGenerator.CreateALTable(Rec),
            Rec.GetALBufferTableName());
    end;

    procedure DownloadALXMLPort()
    var
        DMTObjectGenerator: Codeunit DMTObjectGenerator;
    begin
        DMTObjectGenerator.DownloadFile(DMTObjectGenerator.CreateALXMLPort(Rec), Rec.GetALXMLPortName());
    end;

    internal procedure ShowBufferTable() OK: Boolean
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin

        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            if not GenBuffTable.FilterByFileName(Rec.DataFilePath) then
                exit(false);
            GenBuffTable.ShowImportDataForFile(Rec.DataFilePath);
        end;

        if Rec.BufferTableType = Rec.BufferTableType::"Custom Buffer Table per file" then begin
            if Rec."Buffer Table ID" = 0 then exit(false);
            Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Rec."Buffer Table ID"));
        end;

    end;

    local procedure ProposeObjectIDs()
    var
        DMTSetup: Record "DMTSetup";
        DMTTable: Record DMTTable;
        ObjectMgt: Codeunit DMTObjMgt;
        AvailableTables: List of [Integer];
        AvailableXMLPorts: List of [Integer];
    begin
        if not DMTSetup.Get() then
            DMTSetup.InsertWhenEmpty();
        DMTSetup.Get();

        ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::Table, AvailableTables);
        ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::XMLPort, AvailableXMLPorts);

        // Collect used numbers
        if DMTTable.FindSet() then
            repeat
                if DMTTable."Import XMLPort ID" <> 0 then
                    if AvailableXMLPorts.Contains(DMTTable."Import XMLPort ID") then
                        AvailableXMLPorts.Remove(DMTTable."Import XMLPort ID");
                if DMTTable."Buffer Table ID" <> 0 then
                    if AvailableTables.Contains(DMTTable."Buffer Table ID") then
                        AvailableTables.Remove(DMTTable."Buffer Table ID");
            until DMTTable.Next() = 0;

        // Buffer Table ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range Buffer Tables" <> '' then
        if rec."Buffer Table ID" = 0 then begin
            Rec."Buffer Table ID" := AvailableTables.Get(1);
            AvailableTables.Remove(Rec."Buffer Table ID");
        end;
        // Import XMLPort ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range XMLPorts" <> '' then
        if rec."Import XMLPort ID" = 0 then begin
            rec."Import XMLPort ID" := AvailableXMLPorts.get(1);
            AvailableXMLPorts.Remove(Rec."Import XMLPort ID");
        end;
        TryFindBufferTableID(false);
        TryFindXMLPortID(false);
    end;

    local procedure InitTableFieldMapping()
    var
        DMTFields: Record "DMTField";
        DMTSetup: record "DMTSetup";
    begin
        DMTSetup.CheckSchemaInfoHasBeenImporterd();
        if not DMTFields.FilterBy(Rec) then begin
            DMTFields.InitForTargetTable(Rec);
            DMTFields.ProposeMatchingTargetFields(Rec);
        end;

    end;

    procedure UpdateQtyLinesInBufferTable() QtyLines: Decimal;
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        if Rec."To Table ID" = 0 then
            exit;

        case Rec.BufferTableType of
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.FilterByFileName(Rec.DataFilePath);
                    QtyLines := GenBuffTable.Count;
                end;
            Rec.BufferTableType::"Custom Buffer Table per file":
                begin
                    RecRef.Open(REc."Buffer Table ID");
                    QtyLines := RecRef.Count();
                end;
        end;
        if Rec."No.of Records in Buffer Table" <> QtyLines then begin
            Rec.Get(Rec.RecordId);
            Rec."No.of Records in Buffer Table" := QtyLines;
            Rec.Modify();
        end;
    end;


    procedure TryFindExportDataFile() Success: Boolean
    var
        DMTSetup: Record "DMTSetup";
        FileMgt: Codeunit "File Management";
        FilePath: Text;
    begin
        DMTSetup.Get();
        if DMTSetup."Default Export Folder Path" = '' then exit(false);
        if Rec.DataFilePath <> '' then exit(false);
        FilePath := FileMgt.CombinePath(DMTSetup."Default Export Folder Path", StrSubstNo('%1.csv', CONVERTSTR(Rec."NAV Src.Table Caption", '<>*\/|"', '_______')));
        if FileMgt.ServerFileExists(FilePath) then begin
            Rec.DataFilePath := CopyStr(FilePath, 1, MaxStrLen(Rec.DataFilePath));
            Rec.Modify();
            Success := true;
        end;
    end;

    procedure TryFindBufferTableID(DoModify: Boolean)
    var
        TableMeta: Record "Table Metadata";
    begin
        TableMeta.SetRange(ID, 50000, 99999);
        TableMeta.SetRange(Name, StrSubstNo('T%1Buffer', Rec."NAV Src.Table No."));
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
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Import', Rec."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            Rec."Import XMLPort ID" := AllObjWithCaption."Object ID";
            if DoModify then
                Rec.Modify();
        end;
    end;

    procedure GetALBufferTableName() Name: Text;
    begin
        Name := StrSubstNo('TABLE %1 - T%2Buffer.al', Rec."Buffer Table ID", Rec."NAV Src.Table No.");
    end;

    procedure GetALXMLPortName() Name: Text;
    begin
        Name := StrSubstNo('XMLPORT %1 - T%2Import.al', Rec."Import XMLPort ID", "NAV Src.Table No.");
    end;

    procedure DownloadAllALBufferTableFiles(var DMTTable: Record DMTTable)
    var
        DMTTable2: Record DMTTable;
        ObjGen: Codeunit DMTObjectGenerator;
        DataCompression: Codeunit "Data Compression";
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: text;
        ZIPFileTypeTok: TextConst DEU = 'ZIP-Dateien (*.zip)|*.zip', ENU = 'ZIP Files (*.zip)|*.zip';
    begin
        DMTTable2.Copy(DMTTable);
        if DMTTable2.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr);
                OStr.WriteText(ObjGen.CreateALTable(DMTTable2).ToText());
                FileBlob.CreateInStream(IStr);
                DataCompression.AddEntry(IStr, DMTTable2.GetALBufferTableName());
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr);
                OStr.WriteText(ObjGen.CreateALXMLPort(DMTTable2).ToText());
                FileBlob.CreateInStream(IStr);
                DataCompression.AddEntry(IStr, DMTTable2.GetALXMLPortName());
            until DMTTable2.Next() = 0;
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

    procedure CustomBufferTableExits(): boolean
    var
        AllObj: Record AllObjWithCaption;
    begin
        if (Rec."Buffer Table ID" = 0) then exit(false);
        exit(AllObj.Get(AllObj."Object Type"::Table, Rec."Buffer Table ID"));
    end;

    procedure ImportXMLPortExits(): boolean
    var
        AllObj: Record AllObjWithCaption;
    begin
        if (Rec."Import XMLPort ID" = 0) then exit(false);
        exit(AllObj.Get(AllObj."Object Type"::XMLport, Rec."Import XMLPort ID"));
    end;

    procedure UpdateNAVSchemaFileStatus()
    var
        FieldBuffer: Record DMTFieldBuffer;
    begin
        Rec."NAV Schema File Status" := Rec."NAV Schema File Status"::"Import required";
        if not FieldBuffer.IsEmpty then
            Rec."NAV Schema File Status" := Rec."NAV Schema File Status"::Imported;
    end;

    var
        ObjectIDNotInIDRangeErr: TextConst DEU = 'Die Objekt ID muss im Bereich 50000 bis 99999 liegen.',
                                            ENU = 'The object ID must be in the range 50000 to 99999.';

}