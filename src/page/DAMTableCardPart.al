page 90002 "DAMTableCardPart"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMFields;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Processing Action"; "Processing Action") { ApplicationArea = all; }
                field("To Field No."; Rec."To Field No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Trgt.Field No. field';
                    ApplicationArea = All;
                }
                field("To Field Caption"; Rec."To Field Caption")
                {
                    ToolTip = 'Specifies the value of the Trgt.Field Caption field';
                    ApplicationArea = All;
                }
                field("From Field Caption"; Rec."From Field Caption")
                {
                    HideValue = HideFromFieldInfo;
                    ToolTip = 'Specifies the value of the Src.Field Caption field';
                    ApplicationArea = All;
                }
                field("From Field No."; Rec."From Field No.")
                {
                    HideValue = HideFromFieldInfo;
                    ToolTip = 'Specifies the value of the Src.Field No. field';
                    ApplicationArea = All;
                }
                field("Ignore Validation Error"; Rec."Ignore Validation Error")
                {
                    ToolTip = 'Specifies the value of the Ignore Validation Error field';
                    ApplicationArea = All;
                }
                field("Trgt.Field Type"; Rec."To Field Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Trgt.Field Type field';
                    ApplicationArea = All;
                }
                field("From Field Type"; Rec."From Field Type")
                {
                    HideValue = HideFromFieldInfo;
                    ToolTip = 'Specifies the value of the Src.Field Type field';
                    ApplicationArea = All;
                }
                field("Validate Method"; Rec."Validate Method")
                {
                    ToolTip = 'Specifies the value of the Validate Method field';
                    ApplicationArea = All;
                }
                field("Validate Value"; Rec."Validate Value")
                {
                    ToolTip = 'Specifies the value of the Validate Value field';
                    ApplicationArea = All;
                }
                field("Default Value"; Rec."Fixed Value")
                {
                    ToolTip = 'Specifies the value of the Default Value field';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InitTargetFields)
            {
                CaptionML = DEU = 'Feldliste initialisieren', ENU = 'Init Target Fields';
                ApplicationArea = All;
                Image = SuggestField;


                trigger OnAction()
                var
                    DAMFields: Record DAMFields;
                    DAMTable: Record DAMTable;
                begin
                    DAMTable.Get(Rec.GetRangeMin(rec.Code));
                    DAMFields.InitForTargetTable(DAMTable);
                end;
            }
            action(ProposeMatchingFields)
            {
                CaptionML = DEU = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;

                trigger OnAction()
                var
                    DAMFields: Record DAMFields;
                    DAMTable: Record DAMTable;
                begin
                    DAMTable.Get(Rec.GetRangeMin(rec.Code));
                    DAMFields.ProposeMatchingTargetFields(DAMTable);
                    DAMFields.ProposeValidationRules(DAMTable);
                end;
            }
        }
    }
    Var
        [InDataSet]
        HideFromFieldInfo: Boolean;

    trigger OnAfterGetRecord()
    begin
        HideFromFieldInfo := Rec."Fixed Value" <> '';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HideFromFieldInfo := Rec."Fixed Value" <> '';
    end;
}