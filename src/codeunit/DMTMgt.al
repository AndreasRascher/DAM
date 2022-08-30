codeunit 110002 "DMTMgt"
{

    procedure ProgressBar_Open(BufferRef: RecordRef; ProgressBarContent: Text)
    begin
        ProgressBar.Open(ProgressBarContent);
        ProgressBar_Total := BufferRef.COUNT;
        ProgressBar_StartTime := CURRENTDATETIME;
        ProgressBar_IsOpen := TRUE;
    end;

    procedure ProgressBar_Open(TotalLineCount: Integer; ProgressBarContent: Text)
    begin
        ProgressBar.Open(ProgressBarContent);
        ProgressBar_Total := TotalLineCount;
        ProgressBar_StartTime := CURRENTDATETIME;
        ProgressBar_IsOpen := TRUE;
    end;

    procedure ProgressBar_UpdateControl(Number: Integer; Value: Variant)
    begin
        if NOT ProgressBar_IsOpen then
            exit;
        if Number <> 0 then
            ProgressBar.UPDATE(Number, Value);
    end;

    procedure ProgressBar_Close()
    begin
        if ProgressBar_IsOpen then
            ProgressBar.close();
    end;

    procedure ProgressBar_GetTotal(): Integer
    begin
        exit(ProgressBar_Total);
    end;

    procedure ProgressBar_GetStep(): Integer
    begin
        exit(ProgressBar_Step);
    end;

    procedure ProgressBar_NextStep()
    begin
        ProgressBar_Step += 1;
    end;

    procedure ProgressBar_GetProgress(): Integer
    begin
        exit((10000 * (ProgressBar_Step / ProgressBar_Total)) DIV 1);
    end;

    procedure ProgressBar_Update(Number1: Integer; Value1: Variant; Number2: Integer; Value2: Variant; Number3: Integer; Value3: Variant; Number4: Integer; Value4: Variant; Number5: Integer; Value5: Variant)
    begin
        if NOT ProgressBar_IsOpen then
            exit;
        if (FORMAT(ProgressBar_LastUpdate) = '') then
            ProgressBar_LastUpdate := CURRENTDATETIME;
        if (CURRENTDATETIME - ProgressBar_LastUpdate) < 1000 then
            exit;
        if Number1 <> 0 then
            ProgressBar.UPDATE(Number1, Value1);
        if Number2 <> 0 then
            ProgressBar.UPDATE(Number2, Value2);
        if Number3 <> 0 then
            ProgressBar.UPDATE(Number3, Value3);
        if Number4 <> 0 then
            ProgressBar.UPDATE(Number4, Value4);
        if Number5 <> 0 then
            ProgressBar.UPDATE(Number5, Value5);

        ProgressBar_LastUpdate := CURRENTDATETIME;
    end;

    procedure ProgressBar_GetRemainingTime() TimeLeft: Text
    var
        ElapsedTime: Duration;
        RemainingMins: Decimal;
        RoundedRemainingMins: Integer;
        RemainingSeconds: Decimal;
    begin
        ElapsedTime := ROUND(((CURRENTDATETIME - ProgressBar_StartTime) / 1000), 1);
        RemainingMins := ROUND((((ElapsedTime / ((ProgressBar_GetStep() / ProgressBar_GetTotal()) * 100) * 100) - ElapsedTime) / 60), 0.1);
        RoundedRemainingMins := ROUND(RemainingMins, 1, '<');
        RemainingSeconds := ROUND(((RemainingMins - RoundedRemainingMins) * 0.6) * 100, 1);
        TimeLeft := STRSUBSTNO('%1:', RoundedRemainingMins);
        if STRLEN(FORMAT(RemainingSeconds)) = 1 then
            TimeLeft += STRSUBSTNO('0%1', RemainingSeconds)
        else
            TimeLeft += STRSUBSTNO('%1', RemainingSeconds);
    end;

    procedure ProgressBar_GetTimeElapsed(): Duration
    begin
        exit(CURRENTDATETIME - ProgressBar_StartTime);
    end;

    procedure GetResultQtyMessage()
    begin
        MESSAGE('Anzahl Datensätze..\' +
                'verarbeitet: %1\' +
                'eingelesen : %2\' +
                'mit Fehlern: %3\' +
                'Verarbeitungsdauer: %4', GetResultQty_QtyProcessed(), GetResultQty_QtySuccess(), GetResultQty_QtyFailed(), ProgressBar_GetTimeElapsed());
    end;

    procedure UpdateResultQty(IsSuccess: Boolean; IsProcessed: Boolean)
    begin
        Result_QtyProcessed += 1;
        IF IsSuccess then
            Result_QtySuccess += 1
        ELSE
            Result_QtyFailed += 1;
    end;

    procedure GetResultQty_QtyProcessed(): Integer
    begin
        exit(Result_QtyProcessed);
    end;

    procedure GetResultQty_QtyFailed(): Integer
    begin
        exit(Result_QtyFailed);
    end;

    procedure GetResultQty_QtySuccess(): Integer
    begin
        exit(Result_QtySuccess);
    end;

    procedure GetIncludeExcludeKeyFieldFilter(TableNo: Integer; Include: Boolean) KeyFieldNoFilter: Text
    var
        RecRef: RecordRef;
        KeyField: FieldRef;
        KeyCountIndex: Integer;
        KeyRef: KeyRef;
    begin
        IF TableNo = 0 then exit('');
        RecRef.OPEN(TableNo, TRUE);
        KeyRef := RecRef.KEYINDEX(1); // Primary Key
        for KeyCountIndex := 1 TO KeyRef.FIELDCOUNT do begin
            KeyField := KeyRef.FieldIndex(KeyCountIndex);
            IF Include then
                KeyFieldNoFilter += STRSUBSTNO('|%1', KeyField.NUMBER)
            ELSE
                KeyFieldNoFilter += STRSUBSTNO('&<>%1', KeyField.NUMBER);
        end;
        IF COPYSTR(KeyFieldNoFilter, 1, 1) = '|' then
            KeyFieldNoFilter := COPYSTR(KeyFieldNoFilter, 2);
        IF COPYSTR(KeyFieldNoFilter, 1, 3) = '&<>' then
            KeyFieldNoFilter := COPYSTR(KeyFieldNoFilter, 2);
    end;

    procedure InsertRecFromTmp(VAR BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; InsertTrue: Boolean) InsertOK: Boolean
    var
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
    begin
        TargetRef.OPEN(TmpTargetRef.NUMBER, FALSE);
        CopyRecordRef(TmpTargetRef, TargetRef);

        IF TargetRef2.GET(TargetRef.RECORDID) then begin
            InsertOK := TargetRef.MODIFY(InsertTrue);
        end else begin
            InsertOK := TargetRef.INSERT(InsertTrue);
        end;

    end;

    procedure CopyRecordRef(VAR RecRefSource: RecordRef; VAR RecRefTarget: RecordRef)
    var
        FieldRefSource: FieldRef;
        FieldRefTarget: FieldRef;
        i: Integer;
    begin
        for i := 1 TO RecRefSource.FIELDCOUNT do begin
            FieldRefTarget := RecRefTarget.FieldIndex(i);
            FieldRefSource := RecRefSource.FieldIndex(i);
            FieldRefTarget.Value := FieldRefSource.Value;
        end;
    end;

    procedure AssignFieldWithoutValidate(VAR TargetRef: RecordRef; FromFieldNo: Integer; SourceRef: RecordRef; ToFieldNo: Integer; DoModify: Boolean)
    var
        FromField: FieldRef;
        ToField: FieldRef;
        EvaluateOptionValueAsNumber: Boolean;
    begin
        // Check - Don't copy from or to timestamp
        if (FromFieldNo = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter FromFieldNo = 0');
        if (ToFieldNo = 0) then Error('AssignFieldWithoutValidate: Invalid Paramter ToFieldNo = 0');
        EvaluateOptionValueAsNumber := (Database::DMTGenBuffTable = SourceRef.Number);
        FromField := SourceRef.field(FromFieldNo);
        ToField := TargetRef.field(ToFieldNo);
        if ToField.Type = FromField.Type then
            ToField.Value := FromField.Value
        else
            if not EvaluateFieldRef(ToField, Format(FromField.Value), EvaluateOptionValueAsNumber, true) then
                Error('Evaluating "%1" into "%2" failed', FromField.Value, ToField.Caption);
        IF DoModify then
            TargetRef.modify();
    end;

    procedure ValidateField(VAR TargetRef: RecordRef; SourceRef: RecordRef; DMTField: Record "DMTField")
    var
        DMTErrorLog: Record DMTErrorLog;
        DMTTable: Record DMTTable;
        IsValidateSuccessful: Boolean;
    begin
        if (DMTField."Source Field No." = 0) then Error('ValidateField: Invalid Paramter DMTField."Source Field No." = 0');
        if (DMTField."Target Field No." = 0) then Error('ValidateField: Invalid Paramter DMTField."Target Field No." = 0');
        ClearLastError();
        DMTTable.Get(DMTField."Target Table ID");
        IF DMTField."Use Try Function" and DMTTable."Allow Usage of Try Function" then begin
            IsValidateSuccessful := DoTryFunctionValidate(SourceRef, DMTField."Source Field No.", DMTField."Target Field No.", TargetRef);
        end else begin
            IsValidateSuccessful := DoIfCodeunitRunValidate(SourceRef, DMTField."Source Field No.", DMTField."Target Field No.", TargetRef);
        end;
        // HANDLE VALIDATE RESULT
        IF not IsValidateSuccessful then begin
            if GetLastErrorCode = 'DebuggerActivityAborted' then // Avoid Hangups
                Error(GetLastErrorCode);
            DMTErrorLog.AddEntryForLastError(SourceRef, TargetRef, DMTField);
        end else begin
            // Save Successful changes
            IF TargetRef.modify() then;
        end;
    end;

    procedure ValidateFieldWithValue(VAR TargetRef: RecordRef; ToFieldNo: Integer; NewValue: Variant; IgnoreErrorFlag: Boolean)
    var
        DMTErrorLog: Record DMTErrorLog;
        DMTErrorWrapper: Codeunit DMTErrorWrapper;
        IsValidateSuccessful: Boolean;
    begin
        ClearLastError();
        // VALIDATE
        Commit();
        DMTErrorWrapper.SetFieldValidateWithValue(NewValue, TargetRef, ToFieldNo);
        IsValidateSuccessful := DMTErrorWrapper.RUN();
        DMTErrorWrapper.GetRecRefTo(TargetRef);
        // HANDLE VALIDATE RESULT
        if not IsValidateSuccessful then begin
            DMTErrorLog.AddEntryForLastError(TargetRef, ToFieldNo, IgnoreErrorFlag);
        end else begin
            // Save Successful changes
            IF TargetRef.modify() then;
        end;
    end;

    procedure EvaluateFieldRef(var FieldRef_TO: FieldRef; FromText: text; EvaluateOptionValueAsNumber: Boolean; ThrowError: Boolean): Boolean
    var
        TempBlob: Record "Tenant Media" temporary;
        _DateFormula: DateFormula;
        _RecordID: RecordId;
        _BigInteger: BigInteger;
        _Boolean: Boolean;
        _Date: Date;
        _DateTime: DateTime;
        _Time: Time;
        _Decimal: Decimal;
        _Integer: Integer;
        NoOfOptions: Integer;
        OptionIndex: Integer;
        _OutStream: OutStream;
        OptionElement: text;
        InvalidValueForTypeErr: Label '"%1" is not a valid %2 value.', Comment = '"%1" ist kein gültiger %2 Wert';
    begin
        if FromText = '' then
            case UpperCase(Format(FieldRef_TO.TYPE)) of
                'BIGINTEGER', 'INTEGER', 'DECIMAL':
                    begin
                        FromText := '0';
                        exit(true);
                    end;
            end;
        case UpperCase(Format(FieldRef_TO.TYPE)) OF

            'INTEGER':
                begin
                    IF Evaluate(_Integer, FromText) then begin
                        FieldRef_TO.Value := _Integer;
                        exit(TRUE);
                    end else
                        if ThrowError then
                            Evaluate(_Integer, FromText)
                end;
            'BIGINTEGER':
                IF Evaluate(_BigInteger, FromText) then begin
                    FieldRef_TO.Value := _BigInteger;
                    exit(TRUE);
                end else
                    if ThrowError then
                        Evaluate(_BigInteger, FromText);
            'TEXT', 'TABLEFILTER':
                begin
                    FieldRef_TO.Value := COPYSTR(FromText, 1, FieldRef_TO.LENGTH);
                    exit(TRUE);
                end;
            'CODE':
                begin
                    FieldRef_TO.Value := UPPERCASE(COPYSTR(FromText, 1, FieldRef_TO.LENGTH));
                    exit(TRUE);
                end;
            'DECIMAL':
                IF Evaluate(_Decimal, FromText) then begin
                    FieldRef_TO.Value := _Decimal;
                    exit(TRUE);
                end else
                    if ThrowError then
                        Evaluate(_Decimal, FromText);
            'BOOLEAN':
                IF Evaluate(_Boolean, FromText) then begin
                    FieldRef_TO.Value := _Boolean;
                    exit(TRUE);
                end else
                    if ThrowError then
                        Evaluate(_Boolean, FromText);
            'RECORDID':
                IF Evaluate(_RecordID, FromText) then begin
                    FieldRef_TO.Value := _RecordID;
                    exit(TRUE);
                end else
                    if ThrowError then
                        Error(InvalidValueForTypeErr, FromText, FieldRef_TO.Type);
            'OPTION':
                IF EvaluateOptionValueAsNumber then begin
                    //Optionswert wird als Zahl übergeben
                    if Evaluate(_Integer, FromText) then begin
                        FieldRef_TO.Value := _Integer;
                        exit(TRUE);
                    end else
                        if ThrowError then
                            Evaluate(_RecordID, FromText);
                end else begin
                    //Optionswert wird als Text übergeben
                    NoOfOptions := STRLEN(FieldRef_TO.OPTIONCAPTION) - STRLEN(DELCHR(FieldRef_TO.OPTIONCAPTION, '=', ',')); // zero based
                    FOR OptionIndex := 0 TO NoOfOptions DO begin
                        OptionElement := SELECTSTR(OptionIndex + 1, FieldRef_TO.OPTIONCAPTION);
                        IF OptionElement = FromText then begin
                            FieldRef_TO.Value := OptionIndex;
                            exit(TRUE);
                        end;
                    end;
                end;
            'DATE':
                begin
                    //ApplicationMgt.MakeDateText(FromText);
                    IF Evaluate(_Date, FromText) then begin
                        FieldRef_TO.Value := _Date;
                        exit(TRUE);
                    end else
                        if ThrowError then
                            Evaluate(_Date, FromText);
                end;

            'DATETIME':
                begin
                    //ApplicationMgt.MakeDateTimeText(FromText);
                    IF Evaluate(_DateTime, FromText) then begin
                        FieldRef_TO.Value := _DateTime;
                        exit(TRUE);
                    end else
                        if ThrowError then Evaluate(_DateTime, FromText);
                end;
            'TIME':
                begin
                    IF Evaluate(_Time, FromText) then begin
                        FieldRef_TO.Value := _Time;
                        exit(TRUE);
                    end else
                        if ThrowError then Evaluate(_Time, FromText);
                end;
            'BLOB':
                begin
                    TempBlob.DeleteAll();
                    TempBlob.Content.CREATEOUTSTREAM(_OutStream);
                    _OutStream.WRITETEXT(FromText);
                    TempBlob.insert();
                    FieldRef_TO.VALUE(TempBlob.Content);
                    exit(TRUE);
                end;
            'DATEFORMULA':
                begin
                    IF Evaluate(_DateFormula, FromText, 9) then begin
                        FieldRef_TO.Value := _DateFormula;
                        exit(TRUE);
                    end else
                        if ThrowError then Evaluate(_DateFormula, FromText);
                end;
            ELSE
                MESSAGE('Funktion "EvaluateFieldRef" - nicht behandelter Datentyp %1', FORMAT(FieldRef_TO.TYPE));
        end;  // end_CASE
    end;

    [TryFunction]
    procedure DoTryFunctionValidate(SourceRef: RecordRef; FromFieldNo: Integer; ToFieldNo: Integer; VAR TargetRef: RecordRef)
    begin
        ValidateFieldImplementation(SourceRef, FromFieldNo, ToFieldNo, TargetRef);
    end;

    procedure DoIfCodeunitRunValidate(SourceRef: RecordRef; FromFieldNo: Integer; ToFieldNo: Integer; VAR TargetRef: RecordRef) IsValidateSuccessful: Boolean
    var
        DMTErrorWrapper: Codeunit DMTErrorWrapper;
    begin
        COMMIT();
        DMTErrorWrapper.SetFieldValidateRecRef(SourceRef, FromFieldNo, TargetRef, ToFieldNo);
        IsValidateSuccessful := DMTErrorWrapper.RUN();
        DMTErrorWrapper.GetRecRefTo(TargetRef);
    end;

    procedure ValidateFieldImplementation(SourceRecRef: RecordRef; FromFieldno: Integer; ToFieldNo: Integer; VAR TargetRecRef: RecordRef)
    var
        FromField: FieldRef;
        ToField, FieldWithTypeCorrectValueToValidate : FieldRef;
    begin
        FromField := SourceRecRef.field(FromFieldno);
        ToField := TargetRecRef.field(ToFieldNo);
        FieldWithTypeCorrectValueToValidate := TargetRecRef.field(ToFieldNo);
        case true of
            (ToField.Type = FromField.Type):
                FieldWithTypeCorrectValueToValidate.Value := FromField.VALUE; // Same Type -> no conversion needed
            (FromField.Type in [FieldType::Text, FieldType::Code]):
                if not EvaluateFieldRef(FieldWithTypeCorrectValueToValidate, Format(FromField.Value), true, true) then
                    Error('TODO');
            else
                Error('unhandled TODO %1', FromField.Type);
        end;

        ToField.VALIDATE(FieldWithTypeCorrectValueToValidate.Value);
        TargetRecRef.modify();
    end;

    [TryFunction]
    procedure TryValidateFieldWithValue(VAR TargetRecRef: RecordRef; ToFieldNo: Integer; NewValue: Variant)
    begin
        ValidateFieldWithValueImplementation(ToFieldNo, NewValue, TargetRecRef);
    end;

    procedure ValidateFieldWithValueImplementation(ToFieldNo: Integer; NewValue: Variant; VAR TargetRecRef: RecordRef)
    var
        ToField: FieldRef;
    begin
        ToField := TargetRecRef.field(ToFieldNo);
        ToField.VALIDATE(NewValue);
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

    var
        DMTSetup: Record "DMTSetup";
        ProgressBar_IsOpen: Boolean;
        ProgressBar_LastUpdate: DateTime;
        ProgressBar_StartTime: DateTime;
        ProgressBar: Dialog;
        ProgressBar_Step: integer;
        ProgressBar_Total: Integer;
        Result_QtyProcessed: Integer;
        Result_QtySuccess: Integer;
        Result_QtyFailed: Integer;

}