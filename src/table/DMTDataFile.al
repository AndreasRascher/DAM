table 73004 DMTDataFile
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
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Target Table ID")));
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
        field(20; Path; Code[98]) { Caption = 'Path'; Editable = false; }
        field(21; Name; Text[99]) { Caption = 'Name'; Editable = false; }
        field(22; Size; Integer) { Caption = 'Size'; Editable = false; }
        field(23; "Created At"; DateTime) { Caption = 'Created At'; Editable = false; }
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
                if (Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files") then begin
                    Clear(Rec."Import XMLPort ID");
                    Clear(Rec."Buffer Table ID");
                end;
                DataFileMgt.ProposeObjectIDs(Rec, false);
            end;
        }
        field(41; "Import XMLPort ID"; Integer)
        {
            Caption = 'Import XMLPortID', Comment = 'XMLPort ID für Import';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLport), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(42; "Buffer Table ID"; Integer)
        {
            Caption = 'Buffertable ID', Comment = 'Puffertabelle ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Current App Package ID Filter"));
            ValidateTableRelation = false;
            BlankZero = true;
        }
        field(43; "No.of Records in Buffer Table"; Integer) { Caption = 'No.of Records in Buffer Table', comment = 'Anz. Datensätze in Puffertabelle'; Editable = false; }
        #endregion Buffer Table Data
        #region Import and Processing Options
        field(50; "Use OnInsert Trigger"; Boolean) { Caption = 'Use OnInsert Trigger', Comment = 'OnInsert Trigger verwenden'; InitValue = true; }
        field(52; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'Nur neue Datensätze importieren'; }
        field(53; ImportFilter; TableFilter) { Caption = 'Import Filter', Comment = 'Import Filter'; }
        field(54; ImportGroup; Code[250]) { Caption = 'Import Group', comment = 'Import Gruppe'; }
        #endregion Import and Processing Options
        field(60; LastView; Blob) { }
        field(62; LastFieldUpdateSelection; Blob) { Caption = 'Last Field Update Selection', Comment = 'Auswahl letzes Feldupdate'; }
        field(80; "Table Relations"; Integer) { Caption = 'Table Relations', Comment = 'Tabellenrelationen'; }
        field(81; "Unhandled Table Rel."; Integer) { Caption = 'Unhandled Table Rel.', Comment = 'Offene Tab. Rel.'; }
        field(100; ImportToBufferIndicator; Enum DMTImportIndicator) { Caption = 'ImportToBufferIndicator', Locked = true; Editable = false; }
        field(101; ImportToBufferIndicatorStyle; Text[15]) { Caption = 'ImportToBufferIndicatorStyle', Locked = true; Editable = false; }
        field(102; ImportToTargetIndicator; Enum DMTImportIndicator) { Caption = 'ImportToTargetIndicator', Locked = true; Editable = false; }
        field(103; ImportToTargetIndicatorStyle; Text[15]) { Caption = 'ImportToTargetIndicatorStyle', Locked = true; }
        field(104; ImportXMLPortIDStyle; Text[15]) { Caption = 'ImportXMLPortIDStyle', Locked = true; Editable = false; }
        field(105; BufferTableIDStyle; Text[15]) { Caption = 'BufferTableIDStyle', Locked = true; Editable = false; }
        field(106; DataFileExistsStyle; Text[15]) { Caption = 'DataFilePathStyle', Locked = true; Editable = false; }

    }
    keys
    {
        key(Key1; ID) { Clustered = true; }
        key(Key2; "Sort Order", "Target Table ID") { }
        key(Key3; Path, Name) { }
    }

    fieldgroups
    {

        fieldgroup(DropDown; ID, Name, "NAV Src.Table No.", BufferTableType, "NAV Src.Table Name") { }
    }


    trigger OnInsert()
    var
        DMTFile: Record DMTDataFile;
    begin
        if (Path = '') or (Name = '') then
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

    procedure FilterRelated(var FieldMapping: Record DMTFieldMapping) HasLines: Boolean
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

    procedure CopyFrom(var FileRec: Record File)
    begin
        Rec.Size := FileRec.Size;
        Rec.Path := FileRec.Path;
        Rec.Name := FileRec.Name;
        Rec."Created At" := CreateDateTime(FileRec.Date, FileRec.Time);
    end;

    procedure GetRecByFilePath(FilePath: Text; FileName: Text) OK: Boolean
    var
        DataFile: Record DMTDataFile;
    begin
        DataFile.SetRange(Path, FilePath);
        DataFile.SetRange(Name, FileName);
        OK := DataFile.FindFirst();
        if OK then
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
        FullDataFilePath := FileMgt.CombinePath(Rec.Path, Rec.Name);
    end;

    internal procedure ShowBufferTable() OK: Boolean
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            if not GenBuffTable.FilterBy(Rec) then
                exit(false);
            GenBuffTable.ShowImportDataForFile(Rec);
        end;

        if Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV" then begin
            if Rec."Buffer Table ID" = 0 then exit(false);
            ShowTableContent(Rec."Buffer Table ID");
        end;
    end;

    internal procedure ShowTableContent(TableID: Integer) OK: Boolean
    var
        TableMeta: Record "Table Metadata";
    begin
        OK := TableMeta.Get(TableID);
        if OK then
            Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;
    /// <summary>
    /// Init App and Company FlowFilters for Company / App specific Counts and TableRelations
    /// </summary>
    internal procedure InitFlowFilters()
    begin
        Rec.SetRange("Current App Package ID Filter", GetCurrentAppPackageID());
        Rec.SetFilter("Other App Packages ID Filter", '<>%1', GetCurrentAppPackageID());
        Rec.SetRange("CompanyName Filter", CompanyName); // Required for Table Information Record Count
    end;

    procedure GetCurrentAppPackageID() PackageID: Text
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        PackageID := NAVAppInstalledApp."Package ID";
    end;

    procedure UpdateFileRecProperties(DoModify: Boolean)
    var
        FileRec: Record File;
    begin
        if Rec.FindFileRec(FileRec) then begin
            CopyFrom(FileRec);
            if DoModify then
                Rec.Modify();
        end;
    end;

    procedure ReadLastFieldUpdateSelection() LastFieldUpdateSelectionAsText: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastFieldUpdateSelection);
        if not Rec.LastFieldUpdateSelection.HasValue then exit('');
        Rec.LastFieldUpdateSelection.CreateInStream(IStr);
        IStr.ReadText(LastFieldUpdateSelectionAsText);
    end;

    procedure WriteLastFieldUpdateSelection(LastFieldUpdateSelectionAsText: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastFieldUpdateSelection);
        Rec.Modify();
        Rec.LastFieldUpdateSelection.CreateOutStream(OStr);
        OStr.WriteText(LastFieldUpdateSelectionAsText);
        Rec.Modify();
    end;

    procedure ReadLastSourceTableView() TableView: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(LastView);
        if not Rec.LastView.HasValue then exit('');
        Rec.LastView.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

    procedure WriteSourceTableView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.LastView);
        Rec.Modify();
        Rec.LastView.CreateOutStream(OStr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;

    procedure FindFileRec(var File: Record File) Found: Boolean
    begin
        File.SetRange(Path, Rec.Path);
        File.SetRange(Name, Rec.Name);
        File.SetRange("Is a file", true);
        Found := File.FindFirst();
    end;

    procedure UpdateIndicators()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        FileRec: Record File;
    begin
        DataFileExistsStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
        if Rec.FindFileRec(FileRec) then begin
            Rec.DataFileExistsStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            Rec.CopyFrom(FileRec);
        end;
        Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        Rec.ImportToBufferIndicator := Enum::DMTImportIndicator::Empty;

        case true of
            (Rec."No.of Records in Buffer Table" = 0):
                begin
                    Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    Rec.ImportToBufferIndicator := Enum::DMTImportIndicator::Cross;
                end;
            (Rec."No.of Records in Buffer Table" > 0):
                begin
                    Rec.ImportToBufferIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    Rec.ImportToBufferIndicator := Enum::DMTImportIndicator::CheckMark;
                end;
        end;
        Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::None);
        Rec.ImportToTargetIndicator := Enum::DMTImportIndicator::Empty;
        CalcFields(Rec."No. of Records In Trgt. Table");
        case true of
            /*(Rec.LastImportToTargetAt = 0DT) or*/
            (Rec."No.of Records in Buffer Table" > Rec."No. of Records In Trgt. Table"):
                begin
                    Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
                    Rec.ImportToTargetIndicator := Enum::DMTImportIndicator::Cross;
                end;
            /*(Rec.LastImportToTargetAt <> 0DT) and */
            (Rec."No.of Records in Buffer Table" <= Rec."No. of Records In Trgt. Table") and
            (Rec."No.of Records in Buffer Table" > 0):
                begin
                    Rec.ImportToTargetIndicatorStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
                    Rec.ImportToTargetIndicator := Enum::DMTImportIndicator::CheckMark;
                end;
        end;
        // Generated Objects exist
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            Clear(Rec.ImportXMLPortIDStyle);
            Clear(Rec.BufferTableIDStyle);
        end else begin
            Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if (Rec."Buffer Table ID" <> 0) then
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Buffer Table ID") then
                    Rec.BufferTableIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
            Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Italic + Red");
            if (Rec."Import XMLPort ID" <> 0) then
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::XMLport, Rec."Import XMLPort ID") then
                    Rec.ImportXMLPortIDStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    procedure CopyToTemp(var TempDataFile: Record DMTDataFile temporary)
    var
        DataFile: Record DMTDataFile;
        TempDataFile2: Record DMTDataFile temporary;
    begin
        DataFile.Copy(Rec);
        if DataFile.FindSet() then
            repeat
                TempDataFile2 := DataFile;
                TempDataFile2.Insert(false);
            until DataFile.Next() = 0;
        TempDataFile.Copy(TempDataFile2, true);
    end;

    procedure GetFileSizeInKB() FileSizeInKBText: Text
    var
        SizeInKB: Decimal;
    begin
        SizeInKB := Rec.Size / 1024;
        FileSizeInKBText := Format(SizeInKB, 0, '<Integer Thousand>');
        FileSizeInKBText += ' KB';
    end;

    procedure ClearProcessingInfo(DoModify: Boolean)
    begin
        Clear(ImportToBufferIndicator);
        Clear(ImportToBufferIndicatorStyle);
        Clear(BufferTableIDStyle);
        Clear(ImportToTargetIndicator);
        Clear(ImportToTargetIndicatorStyle);
        Clear(ImportXMLPortIDStyle);
        Clear(DataFileExistsStyle);
        Clear("No.of Records in Buffer Table");
    end;

    procedure InitBufferRef(var BufferRef: RecordRef)
    var
        GenBuffTable: Record DMTGenBuffTable;
        TableMetadata: Record "Table Metadata";
        BufferTableMissingErr: Label 'Buffer Table %1 not found';
    begin
        if Rec.BufferTableType = Rec.BufferTableType::"Generic Buffer Table for all Files" then begin
            // GenBuffTable.InitFirstLineAsCaptions(DMTRec);
            GenBuffTable.FilterGroup(2);
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterBy(Rec);
            GenBuffTable.FilterGroup(0);
            BufferRef.GetTable(GenBuffTable);
        end else
            if Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV" then begin
                if not TableMetadata.Get(Rec."Buffer Table ID") then
                    Error(BufferTableMissingErr, Rec."Buffer Table ID");
                BufferRef.Open(Rec."Buffer Table ID");
            end;
    end;

    procedure LoadFieldMapping(var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
    begin
        Rec.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        if Rec.BufferTableType = Rec.BufferTableType::"Seperate Buffer Table per CSV" then
            FieldMapping.SetFilter("Source Field No.", '<>0');
        FieldMapping.CopyToTemp(TempFieldMapping);
        OK := TempFieldMapping.FindFirst();
    end;

}