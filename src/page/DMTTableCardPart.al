page 110013 "DMTTableCardPart"
{
    PageType = ListPart;
    SourceTable = "DMTField";
    InsertAllowed = false;
    SourceTableView = sorting("Validation Order");

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Processing Action"; rec."Processing Action") { ApplicationArea = all; }
                field("To Field No."; Rec."Target Field No.") { Visible = false; ApplicationArea = All; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; StyleExpr = LineStyleExpr; Editable = false; }
                field("From Field Caption"; Rec."Source Field Caption")
                {
                    Editable = false;
                    HideValue = HideFromFieldInfo;
                    ApplicationArea = All;
                }
                field("From Field No."; Rec."Source Field No.") { LookupPageId = DMTFieldLookup; HideValue = HideFromFieldInfo; ApplicationArea = All; }
                field("Ignore Validation Error"; Rec."Ignore Validation Error") { ApplicationArea = All; }
                field("Trgt.Field Type"; Rec."Target Field Type") { Visible = false; ApplicationArea = All; }
                field("From Field Type"; Rec."Source Field Type") { HideValue = HideFromFieldInfo; Visible = false; ApplicationArea = All; }
                field("Validate Value"; Rec."Validate Value") { ApplicationArea = All; }
                field("Use Try Function"; Rec."Use Try Function") { ApplicationArea = All; }
                field("Fixed Value"; Rec."Fixed Value") { ApplicationArea = All; }
                field(ReplacementsCode; Rec."Replacements Code") { ApplicationArea = All; }
                field(ValidationOrder; Rec."Validation Order") { ApplicationArea = All; Visible = false; }
                field(Comment; Rec.Comment) { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InitTargetFields)
            {
                Caption = 'Init Target Fields', comment = 'Feldliste initialisieren';
                ApplicationArea = All;
                Image = SuggestField;


                trigger OnAction()
                var
                    DMTFields: Record "DMTField";
                    DMTTable: Record DMTTable;
                begin
                    DMTTable.Get(Rec.GetRangeMin(rec."Target Table ID"));
                    DMTFields.InitForTargetTable(DMTTable);
                end;
            }
            action(ProposeMatchingFields)
            {
                Caption = 'Popose Matching Fields', comment = 'Feldzuordnung vorschlagen';
                ApplicationArea = All;
                Image = SuggestField;
                trigger OnAction()
                begin
                    PageActions.ProposeMatchingFields(Rec);
                end;
            }
            group(Lines)
            {
                Caption = 'Lines', Comment = 'Zeilen';
                action(DMTField_SetValidateFieldToTrue)
                {
                    Caption = 'Set Field Validate to True', Comment = 'Feld Validieren auf Ja setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempDMTFieldSelected);
                        PageActions.DMTField_SetValidateField(TempDMTFieldSelected, true);
                    end;
                }
                action(DMTField_SetValidateFieldToFalse)
                {
                    Caption = 'Set Field Validate to False', Comment = 'Feld Validieren auf Nein setzen';
                    ApplicationArea = All;
                    Image = SetupLines;
                    trigger OnAction()
                    begin
                        GetSelection(TempDMTFieldSelected);
                        PageActions.DMTField_SetValidateField(TempDMTFieldSelected, false);
                    end;
                }
            }
            group(ChangeValidationOrder)
            {
                Image = Allocate;
                Caption = 'Change Validation Order', Comment = 'Validierungsreihenfolge ändern';
                action(MoveSelectedUp)
                {
                    ApplicationArea = All;
                    Caption = 'Up', Comment = 'Oben';
                    // Scope = Repeater;
                    Image = MoveUp;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Up);
                    end;
                }
                action(MoveSelectedDown)
                {
                    ApplicationArea = All;
                    Caption = 'Down', Comment = 'Unten';
                    // Scope = Repeater;
                    Image = MoveDown;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Down);
                    end;
                }
                action(MoveSelectedToTop)
                {
                    ApplicationArea = All;
                    Caption = 'Top', Comment = 'Anfang';
                    // Scope = Repeater;
                    Image = ChangeTo;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Top);
                    end;
                }
                action(MoveSelectedToEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Bottom', Comment = 'Ende';
                    // Scope = Repeater;
                    Image = Apply;
                    trigger OnAction()
                    var
                        Direction: Option Up,Down,Top,Bottom;
                    begin
                        MoveSelectedLines(Direction::Bottom);
                    end;
                }
            }
        }
    }

    procedure GetSelection(var TempDMTField_SELECTED: Record DMTField temporary) HasLines: Boolean
    var
        DMTField: Record DMTField;
        Debug: Integer;
    begin
        Clear(TempDMTField_SELECTED);
        if TempDMTField_SELECTED.IsTemporary then TempDMTField_SELECTED.DeleteAll();
        Debug := Rec.Count;
        DMTField.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(DMTField);
        Debug := DMTField.Count;
        DMTField.CopyToTemp(TempDMTField_SELECTED);
        HasLines := TempDMTField_SELECTED.FindFirst();
    end;

    local procedure MoveSelectedLines(Direction: Option Up,Down,Top,Bottom)
    var
        DMTField: Record DMTField;
        TempFieldSelection, TempDMTField : Record DMTField temporary;
        i: Integer;
        RefPos: Integer;
    begin
        If not GetSelection(TempFieldSelection) then
            exit;

        DMTField.SetRange("Target Table ID", TempFieldSelection."Target Table ID");
        DMTField.SetCurrentKey("Validation Order");
        DMTField.CopyToTemp(TempDMTField);

        TempDMTField.SetCurrentKey("Validation Order");
        case Direction of
            Direction::Bottom:
                begin
                    TempDMTField.FindLast();
                    RefPos := TempDMTField."Validation Order";
                    TempFieldSelection.FindSet();
                    repeat
                        i += 1;
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        TempDMTField."Validation Order" := RefPos + i * 10000;
                        TempDMTField.Modify();
                    until TempFieldSelection.Next() = 0;
                end;
            Direction::Top:
                begin
                    TempDMTField.FindFirst();
                    RefPos := TempDMTField."Validation Order";
                    TempFieldSelection.find('+');
                    repeat
                        i += 1;
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        TempDMTField."Validation Order" := RefPos - i * 10000;
                        TempDMTField.Modify();
                    until TempFieldSelection.Next(-1) = 0;
                end;
            Direction::Up:
                begin
                    TempFieldSelection.FindSet();
                    repeat
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        RefPos := TempDMTField."Validation Order";
                        if TempDMTField.Next(-1) <> 0 then begin
                            i := TempDMTField."Validation Order";
                            TempDMTField."Validation Order" := RefPos;
                            TempDMTField.Modify();
                            TempDMTField.Get(TempFieldSelection.RecordId);
                            TempDMTField."Validation Order" := i;
                            TempDMTField.Modify();
                        end;
                    until TempFieldSelection.Next() = 0;
                end;
            Direction::Down:
                begin
                    TempFieldSelection.SetCurrentKey("Validation Order");
                    TempFieldSelection.Ascending(false);
                    TempFieldSelection.FindSet();
                    repeat
                        TempDMTField.Get(TempFieldSelection.RecordId);
                        RefPos := TempDMTField."Validation Order";
                        if TempDMTField.Next(1) <> 0 then begin
                            i := TempDMTField."Validation Order";
                            TempDMTField."Validation Order" := RefPos;
                            TempDMTField.Modify();
                            TempDMTField.Get(TempFieldSelection.RecordId);
                            TempDMTField."Validation Order" := i;
                            TempDMTField.Modify();
                        end;
                    until TempFieldSelection.Next() = 0;
                end;
        end;
        TempDMTField.Reset();
        TempDMTField.SetCurrentKey("Validation Order");
        TempDMTField.FindSet();
        Clear(i);
        repeat
            i += 1;
            DMTField.Get(TempDMTField.RecordId);
            DMTField."Validation Order" := i * 10000;
            DMTField.Modify(false);
        until TempDMTField.Next() = 0;
    end;

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

    Var
        PageActions: Codeunit DMTPageActions;
        TempDMTFieldSelected: Record DMTField temporary;
        [InDataSet]
        HideFromFieldInfo: Boolean;
        [InDataSet]
        LineStyleExpr: text;
}