codeunit 110008 DMTRunDocMigration
{
    trigger OnRun()
    begin
        Start(DocMigrationStructureGlobal);
    end;

    local procedure Start(DocMigration: Record DMTDocMigration)
    var
        rootNode: Record DMTDocMigration;
        log: Codeunit DMTLog;
        bufferRef_Root: RecordRef;
        RecIDsToProcessPerRootRecord: Dictionary of [Integer, List of [RecordId]];
    begin
        if not FindDocMigrationStructureRoot(rootNode, DocMigration) then
            Error('Keine Start Tabelle gefunden');
        InitBufferRefForDocMigrationTableLine(bufferRef_Root, rootNode);
        if bufferRef_Root.FindSet(false, false) then
            repeat
                Clear(RecIDsToProcessPerRootRecord);
                CollectRecIdsInStructure(rootNode, bufferRef_Root, RecIDsToProcessPerRootRecord);
                ToDo: 
                DMTProgressDialog in der bufferRef_Root Schleife initialisieren
                Log am Ende schreiben
                MigrateRecords(rootNode.DeleteRecordIfExits, log, RecIDsToProcessPerRootRecord)
            until bufferRef_Root.Next() = 0;
        log.
    end;

        local procedure CollectRecIdsInStructure(Node: Record DMTDocMigration; parentRef: RecordRef; var RecIDsToProcess: Dictionary of [Integer, List of [RecordId]])
    var
        NextNode: Record DMTDocMigration;
        docMigration_Tables: Record DMTDocMigration;
        emptyRecRef, childRef : RecordRef;
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
        migrate: Codeunit DMTMigrate;
        SourceRecID, TargetRecID : RecordId;
        SourceRef, existingTargetRef : RecordRef;
        docMigrationLineNo: Integer;
        recIdList: List of [RecordId];
        DMTMgt: Codeunit DMTMgt;
        TmpFieldMapping: Record DMTFieldMapping temporary;
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