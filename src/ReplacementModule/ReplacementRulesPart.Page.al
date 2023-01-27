page 110020 DMTReplacementRulesPart
{
    Caption = 'Mapping Rules';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacementRule;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Original Value 1"; Rec."From Value 1") { ApplicationArea = All; }
                field("Original Value 2"; Rec."From Value 2") { ApplicationArea = All; Visible = OriginalValue2_Visible; }
                field(MappingValue1; Rec."To Value 1") { ApplicationArea = All; }
                field(MappingValue2; Rec."To Value 2") { ApplicationArea = All; Visible = MappingValue2_Visible; }
            }
        }
    }

    actions
    {
    }

    internal procedure EnableControls(Mapping: Record DMTReplacement)
    begin
        OriginalValue2_Visible := Mapping."No. of From Fields" in [Mapping."No. of From Fields"::"2"];
        MappingValue2_Visible := Mapping."No. of To Fields" in [Mapping."No. of To Fields"::"2"];
        CurrPage.Update();
    end;

    var
        OriginalValue2_Visible, MappingValue2_Visible : Boolean;
}