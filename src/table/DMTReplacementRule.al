table 91010 "DMTReplacementRule"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "To Table No."; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            DataClassification = SystemMetadata;
            TableRelation = DMTTable."To Table ID";
        }
        field(2; "To Field No."; Integer)
        {
            Caption = 'Target Field No.', Comment = 'Ziel Feldnr.';
            DataClassification = SystemMetadata;
            TableRelation = DMTField."To Field No." WHERE("To Table No." = field("To Table No."));
        }
        field(3; "Line No."; Integer) { Caption = 'Line No.', Comment = 'Zeilennr.'; }
        field(10; "Old Value"; Text[250]) { Caption = 'Old Value', Comment = 'Alter Wert'; }
        field(11; "New Value"; Text[250]) { Caption = 'New Value', Comment = 'Neuer Wert'; }
    }

    keys
    {
        key(PK; "To Table No.", "To Field No.", "Line No.") { Clustered = true; }
    }
    internal procedure FindRulesFor(DMTTable: record DMTTable) OK: Boolean
    begin
        Rec.Reset();
        Rec.SetRange("To Table No.", DMTTable."To Table ID");
        OK := Rec.FindSet(false, false);
    end;
}