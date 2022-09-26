codeunit 110009 DMTImport
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
        DMTTable.CalcFields("No. of Records In Trgt. Table");
    end;

    procedure ProcessFullBuffer(var DMTTable: Record DMTTable; IsUpdateTask: Boolean)
    var
        DMTErrorLog: Record DMTErrorLog;
        TempDMTField_COLLECTION: Record "DMTField" temporary;
        GenBuffTable: Record DMTGenBuffTable;
        BufferRef, BufferRef2 : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
        ProgressBarTitle: Text;
        MaxWith: Integer;
    begin
        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable."Target Table ID");
        LoadFieldMapping(DMTTable, IsUpdateTask, TempDMTField_COLLECTION);

        // Buffer loop
        if DMTTable.BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files" then begin
            GenBuffTable.InitFirstLineAsCaptions(DMTTable.RecordId);
            GenBuffTable.FilterGroup(2);
            GenBuffTable.SetRange(IsCaptionLine, false);
            GenBuffTable.FilterBy(DMTTable);
            GenBuffTable.FilterGroup(0);
            BufferRef.GetTable(GenBuffTable);
        end else
            if DMTTable.BufferTableType = DMTTable.BufferTableType::"Seperate Buffer Table per CSV" then begin
                BufferRef.Open(DMTTable."Buffer Table ID");
            end;
        Commit(); // Runmodal Dialog in Edit View
        if not EditView(BufferRef, DMTTable) then
            exit;
        BufferRef.findset();
        ProgressBarTitle := DMTTable."Target Table Caption";
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
            // TODO Test(BufferRef2, DMTTable, IsUpdateTask, TempDMTField_COLLECTION);
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

        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable."Target Table ID");
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

    // procedure RetryProcessFullBuffer(var RecIdToProcessList: list of [RecordID]; DataFile: Record DMTDataFile; IsUpdateTask: Boolean)
    // var
    //     DMTErrorLog: Record DMTErrorLog;
    //     FieldMapping_COLLECTION: Record "DMTFieldMapping" temporary;
    //     ID: RecordId;
    //     BufferRef: RecordRef;
    //     BufferRef2: RecordRef;
    //     KeyFieldsFilter: Text;
    //     NonKeyFieldsFilter: Text;
    // begin
    //     if RecIdToProcessList.Count = 0 then
    //         Error('Keine Daten zum Verarbeiten');

    //     InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DataFile."Target Table ID");
    //     LoadFieldMapping(DataFile, IsUpdateTask, FieldMapping_COLLECTION);

    //     // Buffer loop
    //     BufferRef.OPEN(DataFile."Buffer Table ID");
    //     ID := RecIdToProcessList.Get(1);
    //     BufferRef.get(ID);
    //     DMTMgt.ProgressBar_Open(RecIdToProcessList.Count,
    //      StrSubstNo(ProgressBarText_TitleTok, BufferRef.CAPTION) +
    //      ProgressBarText_FilterTok +
    //      ProgressBarText_RecordTok +
    //      ProgressBarText_DurationTok +
    //      ProgressBarText_ProgressTok +
    //      ProgressBarText_TimeRemainingTok);
    //     DMTMgt.ProgressBar_UpdateControl(1, 'Error');
    //     foreach ID in RecIdToProcessList do begin
    //         BufferRef.get(ID);
    //         BufferRef2 := BufferRef.DUPLICATE(); // Variant + Events = Call By Reference 
    //         ProcessSingleBufferRecord(BufferRef2, DataFile, IsUpdateTask, FieldMapping_COLLECTION);
    //         DMTMgt.ProgressBar_NextStep();
    //         DMTMgt.ProgressBar_Update(0, '',
    //                                   4, DMTMgt.ProgressBar_GetProgress(),
    //                                   2, STRSUBSTNO('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
    //                                   3, DMTMgt.ProgressBar_GetTimeElapsed(),
    //                                   5, DMTMgt.ProgressBar_GetRemainingTime());
    //         IF DMTMgt.ProgressBar_GetStep() MOD 50 = 0 then
    //             COMMIT();
    //     end;
    //     DMTMgt.ProgressBar_Close();
    //     DMTErrorLog.OpenListWithFilter(DataFile, true);
    //     DMTMgt.GetResultQtyMessage();
    // end;

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

    procedure LoadFieldMapping(DataFile: Record DMTDataFile; UseToFieldFilter: Boolean; var TempFieldMapping_FOUND: record "DMTFieldMapping" temporary) OK: Boolean
    var
        FieldMapping: Record "DMTFieldMapping";
        tempFieldMapping: record "DMTFieldMapping" temporary;
    begin
        DataFile.filterrelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
            FieldMapping.SetFilter("Source Field No.", '<>0');
        if UseToFieldFilter then
            FieldMapping.Setfilter("Target Field No.", DataFile.ReadLastFieldUpdateSelection());
        FieldMapping.FindSet(false, false);  // raise error if empty
        repeat
            tempFieldMapping := FieldMapping;
            tempFieldMapping.Insert(false);
        until FieldMapping.Next() = 0;
        TempFieldMapping_FOUND.Copy(tempFieldMapping, true);
        OK := TempFieldMapping_FOUND.FindFirst();
    end;

    procedure ProcessSingleBufferRecord(BufferRef: RecordRef; DMTTable: Record DMTTable; IsUpdateTask: Boolean; var TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        DMTErrorLog: Record DMTErrorLog;
        TmpTargetRef, TargetRef2 : RecordRef;
        ErrorsExists: Boolean;
        Success: Boolean;
    begin
        DMTErrorLog.DeleteExistingLogForBufferRec(BufferRef);
        Commit(); // End Transaction to avoid locks when debugging
        TmpTargetRef.OPEN(DMTTable."Target Table ID", TRUE);

        ReplaceBufferValuesBeforeProcessing(BufferRef, TempDMTField_COLLECTION);

        AssignKeyFields(BufferRef, TmpTargetRef, TempDMTField_COLLECTION);
        if TmpTargetRef.Insert(false) then;

        if DMTTable."Import Only New Records" and not IsUpdateTask then
            if TargetRef2.Get(TmpTargetRef.RecordId) then begin
                DMTMgt.UpdateResultQty(true, false);
                exit;
            end;
        if DMTTable."Valid Key Fld.Rel. Only" and not IsUpdateTask then
            if not HasValidKeyFldRelations(TmpTargetRef) then begin
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
            Success := DMTMgt.InsertRecFromTmp(TmpTargetRef, DMTTable."Use OnInsert Trigger");
        end;

        DMTMgt.UpdateResultQty(Success, TRUE);
    end;

    // procedure ProcessSingleBufferRecord(BufferRef: RecordRef; DataFile: Record DMTDataFile; IsUpdateTask: Boolean; var TempFieldMapping_COLLECTION: Record "DMTFieldMapping" temporary)
    // var
    //     DMTErrorLog: Record DMTErrorLog;
    //     TmpTargetRef, TargetRef2 : RecordRef;
    //     ErrorsExists: Boolean;
    //     Success: Boolean;
    // begin
    //     DMTErrorLog.DeleteExistingLogForBufferRec(BufferRef);
    //     Commit(); // End Transaction to avoid locks when debugging
    //     TmpTargetRef.OPEN(DataFile."Target Table ID", TRUE);

    //     ReplaceBufferValuesBeforeProcessing(BufferRef, TempFieldMapping_COLLECTION);

    //     AssignKeyFields(BufferRef, TmpTargetRef, TempFieldMapping_COLLECTION);
    //     if TmpTargetRef.Insert(false) then;

    //     if DataFile."Import Only New Records" and not IsUpdateTask then
    //         if TargetRef2.Get(TmpTargetRef.RecordId) then begin
    //             DMTMgt.UpdateResultQty(true, false);
    //             exit;
    //         end;
    //     // if DataFile."Valid Key Fld.Rel. Only" and not IsUpdateTask then
    //     //     if not HasValidKeyFldRelations(TmpTargetRef) then begin
    //     //         DMTMgt.UpdateResultQty(true, false);
    //     //         exit;
    //     //     end;
    //     // When Update: Copy Fields from existing record to temp RecRef
    //     if IsUpdateTask then begin
    //         if TargetRef2.Get(TmpTargetRef.RecordId) then
    //             DMTMgt.CopyRecordRef(TargetRef2, TmpTargetRef);
    //     end;

    //     ValidateNonKeyFieldsAndModify(BufferRef, TmpTargetRef, TempFieldMapping_COLLECTION);

    //     ErrorsExists := DMTErrorLog.ErrorsExistFor(BufferRef, TRUE);
    //     if not ErrorsExists then begin
    //         Success := DMTMgt.InsertRecFromTmp(TmpTargetRef, DataFile."Use OnInsert Trigger");
    //     end;

    //     DMTMgt.UpdateResultQty(Success, TRUE);
    // end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFields(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TmpDMTField: record "DMTField" temporary)
    var
        ToFieldRef: FieldRef;
        KeyFieldsFilter: text;
    begin
        KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, true);
        IF NOT TmpTargetRef.ISTEMPORARY then
            Error('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpDMTField.Reset();
        TmpDMTField.SetFilter("Target Field No.", KeyFieldsFilter);
        TmpDMTField.findset();
        repeat
            if not IsKnownAutoincrementField(TmpDMTField."Target Table ID", TmpDMTField."Target Field No.") then begin
                case TmpDMTField."Processing Action" of
                    TmpDMTField."Processing Action"::Ignore:
                        ;
                    TmpDMTField."Processing Action"::Transfer:
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TmpDMTField."Source Field No.", BufferRef, TmpDMTField."Target Field No.", false);
                    TmpDMTField."Processing Action"::FixedValue:
                        begin
                            ToFieldRef := TmpTargetRef.Field(TmpDMTField."Target Field No.");
                            DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TmpDMTField."Fixed Value");
                        end;
                end;
            end;
        until TmpDMTField.Next() = 0;
    end;

    procedure AssignKeyFields(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TmpFieldMapping: record "DMTFieldMapping" temporary)
    var
        ToFieldRef: FieldRef;
        KeyFieldsFilter: text;
    begin
        KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, true);
        IF NOT TmpTargetRef.ISTEMPORARY then
            Error('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpFieldMapping.Reset();
        TmpFieldMapping.SetFilter("Target Field No.", KeyFieldsFilter);
        TmpFieldMapping.findset();
        repeat
            if not IsKnownAutoincrementField(TmpFieldMapping."Target Table ID", TmpFieldMapping."Target Field No.") then begin
                case TmpFieldMapping."Processing Action" of
                    TmpFieldMapping."Processing Action"::Ignore:
                        ;
                    TmpFieldMapping."Processing Action"::Transfer:
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TmpFieldMapping."Source Field No.", BufferRef, TmpFieldMapping."Target Field No.", false);
                    TmpFieldMapping."Processing Action"::FixedValue:
                        begin
                            ToFieldRef := TmpTargetRef.Field(TmpFieldMapping."Target Field No.");
                            DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TmpFieldMapping."Fixed Value");
                        end;
                end;
            end;
        until TmpFieldMapping.Next() = 0;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TempDMTField: Record "DMTField" temporary)
    var
        ToFieldRef: FieldRef;
        NonKeyFieldsFilter: Text;
    begin
        NonKeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, false);
        TempDMTField.Reset();
        TempDMTField.SetFilter("Target Field No.", NonKeyFieldsFilter);
        TempDMTField.SetCurrentKey("Validation Order");
        if not TempDMTField.findset() then
            exit; // Required for tables with only key fields
        repeat
            //hier: MigrateFieldsaufrufen
            TempDMTField.CalcFields("Target Field Caption");
            case true of
                (TempDMTField."Processing Action" = TempDMTField."Processing Action"::Ignore):
                    ;
                (TempDMTField."Processing Action" = TempDMTField."Processing Action"::Transfer):
                    if TempDMTField."Validate Value" then
                        DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempDMTField)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDMTField."Source Field No.", BufferRef, TempDMTField."Target Field No.", true);

                (TempDMTField."Processing Action" = TempDMTField."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDMTField."Target Field No.");
                        DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TempDMTField."Fixed Value");
                        if TempDMTField."Validate Value" then
                            DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempDMTField."Target Field No.", ToFieldRef.Value, TempDMTField."Ignore Validation Error");
                    end;
            end
        until TempDMTField.Next() = 0;
        TmpTargetRef.Modify(false);
    end;

    // procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TempFieldMapping: Record "DMTFieldMapping" temporary)
    // var
    //     ToFieldRef: FieldRef;
    //     NonKeyFieldsFilter: Text;
    // begin
    //     NonKeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, false);
    //     TempFieldMapping.Reset();
    //     TempFieldMapping.SetFilter("Target Field No.", NonKeyFieldsFilter);
    //     TempFieldMapping.SetCurrentKey("Validation Order");
    //     if not TempFieldMapping.findset() then
    //         exit; // Required for tables with only key fields
    //     repeat
    //         //hier: MigrateFieldsaufrufen
    //         TempFieldMapping.CalcFields("Target Field Caption");
    //         case true of
    //             (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Ignore):
    //                 ;
    //             (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Transfer):
    //                 if TempFieldMapping."Validation Type" = Enum::DMTFieldValidationType::AlwaysValidate then
    //                     DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempFieldMapping)
    //                 else
    //                     DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TempFieldMapping."Source Field No.", BufferRef, TempFieldMapping."Target Field No.", true);

    //             (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::FixedValue):
    //                 begin
    //                     ToFieldRef := TmpTargetRef.Field(TempFieldMapping."Target Field No.");
    //                     DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TempFieldMapping."Fixed Value");
    //                     if TempFieldMapping."Validation Type" = TempFieldMapping."Validation Type"::AlwaysValidate then
    //                         DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempFieldMapping."Target Field No.", ToFieldRef.Value, TempFieldMapping."Ignore Validation Error")
    //                     else
    //                         Error('unhandled Type');
    //                 end;
    //         end
    //     until TempFieldMapping.Next() = 0;
    //     TmpTargetRef.Modify(false);
    // end;

    procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef; var DMTTable: Record DMTTable) Continue: Boolean;
    var
        DMTField: Record DMTField;
        GenBuffTable: Record DMTGenBuffTable;
        FPBuilder: FilterPageBuilder;
        Index: Integer;
        PrimaryKeyRef: KeyRef;
        KeyFieldsFilter: Text;
    begin
        FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
        IF BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.CAPTION, BufferRef.GETVIEW());

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

    local procedure EditView(var BufferRef: RecordRef; var DMTTable: Record DMTTable) Continue: Boolean
    begin
        Continue := true; // Canceling the dialog should stop th process

        if NoUserInteraction then
            exit(Continue);

        if BufferTableView = '' then begin
            if DMTTable.ReadTableLastView() <> '' then
                BufferRef.SetView(DMTTable.ReadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef, DMTTable) then
                exit(false);
            if BufferRef.HasFilter then begin
                DMTTable.WriteTableLastView(BufferRef.GetView());
                Commit();
            end else begin
                DMTTable.WriteTableLastView('');
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

    local procedure ReplaceBufferValuesBeforeProcessing(var BufferRef: RecordRef; var TempMapingField_COLLECTION: Record "DMTFieldMapping" temporary)
    var
        TempFieldWithReplacementCode: Record "DMTField" temporary;
        ReplacementsHeader: Record DMTReplacementsHeader;
        ToFieldRef: FieldRef;
        ReplaceValueDictionary: Dictionary of [Text, Text];
        NewValue: Text;
    begin
        TempFieldWithReplacementCode.Copy(TempMapingField_COLLECTION, true);
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

    local procedure IsKnownAutoincrementField(TargetTableID: Integer; TargetFieldNo: Integer) IsAutoincrement: Boolean
    var
        RecordLink: Record "Record Link";
        ReservationEntry: Record "Reservation Entry";
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        ActivityLog: Record "Activity Log";
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

    // local procedure Test(BufferRef2: RecordRef; var DMTTable: Record DMTTable; IsUpdateTask: Boolean; var TempDMTField_COLLECTION: Record DMTField temporary)
    // var
    //     ProcessRecord: Codeunit DMTProcessRecord;
    //     Success: Boolean;
    // begin
    //     ClearLastError();
    //     ProcessRecord.Initialize(DMTTable, BufferRef2);
    //     Commit();
    //     While not ProcessRecord.Run() do begin
    //         ProcessRecord.LogLastError();
    //     end;
    //     ProcessRecord.SaveRecord();
    // end;

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
                        Error('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.Caption, DMTTable."Buffer Table ID");
                end;
            DMTTable.BufferTableType::"Generic Buffer Table for all Files":
                begin
                    if not GenBuffTable.FilterBy(DMTTable) then
                        Error('Für "%1" wurden keine importierten Daten gefunden', DMTTable.GetDataFilePath());
                end;
        end;
    end;

    procedure CheckMappedFieldsExist(DMTTable: Record DMTTable)
    var
        DMTField: Record DMTField;
    begin
        DMTField.FilterBy(DMTTable);
        DMTField.SetFilter("Processing Action", '<>%1', DMTField."Processing Action"::Ignore);
        DMTTable.Calcfields("Target Table Caption");
        if DMTField.IsEmpty then
            Error('Tabelle "%1" enthält kein Feldmapping', DMTTable."Target Table Caption");
    end;

    procedure CreateSourceToTargetRecIDMapping(DMTTable: Record DMTTable; var NotTransferedRecords: List of [RecordId]) RecordMapping: Dictionary of [RecordId, RecordId]
    var
        TempDMTField: Record DMTField temporary;
        DMTGenBuffTable: Record DMTGenBuffTable;
        SourceRef, TmpTargetRef : RecordRef;
        TargetRef: RecordRef;
    begin
        Clear(NotTransferedRecords);
        Clear(RecordMapping);

        LoadFieldMapping(DMTTable, false, TempDMTField);
        // FindSourceRef - GenBuffer
        if DMTTable.BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files" then begin
            if not DMTGenBuffTable.FindSetLinesByFileNameWithoutCaptionLine(DMTTable.RecordId) then
                exit;
            SourceRef.GetTable(DMTGenBuffTable);
            if SourceRef.IsEmpty then
                exit;
        end;
        // FindSourceRef - CSVBuffer
        if DMTTable.BufferTableType = DMTTable.BufferTableType::"Seperate Buffer Table per CSV" then begin
            SourceRef.Open(DMTTable."Buffer Table ID");
            if SourceRef.IsEmpty then
                exit;
        end;
        // Map RecordIDs
        SourceRef.FindSet(false, false);
        repeat
            Clear(TmpTargetRef);
            TmpTargetRef.Open(DMTTable."Target Table ID", true);
            AssignKeyFields(SourceRef, TmpTargetRef, TempDMTField);
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
        ListIndex, LastIndex : Integer;
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
        BufferTableView: Text;
        NoUserInteraction: Boolean;
        ProgressBarText_TitleTok: label '_________________________%1_________________________', Locked = true;
        ProgressBarText_FilterTok: label '\Filter:       ########################################1#';
        ProgressBarText_RecordTok: label '\Record:    ########################################2#';
        ProgressBarText_DurationTok: label '\Duration:        ########################################3#';
        ProgressBarText_ProgressTok: label '\Progress:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@';
        ProgressBarText_TimeRemainingTok: label '\Time Remaining: ########################################5#';
}