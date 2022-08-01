codeunit 50001 "DMTErrorWrapper"
{
    trigger OnRun()
    begin
        ClearLastError();
        CASE OnRunAction OF
            OnRunAction::FieldValidate:
                FieldValidateRecRef(RecRef_FROM, FieldNo_FROM, RecRef_TO, FieldNo_TO);
            OnRunAction::FieldValidateWithValue:
                FieldValidateWithValue(NewValue, RecRef_TO, FieldNo_TO);
        end;
    end;

    procedure SetFieldValidateRecRef(_RecRef_FROM: RecordRef; _FieldNo_FROM: Integer; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidate;
        RecRef_FROM := _RecRef_FROM.duplicate();
        RecRef_TO := _RecRef_TO.duplicate();
        FieldNo_FROM := _FieldNo_FROM;
        FieldNo_TO := _FieldNo_TO;
    end;

    procedure SetFieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    begin
        OnRunAction := OnRunAction::FieldValidateWithValue;
        NewValue := _NewValue;
        RecRef_TO := _RecRef_TO.duplicate();
        FieldNo_TO := _FieldNo_TO;
    end;

    procedure GetRecRefFrom(VAR _RecRef_FROM: RecordRef)
    begin
        _RecRef_FROM := RecRef_FROM;
    end;

    procedure GetRecRefTo(VAR _RecRef_TO: RecordRef)
    begin
        _RecRef_TO := RecRef_TO;
    end;

    LOCAL procedure FieldValidateRecRef(_RecRef_FROM: RecordRef; _FieldNo_FROM: Integer; var _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        ToField: FieldRef;
        FromField: FieldRef;
    begin
        FromField := _RecRef_FROM.FIELD(_FieldNo_FROM);
        ToField := _RecRef_TO.FIELD(_FieldNo_TO);
        ToField.VALIDATE(FromField.VALUE);
    end;

    LOCAL procedure FieldValidateWithValue(_NewValue: Variant; _RecRef_TO: RecordRef; _FieldNo_TO: Integer)
    var
        ToField: FieldRef;
    begin
        ToField := _RecRef_TO.FIELD(_FieldNo_TO);
        ToField.VALIDATE(_NewValue);
    end;


    var
        RecRef_FROM: RecordRef;
        RecRef_TO: RecordRef;
        FieldNo_FROM: Integer;
        FieldNo_TO: Integer;
        OnRunAction: Option FieldValidate,FieldValidateWithValue;
        NewValue: Variant;
}