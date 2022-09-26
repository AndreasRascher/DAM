codeunit 110005 DMTRelationsCheck
{
    procedure FindRelatedTableIDs(DMTTable: Record DMTTable) RelatedTableIDsList: List of [Integer]
    var
        DMTField: Record DMTField;
    begin
        if not DMTField.FilterBy(DMTTable) then
            exit;
        DMTField.SetLoadFields(DMTField."Target Table ID", DMTField."Target Field No.");
        DMTField.FindSet(false, false);
        repeat
            CreateRelatedTableIDsList(DMTField."Target Table ID", DMTField."Target Field No.", RelatedTableIDsList);
        until DMTField.Next() = 0;
    end;

    procedure FindRelatedTableIDs(DataFile: Record DMTDataFile) RelatedTableIDsList: List of [Integer]
    var
        FieldMapping: Record DMTFieldMapping;
    begin
        if not DataFile.FilterRelated(FieldMapping) then
            exit;
        FieldMapping.SetLoadFields(FieldMapping."Target Table ID", FieldMapping."Target Field No.");
        FieldMapping.FindSet(false, false);
        repeat
            CreateRelatedTableIDsList(FieldMapping."Target Table ID", FieldMapping."Target Field No.", RelatedTableIDsList);
        until FieldMapping.Next() = 0;
    end;

    procedure FindUnhandledRelatedTableIDs(DMTTable: Record DMTTable) UnhandledTableIDs: List of [Integer]
    var
        DMTTable2: Record DMTTable;
        TableID: Integer;
        RelatedTableIDs: List of [Integer];
    begin
        RelatedTableIDs := FindRelatedTableIDs(DMTTable);
        if RelatedTableIDs.Count = 0 then exit;
        foreach TableID in RelatedTableIDs do
            if not (TableID >= 2000000000) then
                if not DMTTable2.Get(TableID) then begin
                    UnhandledTableIDs.Add(TableID);
                end;
    end;

    procedure FindUnhandledRelatedTableIDs(DataFile: Record DMTDataFile) UnhandledTableIDs: List of [Integer]
    var
        DataFile2: Record DMTDataFile;
        TableID: Integer;
        RelatedTableIDs: List of [Integer];
    begin
        RelatedTableIDs := FindRelatedTableIDs(DataFile);
        if RelatedTableIDs.Count = 0 then exit;
        foreach TableID in RelatedTableIDs do
            if not (TableID >= 2000000000) then
                if not DataFile2.Get(TableID) then begin
                    UnhandledTableIDs.Add(TableID);
                end;
    end;

    procedure ShowUnhandledTableRelations(DMTTable: Record DMTTable)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        tempAllObjWithCaption: Record AllObjWithCaption temporary;
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        TableIDs := FindUnhandledRelatedTableIDs(DMTTable);
        if TableIDs.Count = 0 then exit;
        foreach TableID in TableIDs do
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableID) then begin
                tempAllObjWithCaption := AllObjWithCaption;
                tempAllObjWithCaption.Insert();
            end;
        if FindUnhandledRelatedTableIDs(DMTTable).count = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        Page.RunModal(Page::"All Objects with Caption", tempAllObjWithCaption);
    end;

    procedure ShowUnhandledTableRelations(DataFile: Record DMTDataFile)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        tempAllObjWithCaption: Record AllObjWithCaption temporary;
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        TableIDs := FindUnhandledRelatedTableIDs(DataFile);
        if TableIDs.Count = 0 then exit;
        foreach TableID in TableIDs do
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableID) then begin
                tempAllObjWithCaption := AllObjWithCaption;
                tempAllObjWithCaption.Insert();
            end;
        if FindUnhandledRelatedTableIDs(DataFile).count = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        Page.RunModal(Page::"All Objects with Caption", tempAllObjWithCaption);
    end;

    procedure ProposeSortOrder()
    var
        DMTTable: Record DMTTable;
        Relations: Dictionary of [Integer, List of [Integer]];
        TableID, RelatedTableID : Integer;
        TableSorting: Dictionary of [Integer, Integer];
        RequiredTablesExist: Boolean;
        Level: Integer;
    begin
        DMTTable.ModifyAll("Sort Order", 0);
        if DMTTable.FindSet() then
            repeat
                Relations.Add(DMTTable."Target Table ID", FindRelatedTableIDs(DMTTable));
            until DMTTable.Next() = 0;
        for Level := 1 to 10 do begin
            // 1. Tables Without Relations
            if Level = 1 then
                foreach TableID in Relations.Keys do
                    if Relations.Get(TableID).Count = 0 then begin
                        TableSorting.Add(TableID, Level);
                        Relations.Remove(TableID);
                    end;
            // 2. Tables on Top of Sorted Tables 
            if Level > 1 then
                foreach TableID in Relations.Keys do begin
                    RequiredTablesExist := true;
                    foreach RelatedTableID in Relations.get(TableID) do begin
                        if not TableSorting.ContainsKey(RelatedTableID) then begin
                            RequiredTablesExist := false;
                            break;
                        end;
                    end;
                    if RequiredTablesExist then begin
                        TableSorting.Add(TableID, Level);
                        Relations.Remove(TableID);
                    end;
                end;
        end;
        // store Sort info
        foreach TableID in TableSorting.Keys do begin
            DMTTable.Get(TableID);
            DMTTable."Sort Order" := TableSorting.Get(TableID);
            DMTTable.Modify();
        end;


    end;

    internal procedure ShowTableRelations(DMTTable: Record DMTTable)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        tempAllObjWithCaption: Record AllObjWithCaption temporary;
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        TableIDs := FindRelatedTableIDs(DMTTable);
        if TableIDs.Count = 0 then exit;
        foreach TableID in TableIDs do
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableID) then begin
                tempAllObjWithCaption := AllObjWithCaption;
                tempAllObjWithCaption.Insert();
            end;
        if FindUnhandledRelatedTableIDs(DMTTable).count = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        Page.RunModal(Page::"All Objects with Caption", tempAllObjWithCaption);
    end;

    internal procedure ShowTableRelations(DataFile: Record DMTDataFile)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        tempAllObjWithCaption: Record AllObjWithCaption temporary;
        TableIDs: List of [Integer];
        TableID: Integer;
    begin
        TableIDs := FindRelatedTableIDs(DataFile);
        if TableIDs.Count = 0 then exit;
        foreach TableID in TableIDs do
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableID) then begin
                tempAllObjWithCaption := AllObjWithCaption;
                tempAllObjWithCaption.Insert();
            end;
        if FindUnhandledRelatedTableIDs(DataFile).count = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);

        Page.RunModal(Page::"All Objects with Caption", tempAllObjWithCaption);
    end;

    local procedure CreateRelatedTableIDsList(TargetTableID: Integer; TargetFieldNo: Integer; var RelatedTableIDsList: List of [Integer])
    var
        TargetField: Record Field;
        TableRelations: record "Table Relations Metadata";
        ExcludeKnownTableIDsFromSearchFilter: Text;
    begin
        if TargetField.Get(TargetTableID, TargetFieldNo) then begin
            TableRelations.SetRange("Table ID", TargetField.TableNo);
            TableRelations.SetRange("Field No.", TargetField."No.");
            TableRelations.setfilter("Related Table ID", ExcludeKnownTableIDsFromSearchFilter);
            if TableRelations.FindSet() then
                repeat
                    if not RelatedTableIDsList.Contains(TableRelations."Related Table ID") then
                        RelatedTableIDsList.Add(TableRelations."Related Table ID");
                    ExcludeKnownTableIDsFromSearchFilter += StrSubstNo('&<>%1', TableRelations."Related Table ID");
                until TableRelations.Next() = 0;
            ExcludeKnownTableIDsFromSearchFilter := ExcludeKnownTableIDsFromSearchFilter.TrimStart('&');
        end;
    end;

    //     procedure ValidateTableRelation(DMTField: Record DMTField; FieldValue: Text)
    //     var
    //         RelationTableNo, RelationFieldNo : Integer;
    //         ErrorText: Text;
    //     begin
    //         if FieldValue = '' then
    //             exit;
    //         if GetSimpleRelationInfo(DMTField, RelationTableNo, RelationFieldNo) then
    //             if not DataExistsInTargetTable(FieldValue, RelationTableNo, RelationFieldNo) then
    //                 if not DataExistsInBufferTable(FieldValue, RelationTableNo, RelationFieldNo) then
    //                     ErrorText := 'ToDo EnumErrorType::TableRelation';
    //     end;

    //     procedure GetSimpleRelationInfo(DMTField: Record DMTField; var RelationTableNo: Integer; var RelationFieldNo: Integer) HasRelations: Boolean
    //     var
    //         TableRelationsMetadata: Record "Table Relations Metadata";
    //     begin
    //         TableRelationsMetadata.SetRange("Table ID", DMTField."To Table No.");
    //         TableRelationsMetadata.SetRange("Field No.", DMTField."To Field No.");
    //         if TableRelationsMetadata.FindFirst() then
    //             if (TableRelationsMetadata.Next() = 0) then begin
    //                 RelationTableNo := TableRelationsMetadata."Related Table ID";
    //                 RelationFieldNo := TableRelationsMetadata."Related Field No.";
    //             end;
    //     end;

    //     local procedure RelatedKeyFieldValue(DMTField: Record DMTField; TableID: Integer; RelatedTableID: Integer; RelatedFieldNo: Integer): Text[2048]
    //     var
    //         TableRelationsMetadata: Record "Table Relations Metadata";

    //     begin
    //         TableRelationsMetadata.SetRange("Table ID", TableID);
    //         TableRelationsMetadata.SetRange("Related Table ID", RelatedFieldNo);
    //         TableRelationsMetadata.SetRange("Related Field No.", RelatedFieldNo);
    //         if TableRelationsMetadata.FindFirst() then begin
    //             // ConfigPackageDataOtherFields.Get(
    //             //   ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."No.", TableRelationsMetadata."Field No.");
    //             // exit(ConfigPackageDataOtherFields.Value);
    //         end;
    //     end;

    //     local procedure DataExistsInTargetTable(FieldValue: Text; RelationTableNo: Integer; RelationFieldNo: Integer): Boolean
    //     var
    //         RecRef: RecordRef;
    //     begin
    //         RecRef.Open(RelationTableNo);

    //         RecRef.Field(RelationFieldNo).SetFilter(FieldValue);
    //     end;

    //     local procedure DataExistsInBufferTable(FieldValue: Text; RelationTableNo: Integer; RelationFieldNo: Integer): Boolean
    //     begin
    //         Error('ToDo');
    //     end;





    //     var
    //         ConfigPackageMgmt: Codeunit "Config. Package Management";
}