codeunit 110008 DMTRelationsCheck
{
    procedure FindRelatedTableIDs(DMTTable: Record DMTTable) RelatedTableIDsList: List of [Integer]
    var
        DMTField: Record DMTField;
        TargetField: Record Field;
        TableRelations: record "Table Relations Metadata";
        ExcludeKnownTableIDsFromSearchFilter: Text;
    begin
        if not DMTField.FilterBy(DMTTable) then
            exit;
        DMTField.FindSet(false, false);
        repeat
            if TargetField.Get(DMTField."Target Table ID", DMTField."Target Field No.") then begin
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
        until DMTField.Next() = 0;
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
            if not DMTTable2.Get(TableID) then begin
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