table 110000 "DMTTable"
{
    DataClassification = SystemMetadata;
    LookupPageId = DMTTableList;
    DrillDownPageId = DMTTableList;

    fields
    {
        field(1; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Zieltabellen ID';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(4; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table Caption', comment = 'Zieltabelle Bezeichnung';
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
        field(31; "No. of Lines In Trgt. Table"; Integer)
        {
            Caption = 'No. of Lines in Target Table', Comment = 'Anz. Zeilen in Zieltabelle';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("Target Table ID"), "Company Name" = field(CompanyNameFilter)));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent(Rec."Target Table ID");
            end;
        }
        field(32; "CompanyNameFilter"; Text[30])
        {
            Caption = 'Company Name Filter';
            FieldClass = FlowFilter;
            TableRelation = Company.Name;
            Editable = false;
        }
        field(50; BufferTableType; Enum BufferTableType)
        {
            Caption = 'Buffer Table Type', Comment = 'Puffertabellenart';

            trigger OnValidate()
            begin
                if (Rec.BuffertableType = Rec.BufferTableType::"Generic Buffer Table for all Files") then begin
                    Clear(Rec."Import XMLPort ID");
                    Clear(Rec."Buffer Table ID");
                end;
                ProposeObjectIDs(false);
            end;
        }
        #region SourceFileProperties        
        field(52; DataFileFolderPath; Text[250])
        {
            Caption = 'Data File Folder Path', comment = 'Ordnerpfad Exportdatei';
            trigger OnValidate()
            begin
                SetDataFilePath(DataFileFolderPath);
            end;

            trigger OnLookup()
            var
                DMTMgt: Codeunit DMTMgt;
            begin
                DataFileFolderPath := DMTMgt.LookUpPath(Rec.GetDataFilePath(), true);
            end;
        }
        field(53; DataFileName; Text[250])
        {
            Caption = 'Data File Name', comment = 'Dateiname Exportdatei';
            trigger OnValidate()
            begin
                SetDataFilePath(DataFileName);
            end;

            trigger OnLookup()
            var
                DMTMgt: Codeunit DMTMgt;
                CurrPath: Text;
            begin
                CurrPath := Rec.GetDataFilePath();
                SetDataFilePath(DMTMgt.LookUpPath(Rec.GetDataFilePath(), false));
            end;
        }
        field(54; "DataFile Size"; Integer) { Caption = 'Data File Size (Byte)', Comment = 'Dateigröße (Byte)'; }
        field(55; "DataFile Created At"; DateTime) { Caption = 'Data File Created At', Comment = 'Datei erstellt am'; }

        #endregion SourceFileProperties
        field(60; "Import XMLPort ID"; Integer)
        {
            Caption = 'Import XMLPortID', Comment = 'XMLPort ID für Import';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "Object ID" = filter('50000..'));
            ValidateTableRelation = false;
            BlankZero = true;
            trigger OnValidate()
            begin
                // if not ("Import XMLPort ID" in [50000 .. 99999, 0]) then
                //     Error(ObjectIDNotInIDRangeErr);
            end;
        }
        field(61; "Buffer Table ID"; Integer)
        {
            Caption = 'Buffertable ID', Comment = 'Puffertabelle ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "Object ID" = filter('50000..'));
            ValidateTableRelation = false;
            BlankZero = true;
            trigger OnValidate()
            begin
                // if not ("Import XMLPort ID" in [50000 .. 99999, 0]) then
                //     Error(ObjectIDNotInIDRangeErr);
            end;
        }
        field(62; "No.of Src.Fields Assigned"; Integer)
        {
            Caption = 'No.of Src.Fields Assigned', Comment = 'Anz. zugeordneter Felder';
            FieldClass = FlowField;
            CalcFormula = count("DMTField" where("Target Table ID" = field("Target Table ID"), "Source Field No." = filter(> 0)));
            Editable = false;
        }
        field(100; "Use OnInsert Trigger"; boolean)
        {
            Caption = 'Use OnInsert Trigger', Comment = 'OnInsert Trigger verwenden';
            InitValue = true;
        }
        field(101; "Sort Order"; Integer) { Caption = 'Sort Order', comment = 'Sortierung'; }
        field(102; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'Nur neue Datensätze importieren'; }
        field(103; LastView; Blob) { }
        field(104; LastFieldUpdateSelection; Blob) { Caption = 'Last Field Update Selection', Comment = 'Auswahl letzes Feldupdate'; }
        field(105; "Table Relations"; Integer) { Caption = 'Table Relations', Comment = 'Tabellenrelationen'; }
        field(106; "Unhandled Table Rel."; Integer) { Caption = 'Unhandled Table Rel.', Comment = 'Offene Tab. Rel.'; }
        field(200; LastImportToTargetAt; DateTime) { Caption = 'Last Import At (Target Table)', Comment = 'Letzter Import am (Zieltabelle)'; }
        field(201; "Import Duration (Longest)"; Duration) { Caption = 'Import Duration (Longest)', Comment = 'Import Dauer (Längste)'; }
        field(202; LastImportBy; Code[50])
        {
            Caption = 'User ID', comment = 'Benutzer-ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(203; LastImportToBufferAt; DateTime) { Caption = 'Last Import At (Buffer Table)', Comment = 'Letzter Import am (Puffertabelle)'; }
        field(300; ImportToBufferIndicator; Text[1]) { }
        field(301; ImportToBufferIndicatorStyle; Text[15]) { }
        field(302; ImportToTargetIndicator; Text[1]) { }
        field(303; ImportToTargetIndicatorStyle; Text[15]) { }
        field(304; ImportXMLPortIDStyle; Text[15]) { }
        field(305; BufferTableIDStyle; Text[15]) { }
        field(306; DataFilePathStyle; Text[15]) { }

        #region NAVDataSourceFields
        field(40; "Data Source Type"; Enum DMTDataSourceType) { Caption = 'Data Source Type'; }
        field(41; "NAV Schema File Status"; Option)
        {
            Caption = 'NAV Schema File Status', Comment = 'NAV Schema Datei Status';
            Editable = false;
            OptionMembers = "Import required",Imported;
            OptionCaptionML = ENU = '"Import required",Imported', DEU = '"Import erforderlich",Importiert';
        }
        field(42; "NAV Src.Table No."; Integer) { Caption = 'NAV Src.Table No.', Comment = 'NAV Tabellennr.'; }
        field(43; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; }
        field(44; "NAV Src.Table Caption"; Text[250])
        {
            Caption = 'NAV Source Table Caption';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.LookUpOldVersionTable(Rec);
                if "Target Table ID" = 0 then begin
                    Rec.Validate("Target Table Caption", Format("NAV Src.Table No."));
                    ProposeObjectIDs(false);
                    InitTableFieldMapping();
                end;
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit DMTObjMgt;
            begin
                ObjectMgt.ValidateFromTableCaption(Rec, xRec);
                if ("Target Table ID" = 0) and ("NAV Src.Table No." <> 0) then begin
                    Rec.Validate("Target Table Caption", Format("NAV Src.Table No."));
                    ProposeObjectIDs(false);
                end;
            end;
        }
        #endregion NAVDataSourceFields
    }

    keys
    {
        key(PK; "Target Table ID") { Clustered = true; }
        key(Sorted; "Sort Order") { }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Target Table ID", "Target Table Caption") { }
        fieldgroup(Brick; "Target Table Caption", "No.of Records in Buffer Table") { }
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
        rec.GetDataFilePathWithError(); //ThrowErrorIfNotSet
        case Rec.BufferTableType of
            Rec.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    rec.TestField("Import XMLPort ID");
                    file.Open(Rec.GetDataFilePath(), TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    Xmlport.Import(Rec."Import XMLPort ID", InStr);
                    UpdateQtyLinesInBufferTable();
                end;
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    file.Open(Rec.GetDataFilePath(), TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    GenBuffImport.SetSource(InStr);
                    GenBuffImport.SetDMTTable(Rec);
                    Progress.Open(StrSubstNo(ImportFileFromPathLbl, ConvertStr(file.Name, '\', '/')));
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
            if not GenBuffTable.FilterByFileName(Rec.GetDataFilePathWithError()) then
                exit(false);
            GenBuffTable.ShowImportDataForFile(Rec.GetDataFilePath());
        end;

        if Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV" then begin
            if Rec."Buffer Table ID" = 0 then exit(false);
            ShowTableContent(Rec."Buffer Table ID");
        end;
    end;

    internal procedure ShowTableContent(TableID: Integer) OK: Boolean
    var
        TableMeta: record "Table Metadata";
    begin
        OK := TableMeta.Get(TableID);
        if ok then
            Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;

    procedure ProposeObjectIDs(IsRenumberObjectsIntent: Boolean)
    var
        DMTSetup: Record "DMTSetup";
        DMTTable: Record DMTTable;
        ObjectMgt: Codeunit DMTObjMgt;
        AvailableTables: List of [Integer];
        AvailableXMLPorts: List of [Integer];
        NoAvailableObjectIDsErr: Label 'No free object IDs of type %1 could be found. Defined ID range in setup: %2',
                                comment = 'Es konnten keine freien Objekt-IDs vom Typ %1 gefunden werden. Definierter ID Bereich in der Einrichtung: %2';
    begin
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then
            exit;
        if not DMTSetup.Get() then
            DMTSetup.InsertWhenEmpty();
        DMTSetup.Get();

        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::Table, AvailableTables, false) = 0 then
            Error(NoAvailableObjectIDsErr, format(Enum::DMTObjTypes::Table), DMTSetup."Obj. ID Range Buffer Tables");
        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::XMLPort, AvailableXMLPorts, false) = 0 then
            Error(NoAvailableObjectIDsErr, format(Enum::DMTObjTypes::XMLPort), DMTSetup."Obj. ID Range Buffer Tables");

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
        if (rec."Buffer Table ID" = 0) and (AvailableTables.Count > 0) then begin
            Rec."Buffer Table ID" := AvailableTables.Get(1);
            AvailableTables.Remove(Rec."Buffer Table ID");
        end;
        // Import XMLPort ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range XMLPorts" <> '' then
        if (rec."Import XMLPort ID" = 0) and (AvailableXMLPorts.Count > 0) then begin
            rec."Import XMLPort ID" := AvailableXMLPorts.get(1);
            AvailableXMLPorts.Remove(Rec."Import XMLPort ID");
        end;
        if not IsRenumberObjectsIntent then begin
            TryFindBufferTableID(false);
            TryFindXMLPortID(false);
        end
    end;

    local procedure InitTableFieldMapping()
    var
        DMTFields: Record "DMTField";
        DMTSetup: record "DMTSetup";
    begin
        DMTSetup.CheckSchemaInfoHasBeenImporterd();
        if not DMTFields.FilterBy(Rec) then begin
            DMTFields.InitForTargetTable(Rec);
            // DMTFields.ProposeMatchingTargetFields(Rec);
            DMTFields.AssignSourceToTargetFields(Rec);
        end;

    end;

    procedure FindFileRec(File: Record File) Found: Boolean
    begin
        File.SetRange(Path, Rec.DataFileFolderPath);
        File.SetRange(Name, Rec.DataFileName);
        Found := File.FindFirst();
    end;

    procedure SetDataFilePath(CurrPath: Text)
    var
        FileMgt: Codeunit "File Management";
        File: Record File;
        FileNotAccessibleFromServiceLabelMsg: TextConst DEU = 'Der Pfad "%1" konnte vom Service Tier nicht erreicht werden', Comment = 'The path "%1" is not accessibly for the service tier';
    begin
        if CurrPath = '' then begin
            Rec.DataFileFolderPath := '';
            Rec.DataFileName := '';
            exit;
        end;
        // Remove quotes from path 
        CurrPath := CurrPath.TrimEnd('"').TrimStart('"');
        if CurrPath <> '' then begin
            Rec.DataFileFolderPath := CopyStr(FileMgt.GetDirectoryName(CurrPath), 1, MaxstrLen(Rec.DataFileFolderPath));
            Rec.DataFileName := CopyStr(FileMgt.GetFileName(CurrPath), 1, MaxStrLen(Rec.DataFileName));
        end;

        if (CurrPath <> '') then begin
            if not FileMgt.ServerFileExists(CurrPath) then
                Message(FileNotAccessibleFromServiceLabelMsg, DataFileFolderPath)
            else begin
                if Rec.FindFileRec(File) then begin
                    Rec."DataFile Size" := File.Size;
                    Rec."DataFile Created At" := CreateDateTime(File.Date, File.Time);
                end;
            end;
        end;
    end;

    procedure UpdateQtyLinesInBufferTable() QtyLines: Decimal;
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        if Rec."Target Table ID" = 0 then
            exit;

        case Rec.BufferTableType of
            Rec.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.FilterByFileName(Rec.GetDataFilePathWithError());
                    GenBuffTable.SetRange(IsCaptionLine, false);
                    QtyLines := GenBuffTable.Count;
                end;
            Rec.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    RecRef.Open(REc."Buffer Table ID");
                    QtyLines := RecRef.Count();
                end;
        end;
        // if Rec."No.of Records in Buffer Table" <> QtyLines then begin
        Rec.Get(Rec.RecordId);
        Rec."No.of Records in Buffer Table" := QtyLines;
        Rec.LastImportToBufferAt := CurrentDateTime;
        Rec.Modify();
        // end;
    end;

    procedure TryFindExportDataFile() FileExists: Boolean
    var
        DMTSetup: Record "DMTSetup";
        FileMgt: Codeunit "File Management";
        FilePath: Text;
    begin
        if (Rec.GetDataFilePath() <> '') and FileMgt.ServerFileExists(Rec.GetDataFilePath()) then
            exit(true);

        DMTSetup.Get();
        if DMTSetup."Default Export Folder Path" = '' then
            exit(false);
        //Land/Region -> Land_Region
        FilePath := FileMgt.CombinePath(DMTSetup."Default Export Folder Path", StrSubstNo('%1.csv', CONVERTSTR(Rec."NAV Src.Table Caption", '<>*\/|"', '_______')));
        if FileMgt.ServerFileExists(FilePath) then begin
            FileExists := true;
            Rec.SetDataFilePath(FilePath);
            Rec.Modify();
        end else begin
            //Message(FilePath);
        end;
    end;

    procedure TryFindBufferTableID(DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTSetup: Record DMTSetup;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        if DMTSetup.Get() and (DMTSetup."Obj. ID Range Buffer Tables" <> '') then
            AllObjWithCaption.SetFilter("Object ID", DMTSetup."Obj. ID Range Buffer Tables")
        else
            AllObjWithCaption.SetRange("Object ID", 50000, 99999);
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Buffer', Rec."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            Rec."Buffer Table ID" := AllObjWithCaption."Object ID";
            if DoModify then
                Rec.Modify();
        end;
    end;

    procedure TryFindXMLPortID(DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTSetup: Record DMTSetup;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::XMLport);
        if DMTSetup.Get() and (DMTSetup."Obj. ID Range Buffer Tables" <> '') then
            AllObjWithCaption.SetFilter("Object ID", DMTSetup."Obj. ID Range XMLPorts")
        else
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

    procedure DownloadAllALDataMigrationObjects()
    var
        DMTTable: Record DMTTable;
        DataCompression: Codeunit "Data Compression";
        ObjGen: Codeunit DMTObjectGenerator;
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: text;
        DefaultTextEncoding: TextEncoding;
    begin
        DefaultTextEncoding := TextEncoding::UTF8;
        // DefaultTextEncoding := TextEncoding::MSDos;
        // DefaultTextEncoding := TextEncoding::UTF16;
        // DefaultTextEncoding := TextEncoding::Windows;
        DMTTable.SetRange(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
        if DMTTable.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALTable(DMTTable).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, DMTTable.GetALBufferTableName());
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALXMLPort(DMTTable).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, DMTTable.GetALXMLPortName());
            until DMTTable.Next() = 0;
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr, DefaultTextEncoding);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(iStr, 'Download', 'ToFolder', format(Enum::DMTFileFilter::ZIP), toFileName);
    end;

    procedure WriteTableLastView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastView);
        Rec.Modify();
        rec.LastView.CreateOutStream(Ostr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;

    procedure ReadTableLastView() TableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(LastView);
        if not rec.LastView.HasValue then exit('');
        rec.LastView.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

    procedure WriteLastFieldUpdateSelection(LastFieldUpdateSelectionAsText: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastFieldUpdateSelection);
        Rec.Modify();
        rec.LastFieldUpdateSelection.CreateOutStream(Ostr);
        OStr.WriteText(LastFieldUpdateSelectionAsText);
        Rec.Modify();
    end;

    procedure ReadLastFieldUpdateSelection() LastFieldUpdateSelectionAsText: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(LastFieldUpdateSelection);
        if not rec.LastFieldUpdateSelection.HasValue then exit('');
        rec.LastFieldUpdateSelection.CreateInStream(IStr);
        IStr.ReadText(LastFieldUpdateSelectionAsText);
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

    internal procedure InitOrRefreshFieldSortOrder(): Boolean
    var
        DMTField: Record DMTField;
        RecID: RecordId;
        NewSortingValues: Dictionary of [RecordId, Integer];
        i: Integer;
    begin
        if Rec."Target Table ID" = 0 then
            exit(false);
        if not DMTField.FilterBy(Rec) then
            exit(false);
        DMTField.SetCurrentKey("Validation Order");
        if not DMTField.FindSet() then exit(false);
        repeat
            i += 1;
            if DMTField."Validation Order" <> i * 10000 then begin
                NewSortingValues.Add(DMTField.RecordId, i * 10000);
            end;
        until DMTField.Next() = 0;

        foreach RecID in NewSortingValues.Keys do begin
            DMTField.Get(RecID);
            DMTField."Validation Order" := NewSortingValues.Get(RecID);
            DMTField.Modify();
        end;
    end;

    internal procedure RenumberALObjects()
    var
        DMTTable: Record DMTTable;
        DMTSetup: Record DMTSetup;
        SessionStorage: Codeunit DMTSessionStorage;
        ObjectMgt: Codeunit DMTObjMgt;
        AvailableTables, AvailableXMLPorts : List of [Integer];
    begin
        SessionStorage.DisposeLicenseInfo();

        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::Table, AvailableTables, false) = 0 then
            Error('NoAvailableObjectIDsErr "%1"-"%2"', format(Enum::DMTObjTypes::Table), DMTSetup."Obj. ID Range Buffer Tables");
        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::XMLPort, AvailableXMLPorts, false) = 0 then
            Error('NoAvailableObjectIDsErr "%1"-"%2"', format(Enum::DMTObjTypes::XMLPort), DMTSetup."Obj. ID Range Buffer Tables");
        DMTSetup.Get();
        DMTSetup.TestField("Obj. ID Range Buffer Tables");
        DMTSetup.TestField("Obj. ID Range XMLPorts");


        DMTTable.ModifyAll("Buffer Table ID", 0);
        DMTTable.ModifyAll("Import XMLPort ID", 0);

        DMTTable.SetRange(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
        if DMTTable.FindSet() then
            repeat
                if AvailableTables.Count > 0 then begin
                    DMTTable."Buffer Table ID" := AvailableTables.Get(1);
                    AvailableTables.Remove(DMTTable."Buffer Table ID");
                end;
                if AvailableXMLPorts.Count > 0 then begin
                    DMTTable."Import XMLPort ID" := AvailableXMLPorts.Get(1);
                    AvailableXMLPorts.Remove(DMTTable."Import XMLPort ID");
                end;
                DMTTable.Modify();
            until DMTTable.Next() = 0;
    end;

    internal procedure RenewObjectIdAssignments()
    var
        DMTTable: Record DMTTable;
    begin
        DMTTable.SetRange(BufferTableType, DMTTable.BufferTableType::"Seperate Buffer Table per CSV");
        if DMTTable.FindSet() then
            repeat
                DMTTable.TryFindBufferTableID(true);
                DMTTable.TryFindXMLPortID(true);
            until DMTTable.Next() = 0;
    end;

    internal procedure GetDataFilePath() Path: Text
    var
        FileMgt: Codeunit "File Management";
    begin
        if (Rec.DataFileFolderPath = '') or (Rec.DataFileName = '') then
            exit('');
        Path := FileMgt.CombinePath(Rec.DataFileFolderPath, Rec.DataFileName);
    end;

    internal procedure GetDataFilePathWithError() Path: Text
    var
        FilePathEmptyErr: Label 'The Filepath is undefined.', comment = 'Der Dateipfad wurde nicht definiert.';
    begin
        Path := GetDataFilePath();
        if Path = '' then Error(FilePathEmptyErr);
    end;

    procedure CreateTableIDFilter(FieldNo: Integer) FilterExpr: Text;
    var
        DMTTable: Record DMTTable;
    begin
        If not DMTTable.FindSet(false, false) then
            exit('');
        repeat
            case FieldNo of
                DMTTable.FieldNo("Target Table ID"):
                    begin
                        if DMTTable."Target Table ID" <> 0 then
                            FilterExpr += StrSubstNo('%1|', DMTTable."Target Table ID");
                    end;
                DMTTable.FieldNo("NAV Src.Table No."):
                    begin
                        if DMTTable."NAV Src.Table No." <> 0 then
                            FilterExpr += StrSubstNo('%1|', DMTTable."Buffer Table ID");
                    end;
            end;
        until DMTTable.Next() = 0;
        FilterExpr := FilterExpr.TrimEnd('|');
    end;

    procedure GetNoOfRecordsInTrgtTable(): Integer
    var
        TableInformation: Record "Table Information";
    begin
        if TableInformation.Get(CompanyName, Rec."Target Table ID") then;
        // TableInformation.Calcfields("No. of Records");
        exit(TableInformation."No. of Records");
    end;

    procedure OpenCardPage()
    begin
        Page.Run(Page::DMTTableCard, Rec);
    end;

    procedure ImportSelectedIntoBuffer(var DMTTable_SELECTED: Record DMTTable)
    var
        DMTTable: Record DMTTable;
        Start: DateTime;
        TableStart: DateTime;
        Progress: Dialog;
        FinishedMsg: Label 'Processing finished\Duration %1', Comment = 'Vorgang abgeschlossen\Dauer %1';
        ImportFilesProgressMsg: Label 'Reading files into buffer tables', Comment = 'Dateien werden eingelesen';
        ProgressMsg: Text;
    begin
        DMTTable_SELECTED.SetCurrentKey("Sort Order");
        ProgressMsg := '==========================================\' +
                       ImportFilesProgressMsg + '\' +
                       '==========================================\';

        DMTTable_SELECTED.FindSet(false, false);
        REPEAT
            ProgressMsg += '\' + DMTTable_SELECTED."Target Table Caption" + '    ###########################' + FORMAT(DMTTable_SELECTED."Target Table ID") + '#';
        UNTIL DMTTable_SELECTED.NEXT() = 0;

        DMTTable_SELECTED.FindSet();
        Start := CurrentDateTime;
        Progress.Open(ProgressMsg);
        repeat
            TableStart := CurrentDateTime;
            DMTTable := DMTTable_SELECTED;
            Progress.Update(DMTTable_SELECTED."Target Table ID", 'Wird eingelesen');
            DMTTable.ImportToBufferTable();
            Commit();
            Progress.Update(DMTTable_SELECTED."Target Table ID", CURRENTDATETIME - TableStart);
        until DMTTable_SELECTED.Next() = 0;
        Progress.Close();
        Message(FinishedMsg, CurrentDateTime - Start);
    end;

    procedure UpdateIndicators()
    begin
        UpdateIndicator_ImportToBuffer();
        UpdateIndicator_ImportToTarget();
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            clear(Rec.ImportXMLPortIDStyle);
            clear(Rec.BufferTableIDStyle);
        end else begin
            Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if Rec.ImportXMLPortExits() then
                Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if Rec.CustomBufferTableExits() then
                Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
        DataFilePathStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
        if Rec.TryFindExportDataFile() then
            DataFilePathStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
    end;

    local procedure UpdateIndicator_ImportToBuffer()
    begin
        Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        Rec.ImportToBufferIndicator := ' ';
        case true of
            (Rec."No.of Records in Buffer Table" = 0):
                begin
                    Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    Rec.ImportToBufferIndicator := '✘';
                end;
            (Rec."No.of Records in Buffer Table" > 0):
                begin
                    Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    Rec.ImportToBufferIndicator := '✔';
                end;
        end;
    end;

    local procedure UpdateIndicator_ImportToTarget()
    begin
        Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        Rec.ImportToTargetIndicator := ' ';
        case true of
            (Rec.LastImportToTargetAt = 0DT) or (Rec."No.of Records in Buffer Table" > Rec."No. of Lines In Trgt. Table"):
                begin
                    Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    Rec.ImportToTargetIndicator := '✘';
                end;
            (Rec.LastImportToTargetAt <> 0DT) and (Rec."No.of Records in Buffer Table" <= Rec."No. of Lines In Trgt. Table"):
                begin
                    Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    Rec.ImportToTargetIndicator := '✔';
                end;
        end;
    end;

}