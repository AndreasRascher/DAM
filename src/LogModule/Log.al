table 110006 DMTLog
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.', comment = 'Lfd.Nr.';
            AutoIncrement = true;
        }
        field(10; LogEntryType; Enum DMTLogEntryType)
        {
            Caption = 'Log Entry Type', Comment = 'de-DE=Protokollpostenart';
        }
        field(11; "Process No."; Integer)
        {
            Caption = 'Process No.', Comment = 'de-DE=Vorgangsnr.';
        }
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