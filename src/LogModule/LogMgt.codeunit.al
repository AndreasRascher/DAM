codeunit 110006 DMTLog
{

    procedure DeleteExistingLogFor(BufferRef: RecordRef);
    var
        LogEntry: Record DMTLogEntry;
    begin
        LogEntry.SetRange("Source ID", BufferRef.RecordId);
        if not LogEntry.IsEmpty then
            LogEntry.DeleteAll();
    end;

    procedure FilterFor(var FieldMapping: Record DMTFieldMapping) HasLines: Boolean
    var
        DataFile: Record DMTDataFile;
        LogEntry: Record DMTLogEntry;
    begin
        DataFile.Get(FieldMapping.GetRangeMin("Data File ID"));
        LogEntry.SetRange(DataFileName, DataFile.Name);
        LogEntry.SetRange(DataFilePath, DataFile.Path);
        LogEntry.SetRange("Target Field No.", FieldMapping."Target Field No.");
        HasLines := not LogEntry.IsEmpty;
    end;

    procedure InitNewProcess(LogUsage: Enum DMTLogUsage; DataFile: Record DMTDataFile)
    var
        LogEntry: Record DMTLogEntry;
    begin
        Clear(LogEntryTemplate);
        LogEntryTemplate."Process No." := LogEntry.GetNextProcessNo();
        LogEntryTemplate.Usage := LogUsage;
        if DataFile.ID <> 0 then begin
            LogEntryTemplate."Target Table ID" := DataFile."Target Table ID";
            LogEntryTemplate.DataFilePath := DataFile.Path;
            LogEntryTemplate.DataFileName := DataFile.Name;
        end;
        StartGlobal := CurrentDateTime;

        Clear(ProcessingStatistics);
        ProcessingStatistics.Add(Format(StatisticType::Success), 0);
        ProcessingStatistics.Add(Format(StatisticType::Error), 0);
        ProcessingStatistics.Add(Format(StatisticType::Processed), 0);
    end;

    procedure AddTitleEntryForCurrentProcess(TitleDescription: Text)
    var
        LogEntry: Record DMTLogEntry;
    begin
        CheckIfProcessNoIsSet();
        LogEntry := LogEntryTemplate;
        LogEntry."Entry Type" := LogEntry."Entry Type"::"Process Title";
        LogEntry."Context Description" := CopyStr(TitleDescription, 1, MaxStrLen(LogEntry."Context Description"));
        LogEntry.Insert(true);
    end;

    procedure AddTargetSuccessEntry(SourceID: RecordID; DataFile: Record DMTDataFile)
    var
        FieldMappingDummy: Record DMTFieldMapping;
        ErrorItemDummy: Dictionary of [Text, Text];
    begin
        AddEntry(SourceID, Enum::DMTLogEntryType::Success, DataFile, FieldMappingDummy, ErrorItemDummy);
    end;

    procedure AddTargetErrorByIDEntry(TargetID: RecordID; DataFile: Record DMTDataFile; ErrorItem: Dictionary of [Text, Text])
    var
        FieldMappingDummy: Record DMTFieldMapping;
    begin
        AddEntry(TargetID, Enum::DMTLogEntryType::Error, DataFile, FieldMappingDummy, ErrorItem);
    end;

    procedure AddErrorByFieldMappingEntry(SourceID: RecordID; DataFile: record DMTDataFile; FieldMapping: Record DMTFieldMapping; ErrorItem: Dictionary of [Text, Text])
    begin
        AddEntry(SourceID, Enum::DMTLogEntryType::Error, DataFile, FieldMapping, ErrorItem);
    end;

    local procedure AddEntry(sourceID: RecordID; logEntryType: Enum DMTLogEntryType; DataFile: record DMTDataFile; fieldMapping: Record DMTFieldMapping; errorItem: Dictionary of [Text, Text])
    var
        targetIDDummy: RecordId;
    begin
        AddEntry(sourceID, targetIDDummy, logEntryType, datafile, fieldMapping, errorItem);
    end;

    local procedure AddEntry(SourceID: RecordID; TargetID: RecordId; LogEntryType: Enum DMTLogEntryType; DataFile: record DMTDataFile; FieldMapping: Record DMTFieldMapping; ErrorItem: Dictionary of [Text, Text])
    var
        LogEntry: Record DMTLogEntry;
        KeyFieldMapping: Record DMTFieldMapping;
        GenBuffTable: Record DMTGenBuffTable;
        SourceRef: RecordRef;
        SourceIdText: Text;
    begin
        CheckIfProcessNoIsSet();
        if SourceID.TableNo = Database::DMTGenBuffTable then begin
            DataFile.FilterRelated(KeyFieldMapping);
            KeyFieldMapping.SetRange("Is Key Field(Target)", true);
            GenBuffTable.Get(SourceID);
            SourceRef.GetTable(GenBuffTable);
            if KeyFieldMapping.FindSet() then
                repeat
                    if KeyFieldMapping."Source Field No." <> 0 then
                        SourceIdText := Format(SourceRef.Field(KeyFieldMapping."Source Field No.").Value) + ',';
                until KeyFieldMapping.Next() = 0;
            if SourceIdText.EndsWith(',') then
                SourceIdText := SourceIdText.Remove(StrLen(SourceIdText));
        end else begin
            SourceIdText := Format(SourceID);
        end;
        LogEntry := LogEntryTemplate;
        LogEntry."Entry Type" := LogEntryType;
        LogEntry."Source ID" := SourceID;
        LogEntry."Source ID (Text)" := CopyStr(SourceIdText, 1, MaxStrLen(LogEntry."Source ID (Text)"));
        LogEntry."Target ID" := TargetID;
        LogEntry."Target ID (Text)" := Format(TargetID);
        if FieldMapping."Data File ID" <> 0 then begin
            LogEntry."Target Field No." := FieldMapping."Target Field No.";
        end;

        if LogEntryType = LogEntryType::Error then begin
            LogEntry."Ignore Error" := FieldMapping."Ignore Validation Error";
            LogEntry.ErrorCode := CopyStr(ErrorItem.Get('GetLastErrorCode'), 1, MaxStrLen(LogEntry.ErrorCode));
            LogEntry.SetErrorCallStack(ErrorItem.Get('GetLastErrorCallStack'));
            LogEntry."Context Description" := CopyStr(ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(LogEntry."Context Description"));
            if ErrorItem.ContainsKey('ErrorValue') then
                LogEntry."Error Field Value" := CopyStr(ErrorItem.Get('ErrorValue'), 1, MaxStrLen(LogEntry."Error Field Value"));
        end;

        LogEntry.Insert();
    end;

    procedure AddEntryForCurrentProcess(sourceRef: RecordRef; targetRef: RecordRef; fieldMapping: Record DMTFieldMapping; errorItem: Dictionary of [Text, Text]);
    var
        LogEntry: Record DMTLogEntry;
    begin
        CheckIfProcessNoIsSet();
        LogEntry := LogEntryTemplate;

        LogEntry."Source ID" := sourceRef.RecordId;
        LogEntry."Target ID" := targetRef.RecordId;
        LogEntry."Source ID (Text)" := CopyStr(Format(LogEntry."Source ID"), 1, MaxStrLen(LogEntry."Source ID (Text)"));
        LogEntry."Target ID (Text)" := CopyStr(Format(LogEntry."Target ID"), 1, MaxStrLen(LogEntry."Target ID (Text)"));

        LogEntry."Target Table ID" := fieldMapping."Target Table ID";
        LogEntry."Target Field No." := fieldMapping."Target Field No.";
        LogEntry."Ignore Error" := fieldMapping."Ignore Validation Error";
        LogEntry."Context Description" := CopyStr(errorItem.Get('GetLastErrorText'), 1, MaxStrLen(LogEntry."Context Description"));
        LogEntry.ErrorCode := CopyStr(errorItem.Get('GetLastErrorCode'), 1, MaxStrLen(LogEntry.ErrorCode));
        LogEntry."Error Field Value" := CopyStr(errorItem.Get('ErrorValue'), 1, MaxStrLen(LogEntry."Error Field Value"));
        LogEntry.SetErrorCallStack(errorItem.Get('GetLastErrorCallStack'));

        LogEntry.Insert();
    end;

    internal procedure CreateErrorItem() ErrorItem: Dictionary of [Text, Text];
    begin
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
    end;

    internal procedure ShowLogForCurrentProcess()
    var
        LogEntry: Record DMTLogEntry;
        LogEntries: Page DMTLogEntries;
    begin
        CheckIfProcessNoIsSet();
        LogEntry.SetRange("Process No.", LogEntryTemplate."Process No.");
        LogEntries.SetTableView(LogEntry);
        LogEntries.Run();
    end;

    internal procedure FieldErrorsExistFor(var FieldMapping: Record DMTFieldMapping) ErrExist: Boolean
    var
        DataFile: Record DMTDataFile;
        LogEntry: Record DMTLogEntry;
    begin
        if FieldMapping."Data File ID" = 0 then
            // Filtered Rec from Page 
            DataFile.Get(FieldMapping.GetRangeMin("Data File ID"))
        else
            DataFile.Get(FieldMapping."Data File ID");
        LogEntry.SetRange("Entry Type", LogEntry."Entry Type"::Error);
        LogEntry.SetRange(DataFileName, DataFile.Name);
        LogEntry.SetRange(DataFilePath, DataFile.Path);
        LogEntry.SetRange("Target Field No.", FieldMapping."Target Field No.");
        ErrExist := not LogEntry.IsEmpty;
    end;

    internal procedure AddImportToBufferSummary(dataFile: record DMTDataFile; duration: Duration)
    var
        logEntry: Record DMTLogEntry;
        durationLbl: Label '⌛: %1', Locked = true;
    begin
        logEntry.Usage := logEntry.Usage::"Import to Buffer Table";
        logEntry."Entry Type" := logEntry."Entry Type"::Summary;
        logEntry."Process No." := 0;
        logEntry."Target Table ID" := dataFile."Target Table ID";
        logEntry."Context Description" := StrSubstNo(durationLbl, duration);
        logEntry.DataFileName := dataFile.Name;
        logEntry.DataFilePath := dataFile.Path;
        logEntry."Target Table ID" := dataFile."Target Table ID";
        logEntry.Insert();
    end;

    internal procedure CreateNoOfBufferRecordsProcessedEntry(dataFile: record DMTDataFile; noOfRecordsProcessed: Integer)
    var
        logEntry: Record DMTLogEntry;
        noOfRecordsProcessedLbl: Label '%1 records processed';
    begin
        logEntry.Usage := logEntry.Usage::"Process Buffer - Record";
        logEntry."Process No." := 0;
        logEntry."Target Table ID" := dataFile."Target Table ID";
        logEntry."Context Description" := StrSubstNo(noOfRecordsProcessedLbl, noOfRecordsProcessed);
        logEntry.Insert();
    end;

    procedure CreateSummary()
    var
        LogEntry: Record DMTLogEntry;
        SummaryLbl: Label '∑: %1/ ✅: %2/ ❌: %3 / ⌛: %4', Locked = true;
    begin
        CheckIfProcessNoIsSet();
        LogEntry := LogEntryTemplate;
        LogEntry."Entry Type" := LogEntry."Entry Type"::Summary;
        LogEntry."Context Description" := StrSubstNo(SummaryLbl,
                                           ProcessingStatistics.Get(Format(StatisticType::Processed)),
                                           ProcessingStatistics.Get(Format(StatisticType::Success)),
                                           ProcessingStatistics.Get(Format(StatisticType::Error)),
                                           CurrentDateTime - StartGlobal);
        LogEntry.Insert(true);
    end;

    local procedure CheckIfProcessNoIsSet()
    begin
        if LogEntryTemplate."Process No." = 0 then
            Error('Process No is not initialized');
    end;

    procedure IncNoOfProcessedRecords()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Processed), ProcessingStatistics.Get(Format(StatisticType::Processed)) + 1);
    end;

    procedure IncNoOfRecordsWithErrors()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Error), ProcessingStatistics.Get(Format(StatisticType::Error)) + 1);
    end;

    procedure IncNoOfSuccessfullyProcessedRecords()
    begin
        ProcessingStatistics.Set(Format(StatisticType::Success), ProcessingStatistics.Get(Format(StatisticType::Success)) + 1);
    end;

    procedure ShowLogEntriesFor(Datafile: Record DMTDataFile)
    var
        LogEntry: Record DMTLogEntry;
        LogEntries: Page DMTLogEntries;
    begin
        LogEntry.FilterFor(Datafile);
        LogEntries.SetTableView(LogEntry);
        LogEntries.Run();
    end;

    var
        LogEntryTemplate: Record DMTLogEntry;
        StartGlobal: DateTime;
        ProcessingStatistics: Dictionary of [Text, Integer];
        StatisticType: Option Processed,Success,Error;
}