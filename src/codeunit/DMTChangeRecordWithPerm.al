codeunit 110009 ChangeRecordWithPerm
{
    Permissions = tabledata "Dimension Set Entry" = rimd,
                  tabledata "Dimension Set Tree Node" = rimd;

    procedure DeleteRecordsInTargetTable(DMTDataFile: Record DMTDataFile)
    var
        DMTCopyTable: Record DMTCopyTable;
        DMTDeleteDatainTargetTable: Page DMTDeleteDatainTargetTable;
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        RecRef: RecordRef;
        UseOnDeleteTrigger: Boolean;
        MaxSteps, StepCount : Integer;
        DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! %1 Records in table "%2" (company "%3") will be deleted. Continue?\Filter:"%4"',
                    Comment = 'Warnung! %1 Datensätze in Tabelle "%2" (Mandant "%3") werden gelöscht. Fortfahren?\Filter:"%4"';
        UseOnDeleteTriggerQst: Label 'Run with OnDelete Trigger?',
                    Comment = 'Mit OnDelete Triggern ausführen?';
    begin
        DMTDeleteDatainTargetTable.SetDataFileID(DMTDataFile);
        DMTDeleteDatainTargetTable.Run();

        // DMTDataFile.TestField("Target Table ID");
        // RecRef.Open(DMTDataFile."Target Table ID");
        // if DMTCopyTable.ShowRequestPageFilterDialog(RecRef) then begin
        //     UseOnDeleteTrigger := Confirm(UseOnDeleteTriggerQst, false);
        //     if Confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, RecRef.Count, RecRef.Caption, RecRef.CurrentCompany, RecRef.GetFilters), false) then begin
        //         if RecRef.FindSet() then begin
        //             MaxSteps := RecRef.Count;
        //             DeleteRecordsWithErrorLog.DialogOpen(RecRef.Caption + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
        //             repeat
        //                 if not DeleteRecordsWithErrorLog.DialogUpdate(1, DeleteRecordsWithErrorLog.CalcProgress(StepCount, MaxSteps), 2, StrSubstNo('%1/%2', StepCount, MaxSteps), 3, RecRef.RecordId) then begin
        //                     DeleteRecordsWithErrorLog.showErrors();
        //                     Error('Process Stopped');
        //                 end;
        //                 StepCount += 1;
        //                 Commit();
        //                 DeleteRecordsWithErrorLog.InitRecordToDelete(RecRef.RecordId, UseOnDeleteTrigger);
        //                 if not DeleteRecordsWithErrorLog.Run() then
        //                     DeleteRecordsWithErrorLog.LogLastError();
        //             until RecRef.Next() = 0;
        //             DeleteRecordsWithErrorLog.showErrors();
        //         end;
        //     end;
        // end;
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