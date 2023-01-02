codeunit 110017 DMTMigrate
{
    /// <summary>
    /// Process buffer records defined by RecordIds
    /// </summary>
    procedure ListOfBufferRecIDs(var RecIdToProcessList: List of [RecordId]; DataFile: Record DMTDataFile)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.RecIdToProcessList(RecIdToProcessList);
        DMTImportSettings.DataFile(DataFile);
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;
    /// <summary>
    /// Process buffer records with field selection
    /// </summary>
    procedure AllFieldsFrom(DataFile: Record DMTDataFile)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.DataFile(DataFile);
        DMTImportSettings.SourceTableView(DataFile.ReadLastSourceTableView());
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;
    /// <summary>
    /// Process buffer records with field selection
    /// </summary>
    procedure AllFieldsWithoutDialogFrom(DataFile: Record DMTDataFile)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.DataFile(DataFile);
        DMTImportSettings.NoUserInteraction(true);
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;
    /// <summary>
    /// Process buffer records
    /// </summary>
    procedure SelectedFieldsFrom(DataFile: Record DMTDataFile)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.DataFile(DataFile);
        DMTImportSettings.DataFile(DataFile);
        DMTImportSettings.UpdateFieldsFilter(DataFile.ReadLastFieldUpdateSelection());
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    /// <summary>
    /// Process buffer records with ProcessingPlan settings
    /// </summary>
    procedure BufferFor(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ProcessingPlan(ProcessingPlan);
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    local procedure LoadFieldMapping(DMTImportSettings: Codeunit DMTImportSettings) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
        TempFieldMapping, TempFieldMapping_ProcessingPlanSettings : Record DMTFieldMapping temporary;
        DataFile: Record DMTDataFile;
    begin
        DataFile := DMTImportSettings.DataFile();
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
            FieldMapping.SetFilter("Source Field No.", '<>0');

        if DMTImportSettings.UpdateFieldsFilter() <> '' then begin // Scope ProcessingPlan
            FieldMapping.SetFilter("Target Field No.", DMTImportSettings.UpdateFieldsFilter());
        end;
        FieldMapping.CopyToTemp(TempFieldMapping);
        // Apply Processing Plan Settings
        if DMTImportSettings.ProcessingPlan()."Line No." <> 0 then begin
            DMTImportSettings.ProcessingPlan().ConvertDefaultValuesViewToFieldLines(TempFieldMapping_ProcessingPlanSettings);
            if TempFieldMapping_ProcessingPlanSettings.FindSet() then
                repeat
                    TempFieldMapping.Get(TempFieldMapping_ProcessingPlanSettings.RecordId);
                    TempFieldMapping := TempFieldMapping_ProcessingPlanSettings;
                    TempFieldMapping.Modify();
                until TempFieldMapping_ProcessingPlanSettings.Next() = 0;
        end;

        OK := TempFieldMapping.FindFirst();
        DMTImportSettings.SetFieldMapping(TempFieldMapping);
    end;

    local procedure ProcessFullBuffer(var DMTImportSettings: Codeunit DMTImportSettings)
    var
        DataFile: Record DMTDataFile;
        ErrorLog: Record DMTErrorLog;
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
        MigrationLib: Codeunit DMTMigrationLib;
        ProgressDialog: Codeunit DMTProgressDialog;
        BufferRef, BufferRef2 : RecordRef;
        MaxWith: Integer;
        ProgressBarTitle: Text;
        RecordWasSkipped, RecordHadErrors : Boolean;
    begin
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        DataFile := DMTImportSettings.DataFile();

        // Show Filter Dialog
        InitBufferRef(DataFile, BufferRef);
        Commit(); // Runmodal Dialog in Edit View
        if not EditView(BufferRef, DMTImportSettings) then
            exit;

        //Prepare Progress Bar
        BufferRef.FindSet();
        DataFile.Calcfields("Target Table Caption");
        ProgressBarTitle := DataFile."Target Table Caption";
        if StrLen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (StrLen(ProgressBarTitle) - MaxWith) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (StrLen(ProgressBarTitle) - MaxWith) div 2, '_');
        end;
        ProgressDialog.SaveCustomStartTime(1);
        ProgressDialog.SetTotalSteps(1, BufferRef.Count);
        ProgressDialog.AppendTextLine(ProgressBarTitle);
        ProgressDialog.AppendText('\Filter:');
        ProgressDialog.AddField(42, 1);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Record:');
        ProgressDialog.AddField(42, 2);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Duration:');
        ProgressDialog.AddField(42, 3);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Progress:');
        ProgressDialog.AddBar(42, 4);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Time Remaining:');
        ProgressDialog.AddField(42, 5);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.Open();
        ProgressDialog.UpdateControl(1, ConvertStr(BufferRef.GetFilters, '@', '_'));

        repeat
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DMTImportSettings, RecordWasSkipped, RecordHadErrors);

            ProgressDialog.NextStep(1);
            if RecordWasSkipped then
                ProgressDialog.NextStep(2);

            ProgressDialog.UpdateControl(2, BufferRef2.GetPosition());
            ProgressDialog.UpdateControlWithCustomDuration(3, 3);
            ProgressDialog.UpdateControl(4, StrSubstNo('%1 / %2', ProgressDialog.GetStep(1), ProgressDialog.GetTotalStep(1)));
            ProgressDialog.UpdateControl(5, ProgressDialog.GetRemainingTime(1, 1));
            // DMTMgt.ProgressBar_NextStep();
            // DMTMgt.ProgressBar_Update(0, '',
            //                           4, DMTMgt.ProgressBar_GetProgress(),
            //                           2, StrSubstNo('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
            //                           3, DMTMgt.ProgressBar_GetTimeElapsed(),
            //                           5, DMTMgt.ProgressBar_GetRemainingTime());

            if ProgressDialog.GetStep(1) mod 50 = 0 then
                Commit();
        until BufferRef.Next() = 0;
        MigrationLib.RunPostProcessingFor(DataFile);
        ProgressDialog.Close();
        ErrorLog.OpenListWithFilter(DataFile, true);
        Message('ToDo: DMTMgt.GetResultQtyMessage();');
    end;

    procedure InitBufferRef(DataFile: Record DMTDataFile; var BufferRef: RecordRef)
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

    local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings; RecordWasSkipped: Boolean; RecordHadErrors: Boolean)
    var
        ErrorLog: Record DMTErrorLog;
        ProcessRecord: Codeunit DMTProcessRecord;
    begin
        ClearLastError();
        Clear(RecordHadErrors);
        Clear(RecordWasSkipped);
        ErrorLog.DeleteExistingLogFor(BufferRef2);
        ProcessRecord.InitFieldTransfer(BufferRef2, DMTImportSettings);
        Commit();
        while not ProcessRecord.Run() do begin
            ProcessRecord.LogLastError();
        end;

        ProcessRecord.InitInsert();
        Commit();
        if not ProcessRecord.Run() then
            ProcessRecord.LogLastError();

        RecordHadErrors := ProcessRecord.SaveErrorLog();
    end;

    local procedure EditView(var BufferRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings) Continue: Boolean
    var
        DataFile: Record DMTDataFile;
    begin
        Continue := true; // Canceling the dialog should stop th process

        if DMTImportSettings.SourceTableView() <> '' then
            BufferRef.SetView(DMTImportSettings.SourceTableView());

        if DMTImportSettings.NoUserInteraction() then begin
            exit(Continue);
        end;

        DataFile.Get(DMTImportSettings.DataFile().RecordId);
        if not ShowRequestPageFilterDialog(BufferRef, DataFile) then
            exit(false);
        if BufferRef.HasFilter then begin
            DataFile.WriteSourceTableView(BufferRef.GetView());
            Commit();
        end else begin
            DataFile.WriteSourceTableView('');
            Commit();
        end;
    end;

    procedure FindCollationProblems(RecordMapping: Dictionary of [RecordId, RecordId]) CollationProblems: Dictionary of [RecordId, RecordId]
    var
        TargetRecID: RecordId;
        LastIndex, ListIndex : Integer;
    begin
        for ListIndex := 1 to RecordMapping.Values.Count do begin
            TargetRecID := RecordMapping.Values.Get(ListIndex);
            LastIndex := RecordMapping.Values.LastIndexOf(TargetRecID);
            if LastIndex <> ListIndex then begin
                CollationProblems.Add(RecordMapping.Keys.Get(ListIndex), RecordMapping.Values.Get(ListIndex));
                CollationProblems.Add(RecordMapping.Keys.Get(LastIndex), RecordMapping.Values.Get(LastIndex));
            end;
        end;
    end;

    procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef; var DataFile: Record DMTDataFile) Continue: Boolean;
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


    var
        ProgressBarText_DurationTok: Label '\Duration:        ########################################3#';
        ProgressBarText_FilterTok: Label '\Filter:       ########################################1#';
        ProgressBarText_ProgressTok: Label '\Progress:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@';
        ProgressBarText_RecordTok: Label '\Record:    ########################################2#';
        ProgressBarText_TimeRemainingTok: Label '\Time Remaining: ########################################5#';
        ProgressBarText_TitleTok: Label '_________________________%1_________________________', Locked = true;

}