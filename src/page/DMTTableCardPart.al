page 81132 "DMTTableCardPart"
{
    PageType = ListPart;
    SourceTable = "DMTField";

    layout
    {
        area(Content)
        {
            repeater(Lines)
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
                field("From Field Caption (GenBufferTable)"; Rec."From Field Caption (GenBuff)")
                {
                    Visible = ShowGenBufferTableColumns;
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        RunSelectSourceFieldDialog();
                    end;
                }
                field("From Field No."; Rec."From Field No.")
                {
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                }
                field("Ignore Validation Error"; Rec."Ignore Validation Error")
                {
                    ApplicationArea = All;
                }
                field("Trgt.Field Type"; Rec."To Field Type")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("From Field Type"; Rec."From Field Type")
                {
                    HideValue = HideFromFieldInfo;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Validate Value"; Rec."Validate Value") { ApplicationArea = All; }
                field("Use Try Function"; Rec."Use Try Function") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
                field("Replacements Code"; Rec."Replacements Code") { ApplicationArea = All; }
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

    procedure RunSelectSourceFieldDialog()
    var
        GenBuffTable: Record DMTGenBuffTable;
        DMTTable: Record DMTTable;
        DMTField2: Record DMTField;
        BuffTableCaptions: Dictionary of [Integer, Text];
        Choices: Text;
        SelectedFieldNo: Integer;
        FieldCaption: Text;
    begin
        DMTTable.Get(Rec."To Table No.");
        GenBuffTable.GetColCaptionForImportedFile(DMTTable, BuffTableCaptions);
        foreach FieldCaption in BuffTableCaptions.Values do begin
            Choices += FieldCaption + ',';
        end;
        SelectedFieldNo := StrMenu(Choices);
        if SelectedFieldNo <> 0 then begin
            DMTField2 := Rec;
            DMTField2."From Field No." := SelectedFieldNo;
            DMTField2."From Field Caption (GenBuff)" := CopyStr(BuffTableCaptions.Get(SelectedFieldNo), 1, MaxStrLen(DMTField2."From Field Caption (GenBuff)"));
            DMTField2.Modify();
        end;
    end;
}