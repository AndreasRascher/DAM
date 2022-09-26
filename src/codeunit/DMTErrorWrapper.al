codeunit 110008 "DMTErrorWrapper"
{
    trigger OnRun()
    begin
        ClearLastError();
        CASE OnRunAction OF
            OnRunAction::FieldValidate:
                FieldValidateRecRef(SourceRef, FieldNo_FROM, TargetRef, TargetFieldNo);
            OnRunAction::FieldValidateWithValue:
                FieldValidateWithValue(NewValue, TargetRef, TargetFieldNo);
            OnRunAction::MigrateFields:
                MigrateFields(SourceRef, TargetRef, TempDMTField);
        end;
    end;

    procedure SetFieldValidateRecRef(_RecRef_FROM: RecordRef; _FieldNo_FROM: Integer; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidate;
        SourceRef := _RecRef_FROM.duplicate();
        TargetRef := _RecRef_TO.duplicate();
        FieldNo_FROM := _FieldNo_FROM;
        TargetFieldNo := _FieldNo_TO;
    end;

    procedure SetFieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _TargetFieldNo: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidateWithValue;
        NewValue := _NewValue;
        TargetRef := _RecRef_TO.duplicate();
        TargetFieldNo := _TargetFieldNo;
    end;

    procedure GetSourceRef(VAR _SourceRef: RecordRef)
    begin
        _SourceRef := SourceRef;
    end;

    procedure GetTargetRef(VAR _TargetRef: RecordRef)
    begin
        _TargetRef := TargetRef;
    end;

    procedure GetLastFieldProcessed(VAR _LastFieldProcessed: RecordId)
    begin
        _LastFieldProcessed := LastFieldProcessed;
    end;

    LOCAL procedure FieldValidateRecRef(_RecRef_FROM: RecordRef; _FieldNo_FROM: Integer; var _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        DMTMgt: Codeunit DMTMgt;
        ToField: FieldRef;
        FromField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        FromField := _RecRef_FROM.Field(_FieldNo_FROM);
        ToField := _RecRef_TO.Field(_FieldNo_TO);
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = _RecRef_FROM.Number);
        if ToField.Type = FromField.Type then
            ToField.Validate(FromField.Value)
        else
            if not DMTMgt.EvaluateFieldRef(ToField, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                Error('Evaluating "%1" into "%2" failed', FromField.Value, ToField.Caption);
    end;

    LOCAL procedure FieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        ToField: FieldRef;
    begin
        ToField := _RecRef_TO.Field(_FieldNo_TO);
        ToField.VALIDATE(_NewValue);
    end;

    local procedure MigrateFields(TargetRef: RecordRef; SourceRef: RecordRef; var TempDMTField: Record DMTField temporary)
    var
        DMTMgt: Codeunit DMTMgt;
        TargetFieldRef: FieldRef;
    begin
        if not TempDMTField.FindSet() then
            exit;
        repeat
            CurrFieldToProcess := TempDMTField.RecordId;
            case TempDMTField."Processing Action" of
                TempDMTField."Processing Action"::Ignore:
                    ;
                TempDMTField."Processing Action"::FixedValue:
                    begin
                        TargetFieldRef := SourceRef.Field(TempDMTField."Target Field No.");
                        DMTMgt.AssignFixedValueToFieldRef(TargetFieldRef, TempDMTField."Fixed Value");
                        if TempDMTField."Validate Value" then
                            DMTMgt.ValidateFieldWithValue(SourceRef, TempDMTField."Target Field No.", format(TargetFieldRef), TempDMTField."Ignore Validation Error")
                        else
                            SourceRef.Field(TempDMTField."Target Field No.").Validate(TargetFieldRef.Value);
                    end;
                TempDMTField."Processing Action"::Transfer:
                    if TempDMTField."Validate Value" then
                        DMTMgt.ValidateField(TargetRef, SourceRef, TempDMTField)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TargetRef,
                                                          TempDMTField."Source Field No.",
                                                          SourceRef,
                                                          TempDMTField."Target Field No.",
                                                          false);
            end;
            LastFieldProcessed := TempDMTField.RecordId;
        until TempDMTField.Next() = 0;
    end;


    var
        TempDMTField: Record DMTField temporary;
        CurrFieldToProcess, LastFieldProcessed : RecordID;
        SourceRef: RecordRef;
        TargetRef: RecordRef;
        FieldNo_FROM: Integer;
        TargetFieldNo: Integer;
        OnRunAction: Option FieldValidate,FieldValidateWithValue,MigrateFields;
        NewValue: Variant;
}