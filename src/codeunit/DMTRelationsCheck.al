codeunit 81127 RelationsCheck
{

    procedure ValidateTableRelation(DMTField: Record DMTField; FieldValue: Text)
    var
        RelationTableNo, RelationFieldNo : Integer;
        ErrorText: Text;
    begin
        if FieldValue = '' then
            exit;
        if GetSimpleRelationInfo(DMTField, RelationTableNo, RelationFieldNo) then
            if not DataExistsInTargetTable(FieldValue, RelationTableNo, RelationFieldNo) then
                if not DataExistsInBufferTable(FieldValue, RelationTableNo, RelationFieldNo) then
                    ErrorText := 'ToDo EnumErrorType::TableRelation';
    end;

    procedure GetSimpleRelationInfo(DMTField: Record DMTField; var RelationTableNo: Integer; var RelationFieldNo: Integer) HasRelations: Boolean
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SetRange("Table ID", DMTField."To Table No.");
        TableRelationsMetadata.SetRange("Field No.", DMTField."To Field No.");
        if TableRelationsMetadata.FindFirst() then
            if (TableRelationsMetadata.Next() = 0) then begin
                RelationTableNo := TableRelationsMetadata."Related Table ID";
                RelationFieldNo := TableRelationsMetadata."Related Field No.";
            end;
    end;

    local procedure RelatedKeyFieldValue(DMTField: Record DMTField; TableID: Integer; RelatedTableID: Integer; RelatedFieldNo: Integer): Text[2048]
    var
        TableRelationsMetadata: Record "Table Relations Metadata";

    begin
        TableRelationsMetadata.SetRange("Table ID", TableID);
        TableRelationsMetadata.SetRange("Related Table ID", RelatedFieldNo);
        TableRelationsMetadata.SetRange("Related Field No.", RelatedFieldNo);
        if TableRelationsMetadata.FindFirst() then begin
            // ConfigPackageDataOtherFields.Get(
            //   ConfigPackageData."Package Code", ConfigPackageData."Table ID", ConfigPackageData."No.", TableRelationsMetadata."Field No.");
            // exit(ConfigPackageDataOtherFields.Value);
        end;
    end;

    local procedure DataExistsInTargetTable(FieldValue: Text; RelationTableNo: Integer; RelationFieldNo: Integer): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(RelationTableNo);

        RecRef.Field(RelationFieldNo).SetFilter(FieldValue);
    end;

    local procedure DataExistsInBufferTable(FieldValue: Text; RelationTableNo: Integer; RelationFieldNo: Integer): Boolean
    begin
        Error('ToDo');
    end;





    var
        ConfigPackageMgmt: Codeunit "Config. Package Management";
}