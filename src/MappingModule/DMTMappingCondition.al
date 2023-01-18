table 110045 "DMTMappingCondition"
{
    fields
    {
        field(1; "Mapping Code"; Code[50]) { Caption = 'Mapping Code'; TableRelation = DMTMapping; }
        field(2; "Original Value"; Text[250]) { Caption = 'Original Value'; }
        field(3; "Comparison Type"; enum "DMTComparisonType") { Caption = 'Comparison Type'; }
        field(4; "Compare Value"; Text[250]) { Caption = 'Compare Value', Comment = 'de-DE=Vergleichswert'; }
    }
    keys
    {
        key(PK; "Mapping Code", "Original Value") { Clustered = true; }
    }
}