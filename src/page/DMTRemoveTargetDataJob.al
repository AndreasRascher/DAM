page 110024 DMTDeleteDatainTargetTable
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
                field(SourceTableView; SourceTableFilter)
                {
                    Caption = 'Source Table Filter';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        EditSourceTableView();
                    end;
                }
                field(TargetTableFilter; TargetTableFilter)
                {
                    Caption = 'Target Table Filter';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        EditTargetTableFilter();
                    end;
                }
                field(UseOnDeleteTrigger; UseOnDeleteTrigger) { Caption = 'Use On Delete Trigger'; ApplicationArea = All; }
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
                    if (TargetTableView <> '') or (SourceTableView <> '') then
                        StartDeletingWithTableView()
                    else
                        DeleteFullTable()
                end;
            }
        }
    }

    trigger OnInit()
    begin
        UseOnDeleteTrigger := true;
    end;

    procedure EditSourceTableView()
    var
        FPBuilder: Codeunit DMTFPBuilder;
        BufferRef: RecordRef;
    begin
        InitBufferRef(CurrDataFile, BufferRef);
        if SourceTableView <> '' then
            BufferRef.SetView(SourceTableView);
        if not FPBuilder.RunModal(BufferRef, CurrDataFile, true) then
            exit;
        SourceTableView := BufferRef.GetView();
        SourceTableFilter := BufferRef.GetFilters;
    end;

    procedure EditTargetTableFilter()
    var
        DMTCopyTable: Record DMTCopyTable;
        FPBuilder: Codeunit DMTFPBuilder;
        RecRef: RecordRef;
    begin
        RecRef.Open(CurrDataFile."Target Table ID");
        if TargetTableView <> '' then
            RecRef.SetView(TargetTableView);
        if FPBuilder.RunModal(RecRef, true) then begin
            TargetTableView := RecRef.GetView();
            TargetTableFilter := RecRef.GetFilters;
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
        TempFieldMapping: Record DMTFieldMapping temporary;
        DMTGenBuffTable: Record DMTGenBuffTable;
        SourceRef, TmpTargetRef : RecordRef;
        TargetRef: RecordRef;
    begin
        Clear(NotTransferedRecords);
        Clear(RecordMapping);

        LoadFieldMapping(DataFile, TempFieldMapping);
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
            Clear(TmpTargetRef);
            TmpTargetRef.Open(DataFile."Target Table ID", true);
            AssignKeyFields(SourceRef, TmpTargetRef, TempFieldMapping);
            if not TargetRef.Get(TmpTargetRef.RecordId) then begin
                NotTransferedRecords.Add(TmpTargetRef.RecordId)
            end else begin
                RecordMapping.Add(SourceRef.RecordId, TmpTargetRef.RecordId);
            end;
        until SourceRef.Next() = 0;
    end;

    local procedure LoadFieldMapping(DataFile: Record DMTDataFile; var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
    begin
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
            FieldMapping.SetFilter("Source Field No.", '<>0');
        FieldMapping.CopyToTemp(TempFieldMapping);
        OK := TempFieldMapping.FindFirst();
    end;

    local procedure AssignKeyFields(SourceRef: RecordRef; var TmpTargetRef: RecordRef; var TmpFieldMapping: Record DMTFieldMapping temporary)
    var
        DMTMgt: Codeunit DMTMgt;
        ToFieldRef: FieldRef;
    begin
        if not TmpTargetRef.IsTemporary then
            Error('AssignKeyFields - Temporay Record expected');
        TmpFieldMapping.Reset();
        TmpFieldMapping.SetRange("Is Key Field(Target)", true);
        TmpFieldMapping.FindSet();
        repeat

            case TmpFieldMapping."Processing Action" of
                TmpFieldMapping."Processing Action"::Ignore:
                    ;
                TmpFieldMapping."Processing Action"::Transfer:
                    DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, SourceRef, TmpFieldMapping, false);
                TmpFieldMapping."Processing Action"::FixedValue:
                    begin
                        ToFieldRef := TmpTargetRef.Field(TmpFieldMapping."Target Field No.");
                        DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TmpFieldMapping."Fixed Value");
                    end;
            end;
        until TmpFieldMapping.Next() = 0;
    end;

    local procedure StartDeletingWithTableView()
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        RecID: RecordId;
        RecordMapping, RecordMapping2 : Dictionary of [RecordId, RecordId];
        MaxSteps, StepCount : Integer;
        NotTransferedRecords: List of [RecordId];
    begin
        // Create RecordID Mapping between Buffer and Target Table
        RecordMapping := CreateSourceToTargetRecIDMapping(CurrDataFile, SourceTableView, NotTransferedRecords);
        // Remove TargetRecordID not in Filter
        if TargetTableView <> '' then begin
            RecordMapping2 := RecordMapping;
            foreach RecID in RecordMapping2.Values do begin
                if not IsRecIDInView(RecID, TargetTableView) then begin
                    RecordMapping2.Remove(RecID);
                end;
            end;
            RecordMapping := RecordMapping2;
        end;
        MaxSteps := RecordMapping.Values.Count;
        CurrDataFile.CalcFields("Target Table Caption");
        if ConfirmDeletion(MaxSteps, CurrDataFile."Target Table Caption") then begin
            DeleteRecordsWithErrorLog.DialogOpen(CurrDataFile."Target Table Caption" + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
            foreach RecID in RecordMapping.Values do begin
                if not DeleteRecordsWithErrorLog.DialogUpdate(1, DeleteRecordsWithErrorLog.CalcProgress(StepCount, MaxSteps), 2, StrSubstNo('%1/%2', StepCount, MaxSteps), 3, RecID) then begin
                    DeleteRecordsWithErrorLog.showErrors();
                    Error('Process Stopped');
                end;
                StepCount += 1;
                Commit();
                DeleteRecordsWithErrorLog.InitRecordToDelete(RecID, UseOnDeleteTrigger);
                if not DeleteRecordsWithErrorLog.Run() then
                    DeleteRecordsWithErrorLog.LogLastError();
            end;
            DeleteRecordsWithErrorLog.showErrors();
        end;
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

    local procedure DeleteFullTable()
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        RecRef: RecordRef;
        MaxSteps, StepCount : Integer;
    begin
        CurrDataFile.TestField("Target Table ID");
        RecRef.Open(CurrDataFile."Target Table ID");
        MaxSteps := RecRef.Count;
        if ConfirmDeletion(MaxSteps, RecRef.Caption) then begin
            if RecRef.FindSet() then begin
                DeleteRecordsWithErrorLog.DialogOpen(RecRef.Caption + ' @@@@@@@@@@@@@@@@@@1@\######2#\######3#');
                repeat
                    if not DeleteRecordsWithErrorLog.DialogUpdate(1, DeleteRecordsWithErrorLog.CalcProgress(StepCount, MaxSteps), 2, StrSubstNo('%1/%2', StepCount, MaxSteps), 3, RecRef.RecordId) then begin
                        DeleteRecordsWithErrorLog.showErrors();
                        Error('Process Stopped');
                    end;
                    StepCount += 1;
                    Commit();
                    DeleteRecordsWithErrorLog.InitRecordToDelete(RecRef.RecordId, UseOnDeleteTrigger);
                    if not DeleteRecordsWithErrorLog.Run() then
                        DeleteRecordsWithErrorLog.LogLastError();
                until RecRef.Next() = 0;
                DeleteRecordsWithErrorLog.showErrors();
            end;
        end;
    end;

    procedure SetDataFileID(DataFile: Record DMTDataFile)
    begin
        CurrDataFile := DataFile;
    end;

    var
        CurrDataFile: Record DMTDataFile;
        UseOnDeleteTrigger: Boolean;
        SourceTableView, TargetTableView, SourceTableFilter, TargetTableFilter : Text;
}