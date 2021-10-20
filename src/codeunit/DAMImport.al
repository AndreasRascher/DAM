codeunit 91000 "DAMImport"
{
    procedure ProcessDAMTable(DAMTable: Record DAMTable; NoUserInteraction_New: Boolean)
    var
        start: DateTime;
    begin
        SetObjectIDs(DAMTable);
        NoUserInteraction := NoUserInteraction_New;
        start := CurrentDateTime;
        ProcessFullBuffer();

        DAMTable.Get(DAMTable.RecordId);
        DAMTable.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DAMTable.LastImportBy));
        DAMTable.LastImportToTargetAt := CurrentDateTime;
        if DAMTable."Import Duration (Longest)" < (CurrentDateTime - start) then
            DAMTable."Import Duration (Longest)" := (CurrentDateTime - start);
        DAMTable.Modify();
    end;

    procedure ProcessFullBuffer()
    var
        DAMErrorLog: Record DAMErrorLog;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
    begin
        InitGlobalParams(BufferRef, KeyFieldsFilter, NonKeyFieldsFilter);

        EditView(BufferRef);

        // Buffer loop
        BufferRef.findset();
        DAMMgt.ProgressBar_Open(BufferRef, '_________________________' + BufferRef.CAPTION + '_________________________' +
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

    procedure ProcessFullBuffer(var RecIdToProcessList: list of [RecordID])
    var
        DAMErrorLog: Record DAMErrorLog;
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
        DAMMgt.ProgressBar_Open(RecIdToProcessList.Count,
         '_________________________' + BufferRef.CAPTION + '_________________________' +
         '\Filter:       ########################################1#' +
         '\Datensatz:    ########################################2#' +
         '\Dauer:        ########################################3#' +
         '\Fortschritt:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@' +
         '\Restlaufzeit: ########################################5#');
        DAMMgt.ProgressBar_UpdateControl(1, 'Error');
        foreach ID in RecIdToProcessList do begin
            BufferRef.get(ID);
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
        end;
        DAMMgt.ProgressBar_Close();
        DAMErrorLog.OpenListWithFilter(BufferRef);
        DAMMgt.GetResultQtyMessage();
    end;

    procedure LoadFieldMapping(DAMTable: Record DAMTable; var TempDAMFields_FOUND: record DAMField temporary) OK: Boolean
    var
        DAMFields: Record "DAMField";
        tempDAMFields: record DAMField temporary;
    begin
        DAMFields.FilterBy(DAMTable);
        DAMFields.FindSet(false, false);  // raise error if empty
        repeat
            tempDAMFields := DAMFields;
            tempDAMFields.Insert(false);
        until DAMFields.Next() = 0;
        TempDAMFields_FOUND.Copy(tempDAMFields, true);
        OK := TempDAMFields_FOUND.FindFirst();
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

        AssignKeyFieldsAndInsertTmpRec(BufferRef, TargetRef, KeyFieldsFilter, TempDAMField_COLLECTION);
        ValidateNonKeyFieldsAndModify(BufferRef, TargetRef);

        ErrorsExist := DAMErrorLog.ErrorsExistFor(BufferRef, TRUE);
        if not ErrorsExist then begin
            Success := DAMMgt.InsertRecFromTmp(BufferRef, TargetRef, DAMTable."Use OnInsert Trigger");
        end;

        DAMMgt.UpdateResultQty(Success, TRUE);
    end;

    procedure SetObjectIDs(DAMTable_NEW: Record DAMTable)
    begin
        DAMTable.Copy(DAMTable_NEW);
        DAMMgt.CheckBufferTableIsNotEmpty(DAMTable."Buffer Table ID");
        BufferTableID := DAMTable."Buffer Table ID";
    end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFieldsAndInsertTmpRec(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; KeyFieldsFilter: text; var TmpDAMField: record DAMField temporary)
    begin
        IF NOT TmpTargetRef.ISTEMPORARY then
            ERROR('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
        TmpDAMField.Reset();
        TmpDAMField.SetFilter("To Field No.", KeyFieldsFilter);
        TmpDAMField.findset();
        repeat
            DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, TmpDAMField."From Field No.", BufferRef, TmpDAMField."To Field No.", false);
        until TmpDAMField.Next() = 0;
        IF TmpTargetRef.INSERT(FALSE) then;
    end;

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef)
    var
        ToFieldRef: FieldRef;
    begin
        TempDAMField_COLLECTION.Reset();
        TempDAMField_COLLECTION.SetFilter("To Field No.", NonKeyFieldsFilter);
        TempDAMField_COLLECTION.findset();
        repeat
            TempDAMField_COLLECTION.CalcFields("To Field Caption", "From Field Caption");
            case true of
                (TempDAMField_COLLECTION."Processing Action" = TempDAMField_COLLECTION."Processing Action"::Transfer):
                    if TempDAMField_COLLECTION."Validate Value" then
                        DAMMgt.ValidateField(TmpTargetRef, BufferRef, TempDAMField_COLLECTION)
                    else
                        DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, TempDAMField_COLLECTION."From Field No.", BufferRef, TempDAMField_COLLECTION."To Field No.", true);


                (TempDAMField_COLLECTION."Processing Action" = TempDAMField_COLLECTION."Processing Action"::FixedValue):
                    begin
                        ToFieldRef := TmpTargetRef.Field(TempDAMField_COLLECTION."To Field No.");
                        if not DAMMgt.EvaluateFieldRef(ToFieldRef, TempDAMField_COLLECTION."Fixed Value", false) then
                            Error('Invalid Fixed Value %1', TempDAMField_COLLECTION."Fixed Value");
                        DAMMgt.ValidateFieldWithValue(TmpTargetRef, TempDAMField_COLLECTION."To Field No.",
                          ToFieldRef.Value,
                          TempDAMField_COLLECTION."Ignore Validation Error");
                    end;
            end
        until TempDAMField_COLLECTION.Next() = 0;
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
        LoadFieldMapping(DAMTable, TempDAMField_COLLECTION);
        BufferRef.OPEN(BufferTableID);
        BuffKeyFieldFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, true /*include*/);
        BuffNonKeyFieldFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, false /*exclude*/);
    end;

    local procedure EditView(var BufferRef: RecordRef)
    begin

        if NoUserInteraction then
            exit;

        if BufferTableView = '' then begin
            if DAMTable.LoadTableLastView() <> '' then
                BufferRef.SetView(DAMTable.LoadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef) then
                exit;

            DAMTable.SaveTableLastView(BufferRef.GetView());
        end else begin
            BufferRef.SetView(BufferTableView);
        end;

    end;


    var
        TempDAMField_COLLECTION: Record "DAMField" temporary;
        DAMTable: Record DAMTable;
        DAMMgt: Codeunit DAMMgt;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
        BufferTableView: Text;
        BufferTableID: Integer;
        NoUserInteraction: Boolean;
}