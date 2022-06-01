page 91016 "DMTReplacementRules"
{
    Caption = 'DMT Replacement Rules', Comment = 'DMT Ersetzungsregeln';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTReplacementRule;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("To Table No."; Rec."To Table No.") { ApplicationArea = All; }
                field("To Field No."; Rec."To Field No.") { ApplicationArea = All; }
                field("New Value"; Rec."New Value") { ApplicationArea = All; }
                field("Old Value"; Rec."Old Value") { ApplicationArea = All; }
            }
        }
    }
}