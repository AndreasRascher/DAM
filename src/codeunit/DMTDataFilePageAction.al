codeunit 110013 "DMTDataFilePageAction"
{
    internal procedure InitFieldMapping(DataFileID: Integer): Boolean
    var
        DataFile: Record DMTDataFile;
        FieldMapping, FieldMapping_NEW : Record DMTFieldMapping;
        DMTmgt: Codeunit DMTMgt;
        TargetRecRef: RecordRef;
        i: Integer;
        KeyFieldIDsList: List of [Integer];
    begin
        DataFile.Get(DataFileID);
        DataFile.TestField("Target Table ID");
        if DataFile."Target Table ID" = 0 then
            exit(false);
        TargetRecRef.Open(DataFile."Target Table ID");
        KeyFieldIDsList := DMTmgt.GetListOfKeyFieldIDs(TargetRecRef);
        for i := 1 to TargetRecRef.FieldCount do begin
            if TargetRecRef.FieldIndex(i).Active then
                if (TargetRecRef.FieldIndex(i).Class = TargetRecRef.FieldIndex(i).Class::Normal) then begin
                    DataFile.FilterRelated(FieldMapping);
                    FieldMapping.SetRange("Target Field No.", TargetRecRef.FieldIndex(i).Number);
                    if FieldMapping.IsEmpty then begin
                        FieldMapping_NEW."Data File ID" := DataFileID;
                        FieldMapping_NEW."Source Table ID" := DataFile."Buffer Table ID";
                        FieldMapping_NEW."Target Field No." := TargetRecRef.FieldIndex(i).Number;
                        FieldMapping_NEW."Target Table ID" := DataFile."Target Table ID";
                        FieldMapping_NEW."Processing Action" := FieldMapping_NEW."Processing Action"::Ignore; //default for fields without action
                        FieldMapping_NEW."Validation Order" := i * 10000;
                        FieldMapping_NEW."Is Key Field(Target)" := KeyFieldIDsList.Contains(FieldMapping_NEW."Target Field No.");
                        FieldMapping_NEW.Insert(true);
                    end;
                end;
        end;
    end;

    procedure ProposeMatchingFields("Data File ID": Integer)
    var
        DataFile: Record DMTDataFile;
    begin
        DataFile.Get("Data File ID");
        AssignSourceToTargetFields(DataFile);
        ProposeValidationRules(DataFile);
    end;

    local procedure AssignSourceToTargetFields(DataFile: Record DMTDataFile)
    var
        FieldMapping: Record DMTFieldMapping;
        MigrationLib: Codeunit DMTMigrationLib;
        SourceFieldNames, TargetFieldNames : Dictionary of [Integer, Text];
        FoundAtIndex: Integer;
        SourceFieldID, TargetFieldID : Integer;
        NewFieldName, SourceFieldName : Text;
    begin
        // Load Target Field Names
        TargetFieldNames := CreateTargetFieldNamesDict(DataFile);
        If TargetFieldNames.Count = 0 then
            exit;

        //Load Source Field Names
        SourceFieldNames := CreateSourceFieldNamesDict(DataFile);
        If SourceFieldNames.Count = 0 then
            exit;

        //Match Fields by Name
        foreach SourceFieldID in SourceFieldNames.Keys do begin
            SourceFieldName := SourceFieldNames.Get(SourceFieldID);
            FoundAtIndex := TargetFieldNames.Values.IndexOf(SourceFieldName);
            // TargetField.SetFilter(FieldName, ConvertStr(BuffTableCaption, '@()&', '????'));
            if FoundAtIndex = 0 then
                if MigrationLib.FindFieldNameInOldVersion(SourceFieldName, DataFile."Target Table ID", NewFieldName) then
                    FoundAtIndex := TargetFieldNames.Values.IndexOf(NewFieldName);
            if FoundAtIndex <> 0 then begin
                TargetFieldID := TargetFieldNames.Keys.Get(FoundAtIndex);
                // SetSourceField
                FieldMapping.Get(DataFile.ID, TargetFieldID);
                FieldMapping.Validate("Source Field No.", SourceFieldID); // Validate to update processing action
                FieldMapping."Source Field Caption" := copyStr(TargetFieldNames.Get(TargetFieldID), 1, MaxStrLen(FieldMapping."Source Field Caption"));
                FieldMapping.Modify();
            end;
        end;
    end;

    internal procedure ProposeValidationRules(DataFile: Record DMTDataFile): Boolean
    var
        FieldMapping, FieldMapping2 : Record DMTFieldMapping;
        MigrationLib: Codeunit DMTMigrationLib;
    begin
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetRange("Processing Action", FieldMapping."Processing Action"::Transfer);
        if FieldMapping.FindSet(true, false) then
            repeat
                FieldMapping2 := FieldMapping;
                MigrationLib.ApplyKnownValidationRules(FieldMapping);
                if format(FieldMapping2) <> Format(FieldMapping) then
                    FieldMapping.Modify()
            until FieldMapping.Next() = 0;
    end;

    local procedure CreateTargetFieldNamesDict(DataFile: Record DMTDataFile) TargetFieldNames: Dictionary of [Integer, Text]
    var
        FieldMapping: Record DMTFieldMapping;
        Field: Record Field;
        ReplaceExistingMatchesQst: Label 'All fields are already assigned. Overwrite existing assignment?', comment = 'Alle Felder sind bereits zugewiesen. Bestehende Zuordnung überschreiben?';
    begin
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Source Field No.", '<>%1', 0);
        if FieldMapping.FindFirst() then begin
            if Confirm(ReplaceExistingMatchesQst) then begin
                FieldMapping.SetRange("Source Field No.");
            end;
        end else begin
            FieldMapping.SetRange("Source Field No."); // no fields assigned case
        end;
        if not FieldMapping.FindSet() then
            exit;
        repeat
            Field.get(FieldMapping."Target Table ID", FieldMapping."Target Field No.");
            TargetFieldNames.Add(Field."No.", Field.FieldName);
        until FieldMapping.Next() = 0;
    end;

    local procedure CreateSourceFieldNamesDict(DataFile: Record DMTDataFile) SourceFieldNames: Dictionary of [Integer, Text]
    var
        GenBuffTable: Record DMTGenBuffTable;
        Field: Record Field;
        SourceFieldNames2: Dictionary of [Integer, Text];
        FieldID: Integer;
    begin
        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    Field.SetRange(TableNo, DataFile."Buffer Table ID");
                    Field.SetRange(Enabled, true);
                    Field.SetRange(Class, Field.Class::Normal);
                    Field.FindSet();
                    repeat
                        SourceFieldNames.Add(Field."No.", Field.FieldName);
                    until Field.Next() = 0;
                end;
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.GetColCaptionForImportedFile(DataFile, SourceFieldNames2);
                    foreach FieldID in SourceFieldNames2.Keys do begin
                        SourceFieldNames.Add(FieldID + 1000, SourceFieldNames2.Get(FieldID));
                    end;
                end;
        end;
    end;

    internal procedure FieldMapping_SetValidateField(TempFieldMapping_Selected: Record DMTFieldMapping temporary; NewValue: Enum DMTFieldValidationType)
    var
        FieldMapping: Record DMTFieldMapping;
        NoOfRecords: Integer;
    begin
        NoOfRecords := TempFieldMapping_Selected.Count;
        if not TempFieldMapping_Selected.FindFirst() then exit;
        TempFieldMapping_Selected.FindSet();
        repeat
            FieldMapping.Get(TempFieldMapping_Selected.RecordId);
            if FieldMapping."Validation Type" <> NewValue then begin
                FieldMapping."Validation Type" := NewValue;
                FieldMapping.Modify()
            end;
        until TempFieldMapping_Selected.Next() = 0;
    end;

    procedure MoveSelectedLines(TempFieldMapping_Selected: Record DMTFieldMapping temporary; Direction: Option Up,Down,Top,Bottom)
    var
        FieldMapping: Record DMTFieldMapping;
        TempFieldMapping: Record DMTFieldMapping temporary;
        i: Integer;
        RefPos: Integer;
    begin
        FieldMapping.SetRange("Target Table ID", TempFieldMapping_Selected."Target Table ID");
        FieldMapping.SetCurrentKey("Validation Order");
        FieldMapping.CopyToTemp(TempFieldMapping);

        TempFieldMapping.SetCurrentKey("Validation Order");
        case Direction of
            Direction::Bottom:
                begin
                    TempFieldMapping.FindLast();
                    RefPos := TempFieldMapping."Validation Order";
                    TempFieldMapping_Selected.FindSet();
                    repeat
                        i += 1;
                        TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                        TempFieldMapping."Validation Order" := RefPos + i * 10000;
                        TempFieldMapping.Modify();
                    until TempFieldMapping_Selected.Next() = 0;
                end;
            Direction::Top:
                begin
                    TempFieldMapping.FindFirst();
                    RefPos := TempFieldMapping."Validation Order";
                    TempFieldMapping_Selected.find('+');
                    repeat
                        i += 1;
                        TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                        TempFieldMapping."Validation Order" := RefPos - i * 10000;
                        TempFieldMapping.Modify();
                    until TempFieldMapping_Selected.Next(-1) = 0;
                end;
            Direction::Up:
                begin
                    TempFieldMapping_Selected.FindSet();
                    repeat
                        TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                        RefPos := TempFieldMapping."Validation Order";
                        if TempFieldMapping.Next(-1) <> 0 then begin
                            i := TempFieldMapping."Validation Order";
                            TempFieldMapping."Validation Order" := RefPos;
                            TempFieldMapping.Modify();
                            TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                            TempFieldMapping."Validation Order" := i;
                            TempFieldMapping.Modify();
                        end;
                    until TempFieldMapping_Selected.Next() = 0;
                end;
            Direction::Down:
                begin
                    TempFieldMapping_Selected.SetCurrentKey("Validation Order");
                    TempFieldMapping_Selected.Ascending(false);
                    TempFieldMapping_Selected.FindSet();
                    repeat
                        TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                        RefPos := TempFieldMapping."Validation Order";
                        if TempFieldMapping.Next(1) <> 0 then begin
                            i := TempFieldMapping."Validation Order";
                            TempFieldMapping."Validation Order" := RefPos;
                            TempFieldMapping.Modify();
                            TempFieldMapping.Get(TempFieldMapping_Selected.RecordId);
                            TempFieldMapping."Validation Order" := i;
                            TempFieldMapping.Modify();
                        end;
                    until TempFieldMapping_Selected.Next() = 0;
                end;
        end;
        TempFieldMapping.Reset();
        TempFieldMapping.SetCurrentKey("Validation Order");
        TempFieldMapping.FindSet();
        Clear(i);
        repeat
            i += 1;
            FieldMapping.Get(TempFieldMapping.RecordId);
            FieldMapping."Validation Order" := i * 10000;
            FieldMapping.Modify(false);
        until TempFieldMapping.Next() = 0;
    end;

    procedure DownloadALXMLPort(DataFile: Record DMTDataFile)
    var
        DMTObjectGenerator: Codeunit "DMTCodeGenerator";
    begin
        DMTObjectGenerator.DownloadFile(DMTObjectGenerator.CreateALXMLPort(DataFile), GetALXMLPortName(DataFile));
    end;

    procedure DownloadALBufferTableFile(DataFile: Record DMTDataFile)
    var
        DMTObjectGenerator: Codeunit "DMTCodeGenerator";
    begin
        DMTObjectGenerator.DownloadFile(
        DMTObjectGenerator.CreateALTable(DataFile), GetALBufferTableName(DataFile));
    end;

    local procedure GetALBufferTableName(DataFile: Record DMTDataFile) Name: Text;
    begin
        Name := StrSubstNo('TABLE %1 - T%2Buffer.al', DataFile."Buffer Table ID", DataFile."NAV Src.Table No.");
    end;

    local procedure GetALXMLPortName(DataFile: Record DMTDataFile) Name: Text;
    begin
        Name := StrSubstNo('XMLPORT %1 - T%2Import.al', DataFile."Import XMLPort ID", DataFile."NAV Src.Table No.");
    end;

    procedure ImportToBufferTable(DataFile: Record DMTDataFile; HideDialog: Boolean)
    var
        GenBuffImport: XmlPort DMTGenBuffImport;
        Start: DateTime;
        Progress: Dialog;
        File: File;
        InStr: InStream;
        ImportFileFromPathLbl: Label 'Importing %1';
    begin
        Start := CurrentDateTime;
        DataFile.TestField("Target Table ID");
        Commit();
        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    DataFile.TestField("Import XMLPort ID");
                    file.Open(DataFile.FullDataFilePath(), TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    Xmlport.Import(DataFile."Import XMLPort ID", InStr);
                    UpdateQtyLinesInBufferTable(DataFile);
                end;
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    file.Open(DataFile.FullDataFilePath(), TextEncoding::MSDos);
                    file.CreateInStream(InStr);
                    GenBuffImport.SetSource(InStr);
                    GenBuffImport.SetImportFromFile(DataFile);
                    if not HideDialog then
                        Progress.Open(StrSubstNo(ImportFileFromPathLbl, ConvertStr(file.Name, '\', '/')));
                    GenBuffImport.Import();
                    if not HideDialog then
                        Progress.Close();
                    UpdateQtyLinesInBufferTable(DataFile);
                end;
        end;
        DataFile.Get(DataFile.RecordID);
        DataFile."Import Duration (Buffer)" := CurrentDateTime - Start;
        DataFile.Modify();
    end;

    procedure ImportSelectedIntoBuffer(var DataFile_SELECTED: Record DMTDataFile temporary)
    var
        DataFile: Record DMTDataFile;
        Start: DateTime;
        TableStart: DateTime;
        Progress: Dialog;
        FinishedMsg: Label 'Processing finished\Duration %1', Comment = 'Vorgang abgeschlossen\Dauer %1';
        ImportFilesProgressMsg: Label 'Reading files into buffer tables', Comment = 'Dateien werden eingelesen';
        ProgressMsg: Text;
    begin
        DataFile_SELECTED.SetCurrentKey("Sort Order");
        ProgressMsg := '==========================================\' +
                       ImportFilesProgressMsg + '\' +
                       '==========================================\';
        DataFile_SELECTED.SetAutoCalcFields("Target Table Caption");
        DataFile_SELECTED.FindSet();
        REPEAT
            ProgressMsg += '\' + DataFile_SELECTED."Target Table Caption" + '    ###########################' + FORMAT(DataFile_SELECTED."Target Table ID") + '#';
        UNTIL DataFile_SELECTED.NEXT() = 0;

        DataFile_SELECTED.FindSet();
        Start := CurrentDateTime;
        Progress.Open(ProgressMsg);
        repeat
            TableStart := CurrentDateTime;
            DataFile := DataFile_SELECTED;
            Progress.Update(DataFile_SELECTED."Target Table ID", 'Wird eingelesen');
            ImportToBufferTable(DataFile, true);
            Commit();
            Progress.Update(DataFile_SELECTED."Target Table ID", CURRENTDATETIME - TableStart);
        until DataFile_SELECTED.Next() = 0;
        Progress.Close();
        Message(FinishedMsg, CurrentDateTime - Start);
    end;

    procedure UpdateQtyLinesInBufferTable(DataFile: Record DMTDataFile) QtyLines: Decimal;
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        if DataFile."Target Table ID" = 0 then
            exit;

        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    GenBuffTable.FilterBy(DataFile);
                    GenBuffTable.SetRange(IsCaptionLine, false);
                    QtyLines := GenBuffTable.Count;
                end;
            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    RecRef.Open(DataFile."Buffer Table ID");
                    QtyLines := RecRef.Count();
                end;
        end;
        // if Rec."No.of Records in Buffer Table" <> QtyLines then begin
        DataFile.Get(DataFile.RecordId);
        DataFile."No.of Records in Buffer Table" := QtyLines;
        DataFile.LastImportToBufferAt := CurrentDateTime;
        DataFile.Modify();
        // end;
    end;

    procedure RetryBufferRecordsWithError(DataFile: Record DMTDataFile)
    var
        DMTImportNew: Codeunit DMTImport;
        DMTErrorLogQry: Query DMTErrorLogQry;
        RecIdList: list of [RecordID];
    begin
        DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileFolderPath, DataFile.Path);
        DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileName, DataFile.Name);
        DMTErrorLogQry.Open();
        while DMTErrorLogQry.Read() do begin
            RecIdList.Add(DMTErrorLogQry.FromID);
        end;
        DMTImportNew.RetryProcessFullBuffer(RecIdList, DataFile, false);
        DataFile.Get(DataFile.RecordId);
        DataFile.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DataFile.LastImportBy));
        DataFile.LastImportToTargetAt := CurrentDateTime;
        DataFile.Modify();
    end;

    procedure TryFindBufferTableID(var DataFile: Record DMTDataFile; DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTSetup: Record DMTSetup;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        if DMTSetup.Get() and (DMTSetup."Obj. ID Range Buffer Tables" <> '') then
            AllObjWithCaption.SetFilter("Object ID", DMTSetup."Obj. ID Range Buffer Tables")
        else
            AllObjWithCaption.SetRange("Object ID", 50000, 99999);
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Buffer', DataFile."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            DataFile."Buffer Table ID" := AllObjWithCaption."Object ID";
            if DoModify then
                DataFile.Modify();
        end;
    end;

    procedure TryFindXMLPortID(var DataFile: Record DMTDataFile; DoModify: Boolean)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        DMTSetup: Record DMTSetup;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::XMLport);
        if DMTSetup.Get() and (DMTSetup."Obj. ID Range Buffer Tables" <> '') then
            AllObjWithCaption.SetFilter("Object ID", DMTSetup."Obj. ID Range XMLPorts")
        else
            AllObjWithCaption.SetRange("Object ID", 50000, 99999);
        AllObjWithCaption.SetRange("Object Name", StrSubstNo('T%1Import', DataFile."NAV Src.Table No."));
        if AllObjWithCaption.FindFirst() then begin
            DataFile."Import XMLPort ID" := AllObjWithCaption."Object ID";
            if DoModify then
                DataFile.Modify();
        end;
    end;

    procedure ProposeObjectIDs(var DataFileRec: record DMTDataFile; IsRenumberObjectsIntent: Boolean)
    var
        DataFile: Record DMTDataFile;
        DMTSetup: Record "DMTSetup";
        ObjectMgt: Codeunit DMTObjMgt;
        NoAvailableObjectIDsErr: Label 'No free object IDs of type %1 could be found. Defined ID range in setup: %2',
                                comment = 'Es konnten keine freien Objekt-IDs vom Typ %1 gefunden werden. Definierter ID Bereich in der Einrichtung: %2';
        AvailableTables: List of [Integer];
        AvailableXMLPorts: List of [Integer];
    begin
        if DataFileRec.BufferTableType = DataFileRec.BufferTableType::"Generic Buffer Table for all Files" then
            exit;
        if not DMTSetup.Get() then
            DMTSetup.InsertWhenEmpty();
        DMTSetup.Get();

        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::Table, AvailableTables, false) = 0 then
            Error(NoAvailableObjectIDsErr, format(Enum::DMTObjTypes::Table), DMTSetup."Obj. ID Range Buffer Tables");
        if ObjectMgt.CreateListOfAvailableObjectIDsInLicense(Enum::DMTObjTypes::XMLPort, AvailableXMLPorts, false) = 0 then
            Error(NoAvailableObjectIDsErr, format(Enum::DMTObjTypes::XMLPort), DMTSetup."Obj. ID Range Buffer Tables");

        // Collect used numbers
        if DataFile.FindSet() then
            repeat
                if DataFile."Import XMLPort ID" <> 0 then
                    if AvailableXMLPorts.Contains(DataFile."Import XMLPort ID") then
                        AvailableXMLPorts.Remove(DataFile."Import XMLPort ID");
                if DataFile."Buffer Table ID" <> 0 then
                    if AvailableTables.Contains(DataFile."Buffer Table ID") then
                        AvailableTables.Remove(DataFile."Buffer Table ID");
            until DataFile.Next() = 0;

        // Buffer Table ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range Buffer Tables" <> '' then
        if (DataFileRec."Buffer Table ID" = 0) and (AvailableTables.Count > 0) then begin
            DataFileRec."Buffer Table ID" := AvailableTables.Get(1);
            AvailableTables.Remove(DataFileRec."Buffer Table ID");
        end;
        // Import XMLPort ID - Assign Next Number in Filter
        // if DMTSetup."Obj. ID Range XMLPorts" <> '' then
        if (DataFileRec."Import XMLPort ID" = 0) and (AvailableXMLPorts.Count > 0) then begin
            DataFileRec."Import XMLPort ID" := AvailableXMLPorts.get(1);
            AvailableXMLPorts.Remove(DataFileRec."Import XMLPort ID");
        end;
        if not IsRenumberObjectsIntent then begin
            TryFindBufferTableID(DataFileRec, false);
            TryFindXMLPortID(DataFileRec, false);
        end
    end;

    internal procedure AutoMigration(var DataFile: Record DMTDataFile)
    var
        DMTImportNew: Codeunit DMTImport;
    begin
        DataFile.TestField("Target Table ID");
        DataFile.Modify();
        ImportToBufferTable(DataFile, false);
        ProposeMatchingFields(DataFile.ID);
        DMTImportNew.StartImport(DataFile, true, false);
    end;

    procedure DeleteSelectedTargetTables(var DataFile_SELECTED: Record DMTDataFile temporary)
    var
        DataFile: Record DMTDataFile;
    begin
        if not (DataFile_SELECTED.FindFirst()) then
            exit;
        repeat
            DataFile := DataFile_SELECTED;
            DataFile.Delete(true);
        until DataFile_SELECTED.Next() = 0;
    end;

    procedure CreateTableIDFilter(var DataFileRec: record DMTDataFile; FieldNo: Integer) FilterExpr: Text;
    var
        DataFile: Record DMTDataFile;
        Integer: Record integer;
    begin
        if DataFileRec.HasFilter then
            DataFile.CopyFilters(DataFileRec);
        If not DataFile.FindSet(false, false) then
            exit('');
        repeat
            case FieldNo of
                DataFile.FieldNo("Target Table ID"):
                    begin
                        if DataFile."Target Table ID" <> 0 then
                            FilterExpr += StrSubstNo('%1|', DataFile."Target Table ID");
                    end;
                DataFile.FieldNo("NAV Src.Table No."):
                    begin
                        if DataFile."NAV Src.Table No." <> 0 then
                            FilterExpr += StrSubstNo('%1|', DataFile."NAV Src.Table No.");
                    end;
            end;
        until DataFile.Next() = 0;
        FilterExpr := FilterExpr.TrimEnd('|');
        //Sort
        Integer.setfilter(Number, FilterExpr);
        Clear(FilterExpr);
        if Integer.FindSet() then
            repeat
                FilterExpr += StrSubstNo('%1|', Integer.Number);
            until Integer.Next() = 0;
        FilterExpr := FilterExpr.TrimEnd('|');
    end;

    internal procedure ImportSelectedIntoTarget(var DataFile_SELECTED: Record DMTDataFile temporary)
    var
        DataFile: Record DMTDataFile;
        DMTImport: Codeunit DMTImport;
    begin
        DataFile_SELECTED.SetCurrentKey("Sort Order");
        if not DataFile_SELECTED.FindSet() then exit;
        repeat
            DataFile := DataFile_SELECTED;
            DMTImport.StartImport(DataFile, true, false);
        until DataFile_SELECTED.Next() = 0;
    end;

    procedure DownloadAllALDataMigrationObjects()
    var
        DataFile: Record DMTDataFile;
        DataCompression: Codeunit "Data Compression";
        ObjGen: Codeunit "DMTCodeGenerator";
        FileBlob: Codeunit "Temp Blob";
        IStr: InStream;
        OStr: OutStream;
        toFileName: text;
        DefaultTextEncoding: TextEncoding;
    begin
        DefaultTextEncoding := TextEncoding::UTF8;
        DataFile.SetRange(BufferTableType, DataFile.BufferTableType::"Seperate Buffer Table per CSV");
        if DataFile.FindSet() then begin
            DataCompression.CreateZipArchive();
            repeat
                //Table
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALTable(DataFile).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALBufferTableName(DataFile));
                //XMLPort
                Clear(FileBlob);
                FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
                OStr.WriteText(ObjGen.CreateALXMLPort(DataFile).ToText());
                FileBlob.CreateInStream(IStr, DefaultTextEncoding);
                DataCompression.AddEntry(IStr, GetALXMLPortName(DataFile));
            until DataFile.Next() = 0;
        end;
        Clear(FileBlob);
        FileBlob.CreateOutStream(OStr, DefaultTextEncoding);
        DataCompression.SaveZipArchive(OStr);
        FileBlob.CreateInStream(IStr, DefaultTextEncoding);
        toFileName := 'BufferTablesAndXMLPorts.zip';
        DownloadFromStream(iStr, 'Download', 'ToFolder', format(Enum::DMTFileFilter::ZIP), toFileName);
    end;

    internal procedure RenumberALObjects()
    var
        DataFile: Record DMTDataFile;
        DMTSetup: Record DMTSetup;
        ObjectMgt: Codeunit DMTObjMgt;
        SessionStorage: Codeunit DMTSessionStorage;
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


        DataFile.ModifyAll("Buffer Table ID", 0);
        DataFile.ModifyAll("Import XMLPort ID", 0);

        DataFile.SetRange(BufferTableType, DataFile.BufferTableType::"Seperate Buffer Table per CSV");
        if DataFile.FindSet() then
            repeat
                if AvailableTables.Count > 0 then begin
                    DataFile."Buffer Table ID" := AvailableTables.Get(1);
                    AvailableTables.Remove(DataFile."Buffer Table ID");
                end;
                if AvailableXMLPorts.Count > 0 then begin
                    DataFile."Import XMLPort ID" := AvailableXMLPorts.Get(1);
                    AvailableXMLPorts.Remove(DataFile."Import XMLPort ID");
                end;
                DataFile.Modify();
            until DataFile.Next() = 0;
    end;

    internal procedure RenewObjectIdAssignments()
    var
        DataFile: Record DMTDataFile;
    begin
        DataFile.SetRange(BufferTableType, DataFile.BufferTableType::"Seperate Buffer Table per CSV");
        if DataFile.FindSet() then
            repeat
                TryFindBufferTableID(DataFile, true);
                TryFindXMLPortID(DataFile, true);
            until DataFile.Next() = 0;
    end;

    procedure ProposeMatchingFieldsForSelection(var DataFile_SELECTED: Record DMTDataFile temporary)
    begin
        if not DataFile_SELECTED.FindSet() then exit;
        repeat
            ProposeMatchingFields(DataFile_SELECTED.ID);
        until DataFile_SELECTED.Next() = 0;
    end;

    internal procedure AddDataFiles()
    var
        DataFileBuffer_Selected: Record DMTDataFileBuffer temporary;
        DMTSelectDataFile: page DMTSelectDataFile;
    begin
        DMTSelectDataFile.LookupMode(true);
        if DMTSelectDataFile.RunModal() <> Action::LookupOK then
            exit;
        if not DMTSelectDataFile.GetSelection(DataFileBuffer_Selected) then
            exit;
        DataFileBuffer_Selected.SetRange("File is already assigned", false);
        DataFileBuffer_Selected.SetFilter("Target Table ID", '<>0');
        if not DataFileBuffer_Selected.FindSet() then begin
            Message('Keine neuen Dateien mit Zieltabellennr. gefunden.');
            exit;
        end;
        repeat
            AddNewDataFile(DataFileBuffer_Selected);
        until DataFileBuffer_Selected.Next() = 0;
    end;

    procedure AddNewDataFile(DataFileBuffer: Record DMTDataFileBuffer)
    var
        DataFile: Record DMTDataFile;
        File: Record File;
        TableMeta: Record "Table Metadata";
        ObjMgt: Codeunit DMTObjMgt;
    begin
        // Exists already
        if DataFile.GetRecByFilePath(DataFileBuffer.Path, DataFileBuffer.Name) then
            exit;

        DataFile.Path := DataFileBuffer.Path;
        DataFile.Name := DataFileBuffer.Name;
        DataFile.Size := DataFileBuffer.Size;
        DataFile."Created At" := DataFileBuffer.DateTime;
        DataFile."Target Table ID" := DataFileBuffer."Target Table ID";
        DataFile."NAV Src.Table No." := DataFileBuffer."NAV Src.Table No.";
        // Target Infos
        TableMeta.Get(DataFileBuffer."Target Table ID");
        DataFileBuffer."Target Table Caption" := TableMeta.Caption;
        // Find NAV Source Infos
        if DataFile."NAV Src.Table No." = 0 then
            DataFile."NAV Src.Table No." := DataFile."Target Table ID";
        ObjMgt.SetNAVTableCaptionAndTableName(DataFile."NAV Src.Table No.", DataFile."NAV Src.Table Caption", DataFile."NAV Src.Table Name");
        DataFile.Insert(true);

        if DataFile.FindFileRec(File) then
            // lager than 100KB -> CSV
            if ((File.Size / 1024) < 100) then
                DataFile.Validate(BufferTableType, DataFile.BufferTableType::"Generic Buffer Table for all Files")
            else
                DataFile.Validate(BufferTableType, DataFile.BufferTableType::"Seperate Buffer Table per CSV");
        ProposeObjectIDs(DataFile, false);
        DataFile.Modify();
        // Fields
        InitFieldMapping(DataFile.ID);
    end;

    internal procedure AssignFilesToNewDefaultFolder(var TempDataFile_SELECTED: Record DMTDataFile temporary)
    var
        DMTSetup: Record DMTSetup;
        DataFile: Record DMTDataFile;
        FileRec: Record File;
        FileMgt: Codeunit "File Management";
    begin
        DMTSetup.Get();
        TempDataFile_SELECTED.SetCurrentKey("Sort Order");
        if not TempDataFile_SELECTED.FindSet() then exit;
        repeat
            DataFile := TempDataFile_SELECTED;
            if DataFile.Path <> DMTSetup."Default Export Folder Path" then
                if FileMgt.ServerFileExists(FileMgt.CombinePath(DMTSetup."Default Export Folder Path", DataFile.Name)) then begin
                    DataFile.Path := CopyStr(DMTSetup."Default Export Folder Path", 1, MaxStrLen(DataFile.Path));
                    if DataFile.FindFileRec(FileRec) then begin
                        DataFile.Size := FileRec.Size;
                        DataFile.Path := FileRec.Path;
                        DataFile.Name := FileRec.Name;
                        DataFile."Created At" := CreateDateTime(FileRec.Date, FileRec.Time);
                        DataFile.ClearProcessingInfo(false);
                    end;
                    DataFile.Modify();
                end;

        until TempDataFile_SELECTED.Next() = 0;
    end;

    internal procedure ClearProcessingInfo(var TempDataFile_SELECTED: Record DMTDataFile temporary)
    var
        DataFile: Record DMTDataFile;
    begin
        if not TempDataFile_SELECTED.FindSet() then exit;
        repeat
            DataFile := TempDataFile_SELECTED;
            DataFile.ClearProcessingInfo(false);
            DataFile.Modify();
        until TempDataFile_SELECTED.Next() = 0;
    end;

}