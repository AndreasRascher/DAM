codeunit 73007 DMTMigrate
{
    /// <summary>
    /// Process buffer records defined by RecordIds
    /// </summary>
    procedure RetryBufferRecordIDs(var RecIdToProcessList: List of [RecordId]; DataFile: Record DMTDataFile)
    var
        Log: Codeunit DMTLog;
    begin
        Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", DataFile);
        ListOfBufferRecIDs(RecIdToProcessList, Log, DataFile, false);
        Log.CreateSummary();
        Log.ShowLogForCurrentProcess();
    end;
    /// <summary>
    /// Process buffer records defined by RecordIds
    /// </summary>
    procedure ListOfBufferRecIDs(var RecIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; DataFile: Record DMTDataFile; StopProcessingRecIDListAfterError: Boolean) IsFullyProcessed: Boolean
    var
        ImportSettings: Codeunit DMTImportSettings;
    begin
        ImportSettings.RecIdToProcessList(RecIdToProcessList);
        ImportSettings.DataFile(DataFile);
        ImportSettings.NoUserInteraction(true);
        ImportSettings.StopProcessingRecIDListAfterError(StopProcessingRecIDListAfterError);
        LoadFieldMapping(ImportSettings);
        IsFullyProcessed := ListOfBufferRecIDsInner(RecIdToProcessList, Log, ImportSettings);
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
        DMTImportSettings.UpdateFieldsFilter(DataFile.ReadLastFieldUpdateSelection());
        DMTImportSettings.UpdateExistingRecordsOnly(true);
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    /// <summary>
    /// Process buffer records with ProcessingPlan settings
    /// </summary>
    procedure BufferFor(ProcessingPlan: Record DMTProcessingPlan)
    var
        DataFile: Record DMTDataFile;
        DMTImportSettings: Codeunit DMTImportSettings;
    begin
        DMTImportSettings.ProcessingPlan(ProcessingPlan);
        DataFile.Get(ProcessingPlan.ID);
        DMTImportSettings.DataFile(DataFile);
        DMTImportSettings.UpdateFieldsFilter(ProcessingPlan.ReadUpdateFieldsFilter());
        DMTImportSettings.SourceTableView(ProcessingPlan.ReadSourceTableView());
        LoadFieldMapping(DMTImportSettings);
        ProcessFullBuffer(DMTImportSettings);
    end;

    local procedure LoadFieldMapping(var DMTImportSettings: Codeunit DMTImportSettings) OK: Boolean
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
            FieldMapping.SetRange("Is Key Field(Target)", true);
            // Mark Key Fields
            FieldMapping.FindSet();
            repeat
                FieldMapping.Mark(true);
            until FieldMapping.Next() = 0;

            // Mark Selected Fields
            FieldMapping.SetRange("Is Key Field(Target)");
            FieldMapping.SetFilter("Target Field No.", DMTImportSettings.UpdateFieldsFilter());
            FieldMapping.FindSet();
            repeat
                FieldMapping.Mark(true);
            until FieldMapping.Next() = 0;

            FieldMapping.SetRange("Target Field No.");
            FieldMapping.MarkedOnly(true);
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
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
        Log: Codeunit DMTLog;
        MigrationLib: Codeunit DMTMigrationLib;
        ProgressDialog: Codeunit DMTProgressDialog;
        BufferRef, BufferRef2 : RecordRef;
        Start: DateTime;
        ResultType: Enum DMTProcessingResultType;
    begin
        Start := CurrentDateTime;
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        DataFile := DMTImportSettings.DataFile();

        // Show Filter Dialog
        DataFile.InitBufferRef(BufferRef);
        Commit(); // Runmodal Dialog in Edit View
        if not EditView(BufferRef, DMTImportSettings) then
            exit;
        CheckMappedFieldsExist(DataFile);
        CheckBufferTableIsNotEmpty(DataFile);

        //Prepare Progress Bar
        if not BufferRef.FindSet() then
            Error(format(enum::DMTErrMsg::NoBufferTableRecorsInFilter), BufferRef.GetFilters);

        PrepareProgressBar(ProgressDialog, DataFile, BufferRef);
        ProgressDialog.Open();
        ProgressDialog.UpdateFieldControl('Filter', ConvertStr(BufferRef.GetFilters, '@', '_'));


        if DMTImportSettings.UpdateFieldsFilter() <> '' then
            Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Field Update", DataFile)
        else
            Log.InitNewProcess(Enum::DMTLogUsage::"Process Buffer - Record", DataFile);

        repeat
            // hier weiter machen:
            // Wenn beim Feldupdate ein Zieldatensatz nicht existiert, dann soll der als geskipped gekennzeichnet werden
            // Nur wenn ein Zieldatensatz existiert und kein Fehler auftreteten ist , dann ist das ok
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DMTImportSettings, Log, ResultType);
            UpdateLog(DMTImportSettings, Log, ResultType);
            UpdateProgress(DMTImportSettings, ProgressDialog, ResultType);
            if ProgressDialog.GetStep('Process') mod 50 = 0 then
                Commit();
        until BufferRef.Next() = 0;
        MigrationLib.RunPostProcessingFor(DataFile);
        ProgressDialog.Close();
        Log.CreateSummary();
        Log.ShowLogForCurrentProcess();
        ShowResultDialog(ProgressDialog);
    end;

    local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var ResultType: Enum DMTProcessingResultType)
    var
        ProcessRecord: Codeunit DMTProcessRecord;
    begin
        ClearLastError();
        Clear(ResultType);
        Log.DeleteExistingLogFor(BufferRef2);
        ProcessRecord.InitFieldTransfer(BufferRef2, DMTImportSettings);
        Commit();
        while not ProcessRecord.Run() do begin
            ProcessRecord.LogLastError();
        end;

        if DMTImportSettings.UpdateExistingRecordsOnly() then begin
            ProcessRecord.InitModify();
            Commit();
            if not ProcessRecord.Run() then
                ProcessRecord.LogLastError();
        end else begin
            ProcessRecord.InitInsert();
            Commit();
            if not ProcessRecord.Run() then
                ProcessRecord.LogLastError();
        end;
        ProcessRecord.SaveErrorLog(Log);
        ResultType := ProcessRecord.GetProcessingResultType();
    end;

    local procedure EditView(var BufferRef: RecordRef; var DMTImportSettings: Codeunit DMTImportSettings) Continue: Boolean
    var
        DataFile: Record DMTDataFile;
        FPBuilder: Codeunit DMTFPBuilder;
    begin
        Continue := true; // Canceling the dialog should stop th process

        if DMTImportSettings.SourceTableView() <> '' then
            BufferRef.SetView(DMTImportSettings.SourceTableView());

        if DMTImportSettings.NoUserInteraction() then begin
            exit(Continue);
        end;

        DataFile.Get(DMTImportSettings.DataFile().RecordId);
        if not FPBuilder.RunModal(BufferRef, DataFile, true) then
            exit(false);
        if BufferRef.HasFilter then begin
            DataFile.WriteSourceTableView(BufferRef.GetView());
            Commit();
        end else begin
            DataFile.WriteSourceTableView('');
            Commit();
        end;
    end;

    local procedure ShowResultDialog(var ProgressDialog: Codeunit DMTProgressDialog)
    var
        ResultMsg: Label 'No. of Records..\processed: %1\imported: %2\With Error: %3\Processing Time:%4',
         Comment = 'de-DE=Anzahl Datensätze..\verarbeitet: %1\eingelesen : %2\mit Fehlern: %3\Verarbeitungsdauer: %4';
    begin
        Message(ResultMsg,
                ProgressDialog.GetStep('Process'),
                ProgressDialog.GetStep('ResultOK'),
                ProgressDialog.GetStep('ResultError'),
                ProgressDialog.GetCustomDuration('Progress'));
    end;

    local procedure UpdateLog(var DMTImportSettings: Codeunit DMTImportSettings; var Log: Codeunit DMTLog; var ResultType: Enum DMTProcessingResultType)
    begin
        Log.IncNoOfProcessedRecords();
        case ResultType of
            ResultType::Error:
                Log.IncNoOfRecordsWithErrors();
            ResultType::Ignored:
                begin
                    if DMTImportSettings.UpdateFieldsFilter() = '' then;
                    //Field Update
                    if DMTImportSettings.UpdateFieldsFilter() <> '' then;
                end;
            ResultType::ChangesApplied:
                Log.IncNoOfSuccessfullyProcessedRecords();
            else begin
                Error('Unhandled Case %1', ResultType::" ");
            end;
        end;
    end;

    procedure PrepareProgressBar(var ProgressDialog: Codeunit DMTProgressDialog; var DataFile: Record DMTDataFile; var BufferRef: RecordRef)
    var
        MaxWith: Integer;
        DurationLbl: Label 'Duration', Comment = 'de-DE Dauer';
        TimeRemainingLbl: Label 'Time Remaining', Comment = 'de-DE Verbleibende Zeit';
        ProgressBarTitle: Text;
    begin
        DataFile.CalcFields("Target Table Caption");
        ProgressBarTitle := DataFile."Target Table Caption";
        MaxWith := 100 - 32;
        if StrLen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (MaxWith - StrLen(ProgressBarTitle)) div 2, '_');
        end;
        // ToDo: Performance der Codeunit ProgressDialog schlecht, ggf.weniger generisch,
        //       durch konkrete Programmierung aller Progressdialoge ersetzten

        ProgressDialog.SaveCustomStartTime('Progress');
        ProgressDialog.SetTotalSteps('Process', BufferRef.Count);
        ProgressDialog.AppendTextLine(ProgressBarTitle);
        ProgressDialog.AppendText('\Filter:');
        ProgressDialog.AddField(42, 'Filter');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Record:');
        ProgressDialog.AddField(42, 'NoofRecord');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + DurationLbl + ':');
        ProgressDialog.AddField(42, 'Duration');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Progress:');
        ProgressDialog.AddBar(42, 'Progress');
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + TimeRemainingLbl + ':');
        ProgressDialog.AddField(42, 'TimeRemaining');
        ProgressDialog.AppendTextLine('');
    end;

    procedure UpdateProgress(var DMTImportSettings: Codeunit DMTImportSettings; var ProgressDialog: Codeunit DMTProgressDialog; ResultType: Enum DMTProcessingResultType)
    begin
        ProgressDialog.NextStep('Process');
        case ResultType of
            ResultType::Error:
                ProgressDialog.NextStep('ResultError');
            ResultType::Ignored:
                begin
                    if DMTImportSettings.UpdateFieldsFilter() = '' then
                        ProgressDialog.NextStep(('Ignored'));
                    //Field Update
                    if DMTImportSettings.UpdateFieldsFilter() <> '' then begin
                        //Log.IncNoOfSuccessfullyProcessedRecords();
                    end;
                end;
            ResultType::ChangesApplied:
                ProgressDialog.NextStep('ResultOK');
            else begin
                Error('Unhandled Case %1', ResultType::" ");
            end;
        end;
        ProgressDialog.UpdateFieldControl('NoofRecord', StrSubstNo('%1 / %2', ProgressDialog.GetStep('Process'), ProgressDialog.GetTotalStep('Process')));
        ProgressDialog.UpdateControlWithCustomDuration('Duration', 'Progress');
        ProgressDialog.UpdateProgressBar('Progress', 'Process');
        ProgressDialog.UpdateFieldControl('TimeRemaining', ProgressDialog.GetRemainingTime('Progress', 'Process'));
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

    procedure CheckMappedFieldsExist(DataFile: Record DMTDataFile)
    var
        FieldMapping: Record DMTFieldMapping;
        FieldMappingEmptyErr: Label 'No field mapping found for "%1"', comment = 'Kein Feldmapping gefunden für "%1"';
    begin
        // Key Fields Mapping Exists
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        FieldMapping.SetRange("Is Key Field(Target)", true);
        FieldMapping.SetFilter("Source Field No.", '<>0');

        DataFile.CalcFields("Target Table Caption");
        if FieldMapping.IsEmpty then
            Error(FieldMappingEmptyErr, DataFile.FullDataFilePath());
    end;

    procedure CheckBufferTableIsNotEmpty(DataFile: Record DMTDataFile)
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        case DataFile.BufferTableType of
            DataFile.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    RecRef.Open(DataFile."Buffer Table ID");
                    if RecRef.IsEmpty then
                        Error('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.Caption, DataFile."Buffer Table ID");
                end;
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    if not GenBuffTable.FilterBy(DataFile) then
                        Error('Für "%1" wurden keine importierten Daten gefunden', DataFile.FullDataFilePath());
                end;
        end;
    end;

    procedure ListOfBufferRecIDsInner(var RecIdToProcessList: List of [RecordId]; var Log: Codeunit DMTLog; ImportSettings: Codeunit DMTImportSettings) IsFullyProcessed: Boolean
    var
        // DMTErrorLog: Record DMTErrorLog;
        DataFile: Record DMTDataFile;
        ID: RecordId;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        ResultType: Enum DMTProcessingResultType;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        DataFile := ImportSettings.DataFile();
        // Buffer loop
        BufferRef.Open(DataFile."Buffer Table ID");
        ID := RecIdToProcessList.Get(1);
        BufferRef.Get(ID);

        IsFullyProcessed := true;
        foreach ID in RecIdToProcessList do begin
            BufferRef.Get(ID);
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, ImportSettings, Log, ResultType);
            Log.IncNoOfProcessedRecords();
            if ResultType = ResultType::ChangesApplied then begin
                Log.IncNoOfSuccessfullyProcessedRecords();
            end;
            if ResultType = ResultType::Error then begin
                Log.IncNoOfRecordsWithErrors();
                if ImportSettings.StopProcessingRecIDListAfterError() then begin
                    exit(false); // break;
                end;
            end;
        end;
    end;
}