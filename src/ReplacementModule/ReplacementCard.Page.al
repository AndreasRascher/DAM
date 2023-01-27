page 110019 DMTReplacementCard
{
    Caption = 'DMT Replacement Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = DMTReplacement;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; Importance = Promoted; }
                field("No. of Orginal Fields"; Rec."No. of From Fields")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    trigger OnValidate()
                    begin
                        CurrPage.Rules.Page.EnableControls(Rec);
                        EnableControls(Rec);
                    end;
                }
                field("No. of Mapping Fields"; Rec."No. of To Fields")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
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
                grid(FieldDefGrid)
                {
                    ShowCaption = false;
                    GridLayout = Rows;
                    group(GridLabels)
                    {
                        Caption = ' ', Locked = true;
                        label(FieldCaption) { Caption = 'Caption'; }
                        label("Rel.to Table ID") { Caption = 'Rel.to Table ID'; }
                        label("Rel.to Table Name") { Caption = 'Rel.to Table'; }
                        // field("From Value 1 Caption"; Rec."From Value 1 Caption") { ApplicationArea = All; Caption = 'Caption'; }
                        // field("Rel.to Table ID (Value 1)"; Rec."Rel.to Table ID (Value 1)") { ApplicationArea = All; Caption = 'Rel.to Table ID'; }
                        // field("Rel.Table Caption (Value 1)"; Rec."Rel.Table Caption (Value 1)") { ApplicationArea = All; Caption = 'Rel.to Table Name'; }
                    }
                    group(FromField1Group)
                    {
                        Caption = 'From Value 1';
                        field("From Value 1 Caption"; Rec."From Value 1 Caption") { ApplicationArea = All; ShowCaption = false; }
                    }
                    group(FromField2Group)
                    {
                        Caption = 'From Value 2';
                        Visible = FromValue2_Visible;
                        field("From Value 2 Caption"; Rec."From Value 2 Caption") { ApplicationArea = All; ShowCaption = false; }
                    }
                    group(ToFieldGroup1)
                    {
                        Caption = 'To Value 1';
                        field("To Value 1 Caption"; Rec."To Value 1 Caption") { ApplicationArea = All; ShowCaption = false; }
                        field("Rel.to Table ID (Value 1)"; Rec."Rel.to Table ID (To Value 1)") { ApplicationArea = All; ShowCaption = false; }
                        field("Rel.Table Caption (Value 1)"; Rec."Rel.Table Caption (To Value 1)") { ApplicationArea = All; ShowCaption = false; }
                    }
                    group(ToFieldGroup2)
                    {
                        Visible = ToValue2_Visible;
                        Caption = 'To Value 2';
                        field("To Value 2 Caption"; Rec."To Value 2 Caption") { ApplicationArea = All; ShowCaption = false; }
                        field("Rel.to Table ID (To Value 2)"; Rec."Rel.to Table ID (Value 2)") { ApplicationArea = All; ShowCaption = false; }
                        field("Rel.Table Caption (To Value 2)"; Rec."Rel.Table Caption (To Value 2)") { ApplicationArea = All; ShowCaption = false; }

                    }
                }
                // group(FromField1Group)
                // {
                //     Caption = 'From Value 1';
                //     field("From Value 1 Caption"; Rec."From Value 1 Caption") { ApplicationArea = All; Caption = 'Caption'; }
                //     field("Rel.to Table ID (Value 1)"; Rec."Rel.to Table ID (Value 1)") { ApplicationArea = All; Caption = 'Rel.to Table ID'; }
                //     field("Rel.Table Caption (Value 1)"; Rec."Rel.Table Caption (Value 1)") { ApplicationArea = All; Caption = 'Rel.to Table Name'; }
                // }
                // group(FromField2Group)
                // {
                //     Caption = 'From Value 2';
                //     field("From Value 2 Caption"; Rec."From Value 2 Caption") { ApplicationArea = All; Caption = 'Caption'; }
                //     field("Rel.to Table ID (Value 2)"; Rec."Rel.to Table ID (Value 2)") { ApplicationArea = All; Caption = 'Rel.to Table ID'; }
                //     field("Rel.Table Caption (Value 2)"; Rec."Rel.Table Caption (Value 2)") { ApplicationArea = All; Caption = 'Rel.to Table Name'; }
                // }
                // group(ToFieldGroup)
                // {
                //     Caption = 'To Values';
                //     field("To Value 1 Caption"; Rec."To Value 1 Caption") { ApplicationArea = All; }
                //     field("To Value 2 Caption"; Rec."To Value 2 Caption") { ApplicationArea = All; }
                // }
            }
            part(Rules; DMTReplacementRulesPart)
            {
                SubPageLink = "Replacement Code" = field(Code);
                UpdatePropagation = SubPart;
            }
        }
    }

    actions
    {
    }
    internal procedure EnableControls(Mapping: Record DMTReplacement)
    begin
        if UpdateVisiblity(Mapping) then
            CurrPage.Update();
    end;

    local procedure UpdateVisiblity(var Mapping: Record DMTReplacement) DoUpdate: Boolean
    var
        OldValue: Boolean;
    begin
        OldValue := Mapping."No. of From Fields" in [Mapping."No. of From Fields"::"2"];
        FromValue2_Visible := Mapping."No. of From Fields" in [Mapping."No. of From Fields"::"2"];
        if FromValue2_Visible <> OldValue then
            DoUpdate := true;

        OldValue := Mapping."No. of From Fields" in [Mapping."No. of To Fields"::"2"];
        ToValue2_Visible := Mapping."No. of To Fields" in [Mapping."No. of To Fields"::"2"];
        if FromValue2_Visible <> OldValue then
            DoUpdate := true;
    end;

    trigger OnAfterGetRecord()
    begin
        EnableControls(Rec);
        CurrPage.Rules.Page.EnableControls(Rec);
    end;

    var
        FromValue2_Visible, ToValue2_Visible : Boolean;
}