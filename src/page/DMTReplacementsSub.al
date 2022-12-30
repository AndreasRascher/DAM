page 110009 DMTReplacementsSub
{
    Caption = 'Line', Comment = 'Zeilen';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacementsLine;
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Old Value"; Rec."Old Value") { ApplicationArea = All; }
                field("New Value"; Rec."New Value") { ApplicationArea = All; }
            }
        }
    }
}