table 73001 DMTLogEntry
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'de-DE=Lfd.Nr.';
            AutoIncrement = true;
        }
        field(10; Usage; Enum DMTLogUsage) { Caption = 'Usage', Comment = 'de-DE=Verwendung'; }
        field(11; "Process No."; Integer) { Caption = 'Process No.', Comment = 'de-DE=Vorgangsnr.'; }
        field(12; "Entry Type"; Enum DMTLogEntryType) { Caption = 'Entry Type', Comment = 'de-DE=Postenart'; }
        field(20; "Source ID"; RecordId) { Caption = 'Source ID'; }
        field(21; "Source ID (Text)"; Text[250]) { Caption = 'Source ID (Text)'; }
        field(30; "Target ID"; RecordId) { Caption = 'Target ID'; }
        field(31; "Target ID (Text)"; Text[250]) { Caption = 'Target ID (Text)'; }
        field(32; "Target Table ID"; Integer) { }
        field(33; "Target Field No."; Integer) { }
        field(40; "Context Description"; Text[2048]) { Caption = 'Context Description', Comment = 'de-DE=Kontext Beschreibung'; }
        field(41; ErrorCode; Text[250]) { Caption = 'Error Code', Comment = 'de-DE=Fehler Code'; }
        field(42; "Error Call Stack"; Blob) { Caption = 'Error Callstack', Comment = 'de-DE=Fehler Aufrufliste'; }
        field(43; "Ignore Error"; Boolean) { Caption = 'Ignore Error', comment = 'de-DE=Fehler ignorieren'; }
        field(44; "Error Field Value"; Text[250]) { Caption = 'Error Field Value', comment = 'de-DE=Fehler für Feldwert'; }
        field(50; DataFilePath; Text[250]) { Caption = 'Data File Folder Path', comment = 'de-DE=Ordnerpfad Exportdatei'; }
        field(51; DataFileName; Text[250]) { Caption = 'Data File Name', comment = 'de-DE=Dateiname Exportdatei'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }

    procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not Rec."Error Call Stack".HasValue() then
            exit('');
        CalcFields("Error Call Stack");
        "Error Call Stack".CreateInStream(InStream, TextEncoding::Windows);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    procedure SetErrorCallStack(NewCallStack: Text)
    var
        OutStream: OutStream;
    begin
        "Error Call Stack".CreateOutStream(OutStream, TextEncoding::Windows);
        OutStream.Write(NewCallStack);
    end;

    procedure GetNextProcessNo() NextEntryNo: Integer
    var
        LogEntry: Record DMTLogEntry;
    begin
        NextEntryNo := 1;
        LogEntry.SetLoadFields("Process No.");
        if LogEntry.FindLast() then
            NextEntryNo += LogEntry."Process No.";
    end;

    internal procedure FilterFor(Datafile: Record DMTDataFile) HasLinesInFilter: Boolean
    begin
        Rec.SetRange("Target Table ID", Datafile."Target Table ID");
        Rec.SetRange(DataFilePath, Datafile.Path);
        Rec.SetRange(DataFileName, Datafile.Name);
        HasLinesInFilter := not Rec.IsEmpty;
    end;

}