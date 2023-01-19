table 110046 DMTMappingRule
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Mapping Code"; Code[100]) { Caption = 'Mapping Code'; TableRelation = DMTMapping.Code; }
        field(2; "Line No"; Integer) { Caption = 'Line No'; }
        field(10; "Original Value"; Text[250]) { Caption = 'Original Value', Comment = 'Urspr. Wert'; }
        field(20; Conditions; Text[250]) { Caption = 'Conditions'; }
        field(30; MappingValues; Text[250]) { Caption = 'Mapping Values'; }
    }
    keys
    {
        key(Key1; "Mapping Code", "Line No") { Clustered = true; }
    }
}