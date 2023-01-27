table 110040 DMTReplacementRule
{
    Caption = 'Mapping Rule';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Replacement Code"; Code[100]) { Caption = 'Replacement Code'; TableRelation = DMTReplacement.Code; }
        field(2; "Line No"; Integer) { Caption = 'Line No'; }
        field(10; "From Value 1"; Text[250]) { Caption = 'Original Value 1', Comment = 'Urspr. Wert 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("From Value 1")); }
        field(11; "From Value 2"; Text[250]) { Caption = 'Original Value 2', Comment = 'Urspr. Wert 2'; CaptionClass = Rec.GetCaption(Rec.FieldNo("From Value 2")); }
        field(20; "To Value 1"; Text[250]) { Caption = 'To Value 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("To Value 1")); }
        field(21; "To Value 2"; Text[250]) { Caption = 'To Value 2'; CaptionClass = Rec.GetCaption(Rec.FieldNo("To Value 1")); }
    }
    keys
    {
        key(Key1; "Replacement Code", "Line No") { Clustered = true; }
    }

    internal procedure GetCaption(FieldNo: Integer) FieldCaption: Text
    var
        Mapping: Record DMTReplacement;
        ReplacementRule: Record DMTReplacementRule;
        CurrentFilter: Text;
        CustomFieldCaption: Text;
    begin
        // GetPagePartFilter
        ReplacementRule.Copy(Rec);
        ReplacementRule.FilterGroup(4);
        CurrentFilter := ReplacementRule.GetFilter("Replacement Code");
        if CurrentFilter in [''/*Not loaded*/, ''''''/*New header Record with empty code*/] then
            exit('');
        if not Mapping.Get(ReplacementRule."Replacement Code") then
            exit;

        case FieldNo of
            Rec.FieldNo("From Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("From Value 1");
                    CustomFieldCaption := Mapping."From Value 1 Caption";
                end;
            Rec.FieldNo("From Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("From Value 2");
                    CustomFieldCaption := Mapping."From Value 2 Caption";

                end;
            Rec.FieldNo("To Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("To Value 1");
                    CustomFieldCaption := Mapping."To Value 1 Caption";
                end;
            Rec.FieldNo("To Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("To Value 2");
                    CustomFieldCaption := Mapping."To Value 2 Caption";
                end;
        end;
        if CustomFieldCaption <> '' then
            exit('3,' + CustomFieldCaption)
        else
            exit('3,' + FieldCaption);
    end;

    internal procedure FilterFor(Replacement: Record DMTReplacement) HasLinesInFilter: Boolean
    begin
        Rec.SetRange("Replacement Code", Replacement.Code);
        exit(not Rec.IsEmpty);
    end;
}