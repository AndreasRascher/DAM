//Import to Buffer, Process Buffer, Field Update, Document Migration, Record Deletion, FieldUpdate
enum 110000 DMTLogEntryType
{
    Extensible = true;

    value(0; " ") { Caption = ' ', Locked = true; }
    value(10; "Import to Buffer") { Caption = ''; }
    value(20; "Process Buffer - Record OK") { Caption = ''; }
    value(21; "Process Buffer - Record Error") { Caption = ''; }
    value(30; "Process Buffer - Field Update") { Caption = ''; }
    value(40; "Process Buffer - Document Migration") { Caption = ''; }
    value(50; "Delete Record") { Caption = ''; }
}