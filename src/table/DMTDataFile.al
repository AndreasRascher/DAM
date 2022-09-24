table 110042 "DMTDataFile"
{
    Caption = 'DMTDataFile', locked = true;
    DrillDownPageId = DMTDataFileList;
    LookupPageId = DMTDataFileList;
    fields
    {
        field(1; ID; Integer) { Caption = 'ID', Locked = true; }
        field(2; "Sort Order"; Integer) { Caption = 'Sort Order', comment = 'Sortierung'; }
        field(3; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', locked = true; FieldClass = FlowFilter; }
        field(4; "Other App Packages ID Filter"; Guid) { Caption = 'Other App Packages ID Filter', locked = true; FieldClass = FlowFilter; }
        field(5; "CompanyName Filter"; Text[30]) { Caption = 'Company Name Filter', locked = true; FieldClass = FlowFilter; }
        #region Target Table
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Zieltabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Other App Packages ID Filter"));
        }
        field(11; "Target Table Caption"; Text[250])
        {
            Caption = 'Target Table Caption', comment = 'Zieltabelle Bezeichnung';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
            Editable = false;
        }
        field(12; "No. of Records In Trgt. Table"; Integer)
        {
            Caption = 'No. of Lines in Target Table', Comment = 'Anz. Zeilen in Zieltabelle';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("Target Table ID"), "Company Name" = field("CompanyName Filter")));
            Editable = false;
        }
        #endregion Target Table
        #region FileInfo
        field(20; "Path"; Code[98]) { Caption = 'Path'; Editable = false; }
        field(21; "Name"; Text[99]) { Caption = 'Name'; Editable = false; }
        field(22; "Size"; Integer) { Caption = 'Size'; Editable = false; }
        field(23; "Created At"; DateTime) { Caption = 'DateTime'; Editable = false; }
        #endregion FileInfo
        #region Buffer Table Data
        field(30; "NAV Src.Table No."; Integer)
        {
            Caption = 'NAV Src.Table No.', Comment = 'NAV Tabellennr.';
            trigger OnValidate()
            var
                ObjMgt: Codeunit DMTObjMgt;
            begin
                ObjMgt.SetNAVTableCaptionAndTableName("NAV Src.Table No.", Rec."NAV Src.Table Caption", Rec."NAV Src.Table Name");
            end;
        }
        field(31; "NAV Src.Table Name"; Text[250]) { Caption = 'NAV Source Table Name'; Editable = false; }
        field(32; "NAV Src.Table Caption"; Text[250]) { Caption = 'NAV Source Table Caption'; Editable = false; }
        field(40; BufferTableType; Enum BufferTableType)
        {
            Caption = 'Buffer Table Type', Comment = 'Puffertabellenart';
            trigger OnValidate()
            var
                DataFileMgt: Codeunit DMTDataFilePageAction;
            begin
                if (Rec.BuffertableType = Rec.BufferTableType::"Generic Buffer Table for all Files") then begin
                    Clear(Rec."Import XMLPort ID");
                    Clear(Rec."Buffer Table ID");
                end;
                DataFileMgt.ProposeObjectIDs(Rec, false);
            end;
        }
        field(41; "Import XMLPort ID"; Integer)
        {
            Caption = 'Import XMLPortID', Comment = 'XMLPort ID für Import';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(42; "Buffer Table ID"; Integer)
        {
            Caption = 'Buffertable ID', Comment = 'Puffertabelle ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(43; "No.of Records in Buffer Table"; Integer) { Caption = 'No.of Records in Buffer Table', comment = 'Anz. Datensätze in Puffertabelle'; Editable = false; }
        #endregion Buffer Table Data
        #region Import and Processing Options
        field(50; "Use OnInsert Trigger"; boolean) { Caption = 'Use OnInsert Trigger', Comment = 'OnInsert Trigger verwenden'; InitValue = true; }
        field(51; "Allow Usage of Try Function"; Boolean) { Caption = 'Allow Usage of Try Function', Comment = 'Verwendung von Try Funktion zulassen'; InitValue = true; }
        field(52; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'Nur neue Datensätze importieren'; }
        #endregion Import and Processing Options
        field(60; LastView; Blob) { }
        field(61; LastImportToTargetAt; DateTime) { Caption = 'Last Import At (Target Table)', Comment = 'Letzter Import am (Zieltabelle)'; }
        field(62; LastFieldUpdateSelection; Blob) { Caption = 'Last Field Update Selection', Comment = 'Auswahl letzes Feldupdate'; }
        field(70; LastImportBy; Code[50]) { Caption = 'User ID', comment = 'Benutzer-ID'; TableRelation = User."User Name"; Editable = false; }
        field(71; "Import Duration (Longest)"; Duration) { Caption = 'Import Duration (Longest)', Comment = 'Import Dauer (Längste)'; Editable = false; }
        field(72; LastImportToBufferAt; DateTime) { Caption = 'Last Import At (Buffer Table)', Comment = 'Letzter Import am (Puffertabelle)'; Editable = false; }
        field(80; "Table Relations"; Integer) { Caption = 'Table Relations', Comment = 'Tabellenrelationen'; }
        field(81; "Unhandled Table Rel."; Integer) { Caption = 'Unhandled Table Rel.', Comment = 'Offene Tab. Rel.'; }
        field(100; ImportToBufferIndicator; Enum DMTImportIndicator) { Caption = 'ImportToBufferIndicator', Locked = true; Editable = false; }
        field(101; ImportToBufferIndicatorStyle; Text[15]) { Caption = 'ImportToBufferIndicatorStyle', Locked = true; Editable = false; }
        field(102; ImportToTargetIndicator; Enum DMTImportIndicator) { Caption = 'ImportToTargetIndicator', Locked = true; Editable = false; }
        field(103; ImportToTargetIndicatorStyle; Text[15]) { Caption = 'ImportToTargetIndicatorStyle', Locked = true; }
        field(104; ImportXMLPortIDStyle; Text[15]) { Caption = 'ImportXMLPortIDStyle', Locked = true; Editable = false; }
        field(105; BufferTableIDStyle; Text[15]) { Caption = 'BufferTableIDStyle', Locked = true; Editable = false; }
        field(106; DataFilePathStyle; Text[15]) { Caption = 'DataFilePathStyle', Locked = true; Editable = false; }

    }
    keys
    {
        key(Key1; ID) { Clustered = true; }
        key(Key2; "Sort Order", "Target Table ID") { }
        key(Key3; Path, Name) { }
    }

    trigger OnInsert()
    var
        DMTFile: Record DMTDataFile;
    begin
        if ("Path" = '') or ("Name" = '') then
            Error(Format(Enum::DMTErrMsg::NoFilePathSelectedError));
        if DMTFile.GetRecByFilePath(Path, Name) then
            Error('FileRecordExistsAlready');
        if ID = 0 then
            Rec.ID := GetNextNo();
    end;

    trigger OnDelete()
    var
        FieldMapping: Record DMTFieldMapping;
        GenBuffTable: Record DMTGenBuffTable;
    begin
        if FilterRelated(FieldMapping) then
            FieldMapping.DeleteAll();
        if GenBuffTable.FilterBy(Rec) then
            GenBuffTable.DeleteAll();
    end;

    procedure FilterRelated(var FieldMapping: Record DMTFieldMapping) HasLines: boolean
    begin
        FieldMapping.SetRange("Data File ID", Rec.ID);
        HasLines := not FieldMapping.IsEmpty;
    end;

    local procedure GetNextNo() NextNo: Integer;
    var
        DataFile: Record DMTDataFile;
    begin
        NextNo := 1;
        if DataFile.FindLast() then
            NextNo += DataFile.ID;
    end;

    procedure GetRecByFilePath(FilePath: Text; FileName: Text) OK: Boolean
    var
        DataFile: Record DMTDataFile;
    begin
        DataFile.Setrange("Path", FilePath);
        DataFile.Setrange("Name", FileName);
        OK := DataFile.FindFirst();
        Rec.Copy(DataFile);
    end;

    procedure GetRecByFilePath(FullFilePath: Text) OK: Boolean
    var
        FileMgt: Codeunit "File Management";
    begin
        OK := GetRecByFilePath(FileMgt.GetDirectoryName(FullFilePath), FileMgt.GetFileName(FullFilePath));
    end;

    procedure FullDataFilePath() FullDataFilePath: Text
    var
        FileMgt: Codeunit "File Management";
    begin
        FullDataFilePath := FileMgt.CombinePath(Rec.Path, rec.Name);
    end;

    internal procedure ShowBufferTable() OK: Boolean
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            if not GenBuffTable.FilterBy(Rec) then
                exit(false);
            GenBuffTable.ShowImportDataForFile(Rec.RecordId);
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

    internal procedure InitFlowFilters()
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        Rec.SetRange("Current App Package ID Filter", NAVAppInstalledApp."Package ID");
        Rec.SetFilter("Other App Packages ID Filter", '<>%1', NAVAppInstalledApp."Package ID");
        Rec.SetRange("CompanyName Filter", CompanyName); // Required for Table Information Record Count
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

    procedure ReadTableLastView() TableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(LastView);
        if not rec.LastView.HasValue then exit('');
        rec.LastView.CreateInStream(IStr);
        IStr.ReadText(TableView);
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

}