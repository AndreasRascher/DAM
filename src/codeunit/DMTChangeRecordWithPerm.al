codeunit 110009 ChangeRecordWithPerm
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                  tabledata "Dimension Set Tree Node" = rimd;

    procedure DeleteRecordsInTargetTable(DMTDataFile: Record DMTDataFile)
    var
        RecRef: RecordRef;
        DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! All Records in table "%1" (company "%2") will be deleted. Continue?',
                    Comment = 'Warnung! Alle Datensätze in Tabelle "%1" (Mandant "%2") werden gelöscht. Fortfahren?';
    begin
        DMTDataFile.TestField("Target Table ID");
        RecRef.Open(DMTDataFile."Target Table ID");
        if confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, RecRef.Caption, RecRef.CurrentCompany), false) then begin
            if not RecRef.IsEmpty then
                RecRef.DeleteAll();
        end;
    end;

    procedure InsertRecFromTmp(var TmpTargetRef: RecordRef; InsertTrue: Boolean) InsertOK: Boolean
    var
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
        DMTMgt: Codeunit DMTMgt;
    begin
        TargetRef.Open(TmpTargetRef.Number, FALSE);
        DMTMgt.CopyRecordRef(TmpTargetRef, TargetRef);

        IF TargetRef2.Get(TargetRef.RecordId) then begin
            InsertOK := TargetRef.Modify(InsertTrue);
        end else begin
            InsertOK := TargetRef.Insert(InsertTrue);
        end;
    end;
}