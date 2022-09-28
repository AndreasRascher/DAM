codeunit 110012 DMTProcessRecordOnly
{
    trigger OnRun()
    begin
        Start()
    end;

    procedure Start()
    begin
        If ProcessedFields.Count < TargetKeyFieldIDs.Count then
            ProcessKeyFields();
        if not SkipRecord then
            ProcessNonKeyFields();
    end;

    local procedure AssignField(ValidateSetting: Enum "DMTFieldValidationType")
    var
        SourcceField: FieldRef;
        TargetField: FieldRef;
    begin
        SourcceField := SourceRef.Field(TempFieldMapping."Source Field No.");
        TargetField := TmpTargetRef.Field(TempFieldMapping."Target Field No.");
        case ValidateSetting of
            ValidateSetting::AssignWithoutValidate:
                begin
                    TargetField.Value := SourcceField.Value;
                end;
            ValidateSetting::ValidateOnlyIfNotEmpty:
                begin
                    if Format(SourcceField.Value) <> Format(TargetRef_INIT.Field(TargetField.Number).Value) then
                        TargetField.Validate(SourcceField.Value);
                end;
            ValidateSetting::AlwaysValidate:
                begin
                    TargetField.Validate(SourcceField.Value);
                end;
        end;
    end;

    local procedure LoadFieldSetup(DataFile: Record DMTDataFile; var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
    begin
        OK := false;
        if TempFieldMapping.FindFirst() then exit(true);
        if not DataFile.FilterRelated(FieldMapping) then
            exit(false);
        FieldMapping.CopyToTemp(TempFieldMapping);
    end;

    local procedure ProcessNonKeyFields()
    begin
        TempFieldMapping.SetRange("Is Key Field(Target)", false);
        TempFieldMapping.SetCurrentKey("Validation Order");
        TempFieldMapping.FindSet();
        repeat
            if not ProcessedFields.Contains(TempFieldMapping.RecordID) then begin
                CurrFieldToProcess := TempFieldMapping.RecordID;
                AssignField(TempFieldMapping."Validation Type");
                ProcessedFields.Add(TempFieldMapping.RecordId);
            end;
        until TempFieldMapping.Next() = 0;
    end;

    local procedure ProcessKeyFields()
    var
        ExistingRef: RecordRef;
    begin
        TempFieldMapping.SetRange("Is Key Field(Target)", true);
        TempFieldMapping.SetFilter("Processing Action", '<>%1', TempFieldMapping."Processing Action"::Ignore);
        TempFieldMapping.SetCurrentKey("Validation Order");
        TempFieldMapping.FindSet();
        repeat
            if not ProcessedFields.Contains(TempFieldMapping.RecordID) then begin
                CurrFieldToProcess := TempFieldMapping.RecordID;
                AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate);
                ProcessedFields.Add(TempFieldMapping.RecordId);
            end;
        until TempFieldMapping.Next() = 0;
        SkipRecord := false;
        case true of
            UpdateExistingRecordsOnly:
                begin
                    if ExistingRef.Get(TmpTargetRef.RecordId) then
                        DMTMgt.CopyRecordRef(ExistingRef, TmpTargetRef)
                    else
                        SkipRecord := true; // only update, do not insert record when updating records
                end;
            DataFile."Import Only New Records" and not UpdateExistingRecordsOnly:
                begin
                    if ExistingRef.Get(TmpTargetRef.RecordId) then
                        SkipRecord := true;
                end;
            DataFile."Import Only New Records":
                begin
                    if ExistingRef.Get(TmpTargetRef.RecordId) then
                        SkipRecord := true;
                end;
        end;
    end;

    procedure Initialize(_DataFile: Record DMTDataFile; var _TempFieldMapping: Record DMTFieldMapping temporary; _SourceRef: RecordRef; _UpdateExistingRecordsOnly: Boolean)
    begin
        DataFile := _DataFile;
        SourceRef := _SourceRef;
        UpdateExistingRecordsOnly := _UpdateExistingRecordsOnly;
        _TempFieldMapping.Copy(_TempFieldMapping, true);
        TmpTargetRef.Open(DataFile."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
    end;

    procedure LogLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        ErrorLogDict.Add(CurrFieldToProcess, ErrorItem);
        ProcessedFields.Add(CurrFieldToProcess);
        ClearLastError();
    end;

    internal procedure SaveRecord()
    begin
        if SkipRecord then
            exit;
        if ErrorLogDict.Count = 0 then begin
            DMTMgt.InsertRecFromTmp(TmpTargetRef, DataFile."Use OnInsert Trigger");
        end else begin
            SaveErrorLog();
        end;
    end;

    local procedure SaveErrorLog()
    var
        FieldMappingID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
    begin
        foreach FieldMappingID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(FieldMappingID);
            TempFieldMapping.Get(FieldMappingID);
            AddEntryForLastError(SourceRef, TmpTargetRef, TempFieldMapping, ErrorItem);
        end;
    end;

    procedure AddEntryForLastError(SourceRef: recordref; TargetRef: RecordRef; FieldMapping: Record "DMTFieldMapping"; ErrorItem: Dictionary of [Text, Text]);
    var
        _DMTErrorlog: Record DMTErrorLog;
    begin
        _DMTErrorlog.DataFileName := DataFile.Name;
        _DMTErrorlog.DataFileFolderPath := DataFile.Path;

        _DMTErrorlog."From ID" := SourceRef.RecordId;
        _DMTErrorlog."To ID" := TargetRef.RecordId;
        _DMTErrorlog."From ID (Text)" := CopyStr(Format(_DMTErrorlog."From ID"), 1, MaxStrLen(_DMTErrorlog."From ID (Text)"));
        _DMTErrorlog."To ID (Text)" := CopyStr(Format(_DMTErrorlog."to ID"), 1, MaxStrLen(_DMTErrorlog."To ID (Text)"));

        _DMTErrorlog."Import from Table No." := SourceRef.Number;
        _DMTErrorlog."Import from Field No." := FieldMapping."Source Field No.";
        _DMTErrorlog."Import to Table No." := FieldMapping."Target Table ID";
        _DMTErrorlog."Import to Field No." := FieldMapping."Target Field No.";
        _DMTErrorlog."Ignore Error" := FieldMapping."Ignore Validation Error";
        _DMTErrorlog.Errortext := CopyStr(ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(ErrorItem.Get('GetLastErrorCode'), 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."DMT User" := CopyStr(UserId, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CurrentDateTime;
        _DMTErrorlog.Insert();
    end;

    var
        DataFile: Record DMTDataFile;
        TempFieldMapping: Record DMTFieldMapping temporary;
        DMTMgt: Codeunit DMTMgt;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        SkipRecord: Boolean;
        // DMTTable: Record DMTTable;
        // TempDMTField: Record DMTField temporary;

        UpdateExistingRecordsOnly: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];
}