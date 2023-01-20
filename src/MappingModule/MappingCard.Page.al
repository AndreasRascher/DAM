page 110019 DMTMappingCard
{
    Caption = 'DMT Mapping Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = DMTMapping;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("No. of Orginal Fields"; Rec."No. of Orginal Fields")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Rules.Page.EnableControls(Rec);
                        EnableControls(Rec);
                    end;
                }
                field("No. of Mapping Fields"; Rec."No. of Mapping Fields")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Rules.Page.EnableControls(Rec);
                        EnableControls(Rec);
                    end;
                }
            }
            group("Field Setup")
            {
                Caption = 'Field Setup';
                group(LeftColumn)
                {
                    ShowCaption = false;
                    field("Original Value 1 Caption"; Rec."Original Value 1 Caption") { ApplicationArea = All; ShowMandatory = true; }
                    group("Original Value 2")
                    {
                        ShowCaption = false;
                        Visible = OriginalValue2_Visible;
                        field("Original Value 2 Caption"; Rec."Original Value 2 Caption") { ApplicationArea = All; ShowMandatory = true; }
                    }
                }
                group(RightColumn)
                {
                    ShowCaption = false;
                    field("Mapping Value 1 Caption"; Rec."Mapping Value 1 Caption") { ApplicationArea = All; ShowMandatory = true; }
                    group("Mapping Value 2")
                    {
                        ShowCaption = false;
                        Visible = MappingValue2_Visible;
                        field("Mapping Value 2 Caption"; Rec."Mapping Value 2 Caption") { ApplicationArea = All; ShowMandatory = true; }
                    }
                }
            }
            part(Rules; DMTMappingRulesPart)
            {
                SubPageLink = "Mapping Code" = field(Code);
            }
        }
    }

    actions
    {
    }
    internal procedure EnableControls(Mapping: Record DMTMapping)
    begin
        OriginalValue2_Visible := Mapping."No. of Orginal Fields" in [Mapping."No. of Orginal Fields"::"2"];
        MappingValue2_Visible := Mapping."No. of Mapping Fields" in [Mapping."No. of Mapping Fields"::"2"];
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls(Rec);
    end;

    var
        OriginalValue2_Visible, MappingValue2_Visible : Boolean;
}