table 110040 DMTMappingRule
{
    Caption = 'Mapping Rule';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Mapping Code"; Code[100]) { Caption = 'Mapping Code'; TableRelation = DMTMapping.Code; }
        field(2; "Line No"; Integer) { Caption = 'Line No'; }
        field(10; "Original Value 1"; Text[250]) { Caption = 'Original Value 1', Comment = 'Urspr. Wert 1'; }
        field(11; "Original Value 2"; Text[250]) { Caption = 'Original Value 2', Comment = 'Urspr. Wert 2'; }
        field(20; "Mapping Value 1"; Text[250]) { Caption = 'Mapping Value 1'; }
        field(21; "Mapping Value 2"; Text[250]) { Caption = 'Mapping Value 2'; }
    }
    keys
    {
        key(Key1; "Mapping Code", "Line No") { Clustered = true; }
    }

    procedure GetCaption(FieldNo: Integer) FieldCaption: Text
    var
        Mapping: Record DMTMapping;
    begin
        if Rec.GetRangeMin("Mapping Code") = '' then
            Mapping.Get(Rec.GetRangeMin("Mapping Code"))
        else
            Mapping.Get(Rec."Mapping Code");
        case FieldNo of
            Rec.FieldNo("Original Value 1"):
                FieldCaption := '3,' + Mapping."Original Value 1 Caption";
            Rec.FieldNo("Original Value 2"):
                FieldCaption := '3,' + Mapping."Original Value 2 Caption";
            Rec.FieldNo("Mapping Value 1"):
                FieldCaption := '3,' + Mapping."Mapping Value 1 Caption";
            Rec.FieldNo("Mapping Value 2"):
                FieldCaption := '3,' + Mapping."Mapping Value 2 Caption";
        end;
    end;
}