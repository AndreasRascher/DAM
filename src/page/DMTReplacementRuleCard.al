page 91018 "DMTReplacementsCard"
{
    Caption = 'DMT Replacements Card', Comment = 'DMT Ersetzungen Karte';
    PageType = Document;
    UsageCategory = None;
    SourceTable = DMTReplacementsHeader;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General', Comment = 'Allgemein';
                field("Code"; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
            part(Lines; DMTReplacementRuleSub)
            {
                ApplicationArea = All;
                Caption = 'Lines', Comment = 'Zeilen';
                SubPageLink = "Repl.Rule Code" = field(Code);
            }
        }
    }
}