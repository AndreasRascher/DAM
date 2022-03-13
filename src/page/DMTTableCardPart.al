page 91003 "DMTTableCardPart"
{
    PageType = ListPart;
    SourceTable = "DMTField";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Processing Action"; rec."Processing Action") { ApplicationArea = all; }
                field("To Field No."; Rec."To Field No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("To Field Caption"; Rec."To Field Caption")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;
                }
                field("From Field Caption"; Rec."From Field Caption")
                {
                    Visible = not ShowGenBufferTableColumns;
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                }
                field("From Field Caption (GenBufferTable)"; "From Field Caption (GenBufferTable)")
                {
                    Visible = ShowGenBufferTableColumns;
                    Caption = 'test';
                    HideValue = HideFromFieldInfo;
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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Src.Field Type field';
                    ApplicationArea = All;
                }
                field("Validate Value"; Rec."Validate Value")
                {
                    ToolTip = 'Specifies the value of the Validate Value field';
                    ApplicationArea = All;
                }
                field("Use Try Function"; "Use Try Function") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
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
                    DMTFields: Record "DMTField";
                    DMTTable: Record DMTTable;
                begin
                    DMTTable.Get(Rec.GetRangeMin(rec."To Table No."));
                    DMTFields.InitForTargetTable(DMTTable);
                end;
            }
            action(ProposeMatchingFields)
            {
                CaptionML = DEU = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;

                trigger OnAction()
                var
                    DMTFields: Record "DMTField";
                    DMTTable: Record DMTTable;
                begin
                    DMTTable.Get(Rec.GetRangeMin(rec."To Table No."));
                    DMTFields.ProposeMatchingTargetFields(DMTTable);
                    DMTFields.ProposeValidationRules(DMTTable);
                end;
            }
        }
    }
    Var
        [InDataSet]
        HideFromFieldInfo: Boolean;
        [InDataSet]
        ShowGenBufferTableColumns: Boolean;
        [InDataSet]
        LineStyleExpr: text;

    trigger OnAfterGetRecord()
    begin
        UpdateControlVariables();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateControlVariables();
    end;

    procedure UpdateControlVariables()
    var
        DMTErrorLog: Record DMTErrorLog;
    begin
        HideFromFieldInfo := Rec."Fixed Value" <> '';
        LineStyleExpr := '';
        if DMTErrorLog.ErrorsExistFor(Rec, true) then
            LineStyleExpr := 'Attention';
    end;

    internal procedure SetBufferTableType(BufferTableType: Option)
    var
        DMTTable: Record DMTTable;
    begin
        ShowGenBufferTableColumns := BufferTableType = DMTTable.BufferTableType::"Generic Buffer Table for all Files";
        CurrPage.Update();
    end;
}