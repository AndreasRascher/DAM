table 110037 DMTReplacementFieldSetup
{
    DataClassification = ToBeClassified;

    fields
    {
        //Mapping Code |DataFile ID | Mapping Field Type | Target Field ID
        field(1; "Replacement Code"; Code[100]) { Caption = 'Mapping Code'; TableRelation = DMTReplacement.Code; }
        field(2; "Data File ID"; Integer)
        {
            Caption = 'Datafile ID';
            TableRelation = DMTDataFile.ID;
        }
        field(3; "Mapping Field Type"; enum "DMTReplacementFieldType") { Caption = 'Field Type', Comment = 'Feldart'; }
        field(4; "Target Field No."; Integer)
        {
            Caption = 'Target Field No.', comment = 'Ziel Feldnr.';
            TableRelation = Field."No." where(TableNo = field("Target Table ID"));
        }
        field(10; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
    }
    keys
    {
        key(Key1; "Replacement Code", "Data File ID", "Mapping Field Type", "Target Field No.")
        {
            Clustered = true;
        }
    }

}