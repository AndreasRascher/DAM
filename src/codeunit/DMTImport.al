codeunit 50000 DMTImport
{
    procedure StartImport(var DMTTable: Record DMTTable; NoUserInteraction_New: Boolean; IsUpdateTask: Boolean)
    var
        start: DateTime;
    begin
        start := CurrentDateTime;
        NoUserInteraction := NoUserInteraction_New;
        CheckBufferTableIsNotEmpty(DMTTable);
        CheckMappedFieldsExist(DMTTable);

        StartImportForCustomBufferTable(DMTTable, IsUpdateTask);
        StartImportForGenericBufferTable(DMTTable, IsUpdateTask);

        UpdateProcessingTime(DMTTable, start);
    end;

    procedure ProcessFullBuffer(var DMTTable: Record DMTTable; IsUpdateTask: Boolean)
    var
        DMTErrorLog: Record DMTErrorLog;
        TempDMTField_COLLECTION: Record "DMTField" temporary;
        GenBuffTable: Record DMTGenBuffTable;
        BufferRef, BufferRef2 : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
    begin
        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable);
        LoadFieldMapping(DMTTable, IsUpdateTask, TempDMTField_COLLECTION);

        // Buffer loop
        if DMTTable.BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files" then begin
            GenBuffTable.InitFirstLineAsCaptions(DMTTable.DataFilePath);
            GenBuffTable.FilterGroup(2);
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterByFileName(DMTTable.DataFilePath);
            GenBuffTable.FilterGroup(0);
            BufferRef.GetTable(GenBuffTable);
        end else
            if DMTTable.BufferTableType = DMTTable.BufferTableType::"Seperate Buffer Table per CSV" then begin
                BufferRef.Open(DMTTable."Buffer Table ID");
            end;
        Commit(); // Runmodal Dialog in Edit View
        EditView(BufferRef, DMTTable);
        BufferRef.findset();
        DMTMgt.ProgressBar_Open(BufferRef, StrSubstNo(ProgressBarText_TitleTok, BufferRef.CAPTION) +
                                                      ProgressBarText_FilterTok +
                                                      ProgressBarText_RecordTok +
                                                      ProgressBarText_DurationTok +
                                                      ProgressBarText_ProgressTok +
                                                      ProgressBarText_TimeRemainingTok);
        DMTMgt.ProgressBar_UpdateControl(1, CONVERTSTR(BufferRef.GETFILTERS, '@', '_'));
        repeat
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2, DMTTable, IsUpdateTask, TempDMTField_COLLECTION);
            DMTMgt.ProgressBar_NextStep();
            DMTMgt.ProgressBar_Update(0, '',
                                      4, DMTMgt.ProgressBar_GetProgress(),
                                      2, STRSUBSTNO('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
                                      3, DMTMgt.ProgressBar_GetTimeElapsed(),
                                      5, DMTMgt.ProgressBar_GetRemainingTime());
            IF DMTMgt.ProgressBar_GetStep() MOD 50 = 0 then
                COMMIT();
        until BufferRef.Next() = 0;
        DMTMgt.ProgressBar_Close();
        DMTErrorLog.OpenListWithFilter(DMTTable, true);
        DMTMgt.GetResultQtyMessage();
    end;

    procedure RetryProcessFullBuffer(var RecIdToProcessList: list of [RecordID]; DMTTable: Record DMTTable; IsUpdateTask: Boolean)
    var
        DMTErrorLog: Record DMTErrorLog;
        TempDMTField_COLLECTION: Record "DMTField" temporary;
        ID: RecordId;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable);
        LoadFieldMapping(DMTTable, IsUpdateTask, TempDMTField_COLLECTION);

        // Buffer loop
        BufferRef.OPEN(DMTTable."Buffer Table ID");
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
            ProcessSingleBufferRecord(BufferRef2, DMTTable, IsUpdateTask, TempDMTField_COLLECTION);
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
        DMTErrorLog.OpenListWithFilter(DMTTable, true);
        DMTMgt.GetResultQtyMessage();
    end;

    procedure LoadFieldMapping(table: Record DMTTable; UseToFieldFilter: Boolean; var TempDMTFields_FOUND: record "DMTField" temporary) OK: Boolean
    var
        field: Record "DMTField";
        tempDMTFields: record "DMTField" temporary;
    begin
        field.FilterBy(table);
        field.SetFilter("Processing Action", '<>%1', field."Processing Action"::Ignore);
        if table.BufferTableType = table.BufferTableType::"Seperate Buffer Table per CSV" then
            field.SetFilter("Source Field No.", '<>0');
        if UseToFieldFilter then
            field.Setfilter("Target Field No.", table.ReadLastFieldUpdateSelection());
        field.FindSet(false, false);  // raise error if empty
        repeat
            tempDMTFields := field;
            tempDMTFields.Insert(false);
        until field.Next() = 0;
        TempDMTFields_FOUND.Copy(tempDMTFields, true);
        OK := TempDMTFields_FOUND.FindFirst();
    end;

    procedure ProcessSingleBufferRecord(BufferRef: RecordRef; DMTTable: Record DMTTable; IsUpdateTask: Boolean; var TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        DMTErrorLog: Record DMTErrorLog;
        TmpTargetRef, TargetRef2 : RecordRef;
        ErrorsExists: Boolean;
        Success: Boolean;
    begin
        DMTErrorLog.DeleteExistingLogForBufferRec(BufferRef);
        TmpTargetRef.OPEN(DMTTable."Target Table ID", TRUE);

        ReplaceBufferValuesBeforeProcessing(BufferRef, TempDMTField_COLLECTION);

        AssignKeyFields(BufferRef, TmpTargetRef, TempDMTField_COLLECTION);
        if TmpTargetRef.Insert(false) then;

        if DMTTable."Import Only New Records" and not IsUpdateTask then
            if TargetRef2.Get(TmpTargetRef.RecordId) then begin
                DMTMgt.UpdateResultQty(true, false);
                exit;
            end;
        // When Update: Copy Fields from existing record to temp RecRef
        if IsUpdateTask then begin
            if TargetRef2.Get(TmpTargetRef.RecordId) then
                DMTMgt.CopyRecordRef(TargetRef2, TmpTargetRef);
        end;

        ValidateNonKeyFieldsAndModify(BufferRef, TmpTargetRef, TempDMTField_COLLECTION);

        ErrorsExists := DMTErrorLog.ErrorsExistFor(BufferRef, TRUE);
        if not ErrorsExists then begin
            Success := DMTMgt.InsertRecFromTmp(BufferRef, TmpTargetRef, DMTTable."Use OnInsert Trigger");
        end;

        DMTMgt.UpdateResultQty(Success, TRUE);
    end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFields(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TmpDMTField: record "DMTField" temporary)
    var
        KeyFieldsFilter: text;
    begin
        KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, true);
        IF NOT TmpTargetRef.ISTEMPORARY then
            ERROR('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpDMTField.Reset();
        TmpDMTField.SetFilter("Target Field No.", KeyFieldsFilter);
        TmpDMTField.findset();
        repeat
            if not IsKnownAutoincrementField(TmpDMTField) then
                DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TmpDMTField."Source Field No.", BufferRef, TmpDMTField."Target Field No.", false);
        until TmpDMTField.Next() = 0;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        ToFieldRef: FieldRef;
        NonKeyFieldsFilter: Text;
    begin
        NonKeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, false);
        TempDMTField_COLLECTION.Reset();
        TempDMTField_COLLECTION.SetFilter("Target Field No.", NonKeyFieldsFilter);
        TempDMTField_COLLECTION.SetCurrentKey("Validation Order");
        if not TempDMTField_COLLECTION.findset() then
            exit; // Required for tables with only key fields
        repeat
            TempDMTField_COLLECTION.CalcFields("Target Field Caption", "Source Field Caption");
            case true of
                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::Ignore):
                    ;
                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::Transfer):
                    if TempDMTField_COLLECTION."Validate Value" then
                        DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempDMTField_COLLECTION)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDMTField_COLLECTION."Source Field No.", BufferRef, TempDMTField_COLLECTION."Target Field No.", true);


                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDMTField_COLLECTION."Target Field No.");
                        if not DMTMgt.EvaluateFieldRef(ToFieldRef, TempDMTField_COLLECTION."Fixed Value", false, false) then
                            Error('Invalid Fixed Value %1', TempDMTField_COLLECTION."Fixed Value");
                        DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempDMTField_COLLECTION."Target Field No.",
                          ToFieldRef.Value,
                          TempDMTField_COLLECTION."Ignore Validation Error");
                    end;
            end
        until TempDMTField_COLLECTION.Next() = 0;
        TmpTargetRef.MODIFY(false);
    end;

    procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef; var DMTTable: Record DMTTable) Continue: Boolean;
    var
        DMTField: Record DMTField;
        GenBuffTable: Record DMTGenBuffTable;
        FPBuilder: FilterPageBuilder;
        Index: Integer;
        PrimaryKeyRef: KeyRef;
        KeyFieldsFilter: Text;
    begin
        FPBuilder.AddTable(BufferRef.CAPTION, BufferRef.NUMBER);// ADD DATAITEM
        IF BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SETVIEW(BufferRef.CAPTION, BufferRef.GETVIEW());

        if DMTTable.BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files" then begin
            KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(DMTTable."Target Table ID", true);
            if DMTField.FilterBy(DMTTable) then begin
                DMTField.setfilter("Target Field No.", KeyFieldsFilter);
                if DMTField.FindSet() then
                    repeat
                        FPBuilder.AddFieldNo(GenBuffTable.TableCaption, DMTField."Source Field No.");
                    until DMTField.Next() = 0;
            end;
        end else begin
            // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
            PrimaryKeyRef := BufferRef.KEYINDEX(1);
            for Index := 1 TO PrimaryKeyRef.FIELDCOUNT DO
                FPBuilder.ADDFIELDNO(BufferRef.CAPTION, PrimaryKeyRef.FieldIndex(Index).NUMBER);
        end;
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RUNMODAL();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.CAPTION));
    end;

    procedure InitFieldFilter(var BuffKeyFieldFilter: Text; var BuffNonKeyFieldFilter: text; DMTTable: Record DMTTable)
    var
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
    begin
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        BuffKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(DMTTable."Target Table ID", true /*include*/);
        BuffNonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(DMTTable."Target Table ID", false /*exclude*/);
    end;

    local procedure EditView(var BufferRef: RecordRef; var DMTTable: Record DMTTable)
    begin

        if NoUserInteraction then
            exit;

        if BufferTableView = '' then begin
            if DMTTable.ReadTableLastView() <> '' then
                BufferRef.SetView(DMTTable.ReadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef, DMTTable) then
                exit;
            if BufferRef.HasFilter then begin
                DMTTable.WriteTableLastView(BufferRef.GetView());
                Commit();
            end;
        end else begin
            BufferRef.SetView(BufferTableView);
        end;
        DMTTable.Find('=');
    end;

    local procedure StartImportForCustomBufferTable(var DMTTable: Record DMTTable; UseToFieldFilter_New: Boolean)
    begin
        if DMTTable.BufferTableType <> DMTTable.BufferTableType::"Seperate Buffer Table per CSV" then
            exit;
        ProcessFullBuffer(DMTTable, UseToFieldFilter_New);
    end;

    local procedure StartImportForGenericBufferTable(var DMTTable: Record DMTTable; UseToFieldFilter_New: Boolean)
    begin
        if DMTTable.BufferTableType <> DMTTable.BufferTableType::"Generic Buffer Table for all Files" then
            exit;
        ProcessFullBuffer(DMTTable, UseToFieldFilter_New);
    end;

    local procedure UpdateProcessingTime(var DMTTable: Record DMTTable; start: DateTime)
    begin
        DMTTable.Get(DMTTable.RecordId);
        DMTTable.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DMTTable.LastImportBy));
        DMTTable.LastImportToTargetAt := CurrentDateTime;
        if DMTTable."Import Duration (Longest)" < (CurrentDateTime - start) then
            DMTTable."Import Duration (Longest)" := (CurrentDateTime - start);
        DMTTable.Modify();
    end;

    local procedure ReplaceBufferValuesBeforeProcessing(var BufferRef: RecordRef; var TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        TempFieldWithReplacementCode: Record "DMTField" temporary;
        ReplacementsHeader: Record DMTReplacementsHeader;
        ToFieldRef: FieldRef;
        ReplaceValueDictionary: Dictionary of [Text, Text];
        NewValue: Text;
    begin
        TempFieldWithReplacementCode.Copy(TempDMTField_COLLECTION, true);
        TempFieldWithReplacementCode.Reset();
        TempFieldWithReplacementCode.SetFilter("Replacements Code", '<>''''');
        if not TempFieldWithReplacementCode.FindSet() then exit;
        repeat
            ReplacementsHeader.Get(TempFieldWithReplacementCode."Replacements Code");
            ReplacementsHeader.loadDictionary(ReplaceValueDictionary);
            ToFieldRef := BufferRef.Field(TempFieldWithReplacementCode."Source Field No.");
            if ReplaceValueDictionary.Get(Format(ToFieldRef.Value), NewValue) then
                if not DMTMgt.EvaluateFieldRef(ToFieldRef, NewValue, false, false) then
                    Error('ReplaceBufferValuesBeforeProcessing EvaluateFieldRef Error "%1"', NewValue);
        until TempFieldWithReplacementCode.Next() = 0;
    end;

    local procedure IsKnownAutoincrementField(var DMTField: Record DMTField temporary) IsAutoincrement: Boolean
    var
        RecordLink: Record "Record Link";
        ReservationEntry: Record "Reservation Entry";
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        ActivityLog: Record "Activity Log";
    begin
        IsAutoincrement := false;
        case true of
            (DMTField."Target Table ID" = RecordLink.RecordId.TableNo) and (DMTField."Target Field No." = RecordLink.FieldNo("Link ID")):
                exit(true);
            (DMTField."Target Table ID" = ReservationEntry.RecordId.TableNo) and (DMTField."Target Field No." = ReservationEntry.FieldNo("Entry No.")):
                exit(true);
            (DMTField."Target Table ID" = ChangeLogEntry.RecordId.TableNo) and (DMTField."Target Field No." = ChangeLogEntry.FieldNo("Entry No.")):
                exit(true);
            (DMTField."Target Table ID" = JobQueueLogEntry.RecordId.TableNo) and (DMTField."Target Field No." = JobQueueLogEntry.FieldNo("Entry No.")):
                exit(true);
            (DMTField."Target Table ID" = ActivityLog.RecordId.TableNo) and (DMTField."Target Field No." = ActivityLog.FieldNo(ID)):
                exit(true);
            else
                exit(false);
        end;

    end;

    procedure CheckBufferTableIsNotEmpty(DMTTable: Record DMTTable)
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Seperate Buffer Table per CSV":
                begin
                    RecRef.OPEN(DMTTable."Buffer Table ID");
                    if RecRef.IsEmpty then
                        ERROR('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.CAPTION, DMTTable."Buffer Table ID");
                end;
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    if not GenBuffTable.FilterByFileName(DMTTable.DataFilePath) then
                        ERROR('Für "%1" wurden keine importierten Daten gefunden', DMTTable.DataFilePath);
                end;
        end;
    end;

    procedure CheckMappedFieldsExist(DMTTable: Record DMTTable)
    var
        DMTField: Record DMTField;
    begin
        DMTField.FilterBy(DMTTable);
        DMTField.SetFilter("Processing Action", '<>%1', DMTField."Processing Action"::Ignore);
        if DMTField.IsEmpty then
            ERROR('Tabelle "%1" enthält kein Feldmapping', DMTTable."Target Table Caption");
    end;


    var
        DMTMgt: Codeunit DMTMgt;
        BufferTableView: Text;
        NoUserInteraction: Boolean;
        ProgressBarText_TitleTok: label '_________________________%1_________________________', Locked = true;
        ProgressBarText_FilterTok: label '\Filter:       ########################################1#';
        ProgressBarText_RecordTok: label '\Record:    ########################################2#';
        ProgressBarText_DurationTok: label '\Duration:        ########################################3#';
        ProgressBarText_ProgressTok: label '\Progress:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@';
        ProgressBarText_TimeRemainingTok: label '\Time Remaining: ########################################5#';
}