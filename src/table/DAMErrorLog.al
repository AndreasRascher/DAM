table 91003 "DAMErrorLog"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            CaptionML = DEU = 'Lfd.Nr.', ENU = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "From ID"; RecordId)
        {
            CaptionML = DEU = 'Import von Record ID', ENU = 'Import from Record ID';
        }
        field(11; "To ID"; RecordId)
        {
            CaptionML = DEU = 'Import nach Record ID', ENU = 'Import to Record ID';
        }
        field(12; "From ID (Text)"; Text[250])
        {
            CaptionML = DEU = 'Import von Record ID', ENU = 'Import from Record ID';
        }
        field(13; "To ID (Text)"; Text[250])
        {
            CaptionML = DEU = 'Import nach Record ID', ENU = 'Import to Record ID';
        }
        field(20; "Import from Table No."; Integer) { }
        field(21; "Import from Field No."; Integer) { }
        field(22; "From Field Caption"; Text[250])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Import to Table No."), "No." = FIELD("Import to Field No.")));
        }
        field(30; "Import to Table No."; Integer) { }
        field(31; "Import to Field No."; Integer) { }
        field(32; "To Field Caption"; Text[250])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Import from Table No."), "No." = FIELD("Import from Field No.")));
        }
        field(40; "Errortext"; Text[2048]) { CaptionML = DEU = 'Fehlertext'; }
        field(41; ErrorCode; Text[250]) { CaptionML = DEU = 'Fehler Code'; }
        field(42; "Ignore Error"; Boolean) { CaptionML = DEU = 'Fehler ignorieren'; }
        field(60; "DAM User"; Text[250]) { CaptionML = DEU = 'DAM Benutzer', ENU = 'DAM User'; Editable = false; }
        field(70; "DAM Errorlog Created At"; DateTime) { CaptionML = DEU = 'DAM Datum der Protokollierung', ENU = 'DAM Date of Errorlog'; }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure AddEntryForLastError(FromRecRef: recordref; ToRecRef: RecordRef; DAMFields: Record DAMFields);
    var
        _DAMErrorlog: Record DAMErrorLog;
    begin
        _DAMErrorlog.INSERT(TRUE);
        _DAMErrorlog."From ID" := FromRecRef.RecordId;
        _DAMErrorlog."To ID" := ToRecRef.RecordId;
        _DAMErrorlog."From ID (Text)" := CopyStr(Format(_DAMErrorlog."From ID"), 1, MaxStrLen(_DAMErrorlog."From ID (Text)"));
        _DAMErrorlog."To ID (Text)" := CopyStr(Format(_DAMErrorlog."to ID"), 1, MaxStrLen(_DAMErrorlog."To ID (Text)"));

        _DAMErrorlog."Import from Table No." := DAMFields."From Table ID";
        _DAMErrorlog."Import from Field No." := DAMFields."From Field No.";
        _DAMErrorlog."Import to Table No." := DAMFields."To Table ID";
        _DAMErrorlog."Import to Field No." := DAMFields."To Field No.";
        _DAMErrorlog."Ignore Error" := DAMFields."Ignore Validation Error";

        _DAMErrorlog.Errortext := COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(_DAMErrorlog.Errortext));
        _DAMErrorlog.ErrorCode := CopyStr(GETLASTERRORCODE, 1, MaxStrLen(_DAMErrorlog.ErrorCode));
        _DAMErrorlog."DAM User" := CopyStr(USERID, 1, MaxStrLen(_DAMErrorlog."DAM User"));
        _DAMErrorlog."DAM Errorlog Created At" := CURRENTDATETIME;
        _DAMErrorlog.MODIFY(TRUE);
    end;

    procedure AddEntryForLastError(ToRecRef: RecordRef; ToFieldNo: Integer; IgnoreError: Boolean);
    var
        _DAMErrorlog: Record DAMErrorLog;
    begin
        _DAMErrorlog.INSERT(TRUE);
        _DAMErrorlog."To ID" := ToRecRef.RecordId;
        _DAMErrorlog."Import to Table No." := ToRecRef.Number;
        _DAMErrorlog."Import to Field No." := ToFieldNo;
        _DAMErrorlog."Ignore Error" := IgnoreError;

        _DAMErrorlog.Errortext := COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(_DAMErrorlog.Errortext));
        _DAMErrorlog.ErrorCode := CopyStr(GETLASTERRORCODE, 1, MaxStrLen(_DAMErrorlog.ErrorCode));
        _DAMErrorlog."DAM User" := CopyStr(USERID, 1, MaxStrLen(_DAMErrorlog."DAM User"));
        _DAMErrorlog."DAM Errorlog Created At" := CURRENTDATETIME;
        _DAMErrorlog.MODIFY(TRUE);
    end;

    procedure AddEntryWithUserDefinedMessage(DAMFields: Record DAMFields; ErrorMessage: text)
    var
        _DAMErrorlog: Record DAMErrorLog;
    begin
        _DAMErrorlog.INSERT(TRUE);
        _DAMErrorlog."Import from Table No." := DAMFields."From Table ID";
        _DAMErrorlog."Import from Field No." := DAMFields."From Field No.";
        _DAMErrorlog."Import to Table No." := DAMFields."To Table ID";
        _DAMErrorlog."Import to Field No." := DAMFields."To Field No.";

        _DAMErrorlog.Errortext := COPYSTR(ErrorMessage, 1, MAXSTRLEN(_DAMErrorlog.Errortext));
        _DAMErrorlog.ErrorCode := '';
        _DAMErrorlog."DAM User" := CopyStr(USERID, 1, MaxStrLen(_DAMErrorlog."DAM User"));
        _DAMErrorlog."DAM Errorlog Created At" := CURRENTDATETIME;
        _DAMErrorlog.MODIFY(TRUE);
    end;

    procedure DeleteExistingLogForBufferRec(BufferRef: RecordRef)
    var
        DAMErrorlog: Record DAMErrorLog;
    begin
        DAMErrorlog.SETRANGE("From ID", BufferRef.RECORDID);
        DAMErrorlog.DELETEALL();
    end;

    procedure ErrorsExistFor(BufferRef: RecordRef; ExcludeIgnoreErrorRecords: Boolean): Boolean
    begin
        SETRANGE("From ID", BufferRef.RECORDID);
        IF ExcludeIgnoreErrorRecords then
            SETRANGE("Ignore Error", FALSE);
        exit(NOT Rec.ISEMPTY);
    end;

    procedure OpenList()
    begin
        PAGE.RUN(PAGE::"DAM Error Log List");
    end;

    procedure OpenListWithFilter(BufferRef: RecordRef)
    begin
        OpenListWithFilter(BufferRef.RECORDID.TABLENO);
    end;

    procedure OpenListWithFilter(FromTableID: Integer)
    var
        DAMErrorLog: Record DAMErrorLog;
    begin
        DAMErrorLog.Setrange("Import from Table No.", FromTableID);
        PAGE.RUN(PAGE::"DAM Error Log List", DAMErrorlog);
    end;

    // procedure OpenListWithWithContextFilter()
    // var
    //     DAMErrorlog: Record DAMErrorlog;
    // begin
    //     DAMErrorlog.SETRANGE("DAM Context Descr.", COPYSTR(DAMSessionInfo.GetDAMContext, 1, MAXSTRLEN("DAM Context Descr.")));
    //     OpenListOnRec(DAMErrorlog);
    // end;
}