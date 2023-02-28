page 110024 DMTDeleteDataInTargetTable
{
    Caption = 'Delete Data in Target Table', Comment = 'Daten in Zieltabelle löschen';
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(SourceTableView; SourceFilterGlobal)
                {
                    Caption = 'Source Table Filter';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        EditSourceTableView(SourceViewGlobal, SourceFilterGlobal, CurrDataFile);
                    end;
                }
                field(TargetTableFilter; TargetFilterGlobal)
                {
                    Caption = 'Target Table Filter';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        EditTargetTableFilter(TargetViewGlobal, TargetFilterGlobal, CurrDataFile);
                    end;
                }
                field(UseOnDeleteTriggerCtrl; UseOnDeleteTriggerGlobal) { Caption = 'Use On Delete Trigger'; ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartDeletingCtrl)
            {
                ApplicationArea = All;
                Caption = 'Start';
                Image = Start;
                trigger OnAction();
                begin
                    if (SourceViewGlobal <> '') or (TargetViewGlobal <> '') then
                        FindRecordIdsInCombinedView(SourceViewGlobal, TargetViewGlobal, CurrDataFile, UseOnDeleteTriggerGlobal)
                    else
                        DeleteFullTable(CurrDataFile, UseOnDeleteTriggerGlobal)
                end;
            }
        }
    }

    trigger OnInit()
    begin
        UseOnDeleteTriggerGlobal := true;
    end;

    procedure EditSourceTableView(var sourceView: Text; var sourceFilter: Text; dataFile: Record DMTDataFile)
    var
        FPBuilder: Codeunit DMTFPBuilder;
        BufferRef: RecordRef;
    begin
        InitBufferRef(dataFile, BufferRef);
        if sourceView <> '' then
            BufferRef.SetView(sourceView);
        if not FPBuilder.RunModal(BufferRef, dataFile, true) then
            exit;
        sourceView := BufferRef.GetView();
        sourceFilter := BufferRef.GetFilters;
    end;

    procedure EditTargetTableFilter(var targetView: Text; var targetFilter: Text; dataFile: Record DMTDataFile)
    var
        FPBuilder: Codeunit DMTFPBuilder;
        RecRef: RecordRef;
    begin
        RecRef.Open(dataFile."Target Table ID");
        if targetView <> '' then
            RecRef.SetView(targetView);
        if FPBuilder.RunModal(RecRef, true) then begin
            targetView := RecRef.GetView();
            targetFilter := RecRef.GetFilters;
        end;
    end;

    local procedure InitBufferRef(DataFile: Record DMTDataFile; var BufferRef: RecordRef)
    var
        GenBuffTable: Record DMTGenBuffTable;
    begin
        if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
            // GenBuffTable.InitFirstLineAsCaptions(DMTDataFile);
            GenBuffTable.FilterGroup(2);
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterBy(DataFile);
            GenBuffTable.FilterGroup(0);
            BufferRef.GetTable(GenBuffTable);
        end else
            if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then begin
                BufferRef.Open(DataFile."Buffer Table ID");
            end;
    end;

    local procedure CreateSourceToTargetRecIDMapping(DataFile: Record DMTDataFile; SourceView: Text; var NotTransferedRecords: List of [RecordId]) RecordMapping: Dictionary of [RecordId, RecordId]
    var
        DMTMgt: Codeunit DMTMgt;
        TempFieldMapping: Record DMTFieldMapping temporary;
        DMTGenBuffTable: Record DMTGenBuffTable;
        SourceRef, TargetRef : RecordRef;
        TargetRecID: RecordId;
    begin
        Clear(NotTransferedRecords);
        Clear(RecordMapping);

        DataFile.LoadFieldMapping(TempFieldMapping);
        // FindSourceRef - GenBuffer
        if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
            if not DMTGenBuffTable.FindSetLinesByFileNameWithoutCaptionLine(DataFile) then
                exit;
            SourceRef.GetTable(DMTGenBuffTable);
            if SourceRef.IsEmpty then
                exit;
        end;
        // FindSourceRef - CSVBuffer
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then begin
            SourceRef.Open(DataFile."Buffer Table ID");
            if SourceRef.IsEmpty then
                exit;
        end;
        // Map RecordIDs
        if SourceView <> '' then
            SourceRef.SetView(SourceView);
        SourceRef.FindSet(false, false);
        repeat
            TargetRecID := DMTMgt.GetTargetRefRecordID(DataFile, SourceRef, TempFieldMapping);
            if not TargetRef.Get(TargetRecID) then begin
                NotTransferedRecords.Add(TargetRecID)
            end else begin
                RecordMapping.Add(SourceRef.RecordId, TargetRecID);
            end;
        until SourceRef.Next() = 0;
    end;

    local procedure FindRecordIdsInCombinedView(sourceView: Text; targetView: Text; dataFile: Record DMTDataFile; useOnDeleteTrigger: Boolean)
    var
        RecID: RecordId;
        TargetRef: RecordRef;
        SourceToTargetRecordMapping: Dictionary of [RecordId, RecordId];
        NotTransferedRecords: List of [RecordId];
        TargetRecordIDsToDelete: List of [RecordId];
    begin
        dataFile.CalcFields("Target Table Caption");
        // Create RecordID Mapping between Buffer and Target Table
        if sourceView <> '' then begin
            SourceToTargetRecordMapping := CreateSourceToTargetRecIDMapping(dataFile, sourceView, NotTransferedRecords);
            TargetRecordIDsToDelete := SourceToTargetRecordMapping.Values;
            // Remove TargetRecordID not in Filter
            if targetView <> '' then begin
                foreach RecID in TargetRecordIDsToDelete do begin
                    if not IsRecIDInView(RecID, targetView) then begin
                        TargetRecordIDsToDelete.Remove(RecID);
                    end;
                end;
            end;
        end else begin
            // Read all RecordIDs from Target
            TargetRef.Open(dataFile."Target Table ID");
            TargetRef.SetView(targetView);
            if TargetRef.FindSet(false, false) then
                repeat
                    TargetRecordIDsToDelete.Add(TargetRef.RecordId);
                until TargetRef.Next() = 0;
        end;

        DeleteRecordsInList(dataFile, useOnDeleteTrigger, TargetRecordIDsToDelete);
    end;

    local procedure IsRecIDInView(RecID: RecordId; TableView: Text) Result: Boolean;
    var
        RecRef: RecordRef;
    begin
        if TableView = '' then exit(true);
        RecRef.Get(RecID);
        RecRef.SetView(TableView);
        Result := RecRef.FindFirst();
    end;

    local procedure ConfirmDeletion(NoOfLinesToDelete: Integer; TableCaption: Text) OK: Boolean
    var
        DeleteAllRecordsInTargetTableWarningMsg: Label 'Warning! %1 Records in table "%2" (company "%3") will be deleted. Continue?',
                                             Comment = 'Warnung! %1 Datensätze in Tabelle "%2" (Mandant "%3") werden gelöscht. Fortfahren?';
    begin
        OK := Confirm(StrSubstNo(DeleteAllRecordsInTargetTableWarningMsg, NoOfLinesToDelete, TableCaption, CompanyName), false);
    end;

    local procedure DeleteFullTable(dataFile: Record DMTDataFile; useOnDeleteTrigger: Boolean)
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        Log: Codeunit DMTLog;
        RecRef: RecordRef;
        MaxSteps: Integer;
    begin
        dataFile.TestField("Target Table ID");
        RecRef.Open(dataFile."Target Table ID");
        MaxSteps := RecRef.Count;
        if ConfirmDeletion(MaxSteps, RecRef.Caption) then begin
            if RecRef.FindSet() then begin
                Log.InitNewProcess(Enum::DMTLogUsage::"Delete Record", dataFile);
                DeleteRecordsWithErrorLog.DialogOpen(RecRef.Caption + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
                repeat
                    if not DeleteRecordsWithErrorLog.DialogUpdate(1, Log.GetProgress(MaxSteps), 2, StrSubstNo('%1/%2', Log.GetNoOfProcessedRecords(), MaxSteps), 3, RecRef.RecordId) then begin
                        Error('Process Stopped');
                    end;
                    Commit();
                    DeleteSingeRecordWithLog(dataFile, useOnDeleteTrigger, Log, RecRef.RecordId);
                until RecRef.Next() = 0;
                Log.CreateSummary();
                Log.ShowLogForCurrentProcess();
            end;
        end;
    end;

    local procedure DeleteRecordsInList(var dataFile: Record DMTDataFile; useOnDeleteTrigger: Boolean; var TargetRecordIDsToDelete: List of [RecordId])
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        Log: Codeunit DMTLog;
        RecID: RecordId;
        MaxSteps: Integer;
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Delete Record", dataFile);
        MaxSteps := TargetRecordIDsToDelete.Count;
        dataFile.CalcFields("Target Table Caption");
        if ConfirmDeletion(MaxSteps, dataFile."Target Table Caption") then begin
            DeleteRecordsWithErrorLog.DialogOpen(dataFile."Target Table Caption" + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
            foreach RecID in TargetRecordIDsToDelete do begin
                if not DeleteRecordsWithErrorLog.DialogUpdate(1, Log.GetProgress(MaxSteps), 2, StrSubstNo('%1/%2', Log.GetNoOfProcessedRecords(), MaxSteps), 3, RecID) then begin
                    Error(format(Enum::DMTErrMsg::"Process Stopped"));
                end;
                Commit();
                DeleteSingeRecordWithLog(dataFile, useOnDeleteTrigger, Log, RecID);
            end;
            Log.CreateSummary();
            Log.ShowLogForCurrentProcess();
        end;
    end;

    local procedure DeleteSingeRecordWithLog(var dataFile: Record DMTDataFile; useOnDeleteTrigger: Boolean; var log: Codeunit DMTLog; recID: RecordId)
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
    begin
        DeleteRecordsWithErrorLog.InitRecordToDelete(recID, useOnDeleteTrigger);
        Log.IncNoOfProcessedRecords();
        if DeleteRecordsWithErrorLog.Run() then begin
            log.AddTargetSuccessEntry(recID, dataFile);
            log.IncNoOfSuccessfullyProcessedRecords();
            log.IncNoOfProcessedRecords();
        end else begin
            log.AddTargetErrorByIDEntry(recID, dataFile, log.CreateErrorItem());
            log.IncNoOfRecordsWithErrors();
            ClearLastError();
        end;
    end;

    procedure SetDataFileID(DataFile: Record DMTDataFile)
    begin
        CurrDataFile := DataFile;
    end;

    var
        CurrDataFile: Record DMTDataFile;
        UseOnDeleteTriggerGlobal: Boolean;
        SourceViewGlobal, TargetViewGlobal, SourceFilterGlobal, TargetFilterGlobal : Text;
}