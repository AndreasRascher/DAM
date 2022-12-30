codeunit 110008 DMTErrorWrapper
{
    trigger OnRun()
    begin
        ClearLastError();
        case OnRunAction of
            OnRunAction::FieldValidate:
                FieldValidateRecRef(SourceRef, TargetRef, FieldMapping);
            OnRunAction::FieldValidateWithValue:
                FieldValidateWithValue(NewValue, TargetRef, TargetFieldNo);
        end;
    end;

    procedure SetFieldValidateRecRef(_SourceRef: RecordRef; _TargetRef: RecordRef; _FieldMapping: Record DMTFieldMapping)
    begin
        OnRunAction := OnRunAction::FieldValidate;
        SourceRef := _SourceRef.Duplicate();
        TargetRef := _TargetRef.Duplicate();
        FieldMapping := _FieldMapping;
    end;

    procedure SetFieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _TargetFieldNo: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidateWithValue;
        NewValue := _NewValue;
        TargetRef := _RecRef_TO.Duplicate();
        TargetFieldNo := _TargetFieldNo;
    end;

    procedure GetTargetRef(var _TargetRef: RecordRef)
    begin
        _TargetRef := TargetRef;
    end;

    local procedure FieldValidateRecRef(_SourceRef: RecordRef; var _TargetRef: RecordRef; _FieldMapping: Record DMTFieldMapping)
    var
        DMTMgt: Codeunit DMTMgt;
    begin
        DMTMgt.ValidateFieldImplementation(_SourceRef, _FieldMapping, _TargetRef);
    end;

    local procedure FieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        ToField: FieldRef;
    begin
        ToField := _RecRef_TO.Field(_FieldNo_TO);
        ToField.Validate(_NewValue);
    end;


    var
        FieldMapping: Record DMTFieldMapping;
        SourceRef: RecordRef;
        TargetRef: RecordRef;
        TargetFieldNo: Integer;
        OnRunAction: Option FieldValidate,FieldValidateWithValue;
        NewValue: Variant;
}