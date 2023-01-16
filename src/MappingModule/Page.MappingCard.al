page 110019 DMTMappingCard
{
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
}