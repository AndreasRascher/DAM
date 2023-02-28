codeunit 110002 DMTMgt
{

    procedure GetIncludeExcludeKeyFieldFilter(TableNo: Integer; Include: Boolean) KeyFieldNoFilter: Text
    var
        RecRef: RecordRef;
        FieldID: Integer;
        KeyFieldIDsList: List of [Integer];
    begin
        if TableNo = 0 then exit('');
        RecRef.Open(TableNo, true);
        KeyFieldIDsList := GetListOfKeyFieldIDs(RecRef);
        foreach FieldID in KeyFieldIDsList do begin
            if Include then
                KeyFieldNoFilter += StrSubstNo('|%1', FieldID)
            else
                KeyFieldNoFilter += StrSubstNo('&<>%1', FieldID);
        end;
        if CopyStr(KeyFieldNoFilter, 1, 1) = '|' then
            KeyFieldNoFilter := CopyStr(KeyFieldNoFilter, 2);
        if CopyStr(KeyFieldNoFilter, 1, 3) = '&<>' then
            KeyFieldNoFilter := CopyStr(KeyFieldNoFilter, 2);
    end;

    procedure GetListOfKeyFieldIDs(var RecRef: RecordRef) KeyFieldIDsList: List of [Integer];
    var
        FieldRef: FieldRef;
        _KeyIndex: Integer;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for _KeyIndex := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(_KeyIndex);
            KeyFieldIDsList.Add(FieldRef.Number);
        end;
    end;

    procedure CopyRecordRef(var RecRefSource: RecordRef; var RecRefTarget: RecordRef)
    var
        FieldRefSource: FieldRef;
        FieldRefTarget: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecRefSource.FieldCount do begin
            if RecRefTarget.FieldIndex(i).Class = FieldClass::Normal then begin
                FieldRefSource := RecRefSource.FieldIndex(i);
                if FieldRefSource.Type in [FieldType::Blob] then
                    FieldRefSource.CalcField();
                FieldRefTarget := RecRefTarget.FieldIndex(i);
                FieldRefTarget.Value := FieldRefSource.Value;
            end;
        end;
    end;

    procedure AssignFieldWithoutValidate(var TargetRef: RecordRef; SourceRef: RecordRef; var FieldMapping: Record DMTFieldMapping; DoModify: Boolean)
    var
        FromField: FieldRef;
        ToField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        // Check - Don't copy from or to timestamp
        if (FieldMapping."Source Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter FromFieldNo = 0');
        if (FieldMapping."Target Field No." = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter ToFieldNo = 0');
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRef.Number);
        FromField := SourceRef.Field(FieldMapping."Source Field No.");
        ToField := TargetRef.Field(FieldMapping."Target Field No.");
        if ToField.Type = FromField.Type then
            ToField.Value := FromField.Value
        else
            if not EvaluateFieldRef(ToField, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                Error('Evaluating "%1" into "%2" failed', FromField.Value, ToField.Caption);
        // ApplyReplacements(FieldMapping, ToField);
        if DoModify then
            TargetRef.Modify();
    end;

    procedure EvaluateFieldRef(var FieldRef_TO: FieldRef; FromText: Text; EvaluateOptionValueAsNumber: Boolean; ThrowError: Boolean): Boolean
    var
        TempBlob: Record "Tenant Media" temporary;
        _DateFormula: DateFormula;
        _RecordID: RecordId;
        _BigInteger: BigInteger;
        _Boolean: Boolean;
        _Date: Date;
        _DateTime: DateTime;
        _Decimal: Decimal;
        _Integer: Integer;
        NoOfOptions: Integer;
        OptionIndex: Integer;
        InvalidValueForTypeErr: Label '"%1" is not a valid %2 value.', Comment = '"%1" ist kein gültiger %2 Wert';
        _OutStream: OutStream;
        OptionElement: Text;
        _Time: Time;
    begin
        if FromText = '' then
            case UpperCase(Format(FieldRef_TO.Type)) of
                'BIGINTEGER', 'INTEGER', 'DECIMAL':
                    begin
                        FromText := '0';
                        exit(true);
                    end;
            end;
        case UpperCase(Format(FieldRef_TO.Type)) of

            'INTEGER':
                begin
                    case true of
                        Evaluate(_Integer, FromText, 9):
                            begin
                                FieldRef_TO.Value := _Integer;
                                exit(true);
                            end;
                        else
                            if ThrowError then
                                Evaluate(_Integer, FromText, 9)
                    end;
                end;
            'BIGINTEGER':
                if Evaluate(_BigInteger, FromText, 9) then begin
                    FieldRef_TO.Value := _BigInteger;
                    exit(true);
                end else
                    if ThrowError then
                        Evaluate(_BigInteger, FromText, 9);
            'TEXT', 'TABLEFILTER':
                begin
                    FieldRef_TO.Value := CopyStr(FromText, 1, FieldRef_TO.Length);
                    exit(true);
                end;
            'CODE':
                begin
                    FieldRef_TO.Value := UpperCase(CopyStr(FromText, 1, FieldRef_TO.Length));
                    exit(true);
                end;
            'DECIMAL':
                if Evaluate(_Decimal, FromText, 9) then begin
                    FieldRef_TO.Value := _Decimal;
                    exit(true);
                end else
                    if ThrowError then
                        Evaluate(_Decimal, FromText, 9);
            'BOOLEAN':
                case true of
                    Evaluate(_Boolean, FromText, 9):
                        begin
                            FieldRef_TO.Value := _Boolean;
                            exit(true);
                        end;
                    // Needed for Evaluate from Fixed Value Test (true,false,ja,nein), xml-format only accepts 0 or 1   
                    Evaluate(_Boolean, FromText):
                        begin
                            FieldRef_TO.Value := _Boolean;
                            exit(true);
                        end
                    else
                        if ThrowError then
                            Evaluate(_Boolean, FromText, 9);
                end;

            'RECORDID':
                if Evaluate(_RecordID, FromText) then begin
                    FieldRef_TO.Value := _RecordID;
                    exit(true);
                end else
                    if ThrowError then
                        Error(InvalidValueForTypeErr, FromText, FieldRef_TO.Type);
            'OPTION':
                if EvaluateOptionValueAsNumber then begin
                    //Optionswert wird als Zahl übergeben
                    if Evaluate(_Integer, FromText) then begin
                        FieldRef_TO.Value := _Integer;
                        exit(true);
                    end else
                        if ThrowError then
                            Evaluate(_RecordID, FromText);
                end else begin
                    //Optionswert wird als Text übergeben
                    NoOfOptions := StrLen(FieldRef_TO.OptionCaption) - StrLen(DelChr(FieldRef_TO.OptionCaption, '=', ',')); // zero based
                    for OptionIndex := 0 to NoOfOptions do begin
                        OptionElement := SelectStr(OptionIndex + 1, FieldRef_TO.OptionCaption);
                        if OptionElement.ToLower() = FromText.ToLower() then begin
                            FieldRef_TO.Value := OptionIndex;
                            exit(true);
                        end;
                    end;
                end;
            'DATE':
                begin
                    //ApplicationMgt.MakeDateText(FromText);
                    if Evaluate(_Date, FromText, 9) then begin
                        FieldRef_TO.Value := _Date;
                        exit(true);
                    end else
                        if ThrowError then
                            Evaluate(_Date, FromText, 9);
                end;

            'DATETIME':
                begin
                    //ApplicationMgt.MakeDateTimeText(FromText);
                    if Evaluate(_DateTime, FromText, 9) then begin
                        FieldRef_TO.Value := _DateTime;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_DateTime, FromText, 9);
                end;
            'TIME':
                begin
                    if Evaluate(_Time, FromText, 9) then begin
                        FieldRef_TO.Value := _Time;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_Time, FromText, 9);
                end;
            'BLOB':
                begin
                    TempBlob.DeleteAll();
                    TempBlob.Content.CreateOutStream(_OutStream);
                    _OutStream.WriteText(FromText);
                    TempBlob.Insert();
                    FieldRef_TO.Value(TempBlob.Content);
                    exit(true);
                end;
            'DATEFORMULA':
                begin
                    if Evaluate(_DateFormula, FromText, 9) then begin
                        FieldRef_TO.Value := _DateFormula;
                        exit(true);
                    end else
                        if ThrowError then Evaluate(_DateFormula, FromText, 9);
                end;
            else
                Message('Funktion "EvaluateFieldRef" - nicht behandelter Datentyp %1', Format(FieldRef_TO.Type));
        end;  // end_CASE
    end;

    procedure AssignValueToFieldRef(SourceRecRef: RecordRef; FieldMapping: Record DMTFieldMapping; TargetRecRef: RecordRef; var FieldWithTypeCorrectValueToValidate: FieldRef)
    var
        DMTMgt: Codeunit DMTMgt;
        FromField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        FromField := SourceRecRef.Field(FieldMapping."Source Field No.");
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRecRef.Number);
        FieldWithTypeCorrectValueToValidate := TargetRecRef.Field(FieldMapping."Target Field No.");

        case true of
            (FieldMapping."Processing Action" = FieldMapping."Processing Action"::FixedValue):
                DMTMgt.AssignFixedValueToFieldRef(FieldWithTypeCorrectValueToValidate, FieldMapping."Fixed Value");
            (TargetRecRef.Field(FieldMapping."Target Field No.").Type = FromField.Type):
                FieldWithTypeCorrectValueToValidate.Value := FromField.Value; // Same Type -> no conversion needed
            (FromField.Type in [FieldType::Text, FieldType::Code]):
                if not EvaluateFieldRef(FieldWithTypeCorrectValueToValidate, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                    Error('TODO');
            else
                Error('unhandled TODO %1', FromField.Type);
        end;
    end;

    procedure LookUpPath(CurrentPath: Text; LookUpFolder: Boolean) ResultPath: Text[250]
    var
        FileBrowser: Page FileBrowser;
    begin
        DMTSetup.GetRecordOnce();
        if CurrentPath = '' then
            CurrentPath := DMTSetup."Default Export Folder Path";
        FileBrowser.SetupFileBrowser(CurrentPath, LookUpFolder);
        FileBrowser.LookupMode(true);
        if not (FileBrowser.RunModal() = Action::LookupOK) then
            exit(CopyStr(CurrentPath, 1, 250));
        ResultPath := CopyStr(FileBrowser.GetSelectedPath(), 1, MaxStrLen(ResultPath));
    end;

    procedure LookUpPath(var FileRec: Record File; CurrentPath: Text; LookUpFolder: Boolean) OK: Boolean
    var
        FileBrowser: Page FileBrowser;
    begin
        DMTSetup.GetRecordOnce();
        if CurrentPath = '' then
            CurrentPath := DMTSetup."Default Export Folder Path";
        FileBrowser.SetupFileBrowser(CurrentPath, LookUpFolder);
        FileBrowser.LookupMode(true);
        if not (FileBrowser.RunModal() = Action::LookupOK) then
            exit(false);
        FileBrowser.GetRecord(FileRec);
        exit(true);
    end;

    internal procedure AssignFixedValueToFieldRef(var ToFieldRef: FieldRef; FixedValue: Text[250])
    begin
        if not EvaluateFieldRef(ToFieldRef, FixedValue, false, false) then
            Error('Invalid Fixed Value %1', FixedValue);
    end;

    procedure GetTargetRefRecordID(dataFile: record DMTDataFile; SourceRef: RecordRef; var TmpFieldMapping: Record DMTFieldMapping temporary) TargetRecID: RecordId
    var
        DMTMgt: Codeunit DMTMgt;
        ToFieldRef: FieldRef;
        TmpTargetRef: RecordRef;
    begin
        TmpTargetRef.Open(dataFile."Target Table ID", true);

        TmpFieldMapping.Reset();
        TmpFieldMapping.SetRange("Is Key Field(Target)", true);
        TmpFieldMapping.FindSet();
        repeat

            case TmpFieldMapping."Processing Action" of
                TmpFieldMapping."Processing Action"::Ignore:
                    ;
                TmpFieldMapping."Processing Action"::Transfer:
                    DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, SourceRef, TmpFieldMapping, false);
                TmpFieldMapping."Processing Action"::FixedValue:
                    begin
                        ToFieldRef := TmpTargetRef.Field(TmpFieldMapping."Target Field No.");
                        DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TmpFieldMapping."Fixed Value");
                    end;
            end;
        until TmpFieldMapping.Next() = 0;
        TargetRecID := TmpTargetRef.RecordId;
    end;

    var
        DMTSetup: Record DMTSetup;
}