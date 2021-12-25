codeunit 91000 "DMTImport"
{
    procedure ProcessDMTTable(DMTTable: Record DMTTable; NoUserInteraction_New: Boolean)
    var
        start: DateTime;
    begin
        SetDMTTableToProcess(DMTTable);
        NoUserInteraction := NoUserInteraction_New;
        start := CurrentDateTime;
        ProcessFullBuffer();

        DMTTable.Get(DMTTable.RecordId);
        DMTTable.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DMTTable.LastImportBy));
        DMTTable.LastImportToTargetAt := CurrentDateTime;
        if DMTTable."Import Duration (Longest)" < (CurrentDateTime - start) then
            DMTTable."Import Duration (Longest)" := (CurrentDateTime - start);
        DMTTable.Modify();
    end;

    procedure ProcessFullBuffer()
    var
        DMTErrorLog: Record DMTErrorLog;
        BufferRef, BufferRef2 : RecordRef;
    begin
        InitGlobalParams(BufferRef, KeyFieldsFilter, NonKeyFieldsFilter);

        EditView(BufferRef);

        // Buffer loop
        BufferRef.findset();
        DMTMgt.ProgressBar_Open(BufferRef, '_________________________' + BufferRef.CAPTION + '_________________________' +
                                           '\Filter:       ########################################1#' +
                                           '\Datensatz:    ########################################2#' +
                                           '\Dauer:        ########################################3#' +
                                           '\Fortschritt:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@' +
                                           '\Restlaufzeit: ########################################5#');
        DMTMgt.ProgressBar_UpdateControl(1, CONVERTSTR(BufferRef.GETFILTERS, '@', '_'));
        repeat
            BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2);
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
        DMTErrorLog.OpenListWithFilter(BufferRef);
        DMTMgt.GetResultQtyMessage();
        if (CurrDMTTask."Line No." <> 0) then begin
            CurrDMTTask.get(CurrDMTTask.RecordId);
            CurrDMTTask."No. of Records" := DMTMgt.ProgressBar_GetTotal();
            CurrDMTTask."No. of Records imported" := DMTMgt.GetResultQty_QtySuccess();
            CurrDMTTask."No. of Records failed" := DMTMgt.GetResultQty_QtyFailed();
            CurrDMTTask.Modify();
        end;
    end;

    procedure ProcessFullBuffer(var RecIdToProcessList: list of [RecordID])
    var
        DMTErrorLog: Record DMTErrorLog;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        ID: RecordId;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        InitGlobalParams(BufferRef, KeyFieldsFilter, NonKeyFieldsFilter);

        // Buffer loop
        ID := RecIdToProcessList.Get(1);
        BufferRef.get(ID);
        DMTMgt.ProgressBar_Open(RecIdToProcessList.Count,
         '_________________________' + BufferRef.CAPTION + '_________________________' +
         '\Filter:       ########################################1#' +
         '\Datensatz:    ########################################2#' +
         '\Dauer:        ########################################3#' +
         '\Fortschritt:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@' +
         '\Restlaufzeit: ########################################5#');
        DMTMgt.ProgressBar_UpdateControl(1, 'Error');
        foreach ID in RecIdToProcessList do begin
            BufferRef.get(ID);
            BufferRef2 := BufferRef.DUPLICATE(); // Variant + Events = Call By Reference 
            ProcessSingleBufferRecord(BufferRef2);
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
        DMTErrorLog.OpenListWithFilter(BufferRef);
        DMTMgt.GetResultQtyMessage();
    end;

    procedure LoadFieldMapping(DMTTable: Record DMTTable; var TempDMTFields_FOUND: record "DMTField" temporary) OK: Boolean
    var
        dAMField: Record "DMTField";
        tempDMTFields: record "DMTField" temporary;
    begin
        dAMField.FilterBy(DMTTable);
        dAMField.SetFilter("Processing Action", '<>%1', dAMField."Processing Action"::Ignore);
        dAMField.FindSet(false, false);  // raise error if empty
        repeat
            tempDMTFields := dAMField;
            tempDMTFields.Insert(false);
        until dAMField.Next() = 0;
        TempDMTFields_FOUND.Copy(tempDMTFields, true);
        OK := TempDMTFields_FOUND.FindFirst();
    end;

    procedure ProcessSingleBufferRecord(BufferRef: RecordRef)
    var
        DMTErrorLog: Record DMTErrorLog;
        // DMTTestRunner: Codeunit DMTTestRunner;
        TargetRef: RecordRef;
        ErrorsExist: Boolean;
        Success: Boolean;
    begin


        // DMTErrorLog.DeleteExistingLogForBufferRec(BufferRef);
        TargetRef.OPEN(CurrDMTTable."To Table ID", TRUE);
        // //ReplaceValuesBeforeProcessing(BufferRef);

        // DMTTestRunner.InitializeValidationTests(BufferRef, DMTTable);
        // DMTTestRunner.Run();
        // DMTTestRunner.GetResultRef(TargetRef);

        AssignKeyFieldsAndInsertTmpRec(BufferRef, TargetRef, KeyFieldsFilter, TempDMTField_COLLECTION);
        ValidateNonKeyFieldsAndModify(BufferRef, TargetRef);

        ErrorsExist := DMTErrorLog.ErrorsExistFor(BufferRef, TRUE);
        if not ErrorsExist then begin
            Success := DMTMgt.InsertRecFromTmp(BufferRef, TargetRef, CurrDMTTable."Use OnInsert Trigger");
        end;

        DMTMgt.UpdateResultQty(Success, TRUE);
    end;

    procedure SetDMTTableToProcess(DMTTable_NEW: Record DMTTable)
    begin
        CurrDMTTable.Copy(DMTTable_NEW);
        DMTMgt.CheckBufferTableIsNotEmpty(CurrDMTTable."Buffer Table ID");
        BufferTableID := CurrDMTTable."Buffer Table ID";
    end;

    procedure SetDMTTaskToProcess(DMTTask: record DMTTask)
    begin
        CurrDMTTask := DMTTask;
    end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFieldsAndInsertTmpRec(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; KeyFieldsFilter: text; var TmpDMTField: record "DMTField" temporary)
    begin
        IF NOT TmpTargetRef.ISTEMPORARY then
            ERROR('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpDMTField.Reset();
        TmpDMTField.SetFilter("To Field No.", KeyFieldsFilter);
        TmpDMTField.findset();
        repeat
            DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TmpDMTField."From Field No.", BufferRef, TmpDMTField."To Field No.", false);
        until TmpDMTField.Next() = 0;
        IF TmpTargetRef.INSERT(FALSE) then;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef)
    var
        ToFieldRef: FieldRef;
    begin
        TempDMTField_COLLECTION.Reset();
        TempDMTField_COLLECTION.SetFilter("To Field No.", NonKeyFieldsFilter);
        TempDMTField_COLLECTION.findset();
        repeat
            TempDMTField_COLLECTION.CalcFields("To Field Caption", "From Field Caption");
            case true of
                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::Ignore):
                    ;
                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::Transfer):
                    if TempDMTField_COLLECTION."Validate Value" then
                        DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempDMTField_COLLECTION)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDMTField_COLLECTION."From Field No.", BufferRef, TempDMTField_COLLECTION."To Field No.", true);


                (TempDMTField_COLLECTION."Processing Action" = TempDMTField_COLLECTION."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDMTField_COLLECTION."To Field No.");
                        if not DMTMgt.EvaluateFieldRef(ToFieldRef, TempDMTField_COLLECTION."Fixed Value", false) then
                            Error('Invalid Fixed Value %1', TempDMTField_COLLECTION."Fixed Value");
                        DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempDMTField_COLLECTION."To Field No.",
                          ToFieldRef.Value,
                          TempDMTField_COLLECTION."Ignore Validation Error");
                    end;
            end
        until TempDMTField_COLLECTION.Next() = 0;
        TmpTargetRef.MODIFY(false);
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

    procedure InitGlobalParams(var BufferRef: RecordRef; var BuffKeyFieldFilter: Text; var BuffNonKeyFieldFilter: text)
    // var
    //     APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
    begin
        // APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        LoadFieldMapping(CurrDMTTable, TempDMTField_COLLECTION);
        BufferRef.OPEN(BufferTableID);
        BuffKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, true /*include*/);
        BuffNonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, false /*exclude*/);
    end;

    local procedure EditView(var BufferRef: RecordRef)
    begin

        if NoUserInteraction then
            exit;

        if BufferTableView = '' then begin
            if CurrDMTTable.LoadTableLastView() <> '' then
                BufferRef.SetView(CurrDMTTable.LoadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef) then
                exit;

            CurrDMTTable.SaveTableLastView(BufferRef.GetView());
        end else begin
            BufferRef.SetView(BufferTableView);
        end;

    end;


    var
        TempDMTField_COLLECTION: Record "DMTField" temporary;
        CurrDMTTable: Record DMTTable;
        CurrDMTTask: Record DMTTask;
        DMTMgt: Codeunit DMTMgt;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
        BufferTableView: Text;
        BufferTableID: Integer;
        NoUserInteraction: Boolean;
}