table 110047 DMTMappingValue
{
    fields
    {
        field(1; "Mapping Code"; Code[50]) { Caption = 'Mapping Code'; TableRelation = DMTMapping; }
        field(2; "Target Table No."; Integer) { Caption = 'Target Table No.'; }
        field(3; "Target Field No."; Integer) { Caption = 'Target Field No.'; }
        field(4; "New Value"; Text[250]) { Caption = 'New Value'; }
    }

    keys
    {
        key(Key1; "Mapping Code", "Target Table No.", "Target Field No.") { Clustered = true; }
    }

}