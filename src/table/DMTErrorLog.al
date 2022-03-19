table 91003 "DMTErrorLog"
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
        field(40; Errortext; Text[2048]) { CaptionML = DEU = 'Fehlertext'; }
        field(41; ErrorCode; Text[250]) { CaptionML = DEU = 'Fehler Code'; }
        field(42; "Ignore Error"; Boolean) { CaptionML = DEU = 'Fehler ignorieren'; }
        field(60; "DMT User"; Text[250]) { CaptionML = DEU = 'DMT Benutzer', ENU = 'DMT User'; Editable = false; }
        field(70; "DMT Errorlog Created At"; DateTime) { CaptionML = DEU = 'DMT Datum der Protokollierung', ENU = 'DMT Date of Errorlog'; }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure AddEntryForLastError(FromRecRef: recordref; ToRecRef: RecordRef; DMTFields: Record "DMTField");
    var
        _DMTErrorlog: Record DMTErrorLog;
    begin

        _DMTErrorlog."From ID" := FromRecRef.RecordId;
        _DMTErrorlog."To ID" := ToRecRef.RecordId;
        _DMTErrorlog."From ID (Text)" := CopyStr(Format(_DMTErrorlog."From ID"), 1, MaxStrLen(_DMTErrorlog."From ID (Text)"));
        _DMTErrorlog."To ID (Text)" := CopyStr(Format(_DMTErrorlog."to ID"), 1, MaxStrLen(_DMTErrorlog."To ID (Text)"));

        _DMTErrorlog."Import from Table No." := DMTFields."From Table ID";
        _DMTErrorlog."Import from Field No." := DMTFields."From Field No.";
        _DMTErrorlog."Import to Table No." := DMTFields."To Table No.";
        _DMTErrorlog."Import to Field No." := DMTFields."To Field No.";
        _DMTErrorlog."Ignore Error" := DMTFields."Ignore Validation Error";

        _DMTErrorlog.Errortext := COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(GETLASTERRORCODE, 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."DMT User" := CopyStr(USERID, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CURRENTDATETIME;
        _DMTErrorlog.INSERT(TRUE);
    end;

    procedure AddEntryForLastError(ToRecRef: RecordRef; ToFieldNo: Integer; IgnoreError: Boolean);
    var
        _DMTErrorlog: Record DMTErrorLog;
    begin
        _DMTErrorlog.INSERT(TRUE);
        _DMTErrorlog."To ID" := ToRecRef.RecordId;
        _DMTErrorlog."Import to Table No." := ToRecRef.Number;
        _DMTErrorlog."Import to Field No." := ToFieldNo;
        _DMTErrorlog."Ignore Error" := IgnoreError;

        _DMTErrorlog.Errortext := COPYSTR(GETLASTERRORTEXT, 1, MAXSTRLEN(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(GETLASTERRORCODE, 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."DMT User" := CopyStr(USERID, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CURRENTDATETIME;
        _DMTErrorlog.MODIFY(TRUE);
    end;

    procedure AddEntryWithUserDefinedMessage(DMTFields: Record "DMTField"; ErrorMessage: text)
    var
        _DMTErrorlog: Record DMTErrorLog;
    begin
        _DMTErrorlog.INSERT(TRUE);
        _DMTErrorlog."Import from Table No." := DMTFields."From Table ID";
        _DMTErrorlog."Import from Field No." := DMTFields."From Field No.";
        _DMTErrorlog."Import to Table No." := DMTFields."To Table No.";
        _DMTErrorlog."Import to Field No." := DMTFields."To Field No.";

        _DMTErrorlog.Errortext := COPYSTR(ErrorMessage, 1, MAXSTRLEN(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := '';
        _DMTErrorlog."DMT User" := CopyStr(USERID, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CURRENTDATETIME;
        _DMTErrorlog.MODIFY(TRUE);
    end;

    procedure DeleteExistingLogForBufferRec(BufferRef: RecordRef)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.SETRANGE("From ID", BufferRef.RECORDID);
        DMTErrorlog.DELETEALL();
    end;

    procedure ErrorsExistFor(BufferRef: RecordRef; ExcludeIgnoreErrorRecords: Boolean): Boolean
    begin
        SETRANGE("From ID", BufferRef.RecordId);
        IF ExcludeIgnoreErrorRecords then
            SETRANGE("Ignore Error", FALSE);
        exit(not Rec.IsEmpty);
    end;

    procedure ErrorsExistFor(DMTField: Record "DMTField"; ExcludeIgnoreErrorRecords: Boolean): Boolean
    begin
        SetRange("Import to Table No.", DMTField."To Table No.");
        SETRANGE("Import to Field No.", DMTField."To Field No.");
        IF ExcludeIgnoreErrorRecords then
            SETRANGE("Ignore Error", FALSE);
        exit(not Rec.IsEmpty);
    end;

    procedure OpenList()
    begin
        PAGE.RUN(PAGE::"DMT Error Log List");
    end;

    procedure OpenListWithFilter(DMTTable: Record DMTTable)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.Setrange("Import to Table No.", DMTTable."To Table ID");
        PAGE.RUN(PAGE::"DMT Error Log List", DMTErrorlog);
    end;

    // procedure OpenListWithWithContextFilter()
    // var
    //     DMTErrorlog: Record DMTErrorlog;
    // begin
    //     DMTErrorlog.SETRANGE("DMT Context Descr.", COPYSTR(DMTSessionInfo.GetDMTContext, 1, MAXSTRLEN("DMT Context Descr.")));
    //     OpenListOnRec(DMTErrorlog);
    // end;
}