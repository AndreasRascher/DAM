codeunit 110014 DMTImport
{
    procedure StartImport(var DataFile: Record DMTDataFile; NoUserInteraction_New: Boolean; IsUpdateTask: Boolean)
    var
        start: DateTime;
    begin
        start := CurrentDateTime;
        NoUserInteraction := NoUserInteraction_New;
        CheckBufferTableIsNotEmpty(DataFile);
        CheckMappedFieldsExist(DataFile);

        ProcessFullBuffer(DataFile, IsUpdateTask);

        UpdateProcessingTime(DataFile, start);
        DataFile.CalcFields("No. of Records In Trgt. Table");
    end;

    procedure ProcessFullBuffer(var DataFile: Record DMTDataFile; IsUpdateTask: Boolean)
    var
        ErrorLog: Record DMTErrorLog;
        TempFieldMapping: Record "DMTFieldMapping" temporary;
        GenBuffTable: Record DMTGenBuffTable;
        BufferRef, BufferRef2 : RecordRef;
        MaxWith: Integer;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
        ProgressBarTitle: Text;
        MigrationLib: Codeunit DMTMigrationLib;
    begin
        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DataFile."Target Table ID");
        LoadFieldMapping(DataFile, IsUpdateTask, TempFieldMapping);


        // Buffer loop
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
                // TempFieldMapping.FindSet();
                // repeat
                //     BufferRef.SetLoadFields(TempFieldMapping."Source Field No.");
                // until TempFieldMapping.Next() = 0;
            end;
        Commit(); // Runmodal Dialog in Edit View
        if not EditView(BufferRef, DataFile) then
            exit;
        ErrorLog.DeleteExistingLogFor(DataFile);
        BufferRef.findset();
        DataFile.Calcfields("Target Table Caption");
        ProgressBarTitle := DataFile."Target Table Caption";
        if Strlen(ProgressBarTitle) < MaxWith then begin
            ProgressBarTitle := PadStr('', (Strlen(ProgressBarTitle) - MaxWith) div 2, '_') +
                                ProgressBarTitle +
                                PadStr('', (Strlen(ProgressBarTitle) - MaxWith) div 2, '_');
        end;
        DMTMgt.ProgressBar_Open(BufferRef, ProgressBarTitle +
                                           ProgressBarText_FilterTok +
                                           ProgressBarText_RecordTok +
                                           ProgressBarText_DurationTok +
                                           ProgressBarText_ProgressTok +
                                           ProgressBarText_TimeRemainingTok);
        DMTMgt.ProgressBar_UpdateControl(1, CONVERTSTR(BufferRef.GETFILTERS, '@', '_'));
        repeat
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DataFile, TempFieldMapping, IsUpdateTask);
            DMTMgt.ProgressBar_NextStep();
            DMTMgt.ProgressBar_Update(0, '',
                                      4, DMTMgt.ProgressBar_GetProgress(),
                                      2, STRSUBSTNO('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
                                      3, DMTMgt.ProgressBar_GetTimeElapsed(),
                                      5, DMTMgt.ProgressBar_GetRemainingTime());
            IF DMTMgt.ProgressBar_GetStep() MOD 50 = 0 then
                COMMIT();
        until BufferRef.Next() = 0;
        MigrationLib.RunPostProcessingFor(DataFile);
        DMTMgt.ProgressBar_Close();
        ErrorLog.OpenListWithFilter(DataFile, true);
        DMTMgt.GetResultQtyMessage();
    end;

    procedure RetryProcessFullBuffer(var RecIdToProcessList: list of [RecordID]; DataFile: Record DMTDataFile; IsUpdateTask: Boolean)
    var
        DMTErrorLog: Record DMTErrorLog;
        TempFieldMapping: Record "DMTFieldMapping" temporary;
        ID: RecordId;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DataFile."Target Table ID");
        LoadFieldMapping(DataFile, IsUpdateTask, TempFieldMapping);

        // Buffer loop
        BufferRef.OPEN(DataFile."Buffer Table ID");
        ID := RecIdToProcessList.Get(1);
        BufferRef.get(ID);
        DMTMgt.ProgressBar_Open(RecIdToProcessList.Count,
         StrSubstNo(ProgressBarText_TitleTok, BufferRef.CAPTION) +
         ProgressBarText_FilterTok +
         ProgressBarText_RecordTok +
         ProgressBarText_DurationTok +
         ProgressBarText_ProgressTok +
         ProgressBarText_TimeRemainingTok);
        DMTMgt.ProgressBar_UpdateControl(1, 'Error');
        foreach ID in RecIdToProcessList do begin
            BufferRef.get(ID);
            BufferRef2 := BufferRef.DUPLICATE(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DataFile, TempFieldMapping, IsUpdateTask);
            DMTMgt.ProgressBar_NextStep();
            DMTMgt.ProgressBar_Update(0, '',
                                      4, DMTMgt.ProgressBar_GetProgress(),
                                      2, STRSUBSTNO('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
                                      3, DMTMgt.ProgressBar_GetTimeElapsed(),
                                      5, DMTMgt.ProgressBar_GetRemainingTime());
            IF DMTMgt.ProgressBar_GetStep() MOD 50 = 0 then
                COMMIT();
        end;
        DMTMgt.ProgressBar_Close();
        DMTErrorLog.OpenListWithFilter(DataFile, true);
        DMTMgt.GetResultQtyMessage();
    end;

    procedure LoadFieldMapping(DataFile: Record DMTDataFile; UseToFieldFilter: Boolean; var TempFieldMapping: Record "DMTFieldMapping" temporary) OK: Boolean
    var
        FieldMapping: Record "DMTFieldMapping";
    begin
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
            FieldMapping.SetFilter("Source Field No.", '<>0');
        if UseToFieldFilter then
            FieldMapping.Setfilter("Target Field No.", DataFile.ReadLastFieldUpdateSelection());
        FieldMapping.CopyToTemp(TempFieldMapping);
        OK := TempFieldMapping.FindFirst();
    end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFields(SourceRef: RecordRef; VAR TmpTargetRef: RecordRef; var TmpFieldMapping: record "DMTFieldMapping" temporary)
    var
        ToFieldRef: FieldRef;
    begin
        IF NOT TmpTargetRef.ISTEMPORARY then
            Error('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpFieldMapping.Reset();
        TmpFieldMapping.SetRange("Is Key Field(Target)", true);
        TmpFieldMapping.findset();
        repeat
            if not IsKnownAutoincrementField(TmpFieldMapping."Target Table ID", TmpFieldMapping."Target Field No.") then begin
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
            end;
        until TmpFieldMapping.Next() = 0;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TempFieldMapping: Record "DMTFieldMapping" temporary)
    var
        ToFieldRef: FieldRef;
    begin
        TempFieldMapping.Reset();
        TempFieldMapping.SetRange("Is Key Field(Target)", false);
        TempFieldMapping.SetCurrentKey("Validation Order");
        if not TempFieldMapping.findset() then
            exit; // Required for tables with only key fields
        repeat
            //hier: MigrateFieldsaufrufen
            TempFieldMapping.CalcFields("Target Field Caption");
            case true of
                (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Ignore):
                    ;
                (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Transfer):
                    if TempFieldMapping."Validation Type" = Enum::DMTFieldValidationType::AlwaysValidate then
                        DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempFieldMapping)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, BufferRef, TempFieldMapping, true);

                (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempFieldMapping."Target Field No.");
                        DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TempFieldMapping."Fixed Value");
                        if TempFieldMapping."Validation Type" = TempFieldMapping."Validation Type"::AlwaysValidate then
                            DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempFieldMapping."Target Field No.", ToFieldRef.Value, TempFieldMapping."Ignore Validation Error")
                        else
                            Error('unhandled Type');
                    end;
            end
        until TempFieldMapping.Next() = 0;
        TmpTargetRef.Modify(false);
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
        IF BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.CAPTION, BufferRef.GETVIEW());

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
            for Index := 1 TO PrimaryKeyRef.FieldCount DO
                FPBuilder.AddFieldNo(BufferRef.Caption, PrimaryKeyRef.FieldIndex(Index).Number);
        end;
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RUNMODAL();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.CAPTION));
    end;

    procedure InitFieldFilter(var BuffKeyFieldFilter: Text; var BuffNonKeyFieldFilter: text; TargetTableID: Integer)
    var
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
    begin
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        BuffKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TargetTableID, true /*include*/);
        BuffNonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TargetTableID, false /*exclude*/);
    end;

    local procedure EditView(var BufferRef: RecordRef; var DMTDataFile: Record DMTDataFile) Continue: Boolean
    begin
        Continue := true; // Canceling the dialog should stop th process

        if NoUserInteraction then
            exit(Continue);

        if BufferTableView = '' then begin
            if DMTDataFile.ReadTableLastView() <> '' then
                BufferRef.SetView(DMTDataFile.ReadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef, DMTDataFile) then
                exit(false);
            if BufferRef.HasFilter then begin
                DMTDataFile.WriteTableLastView(BufferRef.GetView());
                Commit();
            end else begin
                DMTDataFile.WriteTableLastView('');
                Commit();
            end;
        end else begin
            BufferRef.SetView(BufferTableView);
        end;
        DMTDataFile.Find('=');
    end;

    local procedure UpdateProcessingTime(var DMTDataFile: Record DMTDataFile; start: DateTime)
    begin
        DMTDataFile.Get(DMTDataFile.RecordId);
        DMTDataFile.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DMTDataFile.LastImportBy));
        DMTDataFile.LastImportToTargetAt := CurrentDateTime;
        if DMTDataFile."Import Duration (Target)" < (CurrentDateTime - start) then
            DMTDataFile."Import Duration (Target)" := (CurrentDateTime - start);
        DMTDataFile.Modify();
    end;

    local procedure IsKnownAutoincrementField(TargetTableID: Integer; TargetFieldNo: Integer) IsAutoincrement: Boolean
    var
        ActivityLog: Record "Activity Log";
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        RecordLink: Record "Record Link";
        ReservationEntry: Record "Reservation Entry";
    begin
        IsAutoincrement := false;
        case true of
            (TargetTableID = RecordLink.RecordId.TableNo) and (TargetFieldNo = RecordLink.FieldNo("Link ID")):
                exit(true);
            (TargetTableID = ReservationEntry.RecordId.TableNo) and (TargetFieldNo = ReservationEntry.FieldNo("Entry No.")):
                exit(true);
            (TargetTableID = ChangeLogEntry.RecordId.TableNo) and (TargetFieldNo = ChangeLogEntry.FieldNo("Entry No.")):
                exit(true);
            (TargetTableID = JobQueueLogEntry.RecordId.TableNo) and (TargetFieldNo = JobQueueLogEntry.FieldNo("Entry No.")):
                exit(true);
            (TargetTableID = ActivityLog.RecordId.TableNo) and (TargetFieldNo = ActivityLog.FieldNo(ID)):
                exit(true);
            else
                exit(false);
        end;

    end;

    local procedure HasValidKeyFldRelations(var TmpTargetRef: RecordRef): Boolean
    var
        RelatedRef: RecordRef;
        FldRef: FieldRef;
        KeyFieldIndex: Integer;
        KeyRef: KeyRef;
        Debug: List of [Text];
    begin
        KeyRef := TmpTargetRef.KeyIndex(1);
        for KeyFieldIndex := 1 To KeyRef.FieldCount do begin
            FldRef := KeyRef.FieldIndex(KeyFieldIndex);
            Debug.Add('FieldName:' + FldRef.Name);
            if FldRef.Relation <> 0 then begin
                Debug.Add('Relation' + format(FldRef.Relation));
                RelatedRef.Open(FldRef.Relation);
                case true of
                    (RelatedRef.KeyIndex(1).FieldCount = 2) and (KeyRef.FieldCount = 3):
                        begin
                            RelatedRef.Field(RelatedRef.KeyIndex(1).FieldIndex(1).Number).SetRange(KeyRef.FieldIndex(1).Value);
                            RelatedRef.Field(RelatedRef.KeyIndex(1).FieldIndex(2).Number).SetRange(KeyRef.FieldIndex(2).Value);
                            if RelatedRef.FindFirst() then exit(true);
                        end;
                    else
                        Error('HasValidKeyFldRelations - Unhandled Case');
                end;
            end;
        end;
    end;

    local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTDataFile: Record DMTDataFile; var TempFieldMapping: Record DMTFieldMapping; UpdateExistingRecordsOnly: Boolean)
    var
        ErrorLog: Record DMTErrorLog;
        ProcessRecord: Codeunit DMTProcessRecord;
        HasErrors: Boolean;
    begin
        ClearLastError();
        if UpdateExistingRecordsOnly then
            ErrorLog.DeleteExistingLogFor(BufferRef2);
        ProcessRecord.InitFieldTransfer(DMTDataFile, TempFieldMapping, BufferRef2, UpdateExistingRecordsOnly);
        Commit();
        While not ProcessRecord.Run() do begin
            ProcessRecord.LogLastError();
        end;
        ProcessRecord.InitInsert();
        Commit();
        if not ProcessRecord.Run() then
            ProcessRecord.LogLastError();
        HasErrors := ProcessRecord.SaveErrorLog();
        DMTMgt.UpdateResultQty(not HasErrors, true);
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
                        Error('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.CAPTION, DataFile."Buffer Table ID");
                end;
            DataFile.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    if not GenBuffTable.FilterBy(DataFile) then
                        Error('Für "%1" wurden keine importierten Daten gefunden', DataFile.FullDataFilePath());
                end;
        end;
    end;

    procedure CheckMappedFieldsExist(DataFile: Record DMTDataFile)
    var
        FieldMapping: Record DMTFieldMapping;
        FieldMappingEmptyErr: Label 'No field mapping found for "%1"', comment = 'Kein Feldmapping gefunden für "%1"';
    begin
        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        DataFile.Calcfields("Target Table Caption");
        if FieldMapping.IsEmpty then
            Error(FieldMappingEmptyErr, DataFile.FullDataFilePath());
    end;

    procedure CreateSourceToTargetRecIDMapping(DataFile: Record DMTDataFile; var NotTransferedRecords: List of [RecordId]) RecordMapping: Dictionary of [RecordId, RecordId]
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

    var
        DMTMgt: Codeunit DMTMgt;
        NoUserInteraction: Boolean;
        ProgressBarText_DurationTok: label '\Duration:        ########################################3#';
        ProgressBarText_FilterTok: label '\Filter:       ########################################1#';
        ProgressBarText_ProgressTok: label '\Progress:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@';
        ProgressBarText_RecordTok: label '\Record:    ########################################2#';
        ProgressBarText_TimeRemainingTok: label '\Time Remaining: ########################################5#';
        ProgressBarText_TitleTok: label '_________________________%1_________________________', Locked = true;
        BufferTableView: Text;
}