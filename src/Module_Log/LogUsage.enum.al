//Import to Buffer, Process Buffer, Field Update, Document Migration, Record Deletion, FieldUpdate
enum 73011 DMTLogUsage
{
    value(0; " ") { Caption = ' ', Locked = true; }
    value(10; "Information") { Caption = 'Information'; }
    value(20; "Import to Buffer Table") { Caption = 'Import to Buffer Table', Comment = 'de-DE=Import in P.'; }
    value(30; "Process Buffer - Record") { Caption = 'Process Buffer Record', Comment = 'de-DE=DS Verarbeiten'; }
    value(40; "Process Buffer - Field Update") { Caption = 'Update Fields', Comment = 'de-DE=Update'; }
    value(50; "Process Buffer - Document Migration") { Caption = 'Doc. Migration', comment = 'de-DE=Beleg Migration'; }
    value(60; "Delete Record") { Caption = 'Delete Record'; }
}