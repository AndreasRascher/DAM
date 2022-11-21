page 110017 "DMTProcessingInstructions"
{
    Caption = 'Processing Instructions';
    PageType = CardPart;
    SourceTable = DMTProcessingPlan;

    layout
    {
        area(content)
        {
            group("Filter")
            {
                Caption = 'Filter', Comment = 'Filter';
            }

            group("Fixed Value")
            {
                Caption = 'Fixed Values';
            }
        }
    }
}

