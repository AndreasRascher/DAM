page 81127 "DMTReplacementsCard"
{
    Caption = 'DMT Replacements Card', Comment = 'DMT Ersetzungen Karte';
    PageType = Document;
    UsageCategory = None;
    SourceTable = DMTReplacementsHeader;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'Allgemein';
                field("Code"; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Source Table ID"; Rec."Source Table ID") { ApplicationArea = All; }
                field("Source Table Caption"; Rec."Source Table Caption") { ApplicationArea = All; }
            }

            part(Lines; "DMTReplacementsSub")
            {
                ApplicationArea = All;
                Caption = 'Lines', Comment = 'Zeilen';
                SubPageLink = "Repl.Rule Code" = field(Code);
            }
            part(AssignedLines; "DMTReplacementsAssignedSub")
            {
                ApplicationArea = All;
                Caption = 'Assigned Lines', Comment = 'Zugeordnete Zeilen';
                SubPageLink = "Replacements Code" = field(Code);
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ProposeAssignments)
            {
                ApplicationArea = All;
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Propose Assignments', Comment = 'Zuordnung vorschlagen';
                trigger OnAction()
                begin
                    if Rec.Code <> '' then
                        CurrPage.SaveRecord();
                    Rec.proposeAssignments();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}