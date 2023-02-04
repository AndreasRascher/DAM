page 110018 DMTReplacements
{
    Caption = 'DMT Replacements';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTReplacement;
    CardPageId = DMTReplacementCard;
    SourceTableView = where(LineType = const(Header));
    DataCaptionFields = "Replacement Code", Description;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Replacement Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("No. of Lines"; Rec."No. of Lines") { ApplicationArea = All; }
            }
        }
    }
}