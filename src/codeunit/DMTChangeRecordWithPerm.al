codeunit 110009 ChangeRecordWithPerm
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                  tabledata "Dimension Set Tree Node" = rimd;

    procedure DeleteRecordsInTargetTable(DMTDataFile: Record DMTDataFile)
    var
        DMTCopyTable: Record DMTCopyTable;
        RecRef: RecordRef;
        DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! %1 Records in table "%2" (company "%3") will be deleted. Continue?\Filter:"%4"',
                    Comment = 'Warnung! %1 Datensätze in Tabelle "%2" (Mandant "%3") werden gelöscht. Fortfahren?\Filter:"%4"';
    begin
        DMTDataFile.TestField("Target Table ID");
        RecRef.Open(DMTDataFile."Target Table ID");
        if DMTCopyTable.ShowRequestPageFilterDialog(RecRef) then
            if Confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, RecRef.Count, RecRef.Caption, RecRef.CurrentCompany, RecRef.GetFilters), false) then begin
                if not RecRef.IsEmpty then
                    RecRef.DeleteAll();
            end;
    end;

    procedure InsertRecFromTmp(var TmpTargetRef: RecordRef; InsertTrue: Boolean) InsertOK: Boolean
    var
        DMTMgt: Codeunit DMTMgt;
        TargetRef: RecordRef;
        TargetRef2: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        DMTMgt.CopyRecordRef(TmpTargetRef, TargetRef);

        if TargetRef2.Get(TargetRef.RecordId) then begin
            InsertOK := TargetRef.Modify(InsertTrue);
        end else begin
            InsertOK := TargetRef.Insert(InsertTrue);
        end;
    end;
}