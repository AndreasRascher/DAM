codeunit 91000 "DAMImport"
{
    procedure ProcessFullBuffer()
    var
        DAMErrorLog: Record DAMErrorLog;
        APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
    begin
        APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();

        LoadFieldMapping(DAMTable);

        BufferRef.OPEN(BufferTableID);
        if DAMTable.LoadTableLastView() <> '' then
            BufferRef.SetView(DAMTable.LoadTableLastView());

        if not ShowRequestPageFilterDialog(BufferRef) then
            exit;

        DAMTable.SaveTableLastView(BufferRef.GetView());

        // Buffer loop
        BufferRef.findset();
        DAMMgt.ProgressBar_Open(BufferRef, '____________________________' + BufferRef.CAPTION + '____________________________' +
                                           '\Filter:       ########################################1#' +
                                           '\Datensatz:    ########################################2#' +
                                           '\Dauer:        ########################################3#' +
                                           '\Fortschritt:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@' +
                                           '\Restlaufzeit: ########################################5#');
        DAMMgt.ProgressBar_UpdateControl(1, CONVERTSTR(BufferRef.GETFILTERS, '@', '_'));
        repeat
            BufferRef2 := BufferRef.DUPLICATE(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2);
            DAMMgt.ProgressBar_NextStep();
            DAMMgt.ProgressBar_Update(0, '',
                                      4, DAMMgt.ProgressBar_GetProgress(),
                                      2, STRSUBSTNO('%1 / %2', DAMMgt.ProgressBar_GetStep(), DAMMgt.ProgressBar_GetTotal()),
                                      3, DAMMgt.ProgressBar_GetTimeElapsed(),
                                      5, DAMMgt.ProgressBar_GetRemainingTime());
            IF DAMMgt.ProgressBar_GetStep() MOD 50 = 0 then
                COMMIT();
        until BufferRef.Next() = 0;
        DAMMgt.ProgressBar_Close();
        DAMErrorLog.OpenListWithFilter(BufferRef);
        DAMMgt.GetResultQtyMessage();
    end;

    procedure LoadFieldMapping(DAMTable: Record DAMTable)
    var
        DAMFields: Record "DAMField";
    begin
        DAMFields.FilterBy(DAMTable);
        DAMFields.FindSet();  // raise error if empty
        if TempDAMFields.IsTemporary then
            TempDAMFields.DeleteAll(false);
        repeat
            TempDAMFields := DAMFields;
            TempDAMFields.Insert(false);
        until DAMFields.Next() = 0;
    end;

    procedure ProcessSingleBufferRecord(BufferRef: RecordRef)
    var
        DAMErrorLog: Record DAMErrorLog;
        TargetRef: RecordRef;
        ErrorsExist: Boolean;
        Success: Boolean;
    begin
        DAMErrorLog.DeleteExistingLogForBufferRec(BufferRef);
        TargetRef.OPEN(DAMTable."To Table ID", TRUE);
        //ReplaceValuesBeforeProcessing(BufferRef);

        AssignKeyFieldsAndInsertTmpRec(BufferRef, TargetRef);
        ValidateNonKeyFieldsAndModify(BufferRef, TargetRef);

        ErrorsExist := DAMErrorLog.ErrorsExistFor(BufferRef, TRUE);
        if not ErrorsExist then begin
            Success := DAMMgt.InsertRecFromTmp(BufferRef, TargetRef, DAMTable."Use OnInsert Trigger");
            if Success then
                TransferFieldsOnAfterInsert(BufferRef, TargetRef);
        end;

        DAMMgt.UpdateResultQty(Success, TRUE);
    end;

    procedure SetObjectIDs(DAMTable_NEW: Record DAMTable)
    begin
        DAMTable.Copy(DAMTable_NEW);
        DAMMgt.CheckBufferTableIsNotEmpty(DAMTable."Buffer Table ID");
        BufferTableID := DAMTable."Buffer Table ID";
    end;

    procedure AssignKeyFieldsAndInsertTmpRec(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef)
    begin
        IF NOT TmpTargetRef.ISTEMPORARY then
            ERROR('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TempDAMFields.Reset();
        TempDAMFields.SetFilter("To Field No.", DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, true /*include*/));
        TempDAMFields.findset();
        repeat
            DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDAMFields."From Field No.", BufferRef, TempDAMFields."To Field No.", false);
        until TempDAMFields.Next() = 0;
        IF TmpTargetRef.INSERT(FALSE) then;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef)
    var
        ToFieldRef: FieldRef;
    begin
        TempDAMFields.Reset();
        TempDAMFields.SetFilter("To Field No.", DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, false /*include*/));
        TempDAMFields.findset();
        repeat
            TempDAMFields.CalcFields("To Field Caption", "From Field Caption");
            case true of
                (TempDAMFields."Fixed Value OnBeforeInsert" <> ''):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDAMFields."To Field No.");
                        if not DAMMgt.EvaluateFieldRef(ToFieldRef, TempDAMFields."Fixed Value OnBeforeInsert", false) then
                            Error('Invalid Fixed Value OnBeforeInsert %1', TempDAMFields."Fixed Value OnBeforeInsert");
                        DAMMgt.ValidateFieldWithValue(TmpTargetRef, TempDAMFields."To Field No.",
                          ToFieldRef.Value,
                          TempDAMFields."Ignore Validation Error");
                    end;

                (TempDAMFields."Processing Action" = TempDAMFields."Processing Action"::Transfer):
                    if TempDAMFields."Validate Value" then
                        DAMMgt.ValidateField(TmpTargetRef, BufferRef, TempDAMFields)
                    else
                        DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDAMFields."From Field No.", BufferRef, TempDAMFields."To Field No.", true);


                (TempDAMFields."Processing Action" = TempDAMFields."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDAMFields."To Field No.");
                        if not DAMMgt.EvaluateFieldRef(ToFieldRef, TempDAMFields."Fixed Value", false) then
                            Error('Invalid Fixed Value %1', TempDAMFields."Fixed Value");
                        DAMMgt.ValidateFieldWithValue(TmpTargetRef, TempDAMFields."To Field No.",
                          ToFieldRef.Value,
                          TempDAMFields."Ignore Validation Error");
                    end;
            end
        until TempDAMFields.Next() = 0;
        TmpTargetRef.MODIFY(TRUE);
    end;

    procedure ShowRequestPageFilterDialog(VAR BufferRef: RecordRef) Continue: Boolean;
    var
        FPBuilder: FilterPageBuilder;
        PrimaryKeyRef: KeyRef;
        Index: Integer;
    begin
        FPBuilder.ADDTABLE(BufferRef.CAPTION, BufferRef.NUMBER);// ADD DATAITEM
        IF BufferRef.HASFILTER then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SETVIEW(BufferRef.CAPTION, BufferRef.GETVIEW());
        // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
        PrimaryKeyRef := BufferRef.KEYINDEX(1);
        for Index := 1 TO PrimaryKeyRef.FIELDCOUNT DO
            FPBuilder.ADDFIELDNO(BufferRef.CAPTION, PrimaryKeyRef.FIELDINDEX(Index).NUMBER);
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RUNMODAL();
        //IF FPBuilder.RUNMODAL then begin
        BufferRef.SETVIEW(FPBuilder.GETVIEW(BufferRef.CAPTION));
        //FilterText := BufferRef.GETFILTERS;
        //end;
    end;

    local procedure TransferFieldsOnAfterInsert(BufferRef: RecordRef; TargetRef: RecordRef): Boolean
    var
        ToFieldRef: FieldRef;
    begin
        TempDAMFields.Reset();
        TempDAMFields.SetFilter("To Field No.", DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, false /*include*/));
        TempDAMFields.SetFilter("Fixed Value OnBeforeInsert", '<>''''');
        if not TempDAMFields.findset() then exit(false);
        repeat
            case true of
                (TempDAMFields."Fixed Value OnBeforeInsert" <> ''):
                    begin
                        ToFieldRef := TargetRef.Field(TempDAMFields."To Field No.");
                        if not DAMMgt.EvaluateFieldRef(ToFieldRef, TempDAMFields."Fixed Value OnBeforeInsert", false) then
                            Error('Invalid Fixed Value OnBeforeInsert %1', TempDAMFields."Fixed Value OnBeforeInsert");
                        DAMMgt.ValidateFieldWithValue(TargetRef, TempDAMFields."To Field No.",
                          ToFieldRef.Value,
                          TempDAMFields."Ignore Validation Error");
                    end;

                (TempDAMFields."Processing Action" = TempDAMFields."Processing Action"::Transfer):
                    if TempDAMFields."Validate Value" then
                        DAMMgt.ValidateField(TargetRef, BufferRef, TempDAMFields)
                    else
                        DAMMgt.AssignFieldWithoutValidate(TargetRef, TempDAMFields."From Field No.", BufferRef, TempDAMFields."To Field No.", true);

                (TempDAMFields."Processing Action" = TempDAMFields."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TargetRef.Field(TempDAMFields."To Field No.");
                        if not DAMMgt.EvaluateFieldRef(ToFieldRef, TempDAMFields."Fixed Value", false) then
                            Error('Invalid Fixed Value %1', TempDAMFields."Fixed Value");
                        DAMMgt.ValidateFieldWithValue(TargetRef, TempDAMFields."To Field No.",
                          ToFieldRef.Value,
                          TempDAMFields."Ignore Validation Error");
                    end;
            end
        until TempDAMFields.Next() = 0;
        TargetRef.MODIFY(TRUE);
    end;

    var
        TempDAMFields: Record "DAMField" temporary;
        DAMTable: Record DAMTable;
        DAMMgt: Codeunit DAMMgt;
        BufferTableID: Integer;

}