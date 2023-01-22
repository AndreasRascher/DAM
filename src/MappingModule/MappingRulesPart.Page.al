page 110020 DMTMappingRulesPart
{
    Caption = 'Lines';
    PageType = ListPart;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTReplacementRule;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Original Value 1"; Rec."Original Value 1") { ApplicationArea = All; CaptionClass = Rec.GetCaption(Rec.FieldNo("Original Value 1")); }
                field("Original Value 2"; Rec."Original Value 2") { ApplicationArea = All; Visible = OriginalValue2_Visible; CaptionClass = Rec.GetCaption(Rec.FieldNo("Original Value 2")); }
                field(MappingValue1; Rec."Mapping Value 1") { ApplicationArea = All; CaptionClass = Rec.GetCaption(Rec.FieldNo("Mapping Value 1")); }
                field(MappingValue2; Rec."Mapping Value 2") { ApplicationArea = All; Visible = MappingValue2_Visible; CaptionClass = Rec.GetCaption(Rec.FieldNo("Mapping Value 2")); }
            }
        }
    }

    actions
    {
    }

    internal procedure EnableControls(Mapping: Record DMTReplacement)
    begin
        OriginalValue2_Visible := Mapping."No. of Conditions" in [Mapping."No. of Conditions"::"2"];
        MappingValue2_Visible := Mapping."No. of Replacement Fields" in [Mapping."No. of Replacement Fields"::"2"];
        CurrPage.Update();
    end;

    var
        OriginalValue2_Visible, MappingValue2_Visible : Boolean;
}