codeunit 110008 "DMTErrorWrapper"
{
    trigger OnRun()
    begin
        ClearLastError();
        CASE OnRunAction OF
            OnRunAction::FieldValidate:
                FieldValidateRecRef(SourceRef, TargetRef, FieldMapping);
            OnRunAction::FieldValidateWithValue:
                FieldValidateWithValue(NewValue, TargetRef, TargetFieldNo);
        end;
    end;

    procedure SetFieldValidateRecRef(_SourceRef: RecordRef; _TargetRef: RecordRef; _FieldMapping: Record DMTFieldMapping)
    begin
        OnRunAction := OnRunAction::FieldValidate;
        SourceRef := _SourceRef.duplicate();
        TargetRef := _TargetRef.duplicate();
        FieldMapping := _FieldMapping;
    end;

    procedure SetFieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _TargetFieldNo: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidateWithValue;
        NewValue := _NewValue;
        TargetRef := _RecRef_TO.duplicate();
        TargetFieldNo := _TargetFieldNo;
    end;

    procedure GetTargetRef(VAR _TargetRef: RecordRef)
    begin
        _TargetRef := TargetRef;
    end;

    local procedure FieldValidateRecRef(_SourceRef: RecordRef; var _TargetRef: RecordRef; _FieldMapping: Record DMTFieldMapping)
    var
        DMTMgt: Codeunit DMTMgt;
    begin
        DMTMgt.ValidateFieldImplementation(_SourceRef, _FieldMapping, _TargetRef);
    end;

    LOCAL procedure FieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        ToField: FieldRef;
    begin
        ToField := _RecRef_TO.FIELD(_FieldNo_TO);
        ToField.VALIDATE(_NewValue);
    end;


    var
        FieldMapping: Record DMTFieldMapping;
        SourceRef: RecordRef;
        TargetRef: RecordRef;
        TargetFieldNo: Integer;
        OnRunAction: Option FieldValidate,FieldValidateWithValue;
        NewValue: Variant;
}