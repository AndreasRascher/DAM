page 50007 "DMTReplacementsAssignedSub"
{
    Caption = 'Lines', Comment = 'Zeilen';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTField;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; }
                field("To Table No."; Rec."To Table No.") { ApplicationArea = All; }
                field("To Field No."; Rec."To Field No.") { ApplicationArea = All; }
                field("Replacements Code"; Rec."Replacements Code") { ApplicationArea = All; }
            }
        }
    }
}