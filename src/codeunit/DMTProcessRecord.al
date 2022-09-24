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
        SourcceField := SourceRef.Field(TempDMTField."Source Field No.");
        TargetField := TmpTargetRef.Field(TempDMTField."Target Field No.");
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

    local procedure ProcessNonKeyFields()
    begin
        TempDMTField.SetRange("Is Key Field(Target)", false);
        TempDMTField.SetCurrentKey("Validation Order");
        TempDMTField.FindSet();
        repeat
            if not ProcessedFields.Contains(TempDMTField.RecordID) then begin
                CurrFieldToProcess := TempDMTField.RecordID;
                if TempDMTField."Validate Value" then
                    AssignField(Enum::"DMTFieldValidationType"::ValidateOnlyIfNotEmpty, TempDMTField."Use Try Function")
                else
                    AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate, TempDMTField."Use Try Function");
                ProcessedFields.Add(TempDMTField.RecordId);
            end;
        until TempDMTField.Next() = 0;
    end;

    local procedure ProcessKeyFields()
    begin
        TempDMTField.SetRange("Is Key Field(Target)", true);
        TempDMTField.SetFilter("Processing Action", '<>%1', TempDMTField."Processing Action"::Ignore);
        TempDMTField.SetCurrentKey("Validation Order");
        TempDMTField.FindSet();
        repeat
            if not ProcessedFields.Contains(TempDMTField.RecordID) then begin
                CurrFieldToProcess := TempDMTField.RecordID;
                AssignField(Enum::"DMTFieldValidationType"::AssignWithoutValidate, TempDMTField."Use Try Function");
                ProcessedFields.Add(TempDMTField.RecordId);
            end;
        until TempDMTField.Next() = 0;
    end;

    procedure Initialize(_DMTTable: Record DMTTable; _SourceRef: RecordRef)
    var
        DMTMgt: Codeunit DMTMgt;
    begin
        DMTTable := _DMTTable;
        SourceRef := _SourceRef;
        TmpTargetRef.Open(DMTTable."Target Table ID", true, CompanyName);
        TargetKeyFieldIDs := DMTMgt.GetListOfKeyFieldIDs(TmpTargetRef);
        TargetRef_INIT.Open(TmpTargetRef.Number, false, TmpTargetRef.CurrentCompany);
        TargetRef_INIT.Init();
        LoadFieldSetup(DMTTable, TempDMTField);
    end;

    procedure LogLastError()
    ErrorInfo: Dictionary of [Text, Text];
    begin
        ErrorInfo.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorInfo.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorInfo.Add('GetLastErrorText', GetLastErrorText);
        LastErrorLog.Add(CurrFieldToProcess, ErrorInfo);
        ProcessedFields.Add(CurrFieldToProcess);
        ClearLastError();
    end;

    internal procedure SaveRecord()
    var
        DMTErrorLog: Record DMTErrorLog;
    begin
        if LastErrorLog.Count = 0 then begin
            DMTMgt.InsertRecFromTmp(TmpTargetRef, DMTTable."Use OnInsert Trigger");
        end else begin
            // DMTErrorLog.AddEntryForLastError();
        end;
    end;

    var
        TempDMTField: Record DMTField temporary;
        DMTTable: Record DMTTable;
        DMTMgt: Codeunit DMTMgt;
        CurrFieldToProcess: RecordId;
        SourceRef, TargetRef_INIT, TmpTargetRef : RecordRef;
        LastErrorLog: Dictionary of [RecordId, Dictionary of [Text, Text]];
        TargetKeyFieldIDs: List of [Integer];
        ProcessedFields: List of [RecordId];

}