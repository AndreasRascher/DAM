// codeunit 110014 DMTImport
// {
//     procedure RunWithProcessingPlanParams(var ProcessingPlan: Record DMTProcessingPlan)
//     var
//         DataFile: Record DMTDataFile;
//         start: DateTime;
//     begin
//         start := CurrentDateTime;

//         NoUserInteraction := true;
//         DataFile.Get(ProcessingPlan.ID);
//         SourceTableView := ProcessingPlan.ReadSourceTableView();
//         UpdateFieldsFilter := ProcessingPlan.ReadUpdateFieldsFilter();

//         CheckBufferTableIsNotEmpty(DataFile);
//         CheckMappedFieldsExist(DataFile);

//         CurrProcessingPlan := ProcessingPlan;
//         ProcessFullBuffer(DataFile, UpdateFieldsFilter <> '');

//         UpdateProcessingTime(DataFile, start);
//     end;

//     procedure StartImport(var DataFile: Record DMTDataFile; NoUserInteraction_New: Boolean; IsUpdateTask: Boolean; SourceTableView_New: Text; UpdateFieldsFilter_New: Text)
//     var
//         start: DateTime;
//     begin
//         start := CurrentDateTime;
//         NoUserInteraction := NoUserInteraction_New;
//         SourceTableView := SourceTableView_New;
//         UpdateFieldsFilter := UpdateFieldsFilter_New;

//         CheckBufferTableIsNotEmpty(DataFile);
//         CheckMappedFieldsExist(DataFile);

//         ProcessFullBuffer(DataFile, IsUpdateTask);

//         UpdateProcessingTime(DataFile, start);
//         DataFile.CalcFields("No. of Records In Trgt. Table");
//     end;

//     procedure ProcessFullBuffer(var DataFile: Record DMTDataFile; IsUpdateTask: Boolean)
//     var
//         ErrorLog: Record DMTErrorLog;
//         TempFieldMapping: Record DMTFieldMapping temporary;
//         MigrationLib: Codeunit DMTMigrationLib;
//         BufferRef, BufferRef2 : RecordRef;
//         MaxWith: Integer;
//         KeyFieldsFilter: Text;
//         NonKeyFieldsFilter: Text;
//         ProgressBarTitle: Text;
//     begin
//         InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DataFile."Target Table ID");
//         LoadFieldMapping(DataFile, IsUpdateTask, TempFieldMapping);

//         InitBufferRef(DataFile, BufferRef);
//         Commit(); // Runmodal Dialog in Edit View
//         if not EditView(BufferRef, DataFile) then
//             exit;
//         ErrorLog.DeleteExistingLogFor(DataFile);
//         BufferRef.FindSet();
//         DataFile.CalcFields("Target Table Caption");
//         ProgressBarTitle := DataFile."Target Table Caption";
//         if StrLen(ProgressBarTitle) < MaxWith then begin
//             ProgressBarTitle := PadStr('', (StrLen(ProgressBarTitle) - MaxWith) div 2, '_') +
//                                 ProgressBarTitle +
//                                 PadStr('', (StrLen(ProgressBarTitle) - MaxWith) div 2, '_');
//         end;
//         DMTMgt.ProgressBar_Open(BufferRef, ProgressBarTitle +
//                                            ProgressBarText_FilterTok +
//                                            ProgressBarText_RecordTok +
//                                            ProgressBarText_DurationTok +
//                                            ProgressBarText_ProgressTok +
//                                            ProgressBarText_TimeRemainingTok);
//         DMTMgt.ProgressBar_UpdateControl(1, ConvertStr(BufferRef.GetFilters, '@', '_'));
//         repeat
//             BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
//             ProcessSingleBufferRecord(BufferRef2, DataFile, TempFieldMapping, IsUpdateTask);
//             DMTMgt.ProgressBar_NextStep();
//             DMTMgt.ProgressBar_Update(0, '',
//                                       4, DMTMgt.ProgressBar_GetProgress(),
//                                       2, StrSubstNo('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
//                                       3, DMTMgt.ProgressBar_GetTimeElapsed(),
//                                       5, DMTMgt.ProgressBar_GetRemainingTime());
//             if DMTMgt.ProgressBar_GetStep() mod 50 = 0 then
//                 Commit();
//         until BufferRef.Next() = 0;
//         MigrationLib.RunPostProcessingFor(DataFile);
//         DMTMgt.ProgressBar_Close();
//         ErrorLog.OpenListWithFilter(DataFile, true);
//         DMTMgt.GetResultQtyMessage();
//     end;

//     procedure RetryProcessFullBuffer(var RecIdToProcessList: List of [RecordId]; DataFile: Record DMTDataFile; IsUpdateTask: Boolean)
//     var
//         DMTErrorLog: Record DMTErrorLog;
//         TempFieldMapping: Record DMTFieldMapping temporary;
//         ID: RecordId;
//         BufferRef: RecordRef;
//         BufferRef2: RecordRef;
//         KeyFieldsFilter: Text;
//         NonKeyFieldsFilter: Text;
//     begin
//         if RecIdToProcessList.Count = 0 then
//             Error('Keine Daten zum Verarbeiten');

//         InitFieldFilter(KeyFieldsFilter, NonKeyFieldsFilter, DataFile."Target Table ID");
//         LoadFieldMapping(DataFile, IsUpdateTask, TempFieldMapping);

//         // Buffer loop
//         BufferRef.Open(DataFile."Buffer Table ID");
//         ID := RecIdToProcessList.Get(1);
//         BufferRef.Get(ID);
//         DMTMgt.ProgressBar_Open(RecIdToProcessList.Count,
//          StrSubstNo(ProgressBarText_TitleTok, BufferRef.Caption) +
//          ProgressBarText_FilterTok +
//          ProgressBarText_RecordTok +
//          ProgressBarText_DurationTok +
//          ProgressBarText_ProgressTok +
//          ProgressBarText_TimeRemainingTok);
//         DMTMgt.ProgressBar_UpdateControl(1, 'Error');
//         foreach ID in RecIdToProcessList do begin
//             BufferRef.Get(ID);
//             BufferRef2 := BufferRef.Duplicate(); // Variant + Events = Call By Reference 
//             ProcessSingleBufferRecord(BufferRef2, DataFile, TempFieldMapping, IsUpdateTask);
//             DMTMgt.ProgressBar_NextStep();
//             DMTMgt.ProgressBar_Update(0, '',
//                                       4, DMTMgt.ProgressBar_GetProgress(),
//                                       2, StrSubstNo('%1 / %2', DMTMgt.ProgressBar_GetStep(), DMTMgt.ProgressBar_GetTotal()),
//                                       3, DMTMgt.ProgressBar_GetTimeElapsed(),
//                                       5, DMTMgt.ProgressBar_GetRemainingTime());
//             if DMTMgt.ProgressBar_GetStep() mod 50 = 0 then
//                 Commit();
//         end;
//         DMTMgt.ProgressBar_Close();
//         DMTErrorLog.OpenListWithFilter(DataFile, true);
//         DMTMgt.GetResultQtyMessage();
//     end;

//     procedure LoadFieldMapping(DataFile: Record DMTDataFile; UseToFieldFilter: Boolean; var TempFieldMapping: Record DMTFieldMapping temporary) OK: Boolean
//     var
//         FieldMapping: Record DMTFieldMapping;
//         FieldMapping_ProcessingPlan: Record DMTFieldMapping temporary;
//     begin
//         DataFile.FilterRelated(FieldMapping);
//         FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
//         if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then
//             FieldMapping.SetFilter("Source Field No.", '<>0');

//         if UpdateFieldsFilter <> '' then begin // Scope ProcessingPlan
//             FieldMapping.SetFilter("Target Field No.", UpdateFieldsFilter);
//         end else
//             if UseToFieldFilter then  // Scope DataFileCard
//                 FieldMapping.SetFilter("Target Field No.", DataFile.ReadLastFieldUpdateSelection());
//         FieldMapping.CopyToTemp(TempFieldMapping);
//         // Apply Processing Plan Settings
//         if CurrProcessingPlan."Line No." <> 0 then begin
//             CurrProcessingPlan.ConvertDefaultValuesViewToFieldLines(FieldMapping_ProcessingPlan);
//             if FieldMapping_ProcessingPlan.FindSet() then
//                 repeat
//                     TempFieldMapping.Get(FieldMapping_ProcessingPlan.RecordId);
//                     TempFieldMapping := FieldMapping_ProcessingPlan;
//                     TempFieldMapping.Modify()
// until FieldMapping_ProcessingPlan.Next() = 0;
//         end;

//         OK := TempFieldMapping.FindFirst();
//     end;

//     procedure AssignKeyFields(SourceRef: RecordRef; var TmpTargetRef: RecordRef; var TmpFieldMapping: Record DMTFieldMapping temporary)
//     var
//         ToFieldRef: FieldRef;
//     begin
//         if not TmpTargetRef.IsTemporary then
//             Error('AssignKeyFieldsAndInsertTmpRec - Temporay Record expected');
//         TmpFieldMapping.Reset();
//         TmpFieldMapping.SetRange("Is Key Field(Target)", true);
//         TmpFieldMapping.FindSet();
//         repeat
//             if not IsKnownAutoincrementField(TmpFieldMapping."Target Table ID", TmpFieldMapping."Target Field No.") then begin
//                 case TmpFieldMapping."Processing Action" of
//                     TmpFieldMapping."Processing Action"::Ignore:
//                         ;
//                     TmpFieldMapping."Processing Action"::Transfer:
//                         DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, SourceRef, TmpFieldMapping, false);
//                     TmpFieldMapping."Processing Action"::FixedValue:
//                         begin
//                             ToFieldRef := TmpTargetRef.Field(TmpFieldMapping."Target Field No.");
//                             DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TmpFieldMapping."Fixed Value");
//                         end;
//                 end;
//             end;
//         until TmpFieldMapping.Next() = 0;
//     end;

//     procedure ValidateNonKeyFieldsAndModify(BufferRef: RecordRef; var TmpTargetRef: RecordRef; var TempFieldMapping: Record DMTFieldMapping temporary)
//     var
//         ToFieldRef: FieldRef;
//     begin
//         TempFieldMapping.Reset();
//         TempFieldMapping.SetRange("Is Key Field(Target)", false);
//         TempFieldMapping.SetCurrentKey("Validation Order");
//         if not TempFieldMapping.FindSet() then
//             exit; // Required for tables with only key fields
//         repeat
//             //hier: MigrateFieldsaufrufen
//             TempFieldMapping.CalcFields("Target Field Caption");
//             case true of
//                 (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Ignore):
//                     ;
//                 (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::Transfer):
//                     if TempFieldMapping."Validation Type" = Enum::DMTFieldValidationType::AlwaysValidate then
//                         DMTMgt.ValidateField(TmpTargetRef, BufferRef, TempFieldMapping)
//                     else
//                         DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, BufferRef, TempFieldMapping, true);

//                 (TempFieldMapping."Processing Action" = TempFieldMapping."Processing Action"::FixedValue):
//                     begin
//                         ToFieldRef := TmpTargetRef.Field(TempFieldMapping."Target Field No.");
//                         DMTMgt.AssignFixedValueToFieldRef(ToFieldRef, TempFieldMapping."Fixed Value");
//                         if TempFieldMapping."Validation Type" = TempFieldMapping."Validation Type"::AlwaysValidate then
//                             DMTMgt.ValidateFieldWithValue(TmpTargetRef, TempFieldMapping."Target Field No.", ToFieldRef.Value, TempFieldMapping."Ignore Validation Error")
//                         else
//                             Error('unhandled Type');
//                     end;
//             end
//         until TempFieldMapping.Next() = 0;
//         TmpTargetRef.Modify(false);
//     end;

//     procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef; var DataFile: Record DMTDataFile) Continue: Boolean;
//     var
//         FieldMapping: Record DMTFieldMapping;
//         GenBuffTable: Record DMTGenBuffTable;
//         FPBuilder: FilterPageBuilder;
//         Index: Integer;
//         PrimaryKeyRef: KeyRef;
//         Debug: Text;
//     begin
//         FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
//         if BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
//             FPBuilder.SetView(BufferRef.Caption, BufferRef.GetView());

//         if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
//             if DataFile.FilterRelated(FieldMapping) then begin
//                 // Init Captions
//                 if GenBuffTable.FilterBy(DataFile) then
//                     if GenBuffTable.FindFirst() then
//                         GenBuffTable.InitFirstLineAsCaptions(GenBuffTable);
//                 Debug := GenBuffTable.FieldCaption(Fld001);
//                 FieldMapping.SetRange("Is Key Field(Target)", true);
//                 if FieldMapping.FindSet() then
//                     repeat
//                         FPBuilder.AddFieldNo(GenBuffTable.TableCaption, FieldMapping."Source Field No.");
//                     until FieldMapping.Next() = 0;
//             end;
//         end else begin
//             // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
//             PrimaryKeyRef := BufferRef.KeyIndex(1);
//             for Index := 1 to PrimaryKeyRef.FieldCount do
//                 FPBuilder.AddFieldNo(BufferRef.Caption, PrimaryKeyRef.FieldIndex(Index).Number);
//         end;
//         // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
//         Continue := FPBuilder.RunModal();
//         BufferRef.SetView(FPBuilder.GetView(BufferRef.Caption));
//     end;

//     procedure InitFieldFilter(var BuffKeyFieldFilter: Text; var BuffNonKeyFieldFilter: Text; TargetTableID: Integer)
//     var
//         APIUpdRefFieldsBinder: Codeunit "API - Upd. Ref. Fields Binder";
//     begin
//         APIUpdRefFieldsBinder.UnBindApiUpdateRefFields();
//         BuffKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TargetTableID, true /*include*/);
//         BuffNonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(TargetTableID, false /*exclude*/);
//     end;

//     local procedure EditView(var BufferRef: RecordRef; var DMTDataFile: Record DMTDataFile) Continue: Boolean
//     begin
//         Continue := true; // Canceling the dialog should stop th process

//         if NoUserInteraction then begin
//             if SourceTableView <> '' then
//                 BufferRef.SetView(SourceTableView);
//             exit(Continue);
//         end;

//         if DMTDataFile.ReadLastSourceTableView() <> '' then
//             BufferRef.SetView(DMTDataFile.ReadLastSourceTableView());

//         if not ShowRequestPageFilterDialog(BufferRef, DMTDataFile) then
//             exit(false);
//         if BufferRef.HasFilter then begin
//             DMTDataFile.WriteSourceTableView(BufferRef.GetView());
//             Commit();
//         end else begin
//             DMTDataFile.WriteSourceTableView('');
//             Commit();
//         end;

//         DMTDataFile.Find('=');
//     end;

//     local procedure UpdateProcessingTime(var DMTDataFile: Record DMTDataFile; start: DateTime)
//     begin
//         DMTDataFile.Get(DMTDataFile.RecordId);
//         DMTDataFile.LastImportBy := CopyStr(UserId, 1, MaxStrLen(DMTDataFile.LastImportBy));
//         DMTDataFile.LastImportToTargetAt := CurrentDateTime;
//         if DMTDataFile."Import Duration (Target)" < (CurrentDateTime - start) then
//             DMTDataFile."Import Duration (Target)" := (CurrentDateTime - start);
//         DMTDataFile.Modify();
//     end;

//     local procedure IsKnownAutoincrementField(TargetTableID: Integer; TargetFieldNo: Integer) IsAutoincrement: Boolean
//     var
//         ActivityLog: Record "Activity Log";
//         ChangeLogEntry: Record "Change Log Entry";
//         JobQueueLogEntry: Record "Job Queue Log Entry";
//         RecordLink: Record "Record Link";
//         ReservationEntry: Record "Reservation Entry";
//     begin
//         IsAutoincrement := false;
//         case true of
//             (TargetTableID = RecordLink.RecordId.TableNo) and (TargetFieldNo = RecordLink.FieldNo("Link ID")):
//                 exit(true);
//             (TargetTableID = ReservationEntry.RecordId.TableNo) and (TargetFieldNo = ReservationEntry.FieldNo("Entry No.")):
//                 exit(true);
//             (TargetTableID = ChangeLogEntry.RecordId.TableNo) and (TargetFieldNo = ChangeLogEntry.FieldNo("Entry No.")):
//                 exit(true);
//             (TargetTableID = JobQueueLogEntry.RecordId.TableNo) and (TargetFieldNo = JobQueueLogEntry.FieldNo("Entry No.")):
//                 exit(true);
//             (TargetTableID = ActivityLog.RecordId.TableNo) and (TargetFieldNo = ActivityLog.FieldNo(ID)):
//                 exit(true);
//             else
//                 exit(false);
//         end;

//     end;

//     local procedure HasValidKeyFldRelations(var TmpTargetRef: RecordRef): Boolean
//     var
//         RelatedRef: RecordRef;
//         FldRef: FieldRef;
//         KeyFieldIndex: Integer;
//         KeyRef: KeyRef;
//         Debug: List of [Text];
//     begin
//         KeyRef := TmpTargetRef.KeyIndex(1);
//         for KeyFieldIndex := 1 to KeyRef.FieldCount do begin
//             FldRef := KeyRef.FieldIndex(KeyFieldIndex);
//             Debug.Add('FieldName:' + FldRef.Name);
//             if FldRef.Relation <> 0 then begin
//                 Debug.Add('Relation' + Format(FldRef.Relation));
//                 RelatedRef.Open(FldRef.Relation);
//                 case true of
//                     (RelatedRef.KeyIndex(1).FieldCount = 2) and (KeyRef.FieldCount = 3):
//                         begin
//                             RelatedRef.Field(RelatedRef.KeyIndex(1).FieldIndex(1).Number).SetRange(KeyRef.FieldIndex(1).Value);
//                             RelatedRef.Field(RelatedRef.KeyIndex(1).FieldIndex(2).Number).SetRange(KeyRef.FieldIndex(2).Value);
//                             if RelatedRef.FindFirst() then exit(true);
//                         end;
//                     else
//                         Error('HasValidKeyFldRelations - Unhandled Case');
//                 end;
//             end;
//         end;
//     end;

//     local procedure ProcessSingleBufferRecord(BufferRef2: RecordRef; var DMTDataFile: Record DMTDataFile; var TempFieldMapping: Record DMTFieldMapping; UpdateExistingRecordsOnly: Boolean)
//     var
//         ErrorLog: Record DMTErrorLog;
//         ProcessRecord: Codeunit DMTProcessRecord;
//         HasErrors: Boolean;
//     begin
//         ClearLastError();
//         // if UpdateExistingRecordsOnly then  // auskommentiert, da sonst die Fehler nicht gelöscht werden
//         ErrorLog.DeleteExistingLogFor(BufferRef2);
//         ProcessRecord.InitFieldTransfer(DMTDataFile, TempFieldMapping, BufferRef2, UpdateExistingRecordsOnly);
//         Commit();
//         while not ProcessRecord.Run() do begin
//             ProcessRecord.LogLastError();
//         end;
//         ProcessRecord.InitInsert();
//         Commit();
//         if not ProcessRecord.Run() then
//             ProcessRecord.LogLastError();
//         HasErrors := ProcessRecord.SaveErrorLog();
//         DMTMgt.UpdateResultQty(not HasErrors, true);
//     end;

//     procedure InitBufferRef(var DataFile: Record DMTDataFile; var BufferRef: RecordRef)
//     var
//         GenBuffTable: Record DMTGenBuffTable;
//     begin
//         if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
//             // GenBuffTable.InitFirstLineAsCaptions(DMTDataFile);
//             GenBuffTable.FilterGroup(2);
//             GenBuffTable.SetRange(IsCaptionLine, false);
//             GenBuffTable.FilterBy(DataFile);
//             GenBuffTable.FilterGroup(0);
//             BufferRef.GetTable(GenBuffTable);
//         end else
//             if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then begin
//                 BufferRef.Open(DataFile."Buffer Table ID");
//             end;
//     end;

//     procedure CheckBufferTableIsNotEmpty(DataFile: Record DMTDataFile)
//     var
//         GenBuffTable: Record DMTGenBuffTable;
//         RecRef: RecordRef;
//     begin
//         case DataFile.BufferTableType of
//             DataFile.BufferTableType::"Seperate Buffer Table per CSV":
//                 begin
//                     RecRef.Open(DataFile."Buffer Table ID");
//                     if RecRef.IsEmpty then
//                         Error('Tabelle "%1" (ID:%2) enthält keine Daten', RecRef.Caption, DataFile."Buffer Table ID");
//                 end;
//             DataFile.BufferTableType::"Generic Buffer Table for all Files":
//                 begin
//                     if not GenBuffTable.FilterBy(DataFile) then
//                         Error('Für "%1" wurden keine importierten Daten gefunden', DataFile.FullDataFilePath());
//                 end;
//         end;
//     end;

//     procedure CheckMappedFieldsExist(DataFile: Record DMTDataFile)
//     var
//         FieldMapping: Record DMTFieldMapping;
//         FieldMappingEmptyErr: Label 'No field mapping found for "%1"', comment = 'Kein Feldmapping gefunden für "%1"';
//     begin
//         DataFile.FilterRelated(FieldMapping);
//         FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
//         DataFile.CalcFields("Target Table Caption");
//         if FieldMapping.IsEmpty then
//             Error(FieldMappingEmptyErr, DataFile.FullDataFilePath());
//     end;

//     procedure CreateSourceToTargetRecIDMapping(DataFile: Record DMTDataFile; var NotTransferedRecords: List of [RecordId]) RecordMapping: Dictionary of [RecordId, RecordId]
//     var
//         TempFieldMapping: Record DMTFieldMapping temporary;
//         DMTGenBuffTable: Record DMTGenBuffTable;
//         SourceRef, TmpTargetRef : RecordRef;
//         TargetRef: RecordRef;
//     begin
//         Clear(NotTransferedRecords);
//         Clear(RecordMapping);

//         LoadFieldMapping(DataFile, false, TempFieldMapping);
//         // FindSourceRef - GenBuffer
//         if DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files" then begin
//             if not DMTGenBuffTable.FindSetLinesByFileNameWithoutCaptionLine(DataFile) then
//                 exit;
//             SourceRef.GetTable(DMTGenBuffTable);
//             if SourceRef.IsEmpty then
//                 exit;
//         end;
//         // FindSourceRef - CSVBuffer
//         if DataFile.BufferTableType = DataFile.BufferTableType::"Seperate Buffer Table per CSV" then begin
//             SourceRef.Open(DataFile."Buffer Table ID");
//             if SourceRef.IsEmpty then
//                 exit;
//         end;
//         // Map RecordIDs
//         SourceRef.FindSet(false, false);
//         repeat
//             Clear(TmpTargetRef);
//             TmpTargetRef.Open(DataFile."Target Table ID", true);
//             AssignKeyFields(SourceRef, TmpTargetRef, TempFieldMapping);
//             if not TargetRef.Get(TmpTargetRef.RecordId) then begin
//                 NotTransferedRecords.Add(TmpTargetRef.RecordId)
//             end else begin
//                 RecordMapping.Add(SourceRef.RecordId, TmpTargetRef.RecordId);
//             end;
//         until SourceRef.Next() = 0;
//     end;

//     procedure FindCollationProblems(RecordMapping: Dictionary of [RecordId, RecordId]) CollationProblems: Dictionary of [RecordId, RecordId]
//     var
//         TargetRecID: RecordId;
//         LastIndex, ListIndex : Integer;
//     begin
//         for ListIndex := 1 to RecordMapping.Values.Count do begin
//             TargetRecID := RecordMapping.Values.Get(ListIndex);
//             LastIndex := RecordMapping.Values.LastIndexOf(TargetRecID);
//             if LastIndex <> ListIndex then begin
//                 CollationProblems.Add(RecordMapping.Keys.Get(ListIndex), RecordMapping.Values.Get(ListIndex));
//                 CollationProblems.Add(RecordMapping.Keys.Get(LastIndex), RecordMapping.Values.Get(LastIndex));
//             end;
//         end;
//     end;

//     var
//         DMTMgt: Codeunit DMTMgt;
//         #region GlobalProcessionOptions
//         NoUserInteraction: Boolean;
//         UpdateFieldsFilter: Text;
//         SourceTableView: Text;
//         CurrProcessingPlan: Record DMTProcessingPlan;
//         #endregion GlobalProcessionOptions
//         ProgressBarText_DurationTok: Label '\Duration:        ########################################3#';
//         ProgressBarText_FilterTok: Label '\Filter:       ########################################1#';
//         ProgressBarText_ProgressTok: Label '\Progress:  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@4@';
//         ProgressBarText_RecordTok: Label '\Record:    ########################################2#';
//         ProgressBarText_TimeRemainingTok: Label '\Time Remaining: ########################################5#';
//         ProgressBarText_TitleTok: Label '_________________________%1_________________________', Locked = true;
// }