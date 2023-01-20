table 110001 DMTErrorLog
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
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Import to Table No."), "No." = field("Import to Field No.")));
        }
        field(30; "Import to Table No."; Integer) { }
        field(31; "Import to Field No."; Integer) { }
        field(32; "To Field Caption"; Text[250])
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Import to Table No."), "No." = field("Import to Field No.")));
        }
        field(40; Errortext; Text[2048]) { Caption = 'Error Text', Comment = 'Fehlertext'; }
        field(41; ErrorCode; Text[250]) { Caption = 'Error Code', Comment = 'Fehler Code'; }
        field(42; ErrorCallstack; Blob) { Caption = 'Error Callstack', Comment = 'Fehler Aufrufliste'; }
        field(43; "Ignore Error"; Boolean) { Caption = 'Ignore Error', comment = 'Fehler ignorieren'; }
        field(44; "Error Field Value"; Text[250]) { Caption = 'Error Field Value', comment = 'Fehler für Feldwert'; }
        field(52; DataFilePath; Text[250]) { Caption = 'Data File Folder Path', comment = 'Ordnerpfad Exportdatei'; }
        field(53; DataFileName; Text[250]) { Caption = 'Data File Name', comment = 'Dateiname Exportdatei'; }
        field(60; "DMT User"; Text[250]) { Caption = 'DMT User', comment = 'DMT Benutzer'; Editable = false; }
        field(70; "DMT Errorlog Created At"; DateTime) { Caption = 'Errorlog Created At', comment = 'Datum der Protokollierung'; }
        field(80; "Frequency (Summary)"; Integer) { Caption = 'Frequency', Comment = 'Häufigkeit'; }
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
        _DMTErrorlog.Insert(true);
        _DMTErrorlog."To ID" := ToRecRef.RecordId;
        _DMTErrorlog."Import to Table No." := ToRecRef.Number;
        _DMTErrorlog."Import to Field No." := ToFieldNo;
        _DMTErrorlog."Ignore Error" := IgnoreError;

        _DMTErrorlog.Errortext := CopyStr(GetLastErrorText, 1, MaxStrLen(_DMTErrorlog.Errortext));
        _DMTErrorlog.ErrorCode := CopyStr(GetLastErrorCode, 1, MaxStrLen(_DMTErrorlog.ErrorCode));
        _DMTErrorlog."DMT User" := CopyStr(UserId, 1, MaxStrLen(_DMTErrorlog."DMT User"));
        _DMTErrorlog."DMT Errorlog Created At" := CurrentDateTime;
        _DMTErrorlog.Modify(true);
    end;

    procedure DeleteExistingLogFor(BufferRef: RecordRef)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.SetRange("From ID", BufferRef.RecordId);
        if not DMTErrorlog.IsEmpty then // Avoid Tablelocks
            DMTErrorlog.DeleteAll();
    end;

    procedure DeleteExistingLogFor(DataFile: Record DMTDataFile)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DataFile.TestField(Name);
        DataFile.TestField(Path);
        DMTErrorlog.SetRange(DataFileName, DataFile.Name);
        DMTErrorlog.SetRange(DataFilePath, DataFile.Path);
        if not DMTErrorlog.IsEmpty then // Avoid Tablelocks
            DMTErrorlog.DeleteAll();
    end;

    procedure OpenListWithFilter(DataFile: Record DMTDataFile; OpenOnlyIfNotEmpty: Boolean)
    var
        DMTErrorlog: Record DMTErrorLog;
    begin
        DMTErrorlog.SetRange("Import to Table No.", DataFile."Target Table ID");
        if OpenOnlyIfNotEmpty then
            if DMTErrorlog.IsEmpty then
                exit;
        Page.Run(Page::"DMT Error Log List", DMTErrorlog);
    end;

    procedure ShowSummary()
    var
        DataFile: Record DMTDataFile;
        ErrorLog: Record DMTErrorLog;
        TempErrorLog: Record DMTErrorLog temporary;
        ErrorSummary: Query DMTErrorSummary;
        EntryNo: Integer;
    begin

        ErrorLog.Copy(Rec);
        if ErrorLog.FindSet() then begin
            DataFile.GetRecByFilePath(ErrorLog.DataFilePath, ErrorLog.DataFileName);
            ErrorSummary.SetRange(DataFileName, DataFile.Name);
            ErrorSummary.SetRange(DataFileFolderPath, DataFile.Path);
            ErrorSummary.Open();
            while ErrorSummary.Read() do begin
                EntryNo += 1;
                // if FieldMapping.get(DataFile.ID, ErrorSummary.ImportToFieldNo) then begin
                //     FieldMapping.CalcFields("Target Field Caption");
                //     TempErrorLog."To Field Caption" := FieldMapping."Target Field Caption";
                // end;
                TempErrorLog."Entry No." := EntryNo;
                TempErrorLog.DataFilePath := ErrorSummary.DataFileFolderPath;
                TempErrorLog.DataFileName := ErrorSummary.DataFileName;
                TempErrorLog."Import to Table No." := ErrorSummary.ImporttoTableNo;
                TempErrorLog."Import to Field No." := ErrorSummary.ImportToFieldNo;
                TempErrorLog."Frequency (Summary)" := ErrorSummary.NoOfErrorsByValue;
                TempErrorLog."Error Field Value" := ErrorSummary.ErrorFieldValue;
                TempErrorLog.ErrorCode := ErrorSummary.ErrorCode;
                TempErrorLog.Insert();
            end;
        end;
        Page.Run(Page::DMTErrorLogSummary, TempErrorLog);
    end;

    procedure ReadErrorCallStack() ErrorCallStack: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(ErrorCallstack);
        if not Rec.ErrorCallstack.HasValue then exit('');
        Rec.ErrorCallstack.CreateInStream(IStr);
        IStr.ReadText(ErrorCallStack);
    end;

    procedure SaveErrorCallStack(ErrorCallStackNew: Text; DoModify: Boolean)
    var
        OStr: OutStream;
    begin
        Clear(Rec.ErrorCallstack);
        if DoModify then Rec.Modify();
        if ErrorCallStackNew = '' then
            exit;
        Rec.ErrorCallstack.CreateOutStream(OStr);
        OStr.WriteText(ErrorCallStackNew);
        if DoModify then Rec.Modify();
    end;
}