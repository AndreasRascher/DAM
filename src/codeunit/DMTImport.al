codeunit 91000 DMTImport
{
    procedure StartImport(DMTTable: Record DMTTable; NoUserInteraction_New: Boolean)
    var
        start: DateTime;
    begin
        start := CurrentDateTime;
        NoUserInteraction := NoUserInteraction_New;
        CheckBufferTableIsNotEmpty(DMTTable);

        StartImportForCustomBufferTable(DMTTable);
        StartImportForGenericBufferTable(DMTTable);

        UpdateProcessingTime(DMTTable, start);
    end;

    procedure ProcessFullBuffer(DMTTable: Record DMTTable)
    var
        DMTErrorLog: Record DMTErrorLog;
        TempDMTField_COLLECTION: Record "DMTField" temporary;
        BufferRef, BufferRef2 : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
    begin
        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable);
        LoadFieldMapping(DMTTable, TempDMTField_COLLECTION);

        EditView(BufferRef, DMTTable);

        // Buffer loop
        BufferRef.OPEN(DMTTable."Buffer Table ID");
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
            ProcessSingleBufferRecord(BufferRef2, DMTTable, TempDMTField_COLLECTION);
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
    end;

    procedure ProcessFullBuffer(var RecIdToProcessList: list of [RecordID]; DMTTable: Record DMTTable)
    var
        DMTErrorLog: Record DMTErrorLog;
        BufferRef: RecordRef;
        BufferRef2: RecordRef;
        ID: RecordId;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
        TempDMTField_COLLECTION: Record "DMTField" temporary;
    begin
        if RecIdToProcessList.Count = 0 then
            Error('Keine Daten zum Verarbeiten');

        InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DMTTable);

        // Buffer loop
        BufferRef.OPEN(DMTTable."Buffer Table ID");
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
            ProcessSingleBufferRecord(BufferRef2, DMTTable, TempDMTField_COLLECTION);
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

    procedure ProcessSingleBufferRecord(BufferRef: RecordRef; DMTTable: Record DMTTable; TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        DMTErrorLog: Record DMTErrorLog;
        // DMTTestRunner: Codeunit DMTTestRunner;
        TargetRef: RecordRef;
        ErrorsExist: Boolean;
        Success: Boolean;
    begin


        // DMTErrorLog.DeleteExistingLogForBufferRec(BufferRef);
        TargetRef.OPEN(DMTTable."To Table ID", TRUE);
        // //ReplaceValuesBeforeProcessing(BufferRef);

        // DMTTestRunner.InitializeValidationTests(BufferRef, DMTTable);
        // DMTTestRunner.Run();
        // DMTTestRunner.GetResultRef(TargetRef);

        AssignKeyFieldsAndInsertTmpRec(BufferRef, TargetRef, TempDMTField_COLLECTION);
        ValidateNonKeyFieldsAndModify(BufferRef, TargetRef, TempDMTField_COLLECTION);

        ErrorsExist := DMTErrorLog.ErrorsExistFor(BufferRef, TRUE);
        if not ErrorsExist then begin
            Success := DMTMgt.InsertRecFromTmp(BufferRef, TargetRef, DMTTable."Use OnInsert Trigger");
        end;

        DMTMgt.UpdateResultQty(Success, TRUE);
    end;

    procedure SetBufferTableView(bufferTableViewNEW: text)
    begin
        BufferTableView := bufferTableViewNEW;
    end;

    procedure AssignKeyFieldsAndInsertTmpRec(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TmpDMTField: record "DMTField" temporary)
    var
        KeyFieldsFilter: text;
    begin
        KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, true);
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

    procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; VAR TmpTargetRef: RecordRef; var TempDMTField_COLLECTION: Record "DMTField" temporary)
    var
        ToFieldRef: FieldRef;
        NonKeyFieldsFilter: Text;
    begin
        NonKeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TmpTargetRef.Number, false);
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

    procedure InitFieldFilter(var BuffKeyFieldFilter: Text; var BuffNonKeyFieldFilter: text; DMTTable: Record DMTTable)
    // var
    //     APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
    begin
        // APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
        BuffKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(DMTTable."To Table ID", true /*include*/);
        BuffNonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(DMTTable."To Table ID", false /*exclude*/);
    end;

    local procedure EditView(var BufferRef: RecordRef; DMTTable: Record DMTTable)
    begin

        if NoUserInteraction then
            exit;

        if BufferTableView = '' then begin
            ;
            if DMTTable.LoadTableLastView() <> '' then
                BufferRef.SetView(DMTTable.LoadTableLastView());

            if not ShowRequestPageFilterDialog(BufferRef) then
                exit;

            DMTTable.SaveTableLastView(BufferRef.GetView());
        end else begin
            BufferRef.SetView(BufferTableView);
        end;

    end;

    local procedure StartImportForCustomBufferTable(var DMTTable: Record DMTTable)
    begin
        if DMTTable.BufferTableType <> DMTTable.BufferTableType::"Custom Buffer Table per file" then
            exit;
        ProcessFullBuffer(DMTTable);
    end;

    local procedure StartImportForGenericBufferTable(var DMTTable: Record DMTTable)
    begin
        if DMTTable.BufferTableType <> DMTTable.BufferTableType::"Generic Buffer Table for all Files" then
            exit;
        ProcessFullBuffer(DMTTable);
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

    procedure CheckBufferTableIsNotEmpty(DMTTable: Record DMTTable)
    var
        GenBuffTable: Record DMTGenBuffTable;
        RecRef: RecordRef;
    begin
        case DMTTable.BufferTableType of
            DMTTable.BufferTableType::"Custom Buffer Table per file":
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


    var
        DMTMgt: Codeunit DMTMgt;
        BufferTableView: Text;
        NoUserInteraction: Boolean;
}