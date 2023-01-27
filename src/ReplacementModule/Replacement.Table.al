table 110038 DMTReplacement
{
    Caption = 'DMT Replacement';
    LookupPageId = DMTReplacements;
    DrillDownPageId = DMTReplacements;
    fields
    {
        field(1; Code; Code[100]) { Caption = 'Code'; }
        field(2; Description; Text[250]) { Caption = 'Description'; }
        field(10; "No. of From Fields"; Option)
        {
            Caption = 'No. of Orginal Fields';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(20; "No. of To Fields"; Option)
        {
            Caption = 'No. of Mapping Fields';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(30; "To Value 1 Caption"; Text[80]) { Caption = 'To Value 1 Caption'; }
        field(31; "Rel.to Table ID (To Value 1)"; Integer)
        {
            Caption = 'Related to Table ID (Value 1)', Comment = 'Relation zu Tabellen ID (Wert 1)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.Table Caption (To Value 1)");
            end;
        }
        field(40; "To Value 2 Caption"; Text[80]) { Caption = 'To Value 2 Caption'; }
        field(41; "Rel.Table Caption (To Value 1)"; Text[100])
        {
            Caption = 'Related to Table (Value 1)', Comment = 'Relation zu Tabelle (Wert 1)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (To Value 1)")));
            Editable = false;
        }
        field(101; "From Value 1 Caption"; Text[80]) { Caption = 'From Value 1 Caption', Comment = 'Von Wert 1 Bezeichnung'; }

        field(201; "From Value 2 Caption"; Text[80]) { Caption = 'From Value 2 Caption', Comment = 'Von Wert 2 Bezeichnung'; }
        field(202; "Rel.to Table ID (Value 2)"; Integer)
        {
            Caption = 'Related to Table ID (Value 2)', Comment = 'Relation zu Tabellen ID (Wert 2)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.Table Caption (To Value 2)");
            end;
        }
        field(203; "Rel.Table Caption (To Value 2)"; Text[100])
        {
            Caption = 'Related to Table (To Value 2)', Comment = 'Relation zu Tabelle (Zu Wert 2)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (Value 2)")));
            Editable = false;
        }

    }

    keys
    {
        key(Key1; Code) { Clustered = true; }
    }

    trigger OnDelete()
    var
        ReplacementRule: Record DMTReplacementRule;
    begin
        if ReplacementRule.FilterFor(Rec) then
            ReplacementRule.DeleteAll(true);
    end;
}