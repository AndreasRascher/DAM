page 110020 DMTMappingRulesPart
{
    Caption = 'Mapping Rules Part';
    PageType = ListPart;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTMappingRule;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Original Value"; Rec."Original Value") { ApplicationArea = All; }
                field(Conditions; Rec.Conditions)
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        // ConditionsAssistEdit(Rec);
                    end;
                }
                field(MappingValues; Rec.MappingValues)
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        // MappingValuesAssistEdit(Rec);
                    end;
                }
            }
        }
    }

    actions
    {
    }
}