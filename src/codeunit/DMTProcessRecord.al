codeunit 110012 "DMTProcessRecord"
{
    trigger OnRun()
    begin
        Start()
    end;

    procedure Start()
    begin
        If ProcessedFields.Count < TargetKeyFieldIDs.Count then
            ProcessKeyFields();
        ProcessNonKeyFields();
    end;

    local procedure AssignField(ValidateSetting: Enum "DMTFieldValidationType"; UseTryFunction: Boolean)
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

    local procedure LoadFieldSetup(DMTTable: Record DMTTable; var TempDMTField: Record DMTField temporary) OK: Boolean
    var
        DMTField: Record DMTField;
    begin
        if TempDMTField.FindFirst() then exit(true);
        if not DMTField.FilterBy(DMTTable) then
            exit(false);
        DMTField.FindSet();
        repeat
            TempDMTField := DMTField;
            //TODO: Nachversorgung
            if TargetKeyFieldIDs.Contains(TempDMTField."Target Field No.") then
                TempDMTField."Is Key Field(Target)" := true;
            TempDMTField.Insert(false);
        until DMTField.Next() = 0;
    end;

    local procedure LoadFieldSetup(DataFile: Record DMTDataFile; var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
    begin
        if TempFieldMapping.FindFirst() then exit(true);
        if not DataFile.FilterRelated(FieldMapping) then
            exit(false);
        FieldMapping.CopyToTemp(TempFieldMapping);
    end;

    // local procedure ProcessNonKeyFields()
    // begin
    //     TempDMTField.SetRange("Is Key Field(Target)", false);
    //     TempDMTField.SetCurrentKey("Validation Order");
    //     TempDMTField.FindSet();
    //     repeat
    //         if not ProcessedFields.Contains(TempDMTField.RecordID) then begin
    //             CurrFieldToProcess := TempDMTField.RecordID;
    //             if TempDMTField."Validate Value" then
    //                 AssignField(Enum::"DMTFieldValidationType"::ValidateOnlyIfNotEmpty, TempDMTField."Use Try Function")
    //             else
    //                 AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate, TempDMTField."Use Try Function");
    //             ProcessedFields.Add(TempDMTField.RecordId);
    //         end;
    //     until TempDMTField.Next() = 0;
    // end;
    local procedure ProcessNonKeyFields()
    begin
        TempFieldMapping.SetRange("Is Key Field(Target)", false);
        TempFieldMapping.SetCurrentKey("Validation Order");
        TempFieldMapping.FindSet();
        repeat
            if not ProcessedFields.Contains(TempFieldMapping.RecordID) then begin
                CurrFieldToProcess := TempFieldMapping.RecordID;
                AssignField(TempFieldMapping."Validation Type", TempFieldMapping."Use Try Function");
                ProcessedFields.Add(TempFieldMapping.RecordId);
            end;
        until TempFieldMapping.Next() = 0;
    end;

    // local procedure ProcessKeyFields()
    // begin
    //     TempDMTField.SetRange("Is Key Field(Target)", true);
    //     TempDMTField.SetFilter("Processing Action", '<>%1', TempDMTField."Processing Action"::Ignore);
    //     TempDMTField.SetCurrentKey("Validation Order");
    //     TempDMTField.FindSet();
    //     repeat
    //         if not ProcessedFields.Contains(TempDMTField.RecordID) then begin
    //             CurrFieldToProcess := TempDMTField.RecordID;
    //             AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate, TempDMTField."Use Try Function");
    //             ProcessedFields.Add(TempDMTField.RecordId);
    //         end;
    //     until TempDMTField.Next() = 0;
    // end;
    local procedure ProcessKeyFields()
    begin
        TempFieldMapping.SetRange("Is Key Field(Target)", true);
        TempFieldMapping.SetFilter("Processing Action", '<>%1', TempFieldMapping."Processing Action"::Ignore);
        TempFieldMapping.SetCurrentKey("Validation Order");
        TempFieldMapping.FindSet();
        repeat
            if not ProcessedFields.Contains(TempFieldMapping.RecordID) then begin
                CurrFieldToProcess := TempFieldMapping.RecordID;
                AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate, TempFieldMapping."Use Try Function");
                ProcessedFields.Add(TempFieldMapping.RecordId);
            end;
        until TempFieldMapping.Next() = 0;
    end;

    // procedure Initialize(_DMTTable: Record DMTTable; _SourceRef: RecordRef)
    // begin
    //     DMTTable := _DMTTable;
    //     SourceRef := _SourceRef;
    //     TmpTargetRef.Open(DMTTable."Target Table ID", true, CompanyName);
    //     TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
    //     TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
    //     TargetRef_INIT.Init();
    //     LoadFieldSetup(DMTTable, TempDMTField);
    // end;

    procedure Initialize(_DataFile: Record DMTDataFile; _SourceRef: RecordRef)
    begin
        DataFile := _DataFile;
        SourceRef := _SourceRef;
        TmpTargetRef.Open(DataFile."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        LoadFieldSetup(DataFile, TempFieldMapping);
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

    // internal procedure SaveRecord()
    // var
    //     DMTErrorLog: Record DMTErrorLog;
    // begin
    //     if LastErrorLog.Count = 0 then begin
    //         DMTMgt.InsertRecFromTmp(TmpTargetRef, DMTTable."Use OnInsert Trigger");
    //     end else begin
    //         // DMTErrorLog.AddEntryForLastError();
    //     end;
    // end;
    internal procedure SaveRecord()
    begin
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
        // ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        // ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        // ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        _DMTErrorlog.Errortext := CopyStr(ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(ErrorItem.Get('GetLastErrorCode'), 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."DMT User" := CopyStr(USERID, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CURRENTDATETIME;
        _DMTErrorlog.Insert();
    end;

    var
        // DMTTable: Record DMTTable;
        // TempDMTField: Record DMTField temporary;
        DataFile: Record DMTDataFile;
        TempFieldMapping: Record DMTFieldMapping temporary;
        DMTMgt: Codeunit DMTMgt;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];

}