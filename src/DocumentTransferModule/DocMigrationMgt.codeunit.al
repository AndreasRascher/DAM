codeunit 110008 DMTRunDocMigration
{
    trigger OnRun()
    begin
        Start(DocMigrationStructureGlobal);
    end;

    local procedure Start(DocMigration: Record DMTDocMigration)
    var
        rootNode: Record DMTDocMigration;
        dataFile: Record DMTDataFile;
        log: Codeunit DMTLog;
        progressDialog: Codeunit DMTProgressDialog;
        migrate: Codeunit DMTMigrate;
        docMigrationSubscriber: Codeunit DMTDocMigrSubscriber;
        bufferRef_Root: RecordRef;
        RecIDsToProcessPerRootRecord: Dictionary of [Integer, List of [RecordId]];
    begin
        if not FindDocMigrationStructureRoot(rootNode, DocMigration) then
            Error('Keine Start Tabelle gefunden');

        docMigrationSubscriber.Bind();
        InitBufferRefForDocMigrationTableLine(bufferRef_Root, rootNode);
        dataFile.Get(rootNode."DataFile ID");


        ProgressDialog.SaveCustomStartTime(Enum::DMTProgressControlType::Progress);
        ProgressDialog.SetTotalSteps('Process', bufferRef_Root.Count);
        ProgressDialog.AppendTextLine(ProgressBarTitle);
        ProgressDialog.AppendText('\Filter:');
        ProgressDialog.AddField(42, Enum::DMTProgressControlType::"Filter");
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Record:');
        ProgressDialog.AddField(42, Enum::DMTProgressControlType::NoofRecord);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + DurationLbl + ':');
        ProgressDialog.AddField(42, Enum::DMTProgressControlType::"Duration");
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\Progress:');
        ProgressDialog.AddBar(42, Enum::DMTProgressControlType::Progress);
        ProgressDialog.AppendTextLine('');
        ProgressDialog.AppendText('\' + TimeRemainingLbl + ':');
        ProgressDialog.AddField(42, Enum::DMTProgressControlType::TimeRemaining);
        ProgressDialog.AppendTextLine('');

        if bufferRef_Root.FindSet(false, false) then begin
            log.InitNewProcess(enum::DMTLogUsage::"Process Buffer - Document Migration", dataFile);
            ProgressDialog.Open();
            ProgressDialog.UpdateFieldControl(Enum::DMTProgressControlType::"Filter", ConvertStr(bufferRef_Root.GetFilters, '@', '_'));
            repeat
                Clear(RecIDsToProcessPerRootRecord);
                CollectRecIdsInStructure(rootNode, bufferRef_Root, RecIDsToProcessPerRootRecord);
                MigrateRecords(rootNode.DeleteRecordIfExits, log, RecIDsToProcessPerRootRecord);
                progressDialog.NextStep(migrate.StepIndex_Process());
                progressDialog.u
            until bufferRef_Root.Next() = 0;
            progressDialog.Close();
            // Log am Ende schreiben
            log.CreateSummary();
            log.ShowLogForCurrentProcess();
        end;
    end;

    local procedure CollectRecIdsInStructure(Node: Record DMTDocMigration; parentRef: RecordRef; var RecIDsToProcess: Dictionary of [Integer, List of [RecordId]])
    var
        NextNode: Record DMTDocMigration;
        docMigration_Tables: Record DMTDocMigration;
        childRef: RecordRef;
    begin
        AddRecIDToCollection(RecIDsToProcess, Node, parentRef);
        case true of
            Node.FindSetChildNodes(docMigration_Tables):
                repeat
                    // childRef auf parentref filtern & Einstellungen der DocMigration Line anwenden
                    InitBufferRefForDocMigrationTableLine(childRef, docMigration_Tables);
                    ApplyParentTableRelation(childRef, parentRef, docMigration_Tables);
                    if childRef.FindSet(false, false) then
                        repeat
                            // AddRecIDToCollection(RecIDsToProcess, docMigration_Tables, childRef);
                            CollectRecIdsInStructure(docMigration_Tables, childRef, RecIDsToProcess);
                        until childRef.Next() = 0;
                until docMigration_Tables.Next() = 0;
        end;
        // until childRef.Next() = 0;
        // end else begin
        //     if Node.FindSetChildNodes(docMigration_Tables) then
        //         if docMigration_Tables.FindSet() then
        //             repeat
        //                 CollectRecIdsInStructure(docMigration_Tables, parentRef, false, RecIDsToProcess);
        //             until docMigration_Tables.Next() = 0;
        //     // CollectRecIdsInStructure(Node, parentRef, RecIDsToProcess);
        // end;
        // end;
    end;

    local procedure AddRecIDToCollection(var RecIDsToProcess: Dictionary of [Integer, List of [RecordId]]; Node: Record DMTDocMigration; Ref: RecordRef)
    var
        RecIDList: List of [RecordId];
    begin
        if RecIDsToProcess.Get(Node."Line No.", RecIDList) then;
        RecIDList.Add(Ref.RecordId);
        RecIDsToProcess.Set(Node."Line No.", RecIDList);
    end;

    local procedure InitBufferRefForDocMigrationTableLine(var bufferRef: RecordRef; docMigration: Record DMTDocMigration)
    var
        datafile: Record DMTDataFile;
        FPBuilder: Codeunit DMTFPBuilder;
        tableFilter: Text;
    begin
        Clear(bufferRef);
        docMigration.TestField("Line Type", docMigration."Line Type"::Table);
        FPBuilder.OpenRecRefWithFilters(bufferRef, docMigration."DataFile ID", docMigration.ReadFromBlob(docMigration.FieldNo("Table Filter")));
    end;

    local procedure ApplyParentTableRelation(var bufferRef: RecordRef; var parentRef: RecordRef; DocMigration: Record DMTDocMigration)
    var
        TableRelation: Record DMTDocMigration temporary;
    begin
        if DocMigration.LoadTableRelation(TableRelation) = 0 then
            Error('No Table Relations defined for %1 - %2', DocMigration."Line Type", DocMigration.Description);
        if TableRelation.FindSet() then
            repeat
                bufferRef.Field(TableRelation."Field ID").SetRange(parentRef.Field(TableRelation."Related Field ID"));
            until TableRelation.Next() = 0;
    end;

    local procedure FindDocMigrationStructureRoot(var DocMigration_RootTable: Record DMTDocMigration; DocMigration_Start: Record DMTDocMigration) OK: Boolean
    begin
        if (DocMigration_Start."Line Type" = DocMigration_Start."Line Type"::Structure) then begin
            DocMigration_RootTable.SetRange("Attached to Structure Line No.", DocMigration_Start."Line No.");
            DocMigration_RootTable.SetRange("Line Type", DocMigration_Start."Line Type"::Table);
            OK := DocMigration_RootTable.FindFirst();
        end else begin
            DocMigration_RootTable.SetRange("Attached to Structure Line No.", DocMigration_Start."Attached to Structure Line No.");
            DocMigration_RootTable.SetRange("Line Type", DocMigration_Start."Line Type"::Table);
            OK := DocMigration_RootTable.FindFirst();
        end;
    end;

    local procedure MigrateRecords(DeleteRecordIfExits: Boolean; var log: Codeunit DMTLog; RecIDsToProcessPerRootRecord: Dictionary of [Integer, List of [RecordId]])
    var
        dataFile: Record DMTDataFile;
        docMigration: Record DMTDocMigration;
        TmpFieldMapping: Record DMTFieldMapping temporary;
        DMTMgt: Codeunit DMTMgt;
        migrate: Codeunit DMTMigrate;
        SourceRecID, TargetRecID : RecordId;
        existingTargetRef, SourceRef : RecordRef;
        docMigrationLineNo: Integer;
        recIdList: List of [RecordId];
    begin
        // DeleteExisting
        if DeleteRecordIfExits then
            foreach docMigrationLineNo in RecIDsToProcessPerRootRecord.Keys do begin
                RecIDsToProcessPerRootRecord.Get(docMigrationLineNo, recIdList);
                docMigration.Get(docMigration.Usage::DocMigrationSetup, docMigrationLineNo);
                datafile.Get(docMigration."DataFile ID");
                dataFile.LoadFieldMapping(TmpFieldMapping);
                foreach SourceRecID in recIdList do begin
                    SourceRef.Get(SourceRecID);
                    TargetRecID := DMTMgt.GetTargetRefRecordID(dataFile, SourceRef, TmpFieldMapping);
                    if existingTargetRef.Get(TargetRecID) then
                        existingTargetRef.Delete();
                end;
            end;
        // MigrateDocumentRecords
        foreach docMigrationLineNo in RecIDsToProcessPerRootRecord.Keys do begin
            RecIDsToProcessPerRootRecord.Get(docMigrationLineNo, recIdList);
            docMigration.Get(docMigration.Usage::DocMigrationSetup, docMigrationLineNo);
            datafile.Get(docMigration."DataFile ID");
            migrate.ListOfBufferRecIDs(recIdList, log, dataFile);
        end;
        // log.CreateNoOfBufferRecordsProcessedEntry(dataFile, recIdList.Count);
    end;

    procedure setDocMigrationStructure(DocMigrationStructure: Record DMTDocMigration)
    begin
        DocMigrationStructureGlobal := DocMigrationStructure;
    end;

    var
        DocMigrationStructureGlobal: Record DMTDocMigration;

}