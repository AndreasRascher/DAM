page 73025 DMTReplacementRulesPart
{
    Caption = 'Mapping';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacement;
    SourceTableView = sorting(LineType, "Replacement Code", "Line No.") where(LineType = const(Line));
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Original Value 1"; Rec."Comp.Value 1") { ApplicationArea = All; }
                field("Original Value 2"; Rec."Comp.Value 2") { ApplicationArea = All; Visible = OriginalValue2_Visible; }
                field("New Value 1"; Rec."New Value 1") { ApplicationArea = All; }
                field("New Value 2"; Rec."New Value 2") { ApplicationArea = All; Visible = MappingValue2_Visible; }
            }
        }
    }

    actions
    {
    }

    internal procedure EnableControls(Mapping: Record DMTReplacement)
    begin
        SetColumnVisibility(Mapping);
        CurrPage.Update();
    end;

    local procedure SetColumnVisibility(var Mapping: Record DMTReplacement)
    begin
        OriginalValue2_Visible := Mapping."No. of Compare Values" in [Mapping."No. of Compare Values"::"2"];
        MappingValue2_Visible := Mapping."No. of Values to modify" in [Mapping."No. of Values to modify"::"2"];
    end;


    var
        OriginalValue2_Visible, MappingValue2_Visible : Boolean;
}