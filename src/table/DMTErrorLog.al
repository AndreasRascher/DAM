table 110001 "DMTErrorLog"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'Lfd.Nr.';
            AutoIncrement = true;
        }
        field(10; "From ID"; RecordId)
        {
            Caption = 'Import from Record ID', comment = 'Import von Record ID';
        }
        field(11; "To ID"; RecordId)
        {
            Caption = 'Import to Record ID', comment = 'Import nach Record ID';
        }
        field(12; "From ID (Text)"; Text[250])
        {
            Caption = 'Import from Record ID (Text)', comment = 'Import von Record ID (Text)';
        }
        field(13; "To ID (Text)"; Text[250])
        {
            Caption = 'Import to Record ID (Text)', comment = 'Import nach Record ID (Text)';
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
        field(40; Errortext; Text[2048]) { Caption = 'Error Text', Comment = 'Fehlertext'; }
        field(41; ErrorCode; Text[250]) { Caption = 'Error Code', Comment = 'Fehler Code'; }
        field(42; "Ignore Error"; Boolean) { Caption = 'Ignore Error', comment = 'Fehler ignorieren'; }
        field(60; "DMT User"; Text[250]) { Caption = 'DMT User', comment = 'DMT Benutzer'; Editable = false; }
        field(70; "DMT Errorlog Created At"; DateTime) { Caption = 'Errorlog Created At', comment = 'Datum der Protokollierung'; }
        field(52; DataFileFolderPath; Text[250]) { Caption = 'Data File Folder Path', comment = 'Ordnerpfad Exportdatei'; }
        field(53; DataFileName; Text[250]) { Caption = 'Data File Name', comment = 'Dateiname Exportdatei'; }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "From ID") { }
    }

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
        _DMTErrorlog.modify(true);
    end;

    procedure DeleteExistingLogForBufferRec(BufferRef: RecordRef)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.SetRange("From ID", BufferRef.RecordId);
        if not DMTErrorlog.IsEmpty then // Avoid Tablelocks
            DMTErrorlog.DeleteAll();
    end;

    procedure ErrorsExistFor(BufferRef: RecordRef; ExcludeIgnoreErrorRecords: Boolean): Boolean
    begin
        SETRANGE("From ID", BufferRef.RecordId);
        IF ExcludeIgnoreErrorRecords then
            SETRANGE("Ignore Error", FALSE);
        exit(not Rec.IsEmpty);
    end;

    procedure OpenListWithFilter(DataFile: Record DMTDataFile; OpenOnlyIfNotEmpty: Boolean)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.Setrange("Import to Table No.", DataFile."Target Table ID");
        if OpenOnlyIfNotEmpty then
            if DMTErrorLog.IsEmpty then
                exit;
        Page.Run(Page::"DMT Error Log List", DMTErrorlog);
    end;
}