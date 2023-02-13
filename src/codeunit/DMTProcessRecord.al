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
            if (not SkipRecord) or UpdateFieldsInExistingRecordsOnly then
                ProcessNonKeyFields();
        end;

        if RunMode = RunMode::InsertRecord then begin
            SaveRecord();
        end;

        if RunMode = RunMode::ModifyRecord then begin
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
        // DMTMgt.ApplyReplacements(TempFieldMapping, FieldWithTypeCorrectValueToValidate);
        if ReplacementsMgt.HasReplacementForTargetField(TargetField.Number) then begin
            FieldWithTypeCorrectValueToValidate := ReplacementsMgt.GetReplacmentValueFor(TargetField.Number);
            // if not DMTMgt.EvaluateFieldRef(FieldWithTypeCorrectValueToValidate, NewValue, false, false) then
            // Error('ApplyReplacements EvaluateFieldRef Error "%1"', NewValue);
        end;
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
        TargetRecordExists := ExistingRef.Get(TmpTargetRef.RecordId);
        case true of
            // Nur vorhandene Datensätze updaten. Felder aus exist. Datensatz kopieren.
            UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        DMTMgt.CopyRecordRef(ExistingRef, TmpTargetRef)
                    else
                        SkipRecord := true; // only update, do not insert record when updating records
                end;
            // Kein Insert neuer Datensätze
            DataFile."Import Only New Records" and not UpdateFieldsInExistingRecordsOnly:
                begin
                    if TargetRecordExists then
                        SkipRecord := true;
                end;
            DataFile."Import Only New Records":
                begin
                    if TargetRecordExists then
                        SkipRecord := true;
                end;
        end;
    end;

    procedure InitFieldTransfer(_SourceRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings)
    begin
        DataFile := DMTImportSettings.DataFile();
        SourceRef := _SourceRef;
        UpdateFieldsInExistingRecordsOnly := DMTImportSettings.UpdateExistingRecordsOnly();
        DMTImportSettings.GetFieldMapping(TempFieldMapping);
        TmpTargetRef.Open(DataFile."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        RunMode := RunMode::FieldTransfer;
        Clear(ErrorLogDict);
        ReplacementsMgt.InitFor(DataFile, _SourceRef, DataFile."Target Table ID");
    end;

    procedure InitInsert()
    begin
        RunMode := RunMode::InsertRecord;
    end;

    procedure InitModify()
    begin
        RunMode := RunMode::ModifyRecord;
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
        // Check if this error should block the insert oder modify
        if RunMode = RunMode::FieldTransfer then
            if not HasNotIgnoredErrors then begin
                TempFieldMapping.Get(CurrFieldToProcess);
                if not TempFieldMapping."Ignore Validation Error" then
                    HasNotIgnoredErrors := true;
            end;

        ClearLastError();
    end;

    local procedure SaveRecord() Success: Boolean
    begin
        Success := true;
        if ErrorLogDict.Count > 0 then
            exit(false);
        ClearLastError();
        case RunMode of
            RunMode::InsertRecord:
                begin
                    if SkipRecord then
                        exit(false);
                    Success := ChangeRecordWithPerm.InsertOrOverwriteRecFromTmp(TmpTargetRef, DataFile."Use OnInsert Trigger");
                end;
            RunMode::ModifyRecord:
                begin
                    if SkipRecord then
                        exit(false);
                    Success := ChangeRecordWithPerm.ModifyRecFromTmp(TmpTargetRef, DataFile."Use OnInsert Trigger");
                end;
        end;
    end;

    procedure SaveErrorLog(Log: Codeunit DMTLog) ErrorsExist: Boolean
    var
        FieldMappingID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
    begin
        foreach FieldMappingID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(FieldMappingID);
            TempFieldMapping.Get(FieldMappingID);
            ErrorsExist := ErrorsExist or not TempFieldMapping."Ignore Validation Error";
            Log.AddErrorByFieldMappingEntry(SourceRef.RecordId, DataFile, TempFieldMapping, ErrorItem);
        end;
    end;

    procedure GetProcessingResultType() ResultType: Enum DMTProcessingResultType
    begin
        // Ausstiegsgrund						Datensatz		Zieldatensatz 
        // 								        verarbeiten     nicht vorhanden
        // - Neue neue DS / DS existiert bereits	x
        // - Fehler beim Werte übertragen			x			x
        // - Feldupdate 										x

        // Zeilen verarbeiten
        // - DS Verarbeitet,
        //   - = DS Importiert + DS Ignoriert + DS mit Fehler
        // Felder verarbeiten
        // - DS Verarbeitet
        //   - = DS aktualisiert + DS Ignoriert + DS mit Fehler
        case true of
            (RunMode in [RunMode::FieldTransfer, RunMode::ModifyRecord, RunMode::InsertRecord]) and HasNotIgnoredErrors:
                exit(ResultType::Error);
            (RunMode in [RunMode::ModifyRecord, RunMode::InsertRecord]) and SkipRecord:
                exit(ResultType::Ignored);
            (RunMode in [RunMode::FieldTransfer, RunMode::ModifyRecord, RunMode::InsertRecord]) and
            not HasNotIgnoredErrors and not SkipRecord:
                exit(ResultType::ChangesApplied);
            else
                Error('unhandled case');
        end;
    end;


    var
        DataFile: Record DMTDataFile;
        TempFieldMapping: Record DMTFieldMapping temporary;
        ChangeRecordWithPerm: Codeunit ChangeRecordWithPerm;
        DMTMgt: Codeunit DMTMgt;
        ReplacementsMgt: Codeunit DMTReplacementsMgt;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        CurrValueToAssign: FieldRef;
        CurrValueToAssign_IsInitialized: Boolean;
        SkipRecord, TargetRecordExists, HasNotIgnoredErrors : Boolean;
        UpdateFieldsInExistingRecordsOnly: Boolean;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];
        RunMode: Option FieldTransfer,InsertRecord,ModifyRecord;

}