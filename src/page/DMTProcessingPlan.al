page 110015 DMTProcessingPlan
{
    Caption = 'DMT Processing Plan', Comment = 'de-DE Verarbeitungsplan';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTProcessingPlan;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field("Line Type"; Rec."Line Type") { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Action"; Rec."Action") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(DataFileID; Rec.DataFileID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; DMTProcessingInstructions)
            {
                Caption = 'Source Table Filter';
            }
            part(FixedValues; DMTProcessingInstructions)
            {
                Caption = 'Fields';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(ActionName)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction();
            //     begin

            //     end;
            // }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineStyle := '';
        if Rec."Line Type" = Rec."Line Type"::Group then
            LineStyle := format(Enum::DMTFieldStyle::Bold);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
    end;

    internal procedure GetSourceTableFilter(): Text
    begin
        Error('Procedure GetSourceTableFilter not implemented.');
    end;

    var
        LineStyle: Text;
}