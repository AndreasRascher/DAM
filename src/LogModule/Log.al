table 110006 DMTLog
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'Lfd.Nr.';
            AutoIncrement = true;
        }
        field(10; LogEntryType; Enum DMTLogEntryType) { Caption = 'Log Entry Type', Comment = 'de-DE=Protokollpostenart'; }
        field(11; "Process No."; Integer) { Caption = 'Process No.', Comment = 'de-DE=Vorgangsnr.'; }
        field(20; "Source ID"; RecordId) { Caption = 'Source ID'; }
        field(21; "Source ID (Text)"; Text[250]) { Caption = 'Source ID (Text)'; }
        field(40; Errortext; Text[2048]) { Caption = 'Error Text', Comment = 'Fehlertext'; }
        field(41; ErrorCode; Text[250]) { Caption = 'Error Code', Comment = 'Fehler Code'; }
        field(42; ErrorCallstack; Blob) { Caption = 'Error Callstack', Comment = 'Fehler Aufrufliste'; }
        field(43; "Ignore Error"; Boolean) { Caption = 'Ignore Error', comment = 'Fehler ignorieren'; }
        field(44; "Error Field Value"; Text[250]) { Caption = 'Error Field Value', comment = 'Fehler für Feldwert'; }
        field(52; DataFilePath; Text[250]) { Caption = 'Data File Folder Path', comment = 'Ordnerpfad Exportdatei'; }
        field(53; DataFileName; Text[250]) { Caption = 'Data File Name', comment = 'Dateiname Exportdatei'; }

    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        "Process No." := CurrProcessNo;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure InitNewProcessNo(): Integer
    var
        Log: Record DMTLog;
    begin
        Log.SetLoadFields("Process No.");
        CurrProcessNo := 1;
        if Log.FindLast() then
            CurrProcessNo += 1;
        exit(CurrProcessNo);
    end;

    var
        CurrProcessNo: Integer;

}