codeunit 110012 DMTProcessRecord
{
    trigger OnRun()
    begin
        Start()
    end;

    procedure Start()
    begin
        if RunMode = RunMode::FieldTransfer then begin
            if ProcessedFields.Count < TargetKeyFieldIDs.Count then
                ProcessKeyFields();
            if not SkipRecord then
                ProcessNonKeyFields();
        end;

        if RunMode = RunMode::InsertRecord then begin
            SaveRecord();
        end;
    end;

    local procedure AssignField(ValidateSetting: Enum DMTFieldValidationType)
    var
        FieldWithTypeCorrectValueToValidate, TargetField : FieldRef;
        SourceField: FieldRef;
    begin
        SourceField := SourceRef.Field(TempFieldMapping."Source Field No.");
        TargetField := TmpTargetRef.Field(TempFieldMapping."Target Field No.");
        DMTMgt.AssignValueToFieldRef(SourceRef, TempFieldMapping, TmpTargetRef, FieldWithTypeCorrectValueToValidate);
        DMTMgt.ApplyReplacements(TempFieldMapping, FieldWithTypeCorrectValueToValidate);
        CurrValueToAssign := FieldWithTypeCorrectValueToValidate;
        CurrValueToAssign_IsInitialized := true;
        case ValidateSetting of
            ValidateSetting::AssignWithoutValidate:
                begin
                    TargetField.Value := FieldWithTypeCorrectValueToValidate.Value;
                end;
            ValidateSetting::ValidateOnlyIfNotEmpty:
                begin
                    if Format(SourceField.Value) <> Format(TargetRef_INIT.Field(TargetField.Number).Value) then
                        TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                end;
            ValidateSetting::AlwaysValidate:
                begin
                    TargetField.Validate(FieldWithTypeCorrectValueToValidate.Value);
                end;
        end;
    end;

    local procedure ProcessNonKeyFields()
    begin
        TempFieldMapping.SetRange("Is Key Field(Target)", false);
        TempFieldMapping.SetCurrentKey("Validation Order");
        if TempFieldMapping.FindSet() then // if only Key Fields are mapped this is false
            repeat
                if not ProcessedFields.Contains(TempFieldMapping.RecordId) then begin
                    CurrFieldToProcess := TempFieldMapping.RecordId;
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
        if not TempFieldMapping.FindSet() then
            Error('Fieldmapping for Key Fields is invalid');
        repeat
            if not ProcessedFields.Contains(TempFieldMapping.RecordId) then begin
                CurrFieldToProcess := TempFieldMapping.RecordId;
                AssignField(Enum::DMTFieldValidationType::AssignWithoutValidate);
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

    procedure InitFieldTransfer(_DataFile: Record DMTDataFile; var _TempFieldMapping: Record DMTFieldMapping temporary; _SourceRef: RecordRef; _UpdateExistingRecordsOnly: Boolean)
    begin
        DataFile := _DataFile;
        SourceRef := _SourceRef;
        UpdateExistingRecordsOnly := _UpdateExistingRecordsOnly;
        TempFieldMapping.Copy(_TempFieldMapping, true);
        TmpTargetRef.Open(DataFile."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        RunMode := RunMode::FieldTransfer;
        Clear(ErrorLogDict);
    end;

    procedure InitFieldTransfer(_SourceRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings)
    begin
        DataFile := DMTImportSettings.DataFile();
        SourceRef := _SourceRef;
        UpdateExistingRecordsOnly := DMTImportSettings.UpdateExistingRecordsOnly();
        DMTImportSettings.GetFieldMapping(TempFieldMapping);
        TmpTargetRef.Open(DataFile."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        RunMode := RunMode::FieldTransfer;
        Clear(ErrorLogDict);
    end;

    procedure InitInsert()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    procedure LogLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        if GetLastErrorText() = '' then
            exit;
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        if CurrValueToAssign_IsInitialized then
            ErrorItem.Add('ErrorValue', Format(CurrValueToAssign.Value))
        else
            ErrorItem.Add('ErrorValue', '');
        ErrorLogDict.Add(CurrFieldToProcess, ErrorItem);
        ProcessedFields.Add(CurrFieldToProcess);
        ClearLastError();
    end;

    local procedure SaveRecord() Success: Boolean
    begin
        Success := true;
        if SkipRecord then
            exit(false);
        if ErrorLogDict.Count > 0 then
            exit(false);
        ClearLastError();
        Success := ChangeRecordWithPerm.InsertRecFromTmp(TmpTargetRef, DataFile."Use OnInsert Trigger");
    end;

    procedure SaveErrorLog() ErrorsExist: Boolean
    var
        FieldMappingID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
    begin
        foreach FieldMappingID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(FieldMappingID);
            TempFieldMapping.Get(FieldMappingID);
            ErrorsExist := ErrorsExist or not TempFieldMapping."Ignore Validation Error";
            AddEntryForLastError(SourceRef, TmpTargetRef, TempFieldMapping, ErrorItem);
        end;
    end;

    procedure AddEntryForLastError(_SourceRef: RecordRef; _TargetRef: RecordRef; _FieldMapping: Record DMTFieldMapping; _ErrorItem: Dictionary of [Text, Text]);
    var
        _DMTErrorlog: Record DMTErrorLog;
    begin
        _DMTErrorlog.DataFileName := DataFile.Name;
        _DMTErrorlog.DataFilePath := DataFile.Path;

        _DMTErrorlog."From ID" := _SourceRef.RecordId;
        _DMTErrorlog."To ID" := _TargetRef.RecordId;
        _DMTErrorlog."From ID (Text)" := CopyStr(Format(_DMTErrorlog."From ID"), 1, MaxStrLen(_DMTErrorlog."From ID (Text)"));
        _DMTErrorlog."To ID (Text)" := CopyStr(Format(_DMTErrorlog."To ID"), 1, MaxStrLen(_DMTErrorlog."To ID (Text)"));

        _DMTErrorlog."Import from Table No." := _SourceRef.Number;
        _DMTErrorlog."Import from Field No." := _FieldMapping."Source Field No.";
        _DMTErrorlog."Import to Table No." := _FieldMapping."Target Table ID";
        _DMTErrorlog."Import to Field No." := _FieldMapping."Target Field No.";
        _DMTErrorlog."Ignore Error" := _FieldMapping."Ignore Validation Error";
        _DMTErrorlog.Errortext := CopyStr(_ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(_ErrorItem.Get('GetLastErrorCode'), 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."Error Field Value" := CopyStr(_ErrorItem.Get('ErrorValue'), 1, MaxStrLen(_DMTErrorlog."Error Field Value"));
        _DMTErrorlog.SaveErrorCallStack(_ErrorItem.Get('GetLastErrorCallStack'), false);
        _DMTErrorlog."DMT User" := CopyStr(UserId, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CurrentDateTime;
        _DMTErrorlog.Insert();
    end;

    var
        DataFile: Record DMTDataFile;
        TempFieldMapping: Record DMTFieldMapping temporary;
        ChangeRecordWithPerm: Codeunit ChangeRecordWithPerm;
        DMTMgt: Codeunit DMTMgt;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        CurrValueToAssign: FieldRef;
        CurrValueToAssign_IsInitialized: Boolean;
        SkipRecord: Boolean;
        // DMTTable: Record DMTTable;
        // TempDMTField: Record DMTField temporary;
        UpdateExistingRecordsOnly: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];
        RunMode: Option FieldTransfer,InsertRecord;
}