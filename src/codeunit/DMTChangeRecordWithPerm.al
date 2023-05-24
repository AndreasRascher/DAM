codeunit 73001 ChangeRecordWithPerm
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                  tabledata "Dimension Set Tree Node" = rimd;

    procedure DeleteRecordsInTargetTable(DMTDataFile: Record DMTDataFile)
    var
        DMTDeleteDatainTargetTable: Page DMTDeleteDataInTargetTable;
    begin
        DMTDeleteDatainTargetTable.SetDataFileID(DMTDataFile);
        DMTDeleteDatainTargetTable.Run();
    end;


    procedure InsertOrOverwriteRecFromTmp(var TmpTargetRef: RecordRef; InsertTrue: Boolean) InsertOK: Boolean
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

    procedure ModifyRecFromTmp(var TmpTargetRef: RecordRef; UseTrigger: Boolean) InsertOK: Boolean
    var
        DMTMgt: Codeunit DMTMgt;
        TargetRef: RecordRef;
    begin
        TargetRef.Open(TmpTargetRef.Number, false);
        DMTMgt.CopyRecordRef(TmpTargetRef, TargetRef);
        InsertOK := TargetRef.Modify(UseTrigger);
    end;
}