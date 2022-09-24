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
                    FieldMapping.setrange("Target Field No.", TargetRecRef.FieldIndex(i).Number);
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
                MigrationLib.SetKnownValidationRules(FieldMapping);
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
                    GenBuffTable.GetColCaptionForImportedFile(DataFile.RecordId, SourceFieldNames2);
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
        DMTObjectGenerator: Codeunit DMTObjectGenerator;
    begin
        DMTObjectGenerator.DownloadFile(DMTObjectGenerator.CreateALXMLPort(DataFile), GetALXMLPortName(DataFile));
    end;

    procedure DownloadALBufferTableFile(DataFile: Record DMTDataFile)
    var
        DMTObjectGenerator: Codeunit DMTObjectGenerator;
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

    procedure ImportToBufferTable(DataFile: Record DMTDataFile)
    var
        GenBuffImport: XmlPort DMTGenBuffImport;
        File: File;
        InStr: InStream;
        Progress: Dialog;
        ImportFileFromPathLbl: Label 'Importing %1';
    begin
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
                    Progress.Open(StrSubstNo(ImportFileFromPathLbl, ConvertStr(file.Name, '\', '/')));
                    GenBuffImport.Import();
                    Progress.Close();
                    UpdateQtyLinesInBufferTable(DataFile);
                end;
        end
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
        DMTImport: Codeunit DMTImport;
        DMTErrorLogQry: Query DMTErrorLogQry;
        RecIdList: list of [RecordID];
    begin
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
            DMTErrorLogQry.setrange(Import_from_Table_No_, DataFile."Buffer Table ID");
        if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
            DMTErrorLogQry.setrange(Import_from_Table_No_, Database::DMTGenBuffTable);
            DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileFolderPath, DataFile.Path);
            DMTErrorLogQry.SetRange(DMTErrorLogQry.DataFileName, DataFile.Name);
        end;
        DMTErrorLogQry.Open();
        while DMTErrorLogQry.Read() do begin
            RecIdList.Add(DMTErrorLogQry.FromID);
        end;
        DMTImport.RetryProcessFullBuffer(RecIdList, DataFile, false);
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
        DMTSetup: Record "DMTSetup";
        DataFile: Record DMTDataFile;
        ObjectMgt: Codeunit DMTObjMgt;
        AvailableTables: List of [Integer];
        AvailableXMLPorts: List of [Integer];
        NoAvailableObjectIDsErr: Label 'No free object IDs of type %1 could be found. Defined ID range in setup: %2',
                                comment = 'Es konnten keine freien Objekt-IDs vom Typ %1 gefunden werden. Definierter ID Bereich in der Einrichtung: %2';
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
}