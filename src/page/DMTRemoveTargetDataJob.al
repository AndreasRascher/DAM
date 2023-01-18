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
                    StartDeleting();
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
        BufferRef: RecordRef;
    begin
        InitBufferRef(CurrDataFile, BufferRef);
        if SourceTableView <> '' then
            BufferRef.SetView(SourceTableView);

        if not ShowRequestPageFilterDialog(BufferRef, CurrDataFile) then
            exit;
        SourceTableView := BufferRef.GetView();
        SourceTableFilter := BufferRef.GetFilters;
    end;

    procedure EditTargetTableFilter()
    var
        DMTCopyTable: Record DMTCopyTable;
        RecRef: RecordRef;
    begin
        RecRef.Open(CurrDataFile."Target Table ID");
        if TargetTableView <> '' then
            RecRef.SetView(TargetTableView);
        if DMTCopyTable.ShowRequestPageFilterDialog(RecRef) then begin
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

    local procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef; var DataFile: Record DMTDataFile) Continue: Boolean;
    var
        FieldMapping: Record DMTFieldMapping;
        GenBuffTable: Record DMTGenBuffTable;
        FPBuilder: FilterPageBuilder;
        Index: Integer;
        PrimaryKeyRef: KeyRef;
        Debug: Text;
    begin
        FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
        if BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.Caption, BufferRef.GetView());

        if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
            if DataFile.FilterRelated(FieldMapping) then begin
                // Init Captions
                if GenBuffTable.FilterBy(DataFile) then
                    if GenBuffTable.FindFirst() then
                        GenBuffTable.InitFirstLineAsCaptions(GenBuffTable);
                Debug := GenBuffTable.FieldCaption(Fld001);
                FieldMapping.SetRange("Is Key Field(Target)", true);
                if FieldMapping.FindSet() then
                    repeat
                        FPBuilder.AddFieldNo(GenBuffTable.TableCaption, FieldMapping."Source Field No.");
                    until FieldMapping.Next() = 0;
            end;
        end else begin
            // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
            PrimaryKeyRef := BufferRef.KeyIndex(1);
            for Index := 1 to PrimaryKeyRef.FieldCount do
                FPBuilder.AddFieldNo(BufferRef.Caption, PrimaryKeyRef.FieldIndex(Index).Number);
        end;
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RunModal();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.Caption));
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

        LoadFieldMapping(DataFile, false, TempFieldMapping);
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

    local procedure LoadFieldMapping(DataFile: Record DMTDataFile; UseToFieldFilter: Boolean; var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
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

    local procedure StartDeleting()
    var
        DeleteRecordsWithErrorLog: Codeunit DMTDeleteRecordsWithErrorLog;
        RecID: RecordId;
        RecordMapping: Dictionary of [RecordId, RecordId];
        MaxSteps, StepCount : Integer;
        NotTransferedRecords: List of [RecordId];
    begin
        RecordMapping := CreateSourceToTargetRecIDMapping(CurrDataFile, SourceTableView, NotTransferedRecords);
        MaxSteps := RecordMapping.Values.Count;
        CurrDataFile.CalcFields("Target Table Caption");
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

    procedure SetDataFileID(DataFile: Record DMTDataFile)
    begin
        CurrDataFile := DataFile;
    end;

    var
        CurrDataFile: Record DMTDataFile;
        UseOnDeleteTrigger: Boolean;
        SourceTableView, TargetTableView, SourceTableFilter, TargetTableFilter : Text;
}