codeunit 91001 "DAMMgt"
{
    procedure CheckBufferTableIsNotEmpty(TableID: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.OPEN(TableID);
        if RecRef.ISEMPTY then ERROR('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.CAPTION, TableID);
    end;

    procedure ProgressBar_Open(BufferRef: RecordRef; ProgressBarContent: Text)
    begin
        ProgressBar.OPEN(ProgressBarContent);
        ProgressBar_Total := BufferRef.COUNT;
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
        if (CURRENTDATETIME - ProgressBar_LastUpdate) < 500 then
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
            KeyField := KeyRef.FIELDINDEX(KeyCountIndex);
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
        KeyField: FieldRef;
        KeyRef: KeyRef;
    begin
        // don't insert empty Keys
        KeyRef := BufferRef.KEYINDEX(1);
        KeyField := KeyRef.FIELDINDEX(1);
        IF UPPERCASE(FORMAT(KeyField.TYPE)) IN ['CODE', 'TEXT'] then
            IF FORMAT(KeyField.VALUE) = '' then
                exit(FALSE);

        TargetRef.OPEN(TmpTargetRef.NUMBER, FALSE);
        CopyRecordRef(TmpTargetRef, TargetRef);

        IF TargetRef2.GET(TargetRef.RECORDID) then begin
            InsertOK := TargetRef.MODIFY(InsertTrue);
        end ELSE begin
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
            FieldRefTarget := RecRefTarget.FIELDINDEX(i);
            FieldRefSource := RecRefSource.FIELDINDEX(i);
            FieldRefTarget.VALUE := FieldRefSource.VALUE;
        end;
    end;

    procedure AssignFieldWithoutValidate(VAR TargetRef: RecordRef; FromFieldNo: Integer; SourceRef: RecordRef; ToFieldNo: Integer; DoModify: Boolean)
    var
        FromField: FieldRef;
        ToField: FieldRef;
    begin
        FromField := SourceRef.FIELD(FromFieldNo);
        ToField := TargetRef.FIELD(ToFieldNo);
        ToField.VALUE := FromField.VALUE;
        IF DoModify then
            TargetRef.modify();
    end;

    procedure ValidateField(VAR TargetRef: RecordRef; SourceRef: RecordRef; DAMFields: Record DAMFields)
    var
        DAMErrorLog: Record DAMErrorLog;
        DAMErrorWrapper: Codeunit DAMErrorWrapper;
        IsValidateSuccessful: Boolean;
    begin
        CLEARLASTERROR();
        // VALIDATE
        IF DAMFields."Validate Method" = DAMFields."Validate Method"::"try function" then begin
            IsValidateSuccessful := TryValidateField(SourceRef, DAMFields."From Field No.", DAMFields."To Field No.", TargetRef);
        end ELSE begin
            COMMIT();
            DAMErrorWrapper.SetFieldValidateRecRef(SourceRef, DAMFields."From Field No.", TargetRef, DAMFields."To Field No.");
            IsValidateSuccessful := DAMErrorWrapper.RUN();
            DAMErrorWrapper.GetRecRefTo(TargetRef);
        end;
        // HANDLE VALIDATE RESULT
        IF NOT IsValidateSuccessful then begin
            DAMErrorLog.AddEntryForLastError(SourceRef, TargetRef, DAMFields);
        end ELSE begin
            // Save Successful changes
            IF TargetRef.modify() then;
        end;
    end;

    procedure ValidateFieldWithValue(VAR TargetRef: RecordRef; ToFieldNo: Integer; NewValue: Variant; UseIfCodeunitOnRun: Boolean; IgnoreErrorFlag: Boolean)
    var
        DAMErrorLog: Record DAMErrorLog;
        DAMErrorWrapper: Codeunit DAMErrorWrapper;
        IsValidateSuccessful: Boolean;
    begin
        ClearLastError();
        // VALIDATE
        IF NOT UseIfCodeunitOnRun then begin
            IsValidateSuccessful := TryValidateFieldWithValue(TargetRef, ToFieldNo, NewValue);
        end ELSE begin
            Commit();
            DAMErrorWrapper.SetFieldValidateWithValue(NewValue, TargetRef, ToFieldNo);
            IsValidateSuccessful := DAMErrorWrapper.RUN();
            DAMErrorWrapper.GetRecRefTo(TargetRef);
        end;
        // HANDLE VALIDATE RESULT
        IF NOT IsValidateSuccessful then begin
            DAMErrorLog.AddEntryForLastError(TargetRef, ToFieldNo, IgnoreErrorFlag);
        end ELSE begin
            // Save Successful changes
            IF TargetRef.modify() then;
        end;
    end;

    procedure EvaluateFieldRef(var FieldRef_TO: FieldRef; FromText: text; EvaluateOptionValueAsNumber: Boolean): Boolean
    var
        TempBlob: Record "Tenant Media" temporary;
        _RecordID: RecordId;
        _BigInteger: BigInteger;
        _Boolean: Boolean;
        _Date: Date;
        _DateTime: DateTime;
        _Decimal: Decimal;
        _Integer: Integer;
        OptionIndex: Integer;
        _OutStream: OutStream;
    begin
        CASE UPPERCASE(FORMAT(FieldRef_TO.TYPE)) OF

            'INTEGER':
                IF EVALUATE(_Integer, FromText) then begin
                    FieldRef_TO.VALUE := _Integer;
                    exit(TRUE);
                end;
            'BIGINTEGER':
                IF EVALUATE(_BigInteger, FromText) then begin
                    FieldRef_TO.VALUE := _BigInteger;
                    exit(TRUE);
                end;
            'TEXT', 'TABLEFILTER':
                begin
                    FieldRef_TO.VALUE := COPYSTR(FromText, 1, FieldRef_TO.LENGTH);
                    exit(TRUE);
                end;
            'CODE':
                begin
                    FieldRef_TO.VALUE := UPPERCASE(COPYSTR(FromText, 1, FieldRef_TO.LENGTH));
                    exit(TRUE);
                end;
            'DECIMAL':
                IF EVALUATE(_Decimal, FromText) then begin
                    FieldRef_TO.VALUE := _Decimal;
                    exit(TRUE);
                end;
            'BOOLEAN':
                IF EVALUATE(_Boolean, FromText) then begin
                    FieldRef_TO.VALUE := _Boolean;
                    exit(TRUE);
                end;
            'RECORDID':
                IF EVALUATE(_RecordID, FromText) then begin
                    FieldRef_TO.VALUE := _RecordID;
                    exit(TRUE);
                end;
            'OPTION':
                IF EvaluateOptionValueAsNumber then begin
                    //Optionswert wird als Zahl übergeben
                    EVALUATE(_Integer, FromText);
                    FieldRef_TO.VALUE := _Integer;
                    exit(TRUE);
                end ELSE begin
                    //Optionswert wird als Text übergeben
                    IF STRPOS(UPPERCASE(FieldRef_TO.OPTIONCAPTION), UPPERCASE(FromText)) > 0 then begin
                        IF FieldRef_TO.OPTIONCAPTION[1] = ',' then
                            OptionIndex := 2
                        ELSE
                            OptionIndex := 1;
                        WHILE STRPOS(UPPERCASE(SELECTSTR(OptionIndex, FieldRef_TO.OPTIONCAPTION)), UPPERCASE(FromText)) = 0 do begin
                            OptionIndex += 1;
                        end;
                        FieldRef_TO.VALUE := OptionIndex - 1; //Optionswert beginnt mit 0
                        exit(TRUE);
                    end;
                end;
            'DATE':
                begin
                    //ApplicationMgt.MakeDateText(FromText);
                    IF EVALUATE(_Date, FromText) then begin
                        FieldRef_TO.VALUE := _Date;
                        exit(TRUE);
                    end;
                end;

            'DATETIME':
                begin
                    //ApplicationMgt.MakeDateTimeText(FromText);
                    IF EVALUATE(_DateTime, FromText) then begin
                        FieldRef_TO.VALUE := _DateTime;
                        exit(TRUE);
                    end;
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
            ELSE
                MESSAGE('Funktion "EvaluateFieldRef" - nicht behandelter Datentyp %1', FORMAT(FieldRef_TO.TYPE));
        end;  // end_CASE
    end;

    [TryFunction]
    procedure TryValidateField(SourceRef: RecordRef; FromFieldNo: Integer; ToFieldNo: Integer; VAR TargetRef: RecordRef)
    begin
        ValidateFieldImplementation(SourceRef, FromFieldNo, ToFieldNo, TargetRef);
    end;

    procedure ValidateFieldImplementation(SourceRecRef: RecordRef; FromFieldno: Integer; ToFieldNo: Integer; VAR TargetRecRef: RecordRef)
    var
        FromField: FieldRef;
        ToField: FieldRef;
    begin
        FromField := SourceRecRef.FIELD(FromFieldno);
        ToField := TargetRecRef.FIELD(ToFieldNo);
        ToField.VALIDATE(FromField.VALUE);
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
        ToField := TargetRecRef.FIELD(ToFieldNo);
        ToField.VALIDATE(NewValue);
    end;

    var
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